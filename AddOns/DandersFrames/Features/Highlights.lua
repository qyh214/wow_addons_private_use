local addonName, DF = ...

-- ============================================================
-- HIGHLIGHT SYSTEM
-- Animated/styled borders for selection and aggro highlights
-- ============================================================

-- Animation settings.
--
-- ANIMATION_SPEED paired with UPDATE_INTERVAL determines the visual
-- smoothness. The per-sample pixel delta is ANIMATION_SPEED / Hz.
-- When that delta exceeds ~1 pixel the eye perceives discrete stepping
-- rather than continuous motion — the LCD persistence/blur trick that
-- sells sub-pixel motion as smooth flow breaks down.
--
-- The original code ran at 60 Hz with speed 40 → 0.67 px/sample.
-- That's sub-pixel and looks smooth. When the throttle dropped redraw
-- to 30 Hz it became 1.33 px/sample (super-pixel) which looks choppy.
--
-- Solution: halve the speed. 30 Hz × 20 px/sec = 0.67 px/sample, the
-- same per-sample delta as the original. Visually identical smoothness
-- to pre-throttle. The only behavioral change is the full pattern
-- cycle now takes 0.6s instead of 0.3s — ants march at half speed,
-- which a lot of users actually prefer over the more frenetic original.
local ANIMATION_SPEED = 20
local DASH_LENGTH = 6
local GAP_LENGTH = 6
local PATTERN_LENGTH = DASH_LENGTH + GAP_LENGTH

-- Redraw throttle. At 30 Hz with ANIMATION_SPEED 20 the per-sample
-- delta is 0.67 px, matching the original 60 Hz × 40 smoothness exactly.
-- `elapsed` still accumulates every WoW tick so the offset stays
-- smooth when we do sample.
local UPDATE_INTERVAL = 1 / 30

-- Global animator for marching ants effect
local SelectionAnimator = CreateFrame("Frame")
SelectionAnimator.elapsed = 0
SelectionAnimator.accum = 0
SelectionAnimator.frames = {}
SelectionAnimator.hasFrames = false  -- Track whether any frames are registered

local function SelectionAnimator_OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    self.accum = self.accum + elapsed
    if self.accum < UPDATE_INTERVAL then return end
    self.accum = 0
    local offset = (self.elapsed * ANIMATION_SPEED) % PATTERN_LENGTH
    for highlightFrame in pairs(self.frames) do
        if highlightFrame:IsShown() then
            DF:UpdateAnimatedBorder(highlightFrame, offset)
        end
    end
end

-- Add/remove frames and auto-enable/disable the OnUpdate
local function SelectionAnimator_Add(frame)
    SelectionAnimator.frames[frame] = true
    -- Prime the throttle so the first tick after a frame is added draws
    -- immediately. Without this, there's up to 33ms of empty border on
    -- first appearance.
    SelectionAnimator.accum = UPDATE_INTERVAL
    if not SelectionAnimator.hasFrames then
        SelectionAnimator.hasFrames = true
        SelectionAnimator:SetScript("OnUpdate", SelectionAnimator_OnUpdate)
    end
end

local function SelectionAnimator_Remove(frame)
    SelectionAnimator.frames[frame] = nil
    if SelectionAnimator.hasFrames and not next(SelectionAnimator.frames) then
        SelectionAnimator.hasFrames = false
        SelectionAnimator:SetScript("OnUpdate", nil)
    end
end

-- ============================================================
-- ANIMATED BORDER (Marching Ants)
-- ============================================================

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

local function InitAnimatedBorder(ch)
    if ch.animBorder then return ch.animBorder end
    ch.animBorder = {
        topDashes = CreateEdgeDashes(ch, 20),
        bottomDashes = CreateEdgeDashes(ch, 20),
        leftDashes = CreateEdgeDashes(ch, 20),
        rightDashes = CreateEdgeDashes(ch, 20),
    }
    return ch.animBorder
end

-- PERFORMANCE FIX: These functions are defined at module level to avoid creating
-- new closures every frame when UpdateAnimatedBorder runs.
--
-- Additional per-dash optimization (2026-04-08):
--   * Only hide the *trailing* dashes past numDashes. The leading ones
--     will be Show()'d again immediately, so hiding them was wasted work.
--   * Cache r/g/b/a on each dash and skip SetColorTexture when the color
--     hasn't changed. Highlight colors only change on state transition
--     (selection / aggro / hover), not per animation tick.
--   * Cache width/height on each dash and skip SetSize when unchanged.
--     Sizes only change when an edge length changes or a dash rolls past
--     an edge boundary — most ticks they stay constant.
--
-- ClearAllPoints + SetPoint still run every tick because that IS the
-- marching animation (dashes shift position each frame). Show() also
-- still runs because previously-hidden dashes can become visible as the
-- ants march across the edge.

