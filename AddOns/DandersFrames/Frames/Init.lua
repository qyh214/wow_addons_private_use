local addonName, DF = ...

-- ============================================================
-- FRAMES INIT MODULE
-- Contains frame initialization and raid frame setup
-- ============================================================

-- Local caching of frequently used globals for performance
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local C_Timer = C_Timer

-- PERFORMANCE FIX: Reusable tables for layout calculations (avoid GC during roster updates)
local reusableGroupPlayerCounts = {}
local reusableActiveGroups = {}
local reusableActiveGroupList = {}
local reusableFrameToGroup = {}
local reusableGroupCurrentPos = {}
local reusableVisibleFrames = {}
local reusableVisibleSet = {}

-- ============================================================
-- MOVER SYNC HELPER
-- Keeps raidMoverFrame sized to match the active container
-- (test container when in test mode, live container otherwise)
-- ============================================================

function DF:SyncRaidMoverToContainer()
    if not DF.raidMoverFrame or not DF.raidMoverFrame:IsShown() then return end
    local source = DF.raidTestMode and DF.testRaidContainer or DF.raidContainer
    if not source then return end
    local w, h = source:GetSize()
    DF.raidMoverFrame:SetSize(max(w, 100), max(h, 100))
end

-- ============================================================
-- INITIALIZATION & LAYOUT
-- ============================================================

function DF:InitializeFrames()
    if DF.container then return end
    
    -- ============================================================
    -- NOTE: This function is now called at ADDON_LOADED where
    -- InCombatLockdown() is ALWAYS false, even during a combat reload.
    -- This is critical for combat reload support - frames MUST be
    -- created during this window.
    -- ============================================================
    
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Reset lock states on reload (frames should always start locked)
    db.locked = true
    raidDb.raidLocked = true
    DF.testMode = false
    DF.raidTestMode = false
    
    -- ============================================================
    -- HEADER MODE (always enabled)
    -- Legacy frame creation has been removed
    -- All frames are now managed by SecureGroupHeaderTemplate in Headers.lua
    -- ============================================================
    if DF.debugHeaders then
        print("|cFF00FF00[DF Init]|r Header mode - creating container and mover only")
    end
    
    -- Create container (needed for headers and movers)
    DF.container = CreateFrame("Frame", "DandersFramesContainer", UIParent)
    local partyScale = db.frameScale or 1.0
    DF.container:SetScale(partyScale)
    DF.container:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / partyScale, (db.anchorY or 0) / partyScale)
    DF.container:SetSize(500, 200)
    
    -- Create mover frame
    DF:CreateMoverFrame()

    -- Create permanent mover handle for party (skip if party mode disabled)
    if DF.db and DF.db.partyEnabled ~= false then
        DF:CreatePermanentMover(DF.container, "party")
    end

    -- Initialize raid container (needed by Headers.lua)
    DF:InitializeRaidFrames()
end

-- ============================================================
-- RAID FRAMES INITIALIZATION
-- ============================================================

function DF:InitializeRaidFrames()
    if DF.raidContainer then return end
    
    -- ============================================================
    -- NOTE: This function is called at ADDON_LOADED where
    -- InCombatLockdown() is ALWAYS false, even during a combat reload.
    -- We create the container here; raid frames are created by
    -- SecureGroupHeaderTemplate in Headers.lua
    -- ============================================================
    
    local db = DF:GetRaidDB()
    
    -- Create raid container
    -- NOTE: Using SecureFrameTemplate so secure code can SetPoint relative to this frame
    DF.raidContainer = CreateFrame("Frame", "DandersRaidFramesContainer", UIParent, "SecureFrameTemplate")
    local raidScale = db.frameScale or 1.0
    DF.raidContainer:SetScale(raidScale)
    DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / raidScale, (db.raidAnchorY or 0) / raidScale)
    DF.raidContainer:SetSize(400, 300)
    DF.raidContainer:SetMovable(true)
    DF.raidContainer:Hide()  -- Hidden by default, shown when in raid
    
    -- Raid frames are children of SecureGroupHeaderTemplate headers
    -- Access via DF:GetRaidFrame(index) or DF:GetAllRaidFrames()
    
    -- Create raid mover frame
    DF:CreateRaidMoverFrame()

    -- Create permanent mover handle for raid (skip if raid mode disabled)
    if DF.db and DF.db.raidEnabled ~= false then
        DF:CreatePermanentMover(DF.raidContainer, "raid")
    end
end

function DF:CreateRaidFrame(unit, index)
    local frame = DF:CreateUnitFrame(unit, index, true)
    -- Apply initial layout
    DF:ApplyFrameLayout(frame)
    return frame
end

-- Apply layout settings to a raid frame (DEPRECATED - use ApplyFrameLayout instead)
function DF:ApplyRaidFrameLayout(frame)
    DF:ApplyFrameLayout(frame)
end

-- Update raid frame (DEPRECATED - use UpdateUnitFrame instead)
function DF:UpdateRaidFrame(frame)
    DF:UpdateUnitFrame(frame)
end

function DF:UpdateRaidLayout()
    local db = DF:GetRaidDB()
    
    if not DF.raidContainer then return end
    
    -- Protect against calling during combat (secure frame operations would fail)
    if InCombatLockdown() then
        -- For flat layouts, use the specific flat layout refresh flag
        -- which is handled properly in Headers.lua's combat handler
        if not db.raidUseGroups then
            DF.pendingFlatLayoutRefresh = true
        else
            DF.needsUpdate = true
        end
        return
    end
    
    -- Check if using flat grid layout instead of group-based
    if not db.raidUseGroups then
        return DF:UpdateRaidFlatLayout()
    end
    
    -- Use group-based layout
    return DF:UpdateRaidGroupedLayout()
end

