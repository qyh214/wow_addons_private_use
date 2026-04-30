local addonName, DF = ...

-- ============================================================
-- FLAT RAID FRAMES - PinnedFrames-style implementation
-- Replaces the legacy raidCombinedHeader system
-- Uses SecureGroupHeaderTemplate with nameList for explicit control
-- ============================================================

local FlatRaidFrames = {}
DF.FlatRaidFrames = FlatRaidFrames

-- ============================================================
-- MODULE STATE
-- ============================================================

-- Frame storage
FlatRaidFrames.header = nil          -- SecureGroupHeaderTemplate
FlatRaidFrames.innerContainer = nil  -- Inner container for growth anchor control
FlatRaidFrames.initialized = false

-- Pending updates (for combat deferral)
FlatRaidFrames.pendingNameListUpdate = false
FlatRaidFrames.pendingLayoutUpdate = false
FlatRaidFrames.pendingVisibility = nil  -- nil = no pending, true/false = pending state
FlatRaidFrames.pendingInitialize = false
FlatRaidFrames.pendingReinitialize = false

-- Debug flag
FlatRaidFrames.debug = false

-- ============================================================
-- DEBUG UTILITIES
-- ============================================================

local function DebugPrint(...)
    if FlatRaidFrames.debug then
        print("|cFF00FFFF[DF FlatRaid]|r", ...)
    end
end

