local addonName, DF = ...
local L = DF.L

-- ============================================================
-- FRAME SORTING SYSTEM
-- Sorts party/raid frames by role and name
-- ============================================================

-- Local caching of frequently used globals for performance
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local sort = table.sort
local tinsert = table.insert
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitClass = UnitClass
local GetSpecializationInfoByID = GetSpecializationInfoByID

-- NOTE: Previously used reusable tables here, but that caused bugs when
-- SortFrameList was called while iterating over a previous result.
-- Now we return fresh tables each time. The garbage is minimal.

DF.Sort = {}
local Sort = DF.Sort

-- Spec to role mapping (melee vs ranged DPS)
-- This maps DPS spec IDs to whether they're melee
-- Tank/healer specs are excluded - they're filtered by role before this check
local MELEE_SPECS = {
    -- Death Knight
    [251] = true, [252] = true,                    -- Frost, Unholy
    -- Demon Hunter
    [577] = true,                                   -- Havoc
    -- Druid
    [103] = true,                                   -- Feral
    -- Hunter
    [255] = true,                                   -- Survival
    -- Monk
    [269] = true,                                   -- Windwalker
    -- Paladin
    [70] = true,                                    -- Retribution
    -- Rogue
    [259] = true, [260] = true, [261] = true,      -- Assassination, Outlaw, Subtlety
    -- Shaman
    [263] = true,                                   -- Enhancement
    -- Warrior
    [71] = true, [72] = true,                      -- Arms, Fury
}

-- Cache for unit info (cleared on group changes)
Sort.UnitCache = {}

-- ============================================================
-- ROLE DETECTION
-- ============================================================

-- Get the role for a unit (TANK, HEALER, MELEE, RANGED, or DAMAGER)
function Sort:GetUnitRole(unit)
    if not unit or not UnitExists(unit) then return "DAMAGER" end
    
    -- Check cache first
    local guid = UnitGUID(unit)
    if guid and self.UnitCache[guid] then
        return self.UnitCache[guid].role
    end
    
    -- Get assigned role
    local role = UnitGroupRolesAssigned(unit)
    
    -- For DPS, determine if melee or ranged
    if role == "DAMAGER" or role == "NONE" then
        local db = DF:GetDB()
        if db.sortSeparateMeleeRanged then
            local specID = nil
            
            -- For player, we can get spec directly
            if UnitIsUnit(unit, "player") then
                specID = GetSpecializationInfo(GetSpecialization() or 1)
            else
                -- For other players, try to get from inspection cache or guess from class
                -- Note: In a full implementation, you'd use NotifyInspect/INSPECT_READY
                -- For now, we'll use class-based guessing
                local _, class = UnitClass(unit)
                if class then
                    -- Classes that are primarily melee (DPS specs are all melee)
                    if class == "WARRIOR" or class == "ROGUE" or class == "DEATHKNIGHT" or class == "DEMONHUNTER" or class == "PALADIN" then
                        role = "MELEE"
                    -- Classes that are primarily ranged
                    elseif class == "MAGE" or class == "WARLOCK" then
                        role = "RANGED"
                    -- Classes with both melee and ranged DPS specs - default to ranged
                    else
                        role = "RANGED"
                    end
                else
                    role = "DAMAGER"
                end
            end
            
            -- Check spec if we have it
            if specID then
                if MELEE_SPECS[specID] then
                    role = "MELEE"
                else
                    role = "RANGED"
                end
            end
        else
            role = "DAMAGER"
        end
    end
    
    -- Cache the result
    if guid then
        self.UnitCache[guid] = self.UnitCache[guid] or {}
        self.UnitCache[guid].role = role
    end
    
    return role
end

-- Get sort priority for a role based on db settings
function Sort:GetRolePriority(role, db)
    local roleOrder = db.sortRoleOrder or { "TANK", "HEALER", "MELEE", "RANGED" }
    
    for i, r in ipairs(roleOrder) do
        if r == role then
            return i
        end
        -- Handle DAMAGER matching MELEE or RANGED when not separating
        if role == "DAMAGER" and (r == "MELEE" or r == "RANGED") then
            return i
        end
    end
    
    return 100 -- Unknown role goes last
end

-- ============================================================
-- SORTING LOGIC
-- ============================================================

-- Get sort priority for a class based on db settings
function Sort:GetClassPriority(class, db)
    if not class then return 100 end
    
    local classOrder = db.sortClassOrder
    if not classOrder then return 100 end
    
    for i, c in ipairs(classOrder) do
        if c == class then
            return i
        end
    end
    
    return 100 -- Unknown class goes last
end