-- Group-based raid layout positioning
function DF:UpdateRaidGroupedLayout()
    local db = DF:GetRaidDB()
    if not DF.raidContainer then return end
    
    -- CRITICAL: Hide FlatRaidFrames when using grouped layout
    if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
        DF.FlatRaidFrames:SetEnabled(false)
    end
    
    -- Check if we have raid headers or legacy frames
    local hasHeaders = DF.raidSeparatedHeaders or (DF.FlatRaidFrames and DF.FlatRaidFrames.header)
    local hasLegacy = DF.raidFrames and DF.raidFrames[1]
    
    if not hasHeaders and not hasLegacy then return end
    
    -- Use SecureSort's group positioning functions
    local SecureSort = DF.SecureSort
    if not SecureSort then
        return DF:UpdateRaidFlatLayout()
    end
    
    -- NEW HEADER MODE: Headers handle their own positioning via secure templates
    -- We only need to:
    -- 1. Position the group headers relative to each other
    -- 2. Update the raid container size
    -- 3. Update group labels
    if hasHeaders and not hasLegacy then
        -- Update visibility and positioning via headers
        DF:UpdateRaidHeaderVisibility()
        DF:PositionRaidHeaders()
        DF:UpdateRaidGroupLabels()
        return
    end
    
    -- LEGACY MODE: If sorting is enabled AND we're not in test mode, let secure code handle positioning
    -- Test mode must use Lua positioning because there's no real raid roster for secure code to query
    if db.sortEnabled and SecureSort.raidFramesRegistered and not DF.raidTestMode then
        -- Just trigger secure sort which will handle everything
        SecureSort:UpdateRaidGroupLayoutParams()
        local lp = SecureSort.raidGroupLayoutParams
        
        -- Count active groups for container sizing
        -- PERFORMANCE FIX: Reuse tables instead of creating new ones
        wipe(reusableActiveGroupList)
        wipe(reusableActiveGroups)
        local activeGroupList = reusableActiveGroupList
        local activeGroups = reusableActiveGroups
        local isTestMode = DF.raidTestMode
        local visibleCount = 0
        
        for i = 1, 40 do
            local frame = DF.raidFrames[i]
            if frame and frame:IsShown() then
                visibleCount = visibleCount + 1
                local groupNum
                if isTestMode then
                    groupNum = math.ceil(visibleCount / 5)
                else
                    local unit = frame:GetAttribute("unit") or frame.unit
                    if unit and UnitExists(unit) then
                        local name, rank, subgroup = GetRaidRosterInfo(UnitInRaid(unit) or 0)
                        groupNum = subgroup or 1
                    else
                        groupNum = math.ceil(i / 5)
                    end
                end
                if not activeGroups[groupNum] then
                    activeGroups[groupNum] = true
                    table.insert(activeGroupList, groupNum)
                end
            end
        end
        table.sort(activeGroupList)
        
        -- Set container size
        local totalWidth, totalHeight = SecureSort:CalculateRaidGroupContainerSize(#activeGroupList, lp)
        DF.raidContainer:SetSize(totalWidth, totalHeight)
        DF:SyncRaidMoverToContainer()

        -- Set frame sizes only (secure code handles positions)
        for i = 1, 40 do
            local frame = DF.raidFrames[i]
            if frame and frame:IsShown() then
                frame:SetSize(lp.frameWidth, lp.frameHeight)
            end
        end
        
        -- Trigger secure sort to handle actual positioning
        SecureSort:TriggerSecureRaidSort("UpdateRaidGroupedLayout")
        
        -- Update group labels (not secure, can be done anytime)
        DF:UpdateRaidGroupLabels()
        return
    end
    
    -- Sorting disabled OR test mode - use Lua-based positioning logic
    -- (Test mode has no real raid roster, so secure code can't query group membership)
    -- Update group layout params from current settings
    SecureSort:UpdateRaidGroupLayoutParams()
    local lp = SecureSort.raidGroupLayoutParams

    -- [LEAK-TEST] Instrumentation: does the live Lua path run, and what's lp.testMode?
    -- Toggle: /run DandersFrames.debugLeakTest = true (or false to silence)
    if DF.debugLeakTest then
        print(string.format(
            "|cffffa500[DF LEAK-TEST]|r UpdateRaidGroupedLayout -> Lua fallback  raidTestMode=%s  lp.testMode=%s  db.sortEnabled=%s",
            tostring(DF.raidTestMode),
            tostring(lp and lp.testMode),
            tostring(db and db.sortEnabled)
        ))
    end
    
    -- Count visible frames and build group membership data
    -- PERFORMANCE FIX: Reuse tables instead of creating new ones
    wipe(reusableGroupPlayerCounts)
    wipe(reusableActiveGroups)
    wipe(reusableActiveGroupList)
    wipe(reusableFrameToGroup)
    local groupPlayerCounts = reusableGroupPlayerCounts  -- groupNum -> count of players
    local activeGroups = reusableActiveGroups       -- groupNum -> true if has players
    local activeGroupList = reusableActiveGroupList    -- ordered list of active group numbers
    local frameToGroup = reusableFrameToGroup       -- frameIndex -> { groupNum, posInGroup }
    local visibleCount = 0
    
    -- In test mode, frames are sequentially assigned: 1-5 = group 1, 6-10 = group 2, etc.
    -- In live mode, we need to get the actual group from the unit
    local isTestMode = DF.raidTestMode
    
    for i = 1, 40 do
        local frame = DF.raidFrames[i]
        if frame and frame:IsShown() then
            visibleCount = visibleCount + 1
            
            local groupNum
            local posInGroup
            
            if isTestMode then
                -- Test mode: sequential assignment
                groupNum = math.ceil(visibleCount / 5)
                posInGroup = (visibleCount - 1) % 5
            else
                -- Live mode: get actual group from unit
                local unit = frame:GetAttribute("unit") or frame.unit
                if unit and UnitExists(unit) then
                    local name, rank, subgroup = GetRaidRosterInfo(UnitInRaid(unit) or 0)
                    groupNum = subgroup or 1
                    
                    -- Count position within this group
                    posInGroup = (groupPlayerCounts[groupNum] or 0)
                else
                    -- Fallback for units without roster info
                    groupNum = math.ceil(i / 5)
                    posInGroup = (i - 1) % 5
                end
            end
            
            groupPlayerCounts[groupNum] = (groupPlayerCounts[groupNum] or 0) + 1
            -- PERFORMANCE FIX: Reuse sub-table if it exists
            if not frameToGroup[i] then
                frameToGroup[i] = { groupNum = 0, posInGroup = 0 }
            end
            frameToGroup[i].groupNum = groupNum
            frameToGroup[i].posInGroup = posInGroup
            
            if not activeGroups[groupNum] then
                activeGroups[groupNum] = true
                table.insert(activeGroupList, groupNum)
            end
        end
    end
    
    -- Sort activeGroupList by group number
    table.sort(activeGroupList)
    
    -- Recalculate posInGroup now that we know actual counts
    -- PERFORMANCE FIX: Reuse table
    wipe(reusableGroupCurrentPos)
    local groupCurrentPos = reusableGroupCurrentPos
    for i = 1, 40 do
        local frame = DF.raidFrames[i]
        if frame and frame:IsShown() and frameToGroup[i] then
            local groupNum = frameToGroup[i].groupNum
            groupCurrentPos[groupNum] = groupCurrentPos[groupNum] or 0
            frameToGroup[i].posInGroup = groupCurrentPos[groupNum]
            groupCurrentPos[groupNum] = groupCurrentPos[groupNum] + 1
        end
    end
    
    -- Calculate and set container size
    local totalWidth, totalHeight = SecureSort:CalculateRaidGroupContainerSize(#activeGroupList, lp)
    DF.raidContainer:SetSize(totalWidth, totalHeight)
    DF:SyncRaidMoverToContainer()

    -- Position each visible frame
    for i = 1, 40 do
        local frame = DF.raidFrames[i]
        if frame and frame:IsShown() and frameToGroup[i] then
            local groupInfo = frameToGroup[i]
            local groupNum = groupInfo.groupNum
            local posInGroup = groupInfo.posInGroup
            local playersInGroup = groupPlayerCounts[groupNum]
            
            -- Set frame size
            frame:SetSize(lp.frameWidth, lp.frameHeight)
            
            -- Position using shared function
            SecureSort:PositionRaidFrameToGroupSlot(
                frame, 
                groupNum, 
                posInGroup, 
                playersInGroup, 
                activeGroupList, 
                lp, 
                DF.raidContainer
            )
        end
    end
    
    -- Update group labels
    DF:UpdateRaidGroupLabels()
end

-- ============================================================
-- FLAT GRID RAID LAYOUT
-- All players in one unified grid, no group structure
-- ============================================================

function DF:UpdateRaidFlatLayout()
    local db = DF:GetRaidDB()
    
    if not DF.raidContainer then return end
    
    -- Protect against calling during combat (secure frame operations would fail)
    if InCombatLockdown() then
        -- Use the specific flat layout refresh flag
        -- which is handled properly in Headers.lua's combat handler
        DF.pendingFlatLayoutRefresh = true
        return
    end
    
    -- CRITICAL: Hide separated headers when in flat mode
    -- This ensures we don't have two sets of frames visible
    if DF.raidSeparatedHeaders then
        for i = 1, 8 do
            if DF.raidSeparatedHeaders[i] then
                DF.raidSeparatedHeaders[i]:Hide()
                if DF.SetHeaderChildrenEventsEnabled then
                    DF:SetHeaderChildrenEventsEnabled(DF.raidSeparatedHeaders[i], false)
                end
            end
        end
    end
    
    -- Use FlatRaidFrames for flat layouts
    if DF.FlatRaidFrames then
        if not DF.FlatRaidFrames.initialized then
            DF.FlatRaidFrames:Initialize()
        end
        DF.FlatRaidFrames:SetEnabled(true)
        DF.FlatRaidFrames:ApplyLayoutSettings()
        return
    end
end

-- ============================================================
-- RAID GROUP LABELS
-- ============================================================

-- Container for group labels
DF.raidGroupLabels = {}

-- Format the group label text
local function FormatGroupLabelText(groupNum, format)
    if format == "GROUP_NUM" then
        return "Group " .. groupNum
    elseif format == "SHORT" then
        return "G" .. groupNum
    elseif format == "NUM_ONLY" then
        return tostring(groupNum)
    elseif format == "ROMAN" then
        local romans = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII"}
        return romans[groupNum] or tostring(groupNum)
    else
        return "Group " .. groupNum
    end
end

-- Create or get a group label
-- Container parameter allows creating labels for either live (raidContainer) or test (testRaidContainer) mode
local function GetOrCreateGroupLabel(groupNum, container)
    -- Use provided container or default to raidContainer
    local parentContainer = container or DF.raidContainer
    if not parentContainer then return nil end
    
    -- Check if label already exists
    if DF.raidGroupLabels[groupNum] then
        local label = DF.raidGroupLabels[groupNum]
        -- Re-parent if needed (switching between live/test mode)
        if label:GetParent() ~= parentContainer then
            label:SetParent(parentContainer)
            if label.shadow then
                label.shadow:SetParent(parentContainer)
            end
        end
        return label
    end
    
    local label = parentContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetDrawLayer("OVERLAY", 7)
    
    -- Add shadow
    label.shadow = parentContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label.shadow:SetDrawLayer("OVERLAY", 6)
    label.shadow:SetTextColor(0, 0, 0, 0.8)
    
    DF.raidGroupLabels[groupNum] = label
    return label
end

-- Update all raid group labels
-- This can be called during combat - FontStrings are not protected
-- Labels are now anchored directly to group headers (live) or first frame of each group (test)
function DF:UpdateRaidGroupLabels(activeGroupsTable, db, horizontal)
    if not db then db = DF:GetRaidDB() end
    
    local isTestMode = DF.raidTestMode
    
    -- Determine parent container based on mode
    local container = isTestMode and DF.testRaidContainer or DF.raidContainer
    if not container then return end
    
    -- Group labels only make sense in group-based layout mode
    local useGroups = db.raidUseGroups
    local enabled = db.groupLabelEnabled and useGroups
    
    -- Build active groups data
    local activeGroups = {}      -- groupNum -> true if active
    local groupFirstFrame = {}   -- groupNum -> first frame of that group (for test mode anchoring)
    
    if isTestMode then
        if DF.testGroupFirstFrame then
            -- Use sorted first-frame mapping (populated by LightweightPositionRaidTestFrames)
            for groupNum, frame in pairs(DF.testGroupFirstFrame) do
                activeGroups[groupNum] = true
                groupFirstFrame[groupNum] = frame
            end
        else
            -- Fallback: unsorted index-based (before first positioning pass)
            local testFrameCount = db.raidTestFrameCount or 10
            for i = 1, testFrameCount do
                local frame = DF.testRaidFrames and DF.testRaidFrames[i]
                if frame then
                    local groupNum = math.ceil(i / 5)
                    if not activeGroups[groupNum] then
                        activeGroups[groupNum] = true
                        groupFirstFrame[groupNum] = frame
                    end
                end
            end
        end
    else
        -- Live mode: check which separated headers have visible children
        if DF.raidSeparatedHeaders then
            for g = 1, 8 do
                local header = DF.raidSeparatedHeaders[g]
                if header and header:IsShown() then
                    -- Check if header has any visible children
                    local child1 = header:GetAttribute("child1")
                    if child1 and child1:IsShown() then
                        activeGroups[g] = true
                    end
                end
            end
        end
    end
    
    -- Get layout direction
    local isHorizontal = (db.growDirection == "HORIZONTAL")
    local labelPosition = db.groupLabelPosition or "START"
    local offsetX = db.groupLabelOffsetX or 0
    local offsetY = db.groupLabelOffsetY or 0
    
    for g = 1, 8 do
        local label = DF.raidGroupLabels[g]
        
        if not enabled or not activeGroups[g] then
            -- Hide label if disabled or group not active
            if label then
                label:Hide()
                if label.shadow then label.shadow:Hide() end
            end
        else
            -- Create label if needed (pass container for proper parenting in test mode)
            if not label then
                label = GetOrCreateGroupLabel(g, container)
            end
            
            if label then
                -- Ensure label is parented to the correct container
                if label:GetParent() ~= container then
                    label:SetParent(container)
                    if label.shadow then label.shadow:SetParent(container) end
                end
                
                -- Apply font settings
                local font = db.groupLabelFont or "Fonts\\FRIZQT__.TTF"
                local fontSize = db.groupLabelFontSize or 12
                local outline = db.groupLabelOutline or "OUTLINE"
                if outline == "NONE" then outline = "" end
                
                DF:SafeSetFont(label, font, fontSize, outline)
                if label.shadow then
                    DF:SafeSetFont(label.shadow, font, fontSize, outline)
                end
                
                -- Apply color
                local color = db.groupLabelColor or {r = 1, g = 1, b = 1, a = 1}
                label:SetTextColor(color.r, color.g, color.b, color.a or 1)
                
                -- Set text
                local format = db.groupLabelFormat or "GROUP_NUM"
                local text = FormatGroupLabelText(g, format)
                label:SetText(text)
                if label.shadow then label.shadow:SetText(text) end
                
                -- Determine anchor frame and points based on mode and layout
                local anchorFrame
                if isTestMode then
                    anchorFrame = groupFirstFrame[g]
                else
                    anchorFrame = DF.raidSeparatedHeaders and DF.raidSeparatedHeaders[g]
                end
                
                if anchorFrame then
                    -- Calculate anchor points based on label position and layout direction
                    local labelAnchor, frameAnchor, anchorOffsetX, anchorOffsetY
                    
                    if labelPosition == "START" then
                        if isHorizontal then
                            -- Columns mode: START = above the group
                            labelAnchor = "BOTTOM"
                            frameAnchor = "TOP"
                            anchorOffsetX = offsetX
                            anchorOffsetY = offsetY
                        else
                            -- Rows mode: START = left of the group
                            labelAnchor = "RIGHT"
                            frameAnchor = "LEFT"
                            anchorOffsetX = offsetX
                            anchorOffsetY = offsetY
                        end
                    elseif labelPosition == "END" then
                        if isHorizontal then
                            -- Columns mode: END = below the group
                            labelAnchor = "TOP"
                            frameAnchor = "BOTTOM"
                            anchorOffsetX = offsetX
                            anchorOffsetY = offsetY
                        else
                            -- Rows mode: END = right of the group
                            labelAnchor = "LEFT"
                            frameAnchor = "RIGHT"
                            anchorOffsetX = offsetX
                            anchorOffsetY = offsetY
                        end
                    else -- CENTER
                        labelAnchor = "CENTER"
                        frameAnchor = "CENTER"
                        anchorOffsetX = offsetX
                        anchorOffsetY = offsetY
                    end
                    
                    -- Position label relative to anchor frame
                    label:ClearAllPoints()
                    label:SetPoint(labelAnchor, anchorFrame, frameAnchor, anchorOffsetX, anchorOffsetY)
                    
                    -- Position shadow slightly offset from label
                    if label.shadow then
                        label.shadow:ClearAllPoints()
                        label.shadow:SetPoint(labelAnchor, anchorFrame, frameAnchor, anchorOffsetX + 1, anchorOffsetY - 1)
                        
                        if db.groupLabelShadow then
                            label.shadow:Show()
                        else
                            label.shadow:Hide()
                        end
                    end
                    
                    label:Show()
                else
                    -- No anchor frame available, hide label
                    label:Hide()
                    if label.shadow then label.shadow:Hide() end
                end
            end
        end
    end
end


function DF:CreateRaidMoverFrame()
    -- Cannot create UI elements during combat
    if InCombatLockdown() then return end
    
    -- Don't recreate if already exists
    if DF.raidMoverFrame then return end
    
    -- CRITICAL: Ensure raidContainer exists before creating mover
    if not DF.raidContainer then
        print("|cFFFF0000[DF Init]|r Cannot create raid mover - DF.raidContainer doesn't exist!")
        return
    end
    
    -- Parent to UIParent (not raidContainer) so strata works properly
    -- Position over the container
    local mover = CreateFrame("Frame", "DandersRaidFramesMover", UIParent, "BackdropTemplate")
    mover:SetFrameStrata("TOOLTIP")  -- Very high strata to be above secure frames
    mover:SetFrameLevel(100)
    
    -- Set initial size from container
    local cWidth, cHeight = DF.raidContainer:GetSize()
    mover:SetSize(math.max(cWidth, 100), math.max(cHeight, 100))
    
    -- Set initial position from db
    local raidDb = DF:GetRaidDB()
    local raidMoverScale = raidDb.frameScale or 1.0
    mover:SetScale(raidMoverScale)
    mover:SetPoint("CENTER", UIParent, "CENTER", (raidDb.raidAnchorX or 0) / raidMoverScale, (raidDb.raidAnchorY or 0) / raidMoverScale)
    
    mover:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    mover:SetBackdropColor(1.0, 0.5, 0.2, 0.4)  -- More visible
    mover:SetBackdropBorderColor(1.0, 0.5, 0.2, 1.0)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()
    
    local label = mover:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER", mover, "CENTER", 0, 0)
    DF:SafeSetFont(label, nil, 14, "OUTLINE")
    label:SetText("Raid Frames\nDrag to move")
    label:SetTextColor(1, 0.7, 0.3, 1)
    
    DF.raidMoverFrame = mover
    
    -- Shared drag state between OnDragStart/OnUpdate/OnDragStop
    local raidDragOffsetX, raidDragOffsetY = 0, 0

    -- Left-click switches the shared position panel to raid mode.
    mover:HookScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("raid")
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        -- Switch the position panel to raid mode so nudge buttons
        -- affect the raid container.
        if DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("raid")
        end
        -- Use saved db position as truth — avoids all GetCenter/GetLeft
        -- ambiguity on scaled frames
        local db = DF:GetRaidDB()
        local pScale = UIParent:GetEffectiveScale()
        local startCursorX, startCursorY = GetCursorPosition()
        startCursorX = startCursorX / pScale
        startCursorY = startCursorY / pScale
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local frameCX = screenWidth / 2 + (db.raidAnchorX or 0)
        local frameCY = screenHeight / 2 + (db.raidAnchorY or 0)
        local cursorOffX = frameCX - startCursorX
        local cursorOffY = frameCY - startCursorY
        raidDragOffsetX = db.raidAnchorX or 0
        raidDragOffsetY = db.raidAnchorY or 0

        -- Start OnUpdate to track cursor and sync positions during drag
        self:SetScript("OnUpdate", function()
            if InCombatLockdown() then self:SetScript("OnUpdate", nil); return end
            local cursorX, cursorY = GetCursorPosition()
            local ps = UIParent:GetEffectiveScale()
            cursorX = cursorX / ps
            cursorY = cursorY / ps
            local sw, sh = GetScreenWidth(), GetScreenHeight()
            raidDragOffsetX = (cursorX + cursorOffX) - sw / 2
            raidDragOffsetY = (cursorY + cursorOffY) - sh / 2

            local scale = self:GetScale() or 1

            -- Reposition the mover
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", raidDragOffsetX / scale, raidDragOffsetY / scale)

            -- Sync raidContainer to mover position
            DF.raidContainer:ClearAllPoints()
            DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", raidDragOffsetX / scale, raidDragOffsetY / scale)

            -- Sync testRaidContainer to mover position (for live preview)
            if DF.testRaidContainer then
                DF.testRaidContainer:ClearAllPoints()
                DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", raidDragOffsetX / scale, raidDragOffsetY / scale)
            end

            -- Snap preview if enabled
            local snapDb = DF:GetRaidDB()
            if snapDb.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
                DF:UpdateSnapPreview(self, raidDragOffsetX, raidDragOffsetY)
            end
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        -- Stop OnUpdate
        self:SetScript("OnUpdate", nil)

        -- Hide snap preview lines
        DF:HideSnapPreview()

        -- Use the last computed offset from OnUpdate
        local x, y = raidDragOffsetX, raidDragOffsetY

        -- Snap to grid if enabled
        local db = DF:GetRaidDB()
        if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
            x, y = DF:SnapToGrid(x, y)
        end

        -- Save position
        if DF.LogRaidAnchorWrite then DF:LogRaidAnchorWrite("RaidMover:OnDragStop", x, y) end
        db.raidAnchorX = x
        db.raidAnchorY = y

        -- If editing an auto profile, also save as override
        if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
            DF.AutoProfilesUI:SetProfileSetting("raidAnchorX", x)
            DF.AutoProfilesUI:SetProfileSetting("raidAnchorY", y)
            -- Update position override indicator
            if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
                DF.GUI.UpdatePositionOverrideIndicator()
            end
        end

        -- Apply final position to mover, container, and test container
        local scale = self:GetScale() or 1
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)

        DF.raidContainer:ClearAllPoints()
        DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)

        if DF.testRaidContainer then
            DF.testRaidContainer:ClearAllPoints()
            DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)
        end
        
        -- Update position panel
        DF:UpdatePositionPanel()
    end)
    
    mover:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            DF:LockRaidFrames()
        end
    end)
    
    DF.raidMoverFrame = mover
