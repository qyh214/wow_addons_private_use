local addonName, DF = ...

-- ============================================================
-- SECURE SORTING SYSTEM - Phase 0: Foundation
-- ============================================================
-- This module implements secure code for sorting and positioning
-- frames during combat. WoW restricts most frame operations in
-- combat, but code running in a "secure" environment can still
-- call SetPoint, ClearAllPoints, Show, Hide on secure frames.
--
-- KEY CONCEPTS:
-- 1. SecureHandlerBaseTemplate - A frame template that can execute
--    Lua code in a restricted but "secure" environment
-- 2. Secure Environment - A sandboxed Lua environment where only
--    certain functions are available, but frame manipulation is allowed
-- 3. Snippets - Strings of Lua code that run in the secure environment
-- 4. Attributes - The bridge for passing data between secure/insecure code
--
-- LIMITATIONS OF SECURE CODE:
-- - No print() or other output functions
-- - No access to most WoW API functions
-- - No access to addon tables or globals (except what you pass in)
-- - Cannot call methods defined in insecure code
-- - Can only use: basic Lua (math, string, table basics), frame methods,
--   GetAttribute, SetAttribute, and a few secure-specific functions
--
-- HOW WE DEBUG:
-- - Use CallMethod() to call insecure functions for debug output
-- - Store debug info in attributes and read them from insecure code
-- - Test snippets carefully before integrating
--
-- NAMING CONVENTIONS (DandersFrames-specific):
-- Functions:
--   SetSecurePath    - Bridge data from insecure → secure environment
--   ComputeSortWeight - Calculate sort priority for a unit
--   ReorderByWeight   - Apply sorting to frame list
--   SwapFrameAnchors  - Exchange two frames' positions
--   RefreshSortData   - Update role/class data for sorting
-- Snippets:
--   execute_sort      - Main sorting execution
--   calc_priority     - Unit comparison logic
--   apply_positions   - Set frame anchors after sort
-- ============================================================

-- ============================================================
-- MODULE STATE
-- ============================================================

DF.SecureSort = DF.SecureSort or {}
local SecureSort = DF.SecureSort

-- Debug flag - enable verbose output
SecureSort.debug = false

-- Track initialization state
SecureSort.initialized = false
SecureSort.handlerReady = false
SecureSort.framesRegistered = false
SecureSort.raidFramesRegistered = false

-- ============================================================
-- SPECIALIZATION TO ROLE MAPPING
-- ============================================================
-- Maps spec IDs to detailed roles for melee/ranged DPS distinction
-- Roles: 1=Tank, 2=Melee DPS, 3=Healer, 4=Ranged DPS
-- This matches SortUnitFrames' approach

local SPEC_ROLE = {
    -- TANKS (role 1)
    [250] = 1, -- Death Knight Blood 
    [581] = 1, -- Demon Hunter Vengeance
    [73]  = 1, -- Warrior Protection
    [104] = 1, -- Druid Guardian
    [66]  = 1, -- Paladin Protection
    [268] = 1, -- Monk Brewmaster
    
    -- MELEE DPS (role 2)
    [259] = 2, -- Rogue Assassination
    [260] = 2, -- Rogue Outlaw
    [261] = 2, -- Rogue Subtlety
    [103] = 2, -- Druid Feral
    [269] = 2, -- Monk Windwalker
    [251] = 2, -- Death Knight Frost
    [252] = 2, -- Death Knight Unholy
    [577] = 2, -- Demon Hunter Havoc 
    [71]  = 2, -- Warrior Arms
    [72]  = 2, -- Warrior Fury
    [70]  = 2, -- Paladin Retribution
    [255] = 2, -- Hunter Survival
    [263] = 2, -- Shaman Enhancement
    
    -- HEALERS (role 3)
    [65]   = 3, -- Paladin Holy
    [105]  = 3, -- Druid Restoration
    [270]  = 3, -- Monk Mistweaver 
    [257]  = 3, -- Priest Holy
    [256]  = 3, -- Priest Discipline
    [264]  = 3, -- Shaman Restoration
    [1468] = 3, -- Evoker Preservation
    
    -- RANGED DPS (role 4)
    [102]  = 4, -- Druid Balance
    [253]  = 4, -- Hunter Beast Mastery
    [254]  = 4, -- Hunter Marksmanship
    [62]   = 4, -- Mage Arcane
    [63]   = 4, -- Mage Fire
    [64]   = 4, -- Mage Frost
    [258]  = 4, -- Priest Shadow
    [262]  = 4, -- Shaman Elemental
    [265]  = 4, -- Warlock Affliction
    [266]  = 4, -- Warlock Demonology
    [267]  = 4, -- Warlock Destruction
    [1467] = 4, -- Evoker Devastation
    [1473] = 4, -- Evoker Augmentation
}

-- Cache for spec data by player name (persists across sorts)
SecureSort.specCache = {}

-- Queue for players who need inspection
SecureSort.inspectQueue = {}
SecureSort.inspectInProgress = false

-- ============================================================
-- DEBUG UTILITIES
-- ============================================================

local function DebugPrint(...)
    if SecureSort.debug then
        print("|cff00ffff[DF SecureSort]|r", ...)
    end
end

-- This function can be called FROM secure code via CallMethod
-- to output debug information
local function SecureDebugCallback(self, msg)
    if SecureSort.debug then
        print("|cffff00ff[DF Secure]|r", msg or "nil")
    end
end

-- ============================================================
-- SECURE HANDLER CREATION
-- ============================================================