local function DrawHorizontalEdge(ch, border, dashes, isTop, edgeOffset, width, thick, inset, r, g, b, a)
    local numDashes = math.ceil(width / PATTERN_LENGTH) + 2
    -- Hide only the trailing dashes we won't touch this frame
    for i = numDashes + 1, #dashes do dashes[i]:Hide() end
    local startPos = -(edgeOffset % PATTERN_LENGTH)
    for i = 1, numDashes do
        local dashStart = startPos + (i - 1) * PATTERN_LENGTH
        local dashEnd = dashStart + DASH_LENGTH
        local visStart, visEnd = math.max(0, dashStart), math.min(width, dashEnd)
        local dash = dashes[i]
        if visEnd > visStart and dash then
            local dashW = visEnd - visStart
            dash:ClearAllPoints()
            if dash.dfLastW ~= dashW or dash.dfLastH ~= thick then
                dash:SetSize(dashW, thick)
                dash.dfLastW, dash.dfLastH = dashW, thick
            end
            if isTop then
                dash:SetPoint("TOPLEFT", ch, "TOPLEFT", inset + visStart, -inset)
            else
                dash:SetPoint("BOTTOMLEFT", ch, "BOTTOMLEFT", inset + visStart, inset)
            end
            if dash.dfLastR ~= r or dash.dfLastG ~= g or dash.dfLastB ~= b or dash.dfLastA ~= a then
                dash:SetColorTexture(r, g, b, a)
                dash.dfLastR, dash.dfLastG, dash.dfLastB, dash.dfLastA = r, g, b, a
            end
            dash:Show()
        elseif dash then
            dash:Hide()
        end
    end
end

local function DrawVerticalEdge(ch, border, dashes, isRight, edgeOffset, height, thick, inset, r, g, b, a)
    local numDashes = math.ceil(height / PATTERN_LENGTH) + 2
    for i = numDashes + 1, #dashes do dashes[i]:Hide() end
    local startPos = -(edgeOffset % PATTERN_LENGTH)
    for i = 1, numDashes do
        local dashStart = startPos + (i - 1) * PATTERN_LENGTH
        local dashEnd = dashStart + DASH_LENGTH
        local visStart, visEnd = math.max(0, dashStart), math.min(height, dashEnd)
        local dash = dashes[i]
        if visEnd > visStart and dash then
            local dashH = visEnd - visStart
            dash:ClearAllPoints()
            if dash.dfLastW ~= thick or dash.dfLastH ~= dashH then
                dash:SetSize(thick, dashH)
                dash.dfLastW, dash.dfLastH = thick, dashH
            end
            if isRight then
                dash:SetPoint("TOPRIGHT", ch, "TOPRIGHT", -inset, -inset - visStart)
            else
                dash:SetPoint("TOPLEFT", ch, "TOPLEFT", inset, -inset - visStart)
            end
            if dash.dfLastR ~= r or dash.dfLastG ~= g or dash.dfLastB ~= b or dash.dfLastA ~= a then
                dash:SetColorTexture(r, g, b, a)
                dash.dfLastR, dash.dfLastG, dash.dfLastB, dash.dfLastA = r, g, b, a
            end
            dash:Show()
        elseif dash then
            dash:Hide()
        end
    end
end

function DF:UpdateAnimatedBorder(ch, offset)
    local border = ch.animBorder
    if not border then return end
    local thick = ch.animThickness or 2
    local inset = ch.animInset or 0
    local r, g, b, a = ch.animR or 1, ch.animG or 1, ch.animB or 1, ch.animA or 1
    local frameWidth, frameHeight = ch:GetWidth(), ch:GetHeight()
    if frameWidth <= 0 or frameHeight <= 0 then return end
    
    -- Calculate actual drawing area after inset
    local width = frameWidth - (inset * 2)
    local height = frameHeight - (inset * 2)
    if width <= 0 or height <= 0 then return end

    -- Counter-clockwise marching ants:
    -- Bottom: moves left, Left: moves up, Top: moves right, Right: moves down
    DrawHorizontalEdge(ch, border, border.bottomDashes, false, offset, width, thick, inset, r, g, b, a)
    DrawVerticalEdge(ch, border, border.leftDashes, false, width + offset, height, thick, inset, r, g, b, a)
    DrawHorizontalEdge(ch, border, border.topDashes, true, width + height - offset, width, thick, inset, r, g, b, a)
    DrawVerticalEdge(ch, border, border.rightDashes, true, (2 * width) + height - offset, height, thick, inset, r, g, b, a)
end

local function HideAnimatedBorder(ch)
    if not ch.animBorder then return end
    for _, dashes in pairs(ch.animBorder) do
        for _, dash in ipairs(dashes) do dash:Hide() end
    end
end

-- ============================================================
-- HIGHLIGHT FRAME CREATION
-- ============================================================