end

function DF:UnlockRaidFrames()
    if InCombatLockdown() then
        print("|cffff0000DandersFrames:|r Cannot unlock raid frames during combat.")
        return
    end
    
    if not DF.raidContainer then
        print("|cffff0000DandersFrames:|r Cannot unlock - raid container doesn't exist!")
        return
    end
    
    local db = DF:GetRaidDB()
    
    -- Ensure raid mover frame exists (create if needed)
    if not DF.raidMoverFrame then
        DF:CreateRaidMoverFrame()
    end
    
    -- Safety check - if mover still doesn't exist, abort
    if not DF.raidMoverFrame then
        print("|cffff0000DandersFrames:|r Cannot unlock - failed to create raid mover frame!")
        return
    end
    
    -- Save current position before making changes (for reset button)
    DF.savedRaidPositionX = db.raidAnchorX or 0
    DF.savedRaidPositionY = db.raidAnchorY or 0
    
    db.raidLocked = false
    DF.positionPanelMode = "raid"  -- Set mode for position panel
    DF.hideDragOverlay = db.hideDragOverlay or false
    
    local scale = db.frameScale or 1.0

    -- Make container movable and visible
    DF.raidContainer:SetMovable(true)
    DF.raidContainer:SetScale(scale)
    DF.raidContainer:ClearAllPoints()
    DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / scale, (db.raidAnchorY or 0) / scale)
    DF.raidContainer:Show()
    
    -- Ensure container has a reasonable size
    local cWidth, cHeight = DF.raidContainer:GetWidth(), DF.raidContainer:GetHeight()
    if cWidth < 50 or cHeight < 50 then
        -- Use fallback size based on settings
        local frameWidth = db.raidFrameWidth or 80
        local frameHeight = db.raidFrameHeight or 40
        local spacing = db.raidFrameSpacing or 2
        
        -- Default to 8 groups x 5 members layout
        DF.raidContainer:SetSize(
            8 * (frameWidth + spacing),
            5 * (frameHeight + spacing)
        )
        
        if DF.debugHeaders then
            print("|cFF00FF00[DF Init]|r Raid container size was too small, set fallback size")
        end
    end
    
    -- In flat mode, ensure container size is correct before reading it
    -- (the secure position handler for separated mode may have overwritten it)
    if not db.raidUseGroups and DF.FlatRaidFrames then
        DF.FlatRaidFrames:UpdateContainerSize()
    end
    
    -- When in test mode, reposition test frames first so the test container
    -- has the correct calculated 40-player max size, then size the mover from it.
    -- When NOT in test mode, size from the live raidContainer (existing behavior).
    if DF.raidTestMode and DF.testRaidContainer then
        local testFrameCount = db.raidTestFrameCount or 10
        if DF.LightweightPositionRaidTestFrames then
            DF:LightweightPositionRaidTestFrames(testFrameCount)
        end
        local tw, th = DF.testRaidContainer:GetSize()
        DF.raidMoverFrame:SetSize(max(tw, 100), max(th, 100))
    else
        local cWidth, cHeight = DF.raidContainer:GetWidth(), DF.raidContainer:GetHeight()
        DF.raidMoverFrame:SetSize(max(cWidth, 100), max(cHeight, 100))
    end

    DF.raidMoverFrame:SetScale(scale)
    DF.raidMoverFrame:ClearAllPoints()
    DF.raidMoverFrame:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / scale, (db.raidAnchorY or 0) / scale)
    DF.raidMoverFrame:SetFrameStrata("TOOLTIP")  -- Very high strata
    DF.raidMoverFrame:SetFrameLevel(100)
    DF.raidMoverFrame:SetAlpha(1)
    DF.raidMoverFrame:Show()
    DF.raidMoverFrame:Raise()

    -- Sync testRaidContainer position (and size only when not in test mode,
    -- since test mode already has the correct calculated size)
    if DF.testRaidContainer then
        DF.testRaidContainer:SetScale(scale)
        DF.testRaidContainer:ClearAllPoints()
        DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / scale, (db.raidAnchorY or 0) / scale)
        if not DF.raidTestMode then
            DF.testRaidContainer:SetSize(DF.raidContainer:GetSize())
        end
    end
    
    -- Debug info
    if DF.debugHeaders then
        print("|cFF00FF00[DF Init]|r Raid unlock - container size:", DF.raidContainer:GetWidth(), "x", DF.raidContainer:GetHeight())
        print("|cFF00FF00[DF Init]|r Raid unlock - mover size:", DF.raidMoverFrame:GetWidth(), "x", DF.raidMoverFrame:GetHeight())
        print("|cFF00FF00[DF Init]|r Raid unlock - mover shown:", DF.raidMoverFrame:IsShown() and "yes" or "no")
        print("|cFF00FF00[DF Init]|r Raid unlock - mover strata:", DF.raidMoverFrame:GetFrameStrata())
        print("|cFF00FF00[DF Init]|r Raid unlock - mover parent:", DF.raidMoverFrame:GetParent():GetName() or "unnamed")
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
    
    -- Enable raid test mode using the proper function
    DF:ShowRaidTestFrames()
    
    -- Show position panel (shared with party) and update its values from db
    if DF.positionPanel then
        DF:UpdatePositionPanel()
        if DF.positionPanel.UpdateTheme then
            DF.positionPanel:UpdateTheme()
        end
        DF.positionPanel:Show()
    end
    
    -- Update button text if it exists
    if DF.raidLockButton and DF.raidLockButton.Text then
        DF.raidLockButton.Text:SetText("Lock Raid Frames")
    end
    if DF.displayLockButton and DF.displayLockButton.Text then
        DF.displayLockButton.Text:SetText("Lock Frames")
    end
    
    -- Sync GUI toolbar buttons
    if DF.GUI then
        if DF.GUI.UpdateLockButtonState then DF.GUI.UpdateLockButtonState() end
        if DF.GUI.UpdateTestButtonState then DF.GUI.UpdateTestButtonState() end
    end
    
    -- Hide permanent mover while full overlay is active
    if DF.permanentRaidMover then DF.permanentRaidMover:Hide() end

    print("|cff00ff00DandersFrames:|r Raid frames unlocked. Drag to move, right-click to lock.")