-- Compare function for sorting frames
function Sort:CompareUnits(unitA, unitB, db)
    local roleA = self:GetUnitRole(unitA)
    local roleB = self:GetUnitRole(unitB)
    
    local prioA = self:GetRolePriority(roleA, db)
    local prioB = self:GetRolePriority(roleB, db)
    
    -- First sort by role priority
    if prioA ~= prioB then
        return prioA < prioB
    end
    
    -- Then sort by class if enabled
    if db.sortByClass then
        local _, classA = UnitClass(unitA)
        local _, classB = UnitClass(unitB)
        
        local classPrioA = self:GetClassPriority(classA, db)
        local classPrioB = self:GetClassPriority(classB, db)
        
        if classPrioA ~= classPrioB then
            return classPrioA < classPrioB
        end
    end
    
    -- Then sort alphabetically if enabled
    -- Supports "AZ", "ZA", or legacy true (treated as "AZ")
    local alpha = db.sortAlphabetical
    if alpha and alpha ~= false then
        local nameA = UnitName(unitA) or ""
        local nameB = UnitName(unitB) or ""
        if alpha == "ZA" then
            return nameA > nameB
        else
            return nameA < nameB
        end
    end
    
    return false
end

-- Compare function for test mode using test data
function Sort:CompareTestData(dataA, dataB, db)
    -- Get roles from test data
    local roleA = dataA.role or "DAMAGER"
    local roleB = dataB.role or "DAMAGER"
    
    -- Map test roles to sort roles, respecting melee/ranged separation
    local function MapTestRole(data)
        local role = data.role or "DAMAGER"
        if role == "TANK" or role == "HEALER" then return role end
        
        -- When separating melee/ranged, use spec ID for accurate classification
        if db.sortSeparateMeleeRanged then
            -- Check spec ID first (most accurate)
            local specID = data.specID
            if specID and specID > 0 then
                return MELEE_SPECS[specID] and "MELEE" or "RANGED"
            end
            
            -- Fallback to class-based detection (matches live fallback)
            local class = data.class
            if class then
                if class == "WARRIOR" or class == "ROGUE" or class == "DEATHKNIGHT" or class == "DEMONHUNTER" or class == "PALADIN" then
                    return "MELEE"
                else
                    return "RANGED"
                end
            end
        end
        
        return "DAMAGER"
    end
    
    roleA = MapTestRole(dataA)
    roleB = MapTestRole(dataB)
    
    local prioA = self:GetRolePriority(roleA, db)
    local prioB = self:GetRolePriority(roleB, db)
    
    -- First sort by role priority
    if prioA ~= prioB then
        return prioA < prioB
    end
    
    -- Then sort by class if enabled
    if db.sortByClass then
        local classA = dataA.class
        local classB = dataB.class
        
        local classPrioA = self:GetClassPriority(classA, db)
        local classPrioB = self:GetClassPriority(classB, db)
        
        if classPrioA ~= classPrioB then
            return classPrioA < classPrioB
        end
    end
    
    -- Then sort alphabetically if enabled
    -- Supports "AZ", "ZA", or legacy true (treated as "AZ")
    local alpha = db.sortAlphabetical
    if alpha and alpha ~= false then
        local nameA = dataA.name or ""
        local nameB = dataB.name or ""
        if alpha == "ZA" then
            return nameA > nameB
        else
            return nameA < nameB
        end
    end
    
    return false
end

