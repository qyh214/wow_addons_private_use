local addonName, DF = ...

-- ============================================================
-- BOSS DEBUFFS (PRIVATE AURAS) SUPPORT
-- Private Auras are boss debuffs that addons cannot see data for.
-- We can only provide "anchor" frames where Blizzard will render them.
-- ============================================================

-- Check if API exists
if not C_UnitAuras or not C_UnitAuras.AddPrivateAuraAnchor then
    return
end

-- Local references
local pairs, ipairs = pairs, ipairs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists

-- ============================================================
-- FILE-SCOPE STATE
-- ============================================================

-- Track anchor IDs per frame for cleanup
local frameAnchors = {}

-- Track container overlay anchor IDs per frame for cleanup
local containerOverlayAnchors = {}

-- Forward declarations (defined after SetupPrivateAuraAnchors)
local SetupContainerOverlay

-- Build the iconInfo table for AddPrivateAuraAnchor. Normalises values to
-- the safest envelope we have empirical evidence Blizzard renders correctly:
--   * iconWidth == iconHeight (square — always)
--   * rounded to an integer
--   * borderScale always passed explicitly so Blizzard's much-bigger
--     auto-scale doesn't kick in when the user's slider is at default 1.0
local function BuildIconInfo(iconSize, borderScale, textScale, parentFrame)
    local sz = math.floor(iconSize / textScale + 0.5)
    if sz < 1 then sz = 1 end
    local bs = (borderScale or 1.0) / textScale
    return {
        iconWidth   = sz,
        iconHeight  = sz,
        borderScale = bs,
        iconAnchor  = {
            point         = "CENTER",
            relativeTo    = parentFrame,
            relativePoint = "CENTER",
            offsetX       = 0,
            offsetY       = 0,
        },
    }
end

-- Force Blizzard's private aura renderer to re-snapshot the parent's frame
-- level. AddPrivateAuraAnchor caches the parent level on the FIRST register
-- and ignores it on every subsequent re-register against the same parent —
-- so after a remove + re-add cycle, the new icons render at the OLD cached
-- level and can end up painted behind the unit frame even if the parent's
-- level has been raised since.
--
-- Toggling the level to 0 and back to its real value forces the renderer
-- to re-read on the next paint. Workaround sourced from the Grid2 dev.
local function ForceFrameLevelRefresh(parent)
    if not parent then return end
    local level = parent:GetFrameLevel()
    parent:SetFrameLevel(0)
    parent:SetFrameLevel(level)
end

-- Pending updates queue (for changes made during combat)
local pendingUpdates = {}

-- Track if we need to set up anchors after combat
local needsPostCombatSetup = false

-- Helper to queue or execute updates
local function QueueOrExecute(updateType, func)
    if InCombatLockdown() then
        pendingUpdates[updateType] = func
        DF:Debug("Boss debuff changes queued until combat ends.")
    else
        func()
    end
end

-- Process pending updates after combat
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function()
    if next(pendingUpdates) then
        for updateType, func in pairs(pendingUpdates) do
            func()
        end
        pendingUpdates = {}
    end
    if needsPostCombatSetup then
        needsPostCombatSetup = false
        DF:Debug("Combat ended - setting up boss debuff anchors")
        DF:UpdateAllPrivateAuraAnchors()
    end
end)

-- ============================================================
-- POSITIONING HELPERS
-- ============================================================

local function GetGrowthAnchors(growth)
    if growth == "RIGHT" then
        return "LEFT", "RIGHT", 1, 0
    elseif growth == "LEFT" then
        return "RIGHT", "LEFT", -1, 0
    elseif growth == "DOWN" then
        return "TOP", "BOTTOM", 0, -1
    elseif growth == "UP" then
        return "BOTTOM", "TOP", 0, 1
    end
    return "LEFT", "RIGHT", 1, 0
end

-- ============================================================
-- MAIN SETUP FUNCTION
-- ============================================================

