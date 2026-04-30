local addonName, DF = ...

-- ============================================================
-- PINNED FRAMES - Separate frame sets for selected players
-- Uses SecureGroupHeaderTemplate with nameList for explicit control
-- ============================================================

local format = string.format

local PinnedFrames = {}
DF.PinnedFrames = PinnedFrames

-- Storage for headers and containers
PinnedFrames.containers = {}  -- [setIndex] = container frame
PinnedFrames.headers = {}     -- [setIndex] = SecureGroupHeaderTemplate
PinnedFrames.labels = {}      -- [setIndex] = label fontstring
PinnedFrames.bossFrames = {}  -- [setIndex] = { [1..8] = boss frame }
PinnedFrames.bossHandlers = {}  -- [setIndex] = SecureHandlerStateTemplate frame (drives fixed-slot allocator for boss frames)
PinnedFrames.testFrames = {}    -- [setIndex] = { [1..N] = fake non-secure test frame (player-mode Test Mode)}
PinnedFrames.testContainers = {} -- [setIndex] = non-secure container at the test-mode profile's position for this set
PinnedFrames.initialized = false
PinnedFrames.currentMode = nil  -- Track what mode we initialized for

-- Color palette per mode (raid = orange, party = purple-blue)
-- Matches C_RAID / C_ACCENT used across the GUI
local function GetModeColors(isRaid)
    if isRaid then
        return {
            containerBg     = { 0.30, 0.15, 0.05, 0.30 },
            containerBorder = { 0.80, 0.40, 0.15, 0.80 },
            moverBg         = { 0.40, 0.20, 0.05, 0.90 },
            moverBorder     = { 1.00, 0.50, 0.20, 1.00 },
            moverText       = { 1.00, 0.80, 0.50 },
        }
    end
    return {
        containerBg     = { 0.10, 0.10, 0.30, 0.30 },
        containerBorder = { 0.40, 0.40, 0.80, 0.80 },
        moverBg         = { 0.20, 0.20, 0.40, 0.90 },
        moverBorder     = { 0.50, 0.50, 0.90, 1.00 },
        moverText       = { 0.80, 0.80, 1.00 },
    }
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Get pinned frames config for actual current mode
local function GetPinnedDB()
    local db = IsInRaid() and DF:GetRaidDB() or DF:GetDB()
    return db and db.pinnedFrames
end

-- Get the current actual mode (not cached)
local function GetActualMode()
    return IsInRaid() and "raid" or "party"
end

-- Get a specific set's config
local function GetSetDB(setIndex)
    local hlDB = GetPinnedDB()
    return hlDB and hlDB.sets and hlDB.sets[setIndex]
end

-- Returns true if the set is configured to show friendly boss NPCs instead of players
local function IsBossSet(set)
    return set and set.frameType == "friendlyBoss"
end

-- Build nameList from player array
-- Uses full names (including realm for cross-realm players) to match WoW's nameList format
local function BuildNameList(players)
    if not players or #players == 0 then
        return ""
    end
    
    -- Just join the names with commas - don't strip realms
    return table.concat(players, ",")
end

-- Get current group roster as a lookup table
-- Returns both the roster lookup AND the actual names from GetRaidRosterInfo
local function GetGroupRoster()
    local roster = {}          -- shortName -> rosterName (for lookup)
    local rosterNames = {}     -- list of actual roster names (for nameList)
    local numMembers = GetNumGroupMembers()
    
    if numMembers == 0 then
        local name = GetUnitName("player", true)  -- Returns "Name-Realm"
        roster[name] = name
        table.insert(rosterNames, name)
        return roster, rosterNames
    end
    
    local isRaid = IsInRaid()
    
    if isRaid then
        -- Use GetRaidRosterInfo which returns exact name format for nameList
        for i = 1, numMembers do
            local name = GetRaidRosterInfo(i)
            if name then
                -- Store both the full name and short name for lookup
                roster[name] = name
                local shortName = name:match("([^%-]+)") or name
                if shortName ~= name then
                    roster[shortName] = name  -- Map short name to full roster name
                end
                table.insert(rosterNames, name)
            end
        end
    else
        -- Party mode
        local playerName = GetUnitName("player", true)  -- Returns "Name-Realm"
        roster[playerName] = playerName
        table.insert(rosterNames, playerName)
        
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local fullName = GetUnitName(unit, true)  -- Returns "Name-Realm", avoids secret value taint
                if fullName then
                    local name = fullName:match("([^%-]+)") or fullName
                    roster[fullName] = fullName
                    roster[name] = fullName  -- Map short name too
                    table.insert(rosterNames, fullName)
                end
            end
        end
    end
    
    return roster, rosterNames
end

-- Check if player is in current group, returns the roster name if found
local function IsPlayerInGroup(fullName, roster)
    roster = roster or GetGroupRoster()
    
    -- First check if full name (with realm) is in roster
    if roster[fullName] then
        return roster[fullName]  -- Return the actual roster name
    end
    
    -- For same-realm players, also check short name
    local shortName = fullName:match("([^%-]+)") or fullName
    if roster[shortName] then
        return roster[shortName]  -- Return the actual roster name
    end
    
    return nil
end

-- ============================================================
-- AUTO-POPULATION
-- ============================================================

-- Auto-populate a single pinned set based on its settings
function PinnedFrames:AutoPopulateSet(set, roster)
    if not set then return false end

    local changed = false
    roster = roster or GetGroupRoster()

    -- Ensure manualPlayers table exists (migration for existing profiles)
    if not set.manualPlayers then set.manualPlayers = {} end

    local hasAnyAutoFilter = set.autoAddTanks or set.autoAddHealers or set.autoAddDPS

    -- Build lookup of current players in set
    local existingPlayers = {}
    for _, p in ipairs(set.players) do
        local name = p:match("([^%-]+)") or p
        existingPlayers[name] = true
    end

    -- Get group roster with role info
    local numMembers = GetNumGroupMembers()
    if numMembers == 0 then
        -- Solo mode: player role is always DAMAGER (no group role assignment)
        local fullName = GetUnitName("player", true)
        local shortName = fullName and fullName:match("([^%-]+)") or fullName

        -- Auto-add player if DPS filter is on
        if set.autoAddDPS and shortName and not existingPlayers[shortName] then
            table.insert(set.players, fullName)
            changed = true
        end

        -- Auto-remove: remove non-manual players whose role (DAMAGER) doesn't match filters
        if hasAnyAutoFilter then
            for i = #set.players, 1, -1 do
                local playerName = set.players[i]
                if not set.manualPlayers[playerName] then
                    -- Solo player is always DAMAGER
                    local pShort = playerName:match("([^%-]+)") or playerName
                    if pShort == shortName then
                        if not set.autoAddDPS then
                            table.remove(set.players, i)
                            changed = true
                        end
                    else
                        -- Not the current player — they left the group
                        -- CleanOfflinePlayers handles this case
                    end
                end
            end
        end

        return changed
    end

    -- Build name → role map for the removal pass
    local rosterRoles = {}  -- shortName -> role
    local isRaid = IsInRaid()
    for i = 1, numMembers do
        local unit = isRaid and ("raid" .. i) or (i == 1 and "player" or "party" .. (i - 1))
        local fullName = GetUnitName(unit, true)

        if fullName then
            local shortName = fullName:match("([^%-]+)") or fullName
            local role = UnitGroupRolesAssigned(unit)
            if role == "NONE" then role = "DAMAGER" end
            rosterRoles[shortName] = role
            rosterRoles[fullName] = role

            -- Auto-add pass: add players matching enabled role filters
            if not existingPlayers[shortName] then
                local shouldAdd = false
                if set.autoAddTanks and role == "TANK" then
                    shouldAdd = true
                elseif set.autoAddHealers and role == "HEALER" then
                    shouldAdd = true
                elseif set.autoAddDPS and role == "DAMAGER" then
                    shouldAdd = true
                end

                if shouldAdd then
                    table.insert(set.players, fullName)
                    existingPlayers[shortName] = true
                    changed = true
                end
            end
        end
    end

    -- Auto-remove pass: remove players whose role no longer matches any filter
    -- Only runs when at least one auto-add filter is active
    if hasAnyAutoFilter then
        for i = #set.players, 1, -1 do
            local playerName = set.players[i]

            -- Never remove manually added players
            if set.manualPlayers[playerName] then
                -- skip
            else
                -- Only evaluate players still in the group
                -- (offline/left players are handled by CleanOfflinePlayers)
                local role = rosterRoles[playerName]
                if role then
                    local matchesFilter = false
                    if set.autoAddTanks and role == "TANK" then
                        matchesFilter = true
                    elseif set.autoAddHealers and role == "HEALER" then
                        matchesFilter = true
                    elseif set.autoAddDPS and role == "DAMAGER" then
                        matchesFilter = true
                    end

                    if not matchesFilter then
                        table.remove(set.players, i)
                        changed = true
                    end
                end
            end
        end
    end

    return changed
end

-- Clean up offline players from a set
function PinnedFrames:CleanOfflinePlayers(set, roster)
    if not set or set.keepOfflinePlayers then return false end
    
    roster = roster or GetGroupRoster()
    local changed = false
    
    for i = #set.players, 1, -1 do
        local fullName = set.players[i]
        if not IsPlayerInGroup(fullName, roster) then
            table.remove(set.players, i)
            changed = true
        end
    end
    
    return changed
end

-- Process all pinned sets for current mode
function PinnedFrames:ProcessAllSets()
    local hlDB = GetPinnedDB()
    if not hlDB or not hlDB.sets then return false end

    -- Skip processing if no sets are enabled (avoids unnecessary work in arena)
    local anyEnabled = false
    for i = 1, 2 do
        if hlDB.sets[i] and hlDB.sets[i].enabled then
            anyEnabled = true
            break
        end
    end
    if not anyEnabled then return false end

    local roster = GetGroupRoster()
    local changed = false
    
    for i = 1, 2 do
        local set = hlDB.sets[i]
        if set then
            if self:AutoPopulateSet(set, roster) then
                changed = true
            end
            if self:CleanOfflinePlayers(set, roster) then
                changed = true
            end
        end
    end
    
    if changed then
        self:UpdateAllHeaders()
    end

    return changed
end

-- Register/unregister boss frames in unitFrameMap based on visibility
function PinnedFrames:UpdateBossFrameMapEntries(setIndex)
    if not DF.unitFrameMap then return end
    local frames = self.bossFrames[setIndex]
    if not frames then return end

    for i = 1, 8 do
        local f = frames[i]
        if f then
            local unit = "boss" .. i
            if f:IsShown() then
                DF.unitFrameMap[unit] = f
                f.dfEventsEnabled = true
            else
                if DF.unitFrameMap[unit] == f then
                    DF.unitFrameMap[unit] = nil
                end
                f.dfEventsEnabled = false
            end
        end
    end
end

-- Called when boss units change (appear, die, change faction)
function PinnedFrames:OnBossFramesChanged()
    if not self.initialized then return end

    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and set.enabled and IsBossSet(set) then
            -- unitFrameMap and frame refresh are safe during combat (purely visual/data)
            self:UpdateBossFrameMapEntries(setIndex)
            self:RefreshChildFrames(setIndex)

            -- Recompact positioning + container resize need out-of-combat
            -- (both call SetPoint/SetSize on secure frames)
            C_Timer.After(0.05, function()
                if not InCombatLockdown() then
                    self:ApplyBossLayout(setIndex)
                    self:ResizeContainer(setIndex)
                end
            end)
        end
    end
end

-- ============================================================
-- ANCHOR CALCULATION
-- ============================================================

-- Get the anchor point for the container based on growth settings
-- This determines which corner the header anchors to AND the container anchors to UIParent
-- Supports START, CENTER, and END for both frameAnchor and columnAnchor
local function GetContainerAnchorPoint(set)
    local horizontal = set.growDirection == "HORIZONTAL"
    local frameAnchor = set.frameAnchor or "START"
    local columnAnchor = set.columnAnchor or "START"

    -- Map each axis to its WoW anchor component
    local xPart, yPart
    if horizontal then
        -- Horizontal: frameAnchor = left/center/right, columnAnchor = top/center/bottom
        xPart = (frameAnchor == "END") and "RIGHT" or (frameAnchor == "CENTER") and "" or "LEFT"
        yPart = (columnAnchor == "END") and "BOTTOM" or (columnAnchor == "CENTER") and "" or "TOP"
    else
        -- Vertical: frameAnchor = top/center/bottom, columnAnchor = left/center/right
        yPart = (frameAnchor == "END") and "BOTTOM" or (frameAnchor == "CENTER") and "" or "TOP"
        xPart = (columnAnchor == "END") and "RIGHT" or (columnAnchor == "CENTER") and "" or "LEFT"
    end

    local anchor = yPart .. xPart
    if anchor == "" then anchor = "CENTER" end
    return anchor
end