local function GetOrCreateHighlight(frame, highlightType)
    local key = "df" .. highlightType .. "Highlight"
    if frame[key] then 
        -- Update points on existing frame to ensure proper positioning
        local ch = frame[key]
        ch:ClearAllPoints()
        ch:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        ch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        return ch
    end
    
    -- Parent to UIParent to avoid any clipping from ancestors
    local ch = CreateFrame("Frame", nil, UIParent)
    ch:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    ch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    ch:SetFrameStrata(frame:GetFrameStrata())
    -- Frame levels: Aggro = +9, Hover = +10, Selection = +11
    local levelOffset = 9
    if highlightType == "Hover" then levelOffset = 10
    elseif highlightType == "Selection" then levelOffset = 11 end
    ch:SetFrameLevel(frame:GetFrameLevel() + levelOffset)
    ch:Hide()
    
    -- Track the owner frame so we can hide when owner hides
    ch.ownerFrame = frame
    
    -- Hook owner's OnHide to hide highlight when owner hides
    if not frame.dfHighlightHooked then
        frame:HookScript("OnHide", function(self)
            if self.dfSelectionHighlight then self.dfSelectionHighlight:Hide() end
            if self.dfHoverHighlight then self.dfHoverHighlight:Hide() end
            if self.dfAggroHighlight then self.dfAggroHighlight:Hide() end
        end)
        frame.dfHighlightHooked = true
    end
    
    -- Create basic border textures
    ch.topLine = ch:CreateTexture(nil, "OVERLAY")
    ch.bottomLine = ch:CreateTexture(nil, "OVERLAY")
    ch.leftLine = ch:CreateTexture(nil, "OVERLAY")
    ch.rightLine = ch:CreateTexture(nil, "OVERLAY")
    
    frame[key] = ch
    return ch
end

local function HideCornerTextures(ch)
    if ch.topRight then ch.topRight:Hide() end
    if ch.bottomLeft then ch.bottomLeft:Hide() end
    if ch.rightTop then ch.rightTop:Hide() end
    if ch.rightBottom then ch.rightBottom:Hide() end
    if ch.bottomRight then ch.bottomRight:Hide() end
    if ch.leftBottom then ch.leftBottom:Hide() end
end

local function HideGlowLayers(ch)
    if ch.glowLayers then
        for _, layer in ipairs(ch.glowLayers) do
            layer:Hide()
        end
    end
end

-- ============================================================
-- APPLY HIGHLIGHT STYLE
-- ============================================================