function DF:SetupPrivateAuraAnchors(frame)
    if not frame or not frame.unit then return end
    if frame.dfIsPetFrame then return end

    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enablePrivateAuras then return end

    if InCombatLockdown() then return end

    local unit = frame.unit
    local db = DF:GetFrameDB(frame)

    -- Clear existing anchors first
    DF:ClearPrivateAuraAnchors(frame)

    if not db.bossDebuffsEnabled then return end

    -- Read settings
    local maxIcons     = db.bossDebuffsMax or 4
    local spacing      = db.bossDebuffsSpacing or 2
    local growth       = db.bossDebuffsGrowth or "RIGHT"
    local anchor       = db.bossDebuffsAnchor or "LEFT"
    local offsetX      = db.bossDebuffsOffsetX or 0
    local offsetY      = db.bossDebuffsOffsetY or 0
    local frameLevel   = db.bossDebuffsFrameLevel or 35
    local showCountdown = db.bossDebuffsShowCountdown ~= false
    local showNumbers  = db.bossDebuffsShowNumbers ~= false
    local iconSize     = db.bossDebuffsIconSize or 20
    local borderScale  = db.bossDebuffsBorderScale or 1.0
    -- textScale: scales the container frame so Blizzard's rendered text
    -- (timer + stack count) inherits the scale automatically.
    -- The icon dimension is divided by textScale so the visible icon
    -- stays at the correct pixel size despite the parent being scaled.
    -- Spacing and offsets are also divided to stay correct in screen space.
    local textScale    = db.bossDebuffsTextScale or 1.0
    local hideTooltip  = db.bossDebuffsHideTooltip or false

    -- Compensated value (divided by textScale so screen-space size is correct)
    local scaledSize   = iconSize / textScale

    -- Growth anchoring
    local pointOnCurrent, pointOnPrev, xMult, yMult = GetGrowthAnchors(growth)

    -- Lazy-init frame storage
    if not frame.bossDebuffFrames then
        frame.bossDebuffFrames = {}
    end
    frameAnchors[frame] = {}

    -- Anchor against contentOverlay's level (the icon's actual parent in the
    -- normal case) rather than the unit frame's. The unit button's level can
    -- shift mid-life as the secure header reshuffles slots; contentOverlay's
    -- level is set once at create time and matches what every other indicator
    -- uses as its base.
    local baseLevel = (frame.contentOverlay or frame):GetFrameLevel()

    for i = 1, maxIcons do
        -- Lazy-create the icon frame
        local iconFrame = frame.bossDebuffFrames[i]
        if not iconFrame then
            iconFrame = CreateFrame("Frame", nil, frame.contentOverlay or frame)
            if iconFrame.SetPropagateMouseMotion  then iconFrame:SetPropagateMouseMotion(true)  end
            if iconFrame.SetPropagateMouseClicks  then iconFrame:SetPropagateMouseClicks(true)  end

            -- Debug background
            iconFrame.debugBg = iconFrame:CreateTexture(nil, "BACKGROUND")
            iconFrame.debugBg:SetAllPoints()
            iconFrame.debugBg:Hide()

            frame.bossDebuffFrames[i] = iconFrame
        end

        -- Apply scale to the container. Blizzard renders the icon (and its
        -- timer / stack text) as children of this frame, so they inherit the
        -- scale automatically. We compensate icon dimensions and spacing below
        -- so the final on-screen size matches the user's Width/Height settings.
        iconFrame:SetScale(textScale)

        iconFrame:SetParent(frame.contentOverlay or frame)
        iconFrame:ClearAllPoints()
        iconFrame:SetFrameStrata(db.bossDebuffsStrata or "HIGH")
        iconFrame:SetFrameLevel(baseLevel + frameLevel)

        -- hideTooltip: shrink the parent to sub-pixel so Blizzard's C-side icon
        -- children have no effective hit area and show no tooltip on hover.
        -- EnableMouse(false) alone does NOT work — Blizzard's private aura children
        -- are C-side and bypass the Lua mouse flag on the parent.
        -- The icon still renders at full size because iconInfo specifies the full
        -- iconSize regardless of parent size.
        -- With textScale active, all SetPoint offsets are in the container's local
        -- coordinate space (divided by textScale = screen pixels).
        if hideTooltip then
            iconFrame:SetSize(0.001, 0.001)
        else
            iconFrame:SetSize(scaledSize, scaledSize)
        end

        if i == 1 then
            local adjX = offsetX / textScale
            local adjY = offsetY / textScale
            if hideTooltip then
                -- Icon renders centered on the 0.001px frame. Shift by half the
                -- icon's screen-space size so its edge aligns with the anchor point.
                -- Divide by textScale to convert screen pixels → local coordinates.
                adjX = adjX + (iconSize / 2) * xMult / textScale
                adjY = adjY + (iconSize / 2) * yMult / textScale
            end
            iconFrame:SetPoint(pointOnCurrent, frame, anchor, adjX, adjY)
        else
            local prevFrame = frame.bossDebuffFrames[i - 1]
            local gapX = spacing * xMult / textScale
            local gapY = spacing * yMult / textScale
            if hideTooltip then
                -- Frames are 0.001px so chaining loses the icon dimension.
                -- Add a full icon size in screen space (divided by textScale
                -- to convert to local coordinates for SetPoint).
                -- abs() because xMult/yMult can be negative (LEFT/UP growth) — we
                -- want to extend the gap, not cancel it.
                gapX = gapX + iconSize * math.abs(xMult) / textScale
                gapY = gapY + iconSize * math.abs(yMult) / textScale
            end
            iconFrame:SetPoint(pointOnCurrent, prevFrame, pointOnPrev, gapX, gapY)
        end

        -- Restore normal mouse settings (EnableMouse alone is not sufficient to
        -- block tooltip on private auras, but keep it consistent).
        iconFrame:EnableMouse(not hideTooltip)
        if iconFrame.SetPropagateMouseMotion then iconFrame:SetPropagateMouseMotion(not hideTooltip) end
        if iconFrame.SetPropagateMouseClicks then iconFrame:SetPropagateMouseClicks(not hideTooltip) end

        iconFrame:Show()

        -- Debug background
        if DF.bossDebuffDebug and iconFrame.debugBg then
            local colors = {
                {1, 0, 0, 0.4}, {0, 1, 0, 0.4},
                {0, 0, 1, 0.4}, {1, 1, 0, 0.4},
            }
            local c = colors[i] or colors[1]
            iconFrame.debugBg:SetColorTexture(c[1], c[2], c[3], c[4])
            iconFrame.debugBg:Show()
        elseif iconFrame.debugBg then
            iconFrame.debugBg:Hide()
        end

        -- Single anchor registration — one call per slot, no second anchor needed.
        -- Timer text and stack count are rendered by Blizzard as children of
        -- iconFrame and inherit its scale, giving us scaled text for free.
        local anchorArgs = {
            unitToken = unit,
            auraIndex = i,
            parent    = iconFrame,
            showCountdownFrame   = showCountdown,
            showCountdownNumbers = showNumbers,
            iconInfo = BuildIconInfo(iconSize, borderScale, textScale, iconFrame),
            isContainer = false,
        }
        local anchorID = C_UnitAuras.AddPrivateAuraAnchor(anchorArgs)

        if DF.bossDebuffDebug then
            DF:Debug("  [" .. i .. "] AddPrivateAuraAnchor unit=" .. unit
                .. " anchorID=" .. tostring(anchorID))
        end

        if anchorID then
            table.insert(frameAnchors[frame], anchorID)
            ForceFrameLevelRefresh(iconFrame)
        end
        -- No else branch: leave iconFrame Shown so a future Setup/Reanchor call
        -- can re-register on this slot. Hiding here previously trapped the slot
        -- because the lightweight ReanchorPrivateAuras path skips !IsShown frames.
    end

    -- Set up container dispel overlay (native overlay)
    SetupContainerOverlay(frame, unit, db)

    -- Track which unit anchors are monitoring
    frame.bossDebuffAnchoredUnit = unit
