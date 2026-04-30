local addonName, DF = ...

-- ============================================================
-- FRAMES BARS MODULE
-- Contains resource bar and absorb bar logic
-- ============================================================

-- Local caching of frequently used globals for performance
local InCombatLockdown = InCombatLockdown
local UnitIsAFK = UnitIsAFK
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local UnitClass = UnitClass
local issecretvalue = issecretvalue or function() return false end
local pcall = pcall

-- ============================================================
-- RESOURCE BAR LOGIC
-- ============================================================

-- Centralized role and class filter check for resource bar visibility
-- Returns true if the resource bar should be shown for this unit
-- Unit must pass BOTH role filter AND class filter
function DF:ShouldShowResourceBar(unit, db)
    if not db.resourceBarEnabled then return false end

    -- Role filter
    local roleAllowed = false
    local hasAnyRoleFilter = db.resourceBarShowHealer or db.resourceBarShowTank or db.resourceBarShowDPS

    if hasAnyRoleFilter then
        local role = UnitGroupRolesAssigned(unit)
        local inSoloMode = not IsInGroup() and not IsInRaid()

        if inSoloMode and db.resourceBarShowInSoloMode then
            roleAllowed = true
        elseif role == "HEALER" then
            roleAllowed = db.resourceBarShowHealer == true
        elseif role == "TANK" then
            roleAllowed = db.resourceBarShowTank == true
        elseif role == "DAMAGER" then
            roleAllowed = db.resourceBarShowDPS == true
        elseif not role or role == "NONE" then
            -- Unassigned role (e.g. delves) — treat as DPS
            roleAllowed = db.resourceBarShowDPS == true
        end
    else
        local inSoloMode = not IsInGroup() and not IsInRaid()
        roleAllowed = inSoloMode and db.resourceBarShowInSoloMode == true
    end

    if not roleAllowed then return false end

    -- Class filter (unit must also pass)
    local classFilter = db.resourceBarClassFilter
    if classFilter then
        local _, classToken = UnitClass(unit)
        if classToken and classFilter[classToken] == false then
            return false
        end
    end

    return true
end

function DF:ApplyResourceBarLayout(frame)
    if not frame then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    -- The power bar is created in Frames/Create.lua
    if not frame.dfPowerBar then return end
    
    local bar = frame.dfPowerBar
    
    -- Check if resource bar should be shown
    if not db.resourceBarEnabled then
        bar:Hide()
        return
    end
    
    -- Need unit for role check
    if not frame.unit then
        bar:Hide()
        return
    end

    -- Check role-based filtering
    if not DF:ShouldShowResourceBar(frame.unit, db) then
        bar:Hide()
        return
    end

    -- Bar is visible - apply layout
    do
        bar:Show()
        bar:ClearAllPoints()

        -- Orientation & Fill Direction
        bar:SetOrientation(db.resourceBarOrientation or "HORIZONTAL")
        bar:SetReverseFill(db.resourceBarReverseFill)

        local isVertical = (db.resourceBarOrientation == "VERTICAL")
        local length = db.resourceBarWidth or 50
        local thickness = db.resourceBarHeight or 4

        -- Apply pixel-perfect adjustments
        local ppLength = db.pixelPerfect and DF:PixelPerfect(length) or length
        local ppThickness = db.pixelPerfect and DF:PixelPerfect(thickness) or thickness

        -- Compute health bar dimensions from settings instead of GetWidth/GetHeight
        -- which can return stale values before WoW's layout engine processes anchor changes
        local padding = db.framePadding or 0
        local frameWidth = db.frameWidth or 120
        local frameHeight = db.frameHeight or 50
        if db.pixelPerfect and DF.PixelPerfect then
            frameWidth = DF:PixelPerfect(frameWidth)
            frameHeight = DF:PixelPerfect(frameHeight)
            padding = DF:PixelPerfect(padding)
        end
        local healthBarWidth = frameWidth - (2 * padding)
        local healthBarHeight = frameHeight - (2 * padding)

        -- Account for frame border inset (matches other bar calculations)
        local borderInset = 0
        if db.showFrameBorder ~= false then
            borderInset = db.borderSize or 1
        end

        if isVertical then
            -- SWAP: "Width" Value applies to Height (Length), "Height" value applies to Width (Thickness)
            bar:SetWidth(ppThickness)
            bar:SetHeight(ppLength)

            if db.resourceBarMatchWidth then
                if healthBarHeight > 1 then
                    bar:SetHeight(healthBarHeight - (borderInset * 2))
                end
            end
        else
            -- NORMAL: "Width" Value applies to Width, "Height" value applies to Height
            bar:SetWidth(ppLength)
            bar:SetHeight(ppThickness)

            if db.resourceBarMatchWidth then
                if healthBarWidth > 1 then
                    bar:SetWidth(healthBarWidth - (borderInset * 2))
                end
            end
        end
        
        local anchor = db.resourceBarAnchor or "CENTER"
        bar:SetPoint(anchor, frame, anchor, db.resourceBarX or 0, db.resourceBarY or 0)
        
        -- Frame level - relative to the main frame, not health bar
        -- Default of 2 puts it below the frame border (which is at +10)
        -- Values above 10 will render above the frame border
        local frameLevelOffset = db.resourceBarFrameLevel or 2
        bar:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)
        
        -- Border frame level needs to be above the bar itself
        if bar.border then
            bar.border:SetFrameLevel(bar:GetFrameLevel() + 1)
        end
        
        -- Background visibility and color
        if bar.bg then
            if db.resourceBarBackgroundEnabled ~= false then  -- Default to enabled
                bar.bg:Show()
                local bgC = db.resourceBarBackgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                bar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a or 0.8)
            else
                bar.bg:Hide()
            end
        end
        
        -- Border visibility and color
        if bar.border then
            if db.resourceBarBorderEnabled then
                bar.border:Show()
                local borderC = db.resourceBarBorderColor or {r = 0, g = 0, b = 0, a = 1}
                bar.border:SetBackdropBorderColor(borderC.r, borderC.g, borderC.b, borderC.a or 1)
            else
                bar.border:Hide()
            end
        end

        -- Set power value and color immediately so the bar doesn't appear white
        local unit = frame.unit
        if unit and UnitExists(unit) then
            local power = UnitPower(unit)
            local maxPower = UnitPowerMax(unit)
            bar:SetMinMaxValues(0, maxPower)
            bar:SetValue(power)
            local pType, pToken, altR, altG, altB = UnitPowerType(unit)
            local info = DF:GetPowerColor(pToken, pType)
            local _, classToken = UnitClass(unit)
            local classColor = db.resourceBarClassColor and classToken and DF:GetClassColor(classToken)
            if classColor then
                bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
            elseif info then
                bar:SetStatusBarColor(info.r, info.g, info.b, 1)
            elseif altR then
                bar:SetStatusBarColor(altR, altG, altB, 1)
            else
                bar:SetStatusBarColor(0, 0, 1, 1)
            end
        end
    end
end

function DF:UpdateResourceBar(frame)
    if not frame or not frame.unit then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    if not db.resourceBarEnabled then return end
    if not frame.dfPowerBar or not frame.dfPowerBar:IsShown() then return end
    
    local bar = frame.dfPowerBar
    local unit = frame.unit
    
    -- Only process player, party, and raid units
    if unit ~= "player" and not unit:match("^party%d$") and not unit:match("^raid%d+$") then
        bar:Hide()
        return
    end
    
    -- Check unit exists
    if not UnitExists(unit) then 
        bar:Hide()
        return 
    end
    
    -- Get power values - check if they're secret values
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    
    if maxPower then
        bar:SetMinMaxValues(0, maxPower)
        DF.SetBarValue(bar, power, frame)
        
        -- Get power type for coloring
        local pType, pToken, altR, altG, altB = UnitPowerType(unit)
        
        -- Get color from custom overrides or Blizzard defaults
        local info = DF:GetPowerColor(pToken, pType)

        local _, classToken = UnitClass(unit)
        local classColor = db.resourceBarClassColor and classToken and DF:GetClassColor(classToken)
        if classColor then
            bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
        elseif info then
            bar:SetStatusBarColor(info.r, info.g, info.b, 1)
        elseif altR then
            bar:SetStatusBarColor(altR, altG, altB, 1)
        else
            bar:SetStatusBarColor(0, 0, 1, 1)  -- Default to blue (mana)
        end
    else
        bar:Hide()
    end
end