end

function DF:LockRaidFrames()
    if not DF.raidContainer then return end
    
    local db = DF:GetRaidDB()
    db.raidLocked = true
    DF.positionPanelMode = nil  -- Clear mode
    
    DF.raidMoverFrame:Hide()

    -- Restore permanent mover visibility (keeps container movable if enabled)
    DF:UpdatePermanentMoverVisibility()

    -- Stop any OnUpdate for snap preview
    DF.raidMoverFrame:SetScript("OnUpdate", nil)
    
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
    
    -- Disable raid test mode using the proper function
    DF:HideRaidTestFrames()
    
    -- Hide container if not in raid
    if not IsInRaid() then
        DF.raidContainer:Hide()
    end
    
    -- Update button text if it exists
    if DF.raidLockButton and DF.raidLockButton.Text then
        DF.raidLockButton.Text:SetText("Unlock Raid Frames")
    end
    if DF.displayLockButton and DF.displayLockButton.Text then
        DF.displayLockButton.Text:SetText("Unlock Frames")
    end
    
    -- Sync GUI toolbar buttons
    if DF.GUI then
        if DF.GUI.UpdateLockButtonState then DF.GUI.UpdateLockButtonState() end
        if DF.GUI.UpdateTestButtonState then DF.GUI.UpdateTestButtonState() end
    end
    
    print("|cff00ff00DandersFrames:|r Raid frames locked.")