function SecureSort:CreateHandler()
    if self.handler then
        DebugPrint("Handler already exists")
        return self.handler
    end
    
    DebugPrint("Creating secure handler...")
    
    -- Create the main secure handler frame
    -- SecureHandlerBaseTemplate gives us the ability to execute secure code
    local handler = CreateFrame("Button", "DFSecureSortHandler", UIParent, "SecureHandlerBaseTemplate")
    
    -- Store reference
    self.handler = handler
    
    -- Attach debug callback so secure code can output messages
    handler.DebugPrint = SecureDebugCallback

    -- Fired from the sort snippets via CallMethod after sorting+positioning completes.
    -- Routes to the external API CallbackHandler registry (OnFramesSorted event).
    handler.NotifySortComplete = function(_, sortType)
        if DF and DF.FireAPICallback then
            DF:FireAPICallback("OnFramesSorted", sortType)
        end
    end
    
    -- Initialize the secure environment with our base tables
    -- This code runs ONCE to set up the environment
    handler:Execute([[
        -- ============================================================
        -- SECURE ENVIRONMENT INITIALIZATION
        -- ============================================================
        -- These tables exist only in the secure environment
        -- They persist across snippet executions
        
        -- Frame storage
        partyFrames = newtable()      -- [0]=player, [1-4]=party members
        raidFrames = newtable()       -- [1-40]=raid members
        petFrames = newtable()        -- Pet frame references
        containers = newtable()       -- Container frames (partyContainer, raidContainer, etc.)
        
        -- Unit info storage (populated by role/class detection)
        unit2roles = newtable()       -- unit -> role priority number
        unit2class = newtable()       -- unit -> class priority number
        
        -- Working tables for sorting
        wtable = newtable()           -- Working table for sorted frames
        tempTable = newtable()        -- Temporary storage
        
        -- Configuration (will be populated from insecure code)
        sortConfig = newtable()       -- Sorting settings
        layoutConfig = newtable()     -- Layout/position settings
        
        -- State tracking
        isInitialized = false
        frameCount = 0
        lastUpdateTime = 0
        
        -- Debug flag (synced from SecureSort.debug)
        debugEnabled = ]] .. tostring(SecureSort.debug) .. [[
    ]])
    
    DebugPrint("Secure environment initialized (debug=" .. tostring(SecureSort.debug) .. ")")
    
    -- ============================================================
    -- STATE DRIVER FOR AUTOMATIC TRIGGERING
    -- ============================================================
    -- RegisterStateDriver allows WoW to evaluate conditions and set
    -- attributes automatically - even during combat! This is the KEY
    -- to in-combat execution.
    
    -- Use OnAttributeChanged to respond to state changes
    SecureHandlerWrapScript(handler, "OnAttributeChanged", handler, [[
        if name == "state-groupstate" then
            -- Group state changed (raid/party/solo)
            -- This fires when group composition changes, even in combat!
            if debugEnabled then
                self:CallMethod("DebugPrint", "Group state changed to: " .. tostring(value))
            end
            -- In the future, this is where sorting would be triggered
        end
    ]])
    
    -- Register state driver - this auto-updates "state-groupstate" attribute
    RegisterStateDriver(handler, "groupstate", "[group:raid] raid; [group:party] party; solo")
    
    DebugPrint("State driver registered")
    
    -- ============================================================
    -- VISIBLE TEST BUTTONS (for in-combat testing)
    -- ============================================================
    -- These buttons can be clicked during combat to test secure code.
    -- Click them or use: /click DFSecureSwapButton
    -- 
    -- IMPORTANT: The swap code is INLINE in the button's onclick handler
    -- because we can't dynamically change what code runs during combat.
    -- The frame refs are set during RegisterPartyFrames (before combat).
    
    local swapButton = CreateFrame("Button", "DFSecureSwapButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    swapButton:SetSize(120, 30)
    swapButton:SetPoint("TOP", UIParent, "TOP", 0, -100)
    swapButton:SetText("Swap Frames")
    swapButton:Hide() -- Hidden by default, show with /dfsecure showbutton
    
    -- Store reference
    self.swapButton = swapButton
    
    -- The swap code is inline here - it swaps frames 0 and 1
    -- Frame refs are set later by RegisterPartyFrames
    swapButton:SetAttribute("_onclick", [[
        -- Get frame refs (set by RegisterPartyFrames)
        local f0 = self:GetFrameRef("frame0")
        local f1 = self:GetFrameRef("frame1")
        
        if not f0 or not f1 then
            -- Frames not registered yet
            return
        end
        
        -- Read current positions
        local p0, rt0, rp0, x0, y0 = f0:GetPoint(1)
        local p1, rt1, rp1, x1, y1 = f1:GetPoint(1)
        
        if not p0 or not p1 then
            return
        end
        
        -- Swap them!
        f0:ClearAllPoints()
        f0:SetPoint(p1, rt1, rp1, x1, y1)
        
        f1:ClearAllPoints()
        f1:SetPoint(p0, rt0, rp0, x0, y0)
    ]])
    
    DebugPrint("Visible swap button created (hidden by default)")
    
    -- ============================================================
    -- SWAP BACK BUTTON (same logic, just swaps again)
    -- ============================================================
    local swapBackButton = CreateFrame("Button", "DFSecureSwapBackButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    swapBackButton:SetSize(120, 30)
    swapBackButton:SetPoint("TOP", swapButton, "BOTTOM", 0, -5)
    swapBackButton:SetText("Swap Back")
    swapBackButton:Hide()
    
    self.swapBackButton = swapBackButton
    
    -- Same swap code - clicking again swaps them back
    swapBackButton:SetAttribute("_onclick", [[
        local f0 = self:GetFrameRef("frame0")
        local f1 = self:GetFrameRef("frame1")
        
        if not f0 or not f1 then return end
        
        local p0, rt0, rp0, x0, y0 = f0:GetPoint(1)
        local p1, rt1, rp1, x1, y1 = f1:GetPoint(1)
        
        if not p0 or not p1 then return end
        
        f0:ClearAllPoints()
        f0:SetPoint(p1, rt1, rp1, x1, y1)
        
        f1:ClearAllPoints()
        f1:SetPoint(p0, rt0, rp0, x0, y0)
    ]])
    
    DebugPrint("Swap back button created")
    
    -- ============================================================
    -- PHASE 2.5: RESET BUTTON (positions all frames to natural order)
    -- ============================================================
    local resetButton = CreateFrame("Button", "DFSecureResetButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    resetButton:SetSize(120, 30)
    resetButton:SetPoint("TOP", swapBackButton, "BOTTOM", 0, -15)
    resetButton:SetText("Reset (0-4)")
    resetButton:Hide()
    
    self.resetButton = resetButton
    
    -- Reset code - positions frames 0,1,2,3,4 to slots 0,1,2,3,4
    -- Layout config is read from attributes (set by UpdateLayoutParamsOnButtons)
    resetButton:SetAttribute("_onclick", [[
        -- Get all 5 frames
        local frames = newtable()
        frames[0] = self:GetFrameRef("frame0")
        frames[1] = self:GetFrameRef("frame1")
        frames[2] = self:GetFrameRef("frame2")
        frames[3] = self:GetFrameRef("frame3")
        frames[4] = self:GetFrameRef("frame4")
        
        -- Get container from first frame's anchor
        local container = nil
        if frames[0] then
            local _, relTo = frames[0]:GetPoint(1)
            container = relTo or frames[0]:GetParent()
        end
        if not container then return end
        
        -- Get layout config from attributes
        local frameWidth = self:GetAttribute("layoutWidth") or 80
        local frameHeight = self:GetAttribute("layoutHeight") or 40
        local spacing = self:GetAttribute("layoutSpacing") or 2
        local horizontal = self:GetAttribute("layoutHorizontal")
        local growthAnchor = self:GetAttribute("layoutAnchor") or "START"
        local frameCount = self:GetAttribute("frameCount") or 5
        
        -- Calculate stride
        local stride
        if horizontal then
            stride = frameWidth + spacing
        else
            stride = frameHeight + spacing
        end
        
        -- Determine anchor points
        local anchor, relAnchor
        if horizontal then
            if growthAnchor == "START" then
                anchor = "LEFT"
                relAnchor = "LEFT"
            elseif growthAnchor == "END" then
                anchor = "RIGHT"
                relAnchor = "RIGHT"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        else
            if growthAnchor == "START" then
                anchor = "TOP"
                relAnchor = "TOP"
            elseif growthAnchor == "END" then
                anchor = "BOTTOM"
                relAnchor = "BOTTOM"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        end
        
        -- Position each frame to its natural slot (frame 0 -> slot 0, etc.)
        for i = 0, frameCount - 1 do
            local frame = frames[i]
            if frame then
                local slot = i  -- Natural order: frame index = slot index
                
                -- Calculate offset
                -- For END: slot 0 at far end, slot n-1 at anchor (preserves visual order)
                local offset
                if growthAnchor == "START" then
                    offset = slot * stride
                elseif growthAnchor == "END" then
                    offset = -(frameCount - 1 - slot) * stride
                else
                    offset = (slot - (frameCount - 1) / 2) * stride
                end
                
                -- Calculate x, y
                local x, y
                if horizontal then
                    x = offset
                    y = 0
                else
                    x = 0
                    y = -offset
                end
                
                -- Apply position
                frame:ClearAllPoints()
                frame:SetPoint(anchor, container, relAnchor, x, y)
            end
        end
    ]])
    
    DebugPrint("Reset button created (Phase 2.5)")
    
    -- ============================================================
    -- PHASE 2.5: REVERSE BUTTON (positions all frames in reverse order)
    -- ============================================================
    local reverseButton = CreateFrame("Button", "DFSecureReverseButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    reverseButton:SetSize(120, 30)
    reverseButton:SetPoint("TOP", resetButton, "BOTTOM", 0, -5)
    reverseButton:SetText("Reverse (4-0)")
    reverseButton:Hide()
    
    self.reverseButton = reverseButton
    
    -- Reverse code - positions frames 4,3,2,1,0 to slots 0,1,2,3,4
    reverseButton:SetAttribute("_onclick", [[
        -- Get all 5 frames
        local frames = newtable()
        frames[0] = self:GetFrameRef("frame0")
        frames[1] = self:GetFrameRef("frame1")
        frames[2] = self:GetFrameRef("frame2")
        frames[3] = self:GetFrameRef("frame3")
        frames[4] = self:GetFrameRef("frame4")
        
        -- Get container from first frame's anchor
        local container = nil
        if frames[0] then
            local _, relTo = frames[0]:GetPoint(1)
            container = relTo or frames[0]:GetParent()
        end
        if not container then return end
        
        -- Get layout config from attributes
        local frameWidth = self:GetAttribute("layoutWidth") or 80
        local frameHeight = self:GetAttribute("layoutHeight") or 40
        local spacing = self:GetAttribute("layoutSpacing") or 2
        local horizontal = self:GetAttribute("layoutHorizontal")
        local growthAnchor = self:GetAttribute("layoutAnchor") or "START"
        local frameCount = self:GetAttribute("frameCount") or 5
        
        -- Calculate stride
        local stride
        if horizontal then
            stride = frameWidth + spacing
        else
            stride = frameHeight + spacing
        end
        
        -- Determine anchor points
        local anchor, relAnchor
        if horizontal then
            if growthAnchor == "START" then
                anchor = "LEFT"
                relAnchor = "LEFT"
            elseif growthAnchor == "END" then
                anchor = "RIGHT"
                relAnchor = "RIGHT"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        else
            if growthAnchor == "START" then
                anchor = "TOP"
                relAnchor = "TOP"
            elseif growthAnchor == "END" then
                anchor = "BOTTOM"
                relAnchor = "BOTTOM"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        end
        
        -- Position each frame in REVERSE order (frame 4 -> slot 0, frame 3 -> slot 1, etc.)
        for i = 0, frameCount - 1 do
            local frame = frames[i]
            if frame then
                local slot = (frameCount - 1) - i  -- Reverse: frame 0 -> slot 4, frame 4 -> slot 0
                
                -- Calculate offset
                -- For END: slot 0 at far end, slot n-1 at anchor (preserves visual order)
                local offset
                if growthAnchor == "START" then
                    offset = slot * stride
                elseif growthAnchor == "END" then
                    offset = -(frameCount - 1 - slot) * stride
                else
                    offset = (slot - (frameCount - 1) / 2) * stride
                end
                
                -- Calculate x, y
                local x, y
                if horizontal then
                    x = offset
                    y = 0
                else
                    x = 0
                    y = -offset
                end
                
                -- Apply position
                frame:ClearAllPoints()
                frame:SetPoint(anchor, container, relAnchor, x, y)
            end
        end
    ]])
    
    DebugPrint("Reverse button created (Phase 2.5)")
    
    -- ============================================================
    -- ROLE QUERY HEADER (for roleFilter queries in combat)
    -- ============================================================
    -- Create a SecureGroupHeaderTemplate that tracks the party.
    -- We query roles by setting roleFilter and iterating children.
    -- Based on SortUnitFrames approach.
    
    local roleQueryHeader = CreateFrame("Frame", "DFRoleQueryHeader", UIParent, "SecureGroupHeaderTemplate")
    roleQueryHeader:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10000, 10000)
    roleQueryHeader:SetSize(1, 1)
    roleQueryHeader:SetAlpha(0)
    roleQueryHeader:EnableMouse(false)
    
    -- Configure - use minimal template, track party/raid
    roleQueryHeader:SetAttribute("template", "SecureFrameTemplate")
    roleQueryHeader:SetAttribute("showParty", true)
    roleQueryHeader:SetAttribute("showPlayer", true)
    roleQueryHeader:SetAttribute("showRaid", true)
    roleQueryHeader:SetAttribute("showSolo", false)
    
    -- Must be shown for children to be created
    -- Don't disable events - let SecureGroupHeaderTemplate auto-manage
    roleQueryHeader:Show()
    
    self.roleQueryHeader = roleQueryHeader
    
    DebugPrint("Role query header created")
    
    -- ============================================================
    -- IN-COMBAT SORTING VIA ATTRIBUTE CHANGE HOOK
    -- ============================================================
    -- The key insight from SortUnitFrames: We can't call SecureHandlerExecute
    -- during combat, BUT SecureHandlerWrapScript handlers DO run in combat
    -- when their wrapped event fires.
    --
    -- We wrap the handler's OnAttributeChanged for "state-sortTrigger".
    -- When group changes during combat, the roleQueryHeader's children update.
    -- We also wrap one of its children to detect that change and trigger our sort.
    
    -- ============================================================
    -- SORTING SNIPPET (sortPartyFrames)
    -- ============================================================
    -- This snippet ONLY computes the sort order. It does NOT position frames.
    -- After computing the order, it sets sortOrder attributes and calls
    -- the position_all_party_frames snippet which handles all positioning.
    -- This keeps sorting and positioning as separate, modular systems.
    -- ============================================================
    handler:Execute([=[
        sortPartyFrames = [[
            -- =====================================================
            -- STEP 1: Collect VISIBLE frames and their units
            -- =====================================================
            local frameUnits = newtable()
            local visibleFrames = newtable()
            local frameCount = 0
            
            local debugEnabled = self:GetAttribute("debugEnabled")
            
            for i = 0, 4 do
                local f = partyFrames and partyFrames[i]
                if f and f:IsShown() then
                    local u = f:GetAttribute("unit")
                    if u then
                        frameUnits[i] = u
                        visibleFrames[frameCount] = i
                        frameCount = frameCount + 1
                    end
                end
            end
            
            -- Need at least one frame
            if frameCount < 1 then return end
            
            -- =====================================================
            -- STEP 2: Get sort settings
            -- =====================================================
            local sortEnabled = self:GetAttribute("sortEnabled")
            local selfPosition = self:GetAttribute("selfPosition") or "NORMAL"
            local sortAlphabetical = self:GetAttribute("sortAlphabetical") or false
            local sortAlphaReverse = (sortAlphabetical == "ZA")
            local sortByClass = self:GetAttribute("sortByClass") or false
            
            -- =====================================================
            -- STEP 3: Query roles (if sorting enabled)
            -- =====================================================
            local rqh = self:GetFrameRef("roleQueryHeader")
            local unit2role = newtable()
            local unit2class = newtable()
            
            if rqh and sortEnabled then
                local roleNames = newtable()
                roleNames[1] = "TANK"
                roleNames[2] = "HEALER"
                roleNames[3] = "DAMAGER"
                
                for ri = 1, 3 do
                    local roleName = roleNames[ri]
                    rqh:SetAttribute("roleFilter", roleName)
                    
                    for j = 1, 40 do
                        local child = rqh:GetAttribute("frameref-child" .. j)
                        if child then
                            local unit = child:GetAttribute("unit")
                            if unit and not unit2role[unit] then
                                unit2role[unit] = roleName
                            end
                        else
                            break
                        end
                    end
                end
                rqh:SetAttribute("roleFilter", nil)
                
                -- =====================================================
                -- STEP 3b: Query classes using groupFilter
                -- =====================================================
                local classNames = newtable()
                classNames[1] = "WARRIOR"
                classNames[2] = "PALADIN"
                classNames[3] = "HUNTER"
                classNames[4] = "ROGUE"
                classNames[5] = "PRIEST"
                classNames[6] = "DEATHKNIGHT"
                classNames[7] = "SHAMAN"
                classNames[8] = "MAGE"
                classNames[9] = "WARLOCK"
                classNames[10] = "MONK"
                classNames[11] = "DRUID"
                classNames[12] = "DEMONHUNTER"
                classNames[13] = "EVOKER"
                
                for ci = 1, 13 do
                    local className = classNames[ci]
                    rqh:SetAttribute("groupFilter", className)
                    
                    for j = 1, 40 do
                        local child = rqh:GetAttribute("frameref-child" .. j)
                        if child then
                            local unit = child:GetAttribute("unit")
                            if unit and not unit2class[unit] then
                                unit2class[unit] = className
                            end
                        else
                            break
                        end
                    end
                end
                rqh:SetAttribute("groupFilter", nil)
            end
            
            -- =====================================================
            -- STEP 4: Build priority lookups
            -- =====================================================
            local rolePriority = newtable()
            for i = 1, 3 do
                local r = self:GetAttribute("roleOrder" .. i)
                if r then
                    rolePriority[r] = i
                end
            end
            if not rolePriority["TANK"] then rolePriority["TANK"] = 1 end
            if not rolePriority["HEALER"] then rolePriority["HEALER"] = 2 end
            if not rolePriority["DAMAGER"] then rolePriority["DAMAGER"] = 3 end
            
            local classPriority = newtable()
            for i = 1, 13 do
                local cls = self:GetAttribute("classOrder" .. i)
                if cls then
                    classPriority[cls] = i
                end
            end
            
            -- =====================================================
            -- STEP 5: Calculate sort keys for each VISIBLE frame
            -- =====================================================
            local frameSortKey = newtable()
            local frameName = newtable()
            
            for idx = 0, frameCount - 1 do
                local i = visibleFrames[idx]
                local unit = frameUnits[i]
                local role = unit2role[unit] or "DAMAGER"
                local rp = rolePriority[role] or 99
                local cls = unit2class[unit]
                local cp = sortByClass and (classPriority[cls] or 99) or 0
                frameSortKey[idx] = rp * 100 + cp
                
                -- Read name from attribute (pushed by Lua code)
                frameName[idx] = self:GetAttribute("frameName" .. i) or ""
            end
            
            -- =====================================================
            -- STEP 6: Build sorted order
            -- =====================================================
            -- sortOrder[slot] = index into visibleFrames
            local sortOrder = newtable()
            for i = 0, frameCount - 1 do
                sortOrder[i] = i
            end
            
            -- Bubble sort by sort key, then by name as tiebreaker
            if sortEnabled then
                for i = 0, frameCount - 2 do
                    for j = 0, frameCount - 2 - i do
                        local a = sortOrder[j]
                        local b = sortOrder[j + 1]
                        local swap = false
                        
                        if frameSortKey[a] > frameSortKey[b] then
                            -- Different role/class priority - sort by that
                            swap = true
                        elseif frameSortKey[a] == frameSortKey[b] and sortAlphabetical then
                            -- Same role+class AND alphabetical enabled - sort by name
                            local nameA = frameName[a] or ""
                            local nameB = frameName[b] or ""
                            if sortAlphaReverse then
                                if nameA < nameB then swap = true end
                            else
                                if nameA > nameB then swap = true end
                            end
                        end
                        
                        if swap then
                            sortOrder[j] = b
                            sortOrder[j + 1] = a
                        end
                    end
                end
            end
            
            -- =====================================================
            -- STEP 7: Handle self position override
            -- =====================================================
            -- Find which slot has the player frame (frame index 0)
            local playerSlot = nil
            for slot = 0, frameCount - 1 do
                local sortIdx = sortOrder[slot]
                local frameIdx = visibleFrames[sortIdx]
                if frameIdx == 0 then
                    playerSlot = slot
                    break
                end
            end
            
            local targetSlot = nil
            if selfPosition == "FIRST" or selfPosition == "1" then
                targetSlot = 0
            elseif selfPosition == "LAST" then
                targetSlot = frameCount - 1
            elseif selfPosition == "2" then
                targetSlot = 1
            elseif selfPosition == "3" then
                targetSlot = 2
            elseif selfPosition == "4" then
                targetSlot = 3
            elseif selfPosition == "5" then
                targetSlot = 4
            end
            
            -- Clamp to actual visible frame count
            if targetSlot and targetSlot >= frameCount then
                targetSlot = frameCount - 1
            end
            
            if targetSlot and playerSlot and targetSlot ~= playerSlot then
                local temp = sortOrder[playerSlot]
                if targetSlot < playerSlot then
                    for i = playerSlot, targetSlot + 1, -1 do
                        sortOrder[i] = sortOrder[i - 1]
                    end
                else
                    for i = playerSlot, targetSlot - 1 do
                        sortOrder[i] = sortOrder[i + 1]
                    end
                end
                sortOrder[targetSlot] = temp
            end
            
            -- =====================================================
            -- STEP 8: Set sortOrder attributes for positioning
            -- =====================================================
            -- Convert sortOrder (indices into visibleFrames) to actual frame indices
            -- The position_all_party_frames snippet reads these
            self:SetAttribute("posFrameCount", frameCount)
            for slot = 0, frameCount - 1 do
                local visibleIdx = sortOrder[slot]
                local frameIdx = visibleFrames[visibleIdx]
                self:SetAttribute("sortOrder" .. slot, frameIdx)
            end
            
            -- =====================================================
            -- STEP 9: Call the positioning snippet
            -- =====================================================
            -- Positioning is a separate, isolated system that reads
            -- from layoutConfig and sortOrder attributes
            local snippets = _snippets
            local posSnippet = snippets and snippets["position_all_party_frames"]
            if posSnippet then
                self:Run(posSnippet)
            end

            -- Notify external API subscribers that the sort completed.
            self:CallMethod("NotifySortComplete", "party")
        ]]
    ]=])

    -- ============================================================
    -- RAID SORTING SNIPPET (sortRaidFrames)
    -- ============================================================
    -- This snippet sorts raid frames (flat layout) by role and class.
    -- Similar to sortPartyFrames but handles up to 40 frames in a grid.
    -- ============================================================
    handler:Execute([=[
        sortRaidFrames = [[
            -- Unconditional debug to confirm snippet runs
            self:CallMethod("DebugPrint", "RAID SORT SNIPPET ENTERED")
            
            local debugEnabled = self:GetAttribute("debugEnabled")
            
            -- =====================================================
            -- STEP 1: Collect VISIBLE raid frames and their units
            -- =====================================================
            local frameUnits = newtable()
            local visibleFrames = newtable()
            local frameCount = 0
            
            if not raidFrames then
                self:CallMethod("DebugPrint", "RAID SORT: raidFrames is nil!")
                return
            end
            
            self:CallMethod("DebugPrint", "RAID SORT: raidFrames exists, checking frames...")
            
            for i = 1, 40 do
                local f = raidFrames[i]
                if f and f:IsShown() then
                    local u = f:GetAttribute("unit")
                    if u then
                        frameUnits[i] = u
                        visibleFrames[frameCount] = i
                        frameCount = frameCount + 1
                    end
                end
            end
            
            -- Need at least one frame
            if frameCount < 1 then 
                self:CallMethod("DebugPrint", "RAID SORT: No visible frames (frameCount=0)")
                return 
            end
            
            self:CallMethod("DebugPrint", "RAID SORT: Found " .. frameCount .. " visible frames")
            
            -- =====================================================
            -- STEP 2: Get raid sort settings
            -- =====================================================
            local sortEnabled = self:GetAttribute("raidSortEnabled")
            local sortByClass = self:GetAttribute("raidSortByClass") or false
            local sortAlphabetical = self:GetAttribute("raidSortAlphabetical") or false
            local sortAlphaReverse = (sortAlphabetical == "ZA")
            local selfPosition = self:GetAttribute("raidSelfPosition") or "NORMAL"
            local useGroups = raidUseGroups  -- Set by PushRaidGroupLayoutConfig
            
            self:CallMethod("DebugPrint", "RAID SORT: enabled=" .. tostring(sortEnabled) .. " class=" .. tostring(sortByClass) .. " alpha=" .. tostring(sortAlphabetical) .. " useGroups=" .. tostring(useGroups))
            
            -- =====================================================
            -- STEP 3: Query roles, classes, and GROUPS
            -- =====================================================
            local rqh = self:GetFrameRef("roleQueryHeader")
            local unit2role = newtable()
            local unit2class = newtable()
            local unit2group = newtable()
            
            if rqh then
                -- Query subgroups (1-8) using groupFilter
                for gi = 1, 8 do
                    local groupStr = tostring(gi)
                    rqh:SetAttribute("groupFilter", groupStr)
                    
                    for j = 1, 40 do
                        local child = rqh:GetAttribute("frameref-child" .. j)
                        if child then
                            local unit = child:GetAttribute("unit")
                            if unit and not unit2group[unit] then
                                unit2group[unit] = gi
                            end
                        else
                            break
                        end
                    end
                end
                rqh:SetAttribute("groupFilter", nil)
                
                -- GUARD: If using groups, verify ALL visible frames have group data
                -- This prevents the "everyone in group 1" flicker when roleQueryHeader
                -- hasn't fully populated yet (some frames missing = incomplete data)
                if useGroups then
                    local allHaveGroups = true
                    local groupCount = 0
                    
                    for idx = 0, frameCount - 1 do
                        local i = visibleFrames[idx]
                        local unit = frameUnits[i]
                        if unit then
                            if unit2group[unit] then
                                groupCount = groupCount + 1
                            else
                                -- This frame's unit has no group data - data is incomplete
                                allHaveGroups = false
                                break
                            end
                        end
                    end
                    
                    if not allHaveGroups or groupCount == 0 then
                        -- Incomplete group data - leave frames where they are
                        if debugEnabled then
                            self:CallMethod("DebugPrint", "RAID SORT: Incomplete group data (" .. groupCount .. "/" .. frameCount .. "), skipping")
                        end
                        return
                    end
                end
                
                -- Query roles (if sorting enabled)
                if sortEnabled then
                    local roleNames = newtable()
                    roleNames[1] = "TANK"
                    roleNames[2] = "HEALER"
                    roleNames[3] = "DAMAGER"
                    
                    for ri = 1, 3 do
                        local roleName = roleNames[ri]
                        rqh:SetAttribute("roleFilter", roleName)
                        
                        for j = 1, 40 do
                            local child = rqh:GetAttribute("frameref-child" .. j)
                            if child then
                                local unit = child:GetAttribute("unit")
                                if unit and not unit2role[unit] then
                                    unit2role[unit] = roleName
                                end
                            else
                                break
                            end
                        end
                    end
                    rqh:SetAttribute("roleFilter", nil)
                    
                    -- Query classes using groupFilter
                    local classNames = newtable()
                    classNames[1] = "WARRIOR"
                    classNames[2] = "PALADIN"
                    classNames[3] = "HUNTER"
                    classNames[4] = "ROGUE"
                    classNames[5] = "PRIEST"
                    classNames[6] = "DEATHKNIGHT"
                    classNames[7] = "SHAMAN"
                    classNames[8] = "MAGE"
                    classNames[9] = "WARLOCK"
                    classNames[10] = "MONK"
                    classNames[11] = "DRUID"
                    classNames[12] = "DEMONHUNTER"
                    classNames[13] = "EVOKER"
                    
                    for ci = 1, 13 do
                        local className = classNames[ci]
                        rqh:SetAttribute("groupFilter", className)
                        
                        for j = 1, 40 do
                            local child = rqh:GetAttribute("frameref-child" .. j)
                            if child then
                                local unit = child:GetAttribute("unit")
                                if unit and not unit2class[unit] then
                                    unit2class[unit] = className
                                end
                            else
                                break
                            end
                        end
                    end
                    rqh:SetAttribute("groupFilter", nil)
                end
            end
            
            -- =====================================================
            -- STEP 4: Build priority lookups
            -- =====================================================
            local rolePriority = newtable()
            for i = 1, 3 do
                local r = self:GetAttribute("raidRoleOrder" .. i)
                if r then
                    rolePriority[r] = i
                end
            end
            if not rolePriority["TANK"] then rolePriority["TANK"] = 1 end
            if not rolePriority["HEALER"] then rolePriority["HEALER"] = 2 end
            if not rolePriority["DAMAGER"] then rolePriority["DAMAGER"] = 3 end
            
            local classPriority = newtable()
            for i = 1, 13 do
                local cls = self:GetAttribute("raidClassOrder" .. i)
                if cls then
                    classPriority[cls] = i
                end
            end
            
            -- =====================================================
            -- STEP 5: Calculate sort keys for each VISIBLE frame
            -- =====================================================
            local frameSortKey = newtable()
            local frameName = newtable()
            
            for idx = 0, frameCount - 1 do
                local i = visibleFrames[idx]
                local unit = frameUnits[i]
                local role = unit2role[unit] or "DAMAGER"
                local rp = rolePriority[role] or 99
                local cls = unit2class[unit]
                local cp = sortByClass and (classPriority[cls] or 99) or 0
                frameSortKey[idx] = rp * 100 + cp
                
                -- Read name from attribute (pushed by Lua code)
                frameName[idx] = self:GetAttribute("raidFrameName" .. i) or ""
                
                self:CallMethod("DebugPrint", "RAID SORT: frame " .. i .. " idx=" .. idx .. " name=" .. tostring(frameName[idx]) .. " role=" .. role .. " key=" .. frameSortKey[idx])
            end
            
            -- =====================================================
            -- STEP 6: Build sorted order
            -- =====================================================
            local sortOrder = newtable()
            for i = 0, frameCount - 1 do
                sortOrder[i] = i
            end
            
            -- Bubble sort by sort key, then by name as tiebreaker
            if sortEnabled then
                for i = 0, frameCount - 2 do
                    for j = 0, frameCount - 2 - i do
                        local a = sortOrder[j]
                        local b = sortOrder[j + 1]
                        local swap = false
                        
                        if frameSortKey[a] > frameSortKey[b] then
                            -- Different role/class priority - sort by that
                            swap = true
                        elseif frameSortKey[a] == frameSortKey[b] and sortAlphabetical then
                            -- Same role+class AND alphabetical enabled - sort by name
                            local nameA = frameName[a] or ""
                            local nameB = frameName[b] or ""
                            if sortAlphaReverse then
                                if nameA < nameB then swap = true end
                            else
                                if nameA > nameB then swap = true end
                            end
                        end
                        
                        if swap then
                            sortOrder[j] = b
                            sortOrder[j + 1] = a
                        end
                    end
                end
            end
            
            -- =====================================================
            -- STEP 6b: Handle self position override
            -- =====================================================
            -- Get the player's frame index (set by Lua code out of combat)
            local playerFrameIndex = self:GetAttribute("raidPlayerFrameIndex")
            
            -- Find which slot has the player's frame
            local playerSlot = nil
            if playerFrameIndex then
                for slot = 0, frameCount - 1 do
                    local visibleIdx = sortOrder[slot]
                    local frameIdx = visibleFrames[visibleIdx]
                    if frameIdx == playerFrameIndex then
                        playerSlot = slot
                        break
                    end
                end
            end
            
            -- Calculate target slot based on selfPosition setting
            local targetSlot = nil
            if selfPosition == "FIRST" or selfPosition == "1" then
                targetSlot = 0
            elseif selfPosition == "LAST" then
                targetSlot = frameCount - 1
            elseif selfPosition == "2" then
                targetSlot = 1
            elseif selfPosition == "3" then
                targetSlot = 2
            elseif selfPosition == "4" then
                targetSlot = 3
            elseif selfPosition == "5" then
                targetSlot = 4
            end
            
            -- Clamp target to actual frame count
            if targetSlot and targetSlot >= frameCount then
                targetSlot = frameCount - 1
            end
            
            -- Move player to target position if needed
            if targetSlot and playerSlot and targetSlot ~= playerSlot then
                local temp = sortOrder[playerSlot]
                if targetSlot < playerSlot then
                    -- Shift frames right to make room
                    for i = playerSlot, targetSlot + 1, -1 do
                        sortOrder[i] = sortOrder[i - 1]
                    end
                else
                    -- Shift frames left to make room
                    for i = playerSlot, targetSlot - 1 do
                        sortOrder[i] = sortOrder[i + 1]
                    end
                end
                sortOrder[targetSlot] = temp
            end
            
            -- =====================================================
            -- STEP 7: Set sortOrder attributes for positioning
            -- =====================================================
            self:SetAttribute("raidFrameCount", frameCount)
            
            local orderStr = "RAID SORT: Final order: "
            for slot = 0, frameCount - 1 do
                local visibleIdx = sortOrder[slot]
                local frameIdx = visibleFrames[visibleIdx]
                self:SetAttribute("raidSortOrder" .. slot, frameIdx)
                orderStr = orderStr .. "slot" .. slot .. "=frame" .. frameIdx .. " "
                
                -- Also store group membership for grouped positioning
                if useGroups then
                    local unit = frameUnits[frameIdx]
                    local groupNum = unit2group[unit] or 1
                    self:SetAttribute("raidFrameGroup" .. frameIdx, groupNum)
                end
            end
            self:CallMethod("DebugPrint", orderStr)
            
            self:CallMethod("DebugPrint", "RAID SORT: sortOrder set, useGroups=" .. tostring(useGroups) .. " hasGroupConfig=" .. tostring(raidGroupLayoutConfig ~= nil))
            
            -- =====================================================
            -- STEP 8: Call the appropriate positioning snippet
            -- =====================================================
            local snippets = _snippets
            local posSnippet
            if useGroups and raidGroupLayoutConfig then
                posSnippet = snippets and snippets["position_all_raid_frames_grouped"]
                self:CallMethod("DebugPrint", "RAID SORT: Using GROUPED positioning")
            else
                posSnippet = snippets and snippets["position_all_raid_frames"]
                self:CallMethod("DebugPrint", "RAID SORT: Using FLAT positioning")
            end
            if posSnippet then
                self:Run(posSnippet)
            else
                self:CallMethod("DebugPrint", "RAID SORT: No position snippet found!")
            end

            -- Notify external API subscribers that the sort completed.
            self:CallMethod("NotifySortComplete", "raid")
        ]]
    ]=])

    -- Wrap handler's OnAttributeChanged to trigger sorting
    -- When "state-sortTrigger" changes, run the sort
    -- NOTE: Throttling is done on the Lua side in TriggerSecureRaidSort/TriggerSecureSort
    SecureHandlerWrapScript(handler, "OnAttributeChanged", handler, [[
        if name == "state-sorttrigger" then
            -- Trigger sort when this attribute changes
            self:Run(sortPartyFrames)
        elseif name == "state-raidsorttrigger" then
            -- Trigger raid sort when this attribute changes
            self:Run(sortRaidFrames)
        end
    ]])
    
    -- Store handler ref on roleQueryHeader so wrapped code can access it
    SecureHandlerSetFrameRef(roleQueryHeader, "sortHandler", handler)
    
    -- Hook roleQueryHeader children - when unit changes, trigger sort on handler
    -- We need to wrap the header itself since children are created dynamically
    -- NOTE: Throttling is done on the Lua side
    SecureHandlerWrapScript(roleQueryHeader, "OnAttributeChanged", handler, [[
        -- When any attribute changes on the header, it might mean group changed
        -- Check if it's a child-related change
        if name and name:find("^child") then
            -- A child was added/removed/changed - trigger sort
            local h = self:GetFrameRef("sortHandler")
            if h then
                -- Check if we're in raid mode
                local isRaidMode = h:GetAttribute("isRaidMode")
                if isRaidMode then
                    -- Trigger raid sort
                    local v = h:GetAttribute("state-raidsorttrigger") or 0
                    h:SetAttribute("state-raidsorttrigger", v + 1)
                else
                    -- Trigger party sort
                    local v = h:GetAttribute("state-sorttrigger") or 0
                    h:SetAttribute("state-sorttrigger", 1 - v)
                end
            end
        end
    ]])
    
    DebugPrint("In-combat sort hooks registered")
    
    -- ============================================================
    -- SECURE SORT BUTTON
    -- ============================================================
    -- Sorts party frames by role. Queries roles FRESH each time
    -- using roleFilter on SecureGroupHeaderTemplate (works in combat!)
    
    local sortButton = CreateFrame("Button", "DFSecureSortButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    sortButton:SetSize(120, 30)
    sortButton:SetPoint("TOP", reverseButton, "BOTTOM", 0, -15)
    sortButton:SetText("Secure Sort")
    sortButton:Hide()
    
    self.sortButton = sortButton
    
    -- Set frame refs - including roleQueryHeader for the sorting snippet
    SecureHandlerSetFrameRef(sortButton, "container", handler)
    SecureHandlerSetFrameRef(sortButton, "roleQueryHeader", roleQueryHeader)
    
    -- Also set frame refs on the handler for the sorting snippet
    SecureHandlerSetFrameRef(handler, "roleQueryHeader", roleQueryHeader)
    
    -- Secure sort code - MINIMAL TEST
    sortButton:SetAttribute("_onclick", [=[
        -- Step 1: Just set an attribute
        self:SetAttribute("_test1", "step1_worked")
        
        -- Step 2: Try GetFrameRef
        local f0 = self:GetFrameRef("frame0")
        self:SetAttribute("_test2", f0 and "frame0_exists" or "frame0_nil")
        
        -- Step 3: If frame exists, try to get its attribute
        if f0 then
            self:SetAttribute("_test3", "trying_getattr")
            local u = f0:GetAttribute("unit")
            self:SetAttribute("_test4", u or "unit_nil")
        end
        
        -- Step 5: Try container
        local container = self:GetFrameRef("container")
        self:SetAttribute("_test5", container and "container_exists" or "container_nil")
    ]=])
    
    DebugPrint("Secure Sort button created")
    
    -- ============================================================
    -- PHASE 3: DEBUG ROLES BUTTON (prints what data we can get)
    -- ============================================================
    local debugRolesButton = CreateFrame("Button", "DFDebugRolesButton", UIParent, "SecureHandlerClickTemplate,UIPanelButtonTemplate")
    debugRolesButton:SetSize(120, 30)
    debugRolesButton:SetPoint("TOP", sortButton, "BOTTOM", 0, -5)
    debugRolesButton:SetText("Debug Roles")
    debugRolesButton:Hide()
    
    self.debugRolesButton = debugRolesButton
    
    -- Set frame ref to role query header
    SecureHandlerSetFrameRef(debugRolesButton, "roleQueryHeader", roleQueryHeader)
    
    -- Debug code - prints info about what data we can access
    -- This runs in INSECURE code so we can use all Lua functions
    debugRolesButton:SetScript("OnClick", function()
        print("|cff00ff00[DF Debug]|r Querying role data...")
        
        local rqh = DF.SecureSort.roleQueryHeader
        if not rqh then
            print("|cffff0000[DF Debug]|r No roleQueryHeader!")
            return
        end
        
        print("|cff00ff00[DF Debug]|r Header: " .. tostring(rqh:GetName()))
        print("|cff00ff00[DF Debug]|r Shown: " .. tostring(rqh:IsShown()))
        
        -- Get children via GetChildren()
        local children = {rqh:GetChildren()}
        print("|cff00ff00[DF Debug]|r Number of children: " .. #children)
        
        for i, child in ipairs(children) do
            local unit = child:GetAttribute("unit")
            local name = child:GetName()
            print("  Child " .. i .. ": " .. tostring(name) .. " unit=" .. tostring(unit))
            
            if unit then
                -- Try UnitGroupRolesAssigned (works out of combat)
                local role = UnitGroupRolesAssigned(unit)
                local _, class = UnitClass(unit)
                local unitName = UnitName(unit)
                print("    role=" .. tostring(role) .. " class=" .. tostring(class) .. " name=" .. tostring(unitName))
            end
        end
        
        -- Also check direct party info
        print("|cff00ff00[DF Debug]|r Direct party check:")
        print("  IsInGroup: " .. tostring(IsInGroup()))
        print("  GetNumGroupMembers: " .. tostring(GetNumGroupMembers()))
        
        if IsInGroup() then
            -- Player
            local role = UnitGroupRolesAssigned("player")
            local _, class = UnitClass("player")
            print("  player: role=" .. tostring(role) .. " class=" .. tostring(class))
            
            -- Party members
            for i = 1, 4 do
                local unit = "party" .. i
                if UnitExists(unit) then
                    local role = UnitGroupRolesAssigned(unit)
                    local _, class = UnitClass(unit)
                    local name = UnitName(unit)
                    print("  " .. unit .. ": role=" .. tostring(role) .. " class=" .. tostring(class) .. " name=" .. tostring(name))
                end
            end
        end
        
        -- Show our party frames' unit attributes
        print("|cff00ff00[DF Debug]|r Our party frames:")
        if DF.playerFrame then
            local unit = DF.playerFrame:GetAttribute("unit")
            print("  playerFrame: unit=" .. tostring(unit))
        else
            print("  playerFrame: nil")
        end
        for i = 1, 4 do
            local frame = DF.partyFrames and DF.partyFrames[i]
            if frame then
                local unit = frame:GetAttribute("unit")
                print("  partyFrame" .. i .. ": unit=" .. tostring(unit))
            else
                print("  partyFrame" .. i .. ": nil")
            end
        end
        
        -- Show sort button state
        print("|cff00ff00[DF Debug]|r Sort button state:")
        local sb = DF.SecureSort.sortButton
        if sb then
            print("  roleOrder1: " .. tostring(sb:GetAttribute("roleOrder1")))
            print("  roleOrder2: " .. tostring(sb:GetAttribute("roleOrder2")))
            print("  roleOrder3: " .. tostring(sb:GetAttribute("roleOrder3")))
            print("  frameCount: " .. tostring(sb:GetAttribute("frameCount")))
            print("  framesRegistered: " .. tostring(DF.SecureSort.framesRegistered))
            print("  selfPosition: " .. tostring(sb:GetAttribute("selfPosition")))
            print("  sortEnabled: " .. tostring(sb:GetAttribute("sortEnabled")))
            
            -- Show layout params
            print("|cffff8800[DF Debug]|r Layout params:")
            print("  layoutWidth: " .. tostring(sb:GetAttribute("layoutWidth")))
            print("  layoutHeight: " .. tostring(sb:GetAttribute("layoutHeight")))
            print("  layoutSpacing: " .. tostring(sb:GetAttribute("layoutSpacing")))
            print("  layoutHorizontal: " .. tostring(sb:GetAttribute("layoutHorizontal")))
            print("  layoutAnchor: " .. tostring(sb:GetAttribute("layoutAnchor")))
        else
            print("  (no sort button)")
        end
        
        -- Show handler debug info
        local h = DF.SecureSort.handler
        if h then
            print("|cffff8800[DF Debug]|r Handler attributes:")
            print("  posFrameCount: " .. tostring(h:GetAttribute("posFrameCount")))
            print("  sortOrder0: " .. tostring(h:GetAttribute("sortOrder0")))
            print("  sortOrder1: " .. tostring(h:GetAttribute("sortOrder1")))
            print("  sortOrder2: " .. tostring(h:GetAttribute("sortOrder2")))
            print("  sortOrder3: " .. tostring(h:GetAttribute("sortOrder3")))
            print("  sortOrder4: " .. tostring(h:GetAttribute("sortOrder4")))
        else
            print("  (no handler)")
        end
        
        -- Show layoutParams (Lua side)
        local lp = DF.SecureSort.layoutParams
        if lp then
            print("|cffff00ff[DF Debug]|r layoutParams (Lua):")
            print("  frameWidth: " .. tostring(lp.frameWidth))
            print("  frameHeight: " .. tostring(lp.frameHeight))
            print("  spacing: " .. tostring(lp.spacing))
            print("  horizontal: " .. tostring(lp.horizontal))
            print("  growthAnchor: " .. tostring(lp.growthAnchor))
        else
            print("  (no layoutParams)")
        end
        
        print("|cff00ff00[DF Debug]|r Done!")
    end)
    
    DebugPrint("Debug Roles button created (Phase 3)")
    
    -- Mark handler as ready
    self.handlerReady = true
    
    return handler
end

-- ============================================================
-- TEST UI PANEL
-- ============================================================
-- A movable panel with buttons for all SecureSort commands
-- Toggle with /dfsecure ui

function SecureSort:CreateTestUI()
    if self.testUI then
        return self.testUI
    end
    
    -- Main frame - taller to accommodate Phase 2.5 buttons
    local panel = CreateFrame("Frame", "DFSecureSortTestUI", UIParent, "BackdropTemplate")
    panel:SetSize(180, 520)  -- Increased height
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- Center of screen
    panel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    panel:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    panel:SetBackdropBorderColor(0, 0.8, 1, 0.8)
    
    -- Make it movable
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetClampedToScreen(true)
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("|cff00ffffSecureSort Test|r")
    
    -- Status text
    local statusText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    statusText:SetText("|cffaaaaaaClick buttons to test|r")
    panel.statusText = statusText
    
    -- Helper to create buttons
    local buttonY = -50
    local function CreateButton(text, onClick, color)
        local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetPoint("TOP", panel, "TOP", 0, buttonY)
        btn:SetText(text)
        btn:SetScript("OnClick", function()
            panel.statusText:SetText("|cff00ff00Running...|r")
            onClick()
            C_Timer.After(0.2, function()
                SecureSort:UpdateTestUIStatus()
            end)
        end)
        if color then
            btn:GetFontString():SetTextColor(unpack(color))
        end
        buttonY = buttonY - 25
        return btn
    end
    
    local function CreateLabel(text)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOP", panel, "TOP", 0, buttonY)
        label:SetText(text)
        buttonY = buttonY - 16
        return label
    end
    
    -- Section: Initialization
    CreateLabel("|cffff9900-- Setup --|r")
    
    CreateButton("Initialize", function()
        SecureSort:Initialize()
    end)
    
    -- Section: Registration
    CreateLabel("|cff00ff00-- Register Frames --|r")
    
    CreateButton("Register Party (5)", function()
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        local count = SecureSort:RegisterPartyFrames()
        print("|cff00ffff[SecureSort]|r Registered " .. (count or 0) .. "/5 party frames")
    end)
    
    CreateButton("Register Raid (40)", function()
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        local count = SecureSort:RegisterRaidFrames()
        print("|cff00ffff[SecureSort]|r Registered " .. (count or 0) .. "/40 raid frames")
    end)
    
    -- Section: Phase 2 - Combat Swap Test
    CreateLabel("|cffff9900-- Phase 2: Swap Test --|r")
    
    CreateButton("Show Swap Buttons", function()
        SecureSort:ShowTestButtons()
    end)
    
    CreateButton("Swap (ooc)", function()
        if InCombatLockdown() then
            print("|cffff0000In combat! Use the swap button instead|r")
            return
        end
        SecureSort:RunSnippet("test_swap_positions")
    end)
    
    -- Section: Phase 2.5 - Slot Positioning
    CreateLabel("|cff00ffff-- Phase 2.5: Slots --|r")
    
    CreateButton("Update Layout Params", function()
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        SecureSort:UpdateLayoutParams()
        SecureSort:RunSnippet("test_layout_config")
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[SecureSort]|r Layout: " .. 
                (status.testLayoutWidth or "?") .. "x" .. (status.testLayoutHeight or "?") ..
                " spacing=" .. (status.testLayoutSpacing or "?") ..
                " horiz=" .. (status.testLayoutHorizontal or "?") ..
                " anchor=" .. (status.testLayoutAnchor or "?"))
        end)
    end)
    
    CreateButton("Frame 0 → Slot 2", function()
        if InCombatLockdown() then
            print("|cffff0000In combat! Position tests only work out of combat|r")
            return
        end
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        SecureSort:SecurePositionFrameToSlot(0, 2, 5)
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[SecureSort]|r Position result: " .. (status.positionResult or "?") ..
                " at (" .. (status.positionX or "?") .. ", " .. (status.positionY or "?") .. ")")
        end)
    end)
    
    CreateButton("Frame 1 → Slot 0", function()
        if InCombatLockdown() then
            print("|cffff0000In combat!|r")
            return
        end
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        SecureSort:SecurePositionFrameToSlot(1, 0, 5)
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[SecureSort]|r Position result: " .. (status.positionResult or "?"))
        end)
    end)
    
    CreateButton("Reset All (0,1,2,3,4)", function()
        if InCombatLockdown() then
            print("|cffff0000In combat!|r")
            return
        end
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        -- Reset to natural order: frame 0 → slot 0, frame 1 → slot 1, etc.
        local sortOrder = {0, 1, 2, 3, 4}
        SecureSort:SecurePositionAllFrames(sortOrder, 5)
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[SecureSort]|r Positioned " .. (status.positionAllCount or "?") .. " frames")
        end)
    end)
    
    CreateButton("Reverse (4,3,2,1,0)", function()
        if InCombatLockdown() then
            print("|cffff0000In combat!|r")
            return
        end
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        -- Reverse order: frame 4 → slot 0, frame 3 → slot 1, etc.
        local sortOrder = {4, 3, 2, 1, 0}
        SecureSort:SecurePositionAllFrames(sortOrder, 5)
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[SecureSort]|r Positioned " .. (status.positionAllCount or "?") .. " frames (reversed)")
        end)
    end)
    
    CreateButton("Trigger Secure Sort", function()
        if not SecureSort.initialized then
            print("|cffff0000Not initialized!|r")
            return
        end
        if not SecureSort.framesRegistered then
            print("|cffff0000Frames not registered!|r")
            return
        end
        SecureSort:TriggerSecureSort("DebugButton")
        print("|cff00ffff[SecureSort]|r Secure sort triggered!")
    end, {0.2, 0.5, 0.8})
    
    -- Section: Debug
    CreateLabel("|cffaaaaaa-- Debug --|r")
    
    CreateButton("Print Status", function()
        SecureSort:PrintStatus()
    end)
    
    CreateButton("Debug Roles", function()
        if SecureSort.debugRolesButton then
            SecureSort.debugRolesButton:Click()
        else
            print("|cffff0000Debug button not created!|r")
        end
    end, {0.2, 0.6, 0.2})
    
    CreateButton("Toggle Debug", function()
        SecureSort.debug = not SecureSort.debug
        print("|cff00ffff[SecureSort]|r Debug: " .. (SecureSort.debug and "|cff00ff00ON|r" or "|cffaaaaaaoff|r"))
    end)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 2, 2)
    closeBtn:SetScript("OnClick", function()
        panel:Hide()
    end)
    
    -- Combat indicator
    local combatIndicator = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatIndicator:SetPoint("BOTTOM", panel, "BOTTOM", 0, 8)
    combatIndicator:SetText("")
    panel.combatIndicator = combatIndicator
    
    -- Update combat status
    panel:RegisterEvent("PLAYER_REGEN_DISABLED")
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            self.combatIndicator:SetText("|cffff0000** IN COMBAT **|r")
        else
            self.combatIndicator:SetText("|cff00ff00Out of Combat|r")
        end
    end)
    
    -- Set initial combat state
    if InCombatLockdown() then
        combatIndicator:SetText("|cffff0000** IN COMBAT **|r")
    else
        combatIndicator:SetText("|cff00ff00Out of Combat|r")
    end
    
    panel:Hide() -- Hidden by default
    self.testUI = panel
    
    DebugPrint("Test UI created (Phase 2.5)")
    return panel