-- ============================================================
-- ABSORB BAR LOGIC
-- ============================================================
--
-- UpdateAbsorb performance pattern (2026-04-09):
--
-- UpdateAbsorb fires on UNIT_ABSORB_AMOUNT_CHANGED (plus cascading
-- calls from UpdateHealthFast, UpdateUnitFrame, FullFrameRefresh, and
-- several other sites). In raid combat it hits 90-100 calls per game
-- frame during Peak/tk bursts.
--
-- Pre-refactor the function did a full layout rebuild on every call:
-- 20+ frame API calls for anchors/strata/level/orientation, texture/
-- color/blend mode re-apply, overshield glow repositioning (another
-- 12+ API calls), etc. Almost all of this is layout state that only
-- changes when the user adjusts settings or the parent frame resizes.
-- The only things that genuinely change per-event are:
--
--   * maxHealth (UnitHealthMax) — occasionally (level up, stat procs)
--   * absorbs (UnitGetTotalAbsorbs) — every event (that's why we fire)
--   * For ATTACHED modes: `isClamped` from the absorb calculator —
--     this is secret-safe and changes per-event independently of
--     absorbs (the absorb amount vs current-missing-health ratio)
--
-- Fix: AbsorbLayoutStateChanged compares ~25 layout settings + parent
-- frame dimensions against values cached on frame.dfAbsorbState. If
-- nothing changed, we take a minimal fast path that only does the
-- value-related work. If anything changed, we run the full rebuild
-- (same code as before this refactor) and cache the new state at the
-- end.
--
-- This is the same pattern as the Dispel overlay refactor (commit
-- cd6746e), applied to UpdateAbsorb.
-- ============================================================

local DEFAULT_ABSORB_COLOR = {r = 0, g = 0.835, b = 1, a = 0.7}
local DEFAULT_ABSORB_BG_COLOR = {r = 0, g = 0, b = 0, a = 0.5}

-- Compare current absorb-bar layout settings against the cached state
-- on the frame. Returns true if anything that affects layout has
-- changed since the last full rebuild — which means we need to run
-- the full rebuild path. Returns false when everything matches, which
-- means we can take the minimal fast path.
local function AbsorbLayoutStateChanged(frame, db)
    local s = frame.dfAbsorbState
    if not s then return true end

    -- Mode + appearance (all modes)
    if s.mode            ~= (db.absorbBarMode or "OVERLAY")               then return true end
    if s.strata          ~= (db.absorbBarStrata or "MEDIUM")              then return true end
    if s.texture         ~= (db.absorbBarTexture or "Interface\\Buttons\\WHITE8x8") then return true end
    if s.blendMode       ~= (db.absorbBarBlendMode or "BLEND")            then return true end
    if s.pixelPerfect    ~= db.pixelPerfect                               then return true end
    if s.oorEnabled      ~= db.oorEnabled                                 then return true end
    if s.oorAlpha        ~= (db.oorAbsorbBarAlpha or 0.5)                 then return true end
    local col = db.absorbBarColor or DEFAULT_ABSORB_COLOR
    if s.colR ~= col.r or s.colG ~= col.g or s.colB ~= col.b or s.colA ~= (col.a or 0.7) then return true end

    -- Border settings (affect inset calculations for attached/overlay modes)
    if s.showFrameBorder ~= (db.showFrameBorder ~= false)                 then return true end
    if s.borderSize      ~= (db.borderSize or 1)                          then return true end

    -- Floating-mode specific
    if s.orientation     ~= (db.absorbBarOrientation or "HORIZONTAL")     then return true end
    if s.width           ~= (db.absorbBarWidth or 50)                     then return true end
    if s.height          ~= (db.absorbBarHeight or 6)                     then return true end
    if s.anchor          ~= (db.absorbBarAnchor or "CENTER")              then return true end
    if s.offsetX         ~= (db.absorbBarX or 0)                          then return true end
    if s.offsetY         ~= (db.absorbBarY or 0)                          then return true end
    if s.reverse         ~= db.absorbBarReverse                           then return true end
    if s.frameLevel      ~= (db.absorbBarFrameLevel or 10)                then return true end
    local bgC = db.absorbBarBackgroundColor or DEFAULT_ABSORB_BG_COLOR
    if s.bgR ~= bgC.r or s.bgG ~= bgC.g or s.bgB ~= bgC.b or s.bgA ~= bgC.a then return true end

    -- Attached/overlay-mode specific
    if s.healthOrient    ~= (db.healthOrientation or "HORIZONTAL")        then return true end
    if s.overlayReverse  ~= db.absorbBarOverlayReverse                    then return true end
    if s.clampMode       ~= (db.absorbBarAttachedClampMode or 1)          then return true end

    -- Parent dimensions (detects frame resize — relevant for attached/overlay modes)
    if frame.healthBar then
        if s.parentW ~= frame.healthBar:GetWidth()  then return true end
        if s.parentH ~= frame.healthBar:GetHeight() then return true end
    end

    -- Overshield settings (ATTACHED mode)
    if s.showOvershield    ~= db.absorbBarShowOvershield                  then return true end
    if s.overshieldStyle   ~= (db.absorbBarOvershieldStyle or "SPARK")    then return true end
    if s.overshieldAlpha   ~= (db.absorbBarOvershieldAlpha or 0.8)        then return true end
    if s.overshieldReverse ~= db.absorbBarOvershieldReverse               then return true end
    local osc = db.absorbBarOvershieldColor or db.absorbBarColor or DEFAULT_ABSORB_COLOR
    if s.overshieldR ~= osc.r or s.overshieldG ~= osc.g or s.overshieldB ~= osc.b then return true end

    return false
end

-- Cache the current layout settings on frame.dfAbsorbState. Called at
-- the end of a full rebuild so subsequent calls can short-circuit via
-- AbsorbLayoutStateChanged.
local function CacheAbsorbLayoutState(frame, db)
    local s = frame.dfAbsorbState
    if not s then
        s = {}
        frame.dfAbsorbState = s
    end
    s.mode            = db.absorbBarMode or "OVERLAY"
    s.strata          = db.absorbBarStrata or "MEDIUM"
    s.texture         = db.absorbBarTexture or "Interface\\Buttons\\WHITE8x8"
    s.blendMode       = db.absorbBarBlendMode or "BLEND"
    s.pixelPerfect    = db.pixelPerfect
    s.oorEnabled      = db.oorEnabled
    s.oorAlpha        = db.oorAbsorbBarAlpha or 0.5
    local col = db.absorbBarColor or DEFAULT_ABSORB_COLOR
    s.colR, s.colG, s.colB, s.colA = col.r, col.g, col.b, col.a or 0.7
    s.showFrameBorder = db.showFrameBorder ~= false
    s.borderSize      = db.borderSize or 1
    s.orientation     = db.absorbBarOrientation or "HORIZONTAL"
    s.width           = db.absorbBarWidth or 50
    s.height          = db.absorbBarHeight or 6
    s.anchor          = db.absorbBarAnchor or "CENTER"
    s.offsetX         = db.absorbBarX or 0
    s.offsetY         = db.absorbBarY or 0
    s.reverse         = db.absorbBarReverse
    s.frameLevel      = db.absorbBarFrameLevel or 10
    local bgC = db.absorbBarBackgroundColor or DEFAULT_ABSORB_BG_COLOR
    s.bgR, s.bgG, s.bgB, s.bgA = bgC.r, bgC.g, bgC.b, bgC.a
    s.healthOrient    = db.healthOrientation or "HORIZONTAL"
    s.overlayReverse  = db.absorbBarOverlayReverse
    s.clampMode       = db.absorbBarAttachedClampMode or 1
    if frame.healthBar then
        s.parentW = frame.healthBar:GetWidth()
        s.parentH = frame.healthBar:GetHeight()
    end
    s.showOvershield    = db.absorbBarShowOvershield
    s.overshieldStyle   = db.absorbBarOvershieldStyle or "SPARK"
    s.overshieldAlpha   = db.absorbBarOvershieldAlpha or 0.8
    s.overshieldReverse = db.absorbBarOvershieldReverse
    local osc = db.absorbBarOvershieldColor or db.absorbBarColor or DEFAULT_ABSORB_COLOR
    s.overshieldR, s.overshieldG, s.overshieldB = osc.r, osc.g, osc.b
end

-- Invalidate the absorb layout cache for a frame. Call this from any
-- code path that changes state the cache can't detect (e.g., the frame
-- itself being replaced or recreated).
function DF:InvalidateAbsorbLayout(frame)
    if frame then frame.dfAbsorbState = nil end
end

