local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast

-- Local aliases for shared constants (defined in Constants.lua)
local DB_VERSION = CC.DB_VERSION
local PROFILE_TEMPLATE = CC.PROFILE_TEMPLATE

-- Local alias for helper functions (defined in Constants.lua)
local function GetDefaultProfileName() return CC.GetDefaultProfileName and CC.GetDefaultProfileName() or "Default" end

-- HELPER FUNCTIONS (defined early for use throughout)
-- ============================================================

-- Get the combat conditional for a binding (returns nil, "combat", or "nocombat")
-- Uses new 'combat' field, falls back to old 'loadCombat' for compatibility
local function GetCombatCondition(binding)
    -- Check new field first
    if binding.combat then
        if binding.combat == "incombat" then
            return "combat"
        elseif binding.combat == "outofcombat" then
            return "nocombat"
        else
            return nil  -- "always" means no condition
        end
    end
    -- Fall back to old field for compatibility
    return binding.loadCombat
end

-- Check if binding has a combat restriction (not "always")
local function HasCombatRestriction(binding)
    local cond = GetCombatCondition(binding)
    return cond ~= nil
end

-- Build the modifier prefix string for an attribute
-- WoW SecureActionButtonTemplate requires modifiers in order: alt, ctrl, shift
local function BuildModifierPrefix(modifiers)
    if not modifiers or modifiers == "" then
        return ""
    end
    
    -- Parse the modifiers and rebuild in correct order: alt-ctrl-shift-meta
    local hasShift = modifiers:lower():find("shift") ~= nil
    local hasCtrl = modifiers:lower():find("ctrl") ~= nil
    local hasAlt = modifiers:lower():find("alt") ~= nil
    local hasMeta = modifiers:lower():find("meta") ~= nil
    
    local result = ""
    if hasAlt then result = result .. "alt-" end
    if hasCtrl then result = result .. "ctrl-" end
    if hasShift then result = result .. "shift-" end
    if hasMeta then result = result .. "meta-" end
    
    return result
end

-- Build a WoW binding key for SetOverrideBindingClick
-- Format: "ALT-CTRL-SHIFT-META-KEY" (same order)
local function BuildMouseBindingKey(modifiers, button)
    local buttonMap = {
        LeftButton = "BUTTON1",
        RightButton = "BUTTON2",
        MiddleButton = "BUTTON3",
    }
    -- Handle Button4-Button31 dynamically
    local buttonKey = buttonMap[button]
    if not buttonKey then
        local num = button:match("Button(%d+)")
        if num then
            buttonKey = "BUTTON" .. num
        else
            buttonKey = "BUTTON1"
        end
    end
    
    if not modifiers or modifiers == "" then
        return buttonKey
    end
    
    -- Parse modifiers
    local hasShift = modifiers:lower():find("shift") ~= nil
    local hasCtrl = modifiers:lower():find("ctrl") ~= nil
    local hasAlt = modifiers:lower():find("alt") ~= nil
    local hasMeta = modifiers:lower():find("meta") ~= nil
    
    -- Build in order: ALT-CTRL-SHIFT-META-KEY
    local parts = {}
    if hasAlt then table.insert(parts, "ALT") end
    if hasCtrl then table.insert(parts, "CTRL") end
    if hasShift then table.insert(parts, "SHIFT") end
    if hasMeta then table.insert(parts, "META") end
    table.insert(parts, buttonKey)
    
    return table.concat(parts, "-")
end

-- Get the button attribute name (e.g., "shift-ctrl-type1" for shift+ctrl+left click)
local function GetButtonNumber(button)
    if not button then return 1 end
    local buttonMap = {
        LeftButton = 1,
        RightButton = 2,
        MiddleButton = 3,
    }
    -- Handle Button4-Button31 dynamically
    local num = buttonMap[button]
    if not num then
        num = button:match("Button(%d+)")
        if num then
            num = tonumber(num)
        else
            num = 1
        end
    end
    return num
end

-- Export helper functions to CC table for use by other modules
CC.GetCombatCondition = GetCombatCondition
CC.HasCombatRestriction = HasCombatRestriction
CC.BuildModifierPrefix = BuildModifierPrefix
CC.BuildMouseBindingKey = BuildMouseBindingKey
CC.GetButtonNumber = GetButtonNumber