end

-- ============================================================
-- CLICK-CAST REGISTRATION HELPERS
-- Centralised registration for Clique / Clicked / other click-cast addons.
--
-- There are two phases:
--   1. EARLY (frame creation at ADDON_LOADED) — just mark the frame as
--      needing click-cast registration. We do NOT write to ClickCastFrames
--      yet because Clique's __newindex metatable may not be installed.
--      Writing to a plain table means __newindex never fires for that key,
--      even after Clique later replaces the table with a metatable.
--
--   2. LATE (PLAYER_ENTERING_WORLD+0.5s via RegisterClickCastFrames /
--      RegisterRaidClickCastFrames) — now Clique's metatable is in place,
--      so we write ClickCastFrames[frame] = true and Clique picks it up.
--      The dfClickCastRegistered flag prevents writing more than once.
-- ============================================================

-- Register a frame for click-casting (Clique, Clicked, etc.)
--
-- Before PLAYER_ENTERING_WORLD, just marks the frame — we don't write to
-- ClickCastFrames yet because Clique's __newindex metatable may not be
-- installed. Writing to a plain table means __newindex never fires for
-- that key, even after Clique later replaces the table with a metatable.
--
-- After PLAYER_ENTERING_WORLD (clickCastReady = true), writes directly
-- to ClickCastFrames so Clique's metatable picks up the registration.
-- The dfClickCastRegistered flag prevents writing more than once.
function DF:RegisterFrameWithClickCast(frame)
    if not frame then return end
    if frame.dfClickCastRegistered then return end

    if DF.clickCastReady and ClickCastFrames then
        ClickCastFrames[frame] = true
        frame.dfClickCastRegistered = true
    else
        -- Mark for deferred registration
        frame.dfNeedsClickCast = true
    end
end

function DF:UnregisterFrameWithClickCast(frame)
    if not frame then return end
    if ClickCastFrames then
        ClickCastFrames[frame] = false
    end
    frame.dfClickCastRegistered = nil
    frame.dfNeedsClickCast = nil
end

-- Commit all deferred registrations. Called once at PLAYER_ENTERING_WORLD
-- after Clique's metatable is in place.
--
-- Iterates ALL header children directly (not via unit-based lookups like
-- IteratePartyFrames/GetAllRaidFrames) because at commit time some frames
-- may not have units assigned yet (e.g., party frames when solo-queuing
-- for a dungeon — the header pre-creates children but units aren't set
-- until group members actually appear).
function DF:CommitAllClickCastRegistrations()
    DF.clickCastReady = true

    local function commitFrame(frame)
        if frame and frame.dfNeedsClickCast and not frame.dfClickCastRegistered then
            if ClickCastFrames then
                ClickCastFrames[frame] = true
            end
            frame.dfClickCastRegistered = true
            frame.dfNeedsClickCast = nil
        end
    end

    -- Party header children (player + party1-4)
    if DF.partyHeader then
        for i = 1, 5 do
            commitFrame(DF.partyHeader:GetAttribute("child" .. i))
        end
    end

    -- Arena header children
    if DF.arenaHeader then
        for i = 1, 5 do
            commitFrame(DF.arenaHeader:GetAttribute("child" .. i))
        end
    end

    -- Raid separated headers (8 groups x 5)
    if DF.raidSeparatedHeaders then
        for g = 1, 8 do
            local header = DF.raidSeparatedHeaders[g]
            if header then
                for i = 1, 5 do
                    commitFrame(header:GetAttribute("child" .. i))
                end
            end
        end
    end

    -- Flat raid header (up to 40)
    if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
        for i = 1, 40 do
            commitFrame(DF.FlatRaidFrames.header:GetAttribute("child" .. i))
        end
    end

    -- Combined raid header
    if DF.raidCombinedHeader then
        for i = 1, 40 do
            commitFrame(DF.raidCombinedHeader:GetAttribute("child" .. i))
        end
    end

    -- Pet frames
    if DF.petFrames then
        for _, frame in pairs(DF.petFrames) do
            commitFrame(frame)
        end
    end

    -- Pinned frames headers
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header then
                for i = 1, 40 do
                    commitFrame(header:GetAttribute("child" .. i))
                end
            end
        end
    end

    -- Pinned boss frames
    if DF.PinnedFrames and DF.PinnedFrames.bossFrames then
        for setIndex = 1, 2 do
            local frames = DF.PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    commitFrame(frames[i])
                end
            end
        end
    end
end

-- Legacy functions — now just call CommitAllClickCastRegistrations
function DF:RegisterRaidClickCastFrames()
    DF:CommitAllClickCastRegistrations()
end

function DF:RegisterClickCastFrames()
    DF:CommitAllClickCastRegistrations()
end