-- Convert a container's saved position from one anchor to another
-- Returns new x, y offsets for the target anchor
local function ConvertAnchorPosition(container, oldAnchor, newAnchor)
    if oldAnchor == newAnchor then return end

    -- Get the container's current screen edges
    local left = container:GetLeft()
    local right = container:GetRight()
    local top = container:GetTop()
    local bottom = container:GetBottom()

    if not left or not right or not top or not bottom then return end

    -- Get UIParent edges (in same coordinate space)
    local uiLeft = UIParent:GetLeft() or 0
    local uiRight = UIParent:GetRight() or GetScreenWidth()
    local uiTop = UIParent:GetTop() or GetScreenHeight()
    local uiBottom = UIParent:GetBottom() or 0

    -- Calculate the position of each anchor point on the container
    local anchorX = { LEFT = left, RIGHT = right, CENTER = (left + right) / 2 }
    local anchorY = { TOP = top, BOTTOM = bottom, CENTER = (top + bottom) / 2 }

    -- Parse anchor into x/y components
    local function ParseAnchor(anchor)
        if anchor == "CENTER" then return "CENTER", "CENTER" end
        if anchor == "TOP" then return "CENTER", "TOP" end
        if anchor == "BOTTOM" then return "CENTER", "BOTTOM" end
        if anchor == "LEFT" then return "LEFT", "CENTER" end
        if anchor == "RIGHT" then return "RIGHT", "CENTER" end
        local yPart = anchor:match("^(TOP)") or anchor:match("^(BOTTOM)")
        local xPart = anchor:match("(LEFT)$") or anchor:match("(RIGHT)$")
        return xPart or "CENTER", yPart or "CENTER"
    end

    -- Get the screen position of the container's new anchor point
    local newXPart, newYPart = ParseAnchor(newAnchor)
    local containerX = anchorX[newXPart]
    local containerY = anchorY[newYPart]

    -- Get the screen position of UIParent's new anchor point
    local uiAnchorX = { LEFT = uiLeft, RIGHT = uiRight, CENTER = (uiLeft + uiRight) / 2 }
    local uiAnchorY = { TOP = uiTop, BOTTOM = uiBottom, CENTER = (uiTop + uiBottom) / 2 }
    local uiX = uiAnchorX[newXPart]
    local uiY = uiAnchorY[newYPart]

    -- The offset is the difference between container anchor point and UIParent anchor point
    return containerX - uiX, containerY - uiY
end

-- ============================================================
-- FRAME CREATION
-- ============================================================

-- Create a SecureHandlerStateTemplate handler for this set's boss frames.
-- The handler owns three allocator snippets (onBossShow, onBossHide,
-- resetAllocState) plus a 0.25s GUID-swap poll. Each boss frame has its own
-- SecureHandlerShowHideTemplate helper child; when the per-frame
-- [@bossN,help]show;hide visibility driver flips, the helper's _onshow/_onhide
-- run onBossShow/onBossHide on this handler via RunFor, passing bossIndex.
-- Allocation + SetPoint happens inside the restricted environment, so in-combat
-- repositioning is legal — unlike Lua-side SetPoint on SecureUnitButtonTemplate.
-- Allocator state is stored as persistent frame attributes (slotTaken<N> on
-- the handler, assignedSlot on each boss frame) rather than snippet globals,
-- because restricted snippets get a fresh env per invocation.
function PinnedFrames:CreateBossSecureHandler(setIndex, container, bossFrames)
    if self.bossHandlers[setIndex] then return self.bossHandlers[setIndex] end
    if InCombatLockdown() then return nil end

    -- Handler is parented to the container and anchored to fill it, so
    -- positions computed relative to the handler equal positions relative
    -- to the container. The restricted environment only accepts SecureHandler*
    -- frames as SetPoint targets, so we can't anchor to the plain container
    -- directly — we anchor to the handler instead.
    local handler = CreateFrame("Frame",
        "DandersBossPositionHandler" .. setIndex,
        container,
        "SecureHandlerStateTemplate")
    handler:SetAllPoints(container)
    handler:Hide()

    -- Frame refs for snippets: each boss frame addressable via
    -- self:GetFrameRef("bossN"). Container ref isn't needed now that we
    -- anchor to the handler.
    for i = 1, 8 do
        local f = bossFrames[i]
        if f then
            SecureHandlerSetFrameRef(handler, "boss" .. i, f)
        end
    end

    -- Allocator state lives in persistent attributes because restricted-env
    -- snippets get a fresh environment per invocation, so snippet-scoped
    -- globals don't survive RunAttribute calls. We use:
    --   handler attr "slotTaken<N>" (boolean) — which slots are in use
    --   frame attr   "assignedSlot" (number)  — which slot this frame holds
    -- Both auto-nil on first read, which correctly means "untaken/unassigned".

    -- Pin the bossN frame to the lowest-numbered free slot. Re-uses existing
    -- assignment if already set. Called from each boss frame's helper _onshow.
    handler:SetAttribute("onBossShow", [[
        local bossIndex = ...
        local f = self:GetFrameRef("boss" .. bossIndex)
        if not f then return end

        local slot = tonumber(f:GetAttribute("assignedSlot"))
        if not slot then
            for i = 1, 8 do
                if not self:GetAttribute("slotTaken" .. i) then
                    slot = i
                    break
                end
            end
            if not slot then return end
            self:SetAttribute("slotTaken" .. slot, true)
            f:SetAttribute("assignedSlot", slot)
        end

        local anchor = self:GetAttribute("anchor") or "TOPLEFT"
        local x = tonumber(self:GetAttribute("slot" .. slot .. "x")) or 0
        local y = tonumber(self:GetAttribute("slot" .. slot .. "y")) or 0
        f:ClearAllPoints()
        f:SetPoint(anchor, self, anchor, x, y)
    ]])

    -- Release the slot on hide so future shows can reuse it. Other frames
    -- keep their slot assignments (no compaction — matches Targeted List rules).
    handler:SetAttribute("onBossHide", [[
        local bossIndex = ...
        local f = self:GetFrameRef("boss" .. bossIndex)
        if not f then return end

        local slot = tonumber(f:GetAttribute("assignedSlot"))
        if slot then
            self:SetAttribute("slotTaken" .. slot, false)
            f:SetAttribute("assignedSlot", nil)
        end
    ]])

    -- Invoked from Lua at combat end to wipe all slot assignments. Next
    -- onBossShow cycle starts fresh from slot 1.
    handler:SetAttribute("resetAllocState", [[
        for i = 1, 8 do
            self:SetAttribute("slotTaken" .. i, false)
            local f = self:GetFrameRef("boss" .. i)
            if f then f:SetAttribute("assignedSlot", nil) end
        end
    ]])

    -- GUID-swap poll. Midnight 12.0 can silently reassign bossN to a new NPC
    -- without firing UNIT_TARGETABLE_CHANGED / UNIT_FACTION (especially for
    -- boss6-8). Poll every 0.25s and refresh any shown frame whose unit GUID
    -- no longer matches what we cached at OnShow time. Matches Cell's pattern.
    handler.dfBossGuidElapsed = 0
    handler:SetScript("OnUpdate", function(self, elapsed)
        self.dfBossGuidElapsed = (self.dfBossGuidElapsed or 0) + elapsed
        if self.dfBossGuidElapsed < 0.25 then return end
        self.dfBossGuidElapsed = 0

        local frames = PinnedFrames.bossFrames[setIndex]
        if not frames then return end
        for i = 1, 8 do
            local f = frames[i]
            if f and f:IsShown() and f.unit then
                local guid = UnitGUID(f.unit)
                if guid and guid ~= f.dfLastBossGUID then
                    f.dfLastBossGUID = guid
                    if DF.ScanUnitFull then DF:ScanUnitFull(f.unit) end
                    if DF.FullFrameRefresh then DF:FullFrameRefresh(f) end
                end
            end
        end
    end)

    self.bossHandlers[setIndex] = handler

    DF:Debug("PINNED", "Set %d created secure position handler", setIndex)

    return handler
end

-- Push current layout settings into the secure handler's attributes.
-- Must run out of combat (SetAttribute is restricted on secure frames in combat).
function PinnedFrames:UpdateBossHandlerConfig(setIndex)
    local handler = self.bossHandlers[setIndex]
    local set = GetSetDB(setIndex)
    if not handler or not set then return end
    if InCombatLockdown() then return end

    local db = IsInRaid() and DF:GetRaidDB() or DF:GetDB()
    if not db then return end

    local frameWidth    = db.frameWidth or 120
    local frameHeight   = db.frameHeight or 50
    local hSpacing      = set.horizontalSpacing or 2
    local vSpacing      = set.verticalSpacing or 2
    local unitsPerRow   = set.unitsPerRow or 5
    local horizontal    = (set.growDirection == "HORIZONTAL")
    local frameAnchor   = set.frameAnchor or "START"
    local columnAnchor  = set.columnAnchor or "START"
    local anchor        = GetContainerAnchorPoint(set)

    handler:SetAttribute("anchor", anchor)

    -- Size each boss frame to the current mode. SetSize on secure frames is
    -- combat-restricted; we already bailed above on InCombatLockdown.
    local frames = self.bossFrames[setIndex]
    if frames then
        for i = 1, 8 do
            local f = frames[i]
            if f then
                f:SetSize(frameWidth, frameHeight)
                f.isRaidFrame = IsInRaid()
            end
        end
    end

    -- Precompute (x, y) for each of the 8 slots. Slot 1 lives at the
    -- container anchor; subsequent slots offset row-major by (xStep, yStep)
    -- whose direction is dictated by frameAnchor/columnAnchor.
    local xStep = frameWidth + hSpacing
    local yStep = frameHeight + vSpacing

    for slot = 1, 8 do
        local slotIndex = slot - 1
        local row = math.floor(slotIndex / unitsPerRow)
        local col = slotIndex - row * unitsPerRow

        local xOff, yOff
        if horizontal then
            if frameAnchor  == "END" then xOff = -col * xStep else xOff =  col * xStep end
            if columnAnchor == "END" then yOff =  row * yStep else yOff = -row * yStep end
        else
            if frameAnchor  == "END" then yOff =  col * yStep else yOff = -col * yStep end
            if columnAnchor == "END" then xOff = -row * xStep else xOff =  row * xStep end
        end

        handler:SetAttribute("slot" .. slot .. "x", xOff)
        handler:SetAttribute("slot" .. slot .. "y", yOff)
    end
end