local function ApplyHighlightStyle(ch, mode, thickness, inset, r, g, b, alpha, db)
    if not ch then return end
    
    local top, bottom, left, right = ch.topLine, ch.bottomLine, ch.leftLine, ch.rightLine
    
    -- Hide all styles first
    top:Hide() bottom:Hide() left:Hide() right:Hide()
    HideAnimatedBorder(ch)
    HideCornerTextures(ch)
    HideGlowLayers(ch)
    SelectionAnimator_Remove(ch)
    
    -- Snap thickness to whole screen pixels so every +1 step is visible
    local scale = ch:GetEffectiveScale()
    local minThickness = 1 / scale
    local px = thickness * scale              -- desired thickness in pixels
    px = math.max(1, math.ceil(px - 0.01))    -- round up (with tiny epsilon for exact integers)
    thickness = px / scale
    
    if mode == "NONE" then
        ch:Hide()
        return
    elseif mode == "SOLID" then
        top:SetColorTexture(r, g, b, alpha)
        bottom:SetColorTexture(r, g, b, alpha)
        left:SetColorTexture(r, g, b, alpha)
        right:SetColorTexture(r, g, b, alpha)
        
        local pixelThickness = thickness  -- Already snapped above
        
        -- Top and bottom span full width
        top:ClearAllPoints()
        top:SetPoint("TOPLEFT", ch, "TOPLEFT", inset, -inset)
        top:SetPoint("TOPRIGHT", ch, "TOPRIGHT", -inset, -inset)
        top:SetHeight(pixelThickness)
        
        bottom:ClearAllPoints()
        bottom:SetPoint("BOTTOMLEFT", ch, "BOTTOMLEFT", inset, inset)
        bottom:SetPoint("BOTTOMRIGHT", ch, "BOTTOMRIGHT", -inset, inset)
        bottom:SetHeight(pixelThickness)
        
        -- Left and right span full height (overlap with top/bottom at corners)
        left:ClearAllPoints()
        left:SetPoint("TOPLEFT", ch, "TOPLEFT", inset, -inset)
        left:SetPoint("BOTTOMLEFT", ch, "BOTTOMLEFT", inset, inset)
        left:SetWidth(pixelThickness)
        
        right:ClearAllPoints()
        right:SetPoint("TOPRIGHT", ch, "TOPRIGHT", -inset, -inset)
        right:SetPoint("BOTTOMRIGHT", ch, "BOTTOMRIGHT", -inset, inset)
        right:SetWidth(pixelThickness)
        
        top:Show() bottom:Show() left:Show() right:Show()
        
    elseif mode == "ANIMATED" or mode == "DASHED" then
        InitAnimatedBorder(ch)
        ch.animThickness = thickness
        ch.animInset = inset
        ch.animR, ch.animG, ch.animB, ch.animA = r, g, b, alpha
        
        if mode == "ANIMATED" then
            SelectionAnimator_Add(ch)
            -- Draw immediately so dashes are visible this frame.
            -- Without this, HideAnimatedBorder (called above) leaves a
            -- one-frame gap until the next OnUpdate tick redraws them.
            local offset = (SelectionAnimator.elapsed * ANIMATION_SPEED) % PATTERN_LENGTH
            DF:UpdateAnimatedBorder(ch, offset)
        else
            DF:UpdateAnimatedBorder(ch, 0)
        end
        
    elseif mode == "GLOW" then
        -- Create glow layers if needed
        if not ch.glowLayers then
            ch.glowLayers = {}
            for i = 1, 4 do
                local layer = CreateFrame("Frame", nil, ch, "BackdropTemplate")
                layer:SetFrameLevel(ch:GetFrameLevel())
                ch.glowLayers[i] = layer
            end
        end
        
        -- Each layer is slightly larger and more transparent
        local baseSize = thickness
        for i, layer in ipairs(ch.glowLayers) do
            local offset = (i - 1) * 2 + inset
            local layerAlpha = alpha * (1.1 - (i * 0.25))
            
            layer:ClearAllPoints()
            layer:SetPoint("TOPLEFT", ch, "TOPLEFT", -offset, offset)
            layer:SetPoint("BOTTOMRIGHT", ch, "BOTTOMRIGHT", offset, -offset)
            layer:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = baseSize,
            })
            layer:SetBackdropBorderColor(r, g, b, math.max(0, layerAlpha))
            layer:Show()
        end
        
    elseif mode == "CORNERS" then
        local cornerLen = math.min(12, ch:GetWidth() * 0.2, ch:GetHeight() * 0.2)
        
        -- Apply pixel-perfect to corner length
        if db and db.pixelPerfect then
            cornerLen = DF:PixelPerfect(cornerLen)
        end
        
        top:SetColorTexture(r, g, b, alpha)
        left:SetColorTexture(r, g, b, alpha)
        
        top:ClearAllPoints()
        top:SetPoint("TOPLEFT", ch, "TOPLEFT", inset, -inset)
        top:SetSize(cornerLen, thickness)
        
        left:ClearAllPoints()
        left:SetPoint("TOPLEFT", ch, "TOPLEFT", inset, -inset)
        left:SetSize(thickness, cornerLen)
        
        -- Create additional corner textures if needed
        if not ch.topRight then
            ch.topRight = ch:CreateTexture(nil, "OVERLAY")
            ch.bottomLeft = ch:CreateTexture(nil, "OVERLAY")
            ch.rightTop = ch:CreateTexture(nil, "OVERLAY")
            ch.rightBottom = ch:CreateTexture(nil, "OVERLAY")
            ch.bottomRight = ch:CreateTexture(nil, "OVERLAY")
            ch.leftBottom = ch:CreateTexture(nil, "OVERLAY")
        end
        
        for _, tex in pairs({ch.topRight, ch.rightTop, ch.bottomLeft, ch.leftBottom, ch.bottomRight, ch.rightBottom}) do
            tex:ClearAllPoints()
            tex:SetColorTexture(r, g, b, alpha)
        end
        
        ch.topRight:SetPoint("TOPRIGHT", ch, "TOPRIGHT", -inset, -inset)
        ch.topRight:SetSize(cornerLen, thickness)
        ch.topRight:Show()
        
        ch.rightTop:SetPoint("TOPRIGHT", ch, "TOPRIGHT", -inset, -inset)
        ch.rightTop:SetSize(thickness, cornerLen)
        ch.rightTop:Show()
        
        ch.bottomLeft:SetPoint("BOTTOMLEFT", ch, "BOTTOMLEFT", inset, inset)
        ch.bottomLeft:SetSize(cornerLen, thickness)
        ch.bottomLeft:Show()
        
        ch.leftBottom:SetPoint("BOTTOMLEFT", ch, "BOTTOMLEFT", inset, inset)
        ch.leftBottom:SetSize(thickness, cornerLen)
        ch.leftBottom:Show()
        
        ch.bottomRight:SetPoint("BOTTOMRIGHT", ch, "BOTTOMRIGHT", -inset, inset)
        ch.bottomRight:SetSize(cornerLen, thickness)
        ch.bottomRight:Show()
        
        ch.rightBottom:SetPoint("BOTTOMRIGHT", ch, "BOTTOMRIGHT", -inset, inset)
        ch.rightBottom:SetSize(thickness, cornerLen)
        ch.rightBottom:Show()
        
        top:Show()
        left:Show()
    end
    
    ch:Show()
end

-- Expose for reuse by the Aura Designer border indicator
DF.ApplyHighlightStyle = ApplyHighlightStyle