-- ============================================================
-- PROFILE SYSTEM
-- ============================================================

-- Get the player's class (used as key for profile storage)
local function GetPlayerClass()
    local _, class = UnitClass("player")
    return class
end
CC.GetPlayerClass = GetPlayerClass

-- Get current spec index
local function GetCurrentSpec()
    return GetSpecialization() or 1
end

-- Get current talent loadout config ID
local function GetCurrentLoadoutConfigID()
    -- Try GetLastSelectedSavedConfigID first - this is the saved loadout that was selected
    if C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID then
        local specIndex = GetSpecialization()
        if specIndex then
            local specID = GetSpecializationInfo(specIndex)
            if specID then
                local savedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
                if savedConfigID and savedConfigID > 0 then
                    -- print("[DF Debug] GetCurrentLoadoutConfigID using LastSelectedSavedConfigID:", savedConfigID)
                    return savedConfigID
                end
            end
        end
    end
    
    -- Fallback to GetActiveConfigID
    if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local activeID = C_ClassTalents.GetActiveConfigID() or 0
        -- print("[DF Debug] GetCurrentLoadoutConfigID using GetActiveConfigID:", activeID)
        return activeID
    end
    return 0
end

-- Get loadout name from config ID
local function GetLoadoutName(configID)
    if not configID or configID <= 0 then
        return nil
    end
    
    -- First try: look up from spec's loadout list (most reliable for saved loadouts)
    if C_ClassTalents and C_ClassTalents.GetConfigIDsBySpecID then
        local specIndex = GetSpecialization()
        if specIndex then
            local specID = GetSpecializationInfo(specIndex)
            if specID then
                local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
                if configIDs then
                    for _, cid in ipairs(configIDs) do
                        if cid == configID then
                            local info = C_Traits and C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(configID)
                            if info and info.name and info.name ~= "" then
                                return info.name
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Second try: direct lookup via C_Traits.GetConfigInfo
    if C_Traits and C_Traits.GetConfigInfo then
        local configInfo = C_Traits.GetConfigInfo(configID)
        if configInfo and configInfo.name and configInfo.name ~= "" then
            return configInfo.name
        end
    end
    
    -- Fallback: use short hash of the ID
    return "Loadout " .. (configID % 10000)
end

-- Export profile helper functions
CC.GetCurrentSpec = GetCurrentSpec
CC.GetCurrentLoadoutConfigID = GetCurrentLoadoutConfigID
CC.GetLoadoutName = GetLoadoutName

-- Get spec name from spec index
local function GetSpecName(specIndex)
    if not specIndex then return "Unknown" end
    local _, name = GetSpecializationInfo(specIndex)
    return name or "Unknown"
end

-- Create a new empty profile based on template
function CC:CreateEmptyProfile()
    return CopyTable(PROFILE_TEMPLATE)
end

-- Create a profile by copying an existing one
function CC:CopyProfile(sourceProfile)
    if not sourceProfile then
        return self:CreateEmptyProfile()
    end
    return CopyTable(sourceProfile)
end

-- Get the class data structure, creating if needed
function CC:GetClassData()
    local class = GetPlayerClass()
    if not self.db.classes then
        self.db.classes = {}
    end
    if not self.db.classes[class] then
        self.db.classes[class] = {
            profiles = {},
            loadoutAssignments = {},
            activeProfile = GetDefaultProfileName(),
        }
    end
    return self.db.classes[class]
end

-- Get list of all profile names for current class
function CC:GetProfileList()
    local classData = self:GetClassData()
    local names = {}
    for name, _ in pairs(classData.profiles) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Get the currently active profile data
function CC:GetActiveProfile()
    local classData = self:GetClassData()
    local defaultName = GetDefaultProfileName()
    local profileName = classData.activeProfile or defaultName
    
    -- Ensure the profile exists
    if not classData.profiles[profileName] then
        classData.profiles[profileName] = self:CreateEmptyProfile()
    end
    
    return classData.profiles[profileName], profileName
end

-- Get the active profile name
function CC:GetActiveProfileName()
    local classData = self:GetClassData()
    return classData.activeProfile or GetDefaultProfileName()
end