-- Create 8 standalone SecureUnitButtonTemplate frames for a boss-mode set
-- Parented to the container; unit attributes are hardcoded to boss1..boss8
function PinnedFrames:CreateBossFrames(setIndex, container)
    if self.bossFrames[setIndex] then return end
    if InCombatLockdown() then
        DF:DebugWarn("PINNED", "CreateBossFrames: in combat, cannot create frames")
        return
    end

    local modeSuffix = IsInRaid() and "Raid" or "Party"
    local frames = {}

    for i = 1, 8 do
        local name = "DandersPinnedBoss" .. setIndex .. modeSuffix .. "_" .. i
        local frame = CreateFrame(
            "Button",
            name,
            container,
            "DandersUnitButtonTemplate,SecureUnitButtonTemplate"
        )
        frame:SetAttribute("unit", "boss" .. i)
        frame.unit = "boss" .. i
        frame.isPinnedFrame = true
        frame.isPinnedBossFrame = true
        frame.bossIndex = i

        if DF.InitializeHeaderChild then
            DF:InitializeHeaderChild(frame)
        end

        -- Per-frame visibility state driver: shows the frame when bossN
        -- exists AND is friendly. A SecureHandlerShowHideTemplate helper
        -- child (created below) invokes the shared handler's
        -- onBossShow/onBossHide snippets whenever this flips.
        RegisterStateDriver(frame, "visibility", "[@boss" .. i .. ",help]show;hide")

        -- Self-sufficient event system (ElvUI/oUF-style).
        -- Register all unit-specific events directly on the frame with
        -- `RegisterUnitEvent` so they're filtered at the C level — the handler
        -- only fires when the event is for this frame's boss unit. No dispatcher
        -- lookup needed. Each event routes to the appropriate DF update
        -- function on `self`. This avoids "dispatcher forgot boss frames"
        -- bugs because each frame listens for what it needs directly.
        local bossUnit = "boss" .. i
        frame:RegisterUnitEvent("UNIT_HEALTH", bossUnit)
        frame:RegisterUnitEvent("UNIT_MAXHEALTH", bossUnit)
        frame:RegisterUnitEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED", bossUnit)
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", bossUnit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", bossUnit)
        frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", bossUnit)
        frame:RegisterUnitEvent("UNIT_AURA", bossUnit)
        frame:RegisterUnitEvent("UNIT_NAME_UPDATE", bossUnit)
        frame:RegisterUnitEvent("UNIT_FACTION", bossUnit)
        frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", bossUnit)
        frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", bossUnit)
        frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", bossUnit)

        frame:SetScript("OnEvent", function(self, event, unit, updateInfo)
            -- Skip work if hidden (state driver keeps us hidden when bossN
            -- doesn't exist / isn't friendly, so events shouldn't really
            -- fire then, but cheap to guard).
            if not self:IsShown() then return end

            if event == "UNIT_HEALTH"
                    or event == "UNIT_MAXHEALTH"
                    or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED" then
                if DF.UpdateHealthFast then DF:UpdateHealthFast(self) end

            elseif event == "UNIT_POWER_UPDATE"
                    or event == "UNIT_MAXPOWER"
                    or event == "UNIT_DISPLAYPOWER" then
                if DF.UpdatePower then DF:UpdatePower(self) end

            elseif event == "UNIT_AURA" then
                -- Populate aura cache (same logic as directModeSubscriber)
                local cache = DF.AuraCache and DF.AuraCache[unit]
                local needsFull = not updateInfo or updateInfo.isFullUpdate
                    or not cache or not cache.hasFullScan
                if needsFull then
                    if DF.ScanUnitFull then DF:ScanUnitFull(unit) end
                else
                    if DF.ApplyAuraDelta and not DF:ApplyAuraDelta(unit, updateInfo) then
                        if DF.ScanUnitFull then DF:ScanUnitFull(unit) end
                    end
                end
                -- Trigger the full filtered aura update pipeline (same path as
                -- party/raid frames — applies filters, limits, dedup, etc.)
                if DF.TriggerAuraUpdateForUnit then
                    DF:TriggerAuraUpdateForUnit(unit)
                end

            elseif event == "UNIT_NAME_UPDATE" then
                if DF.UpdateName then DF:UpdateName(self) end

            elseif event == "UNIT_FACTION" then
                -- Faction change can flip friendly→hostile — full refresh
                -- (state driver will then hide the frame if no longer friendly)
                if DF.FullFrameRefresh then DF:FullFrameRefresh(self) end

            elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
                if DF.UpdateAbsorb then DF:UpdateAbsorb(self) end

            elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
                if DF.UpdateHealAbsorb then DF:UpdateHealAbsorb(self) end

            elseif event == "UNIT_HEAL_PREDICTION" then
                if DF.UpdateHealPrediction then DF:UpdateHealPrediction(self) end
            end
        end)

        -- OnShow hook: when state driver makes this frame visible, register in
        -- unitFrameMap synchronously so UNIT_HEALTH/UNIT_AURA/etc. events route
        -- here immediately (otherwise the health bar won't update until
        -- OnBossFramesChanged's deferred registration fires).
        frame:HookScript("OnShow", function(self)
            if DF.unitFrameMap and self.unit then
                DF.unitFrameMap[self.unit] = self
                self.dfEventsEnabled = true
                self.dfLastBossGUID = UnitGUID(self.unit)
            end
            C_Timer.After(0.1, function()
                if self and self.unit and self:IsVisible() then
                    -- Populate aura cache for this unit if not yet done
                    if DF.ScanUnitFull then DF:ScanUnitFull(self.unit) end
                    -- Full refresh ensures Aura Designer BeginFrame/EnsureFrameState runs
                    if DF.FullFrameRefresh then DF:FullFrameRefresh(self) end
                    self.dfLastBossGUID = UnitGUID(self.unit)
                end
            end)
        end)

        -- OnHide hook: clear Aura Designer state so the next OnShow reinitializes
        -- from scratch. Without this, when a boss slot is reassigned to a new NPC,
        -- the stale dfAD_* pools cause AD indicators to not apply on first render.
        -- Also remove from unitFrameMap so events don't route to a hidden frame.
        frame:HookScript("OnHide", function(self)
            if DF.unitFrameMap and self.unit and DF.unitFrameMap[self.unit] == self then
                DF.unitFrameMap[self.unit] = nil
            end
            self.dfEventsEnabled = false

            -- Hide all AD indicator widgets before releasing the pool tables.
            -- Without this, icons/squares/bars stay parented to the frame with
            -- IsShown() == true, and reappear from the previous NPC when the
            -- boss slot re-fills with a new unit.
            if DF.AuraDesigner and DF.AuraDesigner.Indicators then
                DF.AuraDesigner.Indicators:HideAll(self)
            end

            self.dfAD = nil
            self.dfAD_icons = nil
            self.dfAD_squares = nil
            self.dfAD_bars = nil
            self.dfAD_configVersion = nil
            self.dfAD_activeInstanceIDs = nil
            self.dfLastBossGUID = nil
        end)

        -- Secure helper that fires _onshow/_onhide inside the restricted
        -- environment whenever this boss frame's visibility state driver
        -- flips. Lets us run slot-allocator/reposition work (which calls
        -- SetPoint on SecureUnitButtonTemplate frames) safely in combat.
        local helper = CreateFrame("Frame", nil, frame, "SecureHandlerShowHideTemplate")
        helper:SetAttribute("bossIndex", i)
        helper:SetAttribute("_onshow", [[
            local h = self:GetFrameRef("bossHandler")
            if h then
                self:RunFor(h, h:GetAttribute("onBossShow"),
                    self:GetAttribute("bossIndex"))
            end
        ]])
        helper:SetAttribute("_onhide", [[
            local h = self:GetFrameRef("bossHandler")
            if h then
                self:RunFor(h, h:GetAttribute("onBossHide"),
                    self:GetAttribute("bossIndex"))
            end
        ]])
        frame.bossHelper = helper

        -- Register with click-casting system
        if ClickCastFrames then
            ClickCastFrames[frame] = true
        end

        frame:Hide()
        frames[i] = frame
    end

    self.bossFrames[setIndex] = frames

    -- Secure handler that repositions these frames compactly, even in combat
    self:CreateBossSecureHandler(setIndex, container, frames)

    -- Wire each helper's bossHandler frame ref now that the handler exists.
    local handler = self.bossHandlers[setIndex]
    if handler then
        for i = 1, 8 do
            local f = frames[i]
            if f and f.bossHelper then
                SecureHandlerSetFrameRef(f.bossHelper, "bossHandler", handler)
            end
        end
    end

    DF:Debug("PINNED", "Set %d created 8 boss frames", setIndex)
end

function PinnedFrames:CreateSetFrames(setIndex)
    if self.containers[setIndex] then return end
    
    -- CRITICAL: Cannot create frames during combat
    if InCombatLockdown() then
        DF:DebugWarn("PINNED", "CreateSetFrames: in combat, cannot create frames")
        return
    end
    
    local set = GetSetDB(setIndex)
    if not set then return end
    
    local modeSuffix = IsInRaid() and "Raid" or "Party"
    
    -- Create container (movable anchor frame)
    local container = CreateFrame("Frame", "DandersPinned" .. setIndex .. modeSuffix .. "Container", UIParent)
    container:SetSize(200, 100)  -- Will be resized based on content
    container:SetFrameStrata("MEDIUM")
    container:SetClampedToScreen(true)
    
    -- Position from saved settings — use growth-direction anchor
    local containerAnchor = GetContainerAnchorPoint(set)
    local pos = set.position or { point = containerAnchor, x = 0, y = 200 * (setIndex == 1 and 1 or -1) }
    -- If saved anchor doesn't match current growth anchor, convert on first layout pass
    local useAnchor = pos.point or containerAnchor
    local initScale = set.scale or 1.0
    container:SetScale(initScale)
    container:ClearAllPoints()
    container:SetPoint(useAnchor, UIParent, useAnchor, (pos.x or 0) / initScale, (pos.y or 0) / initScale)
    
    -- Make draggable when unlocked
    container:SetMovable(true)
    container:EnableMouse(false)  -- Don't capture mouse on container - mover handles dragging

    -- Mode-aware colors: raid = orange, party = purple-blue
    local colors = GetModeColors(IsInRaid())

    -- Visual background when unlocked (for visibility)
    container.bg = container:CreateTexture(nil, "BACKGROUND")
    container.bg:SetAllPoints()
    container.bg:SetColorTexture(unpack(colors.containerBg))
    container.bg:SetShown(not set.locked)

    -- Border when unlocked
    container.border = CreateFrame("Frame", nil, container, "BackdropTemplate")
    container.border:SetAllPoints()
    container.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    container.border:SetBackdropBorderColor(unpack(colors.containerBorder))
    container.border:SetShown(not set.locked)

    -- Mover frame (parented to UIParent for scale independence)
    local mover = CreateFrame("Frame", "DandersPinned" .. setIndex .. "Mover", UIParent)
    mover:SetSize(80, 16)
    mover:SetFrameStrata("HIGH")
    mover:SetPoint("BOTTOM", container, "TOP", 0, 2)

    -- Mover background
    mover.bg = mover:CreateTexture(nil, "BACKGROUND")
    mover.bg:SetAllPoints()
    mover.bg:SetColorTexture(unpack(colors.moverBg))

    -- Mover border (1px)
    mover.border = mover:CreateTexture(nil, "BORDER")
    mover.border:SetAllPoints()
    mover.border:SetColorTexture(unpack(colors.moverBorder))
    local moverInner = mover:CreateTexture(nil, "ARTWORK")
    moverInner:SetPoint("TOPLEFT", 1, -1)
    moverInner:SetPoint("BOTTOMRIGHT", -1, 1)
    moverInner:SetColorTexture(unpack(colors.moverBg))

    -- Mover text
    mover.text = mover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mover.text:SetPoint("CENTER")
    mover.text:SetText("Drag to Move")
    mover.text:SetTextColor(unpack(colors.moverText))
    
    -- Mover is the drag handle
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    
    -- Track starting mouse and container position
    local startMouseX, startMouseY, startPosX, startPosY
    
    mover:SetScript("OnDragStart", function(self)
        if set.locked then return end

        -- Get the current anchor for this set
        local anchor = GetContainerAnchorPoint(set)

        -- Get starting mouse position in screen coordinates
        local uiScale = UIParent:GetEffectiveScale()
        startMouseX, startMouseY = GetCursorPosition()
        startMouseX = startMouseX / uiScale
        startMouseY = startMouseY / uiScale

        -- Get current container position
        local pos = set.position or { x = 0, y = 0 }
        startPosX = pos.x or 0
        startPosY = pos.y or 0

        self:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local ps = UIParent:GetEffectiveScale()
            mx = mx / ps
            my = my / ps

            -- Delta in UIParent space — add directly to logical start position
            local deltaX = mx - startMouseX
            local deltaY = my - startMouseY
            local newX = startPosX + deltaX
            local newY = startPosY + deltaY

            -- Divide by scale for SetPoint — WoW multiplies offsets by frame scale internally
            local s = container:GetScale() or 1
            container:ClearAllPoints()
            container:SetPoint(anchor, UIParent, anchor, newX / s, newY / s)
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        if not startMouseX then return end

        -- Get the current anchor for this set
        local anchor = GetContainerAnchorPoint(set)

        -- Get final position from mouse delta
        local uiScale = UIParent:GetEffectiveScale()
        local mx, my = GetCursorPosition()
        mx = mx / uiScale
        my = my / uiScale

        local deltaX = mx - startMouseX
        local deltaY = my - startMouseY
        local finalX = startPosX + deltaX
        local finalY = startPosY + deltaY

        -- Save logical position (unscaled)
        set.position = { point = anchor, x = finalX, y = finalY }

        -- Divide by scale for SetPoint
        local s = container:GetScale() or 1
        container:ClearAllPoints()
        container:SetPoint(anchor, UIParent, anchor, finalX / s, finalY / s)

        -- If Test Mode is active, re-sync test container(s) to the new position.
        -- The drag updated the current mode's set.position; the test container
        -- may or may not be using this mode's config, but refreshing is cheap
        -- and ensures alignment either way.
        if PinnedFrames.testModeActive and PinnedFrames.ExitTestMode then
            PinnedFrames:ExitTestMode()
            PinnedFrames:EnterTestMode()
        end
    end)
    
    -- Mover shows when unlocked AND enabled
    mover:SetShown(set.enabled and not set.locked)
    container.mover = mover
    
    -- Label (parented to UIParent for scale independence)
    local label = UIParent:CreateFontString("DandersPinned" .. setIndex .. "Label", "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", container, "TOP", 0, 2)
    local labelText = set.name
    if not labelText or labelText == "" then
        labelText = "Pinned " .. setIndex
    end
    label:SetText(labelText)
    label:SetTextColor(0.8, 0.8, 1.0)
    -- Only show label if set is enabled AND showLabel is true
    label:SetShown(set.enabled and set.showLabel)
    
    self.containers[setIndex] = container
    self.labels[setIndex] = label

    if IsBossSet(set) then
        -- BOSS MODE: create 8 standalone boss frames instead of a header
        self:CreateBossFrames(setIndex, container)
        self:ApplyBossLayout(setIndex)

        -- Honor enabled state
        if set.enabled then
            container:Show()
            if label then label:SetShown(set.showLabel) end
            if container.mover then container.mover:SetShown(not set.locked) end
        else
            container:Hide()
            if label then label:Hide() end
            if container.mover then container.mover:Hide() end
        end
        return
    end

    -- Create SecureGroupHeaderTemplate
    local header = CreateFrame("Frame", "DandersPinned" .. setIndex .. modeSuffix .. "Header", container, "SecureGroupHeaderTemplate")
    
    -- Show all unit types - nameList controls which are visible
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showSolo", true)
    
    -- Use same template as main frames
    header:SetAttribute("template", "DandersUnitButtonTemplate")
    
    -- Initial layout
    self:ApplyLayoutSettings(setIndex)
    
    -- Anchor header to container
    header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    
    self.headers[setIndex] = header
    
    -- STARTINGINDEX TRICK - Force create frames upfront
    -- Must happen BEFORE setting nameList/sortMethod
    -- Use groupFilter temporarily to force frame creation
    header:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")  -- All groups
    header:SetAttribute("startingIndex", -39)  -- Creates up to 40 frames
    header:Show()
    header:SetAttribute("startingIndex", 1)    -- Reset to normal operation
    
    -- Now switch to nameList mode
    header:SetAttribute("sortMethod", "NAMELIST")
    header:SetAttribute("groupFilter", nil)  -- Clear groupFilter, nameList takes over
    
    -- Initial nameList (may be empty, that's ok now - frames are created)
    self:UpdateHeaderNameList(setIndex)
    
    -- Count created children for debug log (fast — 40 attribute lookups)
    local childCount = 0
    for i = 1, 40 do
        if header:GetAttribute("child" .. i) then childCount = childCount + 1 end
    end
    DF:Debug("PINNED", "Set %d created %d child frames", setIndex, childCount)
    
    -- Show/hide based on enabled state
    if set.enabled then
        container:Show()
        header:Show()
        -- Label and mover visibility based on their settings
        if label then
            label:SetShown(set.showLabel)
        end
        if container.mover then
            container.mover:SetShown(not set.locked)
        end
    else
        container:Hide()
        header:Hide()
        -- Hide label and mover when disabled
        if label then
            label:Hide()
        end
        if container.mover then
            container.mover:Hide()
        end
        -- Unregister events from child frames (synchronous - no delays for combat safety)
        if DF.SetHeaderChildrenEventsEnabled then
            DF:SetHeaderChildrenEventsEnabled(header, false)
        end
    end
end

-- ============================================================
-- HEADER UPDATES
-- ============================================================

-- Update the nameList for a header
function PinnedFrames:UpdateHeaderNameList(setIndex)
    local header = self.headers[setIndex]
    local set = GetSetDB(setIndex)
    
    if not header or not set then return end
    
    -- Get roster (maps stored names to actual GetRaidRosterInfo names)
    local roster = GetGroupRoster()
    local validRosterNames = {}
    
    -- For each player in set, find their actual roster name
    for _, storedName in ipairs(set.players) do
        local rosterName = IsPlayerInGroup(storedName, roster)
        if rosterName then
            -- Use the actual roster name (what GetRaidRosterInfo returns)
            table.insert(validRosterNames, rosterName)
        end
    end
    
    local nameList = BuildNameList(validRosterNames)
    
    DF:Debug("PINNED", "Set %d updating nameList (%d players in set, %d valid, list=%s)",
        setIndex, #set.players, #validRosterNames,
        nameList ~= "" and nameList or "(empty)")
    
    -- Only update if not in combat
    if InCombatLockdown() then
        self.pendingNameListUpdate = self.pendingNameListUpdate or {}
        self.pendingNameListUpdate[setIndex] = true
        return
    end
    
    -- Clear ALL filtering/grouping attributes - nameList acts as the filter
    -- (Same approach as flat raid mode in Headers.lua)
    header:SetAttribute("groupBy", nil)
    header:SetAttribute("groupingOrder", nil)
    header:SetAttribute("groupFilter", nil)  -- MUST clear this for nameList to work!
    header:SetAttribute("roleFilter", nil)
    header:SetAttribute("strictFiltering", nil)
    
    -- Set nameList and sortMethod
    header:SetAttribute("nameList", nameList)
    header:SetAttribute("sortMethod", "NAMELIST")
    
    -- Force header to re-layout by toggling visibility
    if set.enabled then
        header:Hide()
        header:Show()
    end
    
    -- Resize container after layout change
    self:ResizeContainer(setIndex)
    
    -- Force visual refresh on all visible children after nameList change
    -- OnAttributeChanged handles unit reassignment, but a small delay ensures
    -- the header has finished re-laying out children before we refresh visuals
    C_Timer.After(0.1, function()
        if header and set.enabled then
            PinnedFrames:RefreshChildFrames(setIndex)
        end
    end)
end

-- Apply layout settings to a header
function PinnedFrames:ApplyLayoutSettings(setIndex)
    local set = GetSetDB(setIndex)
    if not set then return end
    if InCombatLockdown() then return end

    -- Refresh Test Mode frames regardless of frame type. Cheapest correct
    -- approach: full Exit+Enter cycle, same as the test count slider uses.
    -- Settings panel slider drags fire at keyboard-repeat rate, but Exit+Enter
    -- is lightweight (just shows/hides non-secure frames and re-applies
    -- layout math — no allocations beyond first use).
    if self.testModeActive then
        self:ExitTestMode()
        self:EnterTestMode()
    end

    if IsBossSet(set) then
        self:ApplyBossLayout(setIndex)
        self:ResizeContainer(setIndex)
        return
    end

    local header = self.headers[setIndex]
    if not header then return end
    
    local db = IsInRaid() and DF:GetRaidDB() or DF:GetDB()
    if not db then
        DF:DebugError("PINNED", "ApplyLayoutSettings: db is nil")
        return
    end
    
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50
    
    -- CRITICAL: Resize all child frames to match current raid/party settings
    -- This ensures frames use the correct size when switching between raid and party
    for i = 1, 40 do
        local child = header:GetAttribute("child" .. i)
        if child then
            child:SetSize(frameWidth, frameHeight)
            -- Also update the isRaidFrame flag for proper DB selection in other functions
            child.isRaidFrame = IsInRaid()
        end
    end
    
    local horizontal = set.growDirection == "HORIZONTAL"
    local hSpacing = set.horizontalSpacing or 2
    local vSpacing = set.verticalSpacing or 2
    local unitsPerRow = set.unitsPerRow or 5
    local columnAnchor = set.columnAnchor or "START"
    local frameAnchor = set.frameAnchor or "START"
    
    -- Frame anchor point determines where first frame is placed and growth direction
    -- HORIZONTAL: START=LEFT (grow right), CENTER=LEFT (grow right, expand from center), END=RIGHT (grow left)
    -- VERTICAL: START=TOP (grow down), CENTER=TOP (grow down, expand from center), END=BOTTOM (grow up)
    -- CENTER uses same internal layout as START — the "center" effect comes from the container anchor
    local point, xOff, yOff
    if horizontal then
        if frameAnchor == "END" then
            point = "RIGHT"
            xOff = -hSpacing  -- Negative to grow left
        else
            point = "LEFT"
            xOff = hSpacing   -- Positive to grow right
        end
        yOff = 0
    else
        if frameAnchor == "END" then
            point = "BOTTOM"
            yOff = vSpacing   -- Positive to grow up
        else
            point = "TOP"
            yOff = -vSpacing  -- Negative to grow down
        end
        xOff = 0
    end

    header:SetAttribute("point", point)
    header:SetAttribute("xOffset", xOff)
    header:SetAttribute("yOffset", yOff)

    -- Column anchor point determines where new columns/rows appear
    -- CENTER uses same internal layout as START — container anchor handles the centering
    local colAnchorPoint, colSpacing
    if horizontal then
        colSpacing = vSpacing
        colAnchorPoint = (columnAnchor == "END") and "BOTTOM" or "TOP"
    else
        colSpacing = hSpacing
        colAnchorPoint = (columnAnchor == "END") and "RIGHT" or "LEFT"
    end
    header:SetAttribute("columnSpacing", colSpacing)
    header:SetAttribute("columnAnchorPoint", colAnchorPoint)
    
    header:SetAttribute("maxColumns", math.ceil(40 / unitsPerRow))
    header:SetAttribute("unitsPerColumn", unitsPerRow)
    
    -- Store frame dimensions for the template
    header:SetAttribute("frameWidth", frameWidth)
    header:SetAttribute("frameHeight", frameHeight)
    
    -- Get the anchor point based on growth settings
    local containerAnchorPoint = GetContainerAnchorPoint(set)
    
    -- Apply scale FIRST (before any position work)
    local container = self.containers[setIndex]
    if container then
        container:SetScale(set.scale or 1.0)
    end
    
    -- Anchor the header to the correct corner of container
    if container then
        header:ClearAllPoints()
        header:SetPoint(containerAnchorPoint, container, containerAnchorPoint, 0, 0)

        -- Restore saved position — convert if anchor changed
        local pos = set.position
        if pos then
            local savedAnchor = pos.point or "CENTER"
            if savedAnchor ~= containerAnchorPoint and container:GetLeft() then
                -- Anchor changed (user changed growth direction) — convert coordinates
                -- ConvertAnchorPosition returns screen-space offsets (affected by scale),
                -- so multiply by scale to convert back to logical space for storage
                local newX, newY = ConvertAnchorPosition(container, savedAnchor, containerAnchorPoint)
                if newX and newY then
                    local cs = container:GetScale() or 1
                    pos.point = containerAnchorPoint
                    pos.x = newX * cs
                    pos.y = newY * cs
                end
            end
            container:ClearAllPoints()
            local s = container:GetScale() or 1
            container:SetPoint(containerAnchorPoint, UIParent, containerAnchorPoint, (pos.x or 0) / s, (pos.y or 0) / s)
            pos.point = containerAnchorPoint
        end
    end
    
    DF:Debug("PINNED", "ApplyLayoutSettings set=%d horizontal=%s frameAnchor=%s columnAnchor=%s containerAnchor=%s size=%dx%d spacing=%d,%d",
        setIndex, tostring(horizontal), tostring(frameAnchor), tostring(columnAnchor),
        tostring(containerAnchorPoint), frameWidth, frameHeight, hSpacing, vSpacing)
    
    -- ============================================================
    -- CRITICAL: 4-step refresh to force repositioning
    -- Without this, changing layout settings won't reposition frames
    -- ============================================================
    if set.enabled and header:IsShown() then
        local currentNameList = header:GetAttribute("nameList")
        
        -- Step 1: Clear nameList to remove unit assignments
        header:SetAttribute("nameList", "")
        
        -- Step 2: Clear all child positions
        for i = 1, 40 do
            local child = header:GetAttribute("child" .. i)
            if child then
                child:ClearAllPoints()
            end
        end
        
        -- Step 3: Force header to process by hiding and showing
        header:Hide()
        header:Show()
        
        -- Step 4: Restore nameList - this reassigns units with new layout
        if currentNameList and currentNameList ~= "" then
            header:SetAttribute("nameList", currentNameList)
        end
    end
    
    -- Resize container after layout change
    self:ResizeContainer(setIndex)
end

-- Manually position boss frames in a grid matching the set's layout settings
-- Called when layout settings change or boss visibility changes
function PinnedFrames:ApplyBossLayout(setIndex)
    local set = GetSetDB(setIndex)
    local container = self.containers[setIndex]
    if not set or not container then return end
    if InCombatLockdown() then return end

    -- Container anchor + scale + saved position handling.
    local anchor = GetContainerAnchorPoint(set)
    container:SetScale(set.scale or 1.0)

    local pos = set.position
    if pos then
        local savedAnchor = pos.point or anchor
        if savedAnchor ~= anchor and container:GetLeft() then
            local newX, newY = ConvertAnchorPosition(container, savedAnchor, anchor)
            if newX and newY then
                local cs = container:GetScale() or 1
                pos.point = anchor
                pos.x = newX * cs
                pos.y = newY * cs
            end
        end
        container:ClearAllPoints()
        local s = container:GetScale() or 1
        container:SetPoint(anchor, UIParent, anchor, (pos.x or 0) / s, (pos.y or 0) / s)
        pos.point = anchor
    end

    -- Push slot coords + sizes to the secure handler. The allocator snippet
    -- reads these whenever a boss frame becomes visible.
    self:UpdateBossHandlerConfig(setIndex)

    -- Re-anchor any already-visible frames to their current slot coords so
    -- live layout changes (spacing, size, anchor) take effect immediately
    -- without waiting for the next Show event.
    local handler = self.bossHandlers[setIndex]
    if handler then
        handler:Execute([[
            local anchor = self:GetAttribute("anchor") or "TOPLEFT"
            for i = 1, 8 do
                local f = self:GetFrameRef("boss" .. i)
                if f then
                    local slot = tonumber(f:GetAttribute("assignedSlot"))
                    if slot then
                        local x = tonumber(self:GetAttribute("slot" .. slot .. "x")) or 0
                        local y = tonumber(self:GetAttribute("slot" .. slot .. "y")) or 0
                        f:ClearAllPoints()
                        f:SetPoint(anchor, self, anchor, x, y)
                    end
                end
            end
        ]])
    end
end

-- Resize container to fit content
function PinnedFrames:ResizeContainer(setIndex)
    -- Can't resize secure frames during combat
    if InCombatLockdown() then return end
    
    local container = self.containers[setIndex]
    local header = self.headers[setIndex]
    local set = GetSetDB(setIndex)
    
    if not container or not set then return end
    if not IsBossSet(set) and not header then return end

    local db = IsInRaid() and DF:GetRaidDB() or DF:GetDB()
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50

    if IsBossSet(set) then
        local frames = self.bossFrames[setIndex]
        if not frames then return end

        local visibleCount = 0
        for i = 1, 8 do
            if frames[i] and frames[i]:IsShown() then
                visibleCount = visibleCount + 1
            end
        end

        if visibleCount == 0 then
            container:SetSize(frameWidth, frameHeight)
            return
        end

        local horizontal = set.growDirection == "HORIZONTAL"
        local spacing = horizontal and (set.horizontalSpacing or 2) or (set.verticalSpacing or 2)
        local unitsPerRow = set.unitsPerRow or 5

        local rows = math.ceil(visibleCount / unitsPerRow)
        local cols = math.min(visibleCount, unitsPerRow)

        local width, height
        if horizontal then
            width = cols * frameWidth + (cols - 1) * spacing
            height = rows * frameHeight + (rows - 1) * (set.verticalSpacing or 2)
        else
            width = rows * frameWidth + (rows - 1) * (set.horizontalSpacing or 2)
            height = cols * frameHeight + (cols - 1) * spacing
        end

        container:SetSize(math.max(width, 50), math.max(height, 30))
        return
    end

    -- Count visible children
    local visibleCount = 0
    for i = 1, 40 do
        local child = header:GetAttribute("child" .. i)
        if child and child:IsShown() then
            visibleCount = visibleCount + 1
        end
    end
    
    if visibleCount == 0 then
        container:SetSize(frameWidth, frameHeight)
        return
    end
    
    local horizontal = set.growDirection == "HORIZONTAL"
    local spacing = horizontal and (set.horizontalSpacing or 2) or (set.verticalSpacing or 2)
    local unitsPerRow = set.unitsPerRow or 5
    
    local rows = math.ceil(visibleCount / unitsPerRow)
    local cols = math.min(visibleCount, unitsPerRow)
    
    local width, height
    if horizontal then
        width = cols * frameWidth + (cols - 1) * spacing
        height = rows * frameHeight + (rows - 1) * (set.verticalSpacing or 2)
    else
        width = rows * frameWidth + (rows - 1) * (set.horizontalSpacing or 2)
        height = cols * frameHeight + (cols - 1) * spacing
    end
    
    container:SetSize(math.max(width, 50), math.max(height, 30))
end

-- Update all headers
function PinnedFrames:UpdateAllHeaders()
    for i = 1, 2 do
        self:UpdateHeaderNameList(i)
    end
end

-- ============================================================
-- ENABLE/DISABLE/LOCK
-- ============================================================

-- Iterate through header children and manage their events
local function SetChildFrameEvents(header, enabled)
    if DF.SetHeaderChildrenEventsEnabled then
        DF:SetHeaderChildrenEventsEnabled(header, enabled)
    end
end

-- Toggle enabled state for a set
-- Refresh all child frames for a set (called after enabling for combat reload support)
-- Uses FullFrameRefresh which uses Blizzard aura cache ONLY - no fallback
function PinnedFrames:RefreshChildFrames(setIndex)
    local set = GetSetDB(setIndex)
    if not set then return end

    if IsBossSet(set) then
        local frames = self.bossFrames[setIndex]
        if not frames then return end
        for i = 1, 8 do
            local f = frames[i]
            if f and f.unit and f:IsVisible() then
                if DF.FullFrameRefresh then
                    DF:FullFrameRefresh(f)
                end
            end
        end
        return
    end

    local header = self.headers[setIndex]
    if not header then return end

    for i = 1, 40 do
        local child = header:GetAttribute("child" .. i)
        if child and child.unit and child:IsVisible() then
            if DF.FullFrameRefresh then
                DF:FullFrameRefresh(child)
            end
        end
    end

    DF:Debug("PINNED", "Set %d refreshed all child frames", setIndex)
end

function PinnedFrames:SetEnabled(setIndex, enabled)
    local set = GetSetDB(setIndex)
    if not set then return end

    set.enabled = enabled

    local container = self.containers[setIndex]
    local header = self.headers[setIndex]
    local isBoss = IsBossSet(set)

    if not container or (not isBoss and not header) then
        if enabled then
            self:CreateSetFrames(setIndex)
        end
        return
    end

    if InCombatLockdown() then
        self.pendingVisibilityUpdate = self.pendingVisibilityUpdate or {}
        self.pendingVisibilityUpdate[setIndex] = enabled
        return
    end

    -- Player mode: toggle header child events
    if not isBoss and header then
        SetChildFrameEvents(header, enabled)
    end

    local label = self.labels[setIndex]

    if enabled then
        container:Show()
        if header then header:Show() end

        if isBoss then
            self:ApplyBossLayout(setIndex)
            self:ResizeContainer(setIndex)
        else
            self:UpdateHeaderNameList(setIndex)
            self:ApplyLayoutSettings(setIndex)
        end

        self:UpdateLabel(setIndex)
        if label then label:SetShown(set.showLabel) end
        if container.mover and not set.locked then
            container.mover:SetShown(true)
        end

        self:RefreshChildFrames(setIndex)
    else
        container:Hide()
        if header then header:Hide() end
        if label then label:Hide() end
        if container.mover then container.mover:Hide() end
    end
end

-- Toggle locked state for a set
function PinnedFrames:SetLocked(setIndex, locked)
    local set = GetSetDB(setIndex)
    local container = self.containers[setIndex]
    
    if not set or not container then return end
    
    -- Unlocking requires frame manipulation that can taint in combat
    if not locked and InCombatLockdown() then
        self.pendingUnlock = self.pendingUnlock or {}
        self.pendingUnlock[setIndex] = true
        DF:Debug("PINNED", "Set %d unlock queued until after combat", setIndex)
        return
    end
    
    set.locked = locked
    
    -- Container background/border visibility
    container.bg:SetShown(not locked)
    container.border:SetShown(not locked)
    
    -- Mover shows when unlocked (independent of label)
    if container.mover then
        container.mover:SetShown(not locked and set.enabled)
    end
end

-- Auto-lock all unlocked sets (called on combat start)
function PinnedFrames:LockAllForCombat()
    if not self.initialized then return end
    
    local hlDB = GetPinnedDB()
    if not hlDB or not hlDB.sets then return end
    
    for i = 1, 2 do
        local set = hlDB.sets[i]
        local container = self.containers[i]
        if set and container and not set.locked then
            -- Remember which sets were unlocked so we can restore after combat
            self.unlockedBeforeCombat = self.unlockedBeforeCombat or {}
            self.unlockedBeforeCombat[i] = true
            
            -- Lock visually (hide mover/bg/border) but don't save to DB
            container.bg:Hide()
            container.border:Hide()
            if container.mover then
                container.mover:Hide()
            end
            
            DF:Debug("PINNED", "Set %d auto-locked for combat", i)
        end
    end
end

-- Restore unlock state after combat
function PinnedFrames:RestoreUnlockedAfterCombat()
    -- Restore sets that were unlocked before combat
    if self.unlockedBeforeCombat then
        for setIndex in pairs(self.unlockedBeforeCombat) do
            local set = GetSetDB(setIndex)
            local container = self.containers[setIndex]
            if set and container and not set.locked then
                container.bg:SetShown(true)
                container.border:SetShown(true)
                if container.mover then
                    container.mover:SetShown(set.enabled)
                end
            end
        end
        self.unlockedBeforeCombat = nil
    end
    
    -- Process any unlock requests that came in during combat
    if self.pendingUnlock then
        for setIndex in pairs(self.pendingUnlock) do
            self:SetLocked(setIndex, false)
        end
        self.pendingUnlock = nil
    end
end

-- Toggle label visibility
function PinnedFrames:SetShowLabel(setIndex, show)
    local set = GetSetDB(setIndex)
    local label = self.labels[setIndex]
    
    if not set or not label then return end
    
    set.showLabel = show
    label:SetShown(show)
end

-- Update label text
function PinnedFrames:UpdateLabel(setIndex)
    local set = GetSetDB(setIndex)
    local label = self.labels[setIndex]
    
    if not set or not label then return end
    
    local labelText = set.name
    if not labelText or labelText == "" then
        labelText = "Pinned " .. setIndex
    end
    label:SetText(labelText)
end

-- Backwards-compat stubs for the old preview-container system (removed in
-- favour of Test Mode, which does the same job with fake frames). These
-- no-ops keep external callers (Options.lua) working until their calls are
-- cleaned up; safe to remove once all callsites are updated.
function PinnedFrames:ShowPreview(_) end
function PinnedFrames:HidePreview() end
function PinnedFrames:UpdatePreviewSet(_) end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function PinnedFrames:Initialize()
    if self.initialized then return end
    
    -- CRITICAL: Cannot create frames during combat
    if InCombatLockdown() then
        DF:DebugWarn("PINNED", "Initialize: in combat, deferring")
        self.pendingInitialize = true
        return
    end

    -- Check if DB is ready - if not during ADDON_LOADED, defer to pending
    if not DF.db then
        DF:DebugWarn("PINNED", "Initialize: DF.db not ready, deferring")
        self.pendingInitialize = true
        return
    end

    -- Track what mode we're initializing for
    self.currentMode = GetActualMode()

    -- Check if pinnedFrames config exists
    local hlDB = GetPinnedDB()
    if not hlDB then
        DF:DebugError("PINNED", "Initialize: no pinnedFrames config found")
        return
    end

    DF:Debug("PINNED", "Initializing pinned frames (mode=%s)", tostring(self.currentMode))
    
    -- Create frames for both sets
    for i = 1, 2 do
        self:CreateSetFrames(i)
    end
    
    self.initialized = true
    
    -- Apply layout settings immediately (no delays for combat safety)
    -- Note: ApplyLayoutSettings is also called in CreateSetFrames, but we do it
    -- again here to ensure all settings are applied after headers are fully set up
    for i = 1, 2 do
        local header = self.headers[i]
        local set = GetSetDB(i)
        if set and set.enabled and (header or IsBossSet(set)) then
            self:ApplyLayoutSettings(i)
        end
    end
    
    DF:Debug("PINNED", "Initialized pinned frames")
end

-- Reinitialize for mode change (party <-> raid)
function PinnedFrames:Reinitialize()
    -- Cannot reinitialize during combat
    if InCombatLockdown() then
        DF:DebugWarn("PINNED", "Reinitialize: in combat, deferring")
        self.pendingReinitialize = true
        return
    end
    
    -- Clean up old frames
    for i = 1, 2 do
        if self.bossHandlers[i] then
            self.bossHandlers[i]:Hide()
            self.bossHandlers[i] = nil
        end
        -- Destroy player-mode test frame pool (non-secure, safe to hide+nil)
        if self.testFrames[i] then
            for _, f in ipairs(self.testFrames[i]) do
                if f then f:Hide() end
            end
            self.testFrames[i] = nil
        end
        if self.testContainers[i] then
            if self.testContainers[i].testMover then
                self.testContainers[i].testMover:Hide()
            end
            if self.testContainers[i].testLabel then
                self.testContainers[i].testLabel:Hide()
            end
            self.testContainers[i]:Hide()
            self.testContainers[i] = nil
        end
        if self.bossFrames[i] then
            for j = 1, 8 do
                local f = self.bossFrames[i][j]
                if f then
                    UnregisterStateDriver(f, "visibility")
                    f:UnregisterAllEvents()
                    f:Hide()
                end
            end
            self.bossFrames[i] = nil
        end
        if self.containers[i] then
            if self.containers[i].mover then
                self.containers[i].mover:Hide()
            end
            self.containers[i]:Hide()
            self.containers[i] = nil
        end
        if self.headers[i] then
            self.headers[i]:Hide()
            self.headers[i] = nil
        end
        if self.labels[i] then
            self.labels[i]:Hide()
        end
        self.labels[i] = nil
    end
    
    self.initialized = false
    self:Initialize()

    -- If Test Mode was active before Reinitialize (e.g. user changed
    -- frame type in the settings panel while test mode was on), re-enter
    -- it so fresh test frames are rendered for the new frame type.
    if self.testModeActive then
        self.testModeActive = false  -- ExitTestMode is a no-op in this state
        self:EnterTestMode()
    end
end

-- Refresh all child frames (calls FullFrameRefresh on each)
function PinnedFrames:RefreshAllChildFrames()
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set then
            if IsBossSet(set) then
                local frames = self.bossFrames[setIndex]
                if frames then
                    for i = 1, 8 do
                        local f = frames[i]
                        if f and f:IsShown() and f.unit then
                            if DF.FullFrameRefresh then
                                DF:FullFrameRefresh(f)
                            end
                        end
                    end
                end
            else
                local header = self.headers[setIndex]
                if header then
                    for i = 1, 40 do
                        local child = header:GetAttribute("child" .. i)
                        if child and child:IsShown() and child.unit then
                            if DF.FullFrameRefresh then
                                DF:FullFrameRefresh(child)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- EVENT HANDLING
-- All initialization must happen synchronously during ADDON_LOADED
-- No C_Timer.After delays - they can fire during combat lockdown
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("ROLE_CHANGED_INFORM")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
eventFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
eventFrame:RegisterEvent("UNIT_FACTION")

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == "DandersFrames" then
            -- Initialize immediately during ADDON_LOADED
            -- During /reload, this fires BEFORE combat lockdown is re-established
            -- so we can safely create frames here without deferring
            if DF.db then
                PinnedFrames:Initialize()
                
                -- Populate the nameList - always update headers on load
                if PinnedFrames.initialized then
                    PinnedFrames:ProcessAllSets()
                    PinnedFrames:UpdateAllHeaders()  -- Force update even if no changes
                    
                    -- Force visual refresh on all child frames immediately
                    PinnedFrames:RefreshAllChildFrames()
                end
            end
        end
        return
    end
    
    if not DF.db then return end
    
    if event == "PLAYER_REGEN_DISABLED" then
        -- Auto-lock all unlocked pinned sets on combat start
        if PinnedFrames.initialized then
            PinnedFrames:LockAllForCombat()
        end
        return
    end
    
    if event == "PLAYER_REGEN_ENABLED" then
        -- Restore unlock state for sets that were unlocked before combat
        if PinnedFrames.initialized then
            PinnedFrames:RestoreUnlockedAfterCombat()
        end
        
        -- Process pending reinitialization after combat
        if PinnedFrames.pendingReinitialize then
            PinnedFrames.pendingReinitialize = nil
            PinnedFrames:Reinitialize()
            PinnedFrames:ProcessAllSets()
            return  -- Reinitialize handles everything
        end
        
        -- Process pending initialization after combat
        if PinnedFrames.pendingInitialize then
            PinnedFrames.pendingInitialize = nil
            PinnedFrames:Initialize()
            PinnedFrames:ProcessAllSets()
        end
        
        -- Process pending updates after combat
        if PinnedFrames.pendingNameListUpdate then
            for setIndex, _ in pairs(PinnedFrames.pendingNameListUpdate) do
                PinnedFrames:UpdateHeaderNameList(setIndex)
            end
            PinnedFrames.pendingNameListUpdate = nil
        end
        
        if PinnedFrames.pendingVisibilityUpdate then
            for setIndex, enabled in pairs(PinnedFrames.pendingVisibilityUpdate) do
                PinnedFrames:SetEnabled(setIndex, enabled)
            end
            PinnedFrames.pendingVisibilityUpdate = nil
        end

        -- Reset slot allocator + reapply layout now that we're out of combat.
        -- Fresh pull starts with all slots free; any frames still visible
        -- (rare — e.g. we left combat mid-add) re-enter via onBossShow.
        if PinnedFrames.initialized then
            for setIndex = 1, 2 do
                local set = GetSetDB(setIndex)
                if set and set.enabled and IsBossSet(set) then
                    local handler = PinnedFrames.bossHandlers[setIndex]
                    if handler then
                        handler:Execute([[ self:RunAttribute("resetAllocState") ]])
                    end
                    PinnedFrames:ApplyBossLayout(setIndex)
                    PinnedFrames:ResizeContainer(setIndex)

                    -- Re-claim slots for any frames still visible post-reset.
                    -- Single Execute call runs a loop inside the restricted env
                    -- rather than 8 separate interpolated snippets.
                    if handler then
                        handler:Execute([[
                            for i = 1, 8 do
                                local f = self:GetFrameRef("boss" .. i)
                                if f and f:IsShown() then
                                    self:RunAttribute("onBossShow", i)
                                end
                            end
                        ]])
                    end
                end
            end
        end
        return
    end
    
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        if PinnedFrames.initialized then
            PinnedFrames:OnBossFramesChanged()
        end
        return
    end

    if event == "UNIT_TARGETABLE_CHANGED" then
        if type(arg1) == "string" and arg1:match("^boss%d$") then
            if PinnedFrames.initialized then
                PinnedFrames:OnBossFramesChanged()
            end
        end
        return
    end

    if event == "UNIT_FACTION" then
        if type(arg1) == "string" and arg1:match("^boss%d$") then
            if PinnedFrames.initialized then
                PinnedFrames:OnBossFramesChanged()
            end
        end
        return
    end

    -- GROUP_ROSTER_UPDATE or ROLE_CHANGED_INFORM
    if PinnedFrames.initialized then
        -- Check if mode changed (party <-> raid)
        local actualMode = GetActualMode()
        if PinnedFrames.currentMode and actualMode ~= PinnedFrames.currentMode then
            DF:Debug("PINNED", "Mode changed from %s to %s — reinitializing",
                tostring(PinnedFrames.currentMode), tostring(actualMode))
            PinnedFrames:Reinitialize()
            return
        end
        
        PinnedFrames:ProcessAllSets()
    end
end)

-- ============================================================
-- DEBUG
-- ============================================================

function PinnedFrames:DebugPrint()
    print("|cFF00FFFF[DF Pinned]|r === Debug Info ===")
    print("  Initialized:", tostring(self.initialized))
    print("  Current mode:", self.currentMode or "unknown")
    print("  Actual mode:", GetActualMode())
    print("  DF.db exists:", tostring(DF.db ~= nil))
    
    local hlDB = GetPinnedDB()
    print("  pinnedFrames DB exists:", tostring(hlDB ~= nil))
    
    -- Show current group roster
    local roster = GetGroupRoster()
    local rosterCount = 0
    for _ in pairs(roster) do rosterCount = rosterCount + 1 end
    print("  Group roster count:", rosterCount)
    for name, _ in pairs(roster) do
        print("    -", name)
    end
    
    for i = 1, 2 do
        local set = GetSetDB(i)
        print(" ")
        print("  === Set " .. i .. " ===")
        if set then
            print("    Enabled:", tostring(set.enabled))
            print("    Locked:", tostring(set.locked))
            print("    ShowLabel:", tostring(set.showLabel))
            print("    Name:", set.name or "(nil)")
            print("    Players in set:", #set.players)
            for j, p in ipairs(set.players) do
                local inGroup = IsPlayerInGroup(p, roster)
                print("      [" .. j .. "]", p, inGroup and "(IN GROUP)" or "(not in group)")
            end
            
            local container = self.containers[i]
            local header = self.headers[i]
            local label = self.labels[i]
            
            print("    Container exists:", tostring(container ~= nil))
            if container then
                print("      Shown:", tostring(container:IsShown()))
                print("      Size:", container:GetWidth(), "x", container:GetHeight())
            end
            
            print("    Header exists:", tostring(header ~= nil))
            if header then
                print("      Shown:", tostring(header:IsShown()))
                local nameListAttr = header:GetAttribute("nameList") or "(nil)"
                print("      nameList attr:", nameListAttr)
                print("      sortMethod:", header:GetAttribute("sortMethod") or "(nil)")
                print("      template:", header:GetAttribute("template") or "(nil)")
                
                -- Count children
                local childCount = 0
                local shownChildren = 0
                for j = 1, 40 do
                    local child = header:GetAttribute("child" .. j)
                    if child then
                        childCount = childCount + 1
                        if child:IsShown() then
                            shownChildren = shownChildren + 1
                        end
                    end
                end
                print("      Children (total):", childCount)
                print("      Children (shown):", shownChildren)
                
                -- List first few children
                for j = 1, math.min(5, childCount) do
                    local child = header:GetAttribute("child" .. j)
                    if child then
                        local unit = child:GetAttribute("unit") or "none"
                        print("        child" .. j .. ":", child:GetName() or "unnamed", "unit=" .. unit, child:IsShown() and "SHOWN" or "hidden")
                    end
                end
            end
            
            print("    Label exists:", tostring(label ~= nil))
            if label then
                print("      Shown:", tostring(label:IsShown()))
                print("      Text:", label:GetText() or "(nil)")
            end
        else
            print("    (set config is nil)")
        end
    end
end

-- Test function - adds player to set 1 and enables it
function PinnedFrames:Test()
    local set = GetSetDB(1)
    if not set then
        print("|cFF00FFFF[DF Pinned]|r Test: No set 1 config found!")
        return
    end
    
    local fullName = GetUnitName("player", true)  -- Returns "Name-Realm"
    
    -- Add player if not already in list
    local found = false
    for _, p in ipairs(set.players) do
        if p == fullName then
            found = true
            break
        end
    end
    
    if not found then
        table.insert(set.players, fullName)
        print("|cFF00FFFF[DF Pinned]|r Test: Added", fullName, "to set 1")
    else
        print("|cFF00FFFF[DF Pinned]|r Test:", fullName, "already in set 1")
    end
    
    -- Enable set 1
    set.enabled = true
    self:SetEnabled(1, true)
    
    -- Update nameList
    self:UpdateHeaderNameList(1)
    
    print("|cFF00FFFF[DF Pinned]|r Test: Set 1 enabled with player")
    print("|cFF00FFFF[DF Pinned]|r Run /dfpinned info to see details")
end

-- ============================================================
-- TEST MODE INTEGRATION
-- Hooks called by TestMode/TestMode.lua when the main Test Mode
-- button is toggled. Populates ENABLED pinned sets with fake data:
--   Boss-mode sets: the real secure boss frames get dfIsTestFrame + fake NPC data
--   Player-mode sets: non-secure test Buttons are created per set container
--                      with fake roster data (names/classes/health)
-- Disabled sets are never touched.
-- ============================================================

-- Returns true if any pinned set is currently in test mode
function PinnedFrames:IsTestModeActive()
    return self.testModeActive == true
end

-- Returns the pinnedFrames sub-table for a specific mode ("raid" or "party").
-- Allows test-mode code to read the raid profile's pinned config while the
-- actual group state is solo/party, and vice versa.
local function GetPinnedDBForMode(isRaidMode)
    local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
    return db and db.pinnedFrames
end

-- Returns a set's config from the specified mode's profile.
local function GetSetDBForMode(setIndex, isRaidMode)
    local hlDB = GetPinnedDBForMode(isRaidMode)
    return hlDB and hlDB.sets and hlDB.sets[setIndex]
end

-- Create a single non-secure player-mode test frame parented to a pinned
-- set's test container. Mirrors the pattern used in TestMode/TestFramePool.lua
-- CreateTestFrame so the frame renders identically to live frames.
-- Create a single non-secure "mock" test frame for a pinned set, parented to
-- the set's test container. Handles both player-mode and boss-mode sets —
-- when isBossSet is true, the `isPinnedBossFrame` marker causes
-- DF:UpdateTestFrame to route to boss test data (NPC names via
-- GetTestUnitData(i, isRaid, true)).
local function CreatePlayerTestFrame(setIndex, index, container, isRaidMode, isBossSet)
    local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
    local frame = CreateFrame(
        "Button",
        "DandersPinnedTest" .. setIndex .. "_" .. index,
        container
    )
    frame:SetSize(db.frameWidth or 120, db.frameHeight or 50)

    frame.index = index
    frame.dfTestIndex = index
    frame.isRaidFrame = isRaidMode
    frame.dfIsTestFrame = true
    frame.dfIsDandersFrame = true
    frame.dfIsPinnedTestFrame = true  -- distinguish from testPartyFrames/testRaidFrames
    frame.isPinnedBossFrame = isBossSet or false
    frame.pinnedSetIndex = setIndex

    -- Fake unit token. For boss-mode test frames we use boss1..boss8 for
    -- consistency; for player mode we use party/raid tokens. UpdateHealthFast
    -- early-returns on dfIsTestFrame so the fake token is never actually
    -- queried via UnitExists/UnitHealth.
    if isBossSet then
        frame.unit = "boss" .. index
    else
        frame.unit = isRaidMode and ("raid" .. index) or (index == 1 and "player" or ("party" .. (index - 1)))
    end

    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")

    if DF.CreateFrameElements then
        DF:CreateFrameElements(frame, isRaidMode)
    end
    if DF.ApplyFrameStyle then
        DF:ApplyFrameStyle(frame)
    end
    if DF.ApplyAuraLayout then
        DF:ApplyAuraLayout(frame, "BUFF")
        DF:ApplyAuraLayout(frame, "DEBUFF")
    end

    frame:Hide()
    return frame
end

-- Attach a drag mover to the test container. Lets the user reposition test
-- frames live during test mode by dragging this handle — updates the
-- TEST MODE'S profile set.position (raid profile when raid test is on).
-- Themed with GetModeColors so raid test uses orange, party test uses blue.
local function AttachTestMover(container, set, isRaidMode)
    -- Mover is hidden when the set is locked (matches real pinned mover behavior)
    local shouldShow = not set.locked

    if container.testMover then
        -- Refresh refs + theme colors in case mode flipped
        container.testMover.dfSet = set
        container.testMover.dfIsRaidMode = isRaidMode
        local colors = GetModeColors(isRaidMode)
        container.testMover.bg:SetColorTexture(unpack(colors.moverBg))
        container.testMover.borderTex:SetColorTexture(unpack(colors.moverBorder))
        container.testMover.inner:SetColorTexture(unpack(colors.moverBg))
        container.testMover.text:SetTextColor(unpack(colors.moverText))
        container.testMover.text:SetText((isRaidMode and "Raid" or "Party") .. " Test — Drag")
        container.testMover:SetShown(shouldShow)
        return
    end

    local colors = GetModeColors(isRaidMode)
    local mover = CreateFrame("Frame", nil, UIParent)
    mover:SetSize(140, 16)
    mover:SetFrameStrata("HIGH")
    mover:SetPoint("BOTTOM", container, "TOP", 0, 2)
    mover.dfSet = set
    mover.dfIsRaidMode = isRaidMode

    mover.bg = mover:CreateTexture(nil, "BACKGROUND")
    mover.bg:SetAllPoints()
    mover.bg:SetColorTexture(unpack(colors.moverBg))

    mover.borderTex = mover:CreateTexture(nil, "BORDER")
    mover.borderTex:SetAllPoints()
    mover.borderTex:SetColorTexture(unpack(colors.moverBorder))
    mover.inner = mover:CreateTexture(nil, "ARTWORK")
    mover.inner:SetPoint("TOPLEFT", 1, -1)
    mover.inner:SetPoint("BOTTOMRIGHT", -1, 1)
    mover.inner:SetColorTexture(unpack(colors.moverBg))

    mover.text = mover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mover.text:SetPoint("CENTER")
    mover.text:SetText((isRaidMode and "Raid" or "Party") .. " Test — Drag")
    mover.text:SetTextColor(unpack(colors.moverText))

    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")

    local startMouseX, startMouseY, startPosX, startPosY

    mover:SetScript("OnDragStart", function(self)
        local currentSet = self.dfSet
        if not currentSet then return end
        local dragAnchor = GetContainerAnchorPoint(currentSet)
        local uiScale = UIParent:GetEffectiveScale()
        startMouseX, startMouseY = GetCursorPosition()
        startMouseX = startMouseX / uiScale
        startMouseY = startMouseY / uiScale
        local p = currentSet.position or { x = 0, y = 0 }
        startPosX = p.x or 0
        startPosY = p.y or 0
        self:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local ps = UIParent:GetEffectiveScale()
            mx = mx / ps
            my = my / ps
            local newX = startPosX + (mx - startMouseX)
            local newY = startPosY + (my - startMouseY)
            local s = container:GetScale() or 1
            container:ClearAllPoints()
            container:SetPoint(dragAnchor, UIParent, dragAnchor, newX / s, newY / s)
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        if not startMouseX then return end
        local currentSet = self.dfSet
        if not currentSet then return end
        local dragAnchor = GetContainerAnchorPoint(currentSet)
        local uiScale = UIParent:GetEffectiveScale()
        local mx, my = GetCursorPosition()
        mx = mx / uiScale
        my = my / uiScale
        local finalX = startPosX + (mx - startMouseX)
        local finalY = startPosY + (my - startMouseY)
        currentSet.position = { point = dragAnchor, x = finalX, y = finalY }
        local s = container:GetScale() or 1
        container:ClearAllPoints()
        container:SetPoint(dragAnchor, UIParent, dragAnchor, finalX / s, finalY / s)
    end)

    mover:SetShown(shouldShow)
    container.testMover = mover
end

-- Ensure the test container for a set exists and is positioned using the
-- specified mode's profile config for that set (so raid test mode while solo
-- anchors at the raid-profile's configured pinned position, not at the
-- party-profile's position). Non-secure frame; can be created in combat.
-- Also attaches a drag mover so the user can reposition test frames live.
function PinnedFrames:EnsureTestContainer(setIndex, set, isRaidMode)
    local container = self.testContainers[setIndex]
    if not container then
        container = CreateFrame(
            "Frame",
            "DandersPinnedTestContainer" .. setIndex,
            UIParent
        )
        container:SetFrameStrata("MEDIUM")
        self.testContainers[setIndex] = container
    end

    local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50
    container:SetSize(frameWidth, frameHeight)

    -- Use the SAVED anchor point (pos.point) first — that's what the user
    -- dragged the set to. Only fall back to GetContainerAnchorPoint (derived
    -- from grow-direction settings) if the set has never been positioned.
    -- Mismatching these puts the container off-screen: e.g. anchoring at
    -- TOPLEFT but using (x=0, y=200) that was saved for CENTER.
    local pos = set.position or {}
    local anchor = pos.point or GetContainerAnchorPoint(set)
    local scale = set.scale or 1.0
    container:SetScale(scale)
    container:ClearAllPoints()
    container:SetPoint(
        anchor, UIParent, anchor,
        (pos.x or 0) / scale, (pos.y or 0) / scale
    )
    container:Show()

    AttachTestMover(container, set, isRaidMode)

    -- Dedicated test label (parented to UIParent for scale independence).
    -- Anchored to the test container so it follows the test mover when
    -- dragged. Uses the test-mode profile's set name so it always reflects
    -- what's on screen (even in cross-mode like "raid test while in party").
    local testLabel = container.testLabel
    if not testLabel then
        testLabel = UIParent:CreateFontString(
            "DandersPinnedTest" .. setIndex .. "Label",
            "OVERLAY",
            "GameFontNormal"
        )
        testLabel:SetTextColor(0.8, 0.8, 1.0)
        container.testLabel = testLabel
    end
    testLabel:ClearAllPoints()
    testLabel:SetPoint("BOTTOM", container, "TOP", 0, 2)
    local labelText = set.name
    if not labelText or labelText == "" then
        labelText = "Pinned " .. setIndex
    end
    testLabel:SetText(labelText)
    testLabel:SetShown(set.showLabel)

    return container
end

-- Make sure the player-mode test frame pool for a set exists and is at least
-- `count` frames large. Frames are created lazily on demand, parented to the
-- set's test container (which lives at the test-mode profile's position).
function PinnedFrames:EnsurePlayerTestFramePool(setIndex, count, isRaidMode, isBossSet)
    local container = self.testContainers[setIndex]
    if not container then return end
    if count < 1 then count = 1 end
    -- Boss mode caps at 8 (WoW API limit); player mode caps at 40 (max raid)
    local cap = isBossSet and 8 or 40
    if count > cap then count = cap end

    self.testFrames[setIndex] = self.testFrames[setIndex] or {}
    local pool = self.testFrames[setIndex]

    for i = 1, count do
        if not pool[i] then
            pool[i] = CreatePlayerTestFrame(setIndex, i, container, isRaidMode, isBossSet)
        else
            -- Reparent + re-apply state in case test mode or set frameType
            -- flipped since last Enter.
            pool[i]:SetParent(container)
            local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
            pool[i]:SetSize(db.frameWidth or 120, db.frameHeight or 50)
            pool[i].isRaidFrame = isRaidMode
            pool[i].isPinnedBossFrame = isBossSet or false
        end
    end
end

-- Position the N player-mode test frames for a set using layout math from
-- the test-mode profile's set config.
function PinnedFrames:ApplyPlayerTestLayout(setIndex, set, isRaidMode)
    local container = self.testContainers[setIndex]
    local pool = self.testFrames[setIndex]
    if not set or not container or not pool then return end

    local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50

    local hSpacing = set.horizontalSpacing or 2
    local vSpacing = set.verticalSpacing or 2
    local unitsPerRow = set.unitsPerRow or 5
    local frameAnchor = set.frameAnchor or "START"
    local columnAnchor = set.columnAnchor or "START"
    local horizontal = set.growDirection == "HORIZONTAL"
    local anchor = GetContainerAnchorPoint(set)

    local n = set.testCount or 3
    if n < 1 then n = 1 end
    if n > 40 then n = 40 end

    -- Size container to fit N frames in the set's layout (mirrors
    -- ResizeContainer for real pinned sets). Frames anchor inside at the
    -- computed `anchor` corner, so the container needs to be the full grid
    -- dimension — otherwise the anchor corner sits in the wrong screen spot.
    local rows = math.ceil(n / unitsPerRow)
    local cols = math.min(n, unitsPerRow)
    local containerWidth, containerHeight
    if horizontal then
        containerWidth = cols * frameWidth + math.max(0, cols - 1) * hSpacing
        containerHeight = rows * frameHeight + math.max(0, rows - 1) * vSpacing
    else
        containerWidth = rows * frameWidth + math.max(0, rows - 1) * hSpacing
        containerHeight = cols * frameHeight + math.max(0, cols - 1) * vSpacing
    end
    container:SetSize(math.max(containerWidth, 50), math.max(containerHeight, 30))

    for i = 1, 40 do
        local f = pool[i]
        if f then
            if i <= n then
                f:SetSize(frameWidth, frameHeight)
                f.isRaidFrame = isRaidMode

                local slotIndex = i - 1
                local row = math.floor(slotIndex / unitsPerRow)
                local col = slotIndex - row * unitsPerRow

                local xStep = frameWidth + hSpacing
                local yStep = frameHeight + vSpacing
                local xOff, yOff
                if horizontal then
                    if frameAnchor == "END" then xOff = -col * xStep else xOff = col * xStep end
                    if columnAnchor == "END" then yOff = row * yStep else yOff = -row * yStep end
                else
                    if frameAnchor == "END" then yOff = col * yStep else yOff = -col * yStep end
                    if columnAnchor == "END" then xOff = -row * xStep else xOff = row * xStep end
                end

                f:ClearAllPoints()
                f:SetPoint(anchor, container, anchor, xOff, yOff)
                f:Show()
            else
                f:Hide()
            end
        end
    end