-- ============================================================
-- UPDATE HIGHLIGHT STYLE COLOR (lightweight recolor)
-- ============================================================
--
-- Changes the color/alpha of a highlight without touching geometry.
-- Used by the Aura Designer expiring ticker (~3 Hz) so it can animate
-- a color curve as an aura approaches expiration without calling the
-- full ApplyHighlightStyle each tick.
--
-- ApplyHighlightStyle is expensive because it tears everything down:
-- hides all edge textures, hides every dash in the animated border
-- (80 Hide ops), removes the frame from the shared animator, and then
-- rebuilds whichever style was requested — even if the only thing that
-- changed was the color. For an animated border with expiring enabled,
-- that tear-down happens 3 times per second per frame on top of the
-- 30 Hz animation, which is pure waste.
--
-- This helper matches each style exactly and only calls the subset of
-- APIs needed to change colors:
--
--   NONE:     no-op
--   SOLID:    4x SetColorTexture on the edge lines
--   GLOW:     4x SetBackdropBorderColor on the glow layers (same per-
--             layer alpha falloff as the original style code)
--   CORNERS:  8x SetColorTexture on the corner textures
--   ANIMATED: just mutate ch.animR/G/B/A. The next animator tick picks
--             up the new color via the per-dash color cache in
--             DrawHorizontalEdge / DrawVerticalEdge and calls
--             SetColorTexture only on dashes whose cached color differs.
--             Zero work on *this* tick.
--   DASHED:   same as ANIMATED but there's no animator redrawing it,
--             so we call UpdateAnimatedBorder(ch, 0) once to push the
--             new colors to the dashes. Still far cheaper than the
--             full tear-down.
--
-- IMPORTANT: only call this when the style has NOT changed from what
-- was last set via ApplyHighlightStyle. If the style changes, call
-- ApplyHighlightStyle instead — this helper does not create, move,
-- or resize geometry.
local function UpdateHighlightStyleColor(ch, mode, r, g, b, alpha)
    if not ch or mode == "NONE" then return end

    if mode == "SOLID" then
        if ch.topLine    then ch.topLine:SetColorTexture(r, g, b, alpha) end
        if ch.bottomLine then ch.bottomLine:SetColorTexture(r, g, b, alpha) end
        if ch.leftLine   then ch.leftLine:SetColorTexture(r, g, b, alpha) end
        if ch.rightLine  then ch.rightLine:SetColorTexture(r, g, b, alpha) end

    elseif mode == "ANIMATED" then
        -- Animator picks up the new color on its next tick. Zero ops here.
        ch.animR, ch.animG, ch.animB, ch.animA = r, g, b, alpha

    elseif mode == "DASHED" then
        -- No animator; push the new color through via a one-shot redraw.
        ch.animR, ch.animG, ch.animB, ch.animA = r, g, b, alpha
        DF:UpdateAnimatedBorder(ch, 0)

    elseif mode == "GLOW" then
        if ch.glowLayers then
            for i, layer in ipairs(ch.glowLayers) do
                -- Matches the alpha falloff in ApplyHighlightStyle's GLOW branch
                local layerAlpha = alpha * (1.1 - (i * 0.25))
                layer:SetBackdropBorderColor(r, g, b, math.max(0, layerAlpha))
            end
        end

    elseif mode == "CORNERS" then
        if ch.topLine     then ch.topLine:SetColorTexture(r, g, b, alpha) end
        if ch.leftLine    then ch.leftLine:SetColorTexture(r, g, b, alpha) end
        if ch.topRight    then ch.topRight:SetColorTexture(r, g, b, alpha) end
        if ch.rightTop    then ch.rightTop:SetColorTexture(r, g, b, alpha) end
        if ch.bottomLeft  then ch.bottomLeft:SetColorTexture(r, g, b, alpha) end
        if ch.leftBottom  then ch.leftBottom:SetColorTexture(r, g, b, alpha) end
        if ch.bottomRight then ch.bottomRight:SetColorTexture(r, g, b, alpha) end
        if ch.rightBottom then ch.rightBottom:SetColorTexture(r, g, b, alpha) end
    end
end

DF.UpdateHighlightStyleColor = UpdateHighlightStyleColor

-- ============================================================
-- UPDATE HIGHLIGHTS FOR A FRAME
-- ============================================================