-- ============================================================
-- UPDATE LIVE RAID FRAMES (when actually in a raid)
-- ============================================================
function DF:UpdateLiveRaidFrames()
    -- Debug: Track what's calling UpdateLiveRaidFrames
    if DF.debugFlatLayout then
        print("|cFFFF00FF[DF Flat Debug]|r UpdateLiveRaidFrames() called!")
        print("  Full stack: " .. (debugstack(2, 10, 0) or "unknown"))
    end
    
    -- Don't show live frames while in test mode
    if DF.testMode or DF.raidTestMode then
        return
    end
    
    -- Use header system if available (new mode)
    if DF.headersCreated then
        -- ARENA GUARD: Arena uses partyContainer + arenaHeader, NOT raidContainer.
        -- IsInRaid()=true in arena, so without this guard we'd show raid frames
        -- and hide partyContainer (destroying the arena header).
        if DF.IsInArena and DF:IsInArena() then
            return
        end
        
        -- Header system handles raid frames via SecureGroupHeaderTemplate
        -- Just need to show the raid container and headers
        if InCombatLockdown() then
            DF.pendingRaidVisibilityUpdate = true
            return
        end
        
        local db = DF:GetRaidDB()
        
        -- Check if raid frames are enabled
        if not db.raidEnabled then
            if DF.raidContainer then
                DF.raidContainer:Hide()
            end
            return
        end
        
        -- Show raid container
        if DF.raidContainer then
            DF.raidContainer:Show()
            -- NOTE: Don't ClearAllPoints/SetPoint here on every call!
            -- Container position is set when entering raid or when settings change.
            -- Repositioning on roster updates causes visual shifting.
        end
        
        -- Update header visibility (show/hide based on group mode)
        DF:UpdateRaidHeaderVisibility()
        
        -- NOTE: We intentionally do NOT call PositionRaidHeaders() here!
        -- PositionRaidHeaders clears child anchor points and triggers a full
        -- re-layout, causing visual shifting when roster changes.
        -- The SecureGroupHeaderTemplate handles child positioning automatically.
        -- Container/header positioning should only happen when SETTINGS change.
        
        -- Hide party container when in raid (party headers are hidden by UpdateHeaderVisibility)
        if DF.container then
            DF.container:Hide()
        end
        if DF.partyContainer then
            DF.partyContainer:Hide()
        end

        -- Update pet frames (must be called in header mode too, not just legacy mode)
        if DF.UpdateAllPetFrames then
            DF:UpdateAllPetFrames()
        end

        return
    end

    -- LEGACY MODE: Old code for non-header system (fallback)
    if not DF.raidContainer then return end
    if not DF.initialized then return end
    
    -- Safety check: Arenas use arena header, not raid frames
    local contentType = DF:GetContentType()
    local inArena = (contentType == "arena")
    if inArena then
        DF.raidContainer:Hide()
        DF:UpdateAllFrames()
        return
    end
    
    -- Protect against calling during combat
    if InCombatLockdown() then
        DF.needsUpdate = true
        return
    end
    
    local db = DF:GetRaidDB()
    
    -- Check if raid frames are enabled
    if not db.raidEnabled then
        DF.raidContainer:Hide()
        return
    end
    
    -- Show raid container
    DF.raidContainer:Show()
    
    -- Update raid container position
    local raidScale = db.frameScale or 1.0
    DF.raidContainer:SetScale(raidScale)
    DF.raidContainer:ClearAllPoints()
    DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", (db.raidAnchorX or 0) / raidScale, (db.raidAnchorY or 0) / raidScale)
    
    -- Legacy: Update layout only if legacy frames exist
    if DF.raidFrames and DF.raidFrames[1] then
        -- Update the layout (this positions frames)
        if db.raidUseGroups then
            DF:UpdateRaidLayout()
        else
            DF:UpdateRaidFlatLayout()
        end
        
        -- Register unit watches and fully update frames for existing raid members
        for i = 1, 40 do
            local frame = DF.raidFrames[i]
            if frame then
                frame.unit = "raid" .. i
                
                -- Use RegisterUnitWatch to automatically show/hide based on unit existence
                DF:SafeRegisterUnitWatch(frame)
                
                -- Apply style
                DF:ApplyFrameStyle(frame)
                
                -- Full update if unit exists
                if UnitExists(frame.unit) then
                    DF:UpdateUnitFrame(frame)
                    if DF.UpdateAuras then DF:UpdateAuras(frame) end
                    if DF.UpdateRoleIcon then DF:UpdateRoleIcon(frame) end
                    if DF.UpdateLeaderIcon then DF:UpdateLeaderIcon(frame) end
                    if DF.UpdateRaidTargetIcon then DF:UpdateRaidTargetIcon(frame) end
                    if DF.UpdateReadyCheckIcon then DF:UpdateReadyCheckIcon(frame) end
                    if DF.UpdateCenterStatusIcon then DF:UpdateCenterStatusIcon(frame) end
                    if DF.UpdateMissingBuffIcon and not InCombatLockdown() then DF:UpdateMissingBuffIcon(frame) end
                    if DF.UpdateExternalDefIcon then DF:UpdateExternalDefIcon(frame) end
                end
                
                DF:RegisterFrameWithClickCast(frame)
            end
        end
    end

    -- Hide party frames when in raid (legacy mode)
    if DF.container then
        DF.container:Hide()
    end
    if DF.playerFrame then
        UnregisterUnitWatch(DF.playerFrame)
        DF.playerFrame:Hide()
    end
    for i = 1, 4 do
        local frame = DF.partyFrames[i]
        if frame then
            UnregisterUnitWatch(frame)
            frame:Hide()
        end
    end
    
    -- Update raid pet frames
    if DF.UpdateAllRaidPetFrames then
        DF:UpdateAllRaidPetFrames()
    end
end

-- ============================================================
-- HIDE LIVE RAID FRAMES (when leaving a raid)
-- ============================================================
function DF:HideLiveRaidFrames()
    if InCombatLockdown() then
        DF.needsUpdate = true
        return
    end
    
    -- Hide raid container
    if DF.raidContainer then
        DF.raidContainer:Hide()
    end
    
    -- Hide raid headers (header mode)
    if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
        DF.FlatRaidFrames.header:Hide()
    end
    if DF.raidSeparatedHeaders then
        for i = 1, 8 do
            if DF.raidSeparatedHeaders[i] then
                DF.raidSeparatedHeaders[i]:Hide()
            end
        end
    end
    
    -- Unregister unit watches for legacy raid frames (if they exist)
    if DF.raidFrames then
        for i = 1, 40 do
            local frame = DF.raidFrames[i]
            if frame then
                UnregisterUnitWatch(frame)
                frame:Hide()
            end
        end
    end
    
    -- Show party container (header mode uses partyContainer)
    -- But not if test mode is active
    if DF.testMode or DF.raidTestMode then
        return
    end
    
    if DF.headersCreated and DF.partyContainer then
        DF.partyContainer:Show()
    elseif DF.container then
        DF.container:Show()
    end
end