end

-- Hide all player-mode test frames and the test container for a set
function PinnedFrames:HidePlayerTestFrames(setIndex)
    local pool = self.testFrames[setIndex]
    if pool then
        for i = 1, #pool do
            if pool[i] then pool[i]:Hide() end
        end
    end
    local container = self.testContainers[setIndex]
    if container then
        if container.testMover then container.testMover:Hide() end
        if container.testLabel then container.testLabel:Hide() end
        container:Hide()
    end
end

-- Called when Test Mode is toggled ON. Renders fake non-secure test frames
-- for every enabled pinned set in the TEST MODE's profile. Works uniformly
-- for player-mode and boss-mode sets — the only difference is the fake
-- name source (roster names vs NPC names) and the max frame count. Real
-- secure frames (pinned headers, boss frames) are NEVER touched — they stay
-- at their live positions, unaffected.
function PinnedFrames:EnterTestMode()
    if not self.initialized then return end
    if InCombatLockdown() then return end

    self.testModeActive = true

    -- Pick the active test mode for sizing/data. Raid wins if both are on.
    local isRaidMode
    if DF.raidTestMode then
        isRaidMode = true
    elseif DF.testMode then
        isRaidMode = false
    else
        return
    end
    local actualModeMatches = (isRaidMode == IsInRaid())

    for setIndex = 1, 2 do
        local set = GetSetDBForMode(setIndex, isRaidMode)
        if set and set.enabled then
            local isBossSet = IsBossSet(set)
            local n = set.testCount or 3
            local cap = isBossSet and 8 or 40
            if n < 1 then n = 1 end
            if n > cap then n = cap end

            -- When the test mode matches the actual group mode, hide the
            -- real pinned header (if any) so it doesn't render alongside
            -- fake frames. Header stays untouched in cross-mode (it's
            -- already at a different position / already hidden).
            if actualModeMatches and self.headers[setIndex] and not isBossSet then
                self.headers[setIndex]:Hide()
            end
            -- Hide the REAL pinned container visuals (mover, bg, border,
            -- label) when test mode matches — otherwise the user sees stale
            -- chrome (blue box + label) anchored at the real container's
            -- position while dragging the test mover. The test container
            -- has its own dedicated mover + label that follow the test
            -- frames. In cross-mode we don't touch the real visuals (they
            -- may be in use by real frames at a different position).
            if actualModeMatches then
                local realContainer = self.containers[setIndex]
                if realContainer then
                    if realContainer.mover then
                        realContainer.mover:Hide()
                    end
                    if realContainer.bg then
                        realContainer.bg:Hide()
                    end
                    if realContainer.border then
                        realContainer.border:Hide()
                    end
                end
                local realLabel = self.labels[setIndex]
                if realLabel then
                    realLabel:Hide()
                end
            end

            self:EnsureTestContainer(setIndex, set, isRaidMode)

            self:EnsurePlayerTestFramePool(setIndex, n, isRaidMode, isBossSet)
            self:ApplyPlayerTestLayout(setIndex, set, isRaidMode)

            local pool = self.testFrames[setIndex]
            if pool then
                for i = 1, n do
                    if pool[i] and DF.UpdateTestFrame then
                        DF:UpdateTestFrame(pool[i], i, true)
                    end
                end
            end
        end
    end
