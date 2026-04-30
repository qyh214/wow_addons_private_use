local addonName, DF = ...

local format = string.format

-- ============================================================
-- HELPER: DEEP COPY TABLE
-- ============================================================

function DF:DeepCopy(src)
    if type(src) ~= "table" then return src end
    -- Unwrap proxy tables to their real backing store
    local mt = getmetatable(src)
    if mt then
        if mt.__isDBProxy then src = DF._realProfile end
        if mt.__realTable then src = mt.__realTable end
    end
    local dest = {}
    for k, v in pairs(src) do
        dest[k] = DF:DeepCopy(v)
    end
    return dest
end

-- ============================================================
-- PROFILE MANAGEMENT
-- ============================================================

-- Resets Party or Raid settings within the CURRENT profile
function DF:ResetProfile(mode)
    local L = DF.L
    if not DF.db or not DF.db[mode] then return end
    local defaults = (mode == "party" and DF.PartyDefaults or DF.RaidDefaults)
    DF.db[mode] = DF:DeepCopy(defaults)
    DF:FullProfileRefresh()
    local modeLabel = mode == "party" and "Party" or "Raid"
    print("|cff00ff00DandersFrames:|r " .. format(L["%s settings reset to defaults."], modeLabel))
end

-- Copies Party->Raid or Raid->Party within CURRENT profile
function DF:CopyProfile(srcMode, destMode)
    local L = DF.L
    if not DF.db or not DF.db[srcMode] or not DF.db[destMode] then return end
    DF.db[destMode] = DF:DeepCopy(DF.db[srcMode])
    DF:FullProfileRefresh()
    local s = srcMode == "party" and "Party" or "Raid"
    local d = destMode == "party" and "Party" or "Raid"
    print("|cff00ff00DandersFrames:|r " .. format(L["Copied settings from %s to %s."], s, d))
end