-- Set the active profile by name (does NOT apply bindings - call ApplyBindings after)
function CC:SetActiveProfile(profileName)
    if InCombatLockdown() then
        -- Queue the switch for after combat
        self.pendingProfileSwitch = profileName
        print("|cffff9900DandersFrames:|r Profile switch to '" .. profileName .. "' queued (in combat)")
        return false
    end
    
    local classData = self:GetClassData()
    
    -- Check profile exists
    if not classData.profiles[profileName] then
        print("|cffff0000DandersFrames:|r Profile '" .. profileName .. "' does not exist")
        return false
    end
    
    local oldProfile = classData.activeProfile
    classData.activeProfile = profileName
    
    -- Update self.profile reference
    self.profile = classData.profiles[profileName]
    
    -- Also update legacy self.db references for compatibility
    self.db.bindings = self.profile.bindings
    self.db.customMacros = self.profile.customMacros
    self.db.options = self.profile.options
    local wasEnabled = self.db.enabled
    self.db.enabled = self.profile.options.enabled

    -- If this switch flipped click-casting from disabled to enabled and a
    -- conflicting addon (Clique / Clicked) is loaded, surface the conflict
    -- popup the same way login does. ShowClickCastConflictPopup respects
    -- the ignoreConflictWarning opt-out internally.
    if not wasEnabled and self.db.enabled then
        self:CheckForConflictingAddons()
        if self.hasConflictingAddons and self.conflictingAddons then
            C_Timer.After(0.1, function()
                if CC.db.enabled and CC.hasConflictingAddons then
                    CC:ShowClickCastConflictPopup(CC.conflictingAddons, CC.enableCb)
                end
            end)
        end
    end

    if oldProfile ~= profileName then
        print("|cff33cc33DandersFrames:|r Switched to profile: " .. profileName)
    end

    return true
end

-- Create a new profile
function CC:CreateProfile(profileName, copyFrom)
    local classData = self:GetClassData()
    
    if classData.profiles[profileName] then
        print("|cffff0000DandersFrames:|r Profile '" .. profileName .. "' already exists")
        return false
    end
    
    if copyFrom and classData.profiles[copyFrom] then
        classData.profiles[profileName] = self:CopyProfile(classData.profiles[copyFrom])
    else
        classData.profiles[profileName] = self:CreateEmptyProfile()
    end
    
    print("|cff33cc33DandersFrames:|r Created profile: " .. profileName)
    return true
end

-- Delete a profile
function CC:DeleteProfile(profileName)
    local classData = self:GetClassData()
    local defaultName = GetDefaultProfileName()
    
    -- Cannot delete the default profile (check both old and new naming)
    if profileName == defaultName or profileName == "Default" then
        print("|cffff0000DandersFrames:|r Cannot delete the default profile")
        return false
    end
    
    if not classData.profiles[profileName] then
        print("|cffff0000DandersFrames:|r Profile '" .. profileName .. "' does not exist")
        return false
    end
    
    -- If deleting the active profile, switch to Default first
    if classData.activeProfile == profileName then
        self:SetActiveProfile(defaultName)
        self:ApplyBindings()
    end
    
    -- Remove from loadout assignments
    for specIndex, loadouts in pairs(classData.loadoutAssignments) do
        for loadoutID, assignedProfile in pairs(loadouts) do
            if assignedProfile == profileName then
                loadouts[loadoutID] = nil
            end
        end
    end
    
    classData.profiles[profileName] = nil
    print("|cff33cc33DandersFrames:|r Deleted profile: " .. profileName)
    return true
end

-- Rename a profile
function CC:RenameProfile(oldName, newName)
    local classData = self:GetClassData()
    local defaultName = GetDefaultProfileName()
    
    -- Cannot rename the default profile (check both old and new naming)
    if oldName == defaultName or oldName == "Default" then
        print("|cffff0000DandersFrames:|r Cannot rename the default profile")
        return false
    end
    
    if not classData.profiles[oldName] then
        print("|cffff0000DandersFrames:|r Profile '" .. oldName .. "' does not exist")
        return false
    end
    
    if classData.profiles[newName] then
        print("|cffff0000DandersFrames:|r Profile '" .. newName .. "' already exists")
        return false
    end
    
    -- Copy profile data to new name
    classData.profiles[newName] = classData.profiles[oldName]
    classData.profiles[oldName] = nil
    
    -- Update active profile if needed
    if classData.activeProfile == oldName then
        classData.activeProfile = newName
    end
    
    -- Update loadout assignments
    for specIndex, loadouts in pairs(classData.loadoutAssignments) do
        for loadoutID, assignedProfile in pairs(loadouts) do
            if assignedProfile == oldName then
                loadouts[loadoutID] = newName
            end
        end
    end
    
    print("|cff33cc33DandersFrames:|r Renamed profile: " .. oldName .. " → " .. newName)
    return true