end

-- Called when Test Mode is toggled OFF. Hide all pinned test frames and
-- their containers, and show the real player-mode header again (whose
-- visibility is driven by actual group membership). No secure frame
-- manipulation needed — Test Mode never touched them.
function PinnedFrames:ExitTestMode()
    if InCombatLockdown() then return end
    self.testModeActive = false

    -- Hide all test frames + test containers (both mode profiles)
    for setIndex = 1, 2 do
        self:HidePlayerTestFrames(setIndex)
    end

    -- Restore real headers for player-mode sets in the current mode (we may
    -- have hidden them when entering test mode in the same mode).
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and not IsBossSet(set) and set.enabled and self.headers[setIndex] then
            self.headers[setIndex]:Show()
        end
        -- Restore real pinned container visuals (mover, bg, border, label)
        -- based on current set state. Mover/bg/border follow the unlocked
        -- state; label follows showLabel. Disabled sets stay hidden.
        if set then
            local realContainer = self.containers[setIndex]
            if realContainer then
                if realContainer.mover then
                    realContainer.mover:SetShown(set.enabled and not set.locked)
                end
                if realContainer.bg then
                    realContainer.bg:SetShown(set.enabled and not set.locked)
                end
                if realContainer.border then
                    realContainer.border:SetShown(set.enabled and not set.locked)
                end
            end
            local realLabel = self.labels[setIndex]
            if realLabel then
                realLabel:SetShown(set.enabled and set.showLabel)
            end
        end
    end

    -- Legacy: no-op in the new design, but other code paths may still have
    -- cleared flags on real boss frames. Defensively clear to avoid stale
    -- dfIsTestFrame leaking from an older-session toggle.
    C_Timer.After(0.15, function()
        for setIndex = 1, 2 do
            local frames = self.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    local f = frames[i]
                    if f and f:IsShown() and f.unit and DF.FullFrameRefresh then
                        DF:FullFrameRefresh(f)
                    end
                end
            end
        end
    end)