end

function SecureSort:UpdateTestUIStatus()
    if not self.testUI then return end
    
    local status = self:GetStatus()
    local text = ""
    
    if not status.initialized then
        text = "|cffff0000Not initialized|r"
    elseif status.testPartyCount and status.testPartyCount > 0 then
        text = "|cff00ff00Ready: " .. status.testPartyCount .. " frames|r"
    else
        text = "|cffff9900Initialized (no frames)|r"
    end
    
    self.testUI.statusText:SetText(text)
end

function SecureSort:ShowTestUI()
    if not self.testUI then
        self:CreateTestUI()
    end
    self.testUI:Show()
    self:UpdateTestUIStatus()
    print("|cff00ffff[SecureSort]|r Test UI shown. Drag to move.")
end

function SecureSort:HideTestUI()
    if self.testUI then
        self.testUI:Hide()
    end
end

function SecureSort:ToggleTestUI()
    if self.testUI and self.testUI:IsShown() then
        self:HideTestUI()
    else
        self:ShowTestUI()
    end
end

-- ============================================================
-- SETSECUREPATH - Data Bridge to Secure Environment
-- ============================================================
-- This is the key function for passing data INTO the secure environment.
-- It works by:
-- 1. Setting temporary attributes on the handler
-- 2. Executing secure code that reads those attributes
-- 3. Storing the value in a nested table path in the secure environment
--
-- Example: SecureSort:SetSecurePath(myFrame, "partyFrames", 1)
-- This stores myFrame at partyFrames[1] in the secure environment
--
-- For frame references, we use SecureHandlerSetFrameRef which creates
-- a special "frameref-X" attribute that secure code can read.

function SecureSort:SetSecurePath(value, ...)
    local handler = self.handler
    if not handler then
        DebugPrint("ERROR: Handler not created, cannot use SetSecurePath")
        return
    end
    
    local n = select('#', ...)
    
    if n == 0 then
        DebugPrint("ERROR: SetSecurePath called with no path")
        return
    end
    
    -- Use SetAttributeNoHandler to avoid triggering secure handlers during setup
    handler:SetAttributeNoHandler("n", n)
    
    -- Store each path component using strchar(i) as attribute name
    for i = 1, n do
        handler:SetAttributeNoHandler(strchar(i), select(i, ...))
    end
    
    -- Handle the value differently based on type
    local isFrame = type(value) == "table" and value.GetObjectType
    if isFrame then
        -- It's a frame - use SecureHandlerSetFrameRef and GetFrameRef
        SecureHandlerSetFrameRef(handler, "pathFrame", value)
        
        -- Execute secure code to store the frame at the path using GetFrameRef
        SecureHandlerExecute(handler, [[
            local n = self:GetAttribute("n")
            local t = _G
            for i = 1, n - 1 do
                local x = self:GetAttribute(strchar(i))
                local u = t[x]
                if not u then
                    u = newtable()
                    t[x] = u
                end
                t = u
            end
            t[self:GetAttribute(strchar(n))] = self:GetFrameRef("pathFrame")
        ]])
    else
        -- It's a simple value - store directly as attribute
        handler:SetAttributeNoHandler("pathValue", value)
        
        -- Execute secure code to store the value at the path
        SecureHandlerExecute(handler, [[
            local n = self:GetAttribute("n")
            local t = _G
            for i = 1, n - 1 do
                local x = self:GetAttribute(strchar(i))
                local u = t[x]
                if not u then
                    u = newtable()
                    t[x] = u
                end
                t = u
            end
            t[self:GetAttribute(strchar(n))] = self:GetAttribute("pathValue")
        ]])
    end
    
    if SecureSort.debug then
        local pathParts = {...}
        -- Debug removed - too spammy
    end
end

-- Convenience wrapper on DF namespace
function DF:SetSecurePath(value, ...)
    SecureSort:SetSecurePath(value, ...)
end

-- Get string character (matches SortUnitFrames approach)
local strchar = string.char

-- ============================================================
-- SNIPPET REGISTRATION
-- ============================================================
-- Snippets are strings of Lua code that will be executed in the
-- secure environment. We register them with names so they can
-- be called via self:Run(snippetName) from other secure code.

function SecureSort:RegisterSnippet(name, code)
    local handler = self.handler
    if not handler then
        DebugPrint("ERROR: Handler not created, cannot register snippet")
        return
    end
    
    -- Use SetSecurePath to store the snippet code in the secure environment
    self:SetSecurePath(code, "_snippets", name)
    
    -- ALSO store as attribute for click-based triggering during combat
    -- This allows /click DFSecureSortHandler to run the snippet
    handler:SetAttribute("snippet-" .. name, code)
    
    DebugPrint("Registered snippet:", name)
end

-- ============================================================
-- NOTE: SetAttribute cannot be called during combat, so we use
-- visible secure buttons that can be clicked manually or via /click
-- ============================================================

-- Show the test buttons for combat testing
function SecureSort:ShowTestButtons()
    if self.swapButton then
        self.swapButton:Show()
    end
    if self.swapBackButton then
        self.swapBackButton:Show()
    end
    if self.resetButton then
        self.resetButton:Show()
    end
    if self.reverseButton then
        self.reverseButton:Show()
    end
    if self.sortButton then
        self.sortButton:Show()
    end
    if self.debugRolesButton then
        self.debugRolesButton:Show()
    end
    print("|cff00ffff[DF SecureSort]|r Test buttons shown. Works in combat!")
    print("|cff00ffff[DF SecureSort]|r Commands: |cffffffff/click DFSecureSortButton|r or |cffffffff/click DFDebugRolesButton|r")
end

-- Hide the test buttons
function SecureSort:HideTestButtons()
    if self.swapButton then
        self.swapButton:Hide()
    end
    if self.swapBackButton then
        self.swapBackButton:Hide()
    end
    if self.resetButton then
        self.resetButton:Hide()
    end
    if self.reverseButton then
        self.reverseButton:Hide()
    end
    if self.sortButton then
        self.sortButton:Hide()
    end
    if self.debugRolesButton then
        self.debugRolesButton:Hide()
    end
    print("|cff00ffff[DF SecureSort]|r Test buttons hidden.")
end

-- Update layout params on combat buttons (must be called out of combat)
function SecureSort:UpdateLayoutParamsOnButtons()
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot update button layout params during combat")
        return false
    end
    
    local lp = self.layoutParams
    if not lp then
        DebugPrint("WARNING: No layout params to push to buttons")
        return false
    end
    
    -- Update reset button
    if self.resetButton then
        self.resetButton:SetAttribute("layoutWidth", lp.frameWidth)
        self.resetButton:SetAttribute("layoutHeight", lp.frameHeight)
        self.resetButton:SetAttribute("layoutSpacing", lp.spacing)
        self.resetButton:SetAttribute("layoutHorizontal", lp.horizontal)
        self.resetButton:SetAttribute("layoutAnchor", lp.growthAnchor)
        self.resetButton:SetAttribute("frameCount", 5)
    end
    
    -- Update reverse button
    if self.reverseButton then
        self.reverseButton:SetAttribute("layoutWidth", lp.frameWidth)
        self.reverseButton:SetAttribute("layoutHeight", lp.frameHeight)
        self.reverseButton:SetAttribute("layoutSpacing", lp.spacing)
        self.reverseButton:SetAttribute("layoutHorizontal", lp.horizontal)
        self.reverseButton:SetAttribute("layoutAnchor", lp.growthAnchor)
        self.reverseButton:SetAttribute("frameCount", 5)
    end
    
    -- Update sort button
    if self.sortButton then
        self.sortButton:SetAttribute("layoutWidth", lp.frameWidth)
        self.sortButton:SetAttribute("layoutHeight", lp.frameHeight)
        self.sortButton:SetAttribute("layoutSpacing", lp.spacing)
        self.sortButton:SetAttribute("layoutHorizontal", lp.horizontal)
        self.sortButton:SetAttribute("layoutAnchor", lp.growthAnchor)
        self.sortButton:SetAttribute("frameCount", 5)
    end
    
    -- Update handler (for in-combat sorting via OnAttributeChanged)
    if self.handler then
        self.handler:SetAttribute("frameWidth", lp.frameWidth)
        self.handler:SetAttribute("frameHeight", lp.frameHeight)
        self.handler:SetAttribute("spacing", lp.spacing)
        self.handler:SetAttribute("horizontal", lp.horizontal)
        self.handler:SetAttribute("growthAnchor", lp.growthAnchor)
        self.handler:SetAttribute("frameCount", 5)
    end
    
    -- Debug removed - too spammy
    return true
end