end

-- Assign a profile to a spec+loadout combination
function CC:AssignProfileToLoadout(specIndex, loadoutConfigID, profileName)
    local classData = self:GetClassData()
    
    if not classData.loadoutAssignments[specIndex] then
        classData.loadoutAssignments[specIndex] = {}
    end
    
    if profileName then
        classData.loadoutAssignments[specIndex][loadoutConfigID] = profileName
    else
        classData.loadoutAssignments[specIndex][loadoutConfigID] = nil
    end
end

-- Get the profile assigned to a spec+loadout
function CC:GetProfileForLoadout(specIndex, loadoutConfigID, noFallback)
    local classData = self:GetClassData()
    
    if classData.loadoutAssignments[specIndex] then
        -- First check specific loadout
        if classData.loadoutAssignments[specIndex][loadoutConfigID] then
            return classData.loadoutAssignments[specIndex][loadoutConfigID], true  -- second return = is specific assignment
        end
        -- Then check default for spec (configID = 0) unless noFallback is true
        if not noFallback and classData.loadoutAssignments[specIndex][0] then
            return classData.loadoutAssignments[specIndex][0], false  -- second return = is fallback
        end
    end
    
    return nil, false
end

-- Check if a loadout has a specific (non-fallback) profile assignment
function CC:HasSpecificLoadoutAssignment(specIndex, loadoutConfigID)
    local classData = self:GetClassData()
    if classData.loadoutAssignments[specIndex] then
        return classData.loadoutAssignments[specIndex][loadoutConfigID] ~= nil
    end
    return false
end

-- Check and auto-switch profile based on current loadout
function CC:CheckLoadoutProfileSwitch()
    if InCombatLockdown() then
        -- Will be called again when combat ends
        return
    end
    
    local specIndex = GetCurrentSpec()
    local loadoutID = GetCurrentLoadoutConfigID()
    local assignedProfile, isSpecific = self:GetProfileForLoadout(specIndex, loadoutID)
    local currentProfile = self:GetActiveProfileName()
    local loadoutName = GetLoadoutName(loadoutID) or "Default"
    
    -- Debug output (use /dfccloadout to see this info manually)
    -- print("|cff888888[DF Loadout] Spec:", specIndex, "LoadoutID:", loadoutID, "LoadoutName:", loadoutName, "Assigned:", assignedProfile or "none", "IsSpecific:", tostring(isSpecific), "Current:", currentProfile, "|r")
    
    if assignedProfile and assignedProfile ~= currentProfile then
        -- Profile is assigned (either to this specific loadout or as spec default) - switch to it
        if self:SetActiveProfile(assignedProfile) then
            self:ApplyBindings()
            self:RefreshClickCastingUI()
            local source = isSpecific and "loadout: " .. loadoutName or "spec default"
            print("|cff33cc33DandersFrames:|r Switched to profile: " .. assignedProfile .. " (" .. source .. ")")
        end
    elseif not assignedProfile and loadoutID > 0 then
        -- No profile assigned to this loadout or spec at all
        -- Check if auto-creation is enabled
        local autoCreate = self.db and self.db.global and self.db.global.autoCreateProfiles
        if autoCreate == nil then autoCreate = true end  -- Default to true
        
        if not autoCreate then
            -- Auto-creation disabled - don't create a new profile
            return
        end
        
        -- Auto-create a profile for this loadout
        local specName = GetSpecName(specIndex)
        local newProfileName = loadoutName and (specName .. " - " .. loadoutName) or specName
        
        -- Ensure unique name
        local classData = self:GetClassData()
        local baseName = newProfileName
        local counter = 1
        while classData.profiles[newProfileName] do
            counter = counter + 1
            newProfileName = baseName .. " " .. counter
        end
        
        -- Create new profile copying current bindings
        if self:CreateProfile(newProfileName, currentProfile) then
            -- Assign it to this loadout
            self:AssignProfileToLoadout(specIndex, loadoutID, newProfileName)
            -- Switch to it
            if self:SetActiveProfile(newProfileName) then
                self:ApplyBindings()
                self:RefreshClickCastingUI()
            end
            
            -- Show notification
            self:ShowProfileCreatedNotification(newProfileName)
        end
    end