function DF:UpdateAbsorb(frame, testIndex)
    if not frame then return end
    if not frame.healthBar then return end

    -- PERF TEST: Skip if disabled (but allow test mode to still work)
    if DF.PerfTest and not DF.PerfTest.enableAbsorbs and not DF.testMode and not DF.raidTestMode then
        if frame.absorbBar then frame.absorbBar:Hide() end
        if frame.absorbOvershieldGlow then frame.absorbOvershieldGlow:Hide() end
        if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
        frame.dfAbsorbState = nil  -- invalidate so re-enabling does a full rebuild
        return
    end

    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    local mode = db.absorbBarMode or "OVERLAY"

    -- Get values - either from test data or real unit
    local maxHealth, absorbs

    if DF.testMode and testIndex ~= nil then
        local testData = DF:GetTestUnitData(testIndex)
        if testData then
            maxHealth = testData.maxHealth
            absorbs = testData.absorbPercent * maxHealth
        else
            maxHealth = 100000
            absorbs = 0
        end
    elseif DF.raidTestMode and testIndex ~= nil then
        local testData = DF:GetTestUnitData(testIndex, true)  -- true = raid
        if testData then
            maxHealth = testData.maxHealth
            absorbs = testData.absorbPercent * maxHealth
        else
            maxHealth = 100000
            absorbs = 0
        end
    else
        -- Only process player, party, and raid units for real data
        if not unit or (unit ~= "player" and not unit:match("^party%d$") and not unit:match("^raid%d+$")) then
            return
        end

        -- Ensure unit exists before querying
        if not UnitExists(unit) then
            return
        end

        -- Get values - StatusBar API handles secret values internally via SetMinMaxValues
        maxHealth = UnitHealthMax(unit)
        absorbs = UnitGetTotalAbsorbs(unit)
    end

    -- ========================================================
    -- FAST PATH: layout state unchanged since last rebuild
    -- ========================================================
    -- The common case in combat: settings/mode/dimensions are stable,
    -- only the absorb value (and possibly isClamped for ATTACHED modes)
    -- has changed. Skip ~90% of the function body.
    local customBar = frame.dfAbsorbBar
    if customBar and customBar:IsShown() and not AbsorbLayoutStateChanged(frame, db) then
        if mode == "ATTACHED" or mode == "ATTACHED_OVERFLOW" then
            -- Need the calculator for clamped state (secret, can't cache).
            -- The calculator object itself is already cached on the frame.
            local attachedAbsorbs = absorbs
            local isClamped = false
            if frame.absorbCalculator and unit and CreateUnitHealPredictionCalculator then
                UnitGetDetailedHealPrediction(unit, nil, frame.absorbCalculator)
                if frame.absorbCalculator.GetDamageAbsorbs then
                    local r1, r2 = frame.absorbCalculator:GetDamageAbsorbs()
                    if r1 then
                        attachedAbsorbs = r1
                        isClamped = r2
                    end
                end
            end

            customBar:SetMinMaxValues(0, maxHealth)
            DF.SetBarValue(customBar, attachedAbsorbs, frame)

            if mode == "ATTACHED_OVERFLOW" and frame.absorbOverflowBar then
                -- Overflow bar gets the unclamped absorb amount
                frame.absorbOverflowBar:SetMinMaxValues(0, maxHealth)
                DF.SetBarValue(frame.absorbOverflowBar, absorbs, frame)

                -- Compute the OOR-adjusted "visible" alpha
                local visAlpha = 1
                if db.oorEnabled then
                    local inRange = frame.dfInRange
                    if not (issecretvalue and issecretvalue(inRange)) and inRange == false then
                        visAlpha = db.oorAbsorbBarAlpha or 0.5
                    end
                end

                -- Secret-safe visibility toggle via visibility helpers.
                -- When clamped: show overflow, hide attached.
                -- When not clamped: show attached, hide overflow.
                if customBar.visibilityHelper then
                    customBar.visibilityHelper:SetAlphaFromBoolean(isClamped, 0, visAlpha)
                    customBar:SetAlpha(customBar.visibilityHelper:GetAlpha())
                end
                if frame.absorbOverflowBar.visibilityHelper then
                    frame.absorbOverflowBar.visibilityHelper:SetAlphaFromBoolean(isClamped, visAlpha, 0)
                    frame.absorbOverflowBar:SetAlpha(frame.absorbOverflowBar.visibilityHelper:GetAlpha())
                end
            elseif mode == "ATTACHED" and frame.absorbOvershieldGlow and db.absorbBarShowOvershield then
                -- ATTACHED mode: overshield glow visibility toggles with isClamped
                frame.absorbOvershieldGlow:SetAlphaFromBoolean(isClamped, db.absorbBarOvershieldAlpha or 0.8, 0)
            end
        else
            -- OVERLAY / FLOATING mode: simplest fast path — just value + OOR
            customBar:SetMinMaxValues(0, maxHealth)
            DF.SetBarValue(customBar, absorbs, frame)
        end

        -- OOR alpha refresh on the main bar. Range state can change
        -- independently of settings (Range.lua updates frame.dfInRange
        -- from the range ticker), so we always re-apply even on the
        -- fast path.
        if db.oorEnabled and customBar.SetAlphaFromBoolean then
            local inRange = frame.dfInRange
            if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
            -- ATTACHED_OVERFLOW's visibility helpers already encode OOR into
            -- their alpha calculation above, so don't double-apply there.
            if mode ~= "ATTACHED_OVERFLOW" then
                customBar:SetAlphaFromBoolean(inRange, 1, db.oorAbsorbBarAlpha or 0.5)
            end
        end

        return
    end

    -- ========================================================
    -- FULL REBUILD PATH (something changed, reapply all layout)
    -- ========================================================

    -- ALWAYS hide overshield glow and overflow bar when switching modes
    -- This must happen before any early returns to prevent stuck visuals
    if frame.absorbOvershieldGlow then
        frame.absorbOvershieldGlow:Hide()
    end
    if frame.absorbOverflowBar then
        frame.absorbOverflowBar:Hide()
    end

    -- NOTE (2026-04-09): the old code used to hide frame.totalAbsorb,
    -- frame.overAbsorbGlow, and frame.totalAbsorbOverlay here. Those
    -- fields are Blizzard CompactUnitFrame elements and DF frames are
    -- built from SecureUnitButtonTemplate, not CompactUnitFrame — so
    -- those fields are ALWAYS nil on our frames. The old Hide() calls
    -- were literally no-ops guarded by always-nil checks. Removed.
    
    -- Create custom absorb bar if needed
    if not frame.dfAbsorbBar then
        frame.dfAbsorbBar = CreateFrame("StatusBar", nil, frame)
        frame.dfAbsorbBar:SetMinMaxValues(0, 1)
        frame.dfAbsorbBar:EnableMouse(false)
        
        -- Background for floating mode
        local bg = frame.dfAbsorbBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfAbsorbBar.bg = bg
    end
    
    local customBar = frame.dfAbsorbBar
    
    -- Strata and level
    local strata = db.absorbBarStrata or "MEDIUM"
    local useSandwich = (strata == "SANDWICH")
    local useSandwichLow = (strata == "SANDWICH_LOW")
    local healthLevel = frame.healthBar:GetFrameLevel()
    
    local absorbLevel
    if useSandwich then
        absorbLevel = healthLevel + 3
    elseif useSandwichLow then
        absorbLevel = healthLevel + 1
    else
        absorbLevel = healthLevel + 15
    end
    
    customBar:SetParent(frame)
    customBar:SetFrameStrata(frame:GetFrameStrata())
    customBar:SetFrameLevel(absorbLevel)
    
    -- Texture and color
    local tex = db.absorbBarTexture or "Interface\\Buttons\\WHITE8x8"
    local col = db.absorbBarColor or {r = 0, g = 0.835, b = 1, a = 0.7}
    local blendMode = db.absorbBarBlendMode or "BLEND"
    
    -- Apply texture only if changed to prevent flickering
    if customBar.currentTexture ~= tex then
        customBar.currentTexture = tex
        if tex == "Interface\\RaidFrame\\Shield-Overlay" then
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(true)
                barTex:SetVertTile(true)
                barTex:SetTexCoord(0, 2, 0, 1)
                barTex:SetDesaturated(true)
                barTex:SetDrawLayer("ARTWORK", 2)
            end
        else
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(false)
                barTex:SetVertTile(false)
                barTex:SetTexCoord(0, 1, 0, 1)
                barTex:SetDesaturated(false)
                barTex:SetDrawLayer("ARTWORK", 1)
            end
        end
    end
    
    -- Always apply blend mode (may have changed without texture change)
    local barTex = customBar:GetStatusBarTexture()
    if barTex then
        barTex:SetBlendMode(blendMode)
    end
    
    -- Always apply color (fast operation, doesn't cause flicker)
    if tex == "Interface\\RaidFrame\\Shield-Overlay" and blendMode == "ADD" then
        customBar:SetStatusBarColor(col.r * 2, col.g * 2, col.b * 2, 1)
    else
        customBar:SetStatusBarColor(col.r, col.g, col.b, col.a or 0.7)
    end
    
    customBar:Show()
    customBar:ClearAllPoints()
    -- Reset frame alpha (may have been set to 0 by ATTACHED_OVERFLOW mode)
    -- Respect OOR fade: use SetAlphaFromBoolean to handle secret values from UnitInRange
    if db.oorEnabled and customBar.SetAlphaFromBoolean then
        local inRange = frame.dfInRange
        if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
        customBar:SetAlphaFromBoolean(inRange, 1, db.oorAbsorbBarAlpha or 0.5)
    else
        customBar:SetAlpha(1)
    end
    
    -- ============================================================
    -- MODE: FLOATING
    -- ============================================================
    if mode == "FLOATING" then
        -- Clear any existing anchors first
        customBar:ClearAllPoints()
        
        -- Set parent first
        customBar:SetParent(frame)
        
        -- Apply strata - must be done after SetParent
        -- Hide briefly to force strata change to take effect
        local wasShown = customBar:IsShown()
        if wasShown then customBar:Hide() end
        
        if not useSandwich and not useSandwichLow then
            customBar:SetFrameStrata(strata)
        else
            customBar:SetFrameStrata(frame:GetFrameStrata())
        end
        
        -- Use user-configured frame level for floating mode
        local floatingLevel = db.absorbBarFrameLevel or 10
        customBar:SetFrameLevel(floatingLevel)
        
        if wasShown then customBar:Show() end
        
        -- Dimensions & Orientation
        local orientation = db.absorbBarOrientation or "HORIZONTAL"
        customBar:SetOrientation(orientation)
        customBar:SetReverseFill(db.absorbBarReverse or false)
        
        local w = db.absorbBarWidth or 50
        local h = db.absorbBarHeight or 6
        
        -- Apply pixel-perfect adjustments
        if db.pixelPerfect then
            w = DF:PixelPerfect(w)
            h = DF:PixelPerfect(h)
        end
        
        if orientation == "VERTICAL" then
            customBar:SetWidth(h)
            customBar:SetHeight(w)
        else
            customBar:SetWidth(w)
            customBar:SetHeight(h)
        end
        
        local anchor = db.absorbBarAnchor or "CENTER"
        local x = db.absorbBarX or 0
        local y = db.absorbBarY or 0
        customBar:SetPoint(anchor, frame, anchor, x, y)
        
        customBar:SetMinMaxValues(0, maxHealth)
        
        if customBar.bg then
            customBar.bg:Show()
            local bgC = db.absorbBarBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
            customBar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
        end
        
        -- Hide any existing border elements
        if customBar.border then customBar.border:Hide() end
        customBar:SetScript("OnUpdate", nil)
        
        -- Set bar value
        DF.SetBarValue(customBar, absorbs, frame)
        
    -- ============================================================
    -- MODE: ATTACHED (anchors to health bar fill texture)
    -- Uses SetDamageAbsorbClampMode(2) for max health clamping
    -- ============================================================
    elseif mode == "ATTACHED" then
        customBar:ClearAllPoints()
        customBar:SetParent(frame.healthBar)
        customBar:SetFrameStrata(frame:GetFrameStrata())
        -- ATTACHED mode should always be below dispel overlay (+6) and aggro highlight (+9)
        -- Use healthLevel + 2 regardless of strata setting
        customBar:SetFrameLevel(healthLevel + 2)
        
        -- For ATTACHED mode, disable tiling to prevent dense repeating in narrow bars
        local attachedBarTex = customBar:GetStatusBarTexture()
        if attachedBarTex then
            attachedBarTex:SetHorizTile(false)
            attachedBarTex:SetVertTile(false)
            attachedBarTex:SetTexCoord(0, 1, 0, 1)
        end
        
        if customBar.bg then customBar.bg:Hide() end
        
        local healthFillTexture = frame.healthBar:GetStatusBarTexture()
        if not healthFillTexture then
            customBar:Hide()
            return
        end
        
        -- Use the calculator API for ATTACHED mode
        local attachedAbsorbs = absorbs
        local isClamped = false
        
        -- Create/reuse the calculator
        if CreateUnitHealPredictionCalculator and unit then
            if not frame.absorbCalculator then
                frame.absorbCalculator = CreateUnitHealPredictionCalculator()
            end
            local calc = frame.absorbCalculator
            
            -- Set clamp mode from settings (default to 1 = Missing Health)
            local clampMode = db.absorbBarAttachedClampMode or 1
            if calc.SetDamageAbsorbClampMode then calc:SetDamageAbsorbClampMode(clampMode) end

            -- Populate the calculator
            UnitGetDetailedHealPrediction(unit, nil, calc)

            -- Get clamped absorbs and clamped bool
            if calc.GetDamageAbsorbs then
                local result1, result2 = calc:GetDamageAbsorbs()
                if result1 then
                    attachedAbsorbs = result1
                    isClamped = result2  -- This is a secret bool in M+
                end
            end
        end

        -- Create/update overshield glow at max health position
        if db.absorbBarShowOvershield then
            -- Create glow texture if needed (directly on health bar)
            if not frame.absorbOvershieldGlow then
                frame.absorbOvershieldGlow = frame.healthBar:CreateTexture(nil, "OVERLAY", nil, 7)
            end
            
            local glow = frame.absorbOvershieldGlow
            local glowStyle = db.absorbBarOvershieldStyle or "SPARK"
            -- Default to absorb bar color if not set
            local glowColor = db.absorbBarOvershieldColor or db.absorbBarColor or {r = 1, g = 1, b = 1}
            local glowAlpha = db.absorbBarOvershieldAlpha or 0.8
            local reversePos = db.absorbBarOvershieldReverse or false
            
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            local isHorizontal = (healthOrient == "HORIZONTAL" or healthOrient == "HORIZONTAL_INV")
            local isReversed = (healthOrient == "HORIZONTAL_INV" or healthOrient == "VERTICAL_INV")
            
            -- For absorbs, default is max HP side. Reverse option flips to no HP side.
            local atMaxHP = not reversePos
            -- Determine which side based on orientation and whether we want max HP side
            local atEnd = (atMaxHP ~= isReversed)  -- XOR: if both true or both false, we're at right/top
            
            glow:ClearAllPoints()
            glow:SetRotation(0)
            glow:SetTexCoord(0, 1, 0, 1)
            
            if glowStyle == "LINE" then
                glow:SetTexture("Interface\\Buttons\\WHITE8x8")
                glow:SetBlendMode("ADD")
                if isHorizontal then
                    if atEnd then
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    else
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                    end
                    glow:SetWidth(2)
                else
                    if atEnd then
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                    else
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    end
                    glow:SetHeight(2)
                end
                
            elseif glowStyle == "GRADIENT" then
                glow:SetBlendMode("ADD")
                if isHorizontal then
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_H_Rev" or "DF_Gradient_H"))
                    if atEnd then
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    else
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                    end
                    glow:SetWidth(20)
                else
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_V_Rev" or "DF_Gradient_V"))
                    if atEnd then
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                    else
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    end
                    glow:SetHeight(20)
                end
                
            elseif glowStyle == "GLOW" then
                glow:SetBlendMode("ADD")
                if isHorizontal then
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_H_Rev" or "DF_Gradient_H"))
                    if atEnd then
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    else
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                    end
                    glow:SetWidth(10)
                else
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_V_Rev" or "DF_Gradient_V"))
                    if atEnd then
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                    else
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    end
                    glow:SetHeight(10)
                end
                
            elseif glowStyle == "SPARK" then
                glow:SetBlendMode("ADD")
                if isHorizontal then
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_H_Rev" or "DF_Gradient_H"))
                    if atEnd then
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    else
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                    end
                    glow:SetWidth(5)
                else
                    glow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_V_Rev" or "DF_Gradient_V"))
                    if atEnd then
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                    else
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    end
                    glow:SetHeight(5)
                end
            end
            
            glow:SetVertexColor(glowColor.r, glowColor.g, glowColor.b, 1)
            glow:Show()
            -- In test mode or if clamped, show the glow
            if testIndex then
                glow:SetAlpha(glowAlpha)
            else
                glow:SetAlphaFromBoolean(isClamped, glowAlpha, 0)
            end
        elseif frame.absorbOvershieldGlow then
            frame.absorbOvershieldGlow:Hide()
        end
        
        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        
        local barWidth = frame.healthBar:GetWidth() - (inset * 2)
        local barHeight = frame.healthBar:GetHeight() - (inset * 2)
        
        -- Use StatusBar API to handle proportional fill - no manual division needed
        -- Set bar to full size and let SetMinMaxValues/SetValue calculate the fill
        if healthOrient == "HORIZONTAL" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(false)
            customBar:SetHeight(barHeight)
            customBar:SetWidth(barWidth)
            customBar:SetPoint("LEFT", healthFillTexture, "RIGHT", 0, 0)
        elseif healthOrient == "HORIZONTAL_INV" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(true)
            customBar:SetHeight(barHeight)
            customBar:SetWidth(barWidth)
            customBar:SetPoint("RIGHT", healthFillTexture, "LEFT", 0, 0)
        elseif healthOrient == "VERTICAL" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(false)
            customBar:SetWidth(barWidth)
            customBar:SetHeight(barHeight)
            customBar:SetPoint("BOTTOM", healthFillTexture, "TOP", 0, 0)
        elseif healthOrient == "VERTICAL_INV" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(true)
            customBar:SetWidth(barWidth)
            customBar:SetHeight(barHeight)
            customBar:SetPoint("TOP", healthFillTexture, "BOTTOM", 0, 0)
        end
        
        -- Let WoW's StatusBar handle the percentage calculation internally
        customBar:SetMinMaxValues(0, maxHealth)
        DF.SetBarValue(customBar, attachedAbsorbs, frame)
        
        if customBar.border then customBar.border:Hide() end
        customBar:SetScript("OnUpdate", nil)

    -- ============================================================
    -- MODE: ATTACHED_OVERFLOW (attached bar + overlay when clamped)
    -- ============================================================
    elseif mode == "ATTACHED_OVERFLOW" then
        customBar:ClearAllPoints()
        customBar:SetParent(frame.healthBar)
        customBar:SetFrameStrata(frame:GetFrameStrata())
        -- ATTACHED_OVERFLOW mode should always be below dispel overlay (+6) and aggro highlight (+9)
        -- Use healthLevel + 2 regardless of strata setting
        customBar:SetFrameLevel(healthLevel + 2)
        
        -- For ATTACHED mode, disable tiling to prevent dense repeating in narrow bars
        local attachedBarTex = customBar:GetStatusBarTexture()
        if attachedBarTex then
            attachedBarTex:SetHorizTile(false)
            attachedBarTex:SetVertTile(false)
            attachedBarTex:SetTexCoord(0, 1, 0, 1)
        end
        
        if customBar.bg then customBar.bg:Hide() end
        
        local healthFillTexture = frame.healthBar:GetStatusBarTexture()
        if not healthFillTexture then
            customBar:Hide()
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            return
        end
        
        -- Use the calculator API for ATTACHED mode
        local attachedAbsorbs = absorbs
        local isClamped = false
        
        -- Create/reuse the calculator
        if CreateUnitHealPredictionCalculator and unit then
            if not frame.absorbCalculator then
                frame.absorbCalculator = CreateUnitHealPredictionCalculator()
            end
            local calc = frame.absorbCalculator
            
            -- Set clamp mode from settings (default to 1 = Missing Health)
            local clampMode = db.absorbBarAttachedClampMode or 1
            if calc.SetDamageAbsorbClampMode then calc:SetDamageAbsorbClampMode(clampMode) end

            -- Populate the calculator
            UnitGetDetailedHealPrediction(unit, nil, calc)

            -- Get clamped absorbs and clamped bool
            if calc.GetDamageAbsorbs then
                local result1, result2 = calc:GetDamageAbsorbs()
                if result1 then
                    attachedAbsorbs = result1
                    isClamped = result2  -- This is a secret bool in M+
                end
            end
        end

        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        
        local barWidth = frame.healthBar:GetWidth() - (inset * 2)
        local barHeight = frame.healthBar:GetHeight() - (inset * 2)
        
        -- Use StatusBar API to handle proportional fill - no manual division needed
        if healthOrient == "HORIZONTAL" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(false)
            customBar:SetHeight(barHeight)
            customBar:SetWidth(barWidth)
            customBar:SetPoint("LEFT", healthFillTexture, "RIGHT", 0, 0)
        elseif healthOrient == "HORIZONTAL_INV" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(true)
            customBar:SetHeight(barHeight)
            customBar:SetWidth(barWidth)
            customBar:SetPoint("RIGHT", healthFillTexture, "LEFT", 0, 0)
        elseif healthOrient == "VERTICAL" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(false)
            customBar:SetWidth(barWidth)
            customBar:SetHeight(barHeight)
            customBar:SetPoint("BOTTOM", healthFillTexture, "TOP", 0, 0)
        elseif healthOrient == "VERTICAL_INV" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(true)
            customBar:SetWidth(barWidth)
            customBar:SetHeight(barHeight)
            customBar:SetPoint("TOP", healthFillTexture, "BOTTOM", 0, 0)
        end
        
        -- Let WoW's StatusBar handle the percentage calculation internally
        customBar:SetMinMaxValues(0, maxHealth)
        DF.SetBarValue(customBar, attachedAbsorbs, frame)
        
        if customBar.border then customBar.border:Hide() end
        customBar:SetScript("OnUpdate", nil)
        
        -- Create visibility helper for the attached bar if needed
        if not customBar.visibilityHelper then
            customBar.visibilityHelper = customBar:CreateTexture(nil, "BACKGROUND")
            customBar.visibilityHelper:SetSize(1, 1)
            customBar.visibilityHelper:SetColorTexture(0, 0, 0, 0)
        end
        
        -- Handle overflow bar (shown when clamped)
        if not frame.absorbOverflowBar then
            frame.absorbOverflowBar = CreateFrame("StatusBar", nil, frame.healthBar)
            frame.absorbOverflowBar:SetMinMaxValues(0, 1)
            frame.absorbOverflowBar:EnableMouse(false)
        end
        
        -- Ensure overflow bar has visibility helper (may have been created by test mode without it)
        if not frame.absorbOverflowBar.visibilityHelper then
            frame.absorbOverflowBar.visibilityHelper = frame.absorbOverflowBar:CreateTexture(nil, "BACKGROUND")
            frame.absorbOverflowBar.visibilityHelper:SetSize(1, 1)
            frame.absorbOverflowBar.visibilityHelper:SetColorTexture(0, 0, 0, 0)
        end
        
        local overflowBar = frame.absorbOverflowBar
        local overflowVisHelper = overflowBar.visibilityHelper
        local attachedVisHelper = customBar.visibilityHelper
        
        -- Configure the overflow bar (always, so it's ready when needed)
        overflowBar:ClearAllPoints()
        -- Overflow bar should be just above attached bar but still below dispel overlay (+6)
        overflowBar:SetFrameLevel(healthLevel + 3)
        
        -- Apply same texture/color as main absorb bar
        local texture = db.absorbBarTexture or "Interface\\TargetingFrame\\UI-StatusBar"
        if type(texture) == "table" then
            texture = texture.path or "Interface\\TargetingFrame\\UI-StatusBar"
        end
        overflowBar:SetStatusBarTexture(texture)
        
        local color = db.absorbBarColor or {r = 1, g = 1, b = 1, a = 0.7}
        overflowBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 0.7)
        
        -- Disable tiling
        local overflowTex = overflowBar:GetStatusBarTexture()
        if overflowTex then
            overflowTex:SetHorizTile(false)
            overflowTex:SetVertTile(false)
        end
        
        -- Position like OVERLAY mode
        overflowBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
        overflowBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
        overflowBar:SetMinMaxValues(0, maxHealth)
        
        -- Match health bar orientation for overlay
        local overlayReverse = db.absorbBarOverlayReverse or false
        
        if healthOrient == "HORIZONTAL" then
            overflowBar:SetOrientation("HORIZONTAL")
            overflowBar:SetReverseFill(not overlayReverse)
        elseif healthOrient == "HORIZONTAL_INV" then
            overflowBar:SetOrientation("HORIZONTAL")
            overflowBar:SetReverseFill(overlayReverse)
        elseif healthOrient == "VERTICAL" then
            overflowBar:SetOrientation("VERTICAL")
            overflowBar:SetReverseFill(not overlayReverse)
        elseif healthOrient == "VERTICAL_INV" then
            overflowBar:SetOrientation("VERTICAL")
            overflowBar:SetReverseFill(overlayReverse)
        end
        
        -- Set bar value to full absorbs (not clamped)
        DF.SetBarValue(overflowBar, absorbs, frame)
        
        -- Use SetAlphaFromBoolean to toggle between attached and overflow bars
        -- Frame alpha: visAlpha when visible, 0 when hidden (bar texture alpha controlled by SetStatusBarColor)
        -- When clamped: show overflow, hide attached
        -- When not clamped: hide overflow, show attached
        -- Respect OOR fade: use OOR alpha instead of 1 when unit is out of range
        -- dfInRange may be a secret boolean from UnitInRange fallback
        local visAlpha = 1
        if db.oorEnabled then
            local inRange = frame.dfInRange
            if not (issecretvalue and issecretvalue(inRange)) then
                if inRange == false then
                    visAlpha = db.oorAbsorbBarAlpha or 0.5
                end
            end
            -- Secret values: can't compare, leave visAlpha at 1 (OOR handled by frame-level fade)
        end
        overflowVisHelper:Show()
        overflowVisHelper:SetAlphaFromBoolean(isClamped, visAlpha, 0)
        overflowBar:SetAlpha(overflowVisHelper:GetAlpha())
        overflowBar:Show()

        attachedVisHelper:Show()
        attachedVisHelper:SetAlphaFromBoolean(isClamped, 0, visAlpha)  -- Inverse: 0 when clamped, visAlpha when not
        customBar:SetAlpha(attachedVisHelper:GetAlpha())

    -- ============================================================
    -- MODE: OVERLAY
    -- ============================================================
    else
        -- Clear any existing anchors first
        customBar:ClearAllPoints()
        
        -- Set parent to health bar for overlay mode
        customBar:SetParent(frame.healthBar)
        customBar:SetFrameStrata(frame:GetFrameStrata())
        -- OVERLAY mode should be above health bar but below dispel overlay (+6) and highlights (+9)
        customBar:SetFrameLevel(healthLevel + 2)
        
        if customBar.bg then customBar.bg:Hide() end
        
        -- Use explicit points instead of SetAllPoints to ensure proper clipping
        -- Inset by border size if frame border is enabled to avoid overlap
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        customBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
        customBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
        customBar:SetMinMaxValues(0, maxHealth)
        
        -- Match health bar orientation
        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local overlayReverse = db.absorbBarOverlayReverse or false
        
        if healthOrient == "HORIZONTAL" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(not overlayReverse)
        elseif healthOrient == "HORIZONTAL_INV" then
            customBar:SetOrientation("HORIZONTAL")
            customBar:SetReverseFill(overlayReverse)
        elseif healthOrient == "VERTICAL" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(not overlayReverse)
        elseif healthOrient == "VERTICAL_INV" then
            customBar:SetOrientation("VERTICAL")
            customBar:SetReverseFill(overlayReverse)
        end
        
        -- Hide any existing border elements
        if customBar.borderLines then
            for i = 1, 4 do
                customBar.borderLines[i]:Hide()
            end
        end
        if customBar.border then
            customBar.border:Hide()
        end
        customBar:SetScript("OnUpdate", nil)

        -- Set bar value
        DF.SetBarValue(customBar, absorbs, frame)
    end

    -- Cache the current layout settings so subsequent calls can
    -- short-circuit via AbsorbLayoutStateChanged. Done at the end of
    -- the full rebuild so the cache reflects the state the bar was
    -- just configured for.
    CacheAbsorbLayoutState(frame, db)
end

-- ============================================================
-- HEAL ABSORB BAR LOGIC (Necrotic, etc.)
-- ============================================================
-- NOTE: In WoW Midnight (12.0), UnitGetTotalHealAbsorbs() returns a
-- "secret value" that cannot be compared with ANY Lua operators.
-- We must pass it directly to SetValue() without any checks.
-- The StatusBar will show 0 width if the value is 0, effectively hiding it.
-- ============================================================

function DF:UpdateHealAbsorb(frame, testIndex)
    if not frame then return end
    if not frame.healthBar then return end
    
    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    local mode = db.healAbsorbBarMode or "OVERLAY"
    
    -- Get values - either from test data or real unit
    local maxHealth, healAbsorb
    
    if DF.testMode and testIndex ~= nil then
        local testData = DF:GetTestUnitData(testIndex)
        if testData then
            maxHealth = testData.maxHealth
            healAbsorb = testData.healAbsorbPercent * maxHealth
        else
            maxHealth = 100000
            healAbsorb = 0
        end
    elseif DF.raidTestMode and testIndex ~= nil then
        local testData = DF:GetTestUnitData(testIndex, true)  -- true = raid
        if testData then
            maxHealth = testData.maxHealth
            healAbsorb = testData.healAbsorbPercent * maxHealth
        else
            maxHealth = 100000
            healAbsorb = 0
        end
    else
        -- Only process player, party, and raid units for real data
        if not unit or (unit ~= "player" and not unit:match("^party%d$") and not unit:match("^raid%d+$")) then
            return
        end
        
        -- Ensure unit exists before querying
        if not UnitExists(unit) then
            if frame.dfHealAbsorbBar then frame.dfHealAbsorbBar:Hide() end
            return
        end
        
        -- Get values - StatusBar API handles secret values internally via SetMinMaxValues
        maxHealth = UnitHealthMax(unit)
        healAbsorb = UnitGetTotalHealAbsorbs(unit)
    end
    
    -- Always hide Blizzard elements since we use custom bars
    if frame.myHealAbsorb then frame.myHealAbsorb:Hide() end
    if frame.myHealAbsorbLeftShadow then frame.myHealAbsorbLeftShadow:Hide() end
    if frame.myHealAbsorbRightShadow then frame.myHealAbsorbRightShadow:Hide() end
    if frame.myHealAbsorbOverlay then frame.myHealAbsorbOverlay:Hide() end
    
    -- Create custom bar if needed
    if not frame.dfHealAbsorbBar then
        frame.dfHealAbsorbBar = CreateFrame("StatusBar", nil, frame)
        frame.dfHealAbsorbBar:SetMinMaxValues(0, 1)
        frame.dfHealAbsorbBar:EnableMouse(false)
        
        -- Background for floating mode
        local bg = frame.dfHealAbsorbBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfHealAbsorbBar.bg = bg
    end
    
    local bar = frame.dfHealAbsorbBar
    local healthLevel = frame.healthBar:GetFrameLevel()
    local healAbsorbLevel = healthLevel + 12
    
    bar:SetParent(frame)
    bar:SetFrameStrata(frame:GetFrameStrata())
    bar:SetFrameLevel(healAbsorbLevel)
    
    -- Texture and color
    local tex = db.healAbsorbBarTexture or "Interface\\Buttons\\WHITE8x8"
    local col = db.healAbsorbBarColor or {r = 0.4, g = 0.1, b = 0.1, a = 0.7}
    local blendMode = db.healAbsorbBarBlendMode or "BLEND"
    
    -- Apply texture only if changed to prevent flickering
    if bar.currentTexture ~= tex then
        bar.currentTexture = tex
        bar:SetStatusBarTexture(tex)
        local barTex = bar:GetStatusBarTexture()
        if barTex then
            barTex:SetHorizTile(false)
            barTex:SetVertTile(false)
            barTex:SetTexCoord(0, 1, 0, 1)
            barTex:SetDesaturated(false)
            barTex:SetDrawLayer("ARTWORK", 1)
        end
    end
    
    -- Always apply blend mode (may have changed without texture change)
    local barTex = bar:GetStatusBarTexture()
    if barTex then
        barTex:SetBlendMode(blendMode)
    end
    
    bar:SetStatusBarColor(col.r, col.g, col.b, col.a or 0.7)
    
    bar:ClearAllPoints()
    
    -- ============================================================
    -- MODE: FLOATING
    -- ============================================================
    if mode == "FLOATING" then
        bar:SetParent(frame)
        bar:SetFrameLevel(healAbsorbLevel)
        
        if bar.bg then
            bar.bg:Show()
            local bgC = db.healAbsorbBarBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
            bar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
        end
        
        -- Hide any existing border elements
        if bar.border then bar.border:Hide() end
        bar:SetScript("OnUpdate", nil)
        
        -- Dimensions & Orientation
        local orientation = db.healAbsorbBarOrientation or "HORIZONTAL"
        bar:SetOrientation(orientation)
        bar:SetReverseFill(db.healAbsorbBarReverse or false)
        
        local w = db.healAbsorbBarWidth or 50
        local h = db.healAbsorbBarHeight or 6
        
        -- Apply pixel-perfect adjustments
        if db.pixelPerfect then
            w = DF:PixelPerfect(w)
            h = DF:PixelPerfect(h)
        end
        
        if orientation == "VERTICAL" then
            bar:SetWidth(h)
            bar:SetHeight(w)
        else
            bar:SetWidth(w)
            bar:SetHeight(h)
        end
        
        local anchor = db.healAbsorbBarAnchor or "CENTER"
        local x = db.healAbsorbBarX or 0
        local y = db.healAbsorbBarY or 0
        bar:SetPoint(anchor, frame, anchor, x, y)
        
    -- ============================================================
    -- MODE: ATTACHED (anchors to health bar fill texture)
    -- Extends inward toward 0 health, clamps at current health
    -- ============================================================
    elseif mode == "ATTACHED" then
        bar:ClearAllPoints()
        bar:SetParent(frame.healthBar)
        -- ATTACHED mode should be below dispel overlay (+6) and aggro highlight (+9)
        bar:SetFrameLevel(healthLevel + 3)
        
        -- For ATTACHED mode, disable tiling to prevent dense repeating in narrow bars
        local attachedBarTex = bar:GetStatusBarTexture()
        if attachedBarTex then
            attachedBarTex:SetHorizTile(false)
            attachedBarTex:SetVertTile(false)
            attachedBarTex:SetTexCoord(0, 1, 0, 1)
        end
        
        if bar.bg then bar.bg:Hide() end
        
        local healthFillTexture = frame.healthBar:GetStatusBarTexture()
        if not healthFillTexture then
            bar:Hide()
            return
        end
        
        -- Use the calculator API for ATTACHED mode
        local attachedHealAbsorb = healAbsorb
        
        if CreateUnitHealPredictionCalculator and unit then
            if not frame.healAbsorbCalculator then
                frame.healAbsorbCalculator = CreateUnitHealPredictionCalculator()
            end
            local calc = frame.healAbsorbCalculator
            
            -- Set clamp mode: 0 = CurrentHealth (don't go past 0 health)
            if calc.SetHealAbsorbClampMode then calc:SetHealAbsorbClampMode(0) end
            -- Set heal absorb mode: 1 = Total (return raw absorb values without
            -- subtracting incoming heals). Default mode 0 reduces heal absorbs by
            -- incoming heal amount, causing the bar to show less than actual absorb.
            if calc.SetHealAbsorbMode then calc:SetHealAbsorbMode(1) end
            
            -- Populate the calculator
            UnitGetDetailedHealPrediction(unit, nil, calc)
            
            -- Get clamped heal absorbs
            if calc.GetHealAbsorbs then
                local result = calc:GetHealAbsorbs()
                if result then
                    attachedHealAbsorb = result
                end
            end
        end
        
        -- Hide any existing overshield glow (not used for heal absorbs)
        if frame.healAbsorbOvershieldGlow then
            frame.healAbsorbOvershieldGlow:Hide()
        end
        
        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        
        local barWidth = frame.healthBar:GetWidth() - (inset * 2)
        local barHeight = frame.healthBar:GetHeight() - (inset * 2)
        
        -- Use StatusBar API to handle proportional fill - no manual division needed
        -- Position: anchor to health fill edge, extend INWARD toward 0 health
        if healthOrient == "HORIZONTAL" then
            bar:SetOrientation("HORIZONTAL")
            bar:SetReverseFill(true)  -- Fill toward 0 (left)
            bar:SetHeight(barHeight)
            bar:SetWidth(barWidth)
            bar:SetPoint("RIGHT", healthFillTexture, "RIGHT", 0, 0)
        elseif healthOrient == "HORIZONTAL_INV" then
            bar:SetOrientation("HORIZONTAL")
            bar:SetReverseFill(false)  -- Fill toward 0 (right)
            bar:SetHeight(barHeight)
            bar:SetWidth(barWidth)
            bar:SetPoint("LEFT", healthFillTexture, "LEFT", 0, 0)
        elseif healthOrient == "VERTICAL" then
            bar:SetOrientation("VERTICAL")
            bar:SetReverseFill(true)  -- Fill toward 0 (down)
            bar:SetWidth(barWidth)
            bar:SetHeight(barHeight)
            bar:SetPoint("TOP", healthFillTexture, "TOP", 0, 0)
        elseif healthOrient == "VERTICAL_INV" then
            bar:SetOrientation("VERTICAL")
            bar:SetReverseFill(false)  -- Fill toward 0 (up)
            bar:SetWidth(barWidth)
            bar:SetHeight(barHeight)
            bar:SetPoint("BOTTOM", healthFillTexture, "BOTTOM", 0, 0)
        end
        
        -- Let WoW's StatusBar handle the percentage calculation internally
        bar:SetMinMaxValues(0, maxHealth)
        DF.SetBarValue(bar, attachedHealAbsorb, frame)
        
        if bar.border then bar.border:Hide() end
        bar:SetScript("OnUpdate", nil)
        bar:Show()
        return
        
    -- ============================================================
    -- MODE: OVERLAY
    -- ============================================================
    else
        bar:SetParent(frame.healthBar)
        -- OVERLAY mode should be above health bar but below dispel overlay (+6) and highlights (+9)
        bar:SetFrameLevel(healthLevel + 2)
        
        if bar.bg then bar.bg:Hide() end
        
        -- Use explicit points instead of SetAllPoints to ensure proper clipping
        -- Inset by border size if frame border is enabled to avoid overlap
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
        bar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
        
        -- Match health bar orientation
        -- Heal absorbs fill from low HP side (opposite of regular absorbs)
        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local overlayReverse = db.healAbsorbBarOverlayReverse or false
        
        if healthOrient == "HORIZONTAL" then
            bar:SetOrientation("HORIZONTAL")
            bar:SetReverseFill(overlayReverse)
        elseif healthOrient == "HORIZONTAL_INV" then
            bar:SetOrientation("HORIZONTAL")
            bar:SetReverseFill(not overlayReverse)
        elseif healthOrient == "VERTICAL" then
            bar:SetOrientation("VERTICAL")
            bar:SetReverseFill(overlayReverse)
        elseif healthOrient == "VERTICAL_INV" then
            bar:SetOrientation("VERTICAL")
            bar:SetReverseFill(not overlayReverse)
        end
        
        -- Hide any existing border elements
        if bar.borderLines then
            for i = 1, 4 do
                bar.borderLines[i]:Hide()
            end
        end
        if bar.border then
            bar.border:Hide()
        end
        bar:SetScript("OnUpdate", nil)
    end
    
    -- CRITICAL: Set min/max BEFORE SetValue, and always show the bar
    -- The bar will render with 0 width if healAbsorb is 0
    bar:SetMinMaxValues(0, maxHealth)
    DF.SetBarValue(bar, healAbsorb, frame)
    bar:Show()
end

-- ============================================================
-- HEAL PREDICTION BAR
-- Uses the new UnitHealPredictionCalculator API (11.1+)
-- IMPORTANT: All health/heal values may be secret in M+, so we CANNOT do
-- any arithmetic on them. We anchor to the health bar fill texture and
-- pass values directly to StatusBar:SetValue().
-- ============================================================
function DF:UpdateHealPrediction(frame, testIndex)
    if not frame or not frame.healthBar then return end
    
    -- PERF TEST: Skip if disabled (but allow test mode to still work)
    if DF.PerfTest and not DF.PerfTest.enableHealPrediction and not DF.testMode and not DF.raidTestMode then
        if frame.dfHealPredictionBar then frame.dfHealPredictionBar:Hide() end
        return
    end
    
    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    
    -- Check if heal prediction is enabled
    if not db.healPredictionEnabled then
        if frame.dfHealPredictionBar then
            frame.dfHealPredictionBar:Hide()
        end
        return
    end
    
    local mode = db.healPredictionMode or "OVERLAY"
    local showMode = db.healPredictionShowMode or "ALL"
    
    -- Get values - either from test data or real unit
    local maxHealth, incomingHeals
    local isTestMode = false
    local testHealthPercent, testHealPercent  -- Only for test mode
    
    if DF.testMode and testIndex ~= nil then
        isTestMode = true
        local testData = DF:GetTestUnitData(testIndex)
        if testData then
            maxHealth = testData.maxHealth
            testHealthPercent = testData.healthPercent
            testHealPercent = testData.healPredictionPercent or 0
            incomingHeals = testHealPercent * maxHealth  -- Safe in test mode
        else
            maxHealth = 100000
            testHealthPercent = 0.75
            testHealPercent = 0
            incomingHeals = 0
        end
    elseif DF.raidTestMode and testIndex ~= nil then
        isTestMode = true
        local testData = DF:GetTestUnitData(testIndex, true)
        if testData then
            maxHealth = testData.maxHealth
            testHealthPercent = testData.healthPercent
            testHealPercent = testData.healPredictionPercent or 0
            incomingHeals = testHealPercent * maxHealth
        else
            maxHealth = 100000
            testHealthPercent = 0.75
            testHealPercent = 0
            incomingHeals = 0
        end
    else
        -- Only process valid units for real data
        if not unit or (unit ~= "player" and not unit:match("^party%d$") and not unit:match("^raid%d+$")) then
            return
        end
        
        -- Ensure unit exists before querying
        if not UnitExists(unit) then
            if frame.dfHealPredictionBar then frame.dfHealPredictionBar:Hide() end
            return
        end
        
        -- Get maxHealth - StatusBar API handles secret values internally via SetMinMaxValues
        maxHealth = UnitHealthMax(unit)
        
        -- Use the new Heal Prediction Calculator API (11.1+) if available
        -- This supports clamp modes and overflow percent
        if CreateUnitHealPredictionCalculator then
            if not frame.healPredictionCalculator then
                frame.healPredictionCalculator = CreateUnitHealPredictionCalculator()
            end
            
            local calc = frame.healPredictionCalculator
            
            -- Configure the calculator based on settings
            -- Overflow always at 100% (1.0)
            -- Show Overheal checked = clamp to Missing Health (1)
            -- Show Overheal unchecked = clamp to Max Health (0)
            local clampMode = db.healPredictionShowOverheal and 1 or 0
            
            calc:SetIncomingHealClampMode(clampMode)
            calc:SetIncomingHealOverflowPercent(1.0)  -- Always 100%
            
            local healerUnit = nil
            if showMode == "MINE" or showMode == "OTHERS" then
                healerUnit = "player"
            end
            
            UnitGetDetailedHealPrediction(unit, healerUnit, calc)
            
            local amount, amountFromHealer, amountFromOthers, clamped = calc:GetIncomingHeals()
            
            if showMode == "MINE" then
                incomingHeals = amountFromHealer
            elseif showMode == "OTHERS" then
                incomingHeals = amountFromOthers
            else
                incomingHeals = amount
            end
        else
            -- Fallback to simple API if calculator not available
            if showMode == "MINE" then
                incomingHeals = UnitGetIncomingHeals(unit, "player")
            else
                incomingHeals = UnitGetIncomingHeals(unit)
            end
        end
        
        -- If nil, hide the bar and return
        if not incomingHeals then
            if frame.dfHealPredictionBar then
                frame.dfHealPredictionBar:Hide()
            end
            return
        end
    end
    
    -- Get color based on show mode
    local color
    if showMode == "MINE" then
        color = db.healPredictionMyColor or {r = 0.0, g = 0.8, b = 0.2, a = 0.7}
    elseif showMode == "OTHERS" then
        color = db.healPredictionOthersColor or {r = 0.0, g = 0.5, b = 0.8, a = 0.7}
    else
        color = db.healPredictionAllColor or {r = 0.0, g = 0.7, b = 0.4, a = 0.7}
    end
    
    -- Create heal prediction bar if needed
    if not frame.dfHealPredictionBar then
        frame.dfHealPredictionBar = CreateFrame("StatusBar", nil, frame)
        frame.dfHealPredictionBar:SetMinMaxValues(0, 1)
        frame.dfHealPredictionBar:EnableMouse(false)
        
        -- Background for floating mode
        local bg = frame.dfHealPredictionBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfHealPredictionBar.bg = bg
    end
    
    local bar = frame.dfHealPredictionBar
    
    -- Strata and level
    local strata = db.healPredictionStrata or "SANDWICH"
    local useSandwich = (strata == "SANDWICH")
    local useSandwichLow = (strata == "SANDWICH_LOW")
    local healthLevel = frame.healthBar:GetFrameLevel()
    
    local predictionLevel
    if useSandwich then
        predictionLevel = healthLevel + 1  -- Below resource bar (which is at +2)
    elseif useSandwichLow then
        predictionLevel = healthLevel + 1
    else
        predictionLevel = healthLevel + 14
    end
    
    -- Texture and color
    local tex = db.healPredictionTexture or "Interface\\Buttons\\WHITE8x8"
    local blendMode = db.healPredictionBlendMode or "BLEND"
    
    -- Apply texture
    if bar.currentTexture ~= tex then
        bar.currentTexture = tex
        bar:SetStatusBarTexture(tex)
        local barTex = bar:GetStatusBarTexture()
        if barTex then
            barTex:SetHorizTile(false)
            barTex:SetVertTile(false)
            barTex:SetTexCoord(0, 1, 0, 1)
            barTex:SetDrawLayer("ARTWORK", 1)
        end
    end
    
    local barTex = bar:GetStatusBarTexture()
    if barTex then
        barTex:SetBlendMode(blendMode)
    end
    
    bar:SetStatusBarColor(color.r, color.g, color.b, color.a or 0.7)
    bar:ClearAllPoints()
    
    -- ============================================================
    -- MODE: FLOATING
    -- ============================================================
    if mode == "FLOATING" then
        bar:SetParent(frame)
        
        if not useSandwich and not useSandwichLow then
            bar:SetFrameStrata(strata)
        else
            bar:SetFrameStrata(frame:GetFrameStrata())
        end
        
        local floatingLevel = db.healPredictionFrameLevel or 12
        bar:SetFrameLevel(floatingLevel)
        
        -- Dimensions & Orientation
        local orientation = db.healPredictionOrientation or "HORIZONTAL"
        bar:SetOrientation(orientation)
        bar:SetReverseFill(db.healPredictionReverse or false)
        
        local w = db.healPredictionWidth or 50
        local h = db.healPredictionHeight or 6
        
        if db.pixelPerfect then
            w = DF:PixelPerfect(w)
            h = DF:PixelPerfect(h)
        end
        
        if orientation == "VERTICAL" then
            bar:SetWidth(h)
            bar:SetHeight(w)
        else
            bar:SetWidth(w)
            bar:SetHeight(h)
        end
        
        local anchor = db.healPredictionAnchor or "CENTER"
        local x = db.healPredictionX or 0
        local y = db.healPredictionY or 0
        bar:SetPoint(anchor, frame, anchor, x, y)
        
        bar:SetMinMaxValues(0, maxHealth)
        
        if bar.bg then
            bar.bg:Show()
            local bgC = db.healPredictionBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
            bar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
        end
        
        -- Use secret-aware SetBarValue
        DF.SetBarValue(bar, incomingHeals, frame)
        bar:Show()
        
    -- ============================================================
    -- MODE: OVERLAY (anchors to health bar fill texture)
    -- No arithmetic on secret values - anchor and let StatusBar handle it
    -- ============================================================
    else
        -- Parent to frame (not healthBar) to avoid clipping when showing overheal
        bar:SetParent(frame)
        bar:SetFrameStrata(frame:GetFrameStrata())
        bar:SetFrameLevel(predictionLevel)
        
        if bar.bg then bar.bg:Hide() end
        
        -- Get the health bar's fill texture - we'll anchor relative to it
        local healthFillTexture = frame.healthBar:GetStatusBarTexture()
        if not healthFillTexture then
            bar:Hide()
            return
        end
        
        local healthOrient = db.healthOrientation or "HORIZONTAL"
        local inset = 0
        if db.showFrameBorder ~= false then
            inset = db.borderSize or 1
        end
        
        -- For test mode, we can use calculated positions
        -- For live mode, we anchor to the health fill texture
        if isTestMode then
            -- Test mode: calculate position (safe, not secret)
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            local healthWidth = testHealthPercent * barWidth
            local healthHeight = testHealthPercent * barHeight
            local healWidth = testHealPercent * barWidth
            local healHeight = testHealPercent * barHeight
            
            if healthOrient == "HORIZONTAL" then
                bar:SetOrientation("HORIZONTAL")
                bar:SetReverseFill(false)
                bar:SetWidth(healWidth)
                -- Use two-point anchoring to match health bar fill height exactly
                bar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset + healthWidth, -inset)
                bar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset + healthWidth, inset)
            elseif healthOrient == "HORIZONTAL_INV" then
                bar:SetOrientation("HORIZONTAL")
                bar:SetReverseFill(true)
                bar:SetWidth(healWidth)
                bar:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset - healthWidth, -inset)
                bar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset - healthWidth, inset)
            elseif healthOrient == "VERTICAL" then
                bar:SetOrientation("VERTICAL")
                bar:SetReverseFill(false)
                bar:SetHeight(healHeight)
                bar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset, inset + healthHeight)
                bar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset + healthHeight)
            elseif healthOrient == "VERTICAL_INV" then
                bar:SetOrientation("VERTICAL")
                bar:SetReverseFill(true)
                bar:SetHeight(healHeight)
                bar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset - healthHeight)
                bar:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset, -inset - healthHeight)
            end
            
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(1)  -- Fill completely since width represents the heal
        else
            -- Live mode: Use StatusBar API to handle proportional fill - no manual division needed
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            
            if healthOrient == "HORIZONTAL" then
                bar:SetOrientation("HORIZONTAL")
                bar:SetReverseFill(false)
                bar:SetWidth(barWidth)
                -- Use two-point anchoring to match health fill texture height exactly
                bar:SetPoint("TOPLEFT", healthFillTexture, "TOPRIGHT", 0, 0)
                bar:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
            elseif healthOrient == "HORIZONTAL_INV" then
                bar:SetOrientation("HORIZONTAL")
                bar:SetReverseFill(true)
                bar:SetWidth(barWidth)
                bar:SetPoint("TOPRIGHT", healthFillTexture, "TOPLEFT", 0, 0)
                bar:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMLEFT", 0, 0)
            elseif healthOrient == "VERTICAL" then
                bar:SetOrientation("VERTICAL")
                bar:SetReverseFill(false)
                bar:SetHeight(barHeight)
                bar:SetPoint("BOTTOMLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                bar:SetPoint("BOTTOMRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
            elseif healthOrient == "VERTICAL_INV" then
                bar:SetOrientation("VERTICAL")
                bar:SetReverseFill(true)
                bar:SetHeight(barHeight)
                bar:SetPoint("TOPLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                bar:SetPoint("TOPRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
            end
            
            -- Let WoW's StatusBar handle the percentage calculation internally
            bar:SetMinMaxValues(0, maxHealth)
            DF.SetBarValue(bar, incomingHeals, frame)
        end
        
        bar:Show()
    end
end

function DF:UpdateName(frame)
    if not frame or not frame.unit then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local name = DF:GetUnitName(frame.unit)
    
    -- Truncate name if needed (UTF-8 aware)
    if name then
        local maxLen = db.nameTextLength or 0
        local truncMode = db.nameTextTruncateMode or "ELLIPSIS"
        
        if maxLen > 0 and DF:UTF8Len(name) > maxLen then
            if truncMode == "CUT" then
                name = DF:UTF8Sub(name, 1, maxLen)
            else -- ELLIPSIS
                name = DF:UTF8Sub(name, 1, maxLen) .. "..."
            end
        end
    end
    
    frame.nameText:SetText(name)
    
    -- Defer color AND alpha to the appearance system so OOR element fading is respected.
    -- UpdateName fires on UNIT_NAME_UPDATE which would otherwise reset alpha to 1.0.
    if DF.UpdateNameTextAppearance then
        DF:UpdateNameTextAppearance(frame)
    else
        -- Fallback if appearance system not loaded yet
        local nameAlpha = 1
        if db.fadeDeadFrames and frame.dfDeadFadeApplied then
            nameAlpha = db.fadeDeadName or 1.0
        end
        if db.nameTextUseClassColor then
            local _, class = UnitClass(frame.unit)
            local classColor = class and DF:GetClassColor(class)
            if classColor then
                frame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b, nameAlpha)
            else
                frame.nameText:SetTextColor(1, 1, 1, nameAlpha)
            end
        else
            local c = db.nameTextColor
            frame.nameText:SetTextColor(c.r, c.g, c.b, nameAlpha)
        end
    end
    
    -- Health text class color (independent of name color setting)
    if db.healthTextUseClassColor and frame.healthText then
        if DF.UpdateHealthTextAppearance then
            DF:UpdateHealthTextAppearance(frame)
        else
            local _, class = UnitClass(frame.unit)
            local classColor = class and DF:GetClassColor(class)
            if classColor then
                frame.healthText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
            end
        end
    end
end

function DF:UpdateRoleIcon(frame, source)
    if DF.RosterDebugCount then 
        DF:RosterDebugCount("UpdateRoleIcon")
        if source then
            DF:RosterDebugCount("UpdateRoleIcon:" .. source)
        end
    end
    if not frame or not frame.unit or not frame.roleIcon then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    local role = UnitGroupRolesAssigned(frame.unit)
    
    -- Use our tracked combat state (set by PLAYER_REGEN events)
    local inCombat = DF.playerInCombat or false
    
    -- Debug (use /df debugrole to enable)
    if DF.debugRoleIcons then
        print("|cff00ffffDF ROLE:|r", frame.unit, "role=", role, "onlyInCombat=", db.roleIconOnlyInCombat, "InCombat=", inCombat)
    end
    
    if role == "NONE" then
        frame.roleIcon:Hide()
        return
    end
    
    -- Determine if we should apply show settings
    -- If "Show All Roles Out of Combat" is checked, role filters only apply during combat
    -- Out of combat, all role icons show regardless of individual filter settings
    local applySettings = true
    if db.roleIconOnlyInCombat and not inCombat then
        applySettings = false  -- Out of combat, show all icons
    end
    
    local shouldShow = true
    if applySettings then
        -- Respect individual show settings
        if role == "TANK" then
            shouldShow = db.roleIconShowTank ~= false
        elseif role == "HEALER" then
            shouldShow = db.roleIconShowHealer ~= false
        elseif role == "DAMAGER" then
            shouldShow = db.roleIconShowDPS ~= false
        end
    end
    
    -- Debug
    if DF.debugRoleIcons then
        print("|cff00ffffDF ROLE:|r   applySettings=", applySettings, "shouldShow=", shouldShow)
    end
    
    if not shouldShow then
        frame.roleIcon:Hide()
        return
    end
    
    local tex, l, r, t, b = DF:GetRoleIconTexture(db, role)
    frame.roleIcon.texture:SetTexture(tex)
    frame.roleIcon.texture:SetTexCoord(l, r, t, b)
    
    frame.roleIcon:Show()
    
    -- Apply positioning
    local scale = db.roleIconScale or 1.0
    local anchor = db.roleIconAnchor or "TOPLEFT"
    local x = db.roleIconX or 2
    local y = db.roleIconY or -2
    local alpha = db.roleIconAlpha or 1
    
    frame.roleIcon:SetScale(scale)
    frame.roleIcon:ClearAllPoints()
    frame.roleIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.roleIcon:SetAlpha(alpha)
    
    -- Apply frame level
    local frameLevel = db.roleIconFrameLevel or 0
    if frameLevel > 0 then
        frame.roleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

function DF:UpdateAllRoleIcons()
    if DF.RosterDebugCount then DF:RosterDebugCount("UpdateAllRoleIcons") end
    
    -- Use our tracked combat state
    local inCombat = DF.playerInCombat or false
    
    -- Debug (use /df debugrole to enable)
    if DF.debugRoleIcons then
        print("|cff00ffffDF ROLE:|r UpdateAllRoleIcons called, InCombat:", inCombat)
    end
    
    local function updateFrame(frame)
        if frame and frame:IsShown() then
            DF:UpdateRoleIcon(frame, "UpdateAllRoleIcons")
            DF:UpdateLeaderIcon(frame)
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

function DF:UpdateLeaderIcon(frame)
    if not frame or not frame.unit or not frame.leaderIcon then return end
    
    -- Use raid DB for raid frames, party DB for party frames
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
    local isLeader = UnitIsGroupLeader(unit)
    local isAssist = UnitIsGroupAssistant(unit) and not isLeader
    
    if isLeader then
        frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
        frame.leaderIcon:Show()
    elseif isAssist then
        frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
        frame.leaderIcon:Show()
    else
        frame.leaderIcon:Hide()
        return
    end
    
    -- Apply positioning
    local scale = db.leaderIconScale or 1.0
    local anchor = db.leaderIconAnchor or "TOPLEFT"
    local x = db.leaderIconX or -2
    local y = db.leaderIconY or 2
    local alpha = db.leaderIconAlpha or 1
    
    frame.leaderIcon:SetScale(scale)
    frame.leaderIcon:ClearAllPoints()
    frame.leaderIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.leaderIcon:SetAlpha(alpha)
    
    -- Apply frame level
    local frameLevel = db.leaderIconFrameLevel or 0
    if frameLevel > 0 then
        frame.leaderIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

function DF:UpdateRaidTargetIcon(frame)
    if not frame or not frame.unit or not frame.raidTargetIcon then return end
    
    -- Use raid DB for raid frames, party DB for party frames
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
    
    -- Get raid target index (secret-safe)
    local index = nil
    local isSecret = false
    pcall(function()
        index = GetRaidTargetIndex(frame.unit)
    end)
    
    -- Check if it's a secret value
    if issecretvalue and issecretvalue(index) then
        isSecret = true
    end
    
    if isSecret then
        -- In Midnight, use SetSpriteSheetCell for secret values
        frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        if frame.raidTargetIcon.texture.SetSpriteSheetCell then
            pcall(function()
                frame.raidTargetIcon.texture:SetSpriteSheetCell(index, 4, 4, 64, 64)
            end)
        end
        frame.raidTargetIcon:Show()
    elseif index then
        -- Normal case - index is accessible
        frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(frame.raidTargetIcon.texture, index)
        frame.raidTargetIcon:Show()
    else
        frame.raidTargetIcon:Hide()
        return
    end
    
    -- Apply positioning
    local scale = db.raidTargetIconScale or 1.5
    local anchor = db.raidTargetIconAnchor or "TOP"
    local x = db.raidTargetIconX or 0
    local y = db.raidTargetIconY or 2
    local alpha = db.raidTargetIconAlpha or 1
    
    frame.raidTargetIcon:SetScale(scale)
    frame.raidTargetIcon:ClearAllPoints()
    frame.raidTargetIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.raidTargetIcon:SetAlpha(alpha)
    
    -- Apply frame level
    local frameLevel = db.raidTargetIconFrameLevel or 0
    if frameLevel > 0 then
        frame.raidTargetIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

function DF:UpdateReadyCheckIcon(frame)
    if not frame or not frame.unit or not frame.readyCheckIcon then return end
    
    -- Use raid DB for raid frames, party DB for party frames
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
    
    local readyCheckStatus = GetReadyCheckStatus(frame.unit)
    
    if readyCheckStatus == "ready" then
        frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        frame.readyCheckIcon:Show()
    elseif readyCheckStatus == "notready" then
        frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        frame.readyCheckIcon:Show()
    elseif readyCheckStatus == "waiting" then
        -- Check if player is AFK while waiting (enhanced ready check)
        local isAFK = nil
        pcall(function()
            isAFK = UnitIsAFK(frame.unit)
        end)
        
        -- Use issecretvalue check
        local afkAccessible = isAFK ~= nil and not (issecretvalue and issecretvalue(isAFK))
        
        if afkAccessible and isAFK then
            -- AFK state - show not ready icon (they likely won't respond)
            frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        else
            frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting")
        end
        frame.readyCheckIcon:Show()
    else
        frame.readyCheckIcon:Hide()
        return
    end
    
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
    
    -- Apply frame level
    local frameLevel = db.readyCheckIconFrameLevel or 0
    if frameLevel > 0 then
        frame.readyCheckIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

-- Schedule ready check icon to hide after a delay
function DF:ScheduleReadyCheckHide(frame)
    if not frame or not frame.readyCheckIcon then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local delay = db.readyCheckIconPersist or 6  -- Default 6 seconds
    
    -- Cancel any existing timer for this frame
    if frame.readyCheckHideTimer then
        frame.readyCheckHideTimer:Cancel()
        frame.readyCheckHideTimer = nil
    end
    
    -- Schedule hiding after delay
    frame.readyCheckHideTimer = C_Timer.NewTimer(delay, function()
        if frame.readyCheckIcon then
            frame.readyCheckIcon:Hide()
        end
        frame.readyCheckHideTimer = nil
    end)
end

function DF:UpdateCenterStatusIcon(frame)
    if not frame or not frame.unit then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    -- Update new individual icons
    if DF.UpdateSummonIcon then DF:UpdateSummonIcon(frame) end
    if DF.UpdateResurrectionIcon then DF:UpdateResurrectionIcon(frame) end
    if DF.UpdatePhasedIcon then DF:UpdatePhasedIcon(frame) end
    if DF.UpdateAFKIcon then DF:UpdateAFKIcon(frame) end
    if DF.UpdateVehicleIcon then DF:UpdateVehicleIcon(frame) end
    if DF.UpdateRaidRoleIcon then DF:UpdateRaidRoleIcon(frame) end
    
    -- DEPRECATED: Legacy centerStatusIcon handling (kept for backward compat)
    if not frame.centerStatusIcon then return end
    
    -- Check if enabled
    if not db.centerStatusIconEnabled then
        frame.centerStatusIcon:Hide()
        return
    end
    
    local unit = frame.unit
    local showIcon = false
    local texture = nil
    
    -- Check for incoming summon (secret-safe)
    if C_IncomingSummon and C_IncomingSummon.HasIncomingSummon then
        local summonStatus = nil
        pcall(function()
            summonStatus = C_IncomingSummon.IncomingSummonStatus(unit)
        end)
        
        -- Check if value is accessible
        if summonStatus ~= nil and not (issecretvalue and issecretvalue(summonStatus)) then
            if summonStatus == Enum.SummonStatus.Pending then
                texture = "Interface\\RaidFrame\\Raid-Icon-SummonPending"
                showIcon = true
            elseif summonStatus == Enum.SummonStatus.Accepted then
                texture = "Interface\\RaidFrame\\Raid-Icon-SummonAccepted"
                showIcon = true
            elseif summonStatus == Enum.SummonStatus.Declined then
                texture = "Interface\\RaidFrame\\Raid-Icon-SummonDeclined"
                showIcon = true
            end
        end
    end
    
    -- Check for incoming resurrect (if no summon) - secret-safe
    if not showIcon then
        local hasRes = nil
        pcall(function()
            hasRes = UnitHasIncomingResurrection(unit)
        end)
        
        if hasRes ~= nil and not (issecretvalue and issecretvalue(hasRes)) and hasRes then
            texture = "Interface\\RaidFrame\\Raid-Icon-Rez"
            showIcon = true
        end
    end
    
    if showIcon and texture then
        frame.centerStatusIcon.texture:SetTexture(texture)
        frame.centerStatusIcon:Show()
        
        -- Apply positioning
        local scale = db.centerStatusIconScale or 1.0
        local anchor = db.centerStatusIconAnchor or "CENTER"
        local x = db.centerStatusIconX or 0
        local y = db.centerStatusIconY or 0
        
        frame.centerStatusIcon:SetScale(scale)
        frame.centerStatusIcon:ClearAllPoints()
        frame.centerStatusIcon:SetPoint(anchor, frame, anchor, x, y)
        
        -- Apply frame level
        local frameLevel = db.centerStatusIconFrameLevel or 0
        if frameLevel > 0 then
            frame.centerStatusIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
        end
    else
        frame.centerStatusIcon:Hide()
    end
end

-- ============================================================
-- RESTED INDICATOR (Solo Mode)
-- ============================================================

function DF:UpdateRestedIndicator()
    -- Only applies to player frame in solo mode
    local playerFrame = DF:GetPlayerFrame()
    if not playerFrame then return end
    if not playerFrame.restedIndicator then return end
    
    local db = DF:GetDB()
    if not db then return end
    
    -- Check if rested indicator is enabled and we're in solo mode
    local inGroup = IsInGroup() or IsInRaid()
    local soloModeEnabled = db.soloMode == true
    local restedEnabled = db.restedIndicator ~= false  -- Default to true if nil
    local showIndicator = restedEnabled and soloModeEnabled and not inGroup
    
    -- Get individual icon/glow settings (default to true)
    local showIcon = db.restedIndicatorIcon ~= false
    local showGlow = db.restedIndicatorGlow ~= false
    
    if not showIndicator then
        playerFrame.restedIndicator:Hide()
        if playerFrame.restedGlow then
            playerFrame.restedGlow:Hide()
        end
        return
    end
    
    -- Check if player is resting and player frame is visible
    if IsResting() and playerFrame:IsShown() then
        -- Show/hide icon based on setting
        if showIcon then
            playerFrame.restedIndicator:Show()
        else
            playerFrame.restedIndicator:Hide()
        end
        
        -- Show/hide glow based on setting
        if playerFrame.restedGlow then
            if showGlow then
                playerFrame.restedGlow:Show()
            else
                playerFrame.restedGlow:Hide()
            end
        end
    else
        playerFrame.restedIndicator:Hide()
        if playerFrame.restedGlow then
            playerFrame.restedGlow:Hide()
        end
    end
end

-- Debug function for rested indicator
function DF:DebugRestedIndicator()
    print("|cff00ff00DandersFrames:|r Rested Indicator Debug")
    local playerFrame = DF:GetPlayerFrame()
    print("  playerFrame exists:", playerFrame ~= nil)
    if playerFrame then
        print("  playerFrame:IsShown():", playerFrame:IsShown())
        print("  restedIndicator exists:", playerFrame.restedIndicator ~= nil)
        if playerFrame.restedIndicator then
            print("  restedIndicator:IsShown():", playerFrame.restedIndicator:IsShown())
        end
        print("  restedGlow exists:", playerFrame.restedGlow ~= nil)
        if playerFrame.restedGlow then
            print("  restedGlow:IsShown():", playerFrame.restedGlow:IsShown())
        end
    end
    local db = DF:GetDB()
    if db then
        print("  db.soloMode:", db.soloMode)
        print("  db.restedIndicator:", db.restedIndicator)
        print("  db.restedIndicatorIcon:", db.restedIndicatorIcon)
        print("  db.restedIndicatorGlow:", db.restedIndicatorGlow)
    end
    print("  IsResting():", IsResting())
    print("  IsInGroup():", IsInGroup())
    print("  IsInRaid():", IsInRaid())
end

-- Raid buff definitions: {spellID, configKey, name, class}
-- Icons are looked up dynamically using GetSpellTexture
-- Raid buff definitions: {spellID or {spellID, spellID2, ...}, configKey, name, class}
-- Some buffs have multiple spell IDs (e.g., cast spell vs applied buff)
DF.RaidBuffs = {
    {{1459, 432778}, "missingBuffCheckIntellect", "Arcane Intellect", "MAGE"},
    {21562, "missingBuffCheckStamina", "Power Word: Fortitude", "PRIEST"},
    {6673, "missingBuffCheckAttackPower", "Battle Shout", "WARRIOR"},
    {{1126, 432661}, "missingBuffCheckVersatility", "Mark of the Wild", "DRUID"},
    {462854, "missingBuffCheckSkyfury", "Skyfury", "SHAMAN"},
    -- Blessing of the Bronze: 13 variant buff IDs from different Evoker augment specs
    {{381732, 381741, 381746, 381748, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758}, "missingBuffCheckBronze", "Blessing of the Bronze", "EVOKER"},
}

-- Map player class to their raid buff config key
DF.ClassToRaidBuff = {
    ["MAGE"] = "missingBuffCheckIntellect",
    ["PRIEST"] = "missingBuffCheckStamina",
    ["WARRIOR"] = "missingBuffCheckAttackPower",
    ["DRUID"] = "missingBuffCheckVersatility",
    ["SHAMAN"] = "missingBuffCheckSkyfury",
    ["EVOKER"] = "missingBuffCheckBronze",
}

-- Get the list of raid buff spell IDs (for filtering from display)
function DF:GetRaidBuffSpellIDs()
    local spellIDs = {}
    for _, buffInfo in ipairs(DF.RaidBuffs) do
        local spellIDOrTable = buffInfo[1]
        if type(spellIDOrTable) == "table" then
            for _, spellID in ipairs(spellIDOrTable) do
                spellIDs[spellID] = true
            end
        else
            spellIDs[spellIDOrTable] = true
        end
    end
    return spellIDs
end

-- Non-secret raid buff spell IDs (Blizzard-whitelisted, remain readable in combat)
-- Source: Ellesmere whitelist, cross-referenced with our RaidBuffs
DF.NonSecretRaidBuffIDs = {}
do
    local WHITELISTED = {
        [1126]=true, [432661]=true, [1459]=true, [432778]=true,
        [21562]=true, [6673]=true, [462854]=true,
        [381732]=true, [381741]=true, [381746]=true, [381748]=true, [381749]=true,
        [381750]=true, [381751]=true, [381752]=true, [381753]=true, [381754]=true,
        [381756]=true, [381757]=true, [381758]=true,
    }
    for _, buffInfo in ipairs(DF.RaidBuffs) do
        local ids = type(buffInfo[1]) == "table" and buffInfo[1] or {buffInfo[1]}
        for _, id in ipairs(ids) do
            if WHITELISTED[id] then DF.NonSecretRaidBuffIDs[id] = true end
        end
    end
end

-- Get raid buff icons for fallback filtering (when spellId is secret)
-- This is cached after first call