end

-- ============================================================
-- CONTAINER DISPEL OVERLAY SETUP
-- Registers a single isContainer=true anchor that renders
-- Blizzard's native dispel overlay for private auras.
-- ============================================================

SetupContainerOverlay = function(frame, unit, db)
    -- Only run when the source selector includes Blizzard ("blizzard" or "both").
    local src = db.dispelOverlaySource or "both"
    if src ~= "blizzard" and src ~= "both" then return end

    -- Parent to the unit frame and match dfDispelOverlay's level (frame+6) so the
    -- native dispel overlay renders at the same depth as DF's own dispel overlay
    -- instead of above the frame border / text / icons.
    local wrapper = frame.containerOverlayFrame
    if not wrapper then
        wrapper = CreateFrame("Frame", nil, frame)
        wrapper:EnableMouse(false)
        if wrapper.SetMouseClickEnabled then wrapper:SetMouseClickEnabled(false) end
        frame.containerOverlayFrame = wrapper
    end

    wrapper:SetParent(frame)
    wrapper:ClearAllPoints()
    local sizeAdjust = db.bossDebuffsContainerOverlaySizeAdjust or 0
    wrapper:SetPoint("TOPLEFT", frame, "TOPLEFT", -sizeAdjust, sizeAdjust)
    wrapper:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", sizeAdjust, -sizeAdjust)
    wrapper:SetFrameStrata(db.bossDebuffsContainerOverlayStrata or "MEDIUM")
    wrapper:SetFrameLevel(frame:GetFrameLevel() + (db.bossDebuffsContainerOverlayFrameLevel or 6))
    -- Always keep the wrapper Shown so Blizzard's container eventFrame
    -- (a descendant, see Blizzard_PrivateAurasUI.lua:699-707) stays
    -- registered for UNIT_AURA. Visibility is controlled via alpha so
    -- the container's internal self.dispels stays in sync when we gate
    -- the overlay on dfDispelOverlay:IsShown().
    wrapper:Show()
    -- Apply the user-chosen alpha directly. In Blizzard mode the wrapper
    -- keeps this value permanently; in Hybrid mode the
    -- UpdateContainerOverlayVisibility call below may immediately override
    -- to 0 if DF's own overlay is currently shown.
    wrapper:SetAlpha(db.bossDebuffsContainerOverlayAlpha or 1.0)

    -- Determine group type from unit token
    local groupType
    if unit and unit:find("^party") then
        groupType = 4
    else
        groupType = 5
    end

    -- Set container attributes (must be set BEFORE AddPrivateAuraAnchor,
    -- because OnAnchorAdded calls ReadContainerSettings immediately)
    wrapper:SetAttribute("max-buffs", 0)
    wrapper:SetAttribute("max-debuffs", 0)
    wrapper:SetAttribute("max-dispel-debuffs", 1)
    wrapper:SetAttribute("ignore-buffs", true)
    wrapper:SetAttribute("ignore-debuffs", true)
    wrapper:SetAttribute("ignore-dispel-debuffs", true)
    wrapper:SetAttribute("show-dispel-indicator-overlay", true)
    wrapper:SetAttribute("suppress-dispel-border-icons", true)
    -- dispel-indicator-option drives both the TOPRIGHT dispel icons and the
    -- gradient: Blizzard only calls SetDispelOverlayAura from inside
    -- SetDispelDebuff, which always shows the icon first, so there's no way to
    -- hide the icons without also hiding the gradient.
    -- 1 = dispellable by me. 2 = all dispellable.
    wrapper:SetAttribute("dispel-indicator-option", db.dispelOverlayDispelType or 2)
    wrapper:SetAttribute("aura-organization-type", db.bossDebuffsContainerOverlayGradientDir)
    wrapper:SetAttribute("group-type", groupType)
    wrapper:SetAttribute("power-bar-used-height", 0)
    wrapper:SetAttribute("icon-size", 10)
    wrapper:SetAttribute("set-aura-size-to-icon-size", false)

    -- Register the container anchor
    local anchorID = C_UnitAuras.AddPrivateAuraAnchor({
        unitToken = unit,
        parent = wrapper,
        isContainer = true,
        auraIndex = 1,
        showCountdownFrame = false,
        showCountdownNumbers = false,
    })

    if anchorID then
        containerOverlayAnchors[frame] = anchorID
        ForceFrameLevelRefresh(wrapper)
        if DF.bossDebuffDebug then
            DF:Debug("Container overlay registered for " .. unit .. " anchorID=" .. tostring(anchorID))
        end
    elseif DF.bossDebuffDebug then
        DF:DebugError("Container overlay registration FAILED for " .. unit)
    end

    -- Initial visibility sync: if DF's own overlay is already shown for a
    -- normal dispellable debuff, keep the Blizzard wrapper hidden so they
    -- don't both render.
    DF:UpdateContainerOverlayVisibility(frame)
