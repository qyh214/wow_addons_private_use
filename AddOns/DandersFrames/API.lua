local addonName, DF = ...

-- ============================================================
-- EXTERNAL API
-- Global functions for external addon integration (Wago UI Packs, etc.)
-- ============================================================

-- These functions are exposed globally so other addons can import/export
-- DandersFrames profiles programmatically.

-- ============================================================
-- FRAME SETTINGS (Party + Raid)
-- ============================================================

-- Export both party and raid frame settings as an encoded string
-- Parameters:
--   profileKey: (optional) specific profile to export, defaults to current profile
-- Returns: string (encoded profile) or nil on error
function DandersFrames_Export(profileKey)
    if not DF or not DF.ExportProfile then
        return nil
    end
    
    -- If a specific profile is requested, temporarily use that profile's data
    if profileKey and profileKey ~= "" then
        -- Check if the profile exists
        if not DandersFramesDB_v2 or not DandersFramesDB_v2.profiles or not DandersFramesDB_v2.profiles[profileKey] then
            return nil  -- Profile doesn't exist
        end
        
        -- Save current db reference
        local originalDB = DF.db
        
        -- Temporarily switch to the requested profile's data
        DF.db = DandersFramesDB_v2.profiles[profileKey]
        
        -- Export with the profile name
        local str = DF:ExportProfile(nil, {party = true, raid = true}, profileKey)
        
        -- Restore original db reference
        DF.db = originalDB
        
        return str
    end
    
    -- Default: export current profile
    local str = DF:ExportProfile(nil, {party = true, raid = true})
    return str
end