end

-- Apply fake test data to all currently-shown pinned test frames. Called
-- by the Test Mode animation ticker so health bars stay in sync with
-- DF.TestData.animationPhase when testAnimateHealth is on.
function PinnedFrames:UpdateTestFrames()
    if not self.testModeActive then return end

    for setIndex = 1, 2 do
        local pool = self.testFrames[setIndex]
        if pool then
            for i = 1, #pool do
                local f = pool[i]
                if f and f:IsShown() and f.dfTestIndex then
                    if DF.UpdateTestFrame then
                        DF:UpdateTestFrame(f, f.dfTestIndex)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- TIMED BOSS SPAWN TEST
-- Schedules show/hide of individual boss slots over time, for
-- verifying slot-allocator behaviour without being in an encounter.
-- Does NOT populate unit data — bossN units still don't exist, so
-- health/aura rendering stays empty. Purely a layout testbed.
-- ============================================================

-- Predefined sequence used by `/dfpinned bossspawn demo`.
-- Format: { { bossIndex, "+"|"-", secondsFromStart }, ... }
local BOSS_SPAWN_DEMO = {
    { 1, "+",  0.5 },
    { 2, "+",  2.0 },
    { 3, "+",  4.0 },
    { 2, "-",  6.0 },
    { 4, "+",  7.5 },
    { 1, "-",  9.5 },
    { 5, "+", 11.0 },
    { 3, "-", 13.0 },
    { 6, "+", 14.5 },
    { 4, "-", 16.5 },
    { 5, "-", 18.5 },
    { 6, "-", 20.0 },
}