end

-- Show notification that a profile was auto-created
function CC:ShowProfileCreatedNotification(profileName)
    -- Simple print for now - could be a fancy toast later
    print("|cff33cc33DandersFrames:|r Auto-created profile: |cffffffff" .. profileName .. "|r")
    print("|cff888888Your bindings were copied to this new profile. You can customize it in the Profiles tab.|r")
end

-- Get all loadouts for a spec (for UI display)
function CC:GetSpecLoadouts(specIndex)
    local loadouts = {}
    
    if C_ClassTalents and C_ClassTalents.GetConfigIDsBySpecID then
        local specID = GetSpecializationInfo(specIndex)
        if specID then
            local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
            if configIDs then
                for _, configID in ipairs(configIDs) do
                    -- Use C_Traits.GetConfigInfo instead of C_ClassTalents.GetConfigInfo
                    local configInfo = C_Traits and C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(configID)
                    local loadoutName = "Loadout " .. configID
                    if configInfo then
                        loadoutName = configInfo.name or loadoutName
                        -- print("[DF Debug] GetSpecLoadouts configID:", configID, "name:", configInfo.name or "nil")
                    end
                    table.insert(loadouts, {
                        configID = configID,
                        name = loadoutName,
                    })
                end
            end
        end
    end
    
    return loadouts
end

-- Get number of specs for current class
function CC:GetNumSpecs()
    return GetNumSpecializations() or 4
end

-- ============================================================
-- PROFILE IMPORT/EXPORT
-- ============================================================

-- Simple base64-ish encoding for export (uses AceSerializer + LibDeflate)
-- Serialization using LibSerialize + LibDeflate (same as profile export)
local function SerializeTable(tbl)
    if not tbl then
        return nil, "No data to serialize"
    end
    
    local LibSerialize = LibStub and LibStub("LibSerialize", true)
    local LibDeflate = LibStub and LibStub("LibDeflate", true)
    
    if not LibSerialize or not LibDeflate then
        return nil, "Missing required libraries"
    end
    
    local serialized = LibSerialize:Serialize(tbl)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    
    return encoded
end

-- Deserialize a string back to a table (accessible from other files via CC:DeserializeString)
function CC:DeserializeString(encoded)
    if not encoded or encoded == "" then
        return nil
    end
    
    local LibSerialize = LibStub and LibStub("LibSerialize", true)
    local LibDeflate = LibStub and LibStub("LibDeflate", true)
    
    if not LibSerialize or not LibDeflate then
        return nil
    end
    
    local compressed = LibDeflate:DecodeForPrint(encoded)
    if not compressed then
        return nil
    end
    
    local serialized = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil
    end
    
    local success, result = LibSerialize:Deserialize(serialized)
    if success and result then
        return result
    end
    
    return nil
end