-- Build groupFilter string from raidGroupVisible setting
-- Returns e.g. "1,2,3,5,6,7" if group 4 and 8 are hidden
local function BuildGroupFilter()
    local db = DF:GetRaidDB()
    if not db or not db.raidGroupVisible then
        return "1,2,3,4,5,6,7,8"
    end
    local groups = {}
    for i = 1, 8 do
        local visible = db.raidGroupVisible[i]
        if visible == nil or visible then  -- Default to visible
            groups[#groups + 1] = tostring(i)
        end
    end
    if #groups == 0 then
        return "1,2,3,4,5,6,7,8"  -- Safety fallback
    end
    return table.concat(groups, ",")
end

-- ============================================================
-- CONFIG ACCESS
-- ============================================================

-- Get raid DB (shortcut)
local function GetRaidDB()
    return DF:GetRaidDB()
end

-- Check if we should be active (flat mode, not grouped mode)
local function ShouldBeActive()
    local db = GetRaidDB()
    return db and not db.raidUseGroups
end

-- ============================================================
-- ANCHOR CALCULATION
-- ============================================================

-- Get the corner anchor point for the header based on growth settings
-- This determines which corner of innerContainer the header anchors to
local function GetHeaderAnchorPoint(db)
    local horizontal = (db.growDirection == "HORIZONTAL")
    local frameAnchor = db.raidFlatFrameAnchor or "START"
    local columnAnchor = db.raidFlatColumnAnchor or "START"
    
    if horizontal then
        -- Horizontal: frameAnchor controls left/right, columnAnchor controls top/bottom
        if frameAnchor == "END" then
            return (columnAnchor == "END") and "BOTTOMRIGHT" or "TOPRIGHT"
        else
            return (columnAnchor == "END") and "BOTTOMLEFT" or "TOPLEFT"
        end
    else
        -- Vertical: frameAnchor controls top/bottom, columnAnchor controls left/right
        if frameAnchor == "END" then
            return (columnAnchor == "END") and "BOTTOMRIGHT" or "BOTTOMLEFT"
        else
            return (columnAnchor == "END") and "TOPRIGHT" or "TOPLEFT"
        end
    end
end

-- Get the anchor point for innerContainer within raidContainer
-- This is the "growth anchor" - where the frame group is positioned/grows from
-- Maps simplified options (START/CENTER/END) to WoW anchor points
-- The mapping depends on orientation (Rows vs Columns)
local function GetGrowthAnchorPoint(db)
    local growthAnchor = db.raidFlatGrowthAnchor or "START"
    local horizontal = (db.growDirection == "HORIZONTAL")  -- true = Rows, false = Columns
    
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
        -- Legacy values - map directly
        return growthAnchor
    end
end

-- Get current group roster as a lookup table
-- Returns: { [name] = true, ... }
local function GetGroupRoster()
    local roster = {}
    local numMembers = GetNumGroupMembers()
    
    if numMembers == 0 then
        -- Solo
        local name = UnitName("player")
        if name then
            roster[name] = true
        end
        return roster
    end
    
    local isRaid = IsInRaid()
    for i = 1, numMembers do
        local unit = isRaid and ("raid" .. i) or (i == 1 and "player" or "party" .. (i - 1))
        local name = UnitName(unit)
        if name then
            roster[name] = true
        end
    end
    
    return roster
end

-- Get player's full name (Name-Realm)
local function GetPlayerFullName()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

-- ============================================================
-- NAMELIST BUILDING
-- This is the core of the new system - we build a sorted list
-- of player names and let SecureGroupHeaderTemplate display them
-- ============================================================

-- Build a sorted nameList string based on current settings
-- This replaces the complex groupBy/groupingOrder/groupFilter juggling
function FlatRaidFrames:BuildSortedNameList()
    local db = GetRaidDB()
    if not db then return "" end
    
    local numMembers = GetNumGroupMembers()
    if numMembers == 0 then
        -- Solo - just return player name
        return UnitName("player") or ""
    end
    
    -- Settings
    local separateMeleeRanged = db.sortSeparateMeleeRanged
    local sortByClass = db.sortByClass
    local sortAlphabetical = db.sortAlphabetical
    
    -- Melee specs by specID (for melee/ranged separation)
    local meleeSpecs = {
        [250] = true, [251] = true, [252] = true,  -- Death Knight
        [577] = true, [581] = true,                 -- Demon Hunter
        [103] = true,                               -- Druid Feral
        [255] = true,                               -- Hunter Survival
        [269] = true,                               -- Monk Windwalker
        [70] = true,                                -- Paladin Ret
        [259] = true, [260] = true, [261] = true,  -- Rogue
        [263] = true,                               -- Shaman Enh
        [71] = true, [72] = true,                   -- Warrior Arms/Fury
    }
    
    -- Class-based melee fallback (when spec not available)
    -- Only classes whose DPS spec is always melee
    local meleeClasses = {
        DEATHKNIGHT = true, DEMONHUNTER = true, ROGUE = true, WARRIOR = true, PALADIN = true
    }
    
    -- Get melee/ranged type for a unit
    local function GetMeleeRangedType(unit, role, class)
        if role ~= "DAMAGER" then return nil end
        
        local specID
        if UnitIsUnit(unit, "player") then
            local spec = GetSpecialization()
            if spec then
                specID = GetSpecializationInfo(spec)
            end
        else
            specID = GetInspectSpecialization(unit)
        end
        
        if specID and specID > 0 then
            return meleeSpecs[specID] and "MELEE" or "RANGED"
        end
        
        -- Fallback to class-based detection
        return meleeClasses[class] and "MELEE" or "RANGED"
    end
    
    -- Build role priority from settings
    local roleOrder = db.sortRoleOrder or {"TANK", "HEALER", "MELEE", "RANGED"}
    local rolePriority = {}
    
    for i, role in ipairs(roleOrder) do
        if separateMeleeRanged then
            -- When separating melee/ranged, use MELEE and RANGED directly
            rolePriority[role] = i
        else
            -- When not separating, map MELEE/RANGED to DAMAGER
            if role == "MELEE" or role == "RANGED" then
                if not rolePriority["DAMAGER"] then
                    rolePriority["DAMAGER"] = i
                end
            else
                rolePriority[role] = i
            end
        end
    end
    
    -- Defaults
    rolePriority["TANK"] = rolePriority["TANK"] or 1
    rolePriority["HEALER"] = rolePriority["HEALER"] or 2
    if separateMeleeRanged then
        rolePriority["MELEE"] = rolePriority["MELEE"] or 3
        rolePriority["RANGED"] = rolePriority["RANGED"] or 4
    else
        rolePriority["DAMAGER"] = rolePriority["DAMAGER"] or 3
    end
    rolePriority["NONE"] = 99
    
    -- Class priority
    local classOrder = db.sortClassOrder or {
        "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", 
        "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", 
        "SHAMAN", "WARLOCK", "WARRIOR"
    }
    local classPriority = {}
    for i, className in ipairs(classOrder) do
        classPriority[className] = i
    end
    
    -- Gather all raid members with their info
    local members = {}
    local playerName = UnitName("player")
    local playerRealm = GetRealmName()
    local playerEntry = nil
    
    for i = 1, numMembers do
        local unit = "raid" .. i
        local name, realm = UnitName(unit)
        
        if name then
            -- Filter by group visibility
            local _, _, subgroup = GetRaidRosterInfo(i)
            if subgroup and db.raidGroupVisible and db.raidGroupVisible[subgroup] == false then
                -- Skip members in hidden groups
            else
            -- Build full name with realm for nameList
            -- Only append realm for cross-realm players (when realm is returned)
            -- Same-server players should use just the name (matches SecureGroupHeaderTemplate behavior)
            local fullName
            if realm and realm ~= "" then
                fullName = name .. "-" .. realm
            else
                fullName = name
            end
            
            local role = UnitGroupRolesAssigned(unit)
            if role == "NONE" then role = "DAMAGER" end
            
            local _, class = UnitClass(unit)
            class = class or "UNKNOWN"
            
            -- Determine sort role (may be MELEE/RANGED if separation enabled)
            local sortRole
            if separateMeleeRanged then
                local meleeRanged = GetMeleeRangedType(unit, role, class)
                sortRole = meleeRanged or role
            else
                sortRole = role
            end
            
            local isPlayer = UnitIsUnit(unit, "player")
            
            local entry = {
                name = name,
                fullName = fullName,
                realm = realm or playerRealm,
                role = role,
                sortRole = sortRole,
                class = class,
                classPriority = classPriority[class] or 99,
                rolePriority = rolePriority[sortRole] or 99,
                isPlayer = isPlayer,
                unit = unit,
            }
            
            if isPlayer then
                playerEntry = entry
            else
                table.insert(members, entry)
            end
            end  -- group visibility filter
        end
    end
    
    -- Sort function
    local function sortFunc(a, b)
        -- Sort by role priority first
        if a.rolePriority ~= b.rolePriority then
            return a.rolePriority < b.rolePriority
        end
        
        -- Then by class if enabled
        if sortByClass then
            if a.classPriority ~= b.classPriority then
                return a.classPriority < b.classPriority
            end
        end
        
        -- Then alphabetically if enabled
        if sortAlphabetical then
            if sortAlphabetical == "ZA" then
                return a.name > b.name
            else
                return a.name < b.name
            end
        end
        
        return false
    end
    
    -- Sort members
    table.sort(members, sortFunc)
    
    -- Build the nameList based on selfPosition setting
    local selfPosition = db.sortSelfPosition or "FIRST"
    local names = {}
    
    if selfPosition == "FIRST" and playerEntry then
        -- Player first (use short name for player)
        table.insert(names, playerEntry.name)
        for _, entry in ipairs(members) do
            table.insert(names, entry.fullName)
        end
    elseif selfPosition == "LAST" and playerEntry then
        -- Others first, player last
        for _, entry in ipairs(members) do
            table.insert(names, entry.fullName)
        end
        table.insert(names, playerEntry.name)
    else
        -- SORTED - include player in sorting
        if playerEntry then
            table.insert(members, playerEntry)
            table.sort(members, sortFunc)
        end
        for _, entry in ipairs(members) do
            if entry.isPlayer then
                table.insert(names, entry.name)
            else
                table.insert(names, entry.fullName)
            end
        end
    end
    
    local result = table.concat(names, ",")
    DebugPrint("BuildSortedNameList result:", result)
    return result
end

-- ============================================================
-- FRAME CREATION
-- Uses the same "startingIndex trick" as PinnedFrames
-- ============================================================

function FlatRaidFrames:CreateFrames()
    if self.header then
        DebugPrint("Header already exists, skipping creation")
        return
    end
    
    if InCombatLockdown() then
        DebugPrint("In combat, cannot create frames")
        return
    end
    
    -- Need raidContainer to exist
    if not DF.raidContainer then
        DebugPrint("raidContainer doesn't exist yet, deferring creation")
        return
    end
    
    local db = GetRaidDB()
    if not db then
        DebugPrint("No raid DB available")
        return
    end
    
    DebugPrint("Creating FlatRaidFrames...")
    
    -- ============================================================
    -- Create innerContainer - this handles growth anchor positioning
    -- The innerContainer sits inside raidContainer and resizes to fit frames
    -- Its anchor point within raidContainer determines growth direction
    -- ============================================================
    self.innerContainer = CreateFrame("Frame", "DandersFlatRaidInnerContainer", DF.raidContainer)
    self.innerContainer:SetSize(100, 100)  -- Will be resized by ResizeInnerContainer
    
    -- Anchor innerContainer based on growth anchor setting
    local growthAnchor = GetGrowthAnchorPoint(db)
    self.innerContainer:SetPoint(growthAnchor, DF.raidContainer, growthAnchor, 0, 0)
    DebugPrint("InnerContainer anchored to:", growthAnchor)
    
    -- ============================================================
    -- Create SecureGroupHeaderTemplate - parented to innerContainer
    -- ============================================================
    self.header = CreateFrame("Frame", "DandersFlatRaidHeader", self.innerContainer, "SecureGroupHeaderTemplate")
    
    -- Show all raid members - nameList controls which are visible
    self.header:SetAttribute("showPlayer", true)
    self.header:SetAttribute("showParty", false)
    self.header:SetAttribute("showRaid", true)
    self.header:SetAttribute("showSolo", true)
    self.header:SetAttribute("groupFilter", BuildGroupFilter())
    
    -- Use same template as main frames
    self.header:SetAttribute("template", "DandersUnitButtonTemplate")
    
    -- ============================================================
    -- CRITICAL: Apply layout attributes BEFORE startingIndex trick
    -- This matches the original CreateRaidCombinedHeader order
    -- ============================================================
    self:ApplyLayoutAttributesInternal()
    
    -- Store frame dimensions
    self.header:SetAttribute("frameWidth", db.frameWidth or 80)
    self.header:SetAttribute("frameHeight", db.frameHeight or 40)
    
    -- ============================================================
    -- STARTINGINDEX TRICK - Pre-create all 40 frames
    -- ============================================================
    self.header:SetAttribute("startingIndex", -39)  -- Creates up to 40 frames
    self.header:Show()
    self.header:SetAttribute("startingIndex", 1)    -- Reset to normal
    -- DON'T hide - visibility is managed by SetEnabled later
    
    -- Count created children and set their sizes
    local childCount = 0
    local frameWidth = db.frameWidth or 80
    local frameHeight = db.frameHeight or 40
    for i = 1, 40 do
        local child = self.header:GetAttribute("child" .. i)
        if child then
            childCount = childCount + 1
            child:SetSize(frameWidth, frameHeight)
            child.isRaidFrame = true
            if DF.RegisterRaidFrame then DF:RegisterRaidFrame(child) end
        end
    end
    DebugPrint("Created", childCount, "child frames, sized to", frameWidth, "x", frameHeight)

    -- Now switch to nameList mode and set initial nameList
    self.header:SetAttribute("sortMethod", "NAMELIST")
    self.header:SetAttribute("groupFilter", nil)  -- Clear groupFilter, nameList takes over
    self:UpdateNameList()
    
    -- Hide until SetEnabled is called
    self.header:Hide()
    self.innerContainer:Hide()
    
    DebugPrint("FlatRaidFrames creation complete")
end

-- Internal function to apply layout attributes (called during creation)
-- Uses anchor calculations like PinnedFrames
function FlatRaidFrames:ApplyLayoutAttributesInternal()
    local header = self.header
    if not header then return end
    
    local db = GetRaidDB()
    if not db then return end
    
    local horizontal = (db.growDirection == "HORIZONTAL")
    local hSpacing = db.raidFlatHorizontalSpacing or 2
    local vSpacing = db.raidFlatVerticalSpacing or 2
    local unitsPerRow = db.raidPlayersPerRow or 5
    local frameAnchor = db.raidFlatFrameAnchor or "START"
    local columnAnchor = db.raidFlatColumnAnchor or "START"
    
    -- Frame anchor point determines where first frame is placed and growth direction
    -- HORIZONTAL: START=LEFT (grow right), END=RIGHT (grow left)
    -- VERTICAL: START=TOP (grow down), END=BOTTOM (grow up)
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
    -- HORIZONTAL: columns are vertical, START=TOP (down), END=BOTTOM (up)
    -- VERTICAL: columns are horizontal, START=LEFT (right), END=RIGHT (left)
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
    
    -- Anchor header to innerContainer corner based on growth settings
    local headerAnchorPoint = GetHeaderAnchorPoint(db)
    header:ClearAllPoints()
    header:SetPoint(headerAnchorPoint, self.innerContainer, headerAnchorPoint, 0, 0)
    
    DebugPrint("ApplyLayoutAttributesInternal:")
    DebugPrint("  headerAnchor:", headerAnchorPoint)
    DebugPrint("  point:", point, "xOff:", xOff, "yOff:", yOff)
    DebugPrint("  columnAnchorPoint:", colAnchorPoint)
end

-- ============================================================
-- LAYOUT SETTINGS
-- Applies positioning attributes to the header (for runtime changes)
-- ============================================================

function FlatRaidFrames:ApplyLayoutSettings(skipRefresh)
    local header = self.header
    if not header then return end
    
    if InCombatLockdown() then
        self.pendingLayoutUpdate = true
        DebugPrint("Layout update deferred (combat)")
        return
    end
    
    local db = GetRaidDB()
    if not db then return end
    
    local frameWidth = db.frameWidth or 80
    local frameHeight = db.frameHeight or 40
    
    local horizontal = (db.growDirection == "HORIZONTAL")
    local hSpacing = db.raidFlatHorizontalSpacing or 2
    local vSpacing = db.raidFlatVerticalSpacing or 2
    local unitsPerRow = db.raidPlayersPerRow or 5
    local frameAnchor = db.raidFlatFrameAnchor or "START"
    local columnAnchor = db.raidFlatColumnAnchor or "START"
    
    -- Frame anchor point determines where first frame is placed and growth direction
    local point, xOff, yOff
    if horizontal then
        if frameAnchor == "END" then
            point = "RIGHT"
            xOff = -hSpacing
        else
            point = "LEFT"
            xOff = hSpacing
        end
        yOff = 0
    else
        if frameAnchor == "END" then
            point = "BOTTOM"
            yOff = vSpacing
        else
            point = "TOP"
            yOff = -vSpacing
        end
        xOff = 0
    end
    
    header:SetAttribute("point", point)
    header:SetAttribute("xOffset", xOff)
    header:SetAttribute("yOffset", yOff)
    
    -- Column anchor point
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
    
    -- Update innerContainer anchor (growth anchor)
    if self.innerContainer then
        local growthAnchor = GetGrowthAnchorPoint(db)
        self.innerContainer:ClearAllPoints()
        self.innerContainer:SetPoint(growthAnchor, DF.raidContainer, growthAnchor, 0, 0)
    end
    
    -- Update header anchor to innerContainer corner
    local headerAnchorPoint = GetHeaderAnchorPoint(db)
    header:ClearAllPoints()
    header:SetPoint(headerAnchorPoint, self.innerContainer, headerAnchorPoint, 0, 0)
    
    DebugPrint("ApplyLayoutSettings:")
    DebugPrint("  horizontal:", horizontal)
    DebugPrint("  frameAnchor:", frameAnchor, "columnAnchor:", columnAnchor)
    DebugPrint("  headerAnchor:", headerAnchorPoint)
    DebugPrint("  frameSize:", frameWidth, "x", frameHeight)
    DebugPrint("  spacing:", hSpacing, vSpacing)
    DebugPrint("  unitsPerRow:", unitsPerRow)
    
    -- ============================================================
    -- CRITICAL: 4-step refresh to force repositioning
    -- This is the secret sauce from the working PinnedFrames
    -- Skip when called from SetEnabled - UpdateNameList() follows immediately
    -- and does its own rebuild, making this stale-data refresh redundant
    -- ============================================================
    if not skipRefresh and header:IsShown() then
        -- Save current sorting state
        local currentNameList = header:GetAttribute("nameList")
        local currentGroupBy = header:GetAttribute("groupBy")
        local currentGroupingOrder = header:GetAttribute("groupingOrder")
        local currentGroupFilter = header:GetAttribute("groupFilter")
        local currentSortMethod = header:GetAttribute("sortMethod")
        
        -- Step 1: Clear nameList/groupBy to remove unit assignments
        header:SetAttribute("groupBy", nil)
        header:SetAttribute("nameList", "")
        
        -- Step 2: Clear all child positions and sync isRaidFrame flag
        -- Always true: these are structurally raid children regardless of IsInRaid() state
        for i = 1, 40 do
            local child = header:GetAttribute("child" .. i)
            if child then
                child:ClearAllPoints()
                child.isRaidFrame = true
                if DF.RegisterRaidFrame then DF:RegisterRaidFrame(child) end
            end
        end
        
        -- Step 3: Force header to process by hiding and showing
        header:Hide()
        header:Show()
        
        -- Step 4: Restore sorting - this reassigns units with new layout
        if currentGroupBy then
            -- Was using groupBy mode
            header:SetAttribute("groupingOrder", currentGroupingOrder)
            header:SetAttribute("groupFilter", currentGroupFilter)
            header:SetAttribute("sortMethod", currentSortMethod)
            header:SetAttribute("groupBy", currentGroupBy)
        elseif currentNameList and currentNameList ~= "" then
            -- Was using nameList mode
            header:SetAttribute("nameList", currentNameList)
            header:SetAttribute("sortMethod", "NAMELIST")
        end
        
        DebugPrint("  4-step refresh complete")
    end
    
    -- Resize innerContainer to fit frames
    self:ResizeInnerContainer()
end

-- Force the header to recalculate child positions
-- This is needed after changing layout attributes
function FlatRaidFrames:RefreshLayout()
    local header = self.header
    if not header then return end
    
    if InCombatLockdown() then
        self.pendingLayoutUpdate = true
        return
    end
    
    local db = GetRaidDB()
    local frameWidth = db and db.frameWidth or 80
    local frameHeight = db and db.frameHeight or 40
    
    DebugPrint("RefreshLayout - resizing children and toggling startingIndex")
    
    -- FIRST: Resize all child frames and sync isRaidFrame flag (needed for proper positioning)
    for i = 1, 40 do
        local child = header:GetAttribute("child" .. i)
        if child then
            child:SetSize(frameWidth, frameHeight)
            child.isRaidFrame = true
            if DF.RegisterRaidFrame then DF:RegisterRaidFrame(child) end
        end
    end
    
    -- Force SecureGroupHeaderTemplate to re-evaluate child positions
    -- by toggling startingIndex - this triggers a full layout refresh
    -- (Same approach as legacy ApplyFlatLayoutAttributes)
    local currentStartingIndex = header:GetAttribute("startingIndex") or 1
    header:SetAttribute("startingIndex", currentStartingIndex == 1 and 2 or 1)
    header:SetAttribute("startingIndex", 1)
    
    DebugPrint("Layout refreshed - children resized, startingIndex toggled")
end

-- Resize innerContainer to fit the visible frames
-- This is what makes the CENTER growth anchor work - as innerContainer resizes,
-- it expands symmetrically from its center point
function FlatRaidFrames:ResizeInnerContainer()
    if not self.innerContainer or not self.header then return end
    DF:Debug("FLATRAID", "ResizeInnerContainer: recalculating")
    
    local db = GetRaidDB()
    if not db then return end
    
    local frameWidth = db.frameWidth or 80
    local frameHeight = db.frameHeight or 40
    local horizontal = (db.growDirection == "HORIZONTAL")
    local hSpacing = db.raidFlatHorizontalSpacing or 2
    local vSpacing = db.raidFlatVerticalSpacing or 2
    local unitsPerRow = db.raidPlayersPerRow or 5
    
    -- Count visible children
    local visibleCount = 0
    for i = 1, 40 do
        local child = self.header:GetAttribute("child" .. i)
        if child and child:IsShown() then
            visibleCount = visibleCount + 1
        end
    end
    
    if visibleCount == 0 then
        self.innerContainer:SetSize(frameWidth, frameHeight)
        return
    end
    
    local rows = math.ceil(visibleCount / unitsPerRow)
    local cols = math.min(visibleCount, unitsPerRow)
    
    local width, height
    if horizontal then
        -- Horizontal: cols frames across, rows down
        width = cols * frameWidth + (cols - 1) * hSpacing
        height = rows * frameHeight + (rows - 1) * vSpacing
    else
        -- Vertical: rows frames down, cols across
        width = rows * frameWidth + (rows - 1) * hSpacing
        height = cols * frameHeight + (cols - 1) * vSpacing
    end
    
    self.innerContainer:SetSize(width, height)
    DF:Debug("FLATRAID", "ResizeInnerContainer: %dx%d (%d visible, %d rows, %d cols)", width, height, visibleCount, rows, cols)
    
    -- Only resize the shared raidContainer if flat mode is actually active
    -- In grouped mode, the position handler manages container sizing — FlatRaid
    -- must NOT touch it or grouped headers will jump to wrong positions
    local rdb = GetRaidDB()
    if rdb and not rdb.raidUseGroups then
        self:UpdateContainerSize()
        DF:SyncRaidMoverToContainer()
    else
        DF:Debug("FLATRAID", "ResizeInnerContainer: SKIPPING container resize (grouped mode active)")
    end
end

-- Update container size based on layout settings
function FlatRaidFrames:UpdateContainerSize()
    if not DF.raidContainer then return end
    if InCombatLockdown() then return end
    
    local db = GetRaidDB()
    if not db then return end
    
    local horizontal = (db.growDirection == "HORIZONTAL")
    local hSpacing = db.raidFlatHorizontalSpacing or 2
    local vSpacing = db.raidFlatVerticalSpacing or 2
    local frameWidth = db.frameWidth or 80
    local frameHeight = db.frameHeight or 40
    local unitsPerRow = db.raidPlayersPerRow or 5
    local maxColumns = math.ceil(40 / unitsPerRow)
    
    local containerWidth, containerHeight
    if horizontal then
        containerWidth = unitsPerRow * frameWidth + (unitsPerRow - 1) * hSpacing
        containerHeight = maxColumns * frameHeight + (maxColumns - 1) * vSpacing
    else
        containerWidth = maxColumns * frameWidth + (maxColumns - 1) * hSpacing
        containerHeight = unitsPerRow * frameHeight + (unitsPerRow - 1) * vSpacing
    end
    
    local oldW, oldH = DF.raidContainer:GetSize()
    DF.raidContainer:SetSize(containerWidth, containerHeight)
    DF:Debug("FLATRAID", "UpdateContainerSize: %dx%d -> %dx%d (raidUseGroups=%s)",
        math.floor(oldW + 0.5), math.floor(oldH + 0.5),
        math.floor(containerWidth + 0.5), math.floor(containerHeight + 0.5),
        tostring(db.raidUseGroups))
    DebugPrint("Container size:", containerWidth, "x", containerHeight)
end

-- ============================================================
-- NAMELIST UPDATE
-- The key function - sets the nameList attribute
-- ============================================================

function FlatRaidFrames:UpdateSorting()
    local header = self.header
    if not header then
        DebugPrint("UpdateSorting: no header")
        return
    end

    -- Safety: bail out if grouped mode is active — FlatRaid should not be sorting
    local rdb = GetRaidDB()
    if rdb and rdb.raidUseGroups then
        DF:Debug("FLATRAID", "UpdateSorting: BLOCKED (grouped mode active, raidUseGroups=true)")
        return
    end

    if InCombatLockdown() then
        self.pendingNameListUpdate = true
        DF:Debug("FLATRAID", "UpdateSorting: deferred (combat lockdown)")
        return
    end

    -- FrameSort integration: yield sorting to FrameSort when active
    if DF:IsFrameSortActive() then return end

    DF:Debug("FLATRAID", "UpdateSorting: starting")

    local db = GetRaidDB()
    if not db then return end

    -- Re-apply layout attributes (point, xOffset, yOffset) from the DB
    -- so that Hide/Show below rebuilds children with the correct spacing. (#269)
    self:ApplyLayoutSettings(true)
    
    -- Check sorting settings
    local sortEnabled = db.sortEnabled
    local selfPosition = db.sortSelfPosition or "SORTED"
    local separateMeleeRanged = db.sortSeparateMeleeRanged
    local sortByClass = db.sortByClass
    local sortAlphabetical = db.sortAlphabetical
    
    DebugPrint("UpdateSorting: sortEnabled=", sortEnabled, "selfPosition=", selfPosition)
    DebugPrint("  separateMeleeRanged=", separateMeleeRanged, "sortByClass=", sortByClass, "sortAlphabetical=", sortAlphabetical)
    
    -- CRITICAL: Handle sortEnabled=false first
    -- Must clear ALL sorting attributes to prevent stale nameList/groupBy from persisting
    if not sortEnabled then
        DebugPrint("  Sorting DISABLED - using INDEX mode (clearing all attributes)")
        
        -- Clear all sorting attributes with nil
        header:SetAttribute("nameList", nil)
        header:SetAttribute("groupBy", nil)
        header:SetAttribute("groupingOrder", nil)
        header:SetAttribute("roleFilter", nil)
        header:SetAttribute("strictFiltering", nil)
        header:SetAttribute("groupFilter", BuildGroupFilter())  -- Respect group visibility
        header:SetAttribute("sortMethod", "INDEX")
        
        -- Force header to recalculate by toggling visibility
        if header:IsShown() then
            header:Hide()
            header:Show()
        end
        
        -- Resize innerContainer to fit visible frames
        self:ResizeInnerContainer()
        return
    end
    
    -- Determine if we need nameList (complex sorting) or can use groupBy (simple role sorting)
    -- Use groupBy when: selfPosition=="SORTED" AND no advanced options
    local useGroupBy = selfPosition == "SORTED" 
                       and not separateMeleeRanged 
                       and not sortByClass 
                       and not sortAlphabetical
    
    DebugPrint("  useGroupBy=", useGroupBy)
    
    if useGroupBy then
        -- Simple mode: use groupBy=ASSIGNEDROLE with groupingOrder from role priority
        -- This matches how grouped layouts work
        
        -- Build groupingOrder from role priority
        local roleOrder = db.sortRoleOrder or {"TANK", "HEALER", "MELEE", "RANGED"}
        local groupingOrder = {}
        
        for _, role in ipairs(roleOrder) do
            if role == "MELEE" or role == "RANGED" then
                -- Map MELEE/RANGED to DAMAGER for groupBy (it only understands TANK/HEALER/DAMAGER)
                if not tContains(groupingOrder, "DAMAGER") then
                    table.insert(groupingOrder, "DAMAGER")
                end
            else
                table.insert(groupingOrder, role)
            end
        end
        
        local orderString = table.concat(groupingOrder, ",")
        DebugPrint("  Using groupBy mode, groupingOrder:", orderString)
        
        -- Set attributes for groupBy mode
        -- CRITICAL ORDER: 
        -- 1. Clear groupBy first (in case it was already set, setting other attrs would trigger update)
        -- 2. Set all other attributes
        -- 3. Set groupBy last (this triggers the update)
        header:SetAttribute("groupBy", nil)  -- Clear first!
        header:SetAttribute("nameList", nil)
        header:SetAttribute("groupingOrder", orderString)
        header:SetAttribute("groupFilter", BuildGroupFilter())
        header:SetAttribute("sortMethod", "NAME")  -- Sort alphabetically within groups
        header:SetAttribute("groupBy", "ASSIGNEDROLE")  -- This triggers update, must be last
    else
        -- Complex mode: use nameList for full control over order
        local nameList = self:BuildSortedNameList()
        DebugPrint("  Using nameList mode:", nameList ~= "" and nameList or "(empty)")

        -- Set attributes for nameList mode
        -- CRITICAL ORDER (#543): Set nameList/sortMethod FIRST, then clear groupBy attrs.
        -- If we clear groupBy/groupFilter first, the header enters an invalid intermediate
        -- state where stale group-header children (and their Blizzard PrivateAuraAnchor
        -- children) cause "calling 'Hide' on bad self" errors during the Hide/Show toggle.
        header:SetAttribute("nameList", nameList)
        header:SetAttribute("sortMethod", "NAMELIST")
        header:SetAttribute("groupBy", nil)
        header:SetAttribute("groupingOrder", nil)
        header:SetAttribute("groupFilter", nil)
    end

    -- Force header to recalculate by toggling visibility
    if header:IsShown() then
        header:Hide()
        header:Show()
    end
    
    -- Resize innerContainer to fit visible frames
    -- Note: Call directly, no delays (combat safety)
    self:ResizeInnerContainer()

    -- Belt-and-suspenders: In complex sort mode, re-apply nameList on next frame
    -- to catch any roster data that wasn't fresh at call time. This fixes a timing gap
    -- where hidden groups could bleed through if the nameList was built from stale data.
    -- NOTE: We call BuildSortedNameList() directly here instead of UpdateNameList()/UpdateSorting()
    -- to avoid an infinite loop: UpdateSorting() in complex mode always schedules this same
    -- deferred timer, so calling UpdateNameList() here would cause it to fire every frame.
    if not useGroupBy then
        C_Timer.After(0, function()
            if not InCombatLockdown() and FlatRaidFrames.header and FlatRaidFrames.header:IsShown() then
                -- Refresh nameList directly to avoid re-entering UpdateSorting
                local nameList = FlatRaidFrames:BuildSortedNameList()
                FlatRaidFrames.header:SetAttribute("nameList", nameList)
            end
        end)
    end

    -- Schedule private aura reanchor after all attribute changes settle
    if DF.SchedulePrivateAuraReanchor then
        DF:SchedulePrivateAuraReanchor()
    end
end

-- Alias for backward compatibility
function FlatRaidFrames:UpdateNameList()
    self:UpdateSorting()
end

-- ============================================================
-- ENABLE / DISABLE
-- ============================================================
-- ENABLE / DISABLE
-- ============================================================

-- Refresh all child frames (called after enabling for combat reload support)
function FlatRaidFrames:RefreshAllChildFrames()
    if not self.header then return end
    
    for i = 1, 40 do
        local child = self.header:GetAttribute("child" .. i)
        if child and child.unit and child:IsVisible() then
            -- Full frame refresh (uses Blizzard aura cache only, no fallback)
            if DF.FullFrameRefresh then
                DF:FullFrameRefresh(child)
            end
        end
    end
    DebugPrint("Refreshed all child frames")
end

function FlatRaidFrames:SetEnabled(enabled)
    DebugPrint("SetEnabled:", enabled)

    -- Guard against re-entrant calls: SetEnabled(false) calls UpdateRaidHeaderVisibility
    -- which can call SetEnabled again, causing infinite recursion
    if self._settingEnabled then return end
    self._settingEnabled = true

    if not self.header then
        if enabled then
            self:CreateFrames()
        end
        -- If still no header after creation attempt, bail
        if not self.header then
            DebugPrint("SetEnabled: no header available")
            self._settingEnabled = nil
            return
        end
    end

    if InCombatLockdown() then
        self.pendingVisibility = enabled
        DebugPrint("Visibility change deferred (combat)")
        self._settingEnabled = nil
        return
    end

    local header = self.header

    -- Tell the grouped-mode secure position handler whether flat mode is active
    -- so it won't resize the shared raidContainer with grouped-grid dimensions
    if DF.raidPositionHandler then
        DF.raidPositionHandler:SetAttribute("flatmodeactive", enabled and 1 or 0)
    end

    if enabled then
        -- ALWAYS hide separated headers when enabling flat mode, even on the fast path.
        -- Auto layout can switch from grouped→flat between frames, leaving grouped headers
        -- visible from the prior mode. Without this, both layouts render on top of each other.
        if DF.raidSeparatedHeaders then
            for i = 1, 8 do
                local sepHeader = DF.raidSeparatedHeaders[i]
                if sepHeader then
                    sepHeader:Hide()
                    if DF.SetHeaderChildrenEventsEnabled then
                        DF:SetHeaderChildrenEventsEnabled(sepHeader, false)
                    end
                end
            end
        end

        -- When already visible, only refresh child sizes and isRaidFrame flag
        -- (skip the heavy Hide/Show + UpdateNameList cycle to avoid double-work
        -- since ApplyRaidFlatSorting will follow from ProcessRosterUpdate).
        if header:IsShown() and self.innerContainer and self.innerContainer:IsShown() then
            DF:Debug("FLATRAID", "SetEnabled(true): already visible, refreshing child sizes only")
            local db = GetRaidDB()
            local frameWidth = db and db.frameWidth or 80
            local frameHeight = db and db.frameHeight or 40
            for i = 1, 40 do
                local child = header:GetAttribute("child" .. i)
                if child then
                    child:SetSize(frameWidth, frameHeight)
                    child.isRaidFrame = true
                    if DF.RegisterRaidFrame then DF:RegisterRaidFrame(child) end
                end
            end
            -- Reapply layout settings in case spacing/anchors/growth changed
            self:ApplyLayoutSettings(true)  -- true = skip internal 4-step refresh
            self:ResizeInnerContainer()
            self._settingEnabled = nil
            return
        end

        DF:Debug("FLATRAID", "SetEnabled(true): performing full setup")

        -- 1. Apply layout attributes (skip 4-step refresh - UpdateNameList rebuilds below)
        self:ApplyLayoutSettings(true)
        
        -- 2. Ensure child frame sizes and isRaidFrame flag are correct BEFORE refresh
        local db = GetRaidDB()
        local frameWidth = db and db.frameWidth or 80
        local frameHeight = db and db.frameHeight or 40
        -- Always true: these are structurally raid children regardless of IsInRaid() state
        for i = 1, 40 do
            local child = header:GetAttribute("child" .. i)
            if child then
                child:SetSize(frameWidth, frameHeight)
                child.isRaidFrame = true
                if DF.RegisterRaidFrame then DF:RegisterRaidFrame(child) end
            end
        end

        -- 3. Update nameList (this will do Hide/Show to refresh with FRESH data)
        self:UpdateNameList()
        
        -- 4. Show innerContainer and header
        if self.innerContainer then
            self.innerContainer:Show()
        end
        header:Show()
        
        -- 5. Resize innerContainer to fit visible frames
        self:ResizeInnerContainer()
        
        if DF.SetHeaderChildrenEventsEnabled then
            DF:SetHeaderChildrenEventsEnabled(header, true)
        end
        
        -- 6. CRITICAL: Force full refresh on all child frames
        -- This ensures auras, absorbs, etc. are updated on combat reload
        self:RefreshAllChildFrames()
        
        -- 7. Delayed resize to ensure proper positioning after frames become visible
        -- SecureGroupHeaderTemplate may not immediately show children after nameList update
        -- If combat starts before the timer fires, queue for PLAYER_REGEN_ENABLED
        C_Timer.After(0.1, function()
            if self.header and self.header:IsShown() then
                if not InCombatLockdown() then
                    self:ResizeInnerContainer()
                else
                    self.pendingResize = true
                end
            end
        end)
    else
        DF:Debug("FLATRAID", "SetEnabled(false): hiding flat raid frames")
        header:Hide()
        if self.innerContainer then
            self.innerContainer:Hide()
        end
        if DF.SetHeaderChildrenEventsEnabled then
            DF:SetHeaderChildrenEventsEnabled(header, false)
        end

        -- When flat frames are disabled and grouped mode is active, ensure
        -- separated headers are visible. This handles the deferred-from-combat
        -- case where the original "show separated" call ran while flat was
        -- still visible. Guard on raidUseGroups to prevent infinite loop
        -- (when raidUseGroups=false, UpdateRaidHeaderVisibility would call
        -- SetEnabled(true), but we only call it when raidUseGroups=true).
        local db = GetRaidDB()
        if db and db.raidUseGroups and DF.UpdateRaidHeaderVisibility
                and IsInRaid() and not InCombatLockdown() then
            DF:UpdateRaidHeaderVisibility()
        end
    end

    self._settingEnabled = nil
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function FlatRaidFrames:Initialize()
    if self.initialized then
        DebugPrint("Already initialized")
        return
    end
    
    -- Only initialize if we're supposed to use flat mode
    if not ShouldBeActive() then
        DebugPrint("Not in flat mode, skipping initialization")
        return
    end
    
    -- Only initialize if the toggle is enabled
    if false then -- useNewFlatRaid always true
        DebugPrint("useNewFlatRaid is false, skipping initialization")
        return
    end
    
    DebugPrint("Initializing FlatRaidFrames...")
    
    self:CreateFrames()
    self.initialized = true
    
    DebugPrint("Initialization complete")
end

function FlatRaidFrames:Reinitialize()
    DebugPrint("Reinitializing...")
    
    if InCombatLockdown() then
        DebugPrint("In combat, cannot reinitialize")
        self.pendingReinitialize = true
        return
    end
    
    -- Clean up old header and innerContainer
    if self.header then
        self.header:Hide()
        -- Note: We can't actually destroy the frame, but we can hide it
        self.header = nil
    end
    
    if self.innerContainer then
        self.innerContainer:Hide()
        self.innerContainer = nil
    end
    
    self.initialized = false
    self:Initialize()
    
    -- If we're supposed to be active, enable
    if ShouldBeActive() and self.initialized then
        self:SetEnabled(true)
    end
end

-- ============================================================
-- EVENT HANDLING
-- All initialization must happen synchronously during ADDON_LOADED
-- No C_Timer.After delays - they can fire during combat lockdown
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
-- NOTE: GROUP_ROSTER_UPDATE, ROLE_CHANGED_INFORM, and PLAYER_SPECIALIZATION_CHANGED
-- are NOT registered here. Roster changes are handled by ProcessRosterUpdate() in Headers.lua
-- which calls ApplyRaidFlatSorting() -> UpdateNameList(). Handling them here too caused
-- a double-update: once immediately from this handler, and once on the next frame from
-- the throttled ProcessRosterUpdate, making frames visibly jump on every roster change.

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    -- ============================================================
    -- ADDON_LOADED - Initialize immediately for combat safety
    -- During /reload, this fires BEFORE combat lockdown is re-established
    -- ============================================================
    if event == "ADDON_LOADED" then
        if arg1 == "DandersFrames" then
            -- Only initialize if:
            -- 1. DB is ready
            -- 2. Toggle is enabled  
            -- 3. We're in flat mode
            -- 4. raidContainer exists (created by Headers.lua)
            if DF.db and ShouldBeActive() and DF.raidContainer then
                DebugPrint("ADDON_LOADED: Initializing FlatRaidFrames")
                FlatRaidFrames:Initialize()
                if FlatRaidFrames.initialized then
                    FlatRaidFrames:SetEnabled(true)
                end
            else
                DebugPrint("ADDON_LOADED: Conditions not met, will initialize later")
                DebugPrint("  db:", DF.db and "yes" or "no")
                DebugPrint("  useNewFlatRaid:", "yes (always)")
                DebugPrint("  ShouldBeActive:", ShouldBeActive() and "yes" or "no")
                DebugPrint("  raidContainer:", DF.raidContainer and "yes" or "no")
            end
        end
        return
    end
    
    -- ============================================================
    -- PLAYER_REGEN_ENABLED - Process pending updates after combat
    -- ============================================================
    if event == "PLAYER_REGEN_ENABLED" then
        -- Handle pending initialization
        if FlatRaidFrames.pendingInitialize then
            FlatRaidFrames.pendingInitialize = nil
            if ShouldBeActive() then
                FlatRaidFrames:Initialize()
                if FlatRaidFrames.initialized then
                    FlatRaidFrames:SetEnabled(true)
                end
            end
            return
        end
        
        -- Handle pending reinitialize (profile change, etc.)
        if FlatRaidFrames.pendingReinitialize then
            FlatRaidFrames.pendingReinitialize = nil
            FlatRaidFrames:Reinitialize()
            return
        end
        
        -- Only process other pending updates if active
        if not DF.db or not FlatRaidFrames.initialized then
            return
        end
        if not ShouldBeActive() then return end
        
        -- Process pending updates
        if FlatRaidFrames.pendingNameListUpdate then
            FlatRaidFrames.pendingNameListUpdate = false
            C_Timer.After(0, function()
                if FlatRaidFrames.header and FlatRaidFrames.header:IsShown() then
                    FlatRaidFrames:UpdateNameList()
                end
            end)
        end
        
        if FlatRaidFrames.pendingLayoutUpdate then
            FlatRaidFrames:ApplyLayoutSettings()
            FlatRaidFrames.pendingLayoutUpdate = false
        end
        
        if FlatRaidFrames.pendingVisibility ~= nil then
            FlatRaidFrames:SetEnabled(FlatRaidFrames.pendingVisibility)
            FlatRaidFrames.pendingVisibility = nil
        end

        if FlatRaidFrames.pendingResize then
            FlatRaidFrames.pendingResize = false
            if FlatRaidFrames.header and FlatRaidFrames.header:IsShown() then
                FlatRaidFrames:ResizeInnerContainer()
            end
        end
        return
    end
    
end)

-- ============================================================
-- DEBUG COMMANDS
-- ============================================================

SLASH_DFFLATRAID1 = "/dfflatraid"
SlashCmdList["DFFLATRAID"] = function(msg)
    if msg == "debug" then
        FlatRaidFrames.debug = not FlatRaidFrames.debug
        print("|cFF00FFFF[DF FlatRaid]|r Debug:", FlatRaidFrames.debug and "ON" or "OFF")
        
    elseif msg == "info" then
        FlatRaidFrames:DebugPrint()
        
    elseif msg == "reinit" then
        if InCombatLockdown() then
            print("|cFF00FFFF[DF FlatRaid]|r Cannot reinitialize in combat")
        else
            FlatRaidFrames:Reinitialize()
            print("|cFF00FFFF[DF FlatRaid]|r Reinitialized")
        end
        
    elseif msg == "test" then
        -- Quick test - initialize and enable
        if false then -- useNewFlatRaid always true
            print("|cFF00FFFF[DF FlatRaid]|r Toggle is OFF. Use /dfnewflat to enable first.")
            return
        end
        FlatRaidFrames:Initialize()
        FlatRaidFrames:SetEnabled(true)
        print("|cFF00FFFF[DF FlatRaid]|r Test: Initialized and enabled")
        
    else
        print("|cFF00FFFF[DF FlatRaid]|r Commands:")
        print("  debug - Toggle debug output")
        print("  info - Show detailed state info")
        print("  reinit - Reinitialize frames")
        print("  test - Initialize and enable (for testing)")
    end
end

-- Detailed state dump
function FlatRaidFrames:DebugPrint()
    print("|cFF00FFFF[DF FlatRaid]|r ========== State Info ==========")
    print("  useNewFlatRaid:", "true (always)")
    print("  initialized:", self.initialized and "true" or "false")
    print("  debug:", self.debug and "true" or "false")
    print("  shouldBeActive:", ShouldBeActive() and "true" or "false")
    
    print(" ")
    print("  Pending updates:")
    print("    nameList:", self.pendingNameListUpdate and "true" or "false")
    print("    layout:", self.pendingLayoutUpdate and "true" or "false")
    print("    visibility:", self.pendingVisibility ~= nil and tostring(self.pendingVisibility) or "none")
    
    print(" ")
    if self.header then
        print("  Header: EXISTS")
        print("    shown:", self.header:IsShown() and "true" or "false")
        print("    nameList:", self.header:GetAttribute("nameList") or "(nil)")
        print("    sortMethod:", self.header:GetAttribute("sortMethod") or "(nil)")
        print("    groupFilter:", self.header:GetAttribute("groupFilter") or "(nil)")
        print("    point:", self.header:GetAttribute("point") or "(nil)")
        print("    unitsPerColumn:", self.header:GetAttribute("unitsPerColumn") or "(nil)")
        print("    maxColumns:", self.header:GetAttribute("maxColumns") or "(nil)")
        
        -- Count children
        local childCount = 0
        local shownCount = 0
        for i = 1, 40 do
            local child = self.header:GetAttribute("child" .. i)
            if child then
                childCount = childCount + 1
                if child:IsShown() then
                    shownCount = shownCount + 1
                end
            end
        end
        print("    children (total):", childCount)
        print("    children (shown):", shownCount)
    else
        print("  Header: NIL")
    end
    
    print(" ")
    local db = GetRaidDB()
    if db then
        print("  DB Settings:")
        print("    raidUseGroups:", db.raidUseGroups and "true" or "false")
        print("    growDirection:", db.growDirection or "(nil)")
        print("    raidPlayersPerRow:", db.raidPlayersPerRow or "(nil)")
        print("    raidFlatPlayerAnchor:", db.raidFlatPlayerAnchor or "(nil)")
        print("    sortSelfPosition:", db.sortSelfPosition or "(nil)")
    else
        print("  DB: NIL")
    end
    
    print("|cFF00FFFF[DF FlatRaid]|r ================================")
end