-- Parse "1+:0,3+:2,1-:5,4+:7" into { { idx, sign, t }, ... }.
-- Returns nil, errorString on parse error.
local function ParseBossSpawnScript(script)
    if type(script) ~= "string" or script == "" then
        return nil, "empty script"
    end
    local steps = {}
    for chunk in string.gmatch(script, "[^,]+") do
        local chunkTrim = chunk:match("^%s*(.-)%s*$")
        local idx, sign, t = chunkTrim:match("^(%d+)([%+%-]):(%-?%d+%.?%d*)$")
        if not idx then
            return nil, "bad step '" .. chunkTrim .. "' (expected form '1+:0')"
        end
        idx = tonumber(idx)
        t = tonumber(t)
        if not idx or idx < 1 or idx > 8 then
            return nil, "boss index " .. tostring(idx) .. " out of range 1..8"
        end
        if not t or t < 0 then
            return nil, "negative or invalid time in '" .. chunkTrim .. "'"
        end
        table.insert(steps, { idx, sign, t })
    end
    table.sort(steps, function(a, b) return a[3] < b[3] end)
    return steps
end

-- Generation counter lets StopBossSpawn cancel pending timers without
-- actually cancelling them (C_Timer doesn't expose cancellation); stale
-- callbacks compare their captured gen to the current one and no-op.
PinnedFrames.bossSpawnGeneration = 0

-- Flip a frame's visibility state driver to a literal show/hide value.
-- Literal values are NOT combat-restricted; only macro-conditional strings are.
local function ForceBossFrameVisible(setIndex, bossIndex, show)
    local frames = PinnedFrames.bossFrames[setIndex]
    if not frames then return end
    local f = frames[bossIndex]
    if not f then return end
    RegisterStateDriver(f, "visibility", show and "show" or "hide")
end

-- Restore real `[@bossN,help]show;hide` drivers on all boss-mode sets.
local function RestoreBossFrameDrivers()
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and set.enabled and IsBossSet(set) then
            local frames = PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    local f = frames[i]
                    if f then
                        RegisterStateDriver(f, "visibility",
                            "[@boss" .. i .. ",help]show;hide")
                    end
                end
            end
        end
    end
end

-- Schedule each step via C_Timer.After, keyed to a captured generation.
function PinnedFrames:RunBossSpawnScript(steps)
    self.bossSpawnGeneration = self.bossSpawnGeneration + 1
    local myGen = self.bossSpawnGeneration

    -- Start from a clean slate so the script's sequence is deterministic.
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and set.enabled and IsBossSet(set) then
            for i = 1, 8 do
                ForceBossFrameVisible(setIndex, i, false)
            end
        end
    end

    local maxT = 0
    for _, step in ipairs(steps) do
        local bossIndex, sign, t = step[1], step[2], step[3]
        if t > maxT then maxT = t end
        C_Timer.After(t, function()
            if PinnedFrames.bossSpawnGeneration ~= myGen then return end
            for setIndex = 1, 2 do
                local set = GetSetDB(setIndex)
                if set and set.enabled and IsBossSet(set) then
                    ForceBossFrameVisible(setIndex, bossIndex, sign == "+")
                end
            end
        end)
    end

    -- Auto-exit 2s after the last step so drivers restore themselves.
    C_Timer.After(maxT + 2, function()
        if PinnedFrames.bossSpawnGeneration ~= myGen then return end
        PinnedFrames:StopBossSpawn(true)
    end)
end

-- Cancel any pending scripted step and restore real drivers.
function PinnedFrames:StopBossSpawn(auto)
    self.bossSpawnGeneration = self.bossSpawnGeneration + 1
    RestoreBossFrameDrivers()
    if auto then
        print("|cFF00FFFF[DF Pinned]|r bossspawn script finished; real drivers restored")
    else
        print("|cFF00FFFF[DF Pinned]|r bossspawn OFF; real drivers restored")
    end
end

-- Public entry point.
--   nil | "" | "off"      → cancel any running script
--   "demo"                → run the built-in 20s sequence
--   custom script string  → parse and run
function PinnedFrames:SetBossSpawnTest(arg)
    if not arg or arg == "" or arg == "off" then
        self:StopBossSpawn(false)
        return
    end

    local anyBossSet = false
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and set.enabled and IsBossSet(set) then
            anyBossSet = true
            break
        end
    end
    if not anyBossSet then
        print("|cFF00FFFF[DF Pinned]|r No enabled boss-mode sets found. Enable a pinned set and set Frame Type to 'Friendly Boss NPCs' first.")
        return
    end

    local steps
    if arg == "demo" then
        steps = BOSS_SPAWN_DEMO
    else
        local parsed, err = ParseBossSpawnScript(arg)
        if not parsed then
            print("|cFF00FFFF[DF Pinned]|r bossspawn parse error: " .. err)
            print("|cFF00FFFF[DF Pinned]|r expected: '1+:0,3+:2,1-:5' (idx <+|->:<seconds>)")
            return
        end
        steps = parsed
    end

    print(format("|cFF00FFFF[DF Pinned]|r bossspawn running %d steps", #steps))
    self:RunBossSpawnScript(steps)
end

-- Test mode for boss frames: force N boss frames visible so the secure
-- positioning can be verified without being in an encounter. Runs out of
-- combat only (needs to unregister/re-register state drivers). Passing
-- nil/0/"off" exits test mode and restores the normal `[@bossN,help]` drivers.
-- Pass visibleCount 1..8 for fixed count, or the string "dyn" for
-- modifier-driven test (boss1 always, boss2-3 with shift, boss4-5 with
-- ctrl, boss6-8 with alt — lets you toggle frames in/out of combat to
-- verify the secure reposition snippet runs correctly).
function PinnedFrames:SetBossTestMode(visibleCount)
    if InCombatLockdown() then
        print("|cFF00FFFF[DF Pinned]|r Boss test mode cannot toggle during combat")
        return
    end

    local isDyn = (visibleCount == "dyn")
    if not isDyn then
        visibleCount = tonumber(visibleCount) or 0
        if visibleCount < 0 then visibleCount = 0 end
        if visibleCount > 8 then visibleCount = 8 end
    end

    self.bossTestMode = isDyn or (visibleCount > 0)
    self.bossTestCount = visibleCount

    local anyToggled = false
    for setIndex = 1, 2 do
        local set = GetSetDB(setIndex)
        if set and set.enabled and IsBossSet(set) then
            local frames = self.bossFrames[setIndex]
            if frames then
                if isDyn then
                    -- Modifier-driven dynamic test: lets you add/remove frames
                    -- with modifier keys, IN OR OUT OF COMBAT. State drivers
                    -- (including mod: conditions) evaluate continuously; when
                    -- they change, the handler's reposition snippet runs.
                    --   boss1:       always visible
                    --   boss2, boss3: visible while holding SHIFT
                    --   boss4, boss5: visible while holding CTRL
                    --   boss6, boss7, boss8: visible while holding ALT
                    local conditions = {
                        [1] = "show",
                        [2] = "[mod:shift]show;hide",
                        [3] = "[mod:shift]show;hide",
                        [4] = "[mod:ctrl]show;hide",
                        [5] = "[mod:ctrl]show;hide",
                        [6] = "[mod:alt]show;hide",
                        [7] = "[mod:alt]show;hide",
                        [8] = "[mod:alt]show;hide",
                    }
                    for i = 1, 8 do
                        local f = frames[i]
                        if f then
                            RegisterStateDriver(f, "visibility", conditions[i])
                        end
                    end
                elseif visibleCount > 0 then
                    -- Fixed-count test: literal state values, no macro eval.
                    -- State driver strings that don't start with `[` are used
                    -- as the literal state value.
                    for i = 1, 8 do
                        local f = frames[i]
                        if i <= visibleCount then
                            RegisterStateDriver(f, "visibility", "show")
                        else
                            RegisterStateDriver(f, "visibility", "hide")
                        end
                    end
                else
                    -- Test mode off: restore real conditions on the visibility driver
                    for i = 1, 8 do
                        local f = frames[i]
                        if f then
                            RegisterStateDriver(f, "visibility", "[@boss" .. i .. ",help]show;hide")
                        end
                    end
                end
                anyToggled = true
            end
        end
    end

    if not anyToggled then
        print("|cFF00FFFF[DF Pinned]|r No enabled boss-mode sets found. Enable a pinned set and set Frame Type to 'Friendly Boss NPCs' first.")
    elseif isDyn then
        print("|cFF00FFFF[DF Pinned]|r Boss test mode ON (dynamic): boss1 always; +2,3 with SHIFT; +4,5 with CTRL; +6,7,8 with ALT. Works in combat. Run '/dfpinned bosstest off' to exit.")
    elseif visibleCount > 0 then
        print(format("|cFF00FFFF[DF Pinned]|r Boss test mode ON: showing %d boss frames. Run '/dfpinned bosstest off' to exit.", visibleCount))
    else
        print("|cFF00FFFF[DF Pinned]|r Boss test mode OFF: restored real state drivers")
    end
end

-- Slash command for debug
SLASH_DFPINNED1 = "/dfpinned"
SlashCmdList["DFPINNED"] = function(msg)
    if msg == "info" then
        PinnedFrames:DebugPrint()
    elseif msg == "reinit" then
        PinnedFrames:Reinitialize()
        print("|cFF00FFFF[DF Pinned]|r Reinitialized")
    elseif msg == "test" then
        PinnedFrames:Test()
    elseif msg and msg:match("^bosstest") then
        -- "/dfpinned bosstest 3" | "/dfpinned bosstest dyn" | "/dfpinned bosstest off"
        local arg = msg:match("^bosstest%s+(%S+)")
        if arg == "off" or arg == "0" or arg == nil then
            PinnedFrames:SetBossTestMode(0)
        elseif arg == "dyn" then
            PinnedFrames:SetBossTestMode("dyn")
        else
            PinnedFrames:SetBossTestMode(tonumber(arg) or 0)
        end
    elseif msg and msg:match("^bossspawn") then
        local arg = msg:match("^bossspawn%s+(.+)$")
        PinnedFrames:SetBossSpawnTest(arg)
    else
        print("|cFF00FFFF[DF Pinned]|r Commands:")
        print("  info - Show detailed debug info (one-shot; pinned frame state dump)")
        print("  test - Add player to set 1 and enable")
        print("  bosstest <N> - Show N boss frames to test secure positioning (1-8, 'off' to exit)")
        print("  bosstest dyn - Modifier-driven test: boss1 always, +2,3 SHIFT, +4,5 CTRL, +6,7,8 ALT (works in combat)")
        print("  bossspawn demo - Run a 20s simulated spawn/despawn sequence for layout testing")
        print("  bossspawn <script> - Custom timed script, e.g. '1+:0,3+:2,1-:5'")
        print("  bossspawn off - Cancel any running bossspawn script")
        print("  reinit - Reinitialize frames")
        print("  (Continuous debug output is routed through the Debug Console under the 'PINNED' category — use /df console)")
    end
end