-- Push sort settings to the sort button (for Phase 3 secure sorting)
-- This pushes settings like role order and self position, NOT the pre-calculated sort.
-- The secure sort button will calculate the sort itself using these settings.
function SecureSort:PushSortSettings()
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot push sort settings during combat")
        self.pendingSettingsPush = true
        return false
    end
    
    if not self.sortButton then
        DebugPrint("WARNING: Sort button not created yet")
        return false
    end
    
    local db = DF:GetDB("party")
    if not db then
        DebugPrint("WARNING: No party db for sort settings")
        return false
    end
    
    -- Get role order from settings
    -- Settings may have MELEE/RANGED, but WoW API only returns DAMAGER
    -- So we need to convert: first occurrence of MELEE or RANGED becomes DAMAGER's position
    local rawRoleOrder = db.sortRoleOrder or {"TANK", "HEALER", "MELEE", "RANGED"}
    local roleOrder = {}
    local damagerPos = nil
    local meleeBeforeRanged = true  -- Default: melee before ranged
    local foundMelee = false
    local foundRanged = false
    
    for i, role in ipairs(rawRoleOrder) do
        if role == "MELEE" then
            if not foundRanged then
                meleeBeforeRanged = true
            end
            foundMelee = true
            if not damagerPos then
                damagerPos = #roleOrder + 1
                roleOrder[damagerPos] = "DAMAGER"
            end
        elseif role == "RANGED" then
            if not foundMelee then
                meleeBeforeRanged = false
            end
            foundRanged = true
            if not damagerPos then
                damagerPos = #roleOrder + 1
                roleOrder[damagerPos] = "DAMAGER"
            end
        else
            roleOrder[#roleOrder + 1] = role
        end
    end
    
    -- If no MELEE/RANGED found, add DAMAGER at end
    if not damagerPos then
        roleOrder[#roleOrder + 1] = "DAMAGER"
    end
    
    -- Push to sortButton
    self.sortButton:SetAttribute("roleOrder1", roleOrder[1] or "TANK")
    self.sortButton:SetAttribute("roleOrder2", roleOrder[2] or "HEALER")
    self.sortButton:SetAttribute("roleOrder3", roleOrder[3] or "DAMAGER")
    self.sortButton:SetAttribute("selfPosition", db.sortSelfPosition or "SORTED")
    self.sortButton:SetAttribute("sortEnabled", db.sortEnabled or false)
    self.sortButton:SetAttribute("sortByClass", db.sortByClass or false)
    self.sortButton:SetAttribute("meleeBeforeRanged", meleeBeforeRanged)
    self.sortButton:SetAttribute("sortAlphabetical", db.sortAlphabetical or false)
    
    -- ALSO push to handler (for in-combat sorting via OnAttributeChanged)
    if self.handler then
        self.handler:SetAttribute("roleOrder1", roleOrder[1] or "TANK")
        self.handler:SetAttribute("roleOrder2", roleOrder[2] or "HEALER")
        self.handler:SetAttribute("roleOrder3", roleOrder[3] or "DAMAGER")
        self.handler:SetAttribute("selfPosition", db.sortSelfPosition or "SORTED")
        self.handler:SetAttribute("sortEnabled", db.sortEnabled or false)
        self.handler:SetAttribute("sortByClass", db.sortByClass or false)
        self.handler:SetAttribute("meleeBeforeRanged", meleeBeforeRanged)
        self.handler:SetAttribute("sortAlphabetical", db.sortAlphabetical or false)
    end
    
    -- Push class order (for secondary sorting within same role)
    local defaultClassOrder = {
        "WARRIOR", "PALADIN", "DEATHKNIGHT", "MONK", "DEMONHUNTER",  -- Plate
        "DRUID", "ROGUE", "HUNTER", "SHAMAN", "EVOKER",              -- Leather/Mail
        "MAGE", "WARLOCK", "PRIEST"                                   -- Cloth
    }
    local classOrder = db.sortClassOrder or defaultClassOrder
    
    for i, class in ipairs(classOrder) do
        self.sortButton:SetAttribute("classOrder" .. i, class)
        if self.handler then
            self.handler:SetAttribute("classOrder" .. i, class)
        end
    end
    
    -- Push spec data for melee/ranged distinction
    self:PushSpecDataToFrames()
    
    -- Push unit names for alphabetical sorting
    self:PushPartyUnitNames()
    
    DebugPrint("Sort settings pushed: " .. 
        (roleOrder[1] or "?") .. ">" .. (roleOrder[2] or "?") .. ">" .. (roleOrder[3] or "?") ..
        " self=" .. (db.sortSelfPosition or "SORTED") ..
        " class=" .. tostring(db.sortByClass or false) ..
        " alpha=" .. tostring(db.sortAlphabetical or false))
    
    return true
end

-- Push party unit names for alphabetical sorting
-- Names are stored as attributes so secure code can access them
function SecureSort:PushPartyUnitNames()
    if InCombatLockdown() then
        self.pendingNamesPush = true
        return false
    end
    
    if not self.handler then return false end
    
    local names = {}
    
    -- Push player name (frame index 0)
    local playerName = UnitName("player") or ""
    local lowerName = strlower(playerName)
    self.handler:SetAttribute("frameName0", lowerName)
    names[#names + 1] = "0:" .. lowerName
    
    -- Push party member names (frame indices 1-4)
    for i = 1, 4 do
        local unit = "party" .. i
        local name = ""
        if UnitExists(unit) then
            name = strlower(UnitName(unit) or "")
            names[#names + 1] = i .. ":" .. name
        end
        self.handler:SetAttribute("frameName" .. i, name)
    end
    
    DebugPrint("Names pushed: " .. table.concat(names, ", "))
    return true
end

-- Trigger the secure sort.
-- Out of combat: Sets trigger attribute which fires the sort via OnAttributeChanged.
-- In combat: The roleQueryHeader's OnAttributeChanged hook auto-triggers when group changes.
-- We can't manually trigger during combat, so we just set pendingSort flag.
function SecureSort:TriggerSecureSort(caller)
    caller = caller or "unknown"
    
    -- Throttle: Don't run more than once per 0.1 seconds
    local now = GetTime()
    if self.lastPartySortTime and (now - self.lastPartySortTime) < 0.1 then
        -- Too soon, schedule a delayed sort instead
        if not self.pendingPartySortTimer then
            self.pendingPartySortTimer = C_Timer.NewTimer(0.1, function()
                self.pendingPartySortTimer = nil
                if not InCombatLockdown() and self.framesRegistered then
                    self:TriggerSecureSort("delayed")
                end
            end)
        end
        DebugPrint("TriggerSecureSort THROTTLED (caller=" .. caller .. ")")
        return true
    end
    self.lastPartySortTime = now
    
    DebugPrint("TriggerSecureSort called (caller=" .. caller .. ")")
    
    if not self.handler then
        DebugPrint("WARNING: Handler not created yet")
        return false
    end
    
    if not self.initialized then
        DebugPrint("WARNING: SecureSort not initialized")
        return false
    end
    
    if not self.framesRegistered then
        DebugPrint("WARNING: Frames not registered yet, skipping secure sort")
        return false
    end
    
    -- In combat, we can't call SetAttribute from Lua.
    -- But the roleQueryHeader's OnAttributeChanged hook will auto-fire when group changes.
    -- So in-combat sorting happens automatically - we just queue for a post-combat refresh.
    if InCombatLockdown() then
        DebugPrint("In combat - in-combat sorting handled by OnAttributeChanged hook")
        -- Still queue for post-combat to ensure we're synced
        self.pendingSort = true
        return true  -- Return true because in-combat sorting is handled by hooks
    end
    
    -- Out of combat: Trigger sort via the state-sorttrigger attribute
    -- This fires OnAttributeChanged on handler which runs sortPartyFrames
    self.handler:SetAttribute("state-sorttrigger", GetTime())
    
    DebugPrint("Secure sort triggered via state-sorttrigger")
    return true
end

-- ============================================================
-- SPECIALIZATION CACHING SYSTEM
-- ============================================================
-- Cache player specs out of combat for melee/ranged DPS distinction
-- Uses inspection API to get spec IDs, maps to detailed roles

-- Get unit name in format suitable for caching (handles cross-realm)
local function GetCacheableName(unit)
    local name = GetUnitName(unit, true)  -- returns "Name-Realm" directly, avoids secret string taint
    return name
end

-- Get detailed role from spec ID (1=Tank, 2=Melee, 3=Healer, 4=Ranged)
function SecureSort:GetSpecRole(specID)
    return SPEC_ROLE[specID] or 0  -- 0 = unknown
end

-- Cache the spec for a unit (called when we get spec info)
function SecureSort:CacheUnitSpec(unit, specID)
    local name = GetCacheableName(unit)
    if not name then return end
    
    local role = self:GetSpecRole(specID)
    if role > 0 then
        self.specCache[name] = {
            specID = specID,
            role = role,  -- 1=Tank, 2=Melee, 3=Healer, 4=Ranged
        }
        -- Spec cached (debug removed - too spammy)
    end
end

-- Get cached spec role for a unit (returns 0 if not cached)
function SecureSort:GetCachedSpecRole(unit)
    local name = GetCacheableName(unit)
    if not name then return 0 end
    
    local cached = self.specCache[name]
    if cached then
        return cached.role
    end
    return 0
end

-- Push cached spec data to secure environment as frame attributes
-- This allows secure code to distinguish melee vs ranged DPS
function SecureSort:PushSpecDataToFrames()
    if InCombatLockdown() then
        self.pendingSpecPush = true
        return false
    end
    
    if not self.handler then return false end
    
    -- For party frames (indices 0-4)
    local partyUnits = {"player", "party1", "party2", "party3", "party4"}
    for i, unit in ipairs(partyUnits) do
        local specRole = 0
        if UnitExists(unit) then
            -- Try to get spec directly first (works for player and inspected units)
            local specID
            if unit == "player" then
                specID = GetSpecializationInfo(GetSpecialization() or 0)
            else
                specID = GetInspectSpecialization(unit)
            end
            
            if specID and specID > 0 then
                self:CacheUnitSpec(unit, specID)
            end
            
            specRole = self:GetCachedSpecRole(unit)
        end
        
        -- Push to handler as frameSpecRole{index} (0-indexed to match frame indices)
        self.handler:SetAttribute("frameSpecRole" .. (i - 1), specRole)
    end
    
    -- Debug removed - too spammy
    return true
end

-- Push cached spec data for raid frames
function SecureSort:PushRaidSpecDataToFrames()
    if InCombatLockdown() then
        self.pendingRaidSpecPush = true
        return false
    end
    
    if not self.handler then return false end
    if not DF.IterateRaidFrames then return false end
    
    local frameIndex = 0
    DF:IterateRaidFrames(function(frame, idx)
        frameIndex = frameIndex + 1
        local specRole = 0
        
        if frame then
            local unit = frame:GetAttribute("unit")
            if unit and UnitExists(unit) then
                specRole = self:GetCachedSpecRole(unit)
            end
        end
        
        self.handler:SetAttribute("raidFrameSpecRole" .. frameIndex, specRole)
    end)
    
    -- Fill remaining slots with 0
    for i = frameIndex + 1, 40 do
        self.handler:SetAttribute("raidFrameSpecRole" .. i, 0)
    end
    
    -- Debug removed - too spammy
    return true
end

-- Queue a unit for inspection (to get their spec)
function SecureSort:QueueInspect(unit)
    if not UnitExists(unit) then return end
    if not UnitIsPlayer(unit) then return end
    if UnitIsUnit(unit, "player") then return end  -- Don't inspect self
    
    local guid = UnitGUID(unit)
    if not guid then return end
    
    -- Don't queue if already cached
    local name = GetCacheableName(unit)
    if name and self.specCache[name] then return end
    
    -- Add to queue
    self.inspectQueue[guid] = unit
    
    -- Start inspection process if not already running
    if not self.inspectInProgress then
        self:ProcessInspectQueue()
    end
end

-- Process the inspection queue
function SecureSort:ProcessInspectQueue()
    if InCombatLockdown() then
        -- Wait for combat to end
        return
    end
    
    -- Get next unit from queue
    local guid, unit = next(self.inspectQueue)
    if not guid then
        self.inspectInProgress = false
        return
    end
    
    -- Verify unit still exists and matches GUID
    if not UnitExists(unit) or UnitGUID(unit) ~= guid then
        self.inspectQueue[guid] = nil
        C_Timer.After(0.1, function() self:ProcessInspectQueue() end)
        return
    end
    
    -- Check if InspectFrame is open (don't interfere with player inspection)
    if InspectFrame and InspectFrame:IsShown() then
        C_Timer.After(2, function() self:ProcessInspectQueue() end)
        return
    end
    
    self.inspectInProgress = true
    
    -- Request inspection
    NotifyInspect(unit)
    
    -- Wait for result (handled by INSPECT_READY event)
end

-- Debounce party-sort re-runs driven by inspect results. Inspects arrive roughly
-- every 0.5s via ProcessInspectQueue; coalescing into a single sort avoids
-- Hide/Show flicker across all 4 party members' inspects.
function SecureSort:ScheduleInspectDrivenPartySort()
    if self.pendingInspectPartySortTimer then return end
    self.pendingInspectPartySortTimer = C_Timer.NewTimer(0.75, function()
        self.pendingInspectPartySortTimer = nil
        if InCombatLockdown() then
            self.pendingInspectPartySort = true
            return
        end
        if not IsInRaid() and DF.ApplyPartyGroupSorting then
            DF:ApplyPartyGroupSorting()
        end
    end)
end

-- Handle INSPECT_READY event
function SecureSort:OnInspectReady(guid)
    -- Only process if this was an inspect WE initiated (guid is in our queue)
    local unit = self.inspectQueue[guid]
    if not unit then
        -- Not our inspect - don't interfere with user's manual inspection
        return
    end
    
    -- Process our queued inspect
    if UnitExists(unit) and UnitGUID(unit) == guid then
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            self:CacheUnitSpec(unit, specID)
            
            -- Push updated spec data if not in combat
            if not InCombatLockdown() then
                if IsInRaid() then
                    self:PushRaidSpecDataToFrames()
                else
                    self:PushSpecDataToFrames()
                end
                -- Notify FlatRaidFrames to re-sort with updated spec data
                -- Guard: only re-sort if flat mode is actually active (not grouped mode)
                if DF.FlatRaidFrames and DF.FlatRaidFrames.initialized then
                    local rdb = DF:GetRaidDB()
                    if rdb and not rdb.raidUseGroups then
                        DF.FlatRaidFrames:UpdateNameList()
                    else
                        DF:Debug("FLATRAID", "Skipping UpdateNameList from inspect: grouped mode active")
                    end
                end
                -- Re-apply party sorting so melee/ranged classification settles as inspects
                -- complete, instead of waiting for an unrelated roster/combat event.
                -- Debounced: inspects stream in ~0.5s apart, so coalesce into one sort.
                if not IsInRaid() and DF.ApplyPartyGroupSorting then
                    self:ScheduleInspectDrivenPartySort()
                end
            else
                -- Defer FlatRaidFrames re-sort until combat ends
                if DF.FlatRaidFrames and DF.FlatRaidFrames.initialized then
                    local rdb = DF:GetRaidDB()
                    if rdb and not rdb.raidUseGroups then
                        DF.FlatRaidFrames.pendingNameListUpdate = true
                    end
                end
                -- Defer party sort until combat ends
                if not IsInRaid() then
                    self.pendingInspectPartySort = true
                end
            end
        end
    end
    
    -- Remove from queue (only our inspects reach here)
    self.inspectQueue[guid] = nil
    
    -- Clear inspection (safe because this was our inspect)
    ClearInspectPlayer()
    
    -- Process next in queue after a delay
    C_Timer.After(0.5, function() self:ProcessInspectQueue() end)
end

-- Scan current group and queue inspections
function SecureSort:ScanGroupForSpecs()
    if InCombatLockdown() then return end
    
    -- Clear old queue
    wipe(self.inspectQueue)
    
    -- Cache player's own spec
    local playerSpecID = GetSpecializationInfo(GetSpecialization() or 0)
    if playerSpecID then
        self:CacheUnitSpec("player", playerSpecID)
    end
    
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                self:QueueInspect(unit)
            end
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                self:QueueInspect(unit)
            end
        end
    end
end

-- ============================================================
-- RAID SORTING FUNCTIONS
-- ============================================================

-- Push raid sort settings to the secure environment
function SecureSort:PushRaidSortSettings()
    if InCombatLockdown() then
        DebugPrint("Cannot push raid sort settings during combat, deferring")
        self.pendingRaidSettingsPush = true
        return false
    end
    
    if not self.handler then
        DebugPrint("WARNING: Handler not created yet")
        return false
    end
    
    local db = DF:GetRaidDB()
    if not db then
        DebugPrint("WARNING: No raid db for sort settings")
        return false
    end
    
    -- Get role order from settings (same conversion as party)
    local rawRoleOrder = db.sortRoleOrder or {"TANK", "HEALER", "MELEE", "RANGED"}
    local roleOrder = {}
    local damagerPos = nil
    local meleeBeforeRanged = true  -- Default: melee before ranged
    local foundMelee = false
    local foundRanged = false
    
    for i, role in ipairs(rawRoleOrder) do
        if role == "MELEE" then
            if not foundRanged then
                meleeBeforeRanged = true
            end
            foundMelee = true
            if not damagerPos then
                damagerPos = #roleOrder + 1
                roleOrder[damagerPos] = "DAMAGER"
            end
        elseif role == "RANGED" then
            if not foundMelee then
                meleeBeforeRanged = false
            end
            foundRanged = true
            if not damagerPos then
                damagerPos = #roleOrder + 1
                roleOrder[damagerPos] = "DAMAGER"
            end
        else
            roleOrder[#roleOrder + 1] = role
        end
    end
    
    if not damagerPos then
        roleOrder[#roleOrder + 1] = "DAMAGER"
    end
    
    -- Push to handler for raid sorting
    self.handler:SetAttribute("raidRoleOrder1", roleOrder[1] or "TANK")
    self.handler:SetAttribute("raidRoleOrder2", roleOrder[2] or "HEALER")
    self.handler:SetAttribute("raidRoleOrder3", roleOrder[3] or "DAMAGER")
    self.handler:SetAttribute("raidSortEnabled", db.sortEnabled or false)
    self.handler:SetAttribute("raidSortByClass", db.sortByClass or false)
    self.handler:SetAttribute("raidSelfPosition", db.sortSelfPosition or "SORTED")
    self.handler:SetAttribute("raidMeleeBeforeRanged", meleeBeforeRanged)
    self.handler:SetAttribute("raidSortAlphabetical", db.sortAlphabetical or false)
    
    -- Find which raid frame index has the player
    local playerFrameIndex = nil
    if DF.IterateRaidFrames then
        local frameIdx = 0
        DF:IterateRaidFrames(function(frame, idx)
            frameIdx = frameIdx + 1
            if frame then
                local unit = frame:GetAttribute("unit")
                if unit and UnitIsUnit(unit, "player") then
                    playerFrameIndex = frameIdx
                    return true  -- Stop iteration
                end
            end
        end)
    end
    self.handler:SetAttribute("raidPlayerFrameIndex", playerFrameIndex)
    
    -- Push class order
    local defaultClassOrder = {
        "WARRIOR", "PALADIN", "DEATHKNIGHT", "MONK", "DEMONHUNTER",
        "DRUID", "ROGUE", "HUNTER", "SHAMAN", "EVOKER",
        "MAGE", "WARLOCK", "PRIEST"
    }
    local classOrder = db.sortClassOrder or defaultClassOrder
    
    for i, class in ipairs(classOrder) do
        self.handler:SetAttribute("raidClassOrder" .. i, class)
    end
    
    -- Push spec data for melee/ranged distinction
    self:PushRaidSpecDataToFrames()
    
    -- Push unit names for alphabetical sorting
    self:PushRaidUnitNames()
    
    DebugPrint("Raid sort settings pushed: " .. 
        (roleOrder[1] or "?") .. ">" .. (roleOrder[2] or "?") .. ">" .. (roleOrder[3] or "?") ..
        " self=" .. (db.sortSelfPosition or "SORTED") ..
        " class=" .. tostring(db.sortByClass or false) ..
        " alpha=" .. tostring(db.sortAlphabetical or false))
    
    return true
end

-- Push raid unit names for alphabetical sorting
-- Names are stored by frame index (1-40) so secure code can look them up
function SecureSort:PushRaidUnitNames()
    if InCombatLockdown() then
        self.pendingRaidNamesPush = true
        return false
    end
    
    if not self.handler then return false end
    
    local nameCount = 0
    local frameIndex = 0
    
    -- Push names for all raid frames by their frame index
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame, idx)
            frameIndex = frameIndex + 1
            local name = ""
            if frame then
                local unit = frame:GetAttribute("unit")
                if unit and UnitExists(unit) then
                    name = strlower(UnitName(unit) or "")
                    if name ~= "" then
                        nameCount = nameCount + 1
                    end
                end
            end
            self.handler:SetAttribute("raidFrameName" .. frameIndex, name)
        end)
    end
    
    -- Clear remaining slots
    for i = frameIndex + 1, 40 do
        self.handler:SetAttribute("raidFrameName" .. i, "")
    end
    
    DebugPrint("Raid names pushed: " .. nameCount .. " units")
    return true
end

-- Push raid layout config to secure environment
function SecureSort:PushRaidLayoutConfig()
    if InCombatLockdown() then
        DebugPrint("Cannot push raid layout config during combat")
        return false
    end
    
    if not self.handler then
        DebugPrint("WARNING: Handler not created yet")
        return false
    end
    
    -- Update layout params first
    self:UpdateRaidLayoutParams()
    local lp = self.raidLayoutParams
    
    -- Push to secure environment by embedding values directly into the code
    -- This avoids issues with attribute retrieval in SecureHandlerExecute
    local code = string.format([[
        raidLayoutConfig = newtable()
        raidLayoutConfig.frameWidth = %f
        raidLayoutConfig.frameHeight = %f
        raidLayoutConfig.hSpacing = %f
        raidLayoutConfig.vSpacing = %f
        raidLayoutConfig.playersPerRow = %d
        raidLayoutConfig.horizontal = %s
        raidLayoutConfig.gridAnchor = "%s"
        raidLayoutConfig.reverseFill = %s
    ]], 
        lp.frameWidth,
        lp.frameHeight,
        lp.hSpacing,
        lp.vSpacing,
        lp.playersPerRow,
        tostring(lp.horizontal),
        lp.gridAnchor or "START",
        tostring(lp.reverseFill or false)
    )
    
    SecureHandlerExecute(self.handler, code)
    
    DebugPrint("Raid layout config pushed: " .. lp.frameWidth .. "x" .. lp.frameHeight ..
        " ppr=" .. lp.playersPerRow .. " horiz=" .. tostring(lp.horizontal) ..
        " anchor=" .. (lp.gridAnchor or "START"))
    
    return true
end

-- Push raid GROUP layout config to secure environment (for group-based layouts)
function SecureSort:PushRaidGroupLayoutConfig()
    if InCombatLockdown() then
        DebugPrint("Cannot push raid group layout config during combat")
        return false
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready for group layout config")
        return false
    end
    
    -- Update params from current settings
    self:UpdateRaidGroupLayoutParams()
    local lp = self.raidGroupLayoutParams
    
    local db = DF:GetRaidDB()
    local useGroups = db and db.raidUseGroups or false
    
    -- Push to secure environment
    local code = string.format([[
        raidGroupLayoutConfig = newtable()
        raidGroupLayoutConfig.frameWidth = %f
        raidGroupLayoutConfig.frameHeight = %f
        raidGroupLayoutConfig.playerSpacing = %f
        raidGroupLayoutConfig.groupSpacing = %f
        raidGroupLayoutConfig.rowColSpacing = %f
        raidGroupLayoutConfig.groupsPerRowCol = %d
        raidGroupLayoutConfig.horizontal = %s
        raidGroupLayoutConfig.groupAnchor = "%s"
        raidGroupLayoutConfig.playerAnchor = "%s"
        raidGroupLayoutConfig.reverseGroupOrder = %s
        raidUseGroups = %s
    ]], 
        lp.frameWidth,
        lp.frameHeight,
        lp.playerSpacing,
        lp.groupSpacing,
        lp.rowColSpacing,
        lp.groupsPerRowCol,
        tostring(lp.horizontal),
        lp.groupAnchor or "CENTER",
        lp.playerAnchor or "START",
        tostring(lp.reverseGroupOrder or false),
        tostring(useGroups)
    )
    
    SecureHandlerExecute(self.handler, code)
    
    DebugPrint("Raid GROUP layout config pushed: useGroups=" .. tostring(useGroups) ..
        " groupsPerRowCol=" .. lp.groupsPerRowCol)
    
    return true
end

-- Trigger the secure raid sort
function SecureSort:TriggerSecureRaidSort(caller)
    caller = caller or "unknown"
    
    -- Throttle: Don't run more than once per 0.1 seconds
    local now = GetTime()
    if self.lastRaidSortTime and (now - self.lastRaidSortTime) < 0.1 then
        -- Too soon, schedule a delayed sort instead
        if not self.pendingRaidSortTimer then
            self.pendingRaidSortTimer = C_Timer.NewTimer(0.1, function()
                self.pendingRaidSortTimer = nil
                if not InCombatLockdown() and self.raidFramesRegistered then
                    self:TriggerSecureRaidSort("delayed")
                end
            end)
        end
        DebugPrint("TriggerSecureRaidSort THROTTLED (caller=" .. caller .. ")")
        return true
    end
    self.lastRaidSortTime = now
    
    DebugPrint("TriggerSecureRaidSort called (caller=" .. caller .. ")")
    
    if not self.handler then
        DebugPrint("WARNING: Handler not created yet")
        return false
    end
    
    if not self.initialized then
        DebugPrint("WARNING: SecureSort not initialized")
        return false
    end
    
    -- Auto-register raid frames if not done yet
    if not self.raidFramesRegistered then
        -- Check if headers exist
        if DF.raidSeparatedHeaders or (DF.FlatRaidFrames and DF.FlatRaidFrames.header) then
            DebugPrint("Auto-registering raid frames now...")
            self:RegisterRaidFrames()
        else
            DebugPrint("WARNING: Raid headers don't exist yet")
            return false
        end
    end
    
    if not self.raidFramesRegistered then
        DebugPrint("WARNING: Raid frames still not registered after auto-register attempt")
        return false
    end
    
    DebugPrint("All checks passed, triggering raid sort")
    
    if InCombatLockdown() then
        DebugPrint("In combat - raid sorting queued for post-combat")
        self.pendingRaidSort = true
        return true
    end
    
    -- Out of combat: Push both layout configs before triggering
    self:PushRaidLayoutConfig()
    self:PushRaidGroupLayoutConfig()
    
    -- Trigger sort via the state-raidsorttrigger attribute
    self.handler:SetAttribute("state-raidsorttrigger", GetTime())
    
    DebugPrint("Secure raid sort triggered via state-raidsorttrigger")
    return true
end


-- ============================================================
-- TEST SNIPPETS - Phase 0 & 1 Verification
-- ============================================================

function SecureSort:RegisterTestSnippets()
    local handler = self.handler
    if not handler then return end
    
    -- Simple test snippet that just sets a flag
    self:RegisterSnippet("test_basic", [[
        -- Basic test - just set a flag
        _G.testBasicRan = true
        if debugEnabled then
            self:CallMethod("DebugPrint", "test_basic snippet executed!")
        end
    ]])
    
    -- Test snippet that counts party frames (indices 0-4)
    self:RegisterSnippet("test_count_party", [[
        local count = 0
        -- Check player frame at index 0
        if partyFrames[0] then count = count + 1 end
        -- Check party frames at indices 1-4
        for i = 1, 4 do
            if partyFrames[i] then count = count + 1 end
        end
        _G.testPartyCount = count
        if debugEnabled then
            self:CallMethod("DebugPrint", "Counted " .. count .. " party frames (expected 5)")
        end
    ]])
    
    -- Test snippet that validates each party frame
    self:RegisterSnippet("test_party_valid", [[
        local results = ""
        -- Check player frame
        local pf = partyFrames[0]
        if pf then
            local unit = pf:GetAttribute("unit") or "?"
            results = results .. "0:" .. unit .. " "
        else
            results = results .. "0:MISSING "
        end
        -- Check party frames
        for i = 1, 4 do
            local f = partyFrames[i]
            if f then
                local unit = f:GetAttribute("unit") or "?"
                results = results .. i .. ":" .. unit .. " "
            else
                results = results .. i .. ":MISSING "
            end
        end
        _G.testPartyResults = results
        if debugEnabled then
            self:CallMethod("DebugPrint", "Party frames: " .. results)
        end
    ]])
    
    -- Legacy test snippet (for backwards compatibility with Phase 0 tests)
    self:RegisterSnippet("test_count_frames", [[
        local count = 0
        for k, v in pairs(partyFrames) do
            if v then count = count + 1 end
        end
        _G.testFrameCount = count
        if debugEnabled then
            self:CallMethod("DebugPrint", "Counted " .. count .. " party frames")
        end
    ]])
    
    -- Legacy test snippet (for backwards compatibility)
    self:RegisterSnippet("test_frame_valid", [[
        local frame = partyFrames[0]  -- Player frame
        if frame then
            local isVisible = frame:IsVisible()
            local unit = frame:GetAttribute("unit")
            _G.testFrameValid = true
            _G.testFrameUnit = unit or "nil"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Frame valid, unit=" .. (unit or "nil") .. ", visible=" .. tostring(isVisible))
            end
        else
            _G.testFrameValid = false
            if debugEnabled then
                self:CallMethod("DebugPrint", "Frame not found at partyFrames[0]")
            end
        end
    ]])
    
    -- ============================================================
    -- RAID FRAME TEST SNIPPETS (Phase 1)
    -- ============================================================
    
    -- Test snippet that counts raid frames (indices 1-40)
    self:RegisterSnippet("test_count_raid", [[
        local count = 0
        if raidFrames then
            for i = 1, 40 do
                if raidFrames[i] then 
                    count = count + 1 
                end
            end
        end
        _G.testRaidCount = count
        if debugEnabled then
            self:CallMethod("DebugPrint", "Counted " .. count .. " raid frames (expected 40)")
        end
    ]])
    
    -- Test snippet that validates a sample of raid frames (1, 10, 20, 30, 40)
    -- NOTE: Can't use table literals in secure code, so check each index explicitly
    self:RegisterSnippet("test_raid_valid", [[
        local results = ""
        if raidFrames then
            -- Check frame 1
            local f1 = raidFrames[1]
            if f1 then
                results = results .. "1:" .. (f1:GetAttribute("unit") or "?") .. " "
            else
                results = results .. "1:MISSING "
            end
            -- Check frame 10
            local f10 = raidFrames[10]
            if f10 then
                results = results .. "10:" .. (f10:GetAttribute("unit") or "?") .. " "
            else
                results = results .. "10:MISSING "
            end
            -- Check frame 20
            local f20 = raidFrames[20]
            if f20 then
                results = results .. "20:" .. (f20:GetAttribute("unit") or "?") .. " "
            else
                results = results .. "20:MISSING "
            end
            -- Check frame 30
            local f30 = raidFrames[30]
            if f30 then
                results = results .. "30:" .. (f30:GetAttribute("unit") or "?") .. " "
            else
                results = results .. "30:MISSING "
            end
            -- Check frame 40
            local f40 = raidFrames[40]
            if f40 then
                results = results .. "40:" .. (f40:GetAttribute("unit") or "?") .. " "
            else
                results = results .. "40:MISSING "
            end
        else
            results = "raidFrames not found"
        end
        _G.testRaidResults = results
        if debugEnabled then
            self:CallMethod("DebugPrint", "Raid frames (sample): " .. results)
        end
    ]])
    
    -- ============================================================
    -- PHASE 2: POSITION SWAP TEST SNIPPETS
    -- ============================================================
    
    -- Test snippet that reads position of party frame 0 (player)
    self:RegisterSnippet("test_read_position", [[
        local f = partyFrames and partyFrames[0]
        if f then
            local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(1)
            _G.testPositionPoint = point or "nil"
            _G.testPositionX = xOfs or 0
            _G.testPositionY = yOfs or 0
            if debugEnabled then
                self:CallMethod("DebugPrint", "Frame 0 position: " .. (point or "nil") .. " x=" .. (xOfs or "?") .. " y=" .. (yOfs or "?"))
            end
        else
            _G.testPositionPoint = "FRAME_NOT_FOUND"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Frame 0 not found")
            end
        end
    ]])
    
    -- Test snippet that swaps positions of party frames 0 and 1
    -- This is the CRITICAL test - can we SetPoint() in secure code?
    self:RegisterSnippet("test_swap_positions", [[
        local f0 = partyFrames and partyFrames[0]
        local f1 = partyFrames and partyFrames[1]
        
        if not f0 or not f1 then
            _G.testSwapResult = "FRAMES_NOT_FOUND"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Swap failed: frames not found")
            end
            return
        end
        
        -- Read current positions
        local p0, rt0, rp0, x0, y0 = f0:GetPoint(1)
        local p1, rt1, rp1, x1, y1 = f1:GetPoint(1)
        
        if not p0 or not p1 then
            _G.testSwapResult = "NO_POINTS"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Swap failed: no points found")
            end
            return
        end
        
        -- Swap them!
        f0:ClearAllPoints()
        f0:SetPoint(p1, rt1, rp1, x1, y1)
        
        f1:ClearAllPoints()
        f1:SetPoint(p0, rt0, rp0, x0, y0)
        
        _G.testSwapResult = "SUCCESS"
        if debugEnabled then
            self:CallMethod("DebugPrint", "Swap SUCCESS! Frames 0 and 1 swapped positions")
        end
    ]])
    
    -- Test snippet that swaps them BACK (so we can test repeatedly)
    self:RegisterSnippet("test_swap_back", [[
        local f0 = partyFrames and partyFrames[0]
        local f1 = partyFrames and partyFrames[1]
        
        if not f0 or not f1 then
            _G.testSwapResult = "FRAMES_NOT_FOUND"
            return
        end
        
        -- Read current positions (which are swapped)
        local p0, rt0, rp0, x0, y0 = f0:GetPoint(1)
        local p1, rt1, rp1, x1, y1 = f1:GetPoint(1)
        
        if not p0 or not p1 then
            _G.testSwapResult = "NO_POINTS"
            return
        end
        
        -- Swap them back!
        f0:ClearAllPoints()
        f0:SetPoint(p1, rt1, rp1, x1, y1)
        
        f1:ClearAllPoints()
        f1:SetPoint(p0, rt0, rp0, x0, y0)
        
        _G.testSwapResult = "SWAPPED_BACK"
        if debugEnabled then
            self:CallMethod("DebugPrint", "Frames swapped back to original positions")
        end
    ]])
    
    DebugPrint("Test snippets registered")
end

-- ============================================================
-- PHASE 2.5: SLOT-BASED POSITIONING SYSTEM
-- ============================================================
-- This system provides proper slot-based positioning that handles
-- all growth modes (START/CENTER/END) and both orientations
-- (horizontal/vertical). The same formula is used for both secure
-- and insecure (test mode) positioning.

-- ============================================================
-- SHARED POSITION CALCULATION (Insecure Lua)
-- ============================================================
-- This function calculates the offset for a given slot.
-- It's used by both the insecure PositionFrameToSlot() and
-- the secure snippet (which contains the same logic).

-- Calculate the offset for a slot position
-- @param slotIndex: 0-based slot index
-- @param frameCount: total number of visible frames (for CENTER calculation)
-- @param layoutParams: table with frameWidth, frameHeight, spacing, horizontal, growthAnchor
-- @return x, y offsets from container anchor
function SecureSort:CalculateSlotPosition(slotIndex, frameCount, layoutParams)
    local horizontal = layoutParams.horizontal
    local spacing = layoutParams.spacing or 2
    local frameWidth = layoutParams.frameWidth or 80
    local frameHeight = layoutParams.frameHeight or 40
    local growthAnchor = layoutParams.growthAnchor or "START"
    
    -- Calculate stride (distance between frame origins)
    local stride = horizontal and (frameWidth + spacing) or (frameHeight + spacing)
    
    -- Calculate offset based on growth anchor
    -- Note: For all anchors, slot 0 should be visually "first" (left for horizontal, top for vertical)
    -- The anchor determines alignment, NOT the direction of reading order
    local offset
    if growthAnchor == "START" then
        -- Frames aligned to start: slot 0 at offset 0, subsequent slots grow away
        offset = slotIndex * stride
    elseif growthAnchor == "END" then
        -- Frames aligned to end: slot n-1 at offset 0, slot 0 at far end
        -- Visual order is preserved (slot 0 still appears first visually)
        offset = -(frameCount - 1 - slotIndex) * stride
    else -- CENTER
        -- Frames grow from center: positions are centered around 0
        offset = (slotIndex - (frameCount - 1) / 2) * stride
    end
    
    -- Return x, y based on orientation
    if horizontal then
        return offset, 0
    else
        return 0, -offset  -- Negative Y for downward growth
    end
end

-- Get the anchor point based on layout params
-- @return anchor, relativeAnchor for SetPoint
function SecureSort:GetSlotAnchors(layoutParams)
    local horizontal = layoutParams.horizontal
    local growthAnchor = layoutParams.growthAnchor or "START"
    
    if horizontal then
        if growthAnchor == "START" then
            return "LEFT", "LEFT"
        elseif growthAnchor == "END" then
            return "RIGHT", "RIGHT"
        else -- CENTER
            return "CENTER", "CENTER"
        end
    else
        if growthAnchor == "START" then
            return "TOP", "TOP"
        elseif growthAnchor == "END" then
            return "BOTTOM", "BOTTOM"
        else -- CENTER
            return "CENTER", "CENTER"
        end
    end
end

-- ============================================================
-- RAID GRID POSITION CALCULATION (Flat Layout)
-- ============================================================
-- These functions calculate positions for raid frames in a 2D grid layout.
-- Used by both test mode (insecure) and secure code (same formula).

-- Calculate x, y position for a raid frame in a flat grid
-- @param slotIndex: 0-based slot index (0 to frameCount-1)
-- @param frameCount: total number of visible frames
-- @param layoutParams: raid layout configuration containing:
--   - frameWidth, frameHeight: frame dimensions
--   - hSpacing, vSpacing: horizontal and vertical spacing
--   - playersPerRow: number of players per row/column
--   - horizontal: true if primary direction is horizontal
--   - gridAnchor: "START", "CENTER", or "END"
--   - reverseFill: if true, reverse fill order within rows/columns
-- @return x, y offsets from the anchor point
function SecureSort:CalculateRaidSlotPosition(slotIndex, frameCount, layoutParams)
    local frameWidth = layoutParams.frameWidth or 80
    local frameHeight = layoutParams.frameHeight or 35
    local hSpacing = layoutParams.hSpacing or 2
    local vSpacing = layoutParams.vSpacing or 2
    local playersPerRow = layoutParams.playersPerRow or 5
    local horizontal = layoutParams.horizontal

    -- growthAnchor: where the grid is positioned in container (mapped from START/CENTER/END)
    local growthAnchor = layoutParams.growthAnchor or "TOPLEFT"

    -- frameAnchor/columnAnchor: control fill direction within the grid
    -- frameAnchor = "END" reverses the primary fill axis (e.g. right-to-left instead of left-to-right)
    -- columnAnchor = "END" reverses the secondary axis (e.g. bottom-to-top instead of top-to-bottom)
    local frameAnchor = layoutParams.frameAnchor or "START"
    local columnAnchor = layoutParams.columnAnchor or "START"

    -- Calculate row and column for this slot
    local row, col
    if horizontal then
        -- Horizontal: fill columns first (left-to-right), then rows (top-to-bottom)
        row = math.floor(slotIndex / playersPerRow)
        col = slotIndex % playersPerRow
    else
        -- Vertical: fill rows first (top-to-bottom), then columns (left-to-right)
        col = math.floor(slotIndex / playersPerRow)
        row = slotIndex % playersPerRow
    end

    -- Reverse fill direction based on frameAnchor and columnAnchor
    -- In horizontal mode: frameAnchor reverses columns, columnAnchor reverses rows
    -- In vertical mode: frameAnchor reverses rows, columnAnchor reverses columns
    local numCols, numRows
    if horizontal then
        numCols = math.min(playersPerRow, frameCount)
        numRows = math.ceil(frameCount / playersPerRow)
    else
        numRows = math.min(playersPerRow, frameCount)
        numCols = math.ceil(frameCount / playersPerRow)
    end

    if horizontal then
        if frameAnchor == "END" then
            col = (numCols - 1) - col
        end
        if columnAnchor == "END" then
            row = (numRows - 1) - row
        end
    else
        if frameAnchor == "END" then
            row = (numRows - 1) - row
        end
        if columnAnchor == "END" then
            col = (numCols - 1) - col
        end
    end

    local gridWidth = numCols * frameWidth + (numCols - 1) * hSpacing

    -- Calculate position based on growthAnchor
    local x, y

    if growthAnchor == "TOP" then
        -- TOP: Center horizontally, anchor at top
        -- Frames grow down from top, centered horizontally
        local baseX = col * (frameWidth + hSpacing)
        y = -row * (frameHeight + vSpacing)
        -- Offset X to center the grid horizontally
        x = baseX - (gridWidth / 2) + (frameWidth / 2)
    elseif growthAnchor == "CENTER" then
        -- CENTER: Center both horizontally and vertically
        local gridHeight = numRows * frameHeight + (numRows - 1) * vSpacing
        local baseX = col * (frameWidth + hSpacing)
        local baseY = -row * (frameHeight + vSpacing)
        x = baseX - (gridWidth / 2) + (frameWidth / 2)
        y = baseY + (gridHeight / 2) - (frameHeight / 2)
    elseif growthAnchor == "TOPLEFT" then
        -- Anchored at top-left: frames grow right (+x) and down (-y)
        x = col * (frameWidth + hSpacing)
        y = -row * (frameHeight + vSpacing)
    elseif growthAnchor == "TOPRIGHT" then
        -- Anchored at top-right: frames grow left (-x) and down (-y)
        x = -col * (frameWidth + hSpacing)
        y = -row * (frameHeight + vSpacing)
    elseif growthAnchor == "BOTTOMLEFT" then
        -- Anchored at bottom-left: frames grow right (+x) and up (+y)
        x = col * (frameWidth + hSpacing)
        y = row * (frameHeight + vSpacing)
    elseif growthAnchor == "BOTTOMRIGHT" then
        -- Anchored at bottom-right: frames grow left (-x) and up (+y)
        x = -col * (frameWidth + hSpacing)
        y = row * (frameHeight + vSpacing)
    else
        -- Default to TOPLEFT
        x = col * (frameWidth + hSpacing)
        y = -row * (frameHeight + vSpacing)
    end

    return x, y
end

-- Get anchor points for raid grid layout
-- @param layoutParams: layout configuration with growthAnchor
-- @return anchor, relativeAnchor for SetPoint
function SecureSort:GetRaidSlotAnchors(layoutParams)
    -- growthAnchor determines WHERE the grid is positioned in the container
    -- We use the same anchor for both frame and container
    local growthAnchor = layoutParams.growthAnchor or "TOPLEFT"
    return growthAnchor, growthAnchor
end

-- ============================================================
-- INSECURE POSITIONING (for Test Mode)
-- ============================================================
-- These functions position frames directly using regular SetPoint().
-- Used when NOT in combat and for test mode frames.

-- Position a single frame to a slot (insecure - for test mode)
-- @param frame: the frame to position
-- @param slotIndex: 0-based slot index
-- @param frameCount: total visible frame count
-- @param layoutParams: layout configuration
-- @param container: the container frame to anchor to
function SecureSort:PositionFrameToSlot(frame, slotIndex, frameCount, layoutParams, container)
    if not frame or not container then
        DebugPrint("ERROR: PositionFrameToSlot - frame or container is nil")
        return false
    end
    
    local x, y = self:CalculateSlotPosition(slotIndex, frameCount, layoutParams)
    local anchor, relativeAnchor = self:GetSlotAnchors(layoutParams)
    
    frame:ClearAllPoints()
    frame:SetPoint(anchor, container, relativeAnchor, x, y)
    
    DebugPrint("Positioned frame to slot " .. slotIndex .. " at (" .. x .. ", " .. y .. ")")
    return true
end

-- Position all frames in a list to slots (insecure - for test mode)
-- @param frames: array of frames in desired order
-- @param layoutParams: layout configuration
-- @param container: the container frame
function SecureSort:PositionAllFramesToSlots(frames, layoutParams, container)
    if not frames or not container then
        DebugPrint("ERROR: PositionAllFramesToSlots - frames or container is nil")
        return false
    end
    
    local frameCount = #frames
    for i, frame in ipairs(frames) do
        local slotIndex = i - 1  -- Convert to 0-based
        self:PositionFrameToSlot(frame, slotIndex, frameCount, layoutParams, container)
    end
    
    DebugPrint("Positioned " .. frameCount .. " frames to slots")
    return true
end

-- ============================================================
-- RAID INSECURE POSITIONING (for Test Mode)
-- ============================================================
-- Position raid frames using the grid calculation functions.
-- Used for test mode where we don't need secure code.

-- Position a single raid frame to a grid slot (insecure - for test mode)
-- @param frame: the frame to position
-- @param slotIndex: 0-based slot index
-- @param frameCount: total visible frame count
-- @param layoutParams: raid layout configuration
-- @param container: the container frame to anchor to
-- @return true if positioned, false if skipped (no change needed)
function SecureSort:PositionRaidFrameToSlot(frame, slotIndex, frameCount, layoutParams, container)
    if not frame or not container then
        return false
    end
    
    local x, y = self:CalculateRaidSlotPosition(slotIndex, frameCount, layoutParams)
    local anchor, relativeAnchor = self:GetRaidSlotAnchors(layoutParams)
    
    -- Optimization: Check if frame is already at this position
    local currentAnchor, currentRelTo, currentRelAnchor, currentX, currentY = frame:GetPoint(1)
    if currentAnchor == anchor and currentRelAnchor == relativeAnchor 
       and currentX and currentY
       and math.abs(currentX - x) < 0.5 and math.abs(currentY - y) < 0.5 then
        -- Frame is already in position, skip
        return false
    end
    
    frame:ClearAllPoints()
    frame:SetPoint(anchor, container, relativeAnchor, x, y)
    
    return true
end

-- Position all visible raid frames to grid slots (insecure - for test mode)
-- @param frameCount: number of visible frames to position
-- @param layoutParams: raid layout configuration
-- @param container: the container frame
-- @return number of frames actually moved
function SecureSort:PositionAllRaidFramesToSlots(frameCount, layoutParams, container)
    if not container then
        DebugPrint("ERROR: PositionAllRaidFramesToSlots - container is nil")
        return 0
    end
    
    if not DF.IterateRaidFrames then
        return 0
    end
    
    local moved = 0
    local frameIndex = 0
    DF:IterateRaidFrames(function(frame, idx)
        frameIndex = frameIndex + 1
        if frameIndex > frameCount then return true end  -- Stop iteration
        
        if frame and frame:IsShown() then
            local slotIndex = frameIndex - 1  -- Convert to 0-based
            if self:PositionRaidFrameToSlot(frame, slotIndex, frameCount, layoutParams, container) then
                moved = moved + 1
            end
        end
    end)
    
    if moved > 0 then
        DebugPrint("Positioned " .. moved .. "/" .. frameCount .. " raid frames")
    end
    return moved
end

-- ============================================================
-- LAYOUT PARAMETERS
-- ============================================================
-- Store current layout parameters for secure code access

SecureSort.layoutParams = {
    frameWidth = 80,
    frameHeight = 40,
    spacing = 2,
    horizontal = false,  -- Default vertical
    growthAnchor = "START",
}

-- Update layout parameters from DF settings
function SecureSort:UpdateLayoutParams(mode)
    mode = mode or "party"  -- Default to party
    local db = DF:GetDB(mode)
    if not db then
        DebugPrint("WARNING: No db for mode '" .. mode .. "', using defaults")
        return
    end
    
    self.layoutParams = {
        frameWidth = db.frameWidth or 80,
        frameHeight = db.frameHeight or 40,
        spacing = db.frameSpacing or 2,
        horizontal = db.growDirection == "HORIZONTAL",
        growthAnchor = db.growthAnchor or "START",
    }
    
    -- Apply pixel-perfect adjustments if enabled
    if db.pixelPerfect and DF.PixelPerfect then
        self.layoutParams.frameWidth = DF:PixelPerfect(self.layoutParams.frameWidth)
        self.layoutParams.frameHeight = DF:PixelPerfect(self.layoutParams.frameHeight)
        self.layoutParams.spacing = DF:PixelPerfect(self.layoutParams.spacing)
    end
    
    -- Debug removed - too spammy
    
    -- Push to secure environment (out of combat only)
    if not InCombatLockdown() then
        self:SetLayoutParamsSecure()
        self:UpdateLayoutParamsOnButtons()  -- Also update combat buttons
        self:PushSortSettings()              -- Push sort settings (role order, self position)
        -- Note: We no longer pre-cache role data. The secure code queries roles fresh each sort.
    end
end

-- Push layout parameters to secure environment
function SecureSort:SetLayoutParamsSecure()
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot set layout params during combat")
        return false
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready")
        return false
    end
    
    local lp = self.layoutParams
    
    -- Set individual values in secure environment
    self:SetSecurePath(lp.frameWidth, "layoutConfig", "frameWidth")
    self:SetSecurePath(lp.frameHeight, "layoutConfig", "frameHeight")
    self:SetSecurePath(lp.spacing, "layoutConfig", "spacing")
    self:SetSecurePath(lp.horizontal, "layoutConfig", "horizontal")
    self:SetSecurePath(lp.growthAnchor, "layoutConfig", "growthAnchor")
    
    -- Debug removed - too spammy
    return true
end

-- ============================================================
-- RAID LAYOUT PARAMETERS (Flat Grid)
-- ============================================================
-- Store current raid layout parameters for test mode and secure code access

SecureSort.raidLayoutParams = {
    frameWidth = 80,
    frameHeight = 35,
    hSpacing = 2,
    vSpacing = 2,
    playersPerRow = 5,
    horizontal = true,  -- Default horizontal (fill left-to-right first)
    gridAnchor = "START",
    reverseFill = false,
}

-- Map simplified growth anchor (START/CENTER/END) to WoW anchor points
-- The mapping depends on orientation (horizontal = Rows, not horizontal = Columns)
-- Rows: START → TOPLEFT, CENTER → CENTER, END → BOTTOMLEFT
-- Columns: START → TOPLEFT, CENTER → CENTER, END → TOPRIGHT
function SecureSort:MapGrowthAnchor(growthAnchor, horizontal)
    if growthAnchor == "START" then
        return "TOPLEFT"
    elseif growthAnchor == "CENTER" then
        return "CENTER"
    elseif growthAnchor == "END" then
        -- End position depends on orientation
        if horizontal then
            -- Rows: End means bottom-left
            return "BOTTOMLEFT"
        else
            -- Columns: End means top-right
            return "TOPRIGHT"
        end
    else
        -- Legacy values or direct anchor points - pass through
        return growthAnchor
    end
end

-- Update raid layout parameters from DF settings
function SecureSort:UpdateRaidLayoutParams()
    local db = DF:GetRaidDB()
    if not db then
        DebugPrint("WARNING: No raid db, using defaults")
        return
    end
    
    local horizontal = db.growDirection == "HORIZONTAL"
    local frameAnchor = db.raidFlatFrameAnchor or "START"
    local columnAnchor = db.raidFlatColumnAnchor or "START"
    
    -- Calculate headerAnchorPoint to match FlatRaidFrames exactly
    local headerAnchorPoint
    if horizontal then
        -- Horizontal: frameAnchor controls left/right, columnAnchor controls top/bottom
        if frameAnchor == "END" then
            headerAnchorPoint = (columnAnchor == "END") and "BOTTOMRIGHT" or "TOPRIGHT"
        else
            headerAnchorPoint = (columnAnchor == "END") and "BOTTOMLEFT" or "TOPLEFT"
        end
    else
        -- Vertical: frameAnchor controls top/bottom, columnAnchor controls left/right
        if frameAnchor == "END" then
            headerAnchorPoint = (columnAnchor == "END") and "BOTTOMRIGHT" or "BOTTOMLEFT"
        else
            headerAnchorPoint = (columnAnchor == "END") and "TOPRIGHT" or "TOPLEFT"
        end
    end
    
    self.raidLayoutParams = {
        frameWidth = db.frameWidth or 80,
        frameHeight = db.frameHeight or 35,
        hSpacing = db.raidFlatHorizontalSpacing or 2,
        vSpacing = db.raidFlatVerticalSpacing or 2,
        playersPerRow = db.raidPlayersPerRow or 5,
        horizontal = horizontal,
        -- FlatRaidFrames-compatible settings
        frameAnchor = frameAnchor,
        columnAnchor = columnAnchor,
        -- Map simplified growthAnchor (START/CENTER/END) to WoW anchor points
        growthAnchor = self:MapGrowthAnchor(db.raidFlatGrowthAnchor or "START", horizontal),
        -- Computed anchor point for frame positioning (matches FlatRaidFrames GetHeaderAnchorPoint)
        headerAnchorPoint = headerAnchorPoint,
    }
    
    -- Apply pixel-perfect adjustments if enabled
    if db.pixelPerfect and DF.PixelPerfect then
        self.raidLayoutParams.frameWidth = DF:PixelPerfect(self.raidLayoutParams.frameWidth)
        self.raidLayoutParams.frameHeight = DF:PixelPerfect(self.raidLayoutParams.frameHeight)
        self.raidLayoutParams.hSpacing = DF:PixelPerfect(self.raidLayoutParams.hSpacing)
        self.raidLayoutParams.vSpacing = DF:PixelPerfect(self.raidLayoutParams.vSpacing)
    end
    
    DebugPrint("Raid layout params updated: " .. 
        self.raidLayoutParams.frameWidth .. "x" .. self.raidLayoutParams.frameHeight .. 
        " hSpacing=" .. self.raidLayoutParams.hSpacing ..
        " vSpacing=" .. self.raidLayoutParams.vSpacing ..
        " playersPerRow=" .. self.raidLayoutParams.playersPerRow ..
        " horizontal=" .. tostring(self.raidLayoutParams.horizontal) ..
        " headerAnchorPoint=" .. self.raidLayoutParams.headerAnchorPoint)
    
    -- Note: Secure environment is updated via PushRaidLayoutConfig() which is called
    -- separately when triggering secure raid sort
end

-- ============================================================
-- RAID GROUP LAYOUT PARAMETERS
-- ============================================================
-- Store current raid GROUP layout parameters for test mode and secure code access

SecureSort.raidGroupLayoutParams = {
    frameWidth = 80,
    frameHeight = 35,
    playerSpacing = 2,           -- Spacing between players within a group
    groupSpacing = 10,           -- Spacing between groups in same row/column
    rowColSpacing = 15,          -- Spacing between rows/columns of groups
    groupsPerRowCol = 2,         -- Number of groups per row (horizontal) or column (vertical)
    horizontal = true,           -- Direction players fill within group (HORIZONTAL = left-to-right)
    groupAnchor = "CENTER",      -- How groups are anchored (START/CENTER/END)
    playerAnchor = "START",      -- How players are anchored within group slot (START/CENTER/END)
    reverseGroupOrder = false,   -- Whether to reverse group order
}

-- Update raid GROUP layout parameters from DF settings
function SecureSort:UpdateRaidGroupLayoutParams()
    local db = DF:GetRaidDB()
    if not db then
        DebugPrint("WARNING: No raid db, using defaults for group layout")
        -- [LEAK-TEST] Early-return case: shared table NOT replaced, stale fields survive.
        if DF.debugLeakTest then
            print(string.format(
                "|cffffa500[DF LEAK-TEST]|r UpdateRaidGroupLayoutParams EARLY RETURN (no db) -- table NOT replaced. Existing testMode=%s",
                tostring(self.raidGroupLayoutParams and self.raidGroupLayoutParams.testMode)
            ))
        end
        return
    end

    -- [LEAK-TEST] About to replace shared table. Capture existing testMode so we can prove
    -- whether fields survive the assignment at the next line.
    if DF.debugLeakTest then
        print(string.format(
            "|cffffa500[DF LEAK-TEST]|r UpdateRaidGroupLayoutParams REPLACING table  old.testMode=%s",
            tostring(self.raidGroupLayoutParams and self.raidGroupLayoutParams.testMode)
        ))
    end

    self.raidGroupLayoutParams = {
        frameWidth = db.frameWidth or 80,
        frameHeight = db.frameHeight or 35,
        playerSpacing = db.frameSpacing or 2,
        groupSpacing = db.raidGroupSpacing or 10,
        rowColSpacing = db.raidRowColSpacing or 15,
        groupsPerRowCol = db.raidGroupsPerRow or 2,
        horizontal = db.growDirection == "HORIZONTAL",
        groupAnchor = db.raidGroupAnchor or "CENTER",
        playerAnchor = db.raidPlayerAnchor or "START",
        reverseGroupOrder = db.raidGroupOrder == "REVERSE",
        groupRowGrowth = db.raidGroupRowGrowth or "START",
    }
    
    -- Apply pixel-perfect adjustments if enabled
    if db.pixelPerfect and DF.PixelPerfect then
        self.raidGroupLayoutParams.frameWidth = DF:PixelPerfect(self.raidGroupLayoutParams.frameWidth)
        self.raidGroupLayoutParams.frameHeight = DF:PixelPerfect(self.raidGroupLayoutParams.frameHeight)
        self.raidGroupLayoutParams.playerSpacing = DF:PixelPerfect(self.raidGroupLayoutParams.playerSpacing)
        self.raidGroupLayoutParams.groupSpacing = DF:PixelPerfect(self.raidGroupLayoutParams.groupSpacing)
        self.raidGroupLayoutParams.rowColSpacing = DF:PixelPerfect(self.raidGroupLayoutParams.rowColSpacing)
    end
    
    DebugPrint("Raid GROUP layout params updated: " .. 
        self.raidGroupLayoutParams.frameWidth .. "x" .. self.raidGroupLayoutParams.frameHeight .. 
        " playerSpacing=" .. self.raidGroupLayoutParams.playerSpacing ..
        " groupSpacing=" .. self.raidGroupLayoutParams.groupSpacing ..
        " rowColSpacing=" .. self.raidGroupLayoutParams.rowColSpacing ..
        " groupsPerRowCol=" .. self.raidGroupLayoutParams.groupsPerRowCol ..
        " horizontal=" .. tostring(self.raidGroupLayoutParams.horizontal))
end

-- Calculate group-based position for a frame
-- @param groupNum: group number (1-8)
-- @param posInGroup: position within group (0-4)
-- @param playersInGroup: actual number of players in this group
-- @param activeGroupList: ordered list of active (non-empty) group numbers
-- @param layoutParams: group layout parameters
-- @return x, y offsets from container TOPLEFT
function SecureSort:CalculateRaidGroupPosition(groupNum, posInGroup, playersInGroup, activeGroupList, layoutParams)
    local lp = layoutParams
    local frameWidth = lp.frameWidth
    local frameHeight = lp.frameHeight
    local playerSpacing = lp.playerSpacing
    local groupSpacing = lp.groupSpacing
    local rowColSpacing = lp.rowColSpacing
    local groupsPerRowCol = lp.groupsPerRowCol
    local horizontal = lp.horizontal
    local groupAnchor = lp.groupAnchor
    local playerAnchor = lp.playerAnchor
    local reverseGroupOrder = lp.reverseGroupOrder
    
    -- Calculate max group dimensions (size of one full group of 5 players)
    local maxGroupWidth, maxGroupHeight
    if horizontal then
        -- In horizontal mode, players stack vertically within group
        maxGroupWidth = frameWidth
        maxGroupHeight = 5 * frameHeight + 4 * playerSpacing
    else
        -- In vertical mode, players stack horizontally within group
        maxGroupWidth = 5 * frameWidth + 4 * playerSpacing
        maxGroupHeight = frameHeight
    end
    
    -- Build row/column structure from active groups
    local numRowsCols
    if horizontal then
        numRowsCols = math.ceil(#activeGroupList / groupsPerRowCol)
    else
        numRowsCols = math.ceil(#activeGroupList / groupsPerRowCol)
    end
    
    -- Find which row/column this group is in, and its position within that row/column
    local groupIndex = 0
    for idx, g in ipairs(activeGroupList) do
        if g == groupNum then
            groupIndex = idx
            break
        end
    end
    
    if groupIndex == 0 then
        -- Group not in active list
        return 0, 0
    end
    
    local rcIndex = math.floor((groupIndex - 1) / groupsPerRowCol) + 1  -- 1-based row/column index
    local posInRC = (groupIndex - 1) % groupsPerRowCol  -- 0-based position within row/column

    -- Calculate groups in this row/column BEFORE any row growth flipping
    local groupsInThisRC = math.min(groupsPerRowCol, #activeGroupList - (rcIndex - 1) * groupsPerRowCol)

    -- Apply row/column growth direction (use full 8-group grid so Row 1 never jumps)
    local fullRowsCols = math.ceil(8 / groupsPerRowCol)
    local groupRowGrowth = lp.groupRowGrowth or "START"
    if groupRowGrowth == "END" then
        rcIndex = fullRowsCols - rcIndex + 1
    end

    -- Apply reverse group order if enabled
    if reverseGroupOrder then
        posInRC = groupsInThisRC - 1 - posInRC
    end
    
    -- Calculate total container dimensions (use full grid when row growth is flipped)
    local effectiveRowsCols = groupRowGrowth == "END" and fullRowsCols or numRowsCols
    local totalWidth, totalHeight
    local maxCols = horizontal and groupsPerRowCol or effectiveRowsCols
    local maxRows = horizontal and effectiveRowsCols or groupsPerRowCol
    
    if horizontal then
        totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * groupSpacing
        totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * rowColSpacing
    else
        totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * rowColSpacing
        totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * groupSpacing
    end
    
    -- Calculate row/column container position
    local rcWidth, rcHeight
    if horizontal then
        rcWidth = groupsInThisRC * maxGroupWidth + (groupsInThisRC - 1) * groupSpacing
        rcHeight = maxGroupHeight
    else
        rcWidth = maxGroupWidth
        rcHeight = groupsInThisRC * maxGroupHeight + (groupsInThisRC - 1) * groupSpacing
    end
    
    local rcX, rcY = 0, 0
    if horizontal then
        rcY = -(rcIndex - 1) * (maxGroupHeight + rowColSpacing)
        -- groupAnchor controls horizontal alignment of the row
        if groupAnchor == "START" then
            rcX = 0
        elseif groupAnchor == "CENTER" then
            rcX = (totalWidth - rcWidth) / 2
        else -- END
            rcX = totalWidth - rcWidth
        end
    else
        rcX = (rcIndex - 1) * (maxGroupWidth + rowColSpacing)
        -- groupAnchor controls vertical alignment of the column
        if groupAnchor == "START" then
            rcY = 0
        elseif groupAnchor == "CENTER" then
            rcY = -(totalHeight - rcHeight) / 2
        else -- END
            rcY = -(totalHeight - rcHeight)
        end
    end
    
    -- Calculate actual group dimensions (based on actual player count)
    local actualGroupWidth, actualGroupHeight
    if horizontal then
        actualGroupWidth = frameWidth
        actualGroupHeight = playersInGroup * frameHeight + (playersInGroup - 1) * playerSpacing
    else
        actualGroupWidth = playersInGroup * frameWidth + (playersInGroup - 1) * playerSpacing
        actualGroupHeight = frameHeight
    end
    
    -- Calculate group position within its row/column slot
    local groupX, groupY = 0, 0
    if horizontal then
        -- Group slot position (horizontal offset in row)
        groupX = posInRC * (maxGroupWidth + groupSpacing)
        -- playerAnchor controls vertical alignment within group slot
        if playerAnchor == "START" then
            groupY = 0
        elseif playerAnchor == "CENTER" then
            groupY = -(maxGroupHeight - actualGroupHeight) / 2
        else -- END
            groupY = -(maxGroupHeight - actualGroupHeight)
        end
    else
        -- Group slot position (vertical offset in column)
        groupY = -posInRC * (maxGroupHeight + groupSpacing)
        -- playerAnchor controls horizontal alignment within group slot
        if playerAnchor == "START" then
            groupX = 0
        elseif playerAnchor == "CENTER" then
            groupX = (maxGroupWidth - actualGroupWidth) / 2
        else -- END
            groupX = maxGroupWidth - actualGroupWidth
        end
    end
    
    -- Calculate frame position within group
    -- Frames are always in order (first at top/left of the group's actual content)
    -- groupX/groupY already positions the group content at START/CENTER/END of slot
    local frameOffsetX, frameOffsetY
    if horizontal then
        frameOffsetX = 0
        frameOffsetY = -posInGroup * (frameHeight + playerSpacing)
    else
        frameOffsetX = posInGroup * (frameWidth + playerSpacing)
        frameOffsetY = 0
    end
    
    -- Final position
    local finalX = rcX + groupX + frameOffsetX
    local finalY = rcY + groupY + frameOffsetY
    
    return finalX, finalY
end

-- Calculate container size for group-based layout
-- @param activeGroupCount: number of active (non-empty) groups
-- @param layoutParams: group layout parameters
-- @return totalWidth, totalHeight
function SecureSort:CalculateRaidGroupContainerSize(activeGroupCount, layoutParams)
    local lp = layoutParams
    local frameWidth = lp.frameWidth
    local frameHeight = lp.frameHeight
    local playerSpacing = lp.playerSpacing
    local groupSpacing = lp.groupSpacing
    local rowColSpacing = lp.rowColSpacing
    local groupsPerRowCol = lp.groupsPerRowCol
    local horizontal = lp.horizontal
    
    -- Calculate max group dimensions
    local maxGroupWidth, maxGroupHeight
    if horizontal then
        maxGroupWidth = frameWidth
        maxGroupHeight = 5 * frameHeight + 4 * playerSpacing
    else
        maxGroupWidth = 5 * frameWidth + 4 * playerSpacing
        maxGroupHeight = frameHeight
    end
    
    -- Calculate grid dimensions for 8 groups (fixed, so dragging works)
    local totalGroups = 8
    local numRowsCols = math.ceil(totalGroups / groupsPerRowCol)
    local maxCols = horizontal and groupsPerRowCol or numRowsCols
    local maxRows = horizontal and numRowsCols or groupsPerRowCol
    
    local totalWidth, totalHeight
    if horizontal then
        totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * groupSpacing
        totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * rowColSpacing
    else
        totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * rowColSpacing
        totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * groupSpacing
    end
    
    return totalWidth, totalHeight
end

-- Position a raid frame using group-based layout
-- @param frame: the frame to position
-- @param groupNum: which group (1-8) this frame belongs to
-- @param posInGroup: position within the group (0-4)
-- @param playersInGroup: how many players are in this group
-- @param activeGroupList: ordered list of active group numbers
-- @param layoutParams: group layout parameters
-- @param container: the container frame
-- @return true if frame was moved, false if already in position
function SecureSort:PositionRaidFrameToGroupSlot(frame, groupNum, posInGroup, playersInGroup, activeGroupList, layoutParams, container)
    -- [LEAK-TEST] Instrumentation: per-call visibility into which frames use this function
    -- and whether the testMode flag leaks onto the shared table. Toggle:
    --   /run DandersFrames.debugLeakTest = true
    if DF.debugLeakTest then
        local frameName = (frame and frame.GetName and frame:GetName()) or "?"
        local containerName = (container and container.GetName and container:GetName()) or "?"
        local isTestFrame = frame and frame.dfIsTestFrame and true or false
        print(string.format(
            "|cffffa500[DF LEAK-TEST]|r PositionRaidFrameToGroupSlot frame=%s container=%s dfIsTestFrame=%s lp.testMode=%s DF.raidTestMode=%s",
            tostring(frameName),
            tostring(containerName),
            tostring(isTestFrame),
            tostring(layoutParams and layoutParams.testMode),
            tostring(DF.raidTestMode)
        ))
    end

    if not frame or not container then
        return false
    end
    
    local x, y = self:CalculateRaidGroupPosition(groupNum, posInGroup, playersInGroup, activeGroupList, layoutParams)
    
    -- Optimization: Check if frame is already at this position
    local currentAnchor, currentRelTo, currentRelAnchor, currentX, currentY = frame:GetPoint(1)
    if currentAnchor == "TOPLEFT" and currentRelAnchor == "TOPLEFT" 
       and currentX and currentY
       and math.abs(currentX - x) < 0.5 and math.abs(currentY - y) < 0.5 then
        return false
    end
    
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)
    
    return true
end

-- Register the container frame with secure environment
function SecureSort:RegisterContainer(container, name)
    if not container then
        DebugPrint("ERROR: Container is nil")
        return false
    end
    
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot register container during combat")
        return false
    end
    
    name = name or "partyContainer"
    self:SetSecurePath(container, "containers", name)
    
    -- Also set as frame ref on handler for direct access
    SecureHandlerSetFrameRef(self.handler, name, container)
    
    DebugPrint("Registered container: " .. name)
    return true
end

-- ============================================================
-- PHASE 2.5 SECURE SNIPPETS
-- ============================================================

function SecureSort:RegisterPhase25Snippets()
    local handler = self.handler
    if not handler then return end
    
    DebugPrint("Registering Phase 2.5 snippets...")
    
    -- Snippet to position a specific frame to a specific slot
    -- Uses layoutConfig from secure environment
    -- Frame index and slot index are passed via attributes
    self:RegisterSnippet("position_frame_to_slot", [[
        -- Get parameters from attributes
        local frameIndex = self:GetAttribute("posFrameIndex") or 0
        local slotIndex = self:GetAttribute("posSlotIndex") or 0
        local frameCount = self:GetAttribute("posFrameCount") or 5
        
        -- Get layout config
        local lc = layoutConfig
        if not lc then
            _G.positionResult = "NO_LAYOUT_CONFIG"
            return
        end
        
        local frameWidth = lc.frameWidth or 80
        local frameHeight = lc.frameHeight or 40
        local spacing = lc.spacing or 2
        local horizontal = lc.horizontal
        local growthAnchor = lc.growthAnchor or "START"
        
        -- Get the frame
        local frame = partyFrames and partyFrames[frameIndex]
        if not frame then
            _G.positionResult = "FRAME_NOT_FOUND"
            return
        end
        
        -- Get the container from the frame's current anchor
        -- (frames should already be parented/anchored to the container)
        local _, container = frame:GetPoint(1)
        if not container then
            -- Fallback: use the frame's parent
            container = frame:GetParent()
        end
        if not container then
            _G.positionResult = "CONTAINER_NOT_FOUND"
            return
        end
        
        -- Calculate stride
        local stride
        if horizontal then
            stride = frameWidth + spacing
        else
            stride = frameHeight + spacing
        end
        
        -- Calculate offset based on growth anchor
        -- For END: slot 0 at far end, slot n-1 at anchor (preserves visual order)
        local offset
        if growthAnchor == "START" then
            offset = slotIndex * stride
        elseif growthAnchor == "END" then
            offset = -(frameCount - 1 - slotIndex) * stride
        else
            -- CENTER: position around center
            offset = (slotIndex - (frameCount - 1) / 2) * stride
        end
        
        -- Determine anchor points
        local anchor, relAnchor
        if horizontal then
            if growthAnchor == "START" then
                anchor = "LEFT"
                relAnchor = "LEFT"
            elseif growthAnchor == "END" then
                anchor = "RIGHT"
                relAnchor = "RIGHT"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        else
            if growthAnchor == "START" then
                anchor = "TOP"
                relAnchor = "TOP"
            elseif growthAnchor == "END" then
                anchor = "BOTTOM"
                relAnchor = "BOTTOM"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        end
        
        -- Calculate x, y
        local x, y
        if horizontal then
            x = offset
            y = 0
        else
            x = 0
            y = -offset
        end
        
        -- Apply position!
        frame:ClearAllPoints()
        frame:SetPoint(anchor, container, relAnchor, x, y)
        
        _G.positionResult = "SUCCESS"
        _G.positionX = x
        _G.positionY = y
        
        if debugEnabled then
            self:CallMethod("DebugPrint", "Positioned frame " .. frameIndex .. " to slot " .. slotIndex .. " at (" .. x .. ", " .. y .. ")")
        end
    ]])
    
    -- ============================================================
    -- ██████╗  ██████╗     ███╗   ██╗ ██████╗ ████████╗
    -- ██╔══██╗██╔═══██╗    ████╗  ██║██╔═══██╗╚══██╔══╝
    -- ██║  ██║██║   ██║    ██╔██╗ ██║██║   ██║   ██║   
    -- ██║  ██║██║   ██║    ██║╚██╗██║██║   ██║   ██║   
    -- ██████╔╝╚██████╔╝    ██║ ╚████║╚██████╔╝   ██║   
    -- ╚═════╝  ╚═════╝     ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   
    --  ██████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ███████╗
    -- ██╔════╝██║  ██║██╔══██╗████╗  ██║██╔════╝ ██╔════╝
    -- ██║     ███████║███████║██╔██╗ ██║██║  ███╗█████╗  
    -- ██║     ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══╝  
    -- ╚██████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝███████╗
    --  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
    -- ============================================================
    -- POSITIONING CODE - TESTED AND WORKING AS OF 2025-01-19
    -- This snippet handles all frame positioning logic.
    -- It reads from layoutConfig (set via SetSecurePath) and
    -- sortOrder attributes (set by sortPartyFrames).
    -- 
    -- WORKS CORRECTLY FOR:
    -- - START anchor (top/left alignment)
    -- - CENTER anchor (centered alignment)  
    -- - END anchor (bottom/right alignment)
    -- - Horizontal and vertical orientations
    -- - Any number of visible frames (1-5)
    --
    -- DO NOT MODIFY without extensive testing of all anchor modes!
    -- ============================================================
    
    -- Snippet to position ALL party frames to slots based on a sort order
    -- Sort order is passed as individual attributes (can't use tables easily)
    self:RegisterSnippet("position_all_party_frames", [[
        -- Get layout config
        local lc = layoutConfig
        if not lc then
            _G.positionAllResult = "NO_LAYOUT_CONFIG"
            return
        end
        
        local frameWidth = lc.frameWidth or 80
        local frameHeight = lc.frameHeight or 40
        local spacing = lc.spacing or 2
        local horizontal = lc.horizontal
        local growthAnchor = lc.growthAnchor or "START"
        
        -- Get frame count
        local frameCount = self:GetAttribute("posFrameCount") or 5
        
        -- Get container from first frame's anchor (all frames share same container)
        local container = nil
        local firstFrame = partyFrames and partyFrames[0]
        if firstFrame then
            local _, relTo = firstFrame:GetPoint(1)
            container = relTo or firstFrame:GetParent()
        end
        if not container then
            _G.positionAllResult = "CONTAINER_NOT_FOUND"
            return
        end
        
        -- Calculate stride
        local stride
        if horizontal then
            stride = frameWidth + spacing
        else
            stride = frameHeight + spacing
        end
        
        -- Determine anchor points
        local anchor, relAnchor
        if horizontal then
            if growthAnchor == "START" then
                anchor = "LEFT"
                relAnchor = "LEFT"
            elseif growthAnchor == "END" then
                anchor = "RIGHT"
                relAnchor = "RIGHT"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        else
            if growthAnchor == "START" then
                anchor = "TOP"
                relAnchor = "TOP"
            elseif growthAnchor == "END" then
                anchor = "BOTTOM"
                relAnchor = "BOTTOM"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        end
        
        -- Position each frame
        -- Sort order: slot 0 gets frame at sortOrder0, slot 1 gets frame at sortOrder1, etc.
        local positioned = 0
        local skipped = 0
        for slot = 0, frameCount - 1 do
            local frameIndex = self:GetAttribute("sortOrder" .. slot)
            if frameIndex ~= nil then
                local frame = partyFrames and partyFrames[frameIndex]
                if frame then
                    -- Calculate offset for this slot
                    -- For END: slot 0 at far end, slot n-1 at anchor (preserves visual order)
                    local offset
                    if growthAnchor == "START" then
                        offset = slot * stride
                    elseif growthAnchor == "END" then
                        offset = -(frameCount - 1 - slot) * stride
                    else
                        offset = (slot - (frameCount - 1) / 2) * stride
                    end
                    
                    -- Calculate x, y
                    local x, y
                    if horizontal then
                        x = offset
                        y = 0
                    else
                        x = 0
                        y = -offset
                    end
                    
                    -- Optimization: Check if frame is already at this position
                    local needsMove = true
                    local curAnchor, curRelTo, curRelAnchor, curX, curY = frame:GetPoint(1)
                    if curAnchor == anchor and curRelAnchor == relAnchor and curX and curY then
                        local dx = curX - x
                        local dy = curY - y
                        if dx < 0.5 and dx > -0.5 and dy < 0.5 and dy > -0.5 then
                            needsMove = false
                            skipped = skipped + 1
                        end
                    end
                    
                    -- Apply position only if needed
                    if needsMove then
                        frame:ClearAllPoints()
                        frame:SetPoint(anchor, container, relAnchor, x, y)
                        positioned = positioned + 1
                    end
                end
            end
        end
        
        local total = positioned + skipped
        self:CallMethod("DebugPrint", "PARTY POS: " .. positioned .. " moved, " .. skipped .. " skipped (" .. total .. " total)")
        _G.positionAllResult = "SUCCESS"
        _G.positionAllCount = positioned
    ]])
    
    -- ============================================================
    -- RAID GRID POSITIONING SNIPPET
    -- ============================================================
    -- Positions raid frames in a grid layout (rows and columns)
    -- Reads from raidLayoutConfig and raidSortOrder attributes
    -- ============================================================
    self:RegisterSnippet("position_all_raid_frames", [[
        -- Get raid layout config
        local lc = raidLayoutConfig
        if not lc then
            self:CallMethod("DebugPrint", "position_all_raid_frames: NO LAYOUT CONFIG!")
            _G.raidPositionResult = "NO_LAYOUT_CONFIG"
            return
        end
        
        local frameWidth = lc.frameWidth or 80
        local frameHeight = lc.frameHeight or 35
        local hSpacing = lc.hSpacing or 2
        local vSpacing = lc.vSpacing or 2
        local playersPerRow = lc.playersPerRow or 5
        local horizontal = lc.horizontal  -- true = fill left-to-right first
        local gridAnchor = lc.gridAnchor or "START"
        local reverseFill = lc.reverseFill
        
        -- Get frame count
        local frameCount = self:GetAttribute("raidFrameCount") or 0
        if frameCount < 1 then
            _G.raidPositionResult = "NO_FRAMES"
            return
        end
        
        -- Get container from the containers table (set via RegisterContainer)
        local container = containers and containers["raidContainer"]
        if not container then
            self:CallMethod("DebugPrint", "position_all_raid_frames: NO CONTAINER!")
            _G.raidPositionResult = "CONTAINER_NOT_FOUND"
            return
        end
        
        -- Calculate grid dimensions for VISIBLE frames (same as Lua CalculateRaidSlotPosition)
        local numCols, numRows
        if horizontal then
            numCols = playersPerRow
            if numCols > frameCount then numCols = frameCount end
            numRows = math.ceil(frameCount / playersPerRow)
        else
            numRows = playersPerRow
            if numRows > frameCount then numRows = frameCount end
            numCols = math.ceil(frameCount / playersPerRow)
        end
        
        local visibleWidth = numCols * frameWidth + (numCols - 1) * hSpacing
        local visibleHeight = numRows * frameHeight + (numRows - 1) * vSpacing
        
        -- Determine anchor point based on gridAnchor
        local anchor, relAnchor
        if gridAnchor == "START" then
            anchor = "TOPLEFT"
            relAnchor = "TOPLEFT"
        elseif gridAnchor == "CENTER" then
            anchor = "CENTER"
            relAnchor = "CENTER"
        else  -- END
            anchor = "BOTTOMRIGHT"
            relAnchor = "BOTTOMRIGHT"
        end
        
        -- Position each frame using EXACT same math as CalculateRaidSlotPosition
        local positioned = 0
        local skipped = 0
        for slot = 0, frameCount - 1 do
            local frameIdx = self:GetAttribute("raidSortOrder" .. slot)
            if frameIdx then
                local frame = raidFrames and raidFrames[frameIdx]
                if frame then
                    -- Calculate row and col for this slot (same as Lua)
                    local row, col
                    if horizontal then
                        -- Horizontal: fill left-to-right first, then down
                        row = math.floor(slot / playersPerRow)
                        col = slot % playersPerRow
                        if reverseFill then
                            col = (playersPerRow - 1) - col
                        end
                    else
                        -- Vertical: fill top-to-bottom first, then right
                        col = math.floor(slot / playersPerRow)
                        row = slot % playersPerRow
                        if reverseFill then
                            row = (playersPerRow - 1) - row
                        end
                    end
                    
                    -- Calculate position based on anchor (same as Lua CalculateRaidSlotPosition)
                    local x, y
                    if gridAnchor == "START" then
                        -- TOPLEFT anchor: (0,0) is top-left, x increases right, y decreases (negative)
                        x = col * (frameWidth + hSpacing)
                        y = -row * (frameHeight + vSpacing)
                    elseif gridAnchor == "CENTER" then
                        -- CENTER anchor: (0,0) is center of grid
                        local halfGridWidth = visibleWidth / 2
                        local halfGridHeight = visibleHeight / 2
                        x = -halfGridWidth + col * (frameWidth + hSpacing) + frameWidth / 2
                        y = halfGridHeight - row * (frameHeight + vSpacing) - frameHeight / 2
                    else  -- END
                        -- BOTTOMRIGHT anchor: (0,0) is bottom-right
                        x = -col * (frameWidth + hSpacing)
                        y = row * (frameHeight + vSpacing)
                    end
                    
                    -- Optimization: Check if frame is already at this position
                    local needsMove = true
                    local curAnchor, curRelTo, curRelAnchor, curX, curY = frame:GetPoint(1)
                    if curAnchor == anchor and curRelAnchor == relAnchor and curX and curY then
                        local dx = curX - x
                        local dy = curY - y
                        if dx < 0.5 and dx > -0.5 and dy < 0.5 and dy > -0.5 then
                            needsMove = false
                            skipped = skipped + 1
                        end
                    end
                    
                    -- Apply position only if needed
                    if needsMove then
                        frame:ClearAllPoints()
                        frame:SetPoint(anchor, container, relAnchor, x, y)
                        positioned = positioned + 1
                    end
                end
            end
        end
        
        local total = positioned + skipped
        self:CallMethod("DebugPrint", "RAID FLAT POS: " .. positioned .. " moved, " .. skipped .. " skipped (" .. total .. " total)")
        _G.raidPositionResult = "SUCCESS"
        _G.raidPositionCount = positioned
    ]])
    
    -- ============================================================
    -- RAID GROUP-BASED POSITIONING SNIPPET
    -- ============================================================
    -- Positions raid frames in a group-based layout (groups in rows/columns)
    -- Reads from raidGroupLayoutConfig and frame group attributes
    -- ============================================================
    self:RegisterSnippet("position_all_raid_frames_grouped", [[
        self:CallMethod("DebugPrint", "RAID POS GROUPED: Entered")
        
        -- Get group layout config
        local lc = raidGroupLayoutConfig
        if not lc then
            self:CallMethod("DebugPrint", "RAID POS GROUPED: No layout config, falling back to flat")
            -- Fall back to flat positioning if no group config
            local snippets = _snippets
            local flatSnippet = snippets and snippets["position_all_raid_frames"]
            if flatSnippet then
                self:Run(flatSnippet)
            end
            return
        end
        
        local frameWidth = lc.frameWidth or 80
        local frameHeight = lc.frameHeight or 35
        local playerSpacing = lc.playerSpacing or 2
        local groupSpacing = lc.groupSpacing or 10
        local rowColSpacing = lc.rowColSpacing or 15
        local groupsPerRowCol = lc.groupsPerRowCol or 2
        local horizontal = lc.horizontal
        local groupAnchor = lc.groupAnchor or "CENTER"
        local playerAnchor = lc.playerAnchor or "START"
        local reverseGroupOrder = lc.reverseGroupOrder
        
        -- Get frame count
        local frameCount = self:GetAttribute("raidFrameCount") or 0
        self:CallMethod("DebugPrint", "RAID POS GROUPED: frameCount=" .. frameCount)
        if frameCount < 1 then
            return
        end
        
        -- Get container
        local container = containers and containers["raidContainer"]
        if not container then
            return
        end
        
        -- Calculate max group dimensions (5 players per group)
        local maxGroupWidth, maxGroupHeight
        if horizontal then
            maxGroupWidth = frameWidth
            maxGroupHeight = 5 * frameHeight + 4 * playerSpacing
        else
            maxGroupWidth = 5 * frameWidth + 4 * playerSpacing
            maxGroupHeight = frameHeight
        end
        
        -- Build group membership from frame attributes
        -- First pass: determine which groups are active and count players
        local groupPlayerCounts = newtable()  -- groupNum -> count
        local activeGroups = newtable()       -- groupNum -> true
        local activeGroupList = newtable()    -- ordered list
        local frameToGroup = newtable()       -- frameIdx -> groupNum
        
        for slot = 0, frameCount - 1 do
            local frameIdx = self:GetAttribute("raidSortOrder" .. slot)
            if frameIdx then
                local groupNum = self:GetAttribute("raidFrameGroup" .. frameIdx) or 1
                if groupNum == 0 then groupNum = 1 end
                
                frameToGroup[frameIdx] = groupNum
                groupPlayerCounts[groupNum] = (groupPlayerCounts[groupNum] or 0) + 1
                
                if not activeGroups[groupNum] then
                    activeGroups[groupNum] = true
                    -- Insert in sorted order
                    local inserted = false
                    for i = 1, 8 do
                        if activeGroupList[i] == nil then
                            activeGroupList[i] = groupNum
                            inserted = true
                            break
                        elseif activeGroupList[i] > groupNum then
                            -- Shift down
                            for j = 8, i + 1, -1 do
                                activeGroupList[j] = activeGroupList[j - 1]
                            end
                            activeGroupList[i] = groupNum
                            inserted = true
                            break
                        end
                    end
                    if not inserted then
                        activeGroupList[8] = groupNum
                    end
                end
            end
        end
        
        -- Compact activeGroupList
        local compactList = newtable()
        local compactCount = 0
        for i = 1, 8 do
            if activeGroupList[i] then
                compactCount = compactCount + 1
                compactList[compactCount] = activeGroupList[i]
            end
        end
        activeGroupList = compactList
        local activeGroupCount = compactCount
        
        -- Calculate grid dimensions for 8 groups (fixed)
        local totalGroups = 8
        local numRowsCols = math.ceil(totalGroups / groupsPerRowCol)
        local maxCols = horizontal and groupsPerRowCol or numRowsCols
        local maxRows = horizontal and numRowsCols or groupsPerRowCol
        
        local totalWidth, totalHeight
        if horizontal then
            totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * groupSpacing
            totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * rowColSpacing
        else
            totalWidth = maxCols * maxGroupWidth + (maxCols - 1) * rowColSpacing
            totalHeight = maxRows * maxGroupHeight + (maxRows - 1) * groupSpacing
        end
        
        -- Track position within each group
        local groupCurrentPos = newtable()
        
        -- Position each frame
        local positioned = 0
        local skipped = 0
        for slot = 0, frameCount - 1 do
            local frameIdx = self:GetAttribute("raidSortOrder" .. slot)
            if frameIdx then
                local frame = raidFrames and raidFrames[frameIdx]
                local groupNum = frameToGroup[frameIdx] or 1
                
                if frame then
                    -- Get position within group
                    local posInGroup = groupCurrentPos[groupNum] or 0
                    groupCurrentPos[groupNum] = posInGroup + 1
                    
                    local playersInGroup = groupPlayerCounts[groupNum] or 1
                    
                    -- Find group index in activeGroupList
                    local groupIndex = 0
                    for i = 1, activeGroupCount do
                        if activeGroupList[i] == groupNum then
                            groupIndex = i
                            break
                        end
                    end
                    
                    if groupIndex > 0 then
                        -- Calculate which row/column this group is in
                        local rcIndex = math.floor((groupIndex - 1) / groupsPerRowCol) + 1
                        local posInRC = (groupIndex - 1) % groupsPerRowCol
                        
                        -- Apply reverse group order if enabled
                        local groupsInThisRC = math.min(groupsPerRowCol, activeGroupCount - (rcIndex - 1) * groupsPerRowCol)
                        if reverseGroupOrder then
                            posInRC = groupsInThisRC - 1 - posInRC
                        end
                        
                        -- Calculate row/column container dimensions
                        local rcWidth, rcHeight
                        if horizontal then
                            rcWidth = groupsInThisRC * maxGroupWidth + (groupsInThisRC - 1) * groupSpacing
                            rcHeight = maxGroupHeight
                        else
                            rcWidth = maxGroupWidth
                            rcHeight = groupsInThisRC * maxGroupHeight + (groupsInThisRC - 1) * groupSpacing
                        end
                        
                        -- Calculate row/column position
                        local rcX, rcY = 0, 0
                        if horizontal then
                            rcY = -(rcIndex - 1) * (maxGroupHeight + rowColSpacing)
                            if groupAnchor == "START" then
                                rcX = 0
                            elseif groupAnchor == "CENTER" then
                                rcX = (totalWidth - rcWidth) / 2
                            else -- END
                                rcX = totalWidth - rcWidth
                            end
                        else
                            rcX = (rcIndex - 1) * (maxGroupWidth + rowColSpacing)
                            if groupAnchor == "START" then
                                rcY = 0
                            elseif groupAnchor == "CENTER" then
                                rcY = -(totalHeight - rcHeight) / 2
                            else -- END
                                rcY = -(totalHeight - rcHeight)
                            end
                        end
                        
                        -- Calculate actual group dimensions
                        local actualGroupWidth, actualGroupHeight
                        if horizontal then
                            actualGroupWidth = frameWidth
                            actualGroupHeight = playersInGroup * frameHeight + (playersInGroup - 1) * playerSpacing
                        else
                            actualGroupWidth = playersInGroup * frameWidth + (playersInGroup - 1) * playerSpacing
                            actualGroupHeight = frameHeight
                        end
                        
                        -- Calculate group position within row/column
                        local groupX, groupY = 0, 0
                        if horizontal then
                            groupX = posInRC * (maxGroupWidth + groupSpacing)
                            if playerAnchor == "START" then
                                groupY = 0
                            elseif playerAnchor == "CENTER" then
                                groupY = -(maxGroupHeight - actualGroupHeight) / 2
                            else -- END
                                groupY = -(maxGroupHeight - actualGroupHeight)
                            end
                        else
                            groupY = -posInRC * (maxGroupHeight + groupSpacing)
                            if playerAnchor == "START" then
                                groupX = 0
                            elseif playerAnchor == "CENTER" then
                                groupX = (maxGroupWidth - actualGroupWidth) / 2
                            else -- END
                                groupX = maxGroupWidth - actualGroupWidth
                            end
                        end
                        
                        -- Calculate frame position within group
                        local frameOffsetX, frameOffsetY
                        if horizontal then
                            frameOffsetX = 0
                            frameOffsetY = -posInGroup * (frameHeight + playerSpacing)
                        else
                            frameOffsetX = posInGroup * (frameWidth + playerSpacing)
                            frameOffsetY = 0
                        end
                        
                        -- Final position
                        local finalX = rcX + groupX + frameOffsetX
                        local finalY = rcY + groupY + frameOffsetY
                        
                        -- Optimization: Check if frame is already at this position
                        local needsMove = true
                        local curAnchor, curRelTo, curRelAnchor, curX, curY = frame:GetPoint(1)
                        if curAnchor == "TOPLEFT" and curRelAnchor == "TOPLEFT" and curX and curY then
                            local dx = curX - finalX
                            local dy = curY - finalY
                            if dx < 0.5 and dx > -0.5 and dy < 0.5 and dy > -0.5 then
                                needsMove = false
                                skipped = skipped + 1
                            end
                        end
                        
                        -- Apply position only if needed
                        if needsMove then
                            frame:ClearAllPoints()
                            frame:SetPoint("TOPLEFT", container, "TOPLEFT", finalX, finalY)
                            positioned = positioned + 1
                        end
                    end
                end
            end
        end
        
        local total = positioned + skipped
        self:CallMethod("DebugPrint", "RAID POS: " .. positioned .. " moved, " .. skipped .. " skipped (" .. total .. " total)")
        _G.raidPositionResult = "SUCCESS_GROUPED"
        _G.raidPositionCount = positioned
    ]])
    
    -- ============================================================
    -- END OF POSITIONING CODE - DO NOT CHANGE ABOVE
    -- ============================================================
    
    -- Test snippet to verify layout config is set
    self:RegisterSnippet("test_layout_config", [[
        local lc = layoutConfig
        if lc then
            _G.testLayoutWidth = lc.frameWidth or "nil"
            _G.testLayoutHeight = lc.frameHeight or "nil"
            _G.testLayoutSpacing = lc.spacing or "nil"
            _G.testLayoutHorizontal = lc.horizontal and "true" or "false"
            _G.testLayoutAnchor = lc.growthAnchor or "nil"
            _G.testLayoutResult = "OK"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Layout: " .. (lc.frameWidth or "?") .. "x" .. (lc.frameHeight or "?") .. " spacing=" .. (lc.spacing or "?") .. " horiz=" .. tostring(lc.horizontal) .. " anchor=" .. (lc.growthAnchor or "?"))
            end
        else
            _G.testLayoutResult = "NOT_SET"
            if debugEnabled then
                self:CallMethod("DebugPrint", "Layout config not set!")
            end
        end
    ]])
    
    DebugPrint("Phase 2.5 snippets registered")
end

-- ============================================================
-- PHASE 3 SECURE SNIPPETS: Role Detection & Sorting
-- ============================================================
-- These snippets query roles and sort frames in secure code,
-- allowing sorting to work during combat.

function SecureSort:RegisterPhase3Snippets()
    DebugPrint("Registering Phase 3 snippets...")
    
    -- --------------------------------------------------------
    -- Snippet: detect_roles
    -- Queries the roleQueryHeader to detect unit roles.
    -- Stores results in unit2role table in secure environment.
    -- --------------------------------------------------------
    self:RegisterSnippet("detect_roles", [=[
        local rqh = self:GetFrameRef("roleQueryHeader")
        if not rqh then
            _G.detectRolesResult = "NO_ROLE_QUERY_HEADER"
            return
        end
        
        -- Initialize role tables
        if not unit2role then unit2role = newtable() end
        if not role2units then role2units = newtable() end
        
        -- Clear previous data
        for k in pairs(unit2role) do unit2role[k] = nil end
        for k in pairs(role2units) do role2units[k] = nil end
        role2units["TANK"] = newtable()
        role2units["HEALER"] = newtable()
        role2units["DAMAGER"] = newtable()
        
        -- Query TANKS
        rqh:SetAttribute("roleFilter", "TANK")
        for i = 1, 5 do
            local child = rqh:GetAttribute("child" .. i)
            if child then
                local unit = child:GetAttribute("unit")
                if unit then
                    unit2role[unit] = "TANK"
                    local tanks = role2units["TANK"]
                    tanks[#tanks + 1] = unit
                end
            end
        end
        
        -- Query HEALERS
        rqh:SetAttribute("roleFilter", "HEALER")
        for i = 1, 5 do
            local child = rqh:GetAttribute("child" .. i)
            if child then
                local unit = child:GetAttribute("unit")
                if unit then
                    unit2role[unit] = "HEALER"
                    local healers = role2units["HEALER"]
                    healers[#healers + 1] = unit
                end
            end
        end
        
        -- Query DAMAGERS
        rqh:SetAttribute("roleFilter", "DAMAGER")
        for i = 1, 5 do
            local child = rqh:GetAttribute("child" .. i)
            if child then
                local unit = child:GetAttribute("unit")
                if unit then
                    unit2role[unit] = "DAMAGER"
                    local dps = role2units["DAMAGER"]
                    dps[#dps + 1] = unit
                end
            end
        end
        
        -- Clear filter
        rqh:SetAttribute("roleFilter", nil)
        
        _G.detectRolesResult = "OK"
        if debugEnabled then
            self:CallMethod("DebugPrint", "Roles detected in secure code")
        end
    ]=])
    
    -- --------------------------------------------------------
    -- Snippet: secure_sort_frames
    -- Sorts frames based on detected roles and settings.
    -- Uses insertion sort (no table.sort in restricted Lua).
    -- Settings are read from handler attributes.
    -- --------------------------------------------------------
    self:RegisterSnippet("secure_sort_frames", [=[
        -- Role priority from settings (set as attributes)
        local roleOrder = newtable()
        roleOrder[1] = self:GetAttribute("roleOrder1") or "TANK"
        roleOrder[2] = self:GetAttribute("roleOrder2") or "HEALER"
        roleOrder[3] = self:GetAttribute("roleOrder3") or "DAMAGER"
        roleOrder[4] = self:GetAttribute("roleOrder4") or "NONE"
        
        local selfPosition = self:GetAttribute("selfPosition") or "NORMAL"
        local frameCount = self:GetAttribute("sortFrameCount") or 5
        
        -- Build role priority lookup
        local rolePriority = newtable()
        for i, role in ipairs(roleOrder) do
            rolePriority[role] = i
        end
        rolePriority["NONE"] = 100
        
        -- Get frames and their units
        local frameUnits = newtable()  -- frameIndex -> unit
        local frameRoles = newtable()  -- frameIndex -> role priority
        
        for i = 0, frameCount - 1 do
            local frame = partyFrames and partyFrames[i]
            if frame then
                local unit = frame:GetAttribute("unit")
                frameUnits[i] = unit
                if unit and unit2role and unit2role[unit] then
                    frameRoles[i] = rolePriority[unit2role[unit]] or 100
                else
                    frameRoles[i] = 100  -- Unknown role goes last
                end
            else
                frameRoles[i] = 999  -- No frame
            end
        end
        
        -- Build sort order using insertion sort
        local sortOrder = newtable()
        for i = 0, frameCount - 1 do
            sortOrder[i] = i  -- Initial order
        end
        
        -- Insertion sort by role priority
        for i = 1, frameCount - 1 do
            local key = sortOrder[i]
            local keyPriority = frameRoles[key]
            local j = i - 1
            while j >= 0 and frameRoles[sortOrder[j]] > keyPriority do
                sortOrder[j + 1] = sortOrder[j]
                j = j - 1
            end
            sortOrder[j + 1] = key
        end
        
        -- Handle self position
        local playerIndex = nil
        for i = 0, frameCount - 1 do
            if frameUnits[sortOrder[i]] == "player" then
                playerIndex = i
                break
            end
        end
        
        if playerIndex and selfPosition ~= "NORMAL" then
            -- Remove player from current position
            local playerFrame = sortOrder[playerIndex]
            for i = playerIndex, frameCount - 2 do
                sortOrder[i] = sortOrder[i + 1]
            end
            
            if selfPosition == "FIRST" then
                -- Shift all and insert at front
                for i = frameCount - 1, 1, -1 do
                    sortOrder[i] = sortOrder[i - 1]
                end
                sortOrder[0] = playerFrame
            elseif selfPosition == "LAST" then
                sortOrder[frameCount - 1] = playerFrame
            end
        end
        
        -- Store sort order for positioning
        for slot = 0, frameCount - 1 do
            self:SetAttribute("computedSortOrder" .. slot, sortOrder[slot])
        end
        
        _G.secureSortResult = "OK"
        if debugEnabled then
            local msg = "Sort order: "
            for i = 0, frameCount - 1 do
                msg = msg .. sortOrder[i] .. " "
            end
            self:CallMethod("DebugPrint", msg)
        end
    ]=])
    
    -- --------------------------------------------------------
    -- Snippet: apply_sort_positions
    -- Applies the computed sort order to frame positions.
    -- --------------------------------------------------------
    self:RegisterSnippet("apply_sort_positions", [=[
        local lc = layoutConfig
        if not lc then
            _G.applySortResult = "NO_LAYOUT_CONFIG"
            return
        end
        
        local frameWidth = lc.frameWidth or 80
        local frameHeight = lc.frameHeight or 40
        local spacing = lc.spacing or 2
        local horizontal = lc.horizontal
        local growthAnchor = lc.growthAnchor or "START"
        local frameCount = self:GetAttribute("sortFrameCount") or 5
        
        -- Get container
        local container = nil
        local firstFrame = partyFrames and partyFrames[0]
        if firstFrame then
            local _, relTo = firstFrame:GetPoint(1)
            container = relTo or firstFrame:GetParent()
        end
        if not container then
            _G.applySortResult = "NO_CONTAINER"
            return
        end
        
        -- Calculate stride
        local stride = horizontal and (frameWidth + spacing) or (frameHeight + spacing)
        
        -- Determine anchor points
        local anchor, relAnchor
        if horizontal then
            if growthAnchor == "START" then
                anchor = "LEFT"
                relAnchor = "LEFT"
            elseif growthAnchor == "END" then
                anchor = "RIGHT"
                relAnchor = "RIGHT"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        else
            if growthAnchor == "START" then
                anchor = "TOP"
                relAnchor = "TOP"
            elseif growthAnchor == "END" then
                anchor = "BOTTOM"
                relAnchor = "BOTTOM"
            else
                anchor = "CENTER"
                relAnchor = "CENTER"
            end
        end
        
        -- Position each frame according to computed sort order
        local positioned = 0
        for slot = 0, frameCount - 1 do
            local frameIndex = self:GetAttribute("computedSortOrder" .. slot)
            if frameIndex ~= nil then
                local frame = partyFrames and partyFrames[frameIndex]
                if frame then
                    -- Calculate offset for this slot
                    local offset
                    if growthAnchor == "START" then
                        offset = slot * stride
                    elseif growthAnchor == "END" then
                        offset = -(frameCount - 1 - slot) * stride
                    else
                        offset = (slot - (frameCount - 1) / 2) * stride
                    end
                    
                    -- Calculate x, y
                    local x, y
                    if horizontal then
                        x = offset
                        y = 0
                    else
                        x = 0
                        y = -offset
                    end
                    
                    -- Apply position
                    frame:ClearAllPoints()
                    frame:SetPoint(anchor, container, relAnchor, x, y)
                    positioned = positioned + 1
                end
            end
        end
        
        _G.applySortResult = positioned
        if debugEnabled then
            self:CallMethod("DebugPrint", "Applied sort positions: " .. positioned .. " frames")
        end
    ]=])
    
    DebugPrint("Phase 3 snippets registered")
end

-- ============================================================
-- PHASE 2.5 HELPER FUNCTIONS
-- ============================================================

-- Position a frame to a slot using secure code (out of combat)
-- @param frameIndex: index in partyFrames (0-4)
-- @param slotIndex: target slot (0-based)
-- @param frameCount: total visible frames
function SecureSort:SecurePositionFrameToSlot(frameIndex, slotIndex, frameCount)
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot call SecurePositionFrameToSlot during combat")
        return false
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready")
        return false
    end
    
    -- Set attributes
    self.handler:SetAttribute("posFrameIndex", frameIndex)
    self.handler:SetAttribute("posSlotIndex", slotIndex)
    self.handler:SetAttribute("posFrameCount", frameCount or 5)
    
    -- Run the snippet
    self:RunSnippet("position_frame_to_slot")
    
    return true
end

-- Position all party frames using secure code (out of combat)
-- @param sortOrder: array where sortOrder[slot+1] = frameIndex for that slot
-- @param frameCount: total visible frames
function SecureSort:SecurePositionAllFrames(sortOrder, frameCount)
    if InCombatLockdown() then
        DebugPrint("WARNING: Cannot call SecurePositionAllFrames during combat")
        return false
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready")
        return false
    end
    
    -- Set frame count
    self.handler:SetAttribute("posFrameCount", frameCount or #sortOrder)
    
    -- Set sort order as individual attributes
    for slot = 0, (frameCount or #sortOrder) - 1 do
        local frameIndex = sortOrder[slot + 1]  -- Lua 1-based to attribute
        self.handler:SetAttribute("sortOrder" .. slot, frameIndex)
    end
    
    -- Run the snippet
    self:RunSnippet("position_all_party_frames")
    
    return true
end

-- ============================================================
-- SNIPPET EXECUTION
-- ============================================================

function SecureSort:RunSnippet(name)
    local handler = self.handler
    if not handler then
        DebugPrint("ERROR: Handler not created")
        return false
    end
    
    -- Store snippet name using SetAttributeNoHandler
    handler:SetAttributeNoHandler("runSnippet", name)
    
    -- Execute secure code that retrieves and runs the snippet
    SecureHandlerExecute(handler, [[
        local name = self:GetAttribute("runSnippet")
        local snippets = _G["_snippets"]
        local snippet = snippets and snippets[name]
        if snippet then
            -- Run the snippet code
            self:Run(snippet)
        else
            if debugEnabled then
                self:CallMethod("DebugPrint", "Snippet not found: " .. tostring(name))
            end
        end
    ]])
    
    return true
end

-- ============================================================
-- STATUS & DEBUG COMMANDS
-- ============================================================

function SecureSort:GetStatus()
    local status = {
        initialized = self.initialized,
        handlerReady = self.handlerReady,
        handlerExists = self.handler ~= nil,
        debug = self.debug,
        inCombat = InCombatLockdown(),
    }
    
    -- Try to read some values from secure environment
    -- NOTE: SecureHandlerExecute cannot be called during combat!
    if self.handler and not InCombatLockdown() then
        -- Use simple attribute names and SetAttributeNoHandler
        SecureHandlerExecute(self.handler, [[
            self:SetAttribute("secureInit", isInitialized or false)
            self:SetAttribute("secureFrameCount", frameCount or 0)
            self:SetAttribute("testBasicRan", testBasicRan or false)
            self:SetAttribute("testFrameCount", testFrameCount or -1)
            self:SetAttribute("testFrameValid", testFrameValid or false)
            -- Phase 1 party test results
            self:SetAttribute("testPartyCount", testPartyCount or -1)
            self:SetAttribute("testPartyResults", testPartyResults or "")
            -- Phase 1 raid test results
            self:SetAttribute("testRaidCount", testRaidCount or -1)
            self:SetAttribute("testRaidResults", testRaidResults or "")
            -- Phase 2 swap test results
            self:SetAttribute("testSwapResult", testSwapResult or "")
            -- Phase 2.5 layout config test results
            self:SetAttribute("testLayoutResult", testLayoutResult or "")
            self:SetAttribute("testLayoutWidth", testLayoutWidth or -1)
            self:SetAttribute("testLayoutHeight", testLayoutHeight or -1)
            self:SetAttribute("testLayoutSpacing", testLayoutSpacing or -1)
            self:SetAttribute("testLayoutHorizontal", testLayoutHorizontal or "")
            self:SetAttribute("testLayoutAnchor", testLayoutAnchor or "")
            -- Phase 2.5 position results
            self:SetAttribute("positionResult", positionResult or "")
            self:SetAttribute("positionX", positionX or 0)
            self:SetAttribute("positionY", positionY or 0)
            self:SetAttribute("positionAllResult", positionAllResult or "")
            self:SetAttribute("positionAllCount", positionAllCount or 0)
        ]])
        
        status.secureIsInit = self.handler:GetAttribute("secureInit")
        status.secureFrameCount = self.handler:GetAttribute("secureFrameCount")
        status.testBasicRan = self.handler:GetAttribute("testBasicRan")
        status.testFrameCount = self.handler:GetAttribute("testFrameCount")
        status.testFrameValid = self.handler:GetAttribute("testFrameValid")
        -- Phase 1 party test results
        status.testPartyCount = self.handler:GetAttribute("testPartyCount")
        status.testPartyResults = self.handler:GetAttribute("testPartyResults")
        -- Phase 1 raid test results
        status.testRaidCount = self.handler:GetAttribute("testRaidCount")
        status.testRaidResults = self.handler:GetAttribute("testRaidResults")
        -- Phase 2 swap test results
        status.testSwapResult = self.handler:GetAttribute("testSwapResult")
        -- Phase 2.5 layout config test results
        status.testLayoutResult = self.handler:GetAttribute("testLayoutResult")
        status.testLayoutWidth = self.handler:GetAttribute("testLayoutWidth")
        status.testLayoutHeight = self.handler:GetAttribute("testLayoutHeight")
        status.testLayoutSpacing = self.handler:GetAttribute("testLayoutSpacing")
        status.testLayoutHorizontal = self.handler:GetAttribute("testLayoutHorizontal")
        status.testLayoutAnchor = self.handler:GetAttribute("testLayoutAnchor")
        -- Phase 2.5 position results
        status.positionResult = self.handler:GetAttribute("positionResult")
        status.positionX = self.handler:GetAttribute("positionX")
        status.positionY = self.handler:GetAttribute("positionY")
        status.positionAllResult = self.handler:GetAttribute("positionAllResult")
        status.positionAllCount = self.handler:GetAttribute("positionAllCount")
    elseif self.handler and InCombatLockdown() then
        -- During combat, just read cached attribute values (may be stale)
        status.secureIsInit = self.handler:GetAttribute("secureInit")
        status.secureFrameCount = self.handler:GetAttribute("secureFrameCount")
        status.testBasicRan = self.handler:GetAttribute("testBasicRan")
        status.testFrameCount = self.handler:GetAttribute("testFrameCount")
        status.testFrameValid = self.handler:GetAttribute("testFrameValid")
        status.testPartyCount = self.handler:GetAttribute("testPartyCount")
        status.testPartyResults = self.handler:GetAttribute("testPartyResults")
        status.testRaidCount = self.handler:GetAttribute("testRaidCount")
        status.testRaidResults = self.handler:GetAttribute("testRaidResults")
        status.testSwapResult = self.handler:GetAttribute("testSwapResult")
        -- Phase 2.5 values
        status.testLayoutResult = self.handler:GetAttribute("testLayoutResult")
        status.testLayoutWidth = self.handler:GetAttribute("testLayoutWidth")
        status.testLayoutHeight = self.handler:GetAttribute("testLayoutHeight")
        status.testLayoutSpacing = self.handler:GetAttribute("testLayoutSpacing")
        status.testLayoutHorizontal = self.handler:GetAttribute("testLayoutHorizontal")
        status.testLayoutAnchor = self.handler:GetAttribute("testLayoutAnchor")
        status.positionResult = self.handler:GetAttribute("positionResult")
        status.positionX = self.handler:GetAttribute("positionX")
        status.positionY = self.handler:GetAttribute("positionY")
        status.positionAllResult = self.handler:GetAttribute("positionAllResult")
        status.positionAllCount = self.handler:GetAttribute("positionAllCount")
        status.combatLimited = true -- Flag that we couldn't refresh values
    end
    
    return status
end

function SecureSort:PrintStatus()
    print("|cff00ffff========== DF SecureSort Status ==========|r")
    local status = self:GetStatus()
    
    print("|cffaaaaaaModule State:|r")
    print("  initialized:", status.initialized and "|cff00ff00true|r" or "|cffff0000false|r")
    print("  handlerReady:", status.handlerReady and "|cff00ff00true|r" or "|cffff0000false|r")
    print("  handlerExists:", status.handlerExists and "|cff00ff00true|r" or "|cffff0000false|r")
    print("  debug:", status.debug and "|cff00ff00ON|r" or "|cffaaaaaa off|r")
    print("  inCombat:", status.inCombat and "|cffff9900YES|r" or "|cff00ff00no|r")
    
    if status.combatLimited then
        print("|cffff9900  (values may be stale - in combat)|r")
    end
    
    if status.handlerExists then
        print("|cffaaaaaaSecure Environment:|r")
        print("  isInitialized:", status.secureIsInit and "|cff00ff00true|r" or "|cffff0000false|r")
        print("  frameCount:", status.secureFrameCount or "?")
        
        print("|cffaaaaaaPhase 0 Tests:|r")
        print("  test_basic ran:", status.testBasicRan and "|cff00ff00true|r" or "|cffaaaaaa not yet|r")
        
        -- Handle testFrameCount properly (could be nil, -1, or a valid number)
        local frameCountStr
        if status.testFrameCount == nil then
            frameCountStr = "|cffaaaaaa not run|r"
        elseif status.testFrameCount == -1 then
            frameCountStr = "|cffaaaaaa not run|r"
        else
            frameCountStr = "|cff00ff00" .. tostring(status.testFrameCount) .. " frames|r"
        end
        print("  test_count_frames:", frameCountStr)
        
        print("  test_frame_valid:", status.testFrameValid and "|cff00ff00valid|r" or "|cffaaaaaa not valid/not run|r")
        
        -- Phase 1 test results
        print("|cffaaaaaaPhase 1 Tests:|r")
        
        -- Party frames
        local partyCountStr
        if status.testPartyCount == nil or status.testPartyCount == -1 then
            partyCountStr = "|cffaaaaaa not run|r"
        elseif status.testPartyCount == 5 then
            partyCountStr = "|cff00ff00" .. tostring(status.testPartyCount) .. "/5|r"
        else
            partyCountStr = "|cffff9900" .. tostring(status.testPartyCount) .. "/5|r"
        end
        print("  party frames:", partyCountStr)
        
        -- Raid frames
        local raidCountStr
        if status.testRaidCount == nil or status.testRaidCount == -1 then
            raidCountStr = "|cffaaaaaa not run|r"
        elseif status.testRaidCount == 40 then
            raidCountStr = "|cff00ff00" .. tostring(status.testRaidCount) .. "/40|r"
        else
            raidCountStr = "|cffff9900" .. tostring(status.testRaidCount) .. "/40|r"
        end
        print("  raid frames:", raidCountStr)
    end
    
    print("|cff00ffff=============================================|r")
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function SecureSort:Initialize()
    if self.initialized then
        DebugPrint("Already initialized")
        return
    end
    
    DebugPrint("Initializing SecureSort module...")
    
    -- Create the secure handler (includes visible test buttons)
    self:CreateHandler()
    
    -- Register test snippets (Phase 0-2)
    self:RegisterTestSnippets()
    
    -- Register Phase 2.5 snippets (slot-based positioning)
    self:RegisterPhase25Snippets()
    
    -- Register Phase 3 snippets (role detection & sorting)
    self:RegisterPhase3Snippets()
    
    -- Mark as initialized
    self.initialized = true
    
    DebugPrint("SecureSort module initialized successfully")
    
    -- Print status if debug is on
    if self.debug then
        self:PrintStatus()
    end
end

-- ============================================================
-- PHASE 1: FRAME REGISTRATION
-- ============================================================
-- Register frames with the secure handler so they can be
-- accessed and manipulated from secure code during combat.

-- Register party frames (player + party1-4) with secure handler
-- Returns: number of frames registered, or nil on error
function SecureSort:RegisterPartyFrames()
    if not self.initialized then
        DebugPrint("ERROR: SecureSort not initialized")
        return nil
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready")
        return nil
    end
    
    local count = 0
    
    -- Register player frame at index 0
    if DF.playerFrame then
        self:SetSecurePath(DF.playerFrame, "partyFrames", 0)
        count = count + 1
        DebugPrint("Registered playerFrame at partyFrames[0]")
    else
        DebugPrint("WARNING: playerFrame not found")
    end
    
    -- Register party frames at indices 1-4
    for i = 1, 4 do
        local frame = DF.partyFrames and DF.partyFrames[i]
        if frame then
            self:SetSecurePath(frame, "partyFrames", i)
            count = count + 1
            DebugPrint("Registered partyFrame" .. i .. " at partyFrames[" .. i .. "]")
        else
            DebugPrint("WARNING: partyFrame" .. i .. " not found")
        end
    end
    
    -- ALSO set frame refs on the swap buttons for in-combat testing
    -- This allows the buttons to access frames 0 and 1 directly
    if DF.playerFrame and self.swapButton then
        SecureHandlerSetFrameRef(self.swapButton, "frame0", DF.playerFrame)
        DebugPrint("Set frame0 ref on swapButton")
    end
    if DF.partyFrames and DF.partyFrames[1] and self.swapButton then
        SecureHandlerSetFrameRef(self.swapButton, "frame1", DF.partyFrames[1])
        DebugPrint("Set frame1 ref on swapButton")
    end
    
    -- Same for swap back button
    if DF.playerFrame and self.swapBackButton then
        SecureHandlerSetFrameRef(self.swapBackButton, "frame0", DF.playerFrame)
    end
    if DF.partyFrames and DF.partyFrames[1] and self.swapBackButton then
        SecureHandlerSetFrameRef(self.swapBackButton, "frame1", DF.partyFrames[1])
    end
    
    -- ============================================================
    -- PHASE 2.5: Register container and layout params
    -- ============================================================
    
    -- Register party group container (or main container as fallback)
    local container = DF.partyGroupContainer or DF.container
    if container then
        self:RegisterContainer(container, "partyContainer")
        DebugPrint("Registered partyContainer")
    else
        DebugPrint("WARNING: No party container found")
    end
    
    -- Clear raid mode flag for secure hook
    self.handler:SetAttribute("isRaidMode", false)
    
    -- Update and push layout parameters
    self:UpdateLayoutParams()
    
    -- Set frame refs on handler for secure snippet access
    for i = 0, 4 do
        local frame = (i == 0) and DF.playerFrame or (DF.partyFrames and DF.partyFrames[i])
        if frame then
            SecureHandlerSetFrameRef(self.handler, "partyFrame" .. i, frame)
            -- ALSO set "frame0", "frame1", etc. for the sorting snippet
            SecureHandlerSetFrameRef(self.handler, "frame" .. i, frame)
        end
    end
    
    -- Set partyGroupContainer ref on handler for the sorting snippet
    if container then
        SecureHandlerSetFrameRef(self.handler, "partyGroupContainer", container)
        DebugPrint("Set partyGroupContainer ref on handler")
    end
    
    -- ============================================================
    -- PHASE 2.5: Set up combat buttons (Reset and Reverse)
    -- ============================================================
    
    -- Set frame refs on reset button (all 5 frames)
    if self.resetButton then
        for i = 0, 4 do
            local frame = (i == 0) and DF.playerFrame or (DF.partyFrames and DF.partyFrames[i])
            if frame then
                SecureHandlerSetFrameRef(self.resetButton, "frame" .. i, frame)
            end
        end
        DebugPrint("Set frame refs on resetButton")
    end
    
    -- Set frame refs on reverse button (all 5 frames)
    if self.reverseButton then
        for i = 0, 4 do
            local frame = (i == 0) and DF.playerFrame or (DF.partyFrames and DF.partyFrames[i])
            if frame then
                SecureHandlerSetFrameRef(self.reverseButton, "frame" .. i, frame)
            end
        end
        DebugPrint("Set frame refs on reverseButton")
    end
    
    -- Set frame refs on sort button (all 5 frames)
    local sortFrameRefsSet = 0
    if self.sortButton then
        for i = 0, 4 do
            local frame = (i == 0) and DF.playerFrame or (DF.partyFrames and DF.partyFrames[i])
            if frame then
                SecureHandlerSetFrameRef(self.sortButton, "frame" .. i, frame)
                sortFrameRefsSet = sortFrameRefsSet + 1
                
                -- Also push class info for this frame
                local unit = frame:GetAttribute("unit")
                if unit and UnitExists(unit) then
                    local _, class = UnitClass(unit)
                    if class then
                        self.sortButton:SetAttribute("frameClass" .. i, class)
                        -- Also set on handler for in-combat sorting
                        if self.handler then
                            self.handler:SetAttribute("frameClass" .. i, class)
                        end
                        DebugPrint("Set frameClass" .. i .. " = " .. class)
                    end
                end
            end
        end
        DebugPrint("Set " .. sortFrameRefsSet .. " frame refs on sortButton")
    end
    
    -- Set container ref on sort button for positioning
    if self.sortButton and container then
        SecureHandlerSetFrameRef(self.sortButton, "container", container)
        DebugPrint("Set container ref on sortButton")
    end
    
    -- Push layout params to combat buttons
    self:UpdateLayoutParamsOnButtons()
    
    -- Push sort settings (role order, self position)
    self:PushSortSettings()
    
    -- ============================================================
    -- IN-COMBAT SORTING: Hook party frames to auto-sort on changes
    -- ============================================================
    -- This is the key to in-combat sorting! We wrap each party frame's
    -- OnShow and OnAttributeChanged. When someone joins/leaves during
    -- combat, the frame's unit attribute changes and/or show/hide fires.
    -- Our wrapped secure code runs and repositions frames.
    -- Based on SortUnitFrames approach.
    
    if self.handler then
        for i = 0, 4 do
            local frame = (i == 0) and DF.playerFrame or (DF.partyFrames and DF.partyFrames[i])
            if frame then
                -- Wrap OnShow - fires when a frame becomes visible (party member joins)
                -- We trigger via attribute change because sortPartyFrames is only
                -- accessible in the handler's environment, not the frame's
                SecureHandlerWrapScript(frame, "OnShow", self.handler, [[
                    -- Toggle trigger attribute - handler's OnAttributeChanged has access to sortPartyFrames
                    local v = owner:GetAttribute("state-sorttrigger") or 0
                    owner:SetAttribute("state-sorttrigger", 1 - v)
                ]])
                
                -- Wrap OnHide - fires when a frame hides (party member leaves)
                SecureHandlerWrapScript(frame, "OnHide", self.handler, [[
                    -- Toggle trigger attribute - handler's OnAttributeChanged has access to sortPartyFrames
                    local v = owner:GetAttribute("state-sorttrigger") or 0
                    owner:SetAttribute("state-sorttrigger", 1 - v)
                ]])
                
                DebugPrint("Wrapped OnShow/OnHide for in-combat sorting on frame" .. i)
            end
        end
        DebugPrint("In-combat sorting hooks registered on party frames")
    end
    
    -- Note: We no longer pre-cache role data or calculate sort order.
    -- The secure code queries roles fresh each sort using roleFilter.
    
    -- Only mark frames as registered if we actually set frame refs on sort button
    -- This prevents TriggerSecureSort from clicking with invalid refs
    if sortFrameRefsSet > 0 and DF.playerFrame then
        self.framesRegistered = true
        DebugPrint("Party frame registration complete: " .. count .. "/5 frames")
        DebugPrint("Combat buttons ready! In-combat sorting enabled!")
    else
        self.framesRegistered = false
        DebugPrint("WARNING: Could not set frame refs on sortButton (frames not ready)")
    end
    
    return count
end

-- Verify party frames are accessible in secure environment
-- Returns: true if all frames accessible, false otherwise
function SecureSort:VerifyPartyFrames()
    if not self.initialized then
        return false
    end
    
    -- Run the test snippet
    self:RunSnippet("test_count_party")
    
    -- Check results (need small delay for secure code to complete)
    local status = self:GetStatus()
    local expectedCount = 5
    
    if status.testPartyCount == expectedCount then
        DebugPrint("Party frames verified: " .. status.testPartyCount .. "/" .. expectedCount)
        return true
    else
        DebugPrint("Party frame verification FAILED: " .. tostring(status.testPartyCount) .. "/" .. expectedCount)
        return false
    end
end

-- Register raid frames (raid1-40) with secure handler
-- Returns: number of frames registered, or nil on error
function SecureSort:RegisterRaidFrames()
    if not self.initialized then
        DebugPrint("ERROR: SecureSort not initialized")
        return nil
    end
    
    if not self.handler then
        DebugPrint("ERROR: Handler not ready")
        return nil
    end
    
    if InCombatLockdown() then
        DebugPrint("Cannot register raid frames during combat, deferring")
        self.needsRaidResort = true
        return nil
    end
    
    local count = 0
    local frameIndex = 0
    
    -- Register raid frames from headers at indices 1-40 in secure environment
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame, idx)
            frameIndex = frameIndex + 1
            if frameIndex > 40 then return true end  -- Stop at 40 frames
            
            if frame then
                self:SetSecurePath(frame, "raidFrames", frameIndex)
                count = count + 1
                if SecureSort.debug then
                    DebugPrint("Registered raidFrame" .. frameIndex .. " at raidFrames[" .. frameIndex .. "]")
                end
            else
                if SecureSort.debug then
                    DebugPrint("WARNING: raidFrame" .. frameIndex .. " not found")
                end
            end
        end)
        
        -- Set frame refs on handler for secure snippet access
        frameIndex = 0
        DF:IterateRaidFrames(function(frame, idx)
            frameIndex = frameIndex + 1
            if frameIndex > 40 then return true end
            
            if frame then
                SecureHandlerSetFrameRef(self.handler, "raidFrame" .. frameIndex, frame)
            end
        end)
    end
    
    -- Register raid container
    local container = DF.raidContainer
    if container then
        self:RegisterContainer(container, "raidContainer")
        SecureHandlerSetFrameRef(self.handler, "raidContainer", container)
        DebugPrint("Set raidContainer ref on handler")
    else
        DebugPrint("WARNING: No raid container found")
    end
    
    -- Set raid mode flag for secure hook to know which sort to trigger
    self.handler:SetAttribute("isRaidMode", true)
    
    -- Push raid layout config, group layout config, and sort settings
    self:PushRaidLayoutConfig()
    self:PushRaidGroupLayoutConfig()
    self:PushRaidSortSettings()
    
    -- ============================================================
    -- IN-COMBAT SORTING: Hook raid frames to auto-sort on changes
    -- ============================================================
    -- NOTE: We previously wrapped OnShow/OnHide on raid frames to trigger sorting
    -- when raid members join/leave during combat. However, this caused a cascade:
    -- when leaving a raid, all 40 frames would hide, each triggering a sort.
    -- 
    -- GROUP_ROSTER_UPDATE already handles roster changes, and the sortRaidFrames
    -- snippet already handles in-combat scenarios. So we no longer wrap OnShow/OnHide.
    --
    -- In-combat sorting is now handled by:
    -- 1. roleQueryHeader's OnAttributeChanged (child changes)
    -- 2. pendingRaidSort flag processed after combat ends
    
    DebugPrint("Raid frames registered (OnShow/OnHide hooks disabled to prevent cascade)")
    
    self.raidFramesRegistered = true
    DebugPrint("Raid frame registration complete: " .. count .. "/40 frames")
    return count
end

-- Verify raid frames are accessible in secure environment
-- Returns: true if all frames accessible, false otherwise
function SecureSort:VerifyRaidFrames()
    if not self.initialized then
        return false
    end
    
    -- Run the test snippet
    self:RunSnippet("test_count_raid")
    
    -- Check results
    local status = self:GetStatus()
    local expectedCount = 40
    
    if status.testRaidCount == expectedCount then
        DebugPrint("Raid frames verified: " .. status.testRaidCount .. "/" .. expectedCount)
        return true
    else
        DebugPrint("Raid frame verification FAILED: " .. tostring(status.testRaidCount) .. "/" .. expectedCount)
        return false
    end
end

-- Register ALL frames (party + raid) - convenience function
-- Returns: table with partyCount, raidCount
function SecureSort:RegisterAllFrames()
    local results = {
        partyCount = self:RegisterPartyFrames(),
        raidCount = self:RegisterRaidFrames()
    }
    return results
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================

SLASH_DFSECURE1 = "/dfsecure"
SlashCmdList["DFSECURE"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()
    
    if cmd == "status" or cmd == "" then
        SecureSort:PrintStatus()
        
    elseif cmd == "debug" then
        SecureSort.debug = not SecureSort.debug
        -- Also toggle in secure environment
        if SecureSort.handler then
            SecureHandlerExecute(SecureSort.handler, "debugEnabled = " .. tostring(SecureSort.debug))
        end
        print("|cff00ffff[DF SecureSort]|r Debug:", SecureSort.debug and "|cff00ff00ON|r" or "|cffaaaaaaoff|r")
        
    elseif cmd == "init" then
        SecureSort:Initialize()
        print("|cff00ffff[DF SecureSort]|r Initialization complete")
        
    elseif cmd == "test" then
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized! Run /dfsecure init first")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Running tests...")
        
        -- Run test snippets
        SecureSort:RunSnippet("test_basic")
        SecureSort:RunSnippet("test_count_frames")
        SecureSort:RunSnippet("test_frame_valid")
        
        -- Show results
        C_Timer.After(0.1, function()
            SecureSort:PrintStatus()
        end)
        
    elseif cmd == "party" then
        -- Phase 1: Register and verify all party frames
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized! Run /dfsecure init first")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Registering party frames...")
        
        -- Register all party frames
        local count = SecureSort:RegisterPartyFrames()
        if not count then
            print("|cffff0000ERROR:|r Registration failed")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Registered " .. count .. "/5 party frames")
        
        -- Verify they're accessible
        print("|cff00ffff[DF SecureSort]|r Verifying in secure environment...")
        SecureSort:RunSnippet("test_count_party")
        SecureSort:RunSnippet("test_party_valid")
        
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[DF SecureSort]|r Results:")
            print("  Party frame count:", status.testPartyCount and ("|cff00ff00" .. status.testPartyCount .. "/5|r") or "|cffaaaaa not run|r")
            print("  Frame details:", status.testPartyResults or "not run")
            
            if status.testPartyCount == 5 then
                print("|cff00ff00SUCCESS:|r All party frames registered and accessible!")
            else
                print("|cffff9900WARNING:|r Expected 5 frames, got " .. tostring(status.testPartyCount))
            end
        end)
        
    elseif cmd == "raid" then
        -- Phase 1: Register and verify all raid frames
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized! Run /dfsecure init first")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Registering raid frames...")
        
        -- Register all raid frames
        local count = SecureSort:RegisterRaidFrames()
        if not count then
            print("|cffff0000ERROR:|r Registration failed")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Registered " .. count .. "/40 raid frames")
        
        -- Verify they're accessible
        print("|cff00ffff[DF SecureSort]|r Verifying in secure environment...")
        SecureSort:RunSnippet("test_count_raid")
        SecureSort:RunSnippet("test_raid_valid")
        
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            print("|cff00ffff[DF SecureSort]|r Results:")
            print("  Raid frame count:", status.testRaidCount and ("|cff00ff00" .. status.testRaidCount .. "/40|r") or "|cffaaaaa not run|r")
            print("  Frame sample:", status.testRaidResults or "not run")
            
            if status.testRaidCount == 40 then
                print("|cff00ff00SUCCESS:|r All raid frames registered and accessible!")
            else
                print("|cffff9900WARNING:|r Expected 40 frames, got " .. tostring(status.testRaidCount))
            end
        end)
        
    elseif cmd == "all" then
        -- Phase 1: Register ALL frames (party + raid)
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized! Run /dfsecure init first")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r Registering ALL frames...")
        
        local results = SecureSort:RegisterAllFrames()
        
        print("|cff00ffff[DF SecureSort]|r Registered:")
        print("  Party frames:", (results.partyCount or 0) .. "/5")
        print("  Raid frames:", (results.raidCount or 0) .. "/40")
        
        -- Verify
        print("|cff00ffff[DF SecureSort]|r Verifying in secure environment...")
        SecureSort:RunSnippet("test_count_party")
        SecureSort:RunSnippet("test_count_raid")
        
        C_Timer.After(0.1, function()
            local status = SecureSort:GetStatus()
            local partyOK = status.testPartyCount == 5
            local raidOK = status.testRaidCount == 40
            
            print("|cff00ffff[DF SecureSort]|r Verification:")
            print("  Party:", partyOK and "|cff00ff005/5|r" or ("|cffff9900" .. tostring(status.testPartyCount) .. "/5|r"))
            print("  Raid:", raidOK and "|cff00ff0040/40|r" or ("|cffff9900" .. tostring(status.testRaidCount) .. "/40|r"))
            
            if partyOK and raidOK then
                print("|cff00ff00SUCCESS:|r All 45 frames registered and accessible!")
            else
                print("|cffff9900WARNING:|r Some frames missing")
            end
        end)
        
    elseif cmd == "register" then
        -- Legacy: Test registering just player frame (kept for backwards compatibility)
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized!")
            return
        end
        
        -- Try to register player frame if it exists
        if DF.playerFrame then
            SecureSort:SetSecurePath(DF.playerFrame, "partyFrames", 0)
            print("|cff00ffff[DF SecureSort]|r Registered playerFrame at partyFrames[0]")
            
            -- Test it
            SecureSort:RunSnippet("test_frame_valid")
            C_Timer.After(0.1, function()
                local status = SecureSort:GetStatus()
                if status.testFrameValid then
                    print("|cff00ff00SUCCESS:|r Frame is accessible in secure environment!")
                else
                    print("|cffff0000FAILED:|r Frame not accessible")
                end
            end)
        else
            print("|cff00ffff[DF SecureSort]|r playerFrame not found - is DF initialized?")
        end
        
    elseif cmd == "swap" then
        -- Phase 2: Test swapping frame positions
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized! Run /dfsecure init first")
            return
        end
        
        print("|cff00ffff[DF SecureSort]|r |cffff9900[Phase 2]|r Testing position swap...")
        
        if InCombatLockdown() then
            -- IN COMBAT: Must use the visible button!
            print("|cffff9900[COMBAT MODE]|r Cannot call SetAttribute during combat!")
            print("|cff00ffff[DF SecureSort]|r Use: |cffffffff/click DFSecureSwapButton|r")
            print("|cff00ffff[DF SecureSort]|r Or run: |cffffffff/dfsecure showbutton|r and click it!")
            SecureSort:ShowTestButtons()
        else
            -- OUT OF COMBAT: Use direct execution
            print("|cff00ffff[DF SecureSort]|r Swapping player frame (0) and party1 frame (1)...")
            SecureSort:RunSnippet("test_swap_positions")
            
            C_Timer.After(0.1, function()
                local swapStatus = SecureSort:GetStatus()
                if swapStatus.testSwapResult == "SUCCESS" then
                    print("|cff00ff00SUCCESS:|r Frames swapped! Look at your frames - they should be in different positions.")
                    print("|cff00ffff[DF SecureSort]|r Run |cffffffff/dfsecure swapback|r to swap them back.")
                else
                    print("|cffff0000FAILED:|r Swap result: " .. tostring(swapStatus.testSwapResult))
                end
            end)
        end
        
    elseif cmd == "swapback" then
        -- Phase 2: Swap frames back to original positions
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized!")
            return
        end
        
        if InCombatLockdown() then
            print("|cffff9900[COMBAT MODE]|r Use: |cffffffff/click DFSecureSwapBackButton|r")
            SecureSort:ShowTestButtons()
        else
            print("|cff00ffff[DF SecureSort]|r Swapping frames back...")
            SecureSort:RunSnippet("test_swap_back")
            
            C_Timer.After(0.1, function()
                local swapStatus = SecureSort:GetStatus()
                if swapStatus.testSwapResult == "SWAPPED_BACK" then
                    print("|cff00ff00SUCCESS:|r Frames swapped back to original positions!")
                else
                    print("|cffff9900Result:|r " .. tostring(swapStatus.testSwapResult))
                end
            end)
        end
        
    elseif cmd == "showbutton" or cmd == "show" then
        -- Show the test buttons for combat testing
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized!")
            return
        end
        SecureSort:ShowTestButtons()
        
    elseif cmd == "hidebutton" or cmd == "hide" then
        -- Hide the test buttons
        if not SecureSort.initialized then
            print("|cff00ffff[DF SecureSort]|r Not initialized!")
            return
        end
        SecureSort:HideTestButtons()
        
    elseif cmd == "ui" then
        -- Toggle the test UI panel
        SecureSort:ToggleTestUI()
        
    elseif cmd == "help" then
        print("|cff00ffff[DF SecureSort]|r Commands:")
        print("  |cffffffff/dfsecure ui|r - Toggle test UI panel (easiest!)")
        print("  /dfsecure status - Show current status")
        print("  /dfsecure debug - Toggle debug output")
        print("  /dfsecure init - Initialize the secure handler")
        print("  /dfsecure party - Register party frames (5)")
        print("  /dfsecure raid - Register raid frames (40)")
        print("  /dfsecure all - Register ALL frames (45)")
        print("  /dfsecure swap - Swap frames 0 and 1")
        print("  /dfsecure swapback - Swap them back")
        print("  /dfsecure showbutton - Show combat test buttons")
        print("  /dfsecure hidebutton - Hide combat test buttons")
        
    else
        print("|cff00ffff[DF SecureSort]|r Unknown command. Try |cffffffff/dfsecure ui|r or |cffffffff/dfsecure help|r")
    end
end

-- ============================================================
-- EVENT HANDLING FOR RESORT ON GROUP CHANGES
-- ============================================================
-- Watch GROUP_ROSTER_UPDATE to resort when party composition changes

local roleUpdateFrame = CreateFrame("Frame")
roleUpdateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
roleUpdateFrame:RegisterEvent("INSPECT_READY")
roleUpdateFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
roleUpdateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
roleUpdateFrame:SetScript("OnEvent", function(self, event, arg1)
    -- Handle inspection results (always process - doesn't need SecureSort initialized)
    if event == "INSPECT_READY" then
        if arg1 then
            SecureSort:OnInspectReady(arg1)
        end
        return
    end
    
    -- Handle spec changes (always process - caches spec and triggers FlatRaidFrames re-sort)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- Re-cache player spec
        local playerSpecID = GetSpecializationInfo(GetSpecialization() or 0)
        if playerSpecID then
            SecureSort:CacheUnitSpec("player", playerSpecID)
        end
        -- Push updated data and re-sort
        if not InCombatLockdown() then
            if SecureSort.initialized then
                if IsInRaid() then
                    SecureSort:PushRaidSpecDataToFrames()
                else
                    SecureSort:PushSpecDataToFrames()
                end
            end
            -- Notify FlatRaidFrames to re-sort with updated spec data
            -- Guard: only re-sort if flat mode is actually active (not grouped mode)
            if DF.FlatRaidFrames and DF.FlatRaidFrames.initialized then
                local rdb = DF:GetRaidDB()
                if rdb and not rdb.raidUseGroups then
                    DF.FlatRaidFrames:UpdateNameList()
                else
                    DF:Debug("FLATRAID", "Skipping UpdateNameList from spec change: grouped mode active")
                end
            end
        end
        return
    end

    -- Handle group roster changes - scan new members for specs
    if event == "GROUP_ROSTER_UPDATE" then
        if not InCombatLockdown() then
            -- Delay slightly to let roster data settle
            C_Timer.After(0.5, function()
                if not InCombatLockdown() then
                    SecureSort:ScanGroupForSpecs()
                end
            end)
        end
        return
    end
    
    -- Handle combat end - process any pending operations
    if event == "PLAYER_REGEN_ENABLED" then
        -- Process pending settings push first
        if SecureSort.pendingSettingsPush then
            SecureSort.pendingSettingsPush = false
            SecureSort:PushSortSettings()
            SecureSort:UpdateLayoutParamsOnButtons()
            DebugPrint("Pushed pending sort settings after combat")
        end
        
        -- Process pending spec data push
        if SecureSort.pendingSpecPush then
            SecureSort.pendingSpecPush = false
            SecureSort:PushSpecDataToFrames()
            DebugPrint("Pushed pending spec data after combat")
        end
        
        -- Process pending party names push
        if SecureSort.pendingNamesPush then
            SecureSort.pendingNamesPush = false
            SecureSort:PushPartyUnitNames()
            DebugPrint("Pushed pending party names after combat")
        end

        -- Process pending inspect-driven party sort (inspects that resolved during combat)
        if SecureSort.pendingInspectPartySort and not IsInRaid() then
            SecureSort.pendingInspectPartySort = false
            if DF.ApplyPartyGroupSorting then
                DF:ApplyPartyGroupSorting()
                DebugPrint("Applied pending inspect-driven party sort after combat")
            end
        end
        
        -- Process pending raid settings push
        if SecureSort.pendingRaidSettingsPush then
            SecureSort.pendingRaidSettingsPush = false
            SecureSort:PushRaidSortSettings()
            SecureSort:PushRaidLayoutConfig()
            DebugPrint("Pushed pending raid sort settings after combat")
        end
        
        -- Process pending raid spec data push
        if SecureSort.pendingRaidSpecPush then
            SecureSort.pendingRaidSpecPush = false
            SecureSort:PushRaidSpecDataToFrames()
            DebugPrint("Pushed pending raid spec data after combat")
        end
        
        -- Process pending raid names push
        if SecureSort.pendingRaidNamesPush then
            SecureSort.pendingRaidNamesPush = false
            SecureSort:PushRaidUnitNames()
            DebugPrint("Pushed pending raid names after combat")
        end
        
        -- Process pending sort (from mid-combat group changes)
        if SecureSort.pendingSort then
            SecureSort.pendingSort = false
            SecureSort:TriggerSecureSort("PLAYER_REGEN_ENABLED_pending")
            DebugPrint("Triggered pending secure sort after combat")
        end
        
        -- Process pending raid sort
        if SecureSort.pendingRaidSort then
            SecureSort.pendingRaidSort = false
            SecureSort:TriggerSecureRaidSort("PLAYER_REGEN_ENABLED_pending")
            DebugPrint("Triggered pending secure raid sort after combat")
        end
        
        -- Handle deferred frame registration
        if SecureSort.needsResort then
            SecureSort.needsResort = false
            if SecureSort.initialized and not SecureSort.framesRegistered and DF.playerFrame then
                SecureSort:RegisterPartyFrames()
                DebugPrint("Auto-registered party frames after combat")
            end
            if SecureSort.framesRegistered then
                SecureSort:TriggerSecureSort("PLAYER_REGEN_ENABLED_deferred")
                DebugPrint("Triggered deferred secure sort after combat")
            end
        end
        
        -- Handle deferred raid frame registration
        if SecureSort.needsRaidResort then
            SecureSort.needsRaidResort = false
            -- Check if raid headers exist
            if SecureSort.initialized and not SecureSort.raidFramesRegistered and (DF.raidSeparatedHeaders or (DF.FlatRaidFrames and DF.FlatRaidFrames.header)) then
                SecureSort:RegisterRaidFrames()
                DebugPrint("Auto-registered raid frames after combat")
            end
            if SecureSort.raidFramesRegistered then
                SecureSort:TriggerSecureRaidSort("PLAYER_REGEN_ENABLED_deferred")
                DebugPrint("Triggered deferred secure raid sort after combat")
            end
        end
        
        -- Resume inspection queue after combat
        SecureSort:ProcessInspectQueue()
    end
end)

-- ============================================================
-- AUTO-INITIALIZATION
-- ============================================================
-- Initialize SecureSort as early as possible to avoid frame flicker.
-- We use multiple events and rapid polling to catch the earliest moment.

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local initAttempted = false
local framesAttempted = false

local function TryInitialize()
    if SecureSort.initialized then return true end
    if not DF.initialized then return false end
    
    -- SecureSort is disabled - Headers.lua handles all sorting via
    -- nameList-based SecureGroupHeaderTemplate (unified header handler)
    return false
end

local function TryRegisterFrames()
    if SecureSort.framesRegistered then return true end
    if not SecureSort.initialized then return false end
    -- Check if party header exists (new system)
    if not DF.partyHeader then return false end
    if InCombatLockdown() then return false end
    
    SecureSort:RegisterPartyFrames()
    
    -- Also register raid frames if headers exist
    if (DF.raidSeparatedHeaders or (DF.FlatRaidFrames and DF.FlatRaidFrames.header)) and not SecureSort.raidFramesRegistered then
        SecureSort:RegisterRaidFrames()
        DebugPrint("Raid frames also registered during init")
    end
    
    -- Immediately trigger sort to position frames
    if SecureSort.framesRegistered then
        SecureSort:TriggerSecureSort("TryRegisterFrames_init")
        DebugPrint("Initial sort triggered - frames should be positioned")
    end
    
    return SecureSort.framesRegistered
end

local function TryFullInit()
    if not initAttempted then
        if TryInitialize() then
            initAttempted = true
        end
    end
    
    if initAttempted and not framesAttempted then
        if TryRegisterFrames() then
            framesAttempted = true
        end
    end
    
    return initAttempted and framesAttempted
end

initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        -- Only care about our addon loading
        if arg1 == "DandersFrames" then
            -- Try immediately - DF might be ready now
            TryFullInit()
            
            -- Also try on next frame in case DF finishes init slightly after
            C_Timer.After(0, TryFullInit)
        end
        
    elseif event == "PLAYER_LOGIN" then
        -- First attempt - DF might not be ready yet
        TryFullInit()
        
        -- Rapid polling to catch the earliest moment frames are ready
        -- Much faster than waiting 1 second
        local attempts = 0
        local ticker
        ticker = C_Timer.NewTicker(0.05, function()
            attempts = attempts + 1
            if TryFullInit() or attempts >= 20 then  -- Max 1 second of polling
                ticker:Cancel()
                if framesAttempted then
                    DebugPrint("SecureSort ready after " .. (attempts * 0.05) .. "s")
                end
            end
        end)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Another chance to init - fires after loading screens
        if not framesAttempted then
            C_Timer.After(0, function()
                TryFullInit()
            end)
        end
        
        -- Scan group specs after loading screen (delayed to let roster data arrive)
        C_Timer.After(2, function()
            if not InCombatLockdown() and (IsInGroup() or IsInRaid()) then
                SecureSort:ScanGroupForSpecs()
            end
        end)
    end
end)

DebugPrint("SecureSort.lua loaded (Phase 3)")