-- Import frame settings from an encoded string
-- Parameters:
--   str: encoded profile string (from DandersFrames_Export or manual export)
--   profileKey: (optional) exact name for the profile - if exists, overwrites it
-- Returns: boolean success, string errorMessage/profileName
function DandersFrames_Import(str, profileKey)
    if not DF then
        return false, "DandersFrames not loaded"
    end
    
    if not str or str == "" then
        return false, "Empty import string"
    end
    
    -- Validate the import string first
    if not DF.ValidateImportString then
        return false, "Import function not available"
    end
    
    local importData, errMsg = DF:ValidateImportString(str)
    if not importData then
        return false, errMsg or "Invalid import string"
    end
    
    -- Use ApplyImportedProfile to create/overwrite a profile
    if DF.ApplyImportedProfile then
        -- Use provided profileKey, or fall back to name from import data
        local targetName = profileKey
        if not targetName or targetName == "" then
            targetName = importData.profileName or "Imported Profile"
        end
        
        -- Always create a new profile for each import so that sequential imports
        -- (e.g. Wago packs importing multiple profiles) each get their own
        -- independent table. Without this, the second import mutates DF.db
        -- which still points to the first imported profile's table.
        -- allowOverwrite=true lets Wago packs re-import into the same profile name.
        local success = DF:ApplyImportedProfile(importData, nil, nil, targetName, true, true)

        if success then
            
            -- Return the actual profile name
            local actualName = DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile or targetName
            
            -- Refresh the GUI if it's open
            if DF.GUIFrame and DF.GUIFrame:IsShown() and DF.GUI and DF.GUI.RefreshCurrentPage then
                DF.GUI:RefreshCurrentPage()
            end
            
            return true, actualName
        else
            return false, "Failed to apply profile"
        end
    end
    
    -- Fallback: direct apply (shouldn't reach here normally)
    if importData.party and DF.db then
        DF.db.party = importData.party
    end
    if importData.raid and DF.db then
        DF.db.raid = importData.raid
    end
    
    -- Update frames
    if DF.UpdateAll then
        DF:UpdateAll()
    end
    
    return true
end

-- ============================================================
-- CLICK CASTING
-- ============================================================

-- Export click casting profile as an encoded string
-- Parameters:
--   profileKey: (optional) specific profile to export, defaults to current profile
-- Returns: string (encoded profile) or nil on error
function DandersFrames_ClickCast_Export(profileKey)
    local CC = DF and DF.ClickCast
    if not CC then
        return nil
    end
    
    -- If a specific profile is requested
    if profileKey and profileKey ~= "" then
        local classData = CC:GetClassData()
        if not classData or not classData.profiles or not classData.profiles[profileKey] then
            return nil  -- Profile doesn't exist
        end
        
        -- Export the specific profile
        local profile = classData.profiles[profileKey]
        local exportData = {
            version = 1,
            profileName = profileKey,
            profile = CopyTable(profile),
            exportedAt = date("%Y-%m-%d %H:%M"),
            class = select(2, UnitClass("player")),
        }
        
        -- Serialize
        local LibSerialize = LibStub and LibStub("LibSerialize", true)
        local LibDeflate = LibStub and LibStub("LibDeflate", true)
        if not LibSerialize or not LibDeflate then
            return nil
        end
        
        local serialized = LibSerialize:Serialize(exportData)
        local compressed = LibDeflate:CompressDeflate(serialized)
        local encoded = LibDeflate:EncodeForPrint(compressed)
        
        return "!DFC1!" .. encoded
    end
    
    -- Default: export current profile
    if not CC.ExportProfile then
        return nil
    end
    return CC:ExportProfile()
end

-- Import click casting profile from an encoded string
-- Parameters:
--   str: encoded profile string
--   profileKey: (optional) exact name for the profile - if exists, overwrites it
--   importAll: (optional) if true, imports ALL bindings including invalid ones
-- Returns: boolean success, string errorMessage/profileName
function DandersFrames_ClickCast_Import(str, profileKey, importAll)
    local CC = DF and DF.ClickCast
    if not CC then
        return false, "ClickCasting module not loaded"
    end
    
    if not str or str == "" then
        return false, "Empty import string"
    end
    
    -- Backwards compatibility: if profileKey is a boolean, treat it as importAll
    if type(profileKey) == "boolean" then
        importAll = profileKey
        profileKey = nil
    end
    
    -- Decode the string
    local data
    
    if string.sub(str, 1, 6) == "!DFC1!" then
        local payload = string.sub(str, 7)
        if CC.DeserializeString then
            data = CC:DeserializeString(payload)
        end
    elseif string.sub(str, 1, 5) == "DF01:" then
        local payload = string.sub(str, 6)
        if CC.DeserializeStringLegacy then
            data = CC:DeserializeStringLegacy(payload)
        end
    else
        return false, "Invalid format (expected !DFC1! or DF01: header)"
    end
    
    if not data then
        return false, "Failed to decode import data"
    end
    
    if not data.profile then
        return false, "Invalid profile data"
    end
    
    -- Analyze bindings for compatibility
    local bindingsToImport = {}
    
    if data.profile.bindings then
        for _, binding in ipairs(data.profile.bindings) do
            local isValid = true
            
            -- Check spell bindings for class compatibility (unless importing all)
            if not importAll and binding.actionType == "spell" and binding.spellName then
                if CC.GetSpellValidityStatus then
                    local status = CC:GetSpellValidityStatus(binding.spellName)
                    isValid = (status ~= "invalid")
                end
            end
            
            if isValid or importAll then
                table.insert(bindingsToImport, binding)
            end
        end
    end
    
    -- Get class data
    local classData = CC:GetClassData()
    if not classData then
        return false, "Failed to get class data"
    end
    
    -- Determine profile name
    local targetProfileName
    if profileKey and profileKey ~= "" then
        -- Use exact profileKey (will overwrite if exists)
        targetProfileName = profileKey
    else
        -- Generate unique name
        targetProfileName = data.profileName or "Imported"
        local baseName = targetProfileName
        local counter = 1
        while classData.profiles[targetProfileName] do
            counter = counter + 1
            targetProfileName = baseName .. " " .. counter
        end
    end
    
    -- Create the profile
    local profile = CopyTable(data.profile)
    profile.bindings = bindingsToImport
    
    -- Import the profile (overwrites if exists)
    classData.profiles[targetProfileName] = profile
    
    -- Ensure all required fields exist
    if not classData.profiles[targetProfileName].bindings then
        classData.profiles[targetProfileName].bindings = {}
    end
    if not classData.profiles[targetProfileName].customMacros then
        classData.profiles[targetProfileName].customMacros = {}
    end
    if not classData.profiles[targetProfileName].options then
        -- Use default options
        classData.profiles[targetProfileName].options = {
            enableMouseover = true,
            enableOnUnitFrames = true,
            enableOnRaidFrames = true,
            enableOnPartyFrames = true,
        }
    end
    
    -- Switch to the imported profile if profileKey was specified
    if profileKey and profileKey ~= "" and CC.SwitchProfile then
        CC:SwitchProfile(targetProfileName)
    end
    
    -- Refresh the UI if open
    if CC.UpdateProfileDropdown then
        CC.UpdateProfileDropdown()
    end
    if CC.RefreshClickCastingUI then
        CC:RefreshClickCastingUI()
    end
    
    return true, targetProfileName
end

-- ============================================================
-- PROFILE UTILITIES (Frame Settings)
-- ============================================================

-- Get a list of all available frame settings profile names
-- Returns: table of profile names (keys), or empty table if none
function DandersFrames_GetProfiles()
    local profiles = {}
    if DandersFramesDB_v2 and DandersFramesDB_v2.profiles then
        for name, _ in pairs(DandersFramesDB_v2.profiles) do
            table.insert(profiles, name)
        end
    end
    return profiles
end

-- Get the current active frame settings profile name
-- Returns: string profile name, or nil if not available
function DandersFrames_GetCurrentProfile()
    if DandersFramesDB_v2 and DandersFramesDB_v2.currentProfile then
        return DandersFramesDB_v2.currentProfile
    end
    return nil
end

-- ============================================================
-- PROFILE UTILITIES (Click Casting)
-- ============================================================

-- Get a list of all available click casting profile names for current class
-- Returns: table of profile names (keys), or empty table if none
function DandersFrames_ClickCast_GetProfiles()
    local profiles = {}
    local CC = DF and DF.ClickCast
    if CC and CC.GetClassData then
        local classData = CC:GetClassData()
        if classData and classData.profiles then
            for name, _ in pairs(classData.profiles) do
                table.insert(profiles, name)
            end
        end
    end
    return profiles
end

-- Get the current active click casting profile name
-- Returns: string profile name, or nil if not available
function DandersFrames_ClickCast_GetCurrentProfile()
    local CC = DF and DF.ClickCast
    if CC and CC.GetActiveProfileName then
        return CC:GetActiveProfileName()
    end
    return nil
end

-- ============================================================
-- LAYOUT & SIZE CONFIG
-- Returns a snapshot of frame dimensions, scale, spacing, and
-- layout settings for the given mode. External addons can use
-- these to size/position companion elements without guesswork.
-- ============================================================

-- Get party frame layout config
-- Returns: table with size/spacing/layout settings, or nil if not ready
--   .frameWidth      number  Frame width in pixels
--   .frameHeight     number  Frame height in pixels
--   .frameScale      number  Scale factor (1.0 = 100%)
--   .framePadding    number  Internal padding in pixels
--   .frameSpacing    number  Spacing between frames in pixels
--   .growDirection   string  "HORIZONTAL" or "VERTICAL"
--   .growthAnchor    string  Anchor point for growth (e.g. "CENTER")
--   .pixelPerfect    boolean Whether pixel-perfect positioning is enabled
function DandersFrames_GetPartyConfig()
    if not DF or not DF.db or not DF.db.party then return nil end
    local db = DF.db.party
    return {
        frameWidth    = db.frameWidth,
        frameHeight   = db.frameHeight,
        frameScale    = db.frameScale,
        framePadding  = db.framePadding,
        frameSpacing  = db.frameSpacing,
        growDirection = db.growDirection,
        growthAnchor  = db.growthAnchor,
        pixelPerfect  = db.pixelPerfect,
    }
end

-- Get raid frame layout config
-- Returns: table with size/spacing/layout settings, or nil if not ready
--   Same fields as GetPartyConfig, plus:
--   .raidUseGroups   boolean Whether raid is in grouped/separated mode
function DandersFrames_GetRaidConfig()
    if not DF or not DF.db or not DF.db.raid then return nil end
    local db = DF.db.raid
    return {
        frameWidth    = db.frameWidth,
        frameHeight   = db.frameHeight,
        frameScale    = db.frameScale,
        framePadding  = db.framePadding,
        frameSpacing  = db.frameSpacing,
        growDirection = db.growDirection,
        growthAnchor  = db.growthAnchor,
        pixelPerfect  = db.pixelPerfect,
        raidUseGroups = db.raidUseGroups,
    }
end

-- ============================================================
-- VERSION INFO
-- ============================================================

-- Get addon version (useful for compatibility checks)
-- Returns: string version
function DandersFrames_GetVersion()
    return DF and DF.VERSION or "Unknown"
end

-- Check if the API is ready (addon fully loaded)
-- Returns: boolean
function DandersFrames_IsReady()
    return DF and DF.db and true or false
end

-- ============================================================
-- FRAME ACCESS
-- ============================================================

-- Get the player frame
-- Returns: frame or nil
function DandersFrames_GetPlayerFrame()
    if not DF then return nil end
    return DF.playerFrame
end

-- Get a specific party frame by index (1-4)
-- Returns: frame or nil
function DandersFrames_GetPartyFrame(index)
    if not DF or not DF.GetPartyFrame then return nil end
    return DF:GetPartyFrame(index)
end

-- Get a specific raid frame by index (1-40)
-- Returns: frame or nil
function DandersFrames_GetRaidFrame(index)
    if not DF or not DF.GetRaidFrame then return nil end
    return DF:GetRaidFrame(index)
end

-- Get a frame by unit ID (e.g. "player", "party2", "raid15")
-- Returns: frame or nil
function DandersFrames_GetFrameForUnit(unit)
    if not DF or not DF.GetFrameForUnit then return nil end
    return DF:GetFrameForUnit(unit)
end

-- Get all visible frames as a table
-- Returns: table of frames (may be empty)
function DandersFrames_GetAllFrames()
    if not DF or not DF.GetAllFrames then return {} end
    return DF:GetAllFrames()
end

-- Iterate all frames with a callback
-- If callback is provided: calls callback(frame) for each frame, returns nil
-- If no callback: returns an iterator function for use in for-loops
-- Usage: DandersFrames_IterateFrames(function(frame) ... end)
-- Usage: for frame in DandersFrames_IterateFrames() do ... end
function DandersFrames_IterateFrames(callback)
    if not DF or not DF.IterateCompactFrames then
        if callback then return end
        return function() return nil end
    end
    return DF:IterateCompactFrames(callback)
end

-- ============================================================
-- FRAME CONTAINERS & HEADERS
-- These return the actual SecureGroupHeaderTemplate frames and
-- container frames. Useful for anchoring to the group as a whole
-- rather than individual unit frames.
-- ============================================================

-- Get the party header (SecureGroupHeaderTemplate that manages party frames)
-- Returns: frame or nil
function DandersFrames_GetPartyHeader()
    return DF and DF.partyHeader or nil
end

-- Get the party container frame (parent of the party header, movable anchor)
-- Returns: frame or nil
function DandersFrames_GetPartyContainer()
    return DF and DF.partyContainer or nil
end

-- Get the raid container frame (parent of all raid headers, movable anchor)
-- Returns: frame or nil
function DandersFrames_GetRaidContainer()
    return DF and DF.raidContainer or nil
end

-- Get a specific raid group header by group number (1-8)
-- Only populated in separated/grouped raid mode (raidUseGroups = true)
-- Returns: frame or nil
function DandersFrames_GetRaidGroupHeader(group)
    if not DF or not DF.raidSeparatedHeaders then return nil end
    return DF.raidSeparatedHeaders[group]
end

-- Get all raid group headers as a table (1-8)
-- Only populated in separated/grouped raid mode
-- Returns: table (keys 1-8, values are frames or nil)
function DandersFrames_GetRaidGroupHeaders()
    if not DF or not DF.raidSeparatedHeaders then return {} end
    local headers = {}
    for i = 1, 8 do
        headers[i] = DF.raidSeparatedHeaders[i]
    end
    return headers
end

-- Get the flat raid header (single SecureGroupHeaderTemplate for all 40 slots)
-- Only populated in flat raid mode (raidUseGroups = false)
-- Returns: frame or nil
function DandersFrames_GetFlatRaidHeader()
    if not DF or not DF.FlatRaidFrames then return nil end
    return DF.FlatRaidFrames.header
end

-- Get the arena header
-- Returns: frame or nil
function DandersFrames_GetArenaHeader()
    return DF and DF.arenaHeader or nil
end

-- Check if raid is using grouped/separated mode vs flat mode
-- Returns: boolean (true = grouped, false = flat), or nil if not available
function DandersFrames_IsRaidGrouped()
    if not DF or not DF.GetRaidDB then return nil end
    local db = DF:GetRaidDB()
    return db and db.raidUseGroups or false
end

-- ============================================================
-- PINNED FRAMES
-- ============================================================

-- Get a pinned frame header by set index (1 or 2)
-- Returns: SecureGroupHeaderTemplate frame or nil
function DandersFrames_GetPinnedHeader(setIndex)
    if not DF or not DF.PinnedFrames or not DF.PinnedFrames.initialized then return nil end
    return DF.PinnedFrames.headers and DF.PinnedFrames.headers[setIndex] or nil
end

-- Get a pinned frame container by set index (1 or 2)
-- Returns: container frame or nil
function DandersFrames_GetPinnedContainer(setIndex)
    if not DF or not DF.PinnedFrames or not DF.PinnedFrames.initialized then return nil end
    return DF.PinnedFrames.containers and DF.PinnedFrames.containers[setIndex] or nil
end

-- Get all visible pinned frames as a table
-- Returns: table of frames (may be empty)
function DandersFrames_GetPinnedFrames()
    local frames = {}
    if not DF or not DF.PinnedFrames or not DF.PinnedFrames.initialized or not DF.PinnedFrames.headers then
        return frames
    end
    for setIndex = 1, 2 do
        local header = DF.PinnedFrames.headers[setIndex]
        if header and header:IsShown() then
            for i = 1, 40 do
                local child = header:GetAttribute("child" .. i)
                if child and child:IsVisible() then
                    table.insert(frames, child)
                end
            end
        end
    end
    return frames
end

-- Find a pinned frame for a specific unit
-- Parameters:
--   unit: string unit ID (e.g. "party1", "raid5")
-- Returns: frame or nil
function DandersFrames_GetPinnedFrameForUnit(unit)
    if not DF or not unit or not DF.PinnedFrames or not DF.PinnedFrames.initialized or not DF.PinnedFrames.headers then
        return nil
    end
    for setIndex = 1, 2 do
        local header = DF.PinnedFrames.headers[setIndex]
        if header and header:IsShown() then
            for i = 1, 40 do
                local child = header:GetAttribute("child" .. i)
                if child and child:IsVisible() and child.unit == unit then
                    return child
                end
            end
        end
    end
    return nil
end

-- Check if pinned frames are initialized and active
-- Returns: boolean
function DandersFrames_IsPinnedActive()
    if not DF or not DF.PinnedFrames then return false end
    return DF.PinnedFrames.initialized == true
end

-- Get the current pinned frames mode
-- Returns: "party" or "raid" or nil
function DandersFrames_GetPinnedMode()
    if not DF or not DF.PinnedFrames or not DF.PinnedFrames.initialized then return nil end
    return DF.PinnedFrames.currentMode
end

-- ============================================================
-- EXTERNAL HIGHLIGHTS
-- Allows external addons to highlight specific unit frames with
-- a colored border overlay. These are separate from DF's internal
-- selection/aggro/hover highlights and will not conflict.
-- ============================================================

local externalHighlights = {}

local function GetOrCreateExternalHighlight(frame)
    if frame.dfExternalHighlight then
        return frame.dfExternalHighlight
    end

    local hl = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    hl:SetAllPoints()
    hl:SetFrameLevel(frame:GetFrameLevel() + 20)
    hl:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    hl:Hide()

    frame.dfExternalHighlight = hl
    return hl
end

-- Highlight a specific unit's frame
-- Parameters:
--   unit: string unit ID (e.g. "player", "party1", "raid5")
--   r, g, b: color (0-1), defaults to yellow (1, 1, 0)
--   a: alpha (0-1), defaults to 1
--   duration: seconds, nil/0 = permanent until cleared
-- Returns: boolean success
function DandersFrames_HighlightUnit(unit, r, g, b, a, duration)
    if not DF or not unit then return false end

    local frame = DF:GetFrameForUnit(unit)
    if not frame then return false end

    r = r or 1
    g = g or 1
    b = b or 0
    a = a or 1

    local hl = GetOrCreateExternalHighlight(frame)
    hl:SetBackdropBorderColor(r, g, b, a)
    hl:Show()
    externalHighlights[unit] = hl

    if duration and duration > 0 then
        C_Timer.After(duration, function()
            if hl:IsShown() and externalHighlights[unit] == hl then
                hl:Hide()
                externalHighlights[unit] = nil
            end
        end)
    end

    return true
end

-- Highlight a frame directly (for external addons that already have a frame ref)
-- Parameters:
--   frame: the frame to highlight
--   r, g, b, a, duration: same as HighlightUnit
--   key: optional string key for tracking (used by ClearHighlight)
-- Returns: boolean success
function DandersFrames_HighlightFrame(frame, r, g, b, a, duration, key)
    if not frame then return false end

    r = r or 1
    g = g or 1
    b = b or 0
    a = a or 1

    local hl = GetOrCreateExternalHighlight(frame)
    hl:SetBackdropBorderColor(r, g, b, a)
    hl:Show()

    local trackKey = key or tostring(frame)
    externalHighlights[trackKey] = hl

    if duration and duration > 0 then
        C_Timer.After(duration, function()
            if hl:IsShown() and externalHighlights[trackKey] == hl then
                hl:Hide()
                externalHighlights[trackKey] = nil
            end
        end)
    end

    return true
end

-- Highlight all visible frames
-- Parameters:
--   r, g, b: color (0-1), defaults to yellow
--   a: alpha (0-1), defaults to 1
--   duration: seconds, nil/0 = permanent until cleared
-- Returns: number of frames highlighted
function DandersFrames_HighlightAll(r, g, b, a, duration)
    if not DF or not DF.GetAllFrames then return 0 end

    local frames = DF:GetAllFrames()
    local count = 0

    for _, frame in ipairs(frames) do
        if frame:IsVisible() then
            local unit = frame.unit or tostring(frame)
            r = r or 1
            g = g or 1
            b = b or 0
            a = a or 1

            local hl = GetOrCreateExternalHighlight(frame)
            hl:SetBackdropBorderColor(r, g, b, a)
            hl:Show()
            externalHighlights[unit] = hl
            count = count + 1

            if duration and duration > 0 then
                C_Timer.After(duration, function()
                    if hl:IsShown() and externalHighlights[unit] == hl then
                        hl:Hide()
                        externalHighlights[unit] = nil
                    end
                end)
            end
        end
    end

    return count
end

-- Clear highlight on a specific unit
-- Parameters:
--   unit: string unit ID
-- Returns: boolean (true if highlight was removed)
function DandersFrames_ClearHighlight(unit)
    if not unit then return false end

    local hl = externalHighlights[unit]
    if hl then
        hl:Hide()
        externalHighlights[unit] = nil
        return true
    end

    -- Also try to find the frame and clear directly
    if DF and DF.GetFrameForUnit then
        local frame = DF:GetFrameForUnit(unit)
        if frame and frame.dfExternalHighlight then
            frame.dfExternalHighlight:Hide()
            return true
        end
    end

    return false
end

-- Clear all external highlights
-- Returns: number of highlights cleared
function DandersFrames_ClearAllHighlights()
    local count = 0
    for key, hl in pairs(externalHighlights) do
        if hl and hl.Hide then
            hl:Hide()
            count = count + 1
        end
    end
    wipe(externalHighlights)
    return count
end

-- ============================================================
-- EVENT CALLBACKS
-- External subscribable events via CallbackHandler-1.0.
-- ============================================================
-- Usage from external addons:
--   DandersFrames.RegisterCallback(self, "OnFramesSorted", function(event, sortType)
--       -- sortType is "party", "raid", or "arena"
--   end)
--   DandersFrames.UnregisterCallback(self, "OnFramesSorted")
--
-- Fires one frame after any DandersFrames unit frame has its `unit` attribute
-- reassigned - i.e., whenever Blizzard's SecureGroupHeaderTemplate reshuffles
-- children in response to a roster change, role swap, nameList update, or
-- internal re-sort. Fires in combat AND out of combat.
--
-- Coalesced per sortType: if Blizzard reassigns N children in the same tick
-- (common during a group-wide reshuffle), the callback fires exactly once
-- for that sortType on the next frame. Safe to re-query
-- DandersFrames_GetFrameForUnit(unit) from within the callback.
-- ============================================================

local CallbackHandler = LibStub and LibStub("CallbackHandler-1.0", true)
if CallbackHandler then
    DF.APICallbacks = CallbackHandler:New(DF)
end

function DF:FireAPICallback(event, ...)
    if not self.APICallbacks then
        self:DebugWarn("API", "Fire %s skipped - CallbackHandler-1.0 not loaded", event)
        return
    end
    self:Debug("API", "Fire %s (%s)", event, tostring(...))
    self.APICallbacks:Fire(event, ...)
end

-- ============================================================
-- DEBUG / TEST SLASH COMMANDS
-- ============================================================

SLASH_DFAPI1 = "/dfapi"
SlashCmdList["DFAPI"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    if msg == "test" then
        DF:FireAPICallback("OnFramesSorted", "party")
        DF:FireAPICallback("OnFramesSorted", "raid")
        DF:FireAPICallback("OnFramesSorted", "arena")
        print("|cff00ff00DandersFrames:|r Fired test OnFramesSorted (party + raid + arena)")

    elseif msg == "fire" then
        -- Re-apply the party header sort. Real sorting happens via the
        -- nameList/groupBy attributes on the SecureGroupHeaderTemplate
        -- (Headers.lua), not the SecureSort snippet path. This is what
        -- actually drives OnFramesSorted in production.
        if InCombatLockdown() then
            print("|cffff0000DandersFrames:|r Cannot fire sort in combat (header attributes are protected)")
            return
        end
        if DF.ApplyPartyGroupSorting then
            DF:ApplyPartyGroupSorting()
            print("|cff00ff00DandersFrames:|r Applied party sort - callback fires ~1 frame later")
        else
            print("|cffff0000DandersFrames:|r ApplyPartyGroupSorting not available")
        end

    elseif msg == "snippet" then
        -- Isolation test: run a bare secure snippet that ONLY calls CallMethod.
        -- If this fires the [DF API TRACE] chat line, secure->Lua hop works and
        -- the sort-path failure is elsewhere (snippet bailing early, etc.).
        if DF.SecureSort and DF.SecureSort.handler and DF.SecureSort.initialized then
            if InCombatLockdown() then
                print("|cffff0000DandersFrames:|r Cannot run snippet test in combat")
                return
            end
            DF.SecureSort.handler:Execute([[
                self:CallMethod("NotifySortComplete", "snippet-test")
            ]])
            print("|cff00ff00DandersFrames:|r Executed bare snippet with CallMethod - expect [DF API TRACE] chat line")
        else
            print("|cffff0000DandersFrames:|r SecureSort.handler not ready (initialized=" .. tostring(DF.SecureSort and DF.SecureSort.initialized) .. ")")
        end

    elseif msg == "watch" then
        if DF._apiWatchToken then
            DandersFrames.UnregisterCallback(DF._apiWatchToken, "OnFramesSorted")
            DF._apiWatchToken = nil
            print("|cff00ff00DandersFrames:|r API watch OFF")
        else
            DF._apiWatchToken = {}
            DandersFrames.RegisterCallback(DF._apiWatchToken, "OnFramesSorted", function(event, sortType)
                print(format("|cff00ccff[DF API]|r %s: %s @ %.3f", event, tostring(sortType), GetTime()))
            end)
            print("|cff00ff00DandersFrames:|r API watch ON - chat messages on every OnFramesSorted")
        end

    elseif msg == "list" then
        if not DF.APICallbacks or not DF.APICallbacks.events then
            print("|cffff0000DandersFrames:|r callback registry not initialized")
            return
        end
        print("|cff00ccffDandersFrames API callbacks:|r")
        local any = false
        for event, subs in pairs(DF.APICallbacks.events) do
            local count = 0
            for _ in pairs(subs) do count = count + 1 end
            print(format("  %s: %d subscriber(s)", event, count))
            any = true
        end
        if not any then
            print("  (no subscribers)")
        end

    else
        print("|cff00ff00DandersFrames API commands:|r")
        print("  /dfapi test    - fire a test callback (bypasses sort)")
        print("  /dfapi fire    - trigger a real sort (with pipeline diagnostics)")
        print("  /dfapi snippet - run a bare secure snippet that only calls CallMethod")
        print("  /dfapi watch   - toggle a chat-printing subscriber")
        print("  /dfapi list    - list current subscribers per event")
    end
end