function DF:UpdateHighlights(frame, forceSelection, forceAggro)
    if not frame then return end
    
    -- DEBUG: Track what's happening
    local debugHighlights = false  -- Set to true to enable debug output
    if debugHighlights then
        print("|cffFFFF00[DF Highlights Debug]|r UpdateHighlights called")
        print("  frame:", frame:GetName() or "unnamed")
        print("  dfIsTestFrame:", frame.dfIsTestFrame and "true" or "false")
        print("  isRaidFrame:", frame.isRaidFrame and "true" or "false")
        print("  DF.testMode:", DF.testMode and "true" or "false")
        print("  DF.raidTestMode:", DF.raidTestMode and "true" or "false")
    end
    
    -- Skip party frames when in raid (they should be hidden but highlights are parented to UIParent)
    -- But NOT for test frames - test mode controls its own visibility
    if not frame.dfIsTestFrame and not frame.isRaidFrame and not frame.isArenaFrame and IsInRaid() then
        -- Hide any existing highlights on party frames when in raid
        if frame.dfSelectionHighlight then frame.dfSelectionHighlight:Hide() end
        if frame.dfHoverHighlight then frame.dfHoverHighlight:Hide() end
        if frame.dfAggroHighlight then frame.dfAggroHighlight:Hide() end
        return
    end
    
    -- Skip if frame is not visible (e.g., party frames when in raid)
    -- This prevents highlights from showing on hidden frames since they're parented to UIParent
    -- For test frames, check IsShown() instead since IsVisible() can be unreliable
    local isFrameVisible = frame.dfIsTestFrame and frame:IsShown() or frame:IsVisible()
    if debugHighlights then
        print("  isFrameVisible:", isFrameVisible and "true" or "false")
    end
    if not isFrameVisible then
        -- Hide any existing highlights
        if frame.dfSelectionHighlight then frame.dfSelectionHighlight:Hide() end
        if frame.dfHoverHighlight then frame.dfHoverHighlight:Hide() end
        if frame.dfAggroHighlight then frame.dfAggroHighlight:Hide() end
        return
    end
    
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableHighlights then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    if not db then return end
    
    local unit = frame.unit
    
    -- In test mode, determine highlights based on test settings and frame position
    local inTestMode = DF.testMode or DF.raidTestMode
    if debugHighlights then
        print("  inTestMode:", inTestMode and "true" or "false")
    end
    if inTestMode and forceSelection == nil and forceAggro == nil then
        -- Determine frame index for test mode
        local frameIndex = nil
        
        -- For test frames, check the test frame arrays directly
        if frame.dfIsTestFrame then
            -- Check party test frames (index 0 = player, 1-4 = party members)
            if DF.testPartyFrames then
                for i = 0, 4 do
                    if DF.testPartyFrames[i] == frame then
                        frameIndex = i
                        break
                    end
                end
            end
            
            -- Check raid test frames (1-40)
            if frameIndex == nil and DF.testRaidFrames then
                for i = 1, 40 do
                    if DF.testRaidFrames[i] == frame then
                        frameIndex = i - 1  -- 0-based for consistency (first raid frame = 0)
                        break
                    end
                end
            end
        else
            -- For live frames during test mode (shouldn't happen but just in case)
            -- Check party frames (index 0 = player, 1-4 = party members)
            DF:IteratePartyFrames(function(f, idx, u)
                if f == frame then
                    frameIndex = idx
                    return true  -- Stop iteration
                end
            end)
            
            -- Check raid frames (index 0-based for consistency)
            if frameIndex == nil then
                DF:IterateRaidFrames(function(f, idx, u)
                    if f == frame then
                        frameIndex = idx - 1  -- 0-based for consistency (first raid frame = 0)
                        return true  -- Stop iteration
                    end
                end)
            end
        end
        
        if debugHighlights then
            print("  frameIndex:", frameIndex or "nil")
            print("  db.testShowSelection:", db.testShowSelection and "true" or "false")
            print("  db.testShowAggro:", db.testShowAggro and "true" or "false")
        end
        
        -- Apply test mode highlights based on settings
        if frameIndex ~= nil then
            if db.testShowSelection then
                forceSelection = (frameIndex == 0)  -- First frame gets selection
            end
            if db.testShowAggro then
                forceAggro = (frameIndex == 1)  -- Second frame gets aggro
            end
        end
        
        if debugHighlights then
            print("  forceSelection:", forceSelection == true and "true" or (forceSelection == false and "false" or "nil"))
            print("  forceAggro:", forceAggro == true and "true" or (forceAggro == false and "false" or "nil"))
        end
    end
    
    -- Check if unit is selected (targeted) - can be overridden for test mode
    local isSelected = forceSelection
    if isSelected == nil then
        isSelected = unit and UnitIsUnit(unit, "target")
    end
    
    -- Check aggro status via threat API - can be overridden for test mode
    local isAggro = forceAggro
    local status = 3  -- Default to red (tanking) for test mode
    if isAggro == nil then
        status = unit and UnitThreatSituation(unit) or 0
        -- If "Only Show When Tanking" is enabled, only show for status 3 (actually tanking)
        if db.aggroOnlyTanking then
            isAggro = status and status == 3
        else
            isAggro = status and status > 0
        end
    end
    
    -- Get modes
    local selectionMode = db.selectionHighlightMode or "SOLID"
    local aggroMode = db.aggroHighlightMode or "SOLID"
    
    if debugHighlights then
        print("  selectionMode:", selectionMode)
        print("  aggroMode:", aggroMode)
        print("  isSelected:", isSelected and "true" or "false")
        print("  isAggro:", isAggro and "true" or "false")
    end
    
    -- Selection Highlight
    local selectionHighlight = GetOrCreateHighlight(frame, "Selection")
    local wantSelection = isSelected and selectionMode ~= "NONE"
    
    if debugHighlights then
        print("  wantSelection:", wantSelection and "true" or "false")
    end
    
    if wantSelection then
        local c = db.selectionHighlightColor or {r = 1, g = 1, b = 1}
        local selThickness = db.selectionHighlightThickness or 2
        local selInset = db.selectionHighlightInset or 0
        
        -- Apply pixel-perfect adjustments (use PixelPerfectThickness to ensure min 1px)
        if db.pixelPerfect then
            selThickness = DF:PixelPerfectThickness(selThickness)
            selInset = DF:PixelPerfect(selInset)
        end
        
        ApplyHighlightStyle(
            selectionHighlight,
            selectionMode,
            selThickness,
            selInset,
            c.r, c.g, c.b,
            db.selectionHighlightAlpha or 1,
            db
        )
    else
        HideAnimatedBorder(selectionHighlight)
        HideGlowLayers(selectionHighlight)
        selectionHighlight:Hide()
        SelectionAnimator_Remove(selectionHighlight)
    end
    
    -- Hover Highlight
    local hoverHighlight = GetOrCreateHighlight(frame, "Hover")
    local hoverMode = db.hoverHighlightMode or "NONE"
    local isHovered = frame.dfIsHovered
    local wantHover = isHovered and hoverMode ~= "NONE"
    
    if wantHover then
        local c = db.hoverHighlightColor or {r = 1, g = 1, b = 1}
        local hoverThickness = db.hoverHighlightThickness or 2
        local hoverInset = db.hoverHighlightInset or 0
        
        -- Apply pixel-perfect adjustments
        if db.pixelPerfect then
            hoverThickness = DF:PixelPerfectThickness(hoverThickness)
            hoverInset = DF:PixelPerfect(hoverInset)
        end
        
        ApplyHighlightStyle(
            hoverHighlight,
            hoverMode,
            hoverThickness,
            hoverInset,
            c.r, c.g, c.b,
            db.hoverHighlightAlpha or 0.8,
            db
        )
    else
        HideAnimatedBorder(hoverHighlight)
        HideGlowLayers(hoverHighlight)
        hoverHighlight:Hide()
        SelectionAnimator_Remove(hoverHighlight)
    end
    
    -- Aggro Highlight
    local aggroHighlight = GetOrCreateHighlight(frame, "Aggro")
    local wantAggro = isAggro and aggroMode ~= "NONE"
    
    -- Get aggro color based on threat level
    local aggroR, aggroG, aggroB = 1, 0, 0  -- Default to red
    if wantAggro then
        if db.aggroUseCustomColors then
            -- Use custom colors based on threat status
            if status == 1 then
                local c = db.aggroColorHighThreat or {r = 1, g = 1, b = 0.47}
                aggroR, aggroG, aggroB = c.r, c.g, c.b
            elseif status == 2 then
                local c = db.aggroColorHighestThreat or {r = 1, g = 0.6, b = 0}
                aggroR, aggroG, aggroB = c.r, c.g, c.b
            else  -- status == 3 (tanking)
                local c = db.aggroColorTanking or {r = 1, g = 0, b = 0}
                aggroR, aggroG, aggroB = c.r, c.g, c.b
            end
        elseif GetThreatStatusColor then
            -- GetThreatStatusColor returns different colors based on threat level:
            -- Status 1: Yellow (has threat, not highest)
            -- Status 2: Orange (highest threat, not tanking)
            -- Status 3: Red (tanking/has aggro)
            aggroR, aggroG, aggroB = GetThreatStatusColor(status)
            -- Safety check in case API returns nil
            aggroR = aggroR or 1
            aggroG = aggroG or 0
            aggroB = aggroB or 0
        end
    end
    
    -- Set flags for health color override mode
    local useHealthColor = aggroMode == "HEALTH_COLOR"
    frame.dfAggroActive = wantAggro and useHealthColor
    if frame.dfAggroActive then
        frame.dfAggroColor = {r = aggroR, g = aggroG, b = aggroB}
        -- Immediately update health color (both bar and texture for gradient mode)
        -- Skip if Aura Designer health bar color is active — AD owns the bar color
        local adOwnsColor = frame.dfAD and frame.dfAD.healthbar
        if frame.healthBar and not adOwnsColor then
            frame.healthBar:SetStatusBarColor(aggroR, aggroG, aggroB)
            local tex = frame.healthBar:GetStatusBarTexture()
            if tex then
                tex:SetVertexColor(aggroR, aggroG, aggroB)
            end
        end
    else
        frame.dfAggroColor = nil
        -- If aggro just cleared, refresh health colors (but not in test mode - test frame handles it)
        if frame.dfAggroColorWasActive and not inTestMode then
            if DF.ApplyHealthColors then
                DF:ApplyHealthColors(frame)
            end
        end
    end
    frame.dfAggroColorWasActive = frame.dfAggroActive
    
    -- Show border highlight only if not using health color mode
    local wantAggroBorder = wantAggro and not useHealthColor
    
    if wantAggroBorder then
        local aggroThickness = db.aggroHighlightThickness or 2
        local aggroInset = db.aggroHighlightInset or 0
        
        -- Apply pixel-perfect adjustments (use PixelPerfectThickness to ensure min 1px)
        if db.pixelPerfect then
            aggroThickness = DF:PixelPerfectThickness(aggroThickness)
            aggroInset = DF:PixelPerfect(aggroInset)
        end
        
        ApplyHighlightStyle(
            aggroHighlight,
            aggroMode,
            aggroThickness,
            aggroInset,
            aggroR, aggroG, aggroB,
            db.aggroHighlightAlpha or 1,
            db
        )
    else
        HideAnimatedBorder(aggroHighlight)
        HideGlowLayers(aggroHighlight)
        aggroHighlight:Hide()
        SelectionAnimator_Remove(aggroHighlight)
    end
end

-- ============================================================
-- HIGHLIGHT UPDATE SYSTEM
-- ============================================================

-- Helper to find frame by unit
local function FindFrameByUnit(unit)
    if not unit then return nil end
    
    -- Fast path: use unitFrameMap
    if DF.unitFrameMap and DF.unitFrameMap[unit] then
        return DF.unitFrameMap[unit]
    end
    
    local foundFrame = nil
    
    -- Arena: use arena frames (IsInRaid()=true in arena, so must check first)
    if DF.IsInArena and DF:IsInArena() then
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(function(frame, index, frameUnit)
                if frame and frame.unit == unit then
                    foundFrame = frame
                    return true
                end
            end)
        end
        return foundFrame
    end
    
    -- Check party frames (includes player) - skip when in raid
    if not IsInRaid() then
        DF:IteratePartyFrames(function(frame, index, frameUnit)
            if frame and frame.unit == unit then
                foundFrame = frame
                return true  -- Stop iteration
            end
        end)
        
        if foundFrame then return foundFrame end
    end
    
    -- Check raid frames
    DF:IterateRaidFrames(function(frame, index, frameUnit)
        if frame and frame.unit == unit then
            foundFrame = frame
            return true  -- Stop iteration
        end
    end)
    
    return foundFrame
end

-- Update all highlights (used for target changes and safety refreshes)
local function UpdateAllHighlights()
    -- Arena: use arena frames (IsInRaid()=true in arena, so must check first)
    if DF.IsInArena and DF:IsInArena() then
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(function(frame, index, unit)
                if frame and frame:IsShown() then
                    DF:UpdateHighlights(frame)
                end
            end)
        end
    elseif not IsInRaid() then
        -- Update party frames (includes player)
        DF:IteratePartyFrames(function(frame, index, unit)
            if frame and frame:IsShown() then
                DF:UpdateHighlights(frame)
            end
        end)
    end
    
    -- Update raid frames (skip in arena - arena frames handled above)
    if not (DF.IsInArena and DF:IsInArena()) then
        DF:IterateRaidFrames(function(frame, index, unit)
            if frame and frame:IsShown() then
                DF:UpdateHighlights(frame)
            end
        end)
    end
    
    -- Update pinned frame children (they share units with main frames)
    if DF.PinnedFrames and DF.PinnedFrames.initialized then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header and header:IsShown() then
                local maxChildren = IsInRaid() and 40 or 5
                for i = 1, maxChildren do
                    local child = header:GetAttribute("child" .. i)
                    if child and child:IsShown() and child.unit then
                        DF:UpdateHighlights(child)
                    end
                end
            end
        end
    end
end

-- Expose for external use
DF.UpdateAllHighlights = UpdateAllHighlights

-- ============================================================
-- EVENT-DRIVEN HIGHLIGHTS (Replaces timer-based updates)
-- ============================================================
-- PERFORMANCE: Converted from 0.1s timer (~450 calls/sec) to event-driven.
-- Events used:
--   PLAYER_TARGET_CHANGED - Update all frames (old target loses selection, new gains)
--   UNIT_THREAT_SITUATION_UPDATE - Update specific unit's frame for aggro changes
--   PLAYER_REGEN_ENABLED - Safety refresh when leaving combat (clears any stuck highlights)
--   GROUP_ROSTER_UPDATE - Safety refresh when group composition changes
--
-- Converted 2025-01-20. See PERFORMANCE_OPTIMIZATIONS.md for details.
-- ============================================================

local highlightEventFrame = CreateFrame("Frame")
highlightEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
highlightEventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
highlightEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
highlightEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

highlightEventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Safety check - wait for initialization
    if not DF.partyHeader then return end
    
    if event == "PLAYER_TARGET_CHANGED" then
        -- Target changed - need to update ALL frames
        -- (old target loses selection highlight, new target gains it)
        UpdateAllHighlights()
        
    elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
        -- Threat changed on specific unit - update that frame
        local unit = ...
        local frame = FindFrameByUnit(unit)
        if frame and frame:IsShown() then
            DF:UpdateHighlights(frame)
        end
        -- Also update any pinned frame children showing this unit
        if unit and DF.PinnedFrames and DF.PinnedFrames.initialized then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header and header:IsShown() then
                    local maxChildren = IsInRaid() and 40 or 5
                    for i = 1, maxChildren do
                        local child = header:GetAttribute("child" .. i)
                        if child and child:IsShown() and child.unit == unit then
                            DF:UpdateHighlights(child)
                        end
                    end
                end
            end
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
        -- Safety refresh - clear any stuck highlights after combat/login
        -- Small delay to let other systems settle
        C_Timer.After(0.1, UpdateAllHighlights)
    end
end)