-- Legacy deserialize for old formats (accessible from other files via CC:DeserializeStringLegacy)
function CC:DeserializeStringLegacy(encoded)
    if not encoded or encoded == "" then
        return nil
    end
    
    -- Try AceSerializer + LibDeflate (old format)
    local AceSerializer = LibStub and LibStub("AceSerializer-3.0", true)
    local LibDeflate = LibStub and LibStub("LibDeflate", true)
    
    if AceSerializer and LibDeflate then
        local decoded = LibDeflate:DecodeForPrint(encoded)
        if decoded then
            local decompressed = LibDeflate:DecompressDeflate(decoded)
            if decompressed then
                local success, result = AceSerializer:Deserialize(decompressed)
                if success and result then
                    return result
                end
            end
        end
    end
    
    -- Check if it looks like hex
    local isHex = #encoded % 2 == 0 and not string.find(encoded, "[^0-9A-Fa-f]")
    
    local luaStr
    if isHex then
        local parts = {}
        for i = 1, #encoded, 2 do
            local hex = string.sub(encoded, i, i + 1)
            local num = tonumber(hex, 16)
            if num then
                parts[#parts + 1] = string.char(num)
            else
                return nil
            end
        end
        if #parts > 0 then
            luaStr = table.concat(parts)
        end
    else
        luaStr = encoded
    end
    
    if not luaStr then
        return nil
    end
    
    local func = loadstring("return " .. luaStr)
    if not func then
        return nil
    end
    
    if setfenv then
        pcall(setfenv, func, {})
    end
    
    local success, result = pcall(func)
    if success and type(result) == "table" then
        return result
    end
    
    return nil
end

-- Export current profile to string
function CC:ExportProfile()
    local profile, profileName = self:GetActiveProfile()
    
    if not profile then
        print("|cffff0000DandersFrames:|r No profile to export")
        return nil
    end
    
    local exportData = {
        version = DB_VERSION,
        profileName = profileName,
        profile = CopyTable(profile),
        exportedAt = date("%Y-%m-%d %H:%M"),
        class = GetPlayerClass(),
    }
    
    local encoded, err = SerializeTable(exportData)
    if not encoded or encoded == "" then
        print("|cffff0000DandersFrames:|r Export failed: " .. (err or "unknown error"))
        return nil
    end
    
    return "!DFC1!" .. encoded  -- DFC1 = DandersFrames ClickCasting v1
end

-- Check if a spell is known/learnable by the current class
-- Returns: "valid_spec" (known/usable now), "valid_class" (class spell, not current spec), "invalid" (not available)
-- Accessible from other files via CC:GetSpellValidityStatus()
function CC:GetSpellValidityStatus(spellName)
    if not spellName or spellName == "" then return "invalid" end
    
    -- Try to get spell info - if the spell doesn't exist at all, it's invalid
    local spellInfo = C_Spell.GetSpellInfo(spellName)
    if not spellInfo then return "invalid" end
    
    local spellId = spellInfo.spellID
    if not spellId then return "invalid" end
    
    local bookType = Enum.SpellBookSpellBank.Player
    
    -- Check if currently known using IsSpellInSpellBook with includeOverrides=true
    -- This properly handles hero talent override spells (like Chrono Flames)
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        if C_SpellBook.IsSpellInSpellBook(spellId, bookType, true) then
            return "valid_spec"
        end
    end
    
    -- Check if spell is usable (handles talent spells that might not be "known" yet)
    local usable = IsUsableSpell and IsUsableSpell(spellName)
    if usable then
        return "valid_spec"
    end
    
    -- Check if this spell exists in the player's spellbook at any level
    if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
        for _, bank in ipairs({Enum.SpellBookSpellBank.Player, Enum.SpellBookSpellBank.Pet}) do
            local numSpells = C_SpellBook.GetNumSpellBookItems(bank) or 0
            for i = 1, numSpells do
                local info = C_SpellBook.GetSpellBookItemInfo(i, bank)
                if info and info.name == spellName then
                    return "valid_spec"
                end
            end
        end
    end
    
    -- Check if it's a talent spell for current class (but maybe different spec)
    -- If spellInfo exists and has a spellID, it's likely a valid WoW spell
    -- We can check if it's a class talent by looking at all specs
    if C_ClassTalents then
        local currentSpec = GetSpecialization() or 1
        local numSpecs = GetNumSpecializations() or 4
        
        for specIndex = 1, numSpecs do
            local specID = GetSpecializationInfo(specIndex)
            if specID then
                -- Check class and spec talent trees
                local configID = C_ClassTalents.GetActiveConfigID()
                if configID then
                    local configInfo = C_Traits.GetConfigInfo(configID)
                    if configInfo then
                        for _, treeID in ipairs(configInfo.treeIDs or {}) do
                            local nodes = C_Traits.GetTreeNodes(treeID)
                            if nodes then
                                for _, nodeID in ipairs(nodes) do
                                    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
                                    if nodeInfo and nodeInfo.entryIDs then
                                        for _, entryID in ipairs(nodeInfo.entryIDs) do
                                            local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                                            if entryInfo and entryInfo.definitionID then
                                                local defInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                                                if defInfo and defInfo.spellID == spellId then
                                                    if specIndex == currentSpec then
                                                        return "valid_spec"
                                                    else
                                                        return "valid_class"
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return "invalid"
end

-- Legacy function for compatibility
local function IsSpellValidForCurrentClass(spellName)
    local status = CC:GetSpellValidityStatus(spellName)
    return status == "valid_spec" or status == "valid_class"
end

-- ============================================================