-- Copies matching settings between Party and Raid (no refresh, no print)
-- Used by SyncLinkedSections for automatic background syncing
function DF:CopySectionSettingsRaw(prefixes, srcMode)
    if not DF.db then return end
    srcMode = srcMode or "party"
    local destMode = srcMode == "party" and "raid" or "party"
    if not DF.db[srcMode] or not DF.db[destMode] then return end

    -- Unwrap proxy for iteration (Lua 5.1 has no __pairs)
    local src = DF.db[srcMode]
    local mt = getmetatable(src)
    if mt and mt.__realTable then src = mt.__realTable end

    for key, value in pairs(src) do
        for _, prefix in ipairs(prefixes) do
            if key:sub(1, #prefix) == prefix then
                if type(value) == "table" then
                    DF.db[destMode][key] = DF:DeepCopy(value)
                else
                    DF.db[destMode][key] = value
                end
                break
            end
        end
    end
end

-- Copies a specific section of settings between Party and Raid modes
-- prefixes: table of string prefixes to match, e.g. {"buff", "debuff"}
-- srcMode: optional, the source mode ("party" or "raid"). If not provided, defaults to "party"
-- Returns: srcMode, destMode (for UI feedback)
function DF:CopySectionSettings(prefixes, srcMode)
    if not DF.db then return end
    
    -- Determine current mode and destination
    srcMode = srcMode or "party"
    local destMode = srcMode == "party" and "raid" or "party"
    
    if not DF.db[srcMode] or not DF.db[destMode] then return end

    -- Unwrap proxy for iteration (Lua 5.1 has no __pairs)
    local src = DF.db[srcMode]
    local mt = getmetatable(src)
    if mt and mt.__realTable then src = mt.__realTable end

    local count = 0
    for key, value in pairs(src) do
        for _, prefix in ipairs(prefixes) do
            if key:sub(1, #prefix) == prefix then
                -- Deep copy if table, otherwise direct assign
                if type(value) == "table" then
                    DF.db[destMode][key] = DF:DeepCopy(value)
                else
                    DF.db[destMode][key] = value
                end
                count = count + 1
                break
            end
        end
    end

    -- Full refresh - these buttons aren't used often so a complete refresh is fine
    DF:FullProfileRefresh()

    local L = DF.L
    local s = srcMode == "party" and "Party" or "Raid"
    local d = destMode == "party" and "Party" or "Raid"
    print("|cff00ff00DandersFrames:|r " .. format(L["Copied %d settings from %s to %s."], count, s, d))

    return srcMode, destMode
end

-- ============================================================
-- PROFILE LIST MANAGEMENT
-- ============================================================

-- Get list of all profile names
function DF:GetProfiles()
    local profiles = {"Default"}
    if DandersFramesDB_v2 and DandersFramesDB_v2.profiles then
        for name, _ in pairs(DandersFramesDB_v2.profiles) do
            if name ~= "Default" then
                table.insert(profiles, name)
            end
        end
    end
    table.sort(profiles, function(a, b)
        if a == "Default" then return true end
        if b == "Default" then return false end
        return a < b
    end)
    return profiles
end

-- Get current profile name
function DF:GetCurrentProfile()
    return DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile or "Default"
end

-- Save the current profile to the profiles table.
-- DeepCopy unwraps the overlay proxy, so saved data is always clean.
function DF:SaveCurrentProfile()
    if not DF.db then return end
    local currentName = DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile or "Default"
    if not DandersFramesDB_v2 or not DandersFramesDB_v2.profiles then return end

    DandersFramesDB_v2.profiles[currentName] = DF:DeepCopy(DF.db)
end

-- Set/create a profile
function DF:SetProfile(name)
    local L = DF.L
    if not name or name == "" then return end

    -- Initialize profiles table if needed
    if not DandersFramesDB_v2 then DandersFramesDB_v2 = {} end
    if not DandersFramesDB_v2.profiles then DandersFramesDB_v2.profiles = {} end

    -- Save current profile before switching (strips runtime overrides)
    DF:SaveCurrentProfile()

    -- Clear auto-profile runtime state and overlay BEFORE switching profiles
    -- so FullProfileRefresh reads the clean new profile with no stale overlay
    if DF.AutoProfilesUI then
        DF.AutoProfilesUI.activeRuntimeProfile = nil
        DF.AutoProfilesUI.activeRuntimeContentKey = nil
        DF.AutoProfilesUI.pendingAutoProfileEval = false
    end
    DF.raidOverrides = nil
    DF:Debug("PROFILE", "SetProfile: cleared runtime state before switching to " .. name)

    -- Create new profile if doesn't exist
    if not DandersFramesDB_v2.profiles[name] then
        DandersFramesDB_v2.profiles[name] = {
            party = DF:DeepCopy(DF.PartyDefaults),
            raid = DF:DeepCopy(DF.RaidDefaults),
            raidAutoProfiles = DF:DeepCopy(DF.RaidAutoProfilesDefaults),
            classColors = {},
            powerColors = {},
            linkedSections = {},
            partyEnabled = true,
            raidEnabled = true,
            settingsFont = "Friz Quadrata TT",
            settingsFontOutline = "",
        }
        print("|cff00ff00DandersFrames:|r " .. format(L["Created new profile: %s"], name))
    end

    -- Backfill defaults on older profiles
    local p = DandersFramesDB_v2.profiles[name]
    if p.partyEnabled        == nil then p.partyEnabled        = true end
    if p.raidEnabled         == nil then p.raidEnabled         = true end
    if p.settingsFont        == nil then p.settingsFont        = "Friz Quadrata TT" end
    if p.settingsFontOutline == nil then p.settingsFontOutline = "" end

    -- Switch to the profile (update both account-wide and per-character)
    DandersFramesDB_v2.currentProfile = name
    if DandersFramesCharDB then
        DandersFramesCharDB.currentProfile = name
    end
    DF.db = DandersFramesDB_v2.profiles[name]
    DF:WrapDB()

    -- Apply the profile — runtime state is already clear so the proxy reads
    -- the new profile directly with no stale overlay
    DF:FullProfileRefresh()

    print("|cff00ff00DandersFrames:|r " .. format(L["Switched to profile: %s"], name))

    -- If the new profile has a different enable-flag state, prompt to reload
    -- so headers can be (re)created. Frames cannot be added/removed at runtime.
    if DF.PromptReloadIfEnableFlagsChanged then
        DF:PromptReloadIfEnableFlagsChanged()
    end

    -- Re-evaluate auto-profiles for the new profile after a short delay
    -- to allow secure frame operations to settle
    C_Timer.After(0.1, function()
        if DF.AutoProfilesUI then
            DF.AutoProfilesUI:EvaluateAndApply()
        end
    end)
end

-- Delete a profile
function DF:DeleteProfile(name)
    local L = DF.L
    if name == "Default" then
        print("|cffff6666DandersFrames:|r " .. L["Cannot delete Default profile."])
        return
    end

    if DandersFramesDB_v2 and DandersFramesDB_v2.profiles and DandersFramesDB_v2.profiles[name] then
        DandersFramesDB_v2.profiles[name] = nil
        print("|cff00ff00DandersFrames:|r " .. format(L["Deleted profile: %s"], name))
    end
end

-- Duplicate current profile to a new name
function DF:DuplicateProfile(newName)
    local L = DF.L
    if not newName or newName == "" then
        print("|cffff6666DandersFrames:|r " .. L["Please enter a profile name."])
        return false
    end

    local currentName = DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile or "Default"

    -- Initialize profiles table if needed
    if not DandersFramesDB_v2 then DandersFramesDB_v2 = {} end
    if not DandersFramesDB_v2.profiles then DandersFramesDB_v2.profiles = {} end

    -- Check if profile already exists
    if DandersFramesDB_v2.profiles[newName] then
        print("|cffff6666DandersFrames:|r " .. format(L["Profile '%s' already exists."], newName))
        return false
    end
    
    -- Save current profile before switching
    DF:SaveCurrentProfile()

    -- Create new profile as a clean copy of current (DeepCopy unwraps proxies)
    DandersFramesDB_v2.profiles[newName] = DF:DeepCopy(DF.db)

    -- Switch to the new profile
    DandersFramesDB_v2.currentProfile = newName
    if DandersFramesCharDB then
        DandersFramesCharDB.currentProfile = newName
    end
    DF.db = DandersFramesDB_v2.profiles[newName]
    DF:WrapDB()

    -- Apply the profile with full refresh
    DF:FullProfileRefresh()
    
    print("|cff00ff00DandersFrames:|r " .. format(L["Duplicated profile '%s' to '%s'."], currentName, newName))
    return true
end

-- ============================================================
-- BASE64 ENCODING/DECODING
-- ============================================================

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function DF:Base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function DF:Base64Decode(data)
    data = string.gsub(data, '[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='', (b64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- ============================================================
-- SERIALIZATION
-- ============================================================

function DF:Serialize(val)
    local t = type(val)
    if t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "string" then
        return string.format("%q", val)
    elseif t == "table" then
        local str = "{"
        for k, v in pairs(val) do
            str = str .. "[" .. DF:Serialize(k) .. "]=" .. DF:Serialize(v) .. ","
        end
        return str .. "}"
    else
        return "nil"
    end
end

-- ============================================================
-- IMPORT / EXPORT (Using LibSerialize + LibDeflate like modern addons)
-- ============================================================

-- Export profile with optional category filtering
function DF:ExportProfile(categories, frameTypes, profileName)
    local L = DF.L
    local LibSerialize = LibStub and LibStub("LibSerialize", true)
    local LibDeflate = LibStub and LibStub("LibDeflate", true)

    if not LibSerialize or not LibDeflate then
        print("|cffff0000DandersFrames:|r Missing required libraries")
        return nil
    end
    
    frameTypes = frameTypes or {party = true, raid = true}
    
    -- Get profile name
    local exportProfileName = profileName
    if not exportProfileName then
        if DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile then
            exportProfileName = DandersFramesDB_v2.currentProfile
        else
            exportProfileName = "Exported Profile"
        end
    end
    
    -- Build export data
    local exportData = {
        version = DF.VERSION,
        exportTime = time(),
        profileName = exportProfileName,
        exportedBy = UnitName("player") or "Unknown",
    }
    
    if not DF.db then
        print("|cffff0000DandersFrames:|r No database")
        return nil
    end
    
    -- If no categories specified, export everything
    if not categories or #categories == 0 then
        if frameTypes.party and DF.db.party then
            exportData.party = DF:DeepCopy(DF.db.party)
        end
        if frameTypes.raid and DF.db.raid then
            exportData.raid = DF:DeepCopy(DF.db.raid)
        end
        -- Include class color overrides
        if DF.db.classColors and next(DF.db.classColors) then
            exportData.classColors = DF:DeepCopy(DF.db.classColors)
        end
        -- Include power color overrides
        if DF.db.powerColors and next(DF.db.powerColors) then
            exportData.powerColors = DF:DeepCopy(DF.db.powerColors)
        end
        -- Include auto layout profiles
        if DF.db.raidAutoProfiles then
            exportData.raidAutoProfiles = DF:DeepCopy(DF.db.raidAutoProfiles)
        end
        -- Include aura blacklist
        if DF.db.auraBlacklist then
            exportData.auraBlacklist = DF:DeepCopy(DF.db.auraBlacklist)
        end
        exportData.categories = nil
    else
        -- Selective category export
        exportData.categories = categories
        if frameTypes.party and DF.db.party then
            exportData.party = self:ExtractCategorySettings(DF.db.party, categories)
        end
        if frameTypes.raid and DF.db.raid then
            exportData.raid = self:ExtractCategorySettings(DF.db.raid, categories)
        end
        -- Auto layouts: top-level key, needs special handling
        local categorySet = {}
        for _, cat in ipairs(categories) do categorySet[cat] = true end
        if categorySet.autoLayout and DF.db.raidAutoProfiles then
            exportData.raidAutoProfiles = DF:DeepCopy(DF.db.raidAutoProfiles)
        end
        -- Aura blacklist: top-level key, include with auras category
        if categorySet.auras and DF.db.auraBlacklist then
            exportData.auraBlacklist = DF:DeepCopy(DF.db.auraBlacklist)
        end
    end

    if not exportData.party and not exportData.raid then
        print("|cffff0000DandersFrames:|r " .. L["No data to export"])
        return nil
    end
    
    exportData.frameTypes = {}
    if exportData.party then exportData.frameTypes.party = true end
    if exportData.raid then exportData.frameTypes.raid = true end
    
    -- Serialize -> Compress -> Encode (same as WeakAuras, Cell, etc.)
    local serialized = LibSerialize:Serialize(exportData)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    
    return "!DFP1!" .. encoded  -- DFP1 = DandersFrames Profile v1
end

-- Validate an import string and return the parsed data if valid
function DF:ValidateImportString(str)
    local LibSerialize = LibStub and LibStub("LibSerialize", true)
    local LibDeflate = LibStub and LibStub("LibDeflate", true)
    
    if not str or str == "" then 
        return nil, "Empty string"
    end
    
    -- Check for our format (starts with !DFP1!)
    if string.sub(str, 1, 6) == "!DFP1!" then
        if not LibSerialize or not LibDeflate then
            return nil, "Missing required libraries"
        end
        
        local encoded = string.sub(str, 7)
        
        -- Decode -> Decompress -> Deserialize
        local compressed = LibDeflate:DecodeForPrint(encoded)
        if not compressed then
            return nil, "Invalid encoding"
        end
        
        local serialized = LibDeflate:DecompressDeflate(compressed)
        if not serialized then
            return nil, "Decompression failed"
        end
        
        local success, data = LibSerialize:Deserialize(serialized)
        if not success then
            return nil, "Deserialization failed"
        end
        
        if type(data) ~= "table" or (not data.party and not data.raid) then
            return nil, "No profile data found"
        end
        
        return data, nil
    end
    
    -- Legacy format support (!DF1! - old LibDeflate with DF:Serialize)
    if string.sub(str, 1, 5) == "!DF1!" then
        if not LibDeflate then
            return nil, "Missing LibDeflate"
        end
        
        local encoded = string.sub(str, 6)
        local compressed = LibDeflate:DecodeForPrint(encoded)
        if not compressed then
            return nil, "Invalid encoding"
        end
        
        local decoded = LibDeflate:DecompressDeflate(compressed)
        if not decoded then
            return nil, "Decompression failed"
        end
        
        -- Old format used loadstring
        local func, err = loadstring("return " .. decoded)
        if not func then
            return nil, "Invalid format"
        end
        
        local success, data = pcall(func)
        if not success or type(data) ~= "table" then
            return nil, "Corrupt data"
        end
        
        if not data.party and not data.raid then
            return nil, "No profile data found"
        end
        
        return data, nil
    end
    
    -- Other legacy formats
    if string.sub(str, 1, 5) == "!DF2!" or string.sub(str, 1, 5) == "!DF3!" or string.sub(str, 1, 5) == "DF02:" then
        return nil, "Legacy format - please re-export"
    end
    
    -- Try legacy base64
    local decoded = DF:Base64Decode(str)
    if decoded and decoded ~= "" then
        local func = loadstring("return " .. decoded)
        if func then
            local success, data = pcall(func)
            if success and type(data) == "table" and (data.party or data.raid) then
                return data, nil
            end
        end
    end
    
    return nil, "Invalid format"
end

-- Get version info from validated import data
function DF:GetImportVersion(importData)
    if importData and importData.version then
        return importData.version
    end
    return "Unknown (legacy format)"
end

-- Get info about what's in the import data
function DF:GetImportInfo(importData)
    if not importData then return nil end
    
    local info = {
        version = self:GetImportVersion(importData),
        hasParty = importData.party ~= nil,
        hasRaid = importData.raid ~= nil,
        isFullExport = importData.categories == nil,
        categories = importData.categories or {},
        frameTypes = importData.frameTypes or {},
        profileName = importData.profileName or "Imported Profile",
        exportedBy = importData.exportedBy,
        exportTime = importData.exportTime,
    }
    
    -- Detect categories if not explicitly stored (legacy imports)
    if info.isFullExport then
        -- Full export contains all categories
        info.detectedCategories = {"position", "layout", "bars", "auras", "text", "icons", "other", "pinnedFrames", "auraDesigner", "autoLayout"}
    else
        info.detectedCategories = importData.categories
    end
    
    return info
end

-- Apply imported data with optional category/frame type filtering
-- selectedCategories: table of category names to import, or nil for all in the data
-- selectedFrameTypes: table like {party = true, raid = true}, or nil for all in the data
-- newProfileName: name for the new profile to create (if nil, uses name from import data)
-- createNewProfile: if true, creates a new profile instead of overwriting current
-- allowOverwrite: if true, allow overwriting an existing profile with the same name (used by Wago API)
function DF:ApplyImportedProfile(importData, selectedCategories, selectedFrameTypes, newProfileName, createNewProfile, allowOverwrite)
    local L = DF.L
    if not importData then return false end

    local importInfo = self:GetImportInfo(importData)

    -- Default to all available frame types
    selectedFrameTypes = selectedFrameTypes or {
        party = importInfo.hasParty,
        raid = importInfo.hasRaid,
    }

    -- Handle profile creation
    if createNewProfile then
        local profileName = newProfileName or importInfo.profileName or "Imported Profile"

        -- Ensure unique name unless overwrite is explicitly allowed (e.g. Wago API imports)
        if not allowOverwrite then
            local baseName = profileName
            local counter = 1
            while DandersFramesDB_v2 and DandersFramesDB_v2.profiles and DandersFramesDB_v2.profiles[profileName] do
                counter = counter + 1
                profileName = baseName .. " " .. counter
            end
        end
        
        -- Initialize profiles table if needed
        if not DandersFramesDB_v2 then DandersFramesDB_v2 = {} end
        if not DandersFramesDB_v2.profiles then DandersFramesDB_v2.profiles = {} end
        
        -- Save current profile before switching
        DF:SaveCurrentProfile()

        -- Create new profile as a COPY of current profile (not defaults)
        -- This way, any categories NOT selected for import will keep the user's current settings
        -- DeepCopy unwraps proxies automatically
        DandersFramesDB_v2.profiles[profileName] = {
            party = DF:DeepCopy(DF.db.party or DF.PartyDefaults),
            raid = DF:DeepCopy(DF.db.raid or DF.RaidDefaults),
            raidAutoProfiles = DF:DeepCopy(DF.db.raidAutoProfiles or DF.RaidAutoProfilesDefaults),
            classColors = DF:DeepCopy(DF.db.classColors or {}),
            powerColors = DF:DeepCopy(DF.db.powerColors or {}),
            auraBlacklist = DF:DeepCopy(DF.db.auraBlacklist or { buffs = {}, debuffs = {} }),
            linkedSections = {},
            partyEnabled = DF.db.partyEnabled ~= false,
            raidEnabled  = DF.db.raidEnabled  ~= false,
        }

        -- Switch to the new profile
        DandersFramesDB_v2.currentProfile = profileName
        if DandersFramesCharDB then
            DandersFramesCharDB.currentProfile = profileName
        end
        DF.db = DandersFramesDB_v2.profiles[profileName]
        DF:WrapDB()
        
        print("|cff00ff00DandersFrames:|r " .. format(L["Created new profile: %s"], profileName))
    end

    -- If it's a full export (legacy or "all categories"), use direct replacement
    if importInfo.isFullExport and not selectedCategories then
        -- Legacy behavior: replace entire profile sections
        if importData.party and selectedFrameTypes.party then 
            DF.db.party = importData.party 
        end
        if importData.raid and selectedFrameTypes.raid then 
            DF.db.raid = importData.raid 
        end
        -- Import class color overrides if present
        if importData.classColors then
            DF.db.classColors = importData.classColors
        end
        -- Import power color overrides if present
        if importData.powerColors then
            DF.db.powerColors = importData.powerColors
        end
        -- Import auto layout profiles if present
        if importData.raidAutoProfiles then
            DF.db.raidAutoProfiles = importData.raidAutoProfiles
        end
        -- Import aura blacklist if present
        if importData.auraBlacklist then
            DF.db.auraBlacklist = importData.auraBlacklist
        end
    else
        -- Selective import: merge only selected categories
        local categoriesToImport = selectedCategories or importInfo.detectedCategories
        
        if importData.party and selectedFrameTypes.party then
            self:MergeCategorySettings(DF.db.party, importData.party, categoriesToImport)
        end
        if importData.raid and selectedFrameTypes.raid then
            self:MergeCategorySettings(DF.db.raid, importData.raid, categoriesToImport)
        end
        -- Auto layouts: top-level key, needs special handling
        local importCategorySet = {}
        for _, cat in ipairs(categoriesToImport) do importCategorySet[cat] = true end
        if importCategorySet.autoLayout and importData.raidAutoProfiles then
            DF.db.raidAutoProfiles = importData.raidAutoProfiles
        end
        -- Aura blacklist: top-level key, import with auras category
        if importCategorySet.auras and importData.auraBlacklist then
            DF.db.auraBlacklist = importData.auraBlacklist
        end
    end
    
    -- Force DIRECT aura source mode — imported profiles may have BLIZZARD
    -- which is no longer supported.
    if DF.db.party then DF.db.party.auraSourceMode = "DIRECT" end
    if DF.db.raid  then DF.db.raid.auraSourceMode  = "DIRECT" end

    DF:FullProfileRefresh()
    print("|cff00ff00DandersFrames:|r " .. L["Profile imported successfully!"])

    -- If the imported state changed which frame modes are enabled, prompt
    -- the user to reload so headers can be (re)created.
    if DF.PromptReloadIfEnableFlagsChanged then
        DF:PromptReloadIfEnableFlagsChanged()
    end

    return true
end

function DF:ImportProfile(str)
    local L = DF.L
    -- Use ValidateImportString which handles both compressed and legacy formats
    local newProfile, errMsg = DF:ValidateImportString(str)
    if not newProfile then
        print("|cffff0000DandersFrames:|r " .. (errMsg or L["Import failed"]))
        return false
    end

    -- Import party and raid settings
    if newProfile.party then
        DF.db.party = newProfile.party
    end
    if newProfile.raid then
        DF.db.raid = newProfile.raid
    end

    -- Force DIRECT aura source mode — imported profiles may have BLIZZARD
    -- which is no longer supported.
    if DF.db.party then DF.db.party.auraSourceMode = "DIRECT" end
    if DF.db.raid  then DF.db.raid.auraSourceMode  = "DIRECT" end

    DF:FullProfileRefresh()
    print("|cff00ff00DandersFrames:|r " .. L["Profile imported successfully!"])

    -- If the imported state changed which frame modes are enabled, prompt
    -- the user to reload so headers can be (re)created.
    if DF.PromptReloadIfEnableFlagsChanged then
        DF:PromptReloadIfEnableFlagsChanged()
    end

    return true
end

-- ============================================================
-- SPEC AUTO-SWITCH (per-character settings)
-- ============================================================

function DF:CheckProfileAutoSwitch()
    -- Use per-character saved variable (DandersFramesCharDB)
    if not DandersFramesCharDB then return end
    if not DandersFramesCharDB.enableSpecSwitch then return end
    
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex then return end
    
    local profileName = DandersFramesCharDB.specProfiles and DandersFramesCharDB.specProfiles[specIndex]
    
    -- If a profile is assigned and it is NOT the current profile
    if profileName and profileName ~= "" and profileName ~= DF:GetCurrentProfile() then
        -- Verify profile exists
        local profiles = DF:GetProfiles()
        local exists = false
        for _, p in ipairs(profiles) do 
            if p == profileName then 
                exists = true 
                break 
            end 
        end
        
        if exists then
            local L = DF.L
            DF:SetProfile(profileName)
            print("|cff00ff00DandersFrames:|r " .. format(L["Auto-switched to profile: %s"], profileName))
            -- Note: SetProfile now calls FullProfileRefresh which handles GUI refresh
        end
    end
end