-- Sort a list of frame data entries
-- Each entry should have: {frame = frame, unit = unit, isPlayer = bool, testData = optional}
-- In test mode, entries should have testData with .name, .class, .role
function Sort:SortFrameList(frameList, db, isTestMode)
    if not db.sortEnabled then return frameList end
    
    local playerEntry = nil
    local otherEntries = {}  -- Fresh table each call
    
    -- Separate player from others
    for _, entry in ipairs(frameList) do
        if entry.isPlayer then
            playerEntry = entry
        else
            tinsert(otherEntries, entry)
        end
    end
    
    -- Sort non-player entries
    if isTestMode then
        -- Use test data for sorting
        sort(otherEntries, function(a, b)
            local dataA = a.testData or {}
            local dataB = b.testData or {}
            return self:CompareTestData(dataA, dataB, db)
        end)
    else
        -- Use real unit data
        sort(otherEntries, function(a, b)
            return self:CompareUnits(a.unit, b.unit, db)
        end)
    end
    
    -- Build final list based on self position setting
    local sortedList = {}  -- Fresh table each call
    local selfPos = db.sortSelfPosition or "SORTED"
    
    -- Check if selfPos is a numeric position (1-5)
    local numericPos = tonumber(selfPos)
    
    if numericPos and playerEntry then
        -- Insert player at specific position
        local inserted = false
        for i, entry in ipairs(otherEntries) do
            -- Insert player before this position if we've reached the target
            if i == numericPos and not inserted then
                tinsert(sortedList, playerEntry)
                inserted = true
            end
            tinsert(sortedList, entry)
        end
        -- If we haven't inserted yet (position is beyond list length), add at end
        if not inserted then
            tinsert(sortedList, playerEntry)
        end
    elseif selfPos == "FIRST" and playerEntry then
        tinsert(sortedList, playerEntry)
        for _, entry in ipairs(otherEntries) do
            tinsert(sortedList, entry)
        end
    elseif selfPos == "LAST" and playerEntry then
        for _, entry in ipairs(otherEntries) do
            tinsert(sortedList, entry)
        end
        tinsert(sortedList, playerEntry)
    else
        -- SORTED (or legacy NORMAL) - sort player with everyone else
        if playerEntry then
            local inserted = false
            
            for i, entry in ipairs(otherEntries) do
                local playerFirst
                if isTestMode then
                    local playerData = playerEntry.testData or {}
                    local entryData = entry.testData or {}
                    playerFirst = self:CompareTestData(playerData, entryData, db)
                else
                    playerFirst = self:CompareUnits("player", entry.unit, db)
                end
                
                if playerFirst and not inserted then
                    tinsert(sortedList, playerEntry)
                    inserted = true
                end
                tinsert(sortedList, entry)
            end
            
            if not inserted then
                tinsert(sortedList, playerEntry)
            end
        else
            -- Can't reuse here, need to return the other entries directly
            return otherEntries
        end
    end
    
    return sortedList
end

-- ============================================================
-- CACHE MANAGEMENT
-- ============================================================

function Sort:ClearCache()
    wipe(self.UnitCache)
end

function Sort:TriggerResort()
    self:ClearCache()
    
    -- SecureSort handles ALL party frame positioning
    -- It queries roles FRESH each sort via roleFilter (works in combat!)
    if DF.SecureSort and DF.SecureSort.initialized and DF.SecureSort.framesRegistered then
        -- Push settings (only works out of combat, but that's fine for configuration)
        if not InCombatLockdown() then
            DF.SecureSort:PushSortSettings()
            DF.SecureSort:UpdateLayoutParamsOnButtons()
        end
        
        -- Trigger the secure sort (works in AND out of combat)
        -- Roles are queried fresh each time, not pre-cached
        DF.SecureSort:TriggerSecureSort()
    end
    
    -- Note: We do NOT call UpdateAllFrames() here anymore.
    -- SecureSort is now the only system that positions party frames.
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================
-- (Event-based sorting removed - Headers.lua unified handler manages all sorting)
-- ============================================================

-- ============================================================
-- SLASH COMMAND
-- ============================================================

SLASH_DFSORT1 = "/dfsort"
SlashCmdList["DFSORT"] = function(msg)
    if msg == "refresh" or msg == "resort" then
        Sort:TriggerResort()
        print("|cff00ff00DandersFrames:|r Re-sorted frames.")
    elseif msg == "clear" then
        Sort:ClearCache()
        print("|cff00ff00DandersFrames:|r Cleared sort cache.")
    elseif msg == "debug" then
        print("|cff00ccffDandersFrames Sort Debug:|r")
        local db = DF:GetDB()
        print("  sortEnabled:", db.sortEnabled)
        print("  sortSelfPosition:", db.sortSelfPosition)
        print("  sortByClass:", db.sortByClass)
        print("  sortAlphabetical:", tostring(db.sortAlphabetical))
        print("  sortSeparateMeleeRanged:", db.sortSeparateMeleeRanged)
        print("  sortRoleOrder:", table.concat(db.sortRoleOrder or {}, ", "))
        if db.sortByClass then
            print("  sortClassOrder:", table.concat(db.sortClassOrder or {}, ", "))
        end
        
        -- Show detected roles and classes for party members
        print("  Unit Info:")
        local _, playerClass = UnitClass("player")
        print("    player:", Sort:GetUnitRole("player"), "-", playerClass, "-", UnitName("player"))
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local _, unitClass = UnitClass(unit)
                print("    " .. unit .. ":", Sort:GetUnitRole(unit), "-", unitClass, "-", UnitName(unit))
            end
        end
    else
        print("|cff00ff00DandersFrames:|r /dfsort commands:")
        print("  refresh - Re-sort frames")
        print("  clear - Clear role cache")
        print("  debug - Show sort debug info")
    end
end