function DF:UpdateAllFrames()
    -- Debug: Track what's calling UpdateAllFrames
    if DF.debugFlatLayout then
        print("|cFFFF00FF[DF Flat Debug]|r UpdateAllFrames() called!")
        print("  Full stack: " .. (debugstack(2, 10, 0) or "unknown"))
    end
    
    -- Header mode: party frames are managed by SecureGroupHeaderTemplate
    -- This function is called when NOT in a raid, to show party frames
    if DF.headersCreated then
        if InCombatLockdown() then
            DF.needsUpdate = true
            return
        end
        
        -- If in test mode, update test frames instead of live frames
        if DF.testMode or DF.raidTestMode then
            -- Still apply settings to live frames (they're hidden but need to stay in sync)
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(frame)
                    if frame and DF.ApplyFrameLayout then
                        DF:ApplyFrameLayout(frame)
                    end
                end)
            end
            
            -- Update test frames with new layout settings
            if DF.RefreshTestFramesWithLayout then
                DF:RefreshTestFramesWithLayout()
            end
            return
        end
        
        -- Show party container
        if DF.partyContainer then
            DF.partyContainer:Show()
        end
        
        -- Update header visibility (this shows/hides based on group status)
        if DF.UpdateHeaderVisibility then
            DF:UpdateHeaderVisibility()
        end
        
        -- Apply settings to all header children (party, raid, or arena)
        -- NOTE: This only applies LAYOUT settings (size, texture, etc.)
        -- Unit data updates (health, role icons, etc.) are handled by:
        -- - OnAttributeChanged -> FullFrameRefresh (unit changes)
        -- - headerChildEventFrame (PLAYER_ROLES_ASSIGNED, RAID_TARGET_UPDATE, etc.)
        -- - UNIT_* events (health, auras, power)
        -- IterateAllFrames routes to arena frames when in arena,
        -- party+raid frames otherwise — so layout changes always hit the correct frames.
        if DF.IterateAllFrames then
            DF:IterateAllFrames(function(frame)
                if frame and frame.dfIsHeaderChild then
                    if DF.ApplyFrameLayout then
                        DF:ApplyFrameLayout(frame)
                    end
                end
            end)
        end
        
        -- NOTE: We intentionally do NOT call ApplyHeaderSettings() here!
        -- ApplyHeaderSettings() repositions headers and containers, which causes
        -- visual shifting when roster changes. It should ONLY be called when
        -- settings actually change (from Options UI, profile switches, etc.),
        -- not during roster updates.
        -- The SecureGroupHeaderTemplate handles child positioning automatically.

        -- Update pet frames (must be called in header mode too, not just legacy mode)
        if DF.UpdateAllPetFrames then
            DF:UpdateAllPetFrames()
        end

        return
    end
    
    -- LEGACY MODE: Original UpdateAllFrames code
    if not DF.container then return end
    if not DF.initialized then return end
    
    -- Protect against calling during combat (secure frame operations would fail)
    if InCombatLockdown() then
        DF.needsUpdate = true
        return
    end
    
    -- If in a raid (and not in test mode), redirect to raid frames
    -- Use unified content type detection - arena uses arena header, not raid frames
    local contentType = DF:GetContentType()
    local inArena = (contentType == "arena")
    if IsInRaid() and not inArena and not DF.testMode and not DF.raidTestMode then
        DF:UpdateLiveRaidFrames()
        return
    end
    
    local db = DF:GetDB()
    
    -- Check group status
    local inGroup = IsInGroup()
    local numPartyMembers = GetNumSubgroupMembers()
    
    -- DEBUG
    if DF.debugEnabled then
        print("|cffff00ffDF DEBUG:|r UpdateAllFrames called")
        print("  inGroup:", inGroup)
        print("  numPartyMembers:", numPartyMembers)
        print("  testMode:", DF.testMode)
        print("  db.soloMode:", db.soloMode)
        print("  db.soloMode == true:", db.soloMode == true)
    end
    
    -- Determine what to show:
    -- Test Mode: show everything (player + 4 party frames)
    -- In Group: show player + party members
    -- Solo Mode (not in group): show player only
    -- No Solo Mode (not in group): show nothing
    -- hidePlayerFrame: completely hide player frame (except in test mode)
    -- raidTestMode: hide party frames entirely (raid test mode uses separate raid frames)
    
    -- When in raid test mode, hide party/player frames entirely
    local showPlayerFrame = (DF.testMode and not DF.raidTestMode) or ((inGroup or (db.soloMode == true)) and not db.hidePlayerFrame and not DF.raidTestMode)
    local showPartyFrames = (DF.testMode and not DF.raidTestMode) or (inGroup and not DF.raidTestMode)
    
    if DF.debugEnabled then
        print("  showPlayerFrame:", showPlayerFrame)
        print("  showPartyFrames:", showPartyFrames)
        print("  hidePlayerFrame:", db.hidePlayerFrame)
        print("  raidTestMode:", DF.raidTestMode)
    end
    
    -- Update container position (always use CENTER for consistency with position panel)
    local partyScale = db.frameScale or 1.0
    DF.container:SetScale(partyScale)
    DF.container:ClearAllPoints()
    DF.container:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / partyScale, (db.anchorY or 0) / partyScale)
    DF.container:Show()  -- Ensure container is visible
    
    -- Calculate layout
    local spacing = db.frameSpacing or 4
    local horizontal = db.growDirection == "HORIZONTAL"
    
    -- Apply pixel-perfect adjustments for positioning calculations
    local ppFrameWidth = db.pixelPerfect and DF:PixelPerfect(db.frameWidth or 120) or (db.frameWidth or 120)
    local ppFrameHeight = db.pixelPerfect and DF:PixelPerfect(db.frameHeight or 50) or (db.frameHeight or 50)
    local ppSpacing = db.pixelPerfect and DF:PixelPerfect(spacing) or spacing
    
    -- Get growth anchor (START/CENTER/END)
    local growthAnchor = db.growthAnchor or "START"
    
    -- First pass: count how many frames will be shown
    local testFrameCount = db.testFrameCount or 5
    local visibleFrames = {}
    
    -- Check player frame
    -- In test mode, use testFrameCount; otherwise use normal logic
    local showPlayerInTest = DF.testMode and testFrameCount >= 1
    if showPlayerFrame or showPlayerInTest then
        local entry = {frame = DF.playerFrame, index = 0, isPlayer = true, unit = "player"}
        -- Add test data for sorting in test mode
        if DF.testMode then
            entry.testData = DF:GetTestUnitData(0, false)  -- false = not raid
        end
        table.insert(visibleFrames, entry)
    end
    
    -- Check party frames
    for i = 1, 4 do
        local frame = DF.partyFrames[i]
        if frame then
            -- In test mode, ONLY use testFrameCount (ignore actual party size)
            -- Outside test mode, use actual party membership
            local showThisFrame
            if DF.testMode then
                showThisFrame = (i + 1) <= testFrameCount
            else
                showThisFrame = inGroup and i <= numPartyMembers
            end
            
            if showPartyFrames and showThisFrame then
                local entry = {frame = frame, index = i, isPlayer = false, unit = "party" .. i}
                -- Add test data for sorting in test mode
                if DF.testMode then
                    entry.testData = DF:GetTestUnitData(i, false)  -- false = not raid
                end
                table.insert(visibleFrames, entry)
            end
        end
    end
    
    -- TODO: CLEANUP - Old sorting commented out
    -- SecureSort now handles all party frame sorting/positioning
    -- This was only used to determine iteration order for visibility setup,
    -- which doesn't depend on sort order.
    --[[
    -- Apply sorting if enabled
    if db.sortEnabled and DF.Sort then
        visibleFrames = DF.Sort:SortFrameList(visibleFrames, db, DF.testMode)
    end
    --]]
    
    local frameCount = #visibleFrames
    
    -- Calculate sizes (use pixel-perfect values)
    local maxFrameCount = 5  -- Maximum party size
    local actualWidth = frameCount > 0 and (frameCount * (ppFrameWidth + ppSpacing) - ppSpacing) or 0
    local actualHeight = frameCount > 0 and (frameCount * (ppFrameHeight + ppSpacing) - ppSpacing) or 0
    local maxWidth = maxFrameCount * (ppFrameWidth + ppSpacing) - ppSpacing
    local maxHeight = maxFrameCount * (ppFrameHeight + ppSpacing) - ppSpacing
    
    -- Set outer container to max size (for consistent dragging area)
    if horizontal then
        DF.container:SetSize(maxWidth, ppFrameHeight)
    else
        DF.container:SetSize(ppFrameWidth, maxHeight)
    end
    
    -- Create party group container if needed (holds actual frames, sized to visible frames)
    -- NOTE: Using SecureFrameTemplate so secure code can SetPoint relative to this frame
    if not DF.partyGroupContainer then
        DF.partyGroupContainer = CreateFrame("Frame", "DandersPartyGroupContainer", DF.container, "SecureFrameTemplate")
    end
    
    -- Size party group container to actual visible frames
    if frameCount > 0 then
        if horizontal then
            DF.partyGroupContainer:SetSize(actualWidth, ppFrameHeight)
        else
            DF.partyGroupContainer:SetSize(ppFrameWidth, actualHeight)
        end
        DF.partyGroupContainer:Show()
    else
        -- NOTE: Even with 0 visible frames, we keep the container visible (but 1x1 size)
        -- when NOT in test mode. This allows party frames to appear during combat
        -- when someone joins. RegisterUnitWatch will show the frames inside.
        DF.partyGroupContainer:SetSize(1, 1)
        if DF.testMode then
            DF.partyGroupContainer:Hide()
        else
            DF.partyGroupContainer:Show()  -- Keep visible for combat party joins
        end
    end
    
    -- Anchor party group container based on growthAnchor
    DF.partyGroupContainer:ClearAllPoints()
    if horizontal then
        -- Horizontal layout - anchor controls left/center/right
        if growthAnchor == "START" then
            DF.partyGroupContainer:SetPoint("LEFT", DF.container, "LEFT", 0, 0)
        elseif growthAnchor == "CENTER" then
            DF.partyGroupContainer:SetPoint("CENTER", DF.container, "CENTER", 0, 0)
        else -- END
            DF.partyGroupContainer:SetPoint("RIGHT", DF.container, "RIGHT", 0, 0)
        end
    else
        -- Vertical layout - anchor controls top/center/bottom
        if growthAnchor == "START" then
            DF.partyGroupContainer:SetPoint("TOP", DF.container, "TOP", 0, 0)
        elseif growthAnchor == "CENTER" then
            DF.partyGroupContainer:SetPoint("CENTER", DF.container, "CENTER", 0, 0)
        else -- END
            DF.partyGroupContainer:SetPoint("BOTTOM", DF.container, "BOTTOM", 0, 0)
        end
    end
    
    -- Position each frame within the party group container
    -- TODO: CLEANUP - This old positioning code is commented out.
    -- SecureSort now handles ALL party frame positioning via secure code.
    -- Remove this block entirely once we confirm SecureSort works in all cases.
    --[[
    -- LEGACY POSITIONING CODE - COMMENTED OUT
    local secureSortActive = DF.SecureSort and DF.SecureSort.initialized and DF.SecureSort.framesRegistered
    
    for idx, frameData in ipairs(visibleFrames) do
        local frame = frameData.frame
        local slotIndex = idx - 1  -- 0-based slot index
        
        -- Reparent to party group container
        frame:SetParent(DF.partyGroupContainer)
        
        -- Only position frames if SecureSort is NOT active
        -- SecureSort handles all positioning via TriggerSecureSort
        if not secureSortActive then
            frame:ClearAllPoints()
            
            -- Use SecureSort positioning functions (handles all growth modes: START/CENTER/END)
            if DF.SecureSort and DF.SecureSort.CalculateSlotPosition then
                local layoutParams = {
                    frameWidth = ppFrameWidth,
                    frameHeight = ppFrameHeight,
                    spacing = ppSpacing,
                    horizontal = horizontal,
                    growthAnchor = growthAnchor,
                }
                local x, y = DF.SecureSort:CalculateSlotPosition(slotIndex, frameCount, layoutParams)
                local anchor, relAnchor = DF.SecureSort:GetSlotAnchors(layoutParams)
                frame:SetPoint(anchor, DF.partyGroupContainer, relAnchor, x, y)
            else
                -- Fallback: Simple START-only positioning (legacy behavior)
                if horizontal then
                    local x = slotIndex * (ppFrameWidth + ppSpacing)
                    frame:SetPoint("LEFT", DF.partyGroupContainer, "LEFT", x, 0)
                else
                    local y = -slotIndex * (ppFrameHeight + ppSpacing)
                    frame:SetPoint("TOP", DF.partyGroupContainer, "TOP", 0, y)
                end
            end
        end
    end
    --]]
    
    -- SecureSort handles positioning - we just need to set up visibility and content
    for idx, frameData in ipairs(visibleFrames) do
        local frame = frameData.frame
        
        -- Reparent to party group container (SecureSort positions relative to this)
        frame:SetParent(DF.partyGroupContainer)
        
        -- Handle visibility and updates
        if frameData.isPlayer then
            if not DF.testMode then
                DF:SafeRegisterUnitWatch(frame)
            else
                UnregisterUnitWatch(frame)
            end
            frame:Show()
            -- Register with click-cast addons when shown
            DF:RegisterFrameWithClickCast(frame)
            DF:ApplyFrameStyle(frame)
            if DF.testMode then
                DF:UpdateTestFrame(frame, 0)
            else
                DF:UpdateFrame(frame)
            end
        else
            if DF.testMode then
                UnregisterUnitWatch(frame)
                frame:Show()
                -- Register with click-cast addons when shown
                DF:RegisterFrameWithClickCast(frame)
                DF:ApplyFrameStyle(frame)  -- Apply style BEFORE UpdateTestFrame so dead fade isn't lost
                DF:UpdateTestFrame(frame, frameData.index)
            else
                DF:SafeRegisterUnitWatch(frame)
                -- Register with click-cast addons
                DF:RegisterFrameWithClickCast(frame)
                DF:ApplyFrameStyle(frame)
                DF:UpdateFrame(frame)
            end
        end
    end
    
    -- IMPORTANT: When NOT in test mode, ensure ALL party frames are parented to
    -- partyGroupContainer and have styles applied. This is necessary for frames
    -- that aren't currently visible (e.g., when solo) but may appear during combat
    -- when party members join. RegisterUnitWatch will handle showing them.
    if not DF.testMode then
        -- Player frame
        if DF.playerFrame then
            DF.playerFrame:SetParent(DF.partyGroupContainer)
            DF:ApplyFrameStyle(DF.playerFrame)
        end
        -- All party frames (even if currently invisible)
        for i = 1, 4 do
            local frame = DF.partyFrames[i]
            if frame then
                frame:SetParent(DF.partyGroupContainer)
                DF:ApplyFrameStyle(frame)
            end
        end
    end
    
    -- Hide frames that aren't visible
    -- NOTE: We only unregister from unit watch in test mode.
    -- Outside test mode, we ALWAYS keep RegisterUnitWatch active so frames
    -- can appear/disappear securely during combat when party members join/leave.
    
    -- IMPORTANT: Register party frames with RegisterUnitWatch when not in test mode.
    -- This ensures frames can appear during combat when party members join.
    -- RegisterUnitWatch will automatically show/hide based on UnitExists().
    if not DF.testMode then
        -- Register player frame only if it should be shown (solo mode enabled or in group)
        if DF.playerFrame then
            if showPlayerFrame then
                DF:SafeRegisterUnitWatch(DF.playerFrame)
            else
                DF:SafeUnregisterUnitWatch(DF.playerFrame)
                DF:UnregisterFrameWithClickCast(DF.playerFrame)
            end
        end
        -- Always register ALL party frames (1-4), even if currently solo
        -- Party frames use "party1"-"party4" units which only exist when in a group
        for i = 1, 4 do
            local frame = DF.partyFrames[i]
            if frame then
                DF:SafeRegisterUnitWatch(frame)
            end
        end
    end
    
    -- Handle test mode player frame visibility
    if DF.testMode and not (testFrameCount >= 1) then
        UnregisterUnitWatch(DF.playerFrame)
        DF.playerFrame:Hide()
        DF:UnregisterFrameWithClickCast(DF.playerFrame)
    end

    for i = 1, 4 do
        local frame = DF.partyFrames[i]
        if frame then
            -- In test mode, ONLY use testFrameCount (ignore actual party size)
            local showThisFrame
            if DF.testMode then
                showThisFrame = (i + 1) <= testFrameCount
            else
                showThisFrame = inGroup and i <= numPartyMembers
            end
            
            if not (showPartyFrames and showThisFrame) then
                if DF.testMode then
                    -- Test mode: we control visibility manually
                    UnregisterUnitWatch(frame)
                    frame:Hide()
                end
                -- Outside test mode: do NOT unregister - let RegisterUnitWatch handle
                -- visibility so frames can appear during combat when party members join
                -- Unregister from click-cast addons when hidden
                DF:UnregisterFrameWithClickCast(frame)
            end
        end
    end
    
    -- Update mover - always show full 5-player size when unlocked so user can see full group footprint
    if DF.moverFrame then
        DF.moverFrame:ClearAllPoints()
        DF.moverFrame:SetAllPoints(DF.container)
        if horizontal then
            DF.moverFrame:SetSize(maxWidth, ppFrameHeight)
        else
            DF.moverFrame:SetSize(ppFrameWidth, maxHeight)
        end
    end
    
    -- Update role icons (not called from UpdateFrame to prevent flickering)
    if DF.UpdateAllRoleIcons and not DF.testMode then
        DF:UpdateAllRoleIcons()
    end
    
    -- Also update raid frames if in raid test mode
    if DF.raidTestMode then
        DF:UpdateRaidTestFrames()
    end
    
    -- Update pet frames
    if DF.UpdateAllPetFrames then
        DF:UpdateAllPetFrames()
    end
    
    -- Update SecureSort layout params when layout changes (Phase 2.5)
    -- This ensures combat buttons use the correct layout settings
    if DF.SecureSort and not InCombatLockdown() then
        -- Try to initialize SecureSort if not done yet
        if not DF.SecureSort.initialized and DF.initialized then
            DF.SecureSort:Initialize()
        end
        
        if DF.SecureSort.initialized then
            DF.SecureSort:UpdateLayoutParams("party")
            
            -- Auto-register frames if not done yet (catches early initialization)
            if not DF.SecureSort.framesRegistered and DF.playerFrame then
                DF.SecureSort:RegisterPartyFrames()
            end
            
            -- In test mode, use Sort module with test data for positioning
            -- (SecureSort can't access test data, only real unit roles)
            if DF.testMode and DF.Sort and DF.Sort.SortFrameList then
                local lp = DF.SecureSort.layoutParams
                
                -- Build frame list with test data
                local frameList = {}
                if DF.playerFrame and testFrameCount >= 1 then
                    local testData = DF:GetTestUnitData(0, false)
                    table.insert(frameList, {
                        frame = DF.playerFrame,
                        index = 0,
                        isPlayer = true,
                        testData = testData
                    })
                end
                if DF.partyFrames then
                    for i = 1, 4 do
                        local frame = DF.partyFrames[i]
                        if frame and (i + 1) <= testFrameCount then
                            local testData = DF:GetTestUnitData(i, false)
                            table.insert(frameList, {
                                frame = frame,
                                index = i,
                                isPlayer = false,
                                testData = testData
                            })
                        end
                    end
                end
                
                -- Apply sorting if enabled
                if db.sortEnabled then
                    frameList = DF.Sort:SortFrameList(frameList, db, true)
                end
                
                -- Position frames in sorted order
                for slotIndex, entry in ipairs(frameList) do
                    local slot = slotIndex - 1
                    DF.SecureSort:PositionFrameToSlot(entry.frame, slot, #frameList, lp, DF.partyGroupContainer)
                end
            elseif DF.SecureSort.framesRegistered then
                -- Not in test mode - use SecureSort for real unit positioning
                DF.SecureSort:TriggerSecureSort("UpdateAllFrames")
            end
        end
    end
end