end

-- ============================================================
-- CONTAINER OVERLAY VISIBILITY GATE
-- Blizzard's container overlay (CompactUnitFrameDispelOverlayTemplate)
-- fires for ANY dispellable debuff, not just private auras — the scan
-- at PrivateAuraAnchorContainerMixin:ParseAllAuras calls AuraUtil.ForEachAura
-- for all Harmful/Helpful auras, then feeds them through CheckAddDispel.
-- There's no attribute to scope it to private-only.
--
-- Since DF already renders its own dispel overlay (dfDispelOverlay) for
-- normal dispellable debuffs via its own logic, showing Blizzard's on top
-- of that would double up visually.
--
-- Strategy: gate the Blizzard wrapper on DF's own overlay's shown state.
--   * dfDispelOverlay:IsShown() == true  → wrapper alpha = 0 (DF wins)
--   * dfDispelOverlay:IsShown() == false → wrapper alpha = user's chosen
--     alpha (Blizzard catches private auras DF can't see)
--
-- We use alpha (not Show/Hide) so the container's internal eventFrame
-- (a descendant of the wrapper) stays registered for UNIT_AURA —
-- Blizzard_PrivateAurasUI.lua:699-707 unregisters on OnHide. Otherwise
-- the container goes deaf while hidden and self.dispels / DispelOverlay
-- state stays stale until the next unrelated UNIT_AURA wakes it up,
-- which produced a visible "stale overlay flashes after debuff drops"
-- bug.
--
-- dfDispelOverlay:IsShown() is secret-safe: DF's show/hide uses plain
-- Show()/Hide() calls (never SetShownFromBoolean with a secret bool), so
-- the shown state is a regular boolean.
-- ============================================================

-- Hide is immediate (DF taking over — no race concern, Blizzard's
-- overlay is behind alpha=0 either way).
--
-- Reveal is deferred one frame via C_Timer.After(0) to avoid a
-- one-frame stale-flash of Blizzard's DispelOverlay: DF updates
-- synchronously inside UNIT_AURA, but Blizzard's container uses
-- MarkDirty → C_Timer.After(0, Clean) to defer its Update (and the
-- subsequent DispelOverlay:Hide()) by one frame. If we set alpha
-- synchronously on reveal, the stale overlay is briefly visible
-- through our userAlpha before Blizzard hides it on the next tick.
-- Deferring the reveal puts both transitions on the same next-frame
-- tick so they render together, flicker-free. The re-check inside
-- the timer handles rapid DF show→hide→show churn by confirming
-- dfOwnShown is still false before revealing.
function DF:UpdateContainerOverlayVisibility(frame)
    if not frame then return end
    local wrapper = frame.containerOverlayFrame
    if not wrapper then return end
    local db = DF:GetFrameDB(frame)
    local src = (db and db.dispelOverlaySource) or "both"

    -- Only the Hybrid ("both") source needs alpha-gating — that's the single
    -- mode where DF's own overlay and the Blizzard wrapper both exist and
    -- need to be alternated. In other modes the wrapper's alpha is owned
    -- by SetupContainerOverlay / UpdateContainerOverlaySettings directly:
    --   * off / dandersframes → wrapper doesn't exist (teardown elsewhere)
    --   * blizzard → wrapper stays at userAlpha permanently
    -- Skipping the rest of this function on every UNIT_AURA in Blizzard
    -- mode avoids a redundant GetFrameDB + SetAlpha per tick.
    if src ~= "both" then return end

    -- Hybrid ("both") gate: suppress the Blizzard wrapper while DF's own
    -- overlay is shown, reveal it otherwise (so Blizzard can still fire for
    -- private auras DF can't see).
    local dfOwnShown = frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown()
    if dfOwnShown then
        wrapper:SetAlpha(0)
        return
    end

    C_Timer.After(0, function()
        if not frame or not frame.containerOverlayFrame then return end
        -- Re-read in case DF took over again during the one-frame wait.
        local currentDfShown = frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown()
        if currentDfShown then return end
        local db2 = DF:GetFrameDB(frame)
        local alpha = (db2 and db2.bossDebuffsContainerOverlayAlpha) or 1.0
        frame.containerOverlayFrame:SetAlpha(alpha)
    end)
end

function DF:UpdateContainerOverlaySettings(frame)
    if not frame then return end

    local db = DF:GetFrameDB(frame)
    if not db then return end

    local wrapper = frame.containerOverlayFrame
    if not wrapper then return end

    -- If the source selector excludes Blizzard, do a full teardown.
    local src = db.dispelOverlaySource or "both"
    local blizOn = (src == "blizzard") or (src == "both")
    if not blizOn then
        local anchorID = containerOverlayAnchors[frame]
        if anchorID then
            C_UnitAuras.RemovePrivateAuraAnchor(anchorID)
            containerOverlayAnchors[frame] = nil
        end
        wrapper:Hide()
        return
    end

    -- If no anchor exists yet (was just enabled), do full setup
    if not containerOverlayAnchors[frame] then
        local unit = frame.bossDebuffAnchoredUnit or frame.unit
        if unit then
            SetupContainerOverlay(frame, unit, db)
        end
        return
    end

    -- Update attributes for live changes
    wrapper:SetAttribute("dispel-indicator-option", db.dispelOverlayDispelType or 2)
    wrapper:SetAttribute("aura-organization-type", db.bossDebuffsContainerOverlayGradientDir)

    -- Live strata + frame-level adjustment (user may need to raise these above
    -- text on short/wide frames where DF's content overlay covers the gradient,
    -- or to push Blizzard's level-0 child render frames above DF elements).
    wrapper:SetFrameStrata(db.bossDebuffsContainerOverlayStrata or "MEDIUM")
    local parent = wrapper:GetParent()
    if parent then
        wrapper:SetFrameLevel(parent:GetFrameLevel() + (db.bossDebuffsContainerOverlayFrameLevel or 6))
        local sizeAdjust = db.bossDebuffsContainerOverlaySizeAdjust or 0
        wrapper:ClearAllPoints()
        wrapper:SetPoint("TOPLEFT", parent, "TOPLEFT", -sizeAdjust, sizeAdjust)
        wrapper:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", sizeAdjust, -sizeAdjust)
    end

    -- Push the user alpha directly so Blizzard-mode slider changes take
    -- effect (UpdateContainerOverlayVisibility is Hybrid-only now and would
    -- no-op otherwise). In Hybrid mode the gate call immediately overrides
    -- to 0 if DF's overlay is visible.
    wrapper:SetAlpha(db.bossDebuffsContainerOverlayAlpha or 1.0)
    DF:UpdateContainerOverlayVisibility(frame)

    -- Signal the container to re-read settings
    wrapper:SetAttribute("update-settings", true)
end

-- ============================================================
-- CLEAR ANCHORS
-- ============================================================

function DF:ClearPrivateAuraAnchors(frame)
    if not frame then return end
    if frame.isBeingCleared then return end
    if InCombatLockdown() then return end
    frame.isBeingCleared = true

    -- Remove Blizzard anchors
    local anchors = frameAnchors[frame]
    if anchors then
        for _, anchorID in ipairs(anchors) do
            C_UnitAuras.RemovePrivateAuraAnchor(anchorID)
        end
        frameAnchors[frame] = nil
    end

    -- Hide icon frames (keep for reuse)
    if frame.bossDebuffFrames then
        for _, iconFrame in ipairs(frame.bossDebuffFrames) do
            iconFrame:Hide()
            iconFrame:ClearAllPoints()
        end
    end

    -- Remove container overlay anchor
    local containerAnchorID = containerOverlayAnchors[frame]
    if containerAnchorID then
        C_UnitAuras.RemovePrivateAuraAnchor(containerAnchorID)
        containerOverlayAnchors[frame] = nil
    end

    -- Hide container overlay wrapper (keep for reuse)
    if frame.containerOverlayFrame then
        frame.containerOverlayFrame:Hide()
    end

    frame.bossDebuffAnchoredUnit = nil
    frame.isBeingCleared = nil
end

-- ============================================================
-- LIGHTWEIGHT REANCHOR (unit token changed, frames stay)
-- ============================================================

-- Rebinds all private aura anchors (icon, per-slot overlay, and container
-- overlay) for a frame whose unit token shifted. Safe to call in combat since
-- 12.0.5 lifted the combat lock on AddPrivateAuraAnchor / RemovePrivateAuraAnchor.
-- The container overlay path re-applies "group-type" + "update-settings" so the
-- Blizzard container re-reads its attributes on re-register (matches Grid2).
function DF:ReanchorPrivateAuras(frame)
    if not frame or not frame.unit then return end
    if frame.dfIsPetFrame then return end
    if not frame.bossDebuffFrames or #frame.bossDebuffFrames == 0 then return end

    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enablePrivateAuras then return end

    local newUnit = frame.unit
    local db = DF:GetFrameDB(frame)
    if not db or not db.bossDebuffsEnabled then return end

    -- Idempotency guard
    if frame.bossDebuffAnchoredUnit == newUnit then return end

    -- Remove old anchors (API only, keep frames)
    local oldAnchors = frameAnchors[frame]
    if oldAnchors then
        for _, anchorID in ipairs(oldAnchors) do
            C_UnitAuras.RemovePrivateAuraAnchor(anchorID)
        end
    end
    frameAnchors[frame] = {}

    -- Re-read settings
    local showCountdown = db.bossDebuffsShowCountdown ~= false
    local showNumbers   = db.bossDebuffsShowNumbers ~= false
    local iconSize      = db.bossDebuffsIconSize or 20
    local borderScale   = db.bossDebuffsBorderScale or 1.0
    local textScale     = db.bossDebuffsTextScale or 1.0
    local frameLevel    = db.bossDebuffsFrameLevel or 35

    -- Re-apply icon frame level. The unit button's level can shift across
    -- secure header reshuffles, so a level captured at first SetupPrivateAuraAnchors
    -- can drift and leave icons rendering behind frame elements.
    local baseLevel = (frame.contentOverlay or frame):GetFrameLevel()

    -- Re-register each frame with new unit token
    local strata = db.bossDebuffsStrata or "HIGH"
    for i, iconFrame in ipairs(frame.bossDebuffFrames) do
        if iconFrame:IsShown() then
            iconFrame:SetFrameStrata(strata)
            iconFrame:SetFrameLevel(baseLevel + frameLevel)
            local anchorID = C_UnitAuras.AddPrivateAuraAnchor({
                unitToken = newUnit,
                auraIndex = i,
                parent    = iconFrame,
                showCountdownFrame   = showCountdown,
                showCountdownNumbers = showNumbers,
                iconInfo = BuildIconInfo(iconSize, borderScale, textScale, iconFrame),
                isContainer = false,
            })

            if anchorID then
                table.insert(frameAnchors[frame], anchorID)
                ForceFrameLevelRefresh(iconFrame)
            end
        end
    end

    -- Rebind container overlay anchor (isContainer=true path)
    local src = db.dispelOverlaySource or "both"
    if (src == "blizzard" or src == "both") and frame.containerOverlayFrame then
        local oldContainerAnchor = containerOverlayAnchors[frame]
        if oldContainerAnchor then
            C_UnitAuras.RemovePrivateAuraAnchor(oldContainerAnchor)
            containerOverlayAnchors[frame] = nil
        end

        local wrapper = frame.containerOverlayFrame
        local groupType = newUnit:find("^party") and 4 or 5
        wrapper:SetAttribute("group-type", groupType)
        wrapper:SetAttribute("update-settings", true)

        local cAnchorID = C_UnitAuras.AddPrivateAuraAnchor({
            unitToken = newUnit,
            parent = wrapper,
            isContainer = true,
            auraIndex = 1,
            showCountdownFrame = false,
            showCountdownNumbers = false,
        })
        if cAnchorID then
            containerOverlayAnchors[frame] = cAnchorID
            ForceFrameLevelRefresh(wrapper)
        end
    end

    -- Only mark the unit anchored if at least one slot succeeded. Otherwise
    -- the idempotency guard at the top of this function would lock out all
    -- future retries even though zero anchors are actually registered.
    if frameAnchors[frame] and #frameAnchors[frame] > 0 then
        frame.bossDebuffAnchoredUnit = newUnit
    end

    if DF.bossDebuffDebug then
        DF:Debug("Reanchored " .. #frame.bossDebuffFrames .. " frames to "
            .. newUnit .. " (" .. #frameAnchors[frame] .. " anchors)")
    end
end

-- ============================================================
-- DEBOUNCED REANCHOR ALL FRAMES
-- ============================================================

local pendingReanchor = false

function DF:SchedulePrivateAuraReanchor()
    if pendingReanchor then return end
    pendingReanchor = true
    C_Timer.After(0, function()
        pendingReanchor = false
        if DF.IterateAllFrames then
            DF:IterateAllFrames(function(frame)
                if frame and frame.unit then
                    DF:ReanchorPrivateAuras(frame)
                end
            end)
        end
        -- Pinned frames
        if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header then
                    for i = 1, 40 do
                        local child = header:GetAttribute("child" .. i)
                        if child and child.unit then
                            DF:ReanchorPrivateAuras(child)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- LIGHTWEIGHT UPDATE FUNCTIONS (no anchor recreation)
-- ============================================================

local function UpdateFramePositions(frame)
    if not frame or not frame.bossDebuffFrames or #frame.bossDebuffFrames == 0 then return end

    local db = DF:GetFrameDB(frame)
    local spacing     = db.bossDebuffsSpacing or 2
    local growth      = db.bossDebuffsGrowth or "RIGHT"
    local anchor      = db.bossDebuffsAnchor or "LEFT"
    local offsetX     = db.bossDebuffsOffsetX or 0
    local offsetY     = db.bossDebuffsOffsetY or 0
    local textScale   = db.bossDebuffsTextScale or 1.0
    local hideTooltip = db.bossDebuffsHideTooltip or false
    local iconSize    = db.bossDebuffsIconSize or 20

    local pointOnCurrent, pointOnPrev, xMult, yMult = GetGrowthAnchors(growth)

    for i, iconFrame in ipairs(frame.bossDebuffFrames) do
        iconFrame:ClearAllPoints()
        if i == 1 then
            local adjX = offsetX / textScale
            local adjY = offsetY / textScale
            if hideTooltip then
                adjX = adjX + (iconSize / 2) * xMult / textScale
                adjY = adjY + (iconSize / 2) * yMult / textScale
            end
            iconFrame:SetPoint(pointOnCurrent, frame, anchor, adjX, adjY)
        else
            local prevFrame = frame.bossDebuffFrames[i - 1]
            local gapX = spacing * xMult / textScale
            local gapY = spacing * yMult / textScale
            if hideTooltip then
                gapX = gapX + iconSize * math.abs(xMult) / textScale
                gapY = gapY + iconSize * math.abs(yMult) / textScale
            end
            iconFrame:SetPoint(pointOnCurrent, prevFrame, pointOnPrev, gapX, gapY)
        end
    end
end

function DF:UpdateAllPrivateAuraPositions()
    QueueOrExecute("positions", function()
        DF:IterateAllFrames(function(frame)
            if frame and frame.bossDebuffFrames then
                UpdateFramePositions(frame)
            end
        end)
    end)
end

function DF:UpdateAllPrivateAuraFrameLevel()
    QueueOrExecute("frameLevel", function()
        DF:IterateAllFrames(function(frame)
            if not frame or not frame.bossDebuffFrames then return end
            local db = DF:GetFrameDB(frame)
            local frameLevel = db.bossDebuffsFrameLevel or 35
            local baseLevel = (frame.contentOverlay or frame):GetFrameLevel()
            for _, iconFrame in ipairs(frame.bossDebuffFrames) do
                iconFrame:SetFrameLevel(baseLevel + frameLevel)
            end
        end)
    end)
end

function DF:UpdateAllPrivateAuraStrata()
    QueueOrExecute("strata", function()
        DF:IterateAllFrames(function(frame)
            if not frame or not frame.bossDebuffFrames then return end
            local db = DF:GetFrameDB(frame)
            local strata = db.bossDebuffsStrata or "HIGH"
            for _, iconFrame in ipairs(frame.bossDebuffFrames) do
                iconFrame:SetFrameStrata(strata)
            end
        end)
    end)
end

function DF:UpdateAllPrivateAuraVisibility()
    QueueOrExecute("visibility", function()
        DF:IterateAllFrames(function(frame)
            if not frame or not frame.bossDebuffFrames then return end
            local db = DF:GetFrameDB(frame)
            local enabled = db.bossDebuffsEnabled
            for _, iconFrame in ipairs(frame.bossDebuffFrames) do
                if enabled then
                    iconFrame:Show()
                else
                    iconFrame:Hide()
                end
            end
        end)
    end)
end

-- ============================================================
-- REFRESH ALL FRAMES
-- ============================================================

local refreshTimer = nil

function DF:PreviewPrivateAuraAnchors()
    if InCombatLockdown() then
        QueueOrExecute("refresh", function()
            DF:RefreshAllPrivateAuraAnchors()
        end)
        return
    end

    -- Immediately update first visible frame for preview
    local updatedFirst = false
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            if not updatedFirst and frame and frame.unit and frame:IsVisible() then
                DF:ClearPrivateAuraAnchors(frame)
                DF:SetupPrivateAuraAnchors(frame)
                updatedFirst = true
            end
        end)
    end

    -- Debounced full refresh for remaining frames
    if refreshTimer then
        refreshTimer:Cancel()
    end
    refreshTimer = C_Timer.NewTimer(0.3, function()
        refreshTimer = nil
        DF:RefreshRemainingPrivateAuraAnchors()
    end)
end

function DF:RefreshRemainingPrivateAuraAnchors()
    if InCombatLockdown() then
        QueueOrExecute("refreshRemaining", function()
            DF:RefreshRemainingPrivateAuraAnchors()
        end)
        return
    end

    local skippedFirst = false
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            if frame and frame.unit then
                if not skippedFirst and frame:IsVisible() then
                    skippedFirst = true
                else
                    DF:ClearPrivateAuraAnchors(frame)
                    DF:SetupPrivateAuraAnchors(frame)
                end
            end
        end)
    end

    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            if frame and frame.unit then
                DF:ClearPrivateAuraAnchors(frame)
                DF:SetupPrivateAuraAnchors(frame)
            end
        end)
    end
end

function DF:RefreshAllPrivateAuraAnchorsDebounced()
    if refreshTimer then
        refreshTimer:Cancel()
    end
    refreshTimer = C_Timer.NewTimer(0.3, function()
        refreshTimer = nil
        if InCombatLockdown() then
            needsPostCombatSetup = true
            return
        end
        DF:RefreshAllPrivateAuraAnchors()
    end)
end

function DF:RefreshAllPrivateAuraAnchors()
    QueueOrExecute("refresh", function()
        if DF.IteratePartyFrames then
            DF:IteratePartyFrames(function(frame)
                if frame and frame.unit then
                    DF:ClearPrivateAuraAnchors(frame)
                    DF:SetupPrivateAuraAnchors(frame)
                end
            end)
        end

        if DF.IterateRaidFrames then
            DF:IterateRaidFrames(function(frame)
                if frame and frame.unit then
                    DF:ClearPrivateAuraAnchors(frame)
                    DF:SetupPrivateAuraAnchors(frame)
                end
            end)
        end

        -- Pinned frames
        if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header then
                    for i = 1, 40 do
                        local child = header:GetAttribute("child" .. i)
                        if child and child.unit then
                            DF:ClearPrivateAuraAnchors(child)
                            DF:SetupPrivateAuraAnchors(child)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- UPDATE ALL FRAMES
-- ============================================================

function DF:UpdateAllPrivateAuraAnchors()
    if InCombatLockdown() then
        needsPostCombatSetup = true
        return
    end

    local function setupIfNeeded(frame)
        if frame and frame.unit then
            local anchors = frameAnchors[frame]
            if not anchors or #anchors == 0 then
                DF:SetupPrivateAuraAnchors(frame)
            end
        end
    end

    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(setupIfNeeded)
    end

    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(setupIfNeeded)
    end

    -- Pinned frames
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header then
                for i = 1, 40 do
                    local child = header:GetAttribute("child" .. i)
                    if child then
                        setupIfNeeded(child)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DandersFrames" then
        if not InCombatLockdown() then
            DF:UpdateAllPrivateAuraAnchors()
        else
            needsPostCombatSetup = true
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if not InCombatLockdown() then
            DF:UpdateAllPrivateAuraAnchors()
        else
            needsPostCombatSetup = true
        end

    elseif event == "GROUP_ROSTER_UPDATE" then
        if not InCombatLockdown() then
            C_Timer.After(0.1, function()
                if not InCombatLockdown() then
                    DF:UpdateAllPrivateAuraAnchors()
                else
                    DF:SchedulePrivateAuraReanchor()
                end
            end)
        else
            DF:SchedulePrivateAuraReanchor()
        end
    end
end)

-- ============================================================
-- DEBUG COMMANDS
-- ============================================================

SLASH_DFBOSSDEBUFFS1 = "/dfboss"
SlashCmdList["DFBOSSDEBUFFS"] = function(msg)
    msg = msg:lower():trim()

    if msg == "refresh" or msg == "update" then
        DF:RefreshAllPrivateAuraAnchors()
        print("|cff00ff00DandersFrames:|r Boss debuff anchors refreshed")

    elseif msg == "debug" then
        DF.bossDebuffDebug = not DF.bossDebuffDebug
        local show = DF.bossDebuffDebug

        DF:IterateAllFrames(function(frame)
            if frame and frame.bossDebuffFrames then
                local colors = {
                    {1, 0, 0, 0.4},
                    {0, 1, 0, 0.4},
                    {0, 0, 1, 0.4},
                    {1, 1, 0, 0.4},
                }
                for i, iconFrame in ipairs(frame.bossDebuffFrames) do
                    if iconFrame.debugBg then
                        if show then
                            local c = colors[i] or colors[1]
                            iconFrame.debugBg:SetColorTexture(c[1], c[2], c[3], c[4])
                            iconFrame.debugBg:Show()
                        else
                            iconFrame.debugBg:Hide()
                        end
                    end
                end
            end
        end)

        print("|cff00ff00DandersFrames:|r Debug mode " .. (show and "ON" or "OFF"))

    elseif msg == "status" then
        local anchorCount = 0
        local frameCount = 0
        for frame, anchors in pairs(frameAnchors) do
            frameCount = frameCount + 1
            anchorCount = anchorCount + #anchors
        end
        print("|cff00ff00DandersFrames:|r Frames with anchors: " .. frameCount)
        print("|cff00ff00DandersFrames:|r Total anchors registered: " .. anchorCount)

        local db = DF:GetDB()
        print("|cff00ff00DandersFrames:|r Settings:")
        print("  bossDebuffsEnabled: " .. tostring(db.bossDebuffsEnabled))
        print("  bossDebuffsMax: " .. tostring(db.bossDebuffsMax))
        print("  bossDebuffsTextScale: " .. tostring(db.bossDebuffsTextScale))

    elseif msg == "frames" then
        print("|cff00ff00DandersFrames:|r Frame Debug:")

        local partyCount = 0
        if DF.IteratePartyFrames then
            DF:IteratePartyFrames(function(frame)
                partyCount = partyCount + 1
                print("  Party[" .. partyCount .. "] " .. tostring(frame:GetName()) .. " unit=" .. tostring(frame.unit))
            end)
        end
        print("  Party frames total: " .. partyCount)

        local raidCount = 0
        if DF.IterateRaidFrames then
            DF:IterateRaidFrames(function(frame)
                raidCount = raidCount + 1
            end)
        end
        print("  Raid frames total: " .. raidCount)

    elseif msg == "force" then
        print("|cff00ff00DandersFrames:|r Force setting up anchors...")
        DF.bossDebuffDebug = true

        local function forceSetup(frame, name)
            if frame and frame.unit then
                print("  Setting up: " .. name .. " unit=" .. frame.unit)

                DF:ClearPrivateAuraAnchors(frame)

                local db = DF:GetFrameDB(frame)
                print("    DB bossDebuffsEnabled: " .. tostring(db.bossDebuffsEnabled))

                local wasEnabled = db.bossDebuffsEnabled
                db.bossDebuffsEnabled = true
                DF:SetupPrivateAuraAnchors(frame)
                db.bossDebuffsEnabled = wasEnabled

                if frame.bossDebuffFrames then
                    print("    Frames created: " .. #frame.bossDebuffFrames)
                    for i, f in ipairs(frame.bossDebuffFrames) do
                        print("      [" .. i .. "] shown=" .. tostring(f:IsShown()) .. " parent=" .. tostring(f:GetParent() and f:GetParent():GetName()))
                        if f.debugBg then f.debugBg:Show() end
                    end
                else
                    print("    No frames created!")
                end
            end
        end

        local idx = 0
        DF:IteratePartyFrames(function(frame)
            idx = idx + 1
            forceSetup(frame, "partyFrame["..idx.."]")
        end)

        idx = 0
        DF:IterateRaidFrames(function(frame)
            idx = idx + 1
            forceSetup(frame, "raidFrame["..idx.."]")
        end)
        print("|cff00ff00DandersFrames:|r Done!")

    else
        print("|cff00ff00DandersFrames Boss Debuffs:|r")
        print("  /dfboss refresh - Refresh anchors")
        print("  /dfboss debug - Toggle debug backgrounds")
        print("  /dfboss status - Show anchor status")
        print("  /dfboss frames - Show all frame references")
        print("  /dfboss force - Force setup on all frames with debug")
    end
end
