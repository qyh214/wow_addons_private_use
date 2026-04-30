local addonName, DF = ...

-- ============================================================
-- AUTO PROFILES UI - Raid-only automatic profile switching
-- ============================================================

local AutoProfilesUI = {}
DF.AutoProfilesUI = AutoProfilesUI

local L = DF.L
local format = string.format

-- Local references
local C_RAID = {r = 1.0, g = 0.5, b = 0.2, a = 1}
local C_WARNING = {r = 1.0, g = 0.67, b = 0.0, a = 1}

-- Deep-copy a value (recursive for nested tables)
local function DeepCopyValue(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = DeepCopyValue(v)
    end
    return copy
end

-- Content type definitions
local CONTENT_TYPES = {
    {
        key = "instanced",
        title = L["Instanced / PvP"],
        description = L["Raids, battlegrounds (1-40)"],
        minRange = 1,
        maxRange = 40,
        isFixed = false,
    },
    {
        key = "mythic",
        title = L["Mythic"],
        description = L["20 players (fixed)"],
        minRange = 20,
        maxRange = 20,
        isFixed = true,
    },
    {
        key = "openWorld",
        title = L["Open World"],
        description = L["World bosses, outdoor raids (1-40)"],
        minRange = 1,
        maxRange = 40,
        isFixed = false,
    },
}

-- ============================================================
-- LOCAL HELPERS for db.raid access and snapshot lookups
-- Defined here so all functions in this file can reference them
-- ============================================================

-- Parse table-based keys (e.g., "raidGroupVisible_1" -> "raidGroupVisible", 1)
local function ParseTableKey(key)
    local tableName, index = key:match("^(.+)_(%d+)$")
    if tableName and index then
        return tableName, tonumber(index)
    end
    return nil, nil
end

-- Parse pinned frame keys (e.g., "pinned.1.scale" -> 1, "scale")
local function ParsePinnedKey(key)
    local setIndex, setting = key:match("^pinned%.(%d+)%.(.+)$")
    if setIndex and setting then
        return tonumber(setIndex), setting
    end
    return nil, nil
end

-- Settings that can be overridden per pinned frame set
local PINNED_OVERRIDABLE = {
    enabled = true, locked = true, showLabel = true,
    growDirection = true, unitsPerRow = true, scale = true,
    horizontalSpacing = true, verticalSpacing = true, frameAnchor = true,
    columnAnchor = true, autoAddTanks = true, autoAddHealers = true,
    autoAddDPS = true, keepOfflinePlayers = true, players = true,
}

-- ============================================================
-- OVERRIDE KEY → TAB MAPPING
-- Maps override key prefixes to sidebar tab IDs for display.
-- Ordered most-specific first to avoid false matches
-- (e.g. "healthText" before "health", "defensiveIcon" before "debuff").
-- ============================================================
local OVERRIDE_TAB_MAP = {
    -- Display
    {"soloMode",            "display_visibility",   L["Visibility"]},
    {"showMinimapButton",   "display_visibility",   L["Visibility"]},
    {"restedIndicator",     "display_visibility",   L["Visibility"]},
    {"hidePlayerFrame",     "display_visibility",   L["Visibility"]},
    {"hideDefaultPlayerFrame", "display_visibility", L["Visibility"]},
    {"hideBlizzardPartyFrames", "display_visibility", L["Visibility"]},
    {"hideBlizzardRaidFrames", "display_visibility", L["Visibility"]},
    {"showBlizzardSideMenu", "display_visibility",  L["Visibility"]},
    {"tooltip",             "display_tooltips",     L["Tooltips"]},
    {"rangeFade",           "display_fading",       L["Fading"]},
    {"oor",                 "display_fading",       L["Fading"]},
    {"dead",                "display_fading",       L["Fading"]},
    {"offline",             "display_fading",       L["Fading"]},
    {"pet",                 "display_pets",         L["Pet Frames"]},
    -- General (specific before generic)
    {"fontShadow",          "general_fonts",        L["Global Fonts"]},
    {"groupLabel",          "general_labels",       L["Group Labels"]},
    {"raidTestFrameCount",  "general_frame",        L["Frame"]},
    {"raidUseGroups",       "general_frame",        L["Frame"]},
    {"raidGroupVisible",    "general_frame",        L["Frame"]},
    {"raidPlayerPerRow",    "general_frame",        L["Frame"]},
    {"raidFlat",            "general_frame",        L["Frame"]},
    {"frame",               "general_frame",        L["Frame"]},
    {"background",          "general_frame",        L["Frame"]},
    {"missingHealth",       "general_frame",        L["Frame"]},
    {"border",              "general_frame",        L["Frame"]},
    {"anchor",              "general_frame",        L["Frame"]},
    {"sort",                "general_sorting",      L["Sorting"]},
    {"selfPosition",        "general_sorting",      L["Sorting"]},
    {"rolePriority",        "general_sorting",      L["Sorting"]},
    {"classPriority",       "general_sorting",      L["Sorting"]},
    {"colorPickerOverride", "general_integrations", L["Integrations"]},
    {"colorPickerGlobalOverride", "general_integrations", L["Integrations"]},
    {"masqueBorderControl", "general_integrations", L["Integrations"]},
    {"buffDisableMouse",    "general_integrations", L["Integrations"]},
    {"debuffDisableMouse",  "general_integrations", L["Integrations"]},
    {"defensiveIconDisableMouse", "general_integrations", L["Integrations"]},
    {"targetedSpellDisableMouse", "general_integrations", L["Integrations"]},
    -- Bars (specific text keys before generic "health" prefix)
    {"healthText",          "text_health",          L["Health Text"]},
    {"healthFont",          "text_health",          L["Health Text"]},
    {"health",              "bars_health",          L["Health Bar"]},
    {"classColor",          "bars_health",          L["Health Bar"]},
    {"smoothBars",          "bars_health",          L["Health Bar"]},
    {"resourceBar",         "bars_resource",        L["Resource Bar"]},
    {"absorbBar",           "bars_absorb",          L["Absorbs"]},
    {"healAbsorb",          "bars_absorb",          L["Absorbs"]},
    {"healPrediction",      "bars_healpred",        L["Heal Prediction"]},
    -- Text
    {"statusText",          "text_status",          L["Status Text"]},
    {"name",                "text_name",            L["Name Text"]},
    -- Auras (specific before generic)
    -- myBuffIndicator removed — feature deprecated and hidden from UI
    {"bossDebuff",          "auras_bossdebuffs",    L["Boss Debuffs"]},
    {"missingBuff",         "auras_missingbuffs",   L["Missing Buffs"]},
    {"defensiveIcon",       "auras_defensiveicon",  L["Defensive Icon"]},
    {"debuff",              "auras_debuffs",        L["Debuffs"]},
    {"buff",                "auras_buffs",          L["Buffs"]},
    {"dispel",              "auras_dispel",         L["Dispel Overlay"]},
    {"auraDesigner",        "auras_auradesigner",   L["Aura Designer"]},
    -- Indicators (specific before generic)
    {"personalTargeted",    "indicators_personal_targeted", L["Personal Targeted"]},
    {"targetedList",        "indicators_targetedlist", L["Targeted List"]},
    {"targetedSpell",       "indicators_targetedspells", L["Targeted Spells"]},
    {"roleIcon",            "indicators_icons",     L["Icons"]},
    {"leaderIcon",          "indicators_icons",     L["Icons"]},
    {"raidTargetIcon",      "indicators_icons",     L["Icons"]},
    {"readyCheckIcon",      "indicators_icons",     L["Icons"]},
    {"summonIcon",          "indicators_icons",     L["Icons"]},
    {"resurrectionIcon",    "indicators_icons",     L["Icons"]},
    {"phasedIcon",          "indicators_icons",     L["Icons"]},
    {"afkIcon",             "indicators_icons",     L["Icons"]},
    {"vehicleIcon",         "indicators_icons",     L["Icons"]},
    {"raidRoleIcon",        "indicators_icons",     L["Icons"]},
    {"statusIconFont",      "indicators_icons",     L["Icons"]},
    {"selectionHighlight",  "indicators_highlights", L["Highlights"]},
    {"hoverHighlight",      "indicators_highlights", L["Highlights"]},
    {"aggroHighlight",      "indicators_highlights", L["Highlights"]},
    {"aggro",               "indicators_highlights", L["Highlights"]},
    -- Pinned frames (prefix match for "pinned.N.setting" format)
    {"pinned.",             "general_pinnedframes", L["Pinned Frames"]},
}

-- Returns tabId, tabLabel for a given override key
local function GetOverrideTabId(key)
    -- Strip table-based suffix (e.g. "raidGroupVisible_1" → "raidGroupVisible")
    local baseKey = key:match("^(.+)_%d+$") or key
    for _, entry in ipairs(OVERRIDE_TAB_MAP) do
        local prefix = entry[1]
        if baseKey:sub(1, #prefix) == prefix then
            return entry[2], entry[3]
        end
    end
    return nil, "Unknown"
end

-- Groups override keys by tab, returns { [tabId] = { tabLabel, keys = {} } }, unknownKeys
local function GroupOverridesByTab(overrides)
    local groups = {}
    local unknownKeys = {}
    for key, _ in pairs(overrides) do
        local tabId, tabLabel = GetOverrideTabId(key)
        if tabId then
            if not groups[tabId] then
                groups[tabId] = { tabLabel = tabLabel, keys = {} }
            end
            tinsert(groups[tabId].keys, key)
        else
            tinsert(unknownKeys, key)
        end
    end
    return groups, unknownKeys
end

-- Get a value from the real raid database, handling raid keys, table keys, and pinned keys.
-- Always reads the real table (DF._realRaidDB) — never the overlay proxy.
local function GetRaidValue(key)
    local realRaid = DF._realRaidDB or (DF.db and DF.db.raid)
    if not realRaid then return nil end

    -- Pinned frame key (stored at raid.pinnedFrames)
    local setIndex, setting = ParsePinnedKey(key)
    if setIndex and setting then
        local pf = realRaid.pinnedFrames
        local sets = pf and pf.sets
        if sets and sets[setIndex] then
            return sets[setIndex][setting]
        end
        return nil
    end

    -- Table-based raid key
    local tableName, index = ParseTableKey(key)
    if tableName and index then
        local tbl = realRaid[tableName]
        if type(tbl) == "table" then
            return tbl[index]
        end
        return nil
    end

    -- Direct raid key
    return realRaid[key]
end

-- Set a value in the real raid database, handling raid keys, table keys, and pinned keys.
-- Always writes to the real table (DF._realRaidDB) — never the overlay proxy.
local function SetRaidValue(key, value)
    local realRaid = DF._realRaidDB or (DF.db and DF.db.raid)
    if not realRaid then return end

    -- Pinned frame key (stored at raid.pinnedFrames)
    local setIndex, setting = ParsePinnedKey(key)
    if setIndex and setting then
        local pf = realRaid.pinnedFrames
        local sets = pf and pf.sets
        if sets and sets[setIndex] then
            sets[setIndex][setting] = value
        end
        return
    end

    -- Table-based raid key
    local tableName, index = ParseTableKey(key)
    if tableName and index then
        local tbl = realRaid[tableName]
        if type(tbl) == "table" then
            tbl[index] = value
        end
    else
        realRaid[key] = value
    end
end

-- Get a value from the global snapshot, handling all key types
-- Pinned keys are stored directly in the snapshot as "pinned.1.scale" etc
local function GetSnapshotValue(snapshot, key)
    if not snapshot then return nil, false end
    
    -- Direct key match (works for pinned keys and direct raid keys)
    if snapshot[key] ~= nil then
        return snapshot[key], true
    end
    
    -- Table-based key (e.g., "raidGroupVisible_1" -> snapshot["raidGroupVisible"][1])
    local tableName, index = ParseTableKey(key)
    if tableName and index and type(snapshot[tableName]) == "table" then
        return snapshot[tableName][index], true
    end
    
    return nil, false
end

-- Find a matching profile within a content type by raid size
-- Returns the first profile whose min-max range includes raidSize, or nil
local function FindMatchingProfile(contentKey, raidSize)
    local autoDb = DF.db and DF.db.raidAutoProfiles
    if not autoDb then return nil end

    local ct = autoDb[contentKey]
    if not ct or not ct.profiles then return nil end

    for _, profile in ipairs(ct.profiles) do
        if raidSize >= profile.min and raidSize <= profile.max then
            DF:Debug("LAYOUT", "FindMatchingProfile: matched \"%s\" for %s (size %d, range %d-%d)", profile.name or "?", contentKey, raidSize, profile.min, profile.max)
            return profile
        end
    end

    DF:Debug("LAYOUT", "FindMatchingProfile: no match for %s (size %d, %d profiles checked)", contentKey, raidSize, #ct.profiles)
    return nil
end

-- Initialize database defaults
function AutoProfilesUI:InitDefaults()
    if not DF.db.raidAutoProfiles then
        DF.db.raidAutoProfiles = {
            enabled = false,
            howItWorksCollapsed = false,
            instanced = { profiles = {} },
            mythic = { profile = nil },
            openWorld = { profiles = {} }
        }
    end
    -- Migration: add howItWorksCollapsed if missing from existing db
    if DF.db.raidAutoProfiles.howItWorksCollapsed == nil then
        DF.db.raidAutoProfiles.howItWorksCollapsed = false
    end
end

-- Get profiles for a content type
function AutoProfilesUI:GetProfiles(contentKey)
    self:InitDefaults()
    if contentKey == "mythic" then
        local profile = DF.db.raidAutoProfiles.mythic.profile
        return profile and {profile} or {}
    else
        return DF.db.raidAutoProfiles[contentKey].profiles or {}
    end
end

-- Check for range overlap within a content type
function AutoProfilesUI:CheckRangeOverlap(contentKey, min, max, excludeIndex)
    local profiles = self:GetProfiles(contentKey)
    for i, p in ipairs(profiles) do
        if i ~= excludeIndex then
            if min <= p.max and max >= p.min then
                return p  -- Returns the overlapping profile
            end
        end
    end
    return nil
end

-- Create a profile
function AutoProfilesUI:CreateProfile(contentKey, name, min, max)
    self:InitDefaults()
    DF:Debug("LAYOUT", "CreateProfile: contentKey=%s name=\"%s\" min=%s max=%s", contentKey, name or "?", tostring(min), tostring(max))

    if contentKey == "mythic" then
        DF.db.raidAutoProfiles.mythic.profile = {
            name = name or "Mythic Setup",
            overrides = {}
        }
        DF:Debug("LAYOUT", "CreateProfile: mythic layout created")
        return true
    end

    -- Check for name conflict
    local profiles = DF.db.raidAutoProfiles[contentKey].profiles
    for _, p in ipairs(profiles) do
        if p.name:lower() == name:lower() then
            DF:DebugWarn("LAYOUT", "CreateProfile: name conflict with \"%s\"", name)
            return false, L["Name already exists"]
        end
    end

    -- Check for range overlap
    local overlap = self:CheckRangeOverlap(contentKey, min, max)
    if overlap then
        return false, format(L["Overlaps with \"%s\""], overlap.name)
    end
    
    -- Create the profile
    table.insert(profiles, {
        name = name,
        min = min,
        max = max,
        overrides = {}
    })
    
    -- Sort by min range
    table.sort(profiles, function(a, b) return a.min < b.min end)
    
    return true
end

-- Delete a profile
function AutoProfilesUI:DeleteProfile(contentKey, index)
    self:InitDefaults()

    -- Capture a reference before deletion to check if it was the active runtime profile
    local deletedProfile
    if contentKey == "mythic" then
        deletedProfile = DF.db.raidAutoProfiles.mythic.profile
        DF.db.raidAutoProfiles.mythic.profile = nil
    else
        local profiles = DF.db.raidAutoProfiles[contentKey].profiles
        if profiles[index] then
            deletedProfile = profiles[index]
            table.remove(profiles, index)
        else
            DF:DebugWarn("LAYOUT", "DeleteProfile: index %s not found in %s", tostring(index), contentKey)
            return false
        end
    end

    DF:Debug("LAYOUT", "DeleteProfile: removed \"%s\" from %s", deletedProfile and deletedProfile.name or "?", contentKey)

    -- If the deleted profile was the active runtime profile, deactivate it
    if deletedProfile and self.activeRuntimeProfile == deletedProfile then
        DF:Debug("LAYOUT", "DeleteProfile: deleted layout was active, deactivating overlay")
        DF.raidOverrides = nil
        self.activeRuntimeProfile = nil
        self.activeRuntimeContentKey = nil
        if DF.FullProfileRefresh then
            DF:FullProfileRefresh()
        end
        print("|cff00ff00DandersFrames:|r " .. L["Auto-profile deactivated (profile deleted)"])
    end

    return true
end

-- Update profile range
function AutoProfilesUI:UpdateProfileRange(contentKey, index, newMin, newMax)
    self:InitDefaults()
    DF:Debug("LAYOUT", "UpdateProfileRange: %s index=%s newMin=%d newMax=%d", contentKey, tostring(index), newMin, newMax)

    if contentKey == "mythic" then
        return false, L["Mythic has fixed range"]
    end

    local profiles = DF.db.raidAutoProfiles[contentKey].profiles
    if not profiles[index] then
        return false, L["Profile not found"]
    end

    -- Check for overlap (excluding current profile)
    local overlap = self:CheckRangeOverlap(contentKey, newMin, newMax, index)
    if overlap then
        DF:DebugWarn("LAYOUT", "UpdateProfileRange: overlap with \"%s\" (%d-%d)", overlap.name, overlap.min, overlap.max)
        return false, format(L["Overlaps with \"%s\""], overlap.name)
    end

    local oldMin, oldMax = profiles[index].min, profiles[index].max
    profiles[index].min = newMin
    profiles[index].max = newMax
    DF:Debug("LAYOUT", "UpdateProfileRange: \"%s\" range %d-%d -> %d-%d", profiles[index].name or "?", oldMin, oldMax, newMin, newMax)

    -- Re-sort
    table.sort(profiles, function(a, b) return a.min < b.min end)

    return true
end

-- ============================================================
-- UI BUILDING
-- ============================================================

-- Build the Auto Profiles page content
function AutoProfilesUI:BuildPage(GUI, pageFrame, db, Add, AddSpace)
    local self = AutoProfilesUI
    self:InitDefaults()
    
    local autoDb = DF.db.raidAutoProfiles
    
    -- Only show for Raid mode
    if GUI.SelectedMode ~= "raid" then
        Add(GUI:CreateHeader(pageFrame.child, L["Raid Auto Layouts"]), 40, "both")
        Add(GUI:CreateLabel(pageFrame.child,
            L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."],
            500, {r = 0.6, g = 0.6, b = 0.6}), 60, "both")
        return
    end

    -- =============================================
    -- Enable Checkbox
    -- =============================================
    local enableCheck = GUI:CreateCheckbox(pageFrame.child, L["Enable Raid Auto-Switching Layouts"],
        nil, nil,  -- dbTable, dbKey (not used)
        function() pageFrame:Refresh() end,  -- callback
        function() return autoDb.enabled end,  -- customGet
        function(val)                           -- customSet
            autoDb.enabled = val
            if not val then
                AutoProfilesUI:RemoveRuntimeProfile()
            else
                AutoProfilesUI:EvaluateAndApply()
            end
        end
    )
    Add(enableCheck, 30, "both")
    
    AddSpace(5, "both")
    
    -- =============================================
    -- Current Status Box
    -- =============================================
    local statusContainer = CreateFrame("Frame", nil, pageFrame.child, "BackdropTemplate")
    statusContainer:SetSize(500, 55)
    statusContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    statusContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    statusContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    
    local statusTitle = statusContainer:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    statusTitle:SetPoint("TOPLEFT", 10, -8)
    statusTitle:SetText(L["CURRENT STATUS"])
    statusTitle:SetTextColor(0.5, 0.5, 0.5)
    
    local statusLine1 = statusContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    statusLine1:SetPoint("TOPLEFT", 10, -24)
    
    local statusLine2 = statusContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    statusLine2:SetPoint("TOPLEFT", 10, -38)
    
    -- Update status display
    if not autoDb.enabled then
        statusLine1:SetText("|cff666666" .. L["Auto-switching disabled"] .. "|r")
        statusLine2:SetText("")
    elseif not IsInRaid() then
        statusLine1:SetText("|cff999999" .. L["Not in a raid group"] .. "|r")
        statusLine2:SetText("")
    else
        -- Live detection
        local contentType = DF:GetContentType()
        local raidSize = GetNumGroupMembers()

        -- Map content type to display name
        local contentNames = {
            mythic = L["Mythic"],
            instanced = L["Instanced / PvP"],
            battleground = L["Instanced / PvP"],
            openWorld = L["Open World"],
            arena = L["Arena"],
        }
        local contentDisplay = contentNames[contentType] or L["Unknown"]

        -- Get instance name if available
        local instanceName = select(1, GetInstanceInfo())
        local difficultyName = select(4, GetInstanceInfo())
        local contentDetail = ""
        if instanceName and instanceName ~= "" and contentType ~= "openWorld" then
            contentDetail = " |cff666666— " .. instanceName
            if difficultyName and difficultyName ~= "" then
                contentDetail = contentDetail .. " (" .. difficultyName .. ")"
            end
            contentDetail = contentDetail .. "|r"
        end

        statusLine1:SetText("|cff66ff66" .. L["Content:"] .. "|r |cffffffff" .. contentDisplay .. "|r" .. contentDetail .. "  |cff666666(" .. format(L["%d players"], raidSize) .. ")|r")

        -- Show active profile
        local profile, profileKey = self:GetActiveProfile()
        if profile then
            local rangeText = ""
            if profileKey == "mythic" then
                rangeText = L["20 players (fixed)"]
            elseif profile.min and profile.max then
                rangeText = profile.min .. "-" .. profile.max
            end
            local overrideCount = 0
            if profile.overrides then
                for _ in pairs(profile.overrides) do overrideCount = overrideCount + 1 end
            end
            statusLine2:SetText("|cff66ff66" .. L["Layout:"] .. "|r |cffffffff\"" .. (profile.name or L["Unnamed"]) .. "\"|r |cff666666— " .. rangeText .. " · " .. format(overrideCount ~= 1 and L["%d overrides"] or L["%d override"], overrideCount) .. "|r")
        else
            statusLine2:SetText("|cff66ff66" .. L["Layout:"] .. "|r |cff999999" .. L["None active (using global settings)"] .. "|r")
        end
    end
    
    Add(statusContainer, 60, "both")
    
    AddSpace(5, "both")
    
    -- =============================================
    -- How It Works Section (collapsible, persisted)
    -- =============================================
    local infoHeaderHeight = 28
    local infoBodyHeight = 206
    local infoCollapsed = autoDb.howItWorksCollapsed
    
    local infoContainer = CreateFrame("Frame", nil, pageFrame.child, "BackdropTemplate")
    infoContainer:SetSize(500, infoHeaderHeight + (infoCollapsed and 0 or infoBodyHeight))
    infoContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    infoContainer:SetBackdropColor(0.15, 0.1, 0.05, 0.5)
    infoContainer:SetBackdropBorderColor(0.4, 0.25, 0.1, 0.5)
    
    -- Clickable header
    local infoHeader = CreateFrame("Button", nil, infoContainer)
    infoHeader:SetPoint("TOPLEFT", 0, 0)
    infoHeader:SetPoint("TOPRIGHT", 0, 0)
    infoHeader:SetHeight(infoHeaderHeight)
    
    local infoArrow = infoHeader:CreateTexture(nil, "OVERLAY")
    infoArrow:SetPoint("LEFT", 10, 0)
    infoArrow:SetSize(12, 12)
    infoArrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\" .. (infoCollapsed and "chevron_right" or "expand_more"))
    infoArrow:SetVertexColor(0.6, 0.6, 0.6)
    
    local howTitle = infoHeader:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    howTitle:SetPoint("LEFT", 28, 0)
    howTitle:SetText(L["How it works"])
    howTitle:SetTextColor(1, 1, 1)
    
    infoHeader:SetScript("OnEnter", function() infoArrow:SetVertexColor(1, 0.8, 0.2) end)
    infoHeader:SetScript("OnLeave", function() infoArrow:SetVertexColor(0.6, 0.6, 0.6) end)
    
    -- Body
    local infoBody = CreateFrame("Frame", nil, infoContainer)
    infoBody:SetPoint("TOPLEFT", 0, -infoHeaderHeight)
    infoBody:SetPoint("TOPRIGHT", 0, -infoHeaderHeight)
    infoBody:SetHeight(infoBodyHeight)
    if infoCollapsed then infoBody:Hide() end
    
    -- Toggle
    infoHeader:SetScript("OnClick", function()
        autoDb.howItWorksCollapsed = not autoDb.howItWorksCollapsed
        if autoDb.howItWorksCollapsed then
            infoArrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
            infoBody:Hide()
        else
            infoArrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
            infoBody:Show()
        end
        -- Refresh page to recalculate layout
        if pageFrame.Refresh then pageFrame:Refresh() end
    end)
    
    local yOff = -4
    
    -- Step 1
    local step1 = infoBody:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    step1:SetPoint("TOPLEFT", 10, yOff)
    step1:SetPoint("RIGHT", infoBody, "RIGHT", -10, 0)
    step1:SetJustifyH("LEFT")
    step1:SetText("|cffff8020" .. "1.|r " .. format(L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."], "|cffffffff", "|r"))
    step1:SetTextColor(0.65, 0.65, 0.65)
    yOff = yOff - 30
    
    -- Step 2
    local step2 = infoBody:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    step2:SetPoint("TOPLEFT", 10, yOff)
    step2:SetPoint("RIGHT", infoBody, "RIGHT", -10, 0)
    step2:SetJustifyH("LEFT")
    step2:SetText("|cffff8020" .. "2.|r " .. format(L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."], "|cffffffff", "|r"))
    step2:SetTextColor(0.65, 0.65, 0.65)
    yOff = yOff - 30
    
    -- Step 3 - visual indicators
    local step3 = infoBody:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    step3:SetPoint("TOPLEFT", 10, yOff)
    step3:SetPoint("RIGHT", infoBody, "RIGHT", -10, 0)
    step3:SetJustifyH("LEFT")
    step3:SetText("|cffff8020" .. "3.|r " .. L["While editing, each setting shows its override status:"])
    step3:SetTextColor(0.65, 0.65, 0.65)
    yOff = yOff - 16
    
    -- Visual example row 1: Matching global (green check)
    local exRow1 = CreateFrame("Frame", nil, infoBody)
    exRow1:SetPoint("TOPLEFT", 24, yOff)
    exRow1:SetSize(460, 16)
    
    local ex1Check = exRow1:CreateTexture(nil, "OVERLAY")
    ex1Check:SetPoint("LEFT", 0, 0)
    ex1Check:SetSize(10, 10)
    ex1Check:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
    ex1Check:SetVertexColor(0.3, 0.7, 0.3)
    
    local ex1Text = exRow1:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    ex1Text:SetPoint("LEFT", ex1Check, "RIGHT", 4, 0)
    ex1Text:SetText(format(L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"], "|cff4db84d", "|r", "|cff666666", "|r"))
    yOff = yOff - 18
    
    -- Visual example row 2: Overridden (star + reset)
    local exRow2 = CreateFrame("Frame", nil, infoBody)
    exRow2:SetPoint("TOPLEFT", 24, yOff)
    exRow2:SetSize(460, 16)
    
    local ex2Star = exRow2:CreateTexture(nil, "OVERLAY")
    ex2Star:SetPoint("LEFT", 0, 0)
    ex2Star:SetSize(12, 12)
    ex2Star:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
    ex2Star:SetVertexColor(1, 0.8, 0.2)
    
    local ex2ResetBg = exRow2:CreateTexture(nil, "ARTWORK")
    ex2ResetBg:SetPoint("LEFT", ex2Star, "RIGHT", 4, 0)
    ex2ResetBg:SetSize(14, 14)
    ex2ResetBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    local ex2Reset = exRow2:CreateTexture(nil, "OVERLAY")
    ex2Reset:SetPoint("CENTER", ex2ResetBg, "CENTER", 0, 0)
    ex2Reset:SetSize(10, 10)
    ex2Reset:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\refresh")
    ex2Reset:SetVertexColor(0.6, 0.6, 0.6)
    
    local ex2Text = exRow2:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    ex2Text:SetPoint("LEFT", ex2ResetBg, "RIGHT", 6, 0)
    ex2Text:SetText(format(L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"], "|cffe6cc80", "|r", "|cff666666", "|r", "|cffffffff", "|r", "|cff666666", "|r"))
    yOff = yOff - 22
    
    -- Step 4
    local step4 = infoBody:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    step4:SetPoint("TOPLEFT", 10, yOff)
    step4:SetPoint("RIGHT", infoBody, "RIGHT", -10, 0)
    step4:SetJustifyH("LEFT")
    step4:SetText("|cffff8020" .. "4.|r " .. format(L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."], "|cffffffff", "|r"))
    step4:SetTextColor(0.65, 0.65, 0.65)
    yOff = yOff - 30
    
    -- Step 5
    local step5 = infoBody:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    step5:SetPoint("TOPLEFT", 10, yOff)
    step5:SetPoint("RIGHT", infoBody, "RIGHT", -10, 0)
    step5:SetJustifyH("LEFT")
    step5:SetText("|cffff8020" .. "5.|r " .. L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."])
    step5:SetTextColor(0.65, 0.65, 0.65)
    
    Add(infoContainer, infoHeaderHeight + (infoCollapsed and 0 or infoBodyHeight), "both")
    
    AddSpace(10, "both")
    
    -- =============================================
    -- Content Type Sections (dynamic height via layoutHeight)
    -- =============================================
    for _, ct in ipairs(CONTENT_TYPES) do
        local section = self:CreateContentTypeSection(GUI, pageFrame, ct)
        -- Add section with its current height
        Add(section, section.totalHeight, "both")
        AddSpace(8, "both")
    end
end

-- Create a content type section (collapsible)
function AutoProfilesUI:CreateContentTypeSection(GUI, pageFrame, contentType)
    local self = AutoProfilesUI
    local autoDb = DF.db.raidAutoProfiles
    
    local profiles = self:GetProfiles(contentType.key)
    local numProfiles = #profiles
    
    -- Calculate heights
    local headerHeight = 32
    local rowHeight = 32
    local addButtonHeight = 32  -- Always include add button height
    local bodyPadding = 10
    local bodyHeight = (numProfiles * rowHeight) + addButtonHeight + bodyPadding
    
    -- If no layouts and is mythic, need extra space for "no layout set" text
    if contentType.key == "mythic" and numProfiles == 0 then
        bodyHeight = 60  -- Empty text + add button + padding
    elseif contentType.isFixed and numProfiles > 0 then
        -- Mythic with profile - no add button needed
        bodyHeight = (numProfiles * rowHeight) + bodyPadding
    end
    
    local section = CreateFrame("Frame", nil, pageFrame.child, "BackdropTemplate")
    section:SetSize(500, headerHeight)
    section:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    section:SetBackdropColor(0.12, 0.12, 0.12, 1)
    section:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    section.expanded = true
    section.contentKey = contentType.key
    section.totalHeight = headerHeight + (section.expanded and bodyHeight or 0)
    
    -- Header button
    local header = CreateFrame("Button", nil, section)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(headerHeight)
    
    -- Arrow
    section.arrow = header:CreateTexture(nil, "OVERLAY")
    section.arrow:SetPoint("LEFT", 10, 0)
    section.arrow:SetSize(12, 12)
    section.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    section.arrow:SetVertexColor(0.6, 0.6, 0.6)
    
    -- Title
    local titleText = header:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    titleText:SetPoint("LEFT", 28, 0)
    titleText:SetText(contentType.title)
    titleText:SetTextColor(1, 0.5, 0.2)  -- Raid orange
    
    -- Description
    local descText = header:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    descText:SetPoint("RIGHT", -10, 0)
    descText:SetText(contentType.description)
    descText:SetTextColor(0.5, 0.5, 0.5)
    
    -- Body container
    section.body = CreateFrame("Frame", nil, section)
    section.body:SetPoint("TOPLEFT", 0, -headerHeight)
    section.body:SetPoint("TOPRIGHT", 0, -headerHeight)
    section.body:SetHeight(bodyHeight)
    
    -- Toggle
    header:SetScript("OnClick", function()
        section.expanded = not section.expanded
        if section.expanded then
            section.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
            section.body:Show()
            section.totalHeight = headerHeight + bodyHeight
        else
            section.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
            section.body:Hide()
            section.totalHeight = headerHeight
        end
        -- Update layoutHeight for the page layout system
        section.layoutHeight = section.totalHeight
        section:SetHeight(section.totalHeight)
        -- Call the page's RefreshStates to reposition all elements
        if pageFrame.RefreshStates then pageFrame:RefreshStates() end
    end)
    
    -- Hover effect
    header:SetScript("OnEnter", function()
        section:SetBackdropColor(0.16, 0.16, 0.16, 1)
    end)
    header:SetScript("OnLeave", function()
        section:SetBackdropColor(0.12, 0.12, 0.12, 1)
    end)
    
    -- Render profile rows
    local y = -5
    for i, profile in ipairs(profiles) do
        local row = self:CreateProfileRow(GUI, pageFrame, section.body, contentType, profile, i)
        row:SetPoint("TOPLEFT", 10, y)
        row:SetPoint("TOPRIGHT", -10, y)
        y = y - rowHeight
    end
    
    -- Empty state for mythic
    if contentType.key == "mythic" and numProfiles == 0 then
        local emptyText = section.body:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        emptyText:SetPoint("TOP", 0, -10)
        emptyText:SetText("|cff666666" .. L["No layout set. Using global settings."] .. "|r")
        
        -- Add button for mythic (centered, full width)
        local addBtn = self:CreateAddButton(GUI, pageFrame, section.body, contentType)
        addBtn:SetPoint("TOPLEFT", 10, -32)
        addBtn:SetPoint("TOPRIGHT", -10, -32)
    elseif not contentType.isFixed then
        -- Add Layout button (full width)
        local addBtn = self:CreateAddButton(GUI, pageFrame, section.body, contentType)
        addBtn:SetPoint("TOPLEFT", 10, y - 5)
        addBtn:SetPoint("TOPRIGHT", -10, y - 5)
    end
    
    section:SetHeight(section.totalHeight)
    return section
end

-- Create a profile row
function AutoProfilesUI:CreateProfileRow(GUI, pageFrame, parent, contentType, profile, index)
    local self = AutoProfilesUI
    
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetHeight(28)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    row:SetBackdropColor(0.08, 0.08, 0.08, 1)
    
    -- Profile name
    local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    nameText:SetPoint("LEFT", 10, 0)
    nameText:SetText(profile.name or L["Unnamed"])
    nameText:SetWidth(100)
    nameText:SetJustifyH("LEFT")
    
    -- Range badge
    local rangeBadge = CreateFrame("Button", nil, row, "BackdropTemplate")
    rangeBadge:SetSize(65, 18)
    rangeBadge:SetPoint("LEFT", 115, 0)
    rangeBadge:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    rangeBadge:SetBackdropColor(0.18, 0.18, 0.18, 1)
    rangeBadge:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local rangeText = rangeBadge:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    rangeText:SetPoint("CENTER")
    
    if contentType.isFixed then
        rangeText:SetText(L["20 players (fixed)"])
        rangeText:SetTextColor(0.5, 0.5, 0.5)
    else
        rangeText:SetText((profile.min or 1) .. " - " .. (profile.max or 40))
        rangeText:SetTextColor(0.7, 0.7, 0.7)
        
        -- Make clickable for editing range
        rangeBadge:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.5, 0.2, 1)
            rangeText:SetTextColor(1, 1, 1)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Click to edit range"])
            GameTooltip:Show()
        end)
        rangeBadge:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            rangeText:SetTextColor(0.7, 0.7, 0.7)
            GameTooltip:Hide()
        end)
        rangeBadge:SetScript("OnClick", function()
            -- Show edit range dialog
            AutoProfilesUI:ShowProfileDialog(contentType, profile, index, pageFrame)
        end)
    end
    
    -- Override count (only mapped keys — "Other" overrides show in tooltip but don't inflate the badge)
    local overrideCount = 0
    if profile.overrides then
        for key in pairs(profile.overrides) do
            if GetOverrideTabId(key) then
                overrideCount = overrideCount + 1
            end
        end
    end
    
    local overrideText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    overrideText:SetPoint("LEFT", 190, 0)
    if overrideCount > 0 then
        overrideText:SetText("|cffffaa00*|r " .. format(overrideCount > 1 and L["%d overrides"] or L["%d override"], overrideCount))
        overrideText:SetTextColor(1, 0.67, 0)
    else
        overrideText:SetText("")
    end
    overrideText:SetWidth(80)
    overrideText:SetJustifyH("LEFT")

    -- Hoverable overlay on override count to show tooltip with details
    if overrideCount > 0 then
        local overrideBtn = CreateFrame("Button", nil, row)
        overrideBtn:SetPoint("LEFT", overrideText, "LEFT", -4, 0)
        overrideBtn:SetSize(88, 22)

        overrideBtn:SetScript("OnEnter", function(self)
            overrideText:SetTextColor(1, 0.8, 0.2)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Override Details"], 1, 0.67, 0)
            GameTooltip:AddLine(" ")

            local groups, unknownKeys = GroupOverridesByTab(profile.overrides)
            local tabOrder = {}
            for tabId in pairs(groups) do tinsert(tabOrder, tabId) end
            table.sort(tabOrder)

            for _, tabId in ipairs(tabOrder) do
                local group = groups[tabId]
                GameTooltip:AddLine(group.tabLabel .. " (" .. #group.keys .. ")", 1, 0.67, 0)
                table.sort(group.keys)
                for _, key in ipairs(group.keys) do
                    local value = profile.overrides[key]
                    local displayVal
                    if type(value) == "boolean" then
                        displayVal = value and "true" or "false"
                    elseif type(value) == "table" then
                        if value.r then
                            displayVal = string.format("(%.1f, %.1f, %.1f)", value.r, value.g, value.b)
                        else
                            displayVal = "{table}"
                        end
                    else
                        displayVal = tostring(value)
                    end
                    GameTooltip:AddDoubleLine("  " .. key, displayVal, 0.8, 0.8, 0.8, 1, 1, 1)
                end
            end

            if #unknownKeys > 0 then
                GameTooltip:AddLine(format(L["Other (%d)"], #unknownKeys), 0.5, 0.5, 0.5)
                table.sort(unknownKeys)
                for _, key in ipairs(unknownKeys) do
                    GameTooltip:AddDoubleLine("  " .. key, tostring(profile.overrides[key]), 0.5, 0.5, 0.5, 0.7, 0.7, 0.7)
                end
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Use /df overrides for full details in chat"], 0.4, 0.4, 0.4)
            GameTooltip:Show()
        end)

        overrideBtn:SetScript("OnLeave", function()
            overrideText:SetTextColor(1, 0.67, 0)
            GameTooltip:Hide()
        end)
    end

    -- Copy To button
    local copyBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
    copyBtn:SetSize(55, 20)
    copyBtn:SetPoint("RIGHT", -120, 0)
    copyBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    copyBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    copyBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local copyText = copyBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    copyText:SetPoint("CENTER")
    copyText:SetText(L["Copy To"])
    copyText:SetTextColor(1, 0.5, 0.2)

    copyBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.15, 0.1, 1)
        self:SetBackdropBorderColor(1, 0.5, 0.2, 1)
    end)
    copyBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)
    copyBtn:SetScript("OnClick", function()
        AutoProfilesUI:ShowCopyDialog(contentType, profile, index, pageFrame)
    end)

    -- Edit Settings button
    local editBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
    editBtn:SetSize(75, 20)
    editBtn:SetPoint("RIGHT", -40, 0)
    editBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    editBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    editBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    local editText = editBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    editText:SetPoint("CENTER")
    editText:SetText(L["Edit Settings"])
    editText:SetTextColor(1, 0.5, 0.2)
    
    editBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.15, 0.1, 1)
        self:SetBackdropBorderColor(1, 0.5, 0.2, 1)
    end)
    editBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)
    editBtn:SetScript("OnClick", function()
        AutoProfilesUI:EnterEditing(contentType.key, index)
    end)

    -- Grey out edit button if a different runtime profile is active
    if self.activeRuntimeProfile and self.activeRuntimeProfile ~= profile then
        editText:SetTextColor(0.3, 0.3, 0.3)
        editBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        editBtn:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
        editBtn:SetScript("OnEnter", function(btn)
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Cannot Edit"], 1, 0.3, 0.3)
            GameTooltip:AddLine(L["Only the active layout can be edited\nwhile auto layouts are running."], 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        editBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        editBtn:SetScript("OnClick", function() end)
    end

    -- Delete button
    local deleteBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
    deleteBtn:SetSize(22, 20)
    deleteBtn:SetPoint("RIGHT", -10, 0)
    deleteBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    deleteBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    deleteBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    local deleteIcon = deleteBtn:CreateTexture(nil, "OVERLAY")
    deleteIcon:SetPoint("CENTER")
    deleteIcon:SetSize(12, 12)
    deleteIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\delete")
    deleteIcon:SetVertexColor(0.6, 0.6, 0.6)
    
    deleteBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.1, 0.1, 1)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
        deleteIcon:SetVertexColor(1, 0.3, 0.3)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Delete Layout"])
        GameTooltip:Show()
    end)
    deleteBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        deleteIcon:SetVertexColor(0.6, 0.6, 0.6)
        GameTooltip:Hide()
    end)
    deleteBtn:SetScript("OnClick", function()
        -- Confirm deletion
        StaticPopupDialogs["DANDERSFRAMES_DELETE_AUTOPROFILE"] = {
            text = format(L["Delete layout \"%s\"?"], profile.name),
            button1 = L["Delete"],
            button2 = L["Cancel"],
            OnAccept = function()
                AutoProfilesUI:DeleteProfile(contentType.key, index)
                if pageFrame.Refresh then pageFrame:Refresh() end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("DANDERSFRAMES_DELETE_AUTOPROFILE")
    end)
    
    return row
end

-- Create Add Layout button
function AutoProfilesUI:CreateAddButton(GUI, pageFrame, parent, contentType)
    local self = AutoProfilesUI
    
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetHeight(24)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(0.08, 0.08, 0.08, 0)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
    
    -- Centered text
    local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnText:SetPoint("CENTER", 0, 0)
    btnText:SetText(L["+ Add Layout"])
    btnText:SetTextColor(0.5, 0.5, 0.5)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.5, 0.2, 1)
        btnText:SetTextColor(1, 0.5, 0.2)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        btnText:SetTextColor(0.5, 0.5, 0.5)
    end)
    btn:SetScript("OnClick", function()
        if contentType.key == "mythic" then
            -- Just create the mythic profile directly
            AutoProfilesUI:CreateProfile("mythic", "Mythic Setup")
            if pageFrame.Refresh then pageFrame:Refresh() end
        else
            -- Show add layout dialog
            AutoProfilesUI:ShowProfileDialog(contentType, nil, nil, pageFrame)
        end
    end)
    
    return btn
end

-- ============================================================
-- PROFILE DIALOG (Add/Edit)
-- Anchored to main GUI frame center, no overlay
-- ============================================================

local profileDialog = nil

function AutoProfilesUI:CreateProfileDialog()
    if profileDialog then return profileDialog end
    
    -- Dialog frame - parented to UIParent like click casting does
    local dialog = CreateFrame("Frame", "DandersAutoProfileDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(360, 240)
    dialog:SetPoint("CENTER", DF.GUIFrame or UIParent, "CENTER", 0, 0)
    dialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dialog:SetBackdropColor(0.06, 0.06, 0.06, 0.98)
    dialog:SetBackdropBorderColor(0, 0, 0, 1)
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetFrameLevel(100)
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()
    
    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetTextColor(0.9, 0.9, 0.9)
    dialog.title = title
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    closeBtn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetSize(12, 12)
    closeIcon:SetPoint("CENTER")
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(0.5, 0.5, 0.5)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
        closeIcon:SetVertexColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        closeIcon:SetVertexColor(0.5, 0.5, 0.5)
    end)
    closeBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- =============================================
    -- Profile Name Section
    -- =============================================
    local nameLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    nameLabel:SetPoint("TOPLEFT", 12, -40)
    nameLabel:SetText(L["Layout Name"])
    nameLabel:SetTextColor(0.6, 0.6, 0.6)
    dialog.nameLabel = nameLabel

    local nameInput = CreateFrame("EditBox", nil, dialog, "BackdropTemplate")
    nameInput:SetSize(336, 26)
    nameInput:SetPoint("TOPLEFT", 12, -56)
    nameInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    nameInput:SetBackdropColor(0.03, 0.03, 0.03, 1)
    nameInput:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    nameInput:SetFontObject("DFFontHighlight")
    nameInput:SetTextInsets(8, 8, 0, 0)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(30)
    nameInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    nameInput:SetScript("OnTextChanged", function(self)
        AutoProfilesUI:ValidateDialog()
    end)
    dialog.nameInput = nameInput
    
    -- =============================================
    -- Range Section with Dual-Handle Slider
    -- =============================================
    local rangeLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    rangeLabel:SetPoint("TOPLEFT", 12, -92)
    rangeLabel:SetText(L["Player Range"])
    rangeLabel:SetTextColor(0.6, 0.6, 0.6)
    dialog.rangeLabel = rangeLabel

    -- Range display
    local rangeDisplay = dialog:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    rangeDisplay:SetPoint("TOPRIGHT", -12, -92)
    rangeDisplay:SetTextColor(1, 0.5, 0.2)
    dialog.rangeDisplay = rangeDisplay
    
    -- Slider track (thinner)
    local sliderWidth = 336
    local sliderTrack = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    sliderTrack:SetSize(sliderWidth, 12)
    sliderTrack:SetPoint("TOPLEFT", 12, -112)
    sliderTrack:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sliderTrack:SetBackdropColor(0.03, 0.03, 0.03, 1)
    sliderTrack:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    dialog.sliderTrack = sliderTrack
    
    -- Range fill (between handles)
    local rangeFill = sliderTrack:CreateTexture(nil, "ARTWORK")
    rangeFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    rangeFill:SetVertexColor(1, 0.5, 0.2, 0.5)
    rangeFill:SetHeight(10)
    rangeFill:SetPoint("TOP", 0, -1)
    dialog.rangeFill = rangeFill
    
    -- Helper to calculate position from value
    local function ValueToPos(value, minRange, maxRange)
        local pct = (value - minRange) / (maxRange - minRange)
        return pct * (sliderWidth - 4) + 2
    end
    
    -- Helper to calculate value from position
    local function PosToValue(pos, minRange, maxRange)
        local pct = (pos - 2) / (sliderWidth - 4)
        return math.floor(pct * (maxRange - minRange) + minRange + 0.5)
    end
    
    -- Handle dragging state
    local dragging = nil
    
    -- Min handle (thinner, more elegant)
    local minHandle = CreateFrame("Button", nil, sliderTrack)
    minHandle:SetSize(8, 16)
    minHandle:SetPoint("CENTER", sliderTrack, "LEFT", 2, 0)
    minHandle:EnableMouse(true)
    local minHandleTex = minHandle:CreateTexture(nil, "OVERLAY")
    minHandleTex:SetAllPoints()
    minHandleTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    minHandleTex:SetVertexColor(1, 0.5, 0.2, 1)
    dialog.minHandle = minHandle
    
    -- Max handle
    local maxHandle = CreateFrame("Button", nil, sliderTrack)
    maxHandle:SetSize(8, 16)
    maxHandle:SetPoint("CENTER", sliderTrack, "LEFT", sliderWidth - 2, 0)
    maxHandle:EnableMouse(true)
    local maxHandleTex = maxHandle:CreateTexture(nil, "OVERLAY")
    maxHandleTex:SetAllPoints()
    maxHandleTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    maxHandleTex:SetVertexColor(1, 0.5, 0.2, 1)
    dialog.maxHandle = maxHandle
    
    local function UpdateSliderVisuals()
        local contentType = dialog.contentType
        if not contentType then return end
        
        local minVal = dialog.currentMin or contentType.minRange
        local maxVal = dialog.currentMax or contentType.maxRange
        local minRange = contentType.minRange
        local maxRange = contentType.maxRange
        
        local minPos = ValueToPos(minVal, minRange, maxRange)
        local maxPos = ValueToPos(maxVal, minRange, maxRange)
        
        minHandle:ClearAllPoints()
        minHandle:SetPoint("CENTER", sliderTrack, "LEFT", minPos, 0)
        maxHandle:ClearAllPoints()
        maxHandle:SetPoint("CENTER", sliderTrack, "LEFT", maxPos, 0)
        
        -- Update fill
        rangeFill:ClearAllPoints()
        rangeFill:SetPoint("LEFT", sliderTrack, "LEFT", minPos, 0)
        rangeFill:SetWidth(math.max(maxPos - minPos, 2))
        
        -- Update display
        if minVal == maxVal then
            rangeDisplay:SetText(format(L["%d players"], minVal))
        else
            rangeDisplay:SetText(format(L["%d - %d players"], minVal, maxVal))
        end

        AutoProfilesUI:ValidateDialog()
    end
    dialog.UpdateSliderVisuals = UpdateSliderVisuals
    
    -- Use OnMouseDown/OnMouseUp for more responsive dragging
    minHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            dragging = "min"
        end
    end)
    
    maxHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            dragging = "max"
        end
    end)
    
    minHandle:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and dragging == "min" then
            dragging = nil
        end
    end)
    
    maxHandle:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and dragging == "max" then
            dragging = nil
        end
    end)
    
    -- Global mouse up to catch releases outside handles
    dialog:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            dragging = nil
        end
    end)
    
    -- OnUpdate on the dialog itself for smoother tracking
    dialog:SetScript("OnUpdate", function(self)
        if not dragging then return end
        
        local contentType = dialog.contentType
        if not contentType then return end
        
        local x = select(1, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local trackLeft = sliderTrack:GetLeft()
        if not trackLeft then return end
        
        local pos = x - trackLeft
        pos = math.max(2, math.min(pos, sliderWidth - 2))
        
        local value = PosToValue(pos, contentType.minRange, contentType.maxRange)
        value = math.max(contentType.minRange, math.min(value, contentType.maxRange))
        
        if dragging == "min" then
            if value <= dialog.currentMax then
                dialog.currentMin = value
            end
        elseif dragging == "max" then
            if value >= dialog.currentMin then
                dialog.currentMax = value
            end
        end
        
        UpdateSliderVisuals()
    end)
    
    -- Click on track to move nearest handle
    sliderTrack:EnableMouse(true)
    sliderTrack:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        
        local contentType = dialog.contentType
        if not contentType then return end
        
        local x = select(1, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local trackLeft = sliderTrack:GetLeft()
        local pos = x - trackLeft
        local value = PosToValue(pos, contentType.minRange, contentType.maxRange)
        
        -- Move closest handle
        local minDist = math.abs(value - dialog.currentMin)
        local maxDist = math.abs(value - dialog.currentMax)
        
        if minDist <= maxDist then
            if value <= dialog.currentMax then
                dialog.currentMin = value
            end
        else
            if value >= dialog.currentMin then
                dialog.currentMax = value
            end
        end
        
        UpdateSliderVisuals()
    end)
    
    -- Scale labels
    local scaleLabels = {1, 10, 20, 30, 40}
    for _, num in ipairs(scaleLabels) do
        local label = sliderTrack:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        label:SetText(num)
        label:SetTextColor(0.35, 0.35, 0.35)
        local xPos = ValueToPos(num, 1, 40)
        label:SetPoint("TOP", sliderTrack, "BOTTOM", xPos - sliderWidth/2, -2)
    end
    
    -- =============================================
    -- Validation Message
    -- =============================================
    local validationIcon = dialog:CreateTexture(nil, "OVERLAY")
    validationIcon:SetSize(14, 14)
    validationIcon:SetPoint("TOPLEFT", 12, -152)
    dialog.validationIcon = validationIcon
    
    local validationMsg = dialog:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    validationMsg:SetPoint("LEFT", validationIcon, "RIGHT", 6, 0)
    validationMsg:SetWidth(310)
    validationMsg:SetJustifyH("LEFT")
    dialog.validationMsg = validationMsg
    
    -- =============================================
    -- Buttons
    -- =============================================
    local cancelBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 26)
    cancelBtn:SetPoint("BOTTOMLEFT", 12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    cancelBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(0.6, 0.6, 0.6)

    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        cancelText:SetTextColor(0.9, 0.9, 0.9)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        cancelText:SetTextColor(0.6, 0.6, 0.6)
    end)
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)

    local createBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    createBtn:SetSize(100, 26)
    createBtn:SetPoint("BOTTOMRIGHT", -12, 12)
    createBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    createBtn:SetBackdropColor(0.15, 0.08, 0.03, 1)
    createBtn:SetBackdropBorderColor(1, 0.5, 0.2, 1)

    local createText = createBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    createText:SetPoint("CENTER")
    createText:SetText(L["Create Layout"])
    createText:SetTextColor(1, 0.5, 0.2)
    dialog.createBtnText = createText

    createBtn:SetScript("OnEnter", function(self)
        if self.enabled then
            self:SetBackdropColor(0.22, 0.12, 0.05, 1)
        end
    end)
    createBtn:SetScript("OnLeave", function(self)
        if self.enabled then
            self:SetBackdropColor(0.15, 0.08, 0.03, 1)
        end
    end)
    createBtn:SetScript("OnClick", function(self)
        if self.enabled then
            AutoProfilesUI:SubmitDialog()
        end
    end)
    dialog.createBtn = createBtn

    profileDialog = dialog
    return dialog
end

function AutoProfilesUI:ShowProfileDialog(contentType, profile, profileIndex, pageFrame)
    local dialog = self:CreateProfileDialog()
    
    -- Re-anchor to GUI frame if it exists now
    if DF.GUIFrame then
        dialog:ClearAllPoints()
        dialog:SetPoint("CENTER", DF.GUIFrame, "CENTER", 0, 0)
    end
    
    -- Store context
    dialog.contentType = contentType
    dialog.profile = profile
    dialog.profileIndex = profileIndex
    dialog.pageFrame = pageFrame
    dialog.isEditMode = (profile ~= nil)
    
    -- Set title
    if dialog.isEditMode then
        dialog.title:SetText(L["Edit Layout Range"])
        dialog.createBtnText:SetText(L["Save Changes"])
        dialog.nameLabel:Hide()
        dialog.nameInput:Hide()
        -- Shift elements up (52px offset from hidden name section)
        dialog.rangeLabel:ClearAllPoints()
        dialog.rangeLabel:SetPoint("TOPLEFT", 12, -40)
        dialog.sliderTrack:ClearAllPoints()
        dialog.sliderTrack:SetPoint("TOPLEFT", 12, -60)
        dialog.validationIcon:ClearAllPoints()
        dialog.validationIcon:SetPoint("TOPLEFT", 12, -100)
        dialog:SetHeight(175)
    else
        dialog.title:SetText(L["Add Layout"])
        dialog.createBtnText:SetText(L["Create Layout"])
        dialog.nameLabel:Show()
        dialog.nameInput:Show()
        -- Reset positions to default
        dialog.rangeLabel:ClearAllPoints()
        dialog.rangeLabel:SetPoint("TOPLEFT", 12, -92)
        dialog.sliderTrack:ClearAllPoints()
        dialog.sliderTrack:SetPoint("TOPLEFT", 12, -112)
        dialog.validationIcon:ClearAllPoints()
        dialog.validationIcon:SetPoint("TOPLEFT", 12, -152)
        dialog:SetHeight(220)
    end
    
    -- Set initial values
    if dialog.isEditMode then
        dialog.nameInput:SetText(profile.name or "")
        dialog.currentMin = profile.min or contentType.minRange
        dialog.currentMax = profile.max or contentType.maxRange
    else
        dialog.nameInput:SetText("")
        local existingProfiles = self:GetProfiles(contentType.key)
        dialog.currentMin, dialog.currentMax = self:SuggestRange(contentType, existingProfiles)
    end
    
    -- Update visuals and show
    dialog.UpdateSliderVisuals()
    self:ValidateDialog()
    dialog:Show()
    
    if not dialog.isEditMode then
        dialog.nameInput:SetFocus()
    end
end

function AutoProfilesUI:SuggestRange(contentType, existingProfiles)
    if #existingProfiles == 0 then
        return 1, 20
    end
    
    local sorted = {}
    for _, p in ipairs(existingProfiles) do
        table.insert(sorted, {min = p.min, max = p.max})
    end
    table.sort(sorted, function(a, b) return a.min < b.min end)
    
    if sorted[1].min > contentType.minRange then
        return contentType.minRange, sorted[1].min - 1
    end
    
    for i = 1, #sorted - 1 do
        if sorted[i].max + 1 < sorted[i + 1].min then
            return sorted[i].max + 1, sorted[i + 1].min - 1
        end
    end
    
    if sorted[#sorted].max < contentType.maxRange then
        return sorted[#sorted].max + 1, contentType.maxRange
    end
    
    return contentType.minRange, contentType.maxRange
end

function AutoProfilesUI:ValidateDialog()
    local dialog = profileDialog
    if not dialog or not dialog:IsShown() then return false end
    
    local contentType = dialog.contentType
    local isValid = true
    local errorMsg = nil
    
    local name = strtrim(dialog.nameInput:GetText() or "")
    local minVal = dialog.currentMin or 1
    local maxVal = dialog.currentMax or 40
    
    -- Validate name (only for new profiles)
    if not dialog.isEditMode then
        if name == "" then
            isValid = false
            errorMsg = L["Enter a profile name"]
        else
            local profiles = self:GetProfiles(contentType.key)
            for _, p in ipairs(profiles) do
                if p.name:lower() == name:lower() then
                    isValid = false
                    errorMsg = L["A profile with this name already exists"]
                    break
                end
            end
        end
    end

    -- Validate range
    if isValid then
        local excludeIndex = dialog.isEditMode and dialog.profileIndex or nil
        local overlap = self:CheckRangeOverlap(contentType.key, minVal, maxVal, excludeIndex)
        if overlap then
            isValid = false
            errorMsg = format(L["Overlaps with \"%s\" (%d-%d)"], overlap.name, overlap.min, overlap.max)
        end
    end

    -- Update validation display
    if isValid then
        dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
        dialog.validationIcon:SetVertexColor(0.3, 0.85, 0.3)
        dialog.validationMsg:SetText(L["Valid range"])
        dialog.validationMsg:SetTextColor(0.3, 0.85, 0.3)
    elseif errorMsg then
        dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
        dialog.validationIcon:SetVertexColor(0.85, 0.3, 0.3)
        dialog.validationMsg:SetText(errorMsg)
        dialog.validationMsg:SetTextColor(0.85, 0.3, 0.3)
    else
        dialog.validationIcon:SetTexture(nil)
        dialog.validationMsg:SetText("")
    end
    
    -- Update button state
    local btn = dialog.createBtn
    btn.enabled = isValid
    if isValid then
        btn:SetBackdropColor(0.15, 0.08, 0.03, 1)
        btn:SetBackdropBorderColor(1, 0.5, 0.2, 1)
        dialog.createBtnText:SetTextColor(1, 0.5, 0.2)
    else
        btn:SetBackdropColor(0.06, 0.06, 0.06, 1)
        btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        dialog.createBtnText:SetTextColor(0.3, 0.3, 0.3)
    end
    
    return isValid
end

function AutoProfilesUI:SubmitDialog()
    local dialog = profileDialog
    if not dialog then return end
    
    local name = strtrim(dialog.nameInput:GetText() or "")
    local minVal = dialog.currentMin
    local maxVal = dialog.currentMax
    local contentType = dialog.contentType
    
    local success, err
    if dialog.isEditMode then
        success, err = self:UpdateProfileRange(contentType.key, dialog.profileIndex, minVal, maxVal)
    else
        success, err = self:CreateProfile(contentType.key, name, minVal, maxVal)
    end
    
    if success then
        dialog:Hide()
        if dialog.pageFrame and dialog.pageFrame.Refresh then
            dialog.pageFrame:Refresh()
        end
        -- Re-evaluate which profile should be active after range change
        self:EvaluateAndApply()
    else
        dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
        dialog.validationIcon:SetVertexColor(0.85, 0.3, 0.3)
        dialog.validationMsg:SetText(err or L["Unknown error"])
        dialog.validationMsg:SetTextColor(0.85, 0.3, 0.3)
    end
end

-- ============================================================
-- COPY TO DIALOG
-- ============================================================

local copyDialog = nil

function AutoProfilesUI:CreateCopyDialog()
    if copyDialog then return copyDialog end

    local dialog = CreateFrame("Frame", "DandersAutoProfileCopyDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(360, 280)
    dialog:SetPoint("CENTER", DF.GUIFrame or UIParent, "CENTER", 0, 0)
    dialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dialog:SetBackdropColor(0.06, 0.06, 0.06, 0.98)
    dialog:SetBackdropBorderColor(0, 0, 0, 1)
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetFrameLevel(100)
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()

    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(L["Copy Layout"])
    title:SetTextColor(0.9, 0.9, 0.9)
    dialog.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    closeBtn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetSize(12, 12)
    closeIcon:SetPoint("CENTER")
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(0.5, 0.5, 0.5)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
        closeIcon:SetVertexColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        closeIcon:SetVertexColor(0.5, 0.5, 0.5)
    end)
    closeBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)

    -- =============================================
    -- Layout Name Section
    -- =============================================
    local nameLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    nameLabel:SetPoint("TOPLEFT", 12, -40)
    nameLabel:SetText(L["Layout Name"])
    nameLabel:SetTextColor(0.6, 0.6, 0.6)

    local nameInput = CreateFrame("EditBox", nil, dialog, "BackdropTemplate")
    nameInput:SetSize(336, 26)
    nameInput:SetPoint("TOPLEFT", 12, -56)
    nameInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    nameInput:SetBackdropColor(0.03, 0.03, 0.03, 1)
    nameInput:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    nameInput:SetFontObject("DFFontHighlight")
    nameInput:SetTextInsets(8, 8, 0, 0)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(30)
    nameInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    nameInput:SetScript("OnTextChanged", function()
        AutoProfilesUI:ValidateCopyDialog()
    end)
    dialog.nameInput = nameInput

    -- =============================================
    -- Destination Selector (radio-style buttons)
    -- =============================================
    local destLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    destLabel:SetPoint("TOPLEFT", 12, -92)
    destLabel:SetText(L["Copy To"])
    destLabel:SetTextColor(0.6, 0.6, 0.6)

    local destButtons = {}
    local buttonWidth = 106
    local buttonSpacing = 6
    local startX = 12

    for i, ct in ipairs(CONTENT_TYPES) do
        local btn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
        btn:SetSize(buttonWidth, 24)
        btn:SetPoint("TOPLEFT", startX + (i - 1) * (buttonWidth + buttonSpacing), -108)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(0.1, 0.1, 0.1, 1)
        btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(ct.title)
        btnText:SetTextColor(0.6, 0.6, 0.6)

        btn.contentType = ct
        btn.label = btnText

        btn:SetScript("OnClick", function(self)
            dialog.selectedDest = self.contentType.key
            AutoProfilesUI:UpdateCopyDestButtons()
            AutoProfilesUI:UpdateCopyRangeVisibility()
            AutoProfilesUI:ValidateCopyDialog()
        end)

        btn:SetScript("OnEnter", function(self)
            if dialog.selectedDest ~= self.contentType.key then
                self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
                self.label:SetTextColor(0.8, 0.8, 0.8)
            end
            -- Show warning if mythic already has a profile
            if self.contentType.key == "mythic" then
                local mythicProfile = DF.db.raidAutoProfiles.mythic.profile
                if mythicProfile then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L["Will replace existing Mythic layout"], 1, 0.67, 0)
                    GameTooltip:AddLine(format(L["\"%s\" will be overwritten."], mythicProfile.name), 0.7, 0.7, 0.7, true)
                    GameTooltip:Show()
                end
            end
        end)

        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if dialog.selectedDest ~= self.contentType.key then
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self.label:SetTextColor(0.6, 0.6, 0.6)
            end
        end)

        destButtons[i] = btn
    end
    dialog.destButtons = destButtons

    -- =============================================
    -- Range Section (dual-handle slider, same as profile dialog)
    -- =============================================
    local rangeLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    rangeLabel:SetPoint("TOPLEFT", 12, -144)
    rangeLabel:SetText(L["Player Range"])
    rangeLabel:SetTextColor(0.6, 0.6, 0.6)
    dialog.rangeLabel = rangeLabel

    local rangeDisplay = dialog:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    rangeDisplay:SetPoint("TOPRIGHT", -12, -144)
    rangeDisplay:SetTextColor(1, 0.5, 0.2)
    dialog.rangeDisplay = rangeDisplay

    local sliderWidth = 336
    local sliderTrack = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    sliderTrack:SetSize(sliderWidth, 12)
    sliderTrack:SetPoint("TOPLEFT", 12, -164)
    sliderTrack:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sliderTrack:SetBackdropColor(0.03, 0.03, 0.03, 1)
    sliderTrack:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    dialog.sliderTrack = sliderTrack

    local rangeFill = sliderTrack:CreateTexture(nil, "ARTWORK")
    rangeFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    rangeFill:SetVertexColor(1, 0.5, 0.2, 0.5)
    rangeFill:SetHeight(10)
    rangeFill:SetPoint("TOP", 0, -1)
    dialog.rangeFill = rangeFill

    local function CopyValueToPos(value)
        local pct = (value - 1) / (40 - 1)
        return pct * (sliderWidth - 4) + 2
    end

    local function CopyPosToValue(pos)
        local pct = (pos - 2) / (sliderWidth - 4)
        return math.floor(pct * (40 - 1) + 1 + 0.5)
    end

    local dragging = nil

    local minHandle = CreateFrame("Button", nil, sliderTrack)
    minHandle:SetSize(8, 16)
    minHandle:SetPoint("CENTER", sliderTrack, "LEFT", 2, 0)
    minHandle:EnableMouse(true)
    local minHandleTex = minHandle:CreateTexture(nil, "OVERLAY")
    minHandleTex:SetAllPoints()
    minHandleTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    minHandleTex:SetVertexColor(1, 0.5, 0.2, 1)
    dialog.minHandle = minHandle

    local maxHandle = CreateFrame("Button", nil, sliderTrack)
    maxHandle:SetSize(8, 16)
    maxHandle:SetPoint("CENTER", sliderTrack, "LEFT", sliderWidth - 2, 0)
    maxHandle:EnableMouse(true)
    local maxHandleTex = maxHandle:CreateTexture(nil, "OVERLAY")
    maxHandleTex:SetAllPoints()
    maxHandleTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    maxHandleTex:SetVertexColor(1, 0.5, 0.2, 1)
    dialog.maxHandle = maxHandle

    local function UpdateCopySliderVisuals()
        local minVal = dialog.currentMin or 1
        local maxVal = dialog.currentMax or 40

        local minPos = CopyValueToPos(minVal)
        local maxPos = CopyValueToPos(maxVal)

        minHandle:ClearAllPoints()
        minHandle:SetPoint("CENTER", sliderTrack, "LEFT", minPos, 0)
        maxHandle:ClearAllPoints()
        maxHandle:SetPoint("CENTER", sliderTrack, "LEFT", maxPos, 0)

        rangeFill:ClearAllPoints()
        rangeFill:SetPoint("LEFT", sliderTrack, "LEFT", minPos, 0)
        rangeFill:SetWidth(math.max(maxPos - minPos, 2))

        if minVal == maxVal then
            rangeDisplay:SetText(format(L["%d players"], minVal))
        else
            rangeDisplay:SetText(format(L["%d - %d players"], minVal, maxVal))
        end

        AutoProfilesUI:ValidateCopyDialog()
    end
    dialog.UpdateSliderVisuals = UpdateCopySliderVisuals

    minHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then dragging = "min" end
    end)
    maxHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then dragging = "max" end
    end)
    minHandle:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and dragging == "min" then dragging = nil end
    end)
    maxHandle:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and dragging == "max" then dragging = nil end
    end)

    dialog:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then dragging = nil end
    end)

    dialog:SetScript("OnUpdate", function(self)
        if not dragging then return end

        local x = select(1, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local trackLeft = sliderTrack:GetLeft()
        if not trackLeft then return end

        local pos = x - trackLeft
        pos = math.max(2, math.min(pos, sliderWidth - 2))

        local value = CopyPosToValue(pos)
        value = math.max(1, math.min(value, 40))

        if dragging == "min" then
            if value <= dialog.currentMax then
                dialog.currentMin = value
            end
        elseif dragging == "max" then
            if value >= dialog.currentMin then
                dialog.currentMax = value
            end
        end

        UpdateCopySliderVisuals()
    end)

    sliderTrack:EnableMouse(true)
    sliderTrack:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end

        local x = select(1, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local trackLeft = sliderTrack:GetLeft()
        local pos = x - trackLeft
        local value = CopyPosToValue(pos)

        local minDist = math.abs(value - dialog.currentMin)
        local maxDist = math.abs(value - dialog.currentMax)

        if minDist <= maxDist then
            if value <= dialog.currentMax then
                dialog.currentMin = value
            end
        else
            if value >= dialog.currentMin then
                dialog.currentMax = value
            end
        end

        UpdateCopySliderVisuals()
    end)

    -- Scale labels
    local scaleLabels = {1, 10, 20, 30, 40}
    for _, num in ipairs(scaleLabels) do
        local label = sliderTrack:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        label:SetText(num)
        label:SetTextColor(0.35, 0.35, 0.35)
        local xPos = CopyValueToPos(num)
        label:SetPoint("TOP", sliderTrack, "BOTTOM", xPos - sliderWidth/2, -2)
    end

    -- Mythic fixed label (shown when mythic is selected destination)
    local mythicFixedLabel = dialog:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    mythicFixedLabel:SetPoint("TOPLEFT", 12, -155)
    mythicFixedLabel:SetText(L["Fixed at 20 players (Mythic)"])
    mythicFixedLabel:SetTextColor(0.5, 0.5, 0.5)
    mythicFixedLabel:Hide()
    dialog.mythicFixedLabel = mythicFixedLabel

    -- =============================================
    -- Validation Message
    -- =============================================
    local validationIcon = dialog:CreateTexture(nil, "OVERLAY")
    validationIcon:SetSize(14, 14)
    validationIcon:SetPoint("TOPLEFT", 12, -200)
    dialog.validationIcon = validationIcon

    local validationMsg = dialog:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    validationMsg:SetPoint("LEFT", validationIcon, "RIGHT", 6, 0)
    validationMsg:SetWidth(310)
    validationMsg:SetJustifyH("LEFT")
    dialog.validationMsg = validationMsg

    -- =============================================
    -- Buttons
    -- =============================================
    local cancelBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 26)
    cancelBtn:SetPoint("BOTTOMLEFT", 12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    cancelBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(0.6, 0.6, 0.6)

    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        cancelText:SetTextColor(0.9, 0.9, 0.9)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        cancelText:SetTextColor(0.6, 0.6, 0.6)
    end)
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)

    local createBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    createBtn:SetSize(100, 26)
    createBtn:SetPoint("BOTTOMRIGHT", -12, 12)
    createBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    createBtn:SetBackdropColor(0.15, 0.08, 0.03, 1)
    createBtn:SetBackdropBorderColor(1, 0.5, 0.2, 1)

    local createText = createBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    createText:SetPoint("CENTER")
    createText:SetText(L["Copy Layout"])
    createText:SetTextColor(1, 0.5, 0.2)
    dialog.createBtnText = createText

    createBtn:SetScript("OnEnter", function(self)
        if self.enabled then
            self:SetBackdropColor(0.22, 0.12, 0.05, 1)
        end
    end)
    createBtn:SetScript("OnLeave", function(self)
        if self.enabled then
            self:SetBackdropColor(0.15, 0.08, 0.03, 1)
        end
    end)
    createBtn:SetScript("OnClick", function(self)
        if self.enabled then
            AutoProfilesUI:SubmitCopyDialog()
        end
    end)
    dialog.createBtn = createBtn

    copyDialog = dialog
    return dialog
end

function AutoProfilesUI:UpdateCopyDestButtons()
    local dialog = copyDialog
    if not dialog then return end

    for _, btn in ipairs(dialog.destButtons) do
        local key = btn.contentType.key
        if key == dialog.selectedDest then
            -- Selected
            btn:SetBackdropColor(0.2, 0.1, 0.05, 1)
            btn:SetBackdropBorderColor(1, 0.5, 0.2, 1)
            btn.label:SetTextColor(1, 0.5, 0.2)
        else
            -- Available but not selected
            btn:SetBackdropColor(0.1, 0.1, 0.1, 1)
            btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            btn.label:SetTextColor(0.6, 0.6, 0.6)
        end
    end
end

function AutoProfilesUI:UpdateCopyRangeVisibility()
    local dialog = copyDialog
    if not dialog then return end

    local isMythic = dialog.selectedDest == "mythic"

    if isMythic then
        dialog.rangeLabel:Hide()
        dialog.rangeDisplay:Hide()
        dialog.sliderTrack:Hide()
        dialog.mythicFixedLabel:Show()
        -- Adjust validation and dialog height
        dialog.validationIcon:ClearAllPoints()
        dialog.validationIcon:SetPoint("TOPLEFT", 12, -175)
        dialog:SetHeight(250)
    else
        dialog.rangeLabel:Show()
        dialog.rangeDisplay:Show()
        dialog.sliderTrack:Show()
        dialog.mythicFixedLabel:Hide()
        dialog.validationIcon:ClearAllPoints()
        dialog.validationIcon:SetPoint("TOPLEFT", 12, -200)
        dialog:SetHeight(280)
    end
end

function AutoProfilesUI:ShowCopyDialog(contentType, profile, index, pageFrame)
    local dialog = self:CreateCopyDialog()

    -- Re-anchor to GUI frame if it exists now
    if DF.GUIFrame then
        dialog:ClearAllPoints()
        dialog:SetPoint("CENTER", DF.GUIFrame, "CENTER", 0, 0)
    end

    -- Store context
    dialog.sourceContentType = contentType.key
    dialog.sourceProfile = profile
    dialog.pageFrame = pageFrame

    -- Pre-fill name
    dialog.nameInput:SetText(format(L["%s (Copy)"], profile.name or L["Unnamed"]))

    -- Default destination to the same content type (same-section copy is common)
    dialog.selectedDest = contentType.key

    -- Set initial range from source profile
    if contentType.isFixed then
        dialog.currentMin = 1
        dialog.currentMax = 40
    else
        dialog.currentMin = profile.min or 1
        dialog.currentMax = profile.max or 40
    end

    -- Update UI
    self:UpdateCopyDestButtons()
    self:UpdateCopyRangeVisibility()
    dialog.UpdateSliderVisuals()
    self:ValidateCopyDialog()
    dialog:Show()
    dialog.nameInput:SetFocus()
end

function AutoProfilesUI:ValidateCopyDialog()
    local dialog = copyDialog
    if not dialog or not dialog:IsShown() then return false end

    local isValid = true
    local errorMsg = nil
    local name = strtrim(dialog.nameInput:GetText() or "")
    local destKey = dialog.selectedDest

    if not destKey then
        isValid = false
        errorMsg = L["Select a destination"]
    elseif name == "" then
        isValid = false
        errorMsg = L["Enter a layout name"]
    else
        -- Check name conflict in destination
        local profiles = self:GetProfiles(destKey)
        for _, p in ipairs(profiles) do
            if p.name:lower() == name:lower() then
                if destKey == "mythic" then
                    -- Mythic replaces, so name conflict is a warning not a block
                    break
                end
                isValid = false
                errorMsg = format(L["A layout with this name already exists in %s"], destKey)
                break
            end
        end

        -- Check range overlap (only for non-mythic destinations)
        if isValid and destKey ~= "mythic" then
            local minVal = dialog.currentMin or 1
            local maxVal = dialog.currentMax or 40
            local overlap = self:CheckRangeOverlap(destKey, minVal, maxVal)
            if overlap then
                isValid = false
                errorMsg = format(L["Overlaps with \"%s\" (%d-%d)"], overlap.name, overlap.min, overlap.max)
            end
        end
    end

    -- Update validation display
    if isValid then
        dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
        dialog.validationIcon:SetVertexColor(0.3, 0.85, 0.3)
        if destKey == "mythic" and DF.db.raidAutoProfiles.mythic.profile then
            dialog.validationMsg:SetText(L["Will replace existing Mythic layout"])
            dialog.validationMsg:SetTextColor(1, 0.67, 0)
        else
            dialog.validationMsg:SetText(L["Ready to copy"])
            dialog.validationMsg:SetTextColor(0.3, 0.85, 0.3)
        end
    elseif errorMsg then
        dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
        dialog.validationIcon:SetVertexColor(0.85, 0.3, 0.3)
        dialog.validationMsg:SetText(errorMsg)
        dialog.validationMsg:SetTextColor(0.85, 0.3, 0.3)
    else
        dialog.validationIcon:SetTexture(nil)
        dialog.validationMsg:SetText("")
    end

    -- Update button state
    local btn = dialog.createBtn
    btn.enabled = isValid
    if isValid then
        btn:SetBackdropColor(0.15, 0.08, 0.03, 1)
        btn:SetBackdropBorderColor(1, 0.5, 0.2, 1)
        dialog.createBtnText:SetTextColor(1, 0.5, 0.2)
    else
        btn:SetBackdropColor(0.06, 0.06, 0.06, 1)
        btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        dialog.createBtnText:SetTextColor(0.3, 0.3, 0.3)
    end

    return isValid
end

function AutoProfilesUI:SubmitCopyDialog()
    local dialog = copyDialog
    if not dialog then return end

    local name = strtrim(dialog.nameInput:GetText() or "")
    local destKey = dialog.selectedDest
    local sourceProfile = dialog.sourceProfile

    -- Deep-copy the overrides from the source
    local copiedOverrides = {}
    if sourceProfile.overrides then
        for k, v in pairs(sourceProfile.overrides) do
            copiedOverrides[k] = DeepCopyValue(v)
        end
    end

    if destKey == "mythic" then
        -- Mythic: single profile, just replace
        self:InitDefaults()
        DF.db.raidAutoProfiles.mythic.profile = {
            name = name,
            overrides = copiedOverrides,
        }
    else
        -- Instanced / Open World: use CreateProfile then inject overrides
        local minVal = dialog.currentMin or 1
        local maxVal = dialog.currentMax or 40
        local success, err = self:CreateProfile(destKey, name, minVal, maxVal)
        if not success then
            dialog.validationIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
            dialog.validationIcon:SetVertexColor(0.85, 0.3, 0.3)
            dialog.validationMsg:SetText(err or L["Unknown error"])
            dialog.validationMsg:SetTextColor(0.85, 0.3, 0.3)
            return
        end

        -- Find the newly created profile and inject overrides
        local profiles = DF.db.raidAutoProfiles[destKey].profiles
        for _, p in ipairs(profiles) do
            if p.name == name then
                p.overrides = copiedOverrides
                break
            end
        end
    end

    dialog:Hide()
    if dialog.pageFrame and dialog.pageFrame.Refresh then
        dialog.pageFrame:Refresh()
    end
    self:EvaluateAndApply()
end

-- ============================================================
-- EDIT MODE STATE & FUNCTIONS
-- ============================================================

-- Runtime state (not persisted)
AutoProfilesUI.editingProfile = nil
AutoProfilesUI.editingContentType = nil
AutoProfilesUI.editingProfileIndex = nil
AutoProfilesUI.globalSnapshot = nil  -- Snapshot of true global values during editing

-- Runtime auto-profile state (not persisted — rebuilt on login/reload via events)
AutoProfilesUI.activeRuntimeProfile = nil     -- Currently applied profile reference
AutoProfilesUI.activeRuntimeContentKey = nil  -- "mythic"/"instanced"/"openWorld"
AutoProfilesUI.pendingAutoProfileEval = false -- Queued evaluation during combat

function AutoProfilesUI:IsEditing()
    return self.editingProfile ~= nil
end

function AutoProfilesUI:EnterEditing(contentType, profileIndex)
    DF:Debug("LAYOUT", "EnterEditing: contentType=%s profileIndex=%s", contentType, tostring(profileIndex))

    -- Clear overlay so snapshot captures true globals (no RemoveRuntimeProfile
    -- needed — real table was never mutated)
    if self.activeRuntimeProfile then
        DF:Debug("LAYOUT", "EnterEditing: clearing active runtime overlay before snapshot")
        DF.raidOverrides = nil
        self.activeRuntimeProfile = nil
        self.activeRuntimeContentKey = nil
    end

    local autoDb = DF.db.raidAutoProfiles

    if contentType == "mythic" then
        self.editingProfile = autoDb.mythic.profile
        self.editingProfileIndex = nil
    else
        local profiles = autoDb[contentType] and autoDb[contentType].profiles
        if profiles and profiles[profileIndex] then
            self.editingProfile = profiles[profileIndex]
            self.editingProfileIndex = profileIndex
        else
            DF:DebugWarn("LAYOUT", "EnterEditing: profile not found at index %s", tostring(profileIndex))
            return false, "Profile not found"
        end
    end
    
    self.editingContentType = contentType
    DF:Debug("LAYOUT", "EnterEditing: editing \"%s\" (%s)", self.editingProfile.name or "?", contentType)

    -- Snapshot ALL true global values before anything gets modified
    -- This lets controls freely write to DF._realRaidDB for live preview while
    -- SetProfileSetting/GetGlobalValue always know the original globals
    self.globalSnapshot = {}
    for key, value in pairs(DF._realRaidDB) do
        self.globalSnapshot[key] = DeepCopyValue(value)
    end

    -- Snapshot pinned frames overridable settings (stored as "pinned.N.setting" keys)
    -- Pinned frames live at raid.pinnedFrames
    -- IMPORTANT: Iterate PINNED_OVERRIDABLE keys rather than set keys to ensure
    -- we capture ALL overridable settings, even ones that are nil due to missing migration.
    -- If a key is nil, backfill a default so both the snapshot and set are consistent.
    local PINNED_DEFAULTS = {
        enabled = false, locked = false, showLabel = false,
        growDirection = "HORIZONTAL", unitsPerRow = 5, scale = 1.0,
        horizontalSpacing = 2, verticalSpacing = 2,
        frameAnchor = "START", columnAnchor = "START",
        autoAddTanks = false, autoAddHealers = false, autoAddDPS = false,
        keepOfflinePlayers = true, players = {},
    }
    local pinnedFrames = DF._realRaidDB and DF._realRaidDB.pinnedFrames
    if pinnedFrames and pinnedFrames.sets then
        for setIdx, set in pairs(pinnedFrames.sets) do
            for setting, _ in pairs(PINNED_OVERRIDABLE) do
                local value = set[setting]
                -- Backfill nil values with defaults so snapshot always has a baseline
                if value == nil then
                    value = PINNED_DEFAULTS[setting]
                    set[setting] = DeepCopyValue(value)
                    value = set[setting]
                end
                local snapKey = "pinned." .. setIdx .. "." .. setting
                self.globalSnapshot[snapKey] = DeepCopyValue(value)
            end
        end
    end
    
    -- Persist a lightweight recovery flag so a crash/disconnect during editing
    -- can be detected on next login and contaminated values reset to defaults
    local recoveryKeys = {}
    for key in pairs(self.globalSnapshot) do
        recoveryKeys[#recoveryKeys + 1] = key
    end
    DF.db.raidAutoEditingRecovery = {
        contentType = contentType,
        profileIndex = profileIndex,
        snapshotKeys = recoveryKeys,
    }

    -- Apply existing overrides to db.raid for live preview
    local overrideCount = 0
    if self.editingProfile.overrides then
        for key, value in pairs(self.editingProfile.overrides) do
            SetRaidValue(key, DeepCopyValue(value))
            overrideCount = overrideCount + 1
        end
    end
    DF:Debug("LAYOUT", "EnterEditing: applied %d overrides for live preview", overrideCount)
    
    -- Refresh pinned frames to show overridden settings in live preview
    if DF.PinnedFrames then
        local pf = DF.db.raid and DF.db.raid.pinnedFrames
        for i = 1, 2 do
            local setEnabled = pf and pf.sets and pf.sets[i] and pf.sets[i].enabled
            DF.PinnedFrames:SetEnabled(i, setEnabled or false)
            DF.PinnedFrames:ApplyLayoutSettings(i)
            DF.PinnedFrames:ResizeContainer(i)
            DF.PinnedFrames:UpdateHeaderNameList(i)
        end
    end

    -- Refresh test mode frames so they display override values
    if DF.raidTestMode and DF.RefreshTestFramesWithLayout then
        DF:RefreshTestFramesWithLayout()
    end

    -- Refresh the GUI to show editing banner and disable Auto Profiles tab
    self:RefreshEditingUI()
    
    -- Switch to a settings tab (e.g., Layout/Frame)
    -- Suppress sidebar hint dismissal for this initial SelectTab call
    self.suppressHintDismiss = true
    local GUI = DF.GUI
    if GUI and GUI.SelectTab then
        GUI.SelectTab("general_frame")
    end
    self.suppressHintDismiss = false

    -- Show sidebar onboarding hint (dismissed on first user tab click)
    self:ShowSidebarHint()

    -- Show override stars on tabs that have overridden settings
    self:RefreshTabOverrideStars()

    return true
end

-- Deep-compare two values (recursive for nested tables)
local function DeepCompare(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for k, v in pairs(a) do
        if not DeepCompare(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

function AutoProfilesUI:ExitEditing(skipUIUpdates)
    DF:Debug("LAYOUT", "ExitEditing: profile=\"%s\" skipUIUpdates=%s", self.editingProfile and self.editingProfile.name or "?", tostring(skipUIUpdates))

    -- Diff safety net: before restoring globals, scan live values vs snapshot
    -- to catch any overrides that weren't explicitly tracked by controls
    if self.editingProfile and self.globalSnapshot then
        if not self.editingProfile.overrides then
            self.editingProfile.overrides = {}
        end
        local overrides = self.editingProfile.overrides
        local autoStored, autoCleaned = 0, 0

        for key, snapshotVal in pairs(self.globalSnapshot) do
            local currentVal = GetRaidValue(key)
            local matches = DeepCompare(snapshotVal, currentVal)

            if not matches then
                -- Only deep-copy when override is new or has actually changed
                if overrides[key] == nil or not DeepCompare(overrides[key], currentVal) then
                    overrides[key] = DeepCopyValue(currentVal)
                    autoStored = autoStored + 1
                end
            elseif matches and overrides[key] ~= nil then
                overrides[key] = nil
                autoCleaned = autoCleaned + 1
            end
        end

        -- Remove orphan keys created during editing that aren't tracked overrides
        local orphansRemoved = 0
        for key in pairs(DF._realRaidDB) do
            if self.globalSnapshot[key] == nil and not overrides[key] then
                DF._realRaidDB[key] = nil
                orphansRemoved = orphansRemoved + 1
            end
        end

        local totalOverrides = 0
        for _ in pairs(overrides) do totalOverrides = totalOverrides + 1 end
        DF:Debug("LAYOUT", "ExitEditing: diff scan — autoStored=%d autoCleaned=%d orphansRemoved=%d totalOverrides=%d", autoStored, autoCleaned, orphansRemoved, totalOverrides)
    end
    
    -- Restore all modified values back to their true globals
    -- SetRaidValue handles raid keys, table keys, and pinned keys
    if self.globalSnapshot then
        for key, originalValue in pairs(self.globalSnapshot) do
            SetRaidValue(key, DeepCopyValue(originalValue))
        end
    end
    
    self.editingProfile = nil
    self.editingContentType = nil
    self.editingProfileIndex = nil
    self.globalSnapshot = nil

    -- Clear crash recovery flag — editing exited cleanly
    if DF.db then
        DF.db.raidAutoEditingRecovery = nil
    end

    -- Hide sidebar hint if still showing
    self:HideSidebarHint()

    -- Clear override stars (they'll refresh after EvaluateAndApply if a runtime profile re-applies)
    self:RefreshTabOverrideStars()

    -- Skip UI updates when GUI is closing (UI will reset on next open anyway)
    if skipUIUpdates then return end

    -- Re-evaluate auto-profiles BEFORE UpdateAll so any re-applied overlay is in
    -- place when frames read settings — otherwise UpdateAll would read globals,
    -- then the delayed evaluator would re-apply the overlay causing a flicker.
    -- EvaluateAndApply internally checks InCombatLockdown so this is combat-safe.
    AutoProfilesUI:EvaluateAndApply()

    -- Refresh frames to show global settings again
    if DF.UpdateAll then DF:UpdateAll() end

    -- Test mode needs a full layout refresh so frames re-read restored global values
    -- UpdateAll() only calls UpdateRaidTestFrames() which skips ApplyTestFrameLayout(),
    -- so frame sizes, textures, fonts etc. would remain stuck on overridden values
    if (DF.testMode or DF.raidTestMode) and DF.RefreshTestFramesWithLayout then
        DF:RefreshTestFramesWithLayout()
    end
    
    -- Refresh pinned frames to show global settings again
    if DF.PinnedFrames then
        local pf = DF.db.raid and DF.db.raid.pinnedFrames
        for i = 1, 2 do
            -- Restore enabled state first (hides containers if globally disabled)
            local setEnabled = pf and pf.sets and pf.sets[i] and pf.sets[i].enabled
            DF.PinnedFrames:SetEnabled(i, setEnabled or false)
            DF.PinnedFrames:ApplyLayoutSettings(i)
            DF.PinnedFrames:ResizeContainer(i)
            DF.PinnedFrames:UpdateHeaderNameList(i)
        end
    end
    
    -- Refresh UI to hide banner and re-enable Auto Profiles tab
    self:RefreshEditingUI()
    
    -- Switch back to Auto Profiles tab
    local GUI = DF.GUI
    if GUI and GUI.SelectTab then
        GUI.SelectTab("profiles_auto")
    end
end

function AutoProfilesUI:GetEditingInfo()
    if not self:IsEditing() then return nil end
    
    local profile = self.editingProfile
    local contentType = self.editingContentType
    
    -- Get content type display name
    local contentName = "Unknown"
    for _, ct in ipairs(CONTENT_TYPES) do
        if ct.key == contentType then
            contentName = ct.title
            break
        end
    end
    
    -- Get range display
    local rangeText
    if contentType == "mythic" then
        rangeText = L["20 players (fixed)"]
    else
        rangeText = format(L["%d-%d players"], profile.min, profile.max)
    end
    
    -- Count overrides
    local overrideCount = 0
    if profile.overrides then
        for _ in pairs(profile.overrides) do
            overrideCount = overrideCount + 1
        end
    end
    
    return {
        name = profile.name or L["Unnamed"],
        contentType = contentType,
        contentName = contentName,
        rangeText = rangeText,
        overrideCount = overrideCount,
    }
end

-- ============================================================
-- EDITING BANNER
-- ============================================================

local editingBanner = nil

function AutoProfilesUI:CreateEditingBanner(parent)
    if editingBanner then return editingBanner end
    
    local banner = CreateFrame("Frame", "DandersAutoProfilesEditingBanner", parent, "BackdropTemplate")
    banner:SetHeight(50)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(0.15, 0.08, 0.03, 1)
    banner:SetBackdropBorderColor(1, 0.5, 0.2, 1)
    banner:SetFrameLevel(parent:GetFrameLevel() + 50)  -- Ensure banner is above page content
    banner:Hide()
    
    -- Settings icon
    local icon = banner:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("LEFT", 12, 0)
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\settings")
    icon:SetVertexColor(1, 0.5, 0.2)
    
    -- "Editing:" label
    local editLabel = banner:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    editLabel:SetPoint("LEFT", icon, "RIGHT", 8, 6)
    editLabel:SetText(L["Editing:"])
    editLabel:SetTextColor(0.7, 0.7, 0.7)
    
    -- Profile name and content type
    local profileText = banner:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    profileText:SetPoint("LEFT", editLabel, "RIGHT", 6, 0)
    profileText:SetTextColor(1, 0.5, 0.2)
    banner.profileText = profileText
    
    -- Range info line
    local infoText = banner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    infoText:SetPoint("LEFT", icon, "RIGHT", 8, -10)
    infoText:SetTextColor(0.5, 0.5, 0.5)
    banner.infoText = infoText
    
    -- Exit Editing button
    local exitBtn = CreateFrame("Button", nil, banner, "BackdropTemplate")
    exitBtn:SetSize(90, 26)
    exitBtn:SetPoint("RIGHT", -12, 0)
    exitBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    exitBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)
    exitBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local exitText = exitBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    exitText:SetPoint("CENTER")
    exitText:SetText(L["Exit Editing"])
    exitText:SetTextColor(0.8, 0.8, 0.8)

    exitBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.5, 0.2, 1)
        exitText:SetTextColor(1, 0.5, 0.2)
    end)
    exitBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        exitText:SetTextColor(0.8, 0.8, 0.8)
    end)
    exitBtn:SetScript("OnClick", function()
        AutoProfilesUI:ExitEditing()
    end)

    -- Reset Aura Designer button (only visible on Aura Designer page)
    local resetADBtn = CreateFrame("Button", nil, banner, "BackdropTemplate")
    resetADBtn:SetSize(140, 26)
    resetADBtn:SetPoint("RIGHT", exitBtn, "LEFT", -8, 0)
    resetADBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    resetADBtn:SetBackdropColor(0.12, 0.06, 0.06, 1)
    resetADBtn:SetBackdropBorderColor(0.5, 0.15, 0.15, 1)

    local resetADText = resetADBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    resetADText:SetPoint("CENTER")
    resetADText:SetText(L["Reset to Global"])
    resetADText:SetTextColor(1, 0.5, 0.5)

    resetADBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
        resetADText:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["Reset Aura Designer to Global"])
        GameTooltip:AddLine(L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    resetADBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.15, 0.15, 1)
        resetADText:SetTextColor(1, 0.5, 0.5)
        GameTooltip:Hide()
    end)
    resetADBtn:SetScript("OnClick", function()
        StaticPopup_Show("DF_AURA_DESIGNER_RESET_GLOBAL")
    end)
    resetADBtn:Hide()
    banner.resetADBtn = resetADBtn

    editingBanner = banner
    return banner
end

function AutoProfilesUI:UpdateEditingBanner()
    if not editingBanner then return end

    local info = self:GetEditingInfo()
    if info then
        editingBanner.profileText:SetText(info.contentName .. " → \"" .. info.name .. "\"")

        -- Show contextual info text based on the current page
        local GUI = DF.GUI
        local isAuraDesignerPage = GUI and GUI.CurrentPageName == "auras_auradesigner"
        if isAuraDesignerPage then
            editingBanner.infoText:SetText(info.rangeText .. " · |cffff6666" .. L["Per-setting reset is not available for Aura Designer"] .. "|r")
        else
            editingBanner.infoText:SetText(info.rangeText .. " · " .. L["Only changed settings will be saved"])
        end

        -- Show/hide the Reset Aura Designer button
        if editingBanner.resetADBtn then
            if isAuraDesignerPage then
                editingBanner.resetADBtn:Show()
            else
                editingBanner.resetADBtn:Hide()
            end
        end

        editingBanner:Show()
    else
        editingBanner:Hide()
    end
end

function AutoProfilesUI:RefreshEditingUI()
    local GUI = DF.GUI
    if not GUI then return end
    
    -- Update the editing banner
    self:UpdateEditingBanner()
    
    -- Disable profile-related tabs when editing
    local tabsToDisable = {"profiles_auto", "profiles_manage", "profiles_importexport"}
    for _, tabName in ipairs(tabsToDisable) do
        local tab = GUI.Tabs and GUI.Tabs[tabName]
        if tab then
            if self:IsEditing() then
                -- Mark tab as disabled (GUI.lua will also respect this)
                tab.disabled = true
                tab:EnableMouse(false)
                tab.Text:SetTextColor(0.2, 0.2, 0.2)  -- Very dark grey
                tab.Text:SetAlpha(0.8)  -- Also reduce alpha
                if tab.accent then tab.accent:Hide() end
                tab.isActive = false
                tab:SetBackdropColor(0, 0, 0, 0)
            else
                -- Re-enable the tab
                tab.disabled = false
                tab:EnableMouse(true)
                tab.Text:SetTextColor(0.9, 0.9, 0.9)
                tab.Text:SetAlpha(1)  -- Restore alpha
            end
        end
    end
    
    -- Disable Party button and Binds button when editing (must stay in Raid mode)
    local buttonsToDisable = {GUI.PartyButton, GUI.ClicksButton}
    for _, btn in ipairs(buttonsToDisable) do
        if btn then
            if self:IsEditing() then
                btn.disabled = true
                btn:EnableMouse(false)
                btn.Text:SetTextColor(0.2, 0.2, 0.2)
                btn.Text:SetAlpha(0.8)
                btn:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
                btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
            else
                btn.disabled = false
                btn:EnableMouse(true)
                btn.Text:SetAlpha(1)
                -- Colors will be restored by UpdateThemeColors below
            end
        end
    end
    
    -- Restore proper button colors when not editing
    if not self:IsEditing() and GUI.UpdateThemeColors then
        GUI.UpdateThemeColors()
    end
    
    -- Update page offset for current page
    self:UpdatePageOffset()
    
    -- Refresh all override indicators
    if GUI.RefreshAllOverrideIndicators then
        GUI.RefreshAllOverrideIndicators()
    end
end

function AutoProfilesUI:UpdatePageOffset()
    local GUI = DF.GUI
    if not GUI or not GUI.CurrentPageName then return end
    
    -- The layout code in GUI.lua now checks IsEditing() and adds offset
    -- We just need to trigger a refresh of the current page
    local page = GUI.Pages[GUI.CurrentPageName]
    if page and page.RefreshStates then
        page:RefreshStates()
    end
end

-- ============================================================
-- INTEGRATE BANNER INTO GUI
-- ============================================================

function AutoProfilesUI:SetupEditingBanner()
    local GUI = DF.GUI
    if not GUI or not GUI.contentFrame then return end

    -- Create the banner parented to the main content frame
    local banner = self:CreateEditingBanner(GUI.contentFrame)
    banner:SetPoint("TOPLEFT", GUI.contentFrame, "TOPLEFT", 0, 0)
    banner:SetPoint("TOPRIGHT", GUI.contentFrame, "TOPRIGHT", 0, 0)

    -- =============================================
    -- SIDEBAR ONBOARDING HINT
    -- Subtle orange border + text on the sidebar when editing starts.
    -- Dismissed on the first user tab click.
    -- =============================================
    local sidebarHint = CreateFrame("Frame", nil, GUI.tabFrame, "BackdropTemplate")
    sidebarHint:SetAllPoints(GUI.tabFrame)
    sidebarHint:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sidebarHint:SetBackdropBorderColor(1, 0.5, 0.2, 0.8)
    sidebarHint:SetFrameLevel(GUI.tabFrame:GetFrameLevel() + 10)
    sidebarHint:EnableMouse(false)  -- Don't block clicks on tabs underneath
    sidebarHint:Hide()

    -- Hint label at the top of the sidebar with a background
    local hintBg = CreateFrame("Frame", nil, sidebarHint, "BackdropTemplate")
    hintBg:SetPoint("TOPLEFT", sidebarHint, "TOPLEFT", 1, -1)
    hintBg:SetPoint("TOPRIGHT", sidebarHint, "TOPRIGHT", -1, -1)
    hintBg:SetHeight(32)
    hintBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    hintBg:SetBackdropColor(0.12, 0.06, 0.02, 0.95)
    hintBg:EnableMouse(false)

    local hintText = hintBg:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    hintText:SetPoint("CENTER", hintBg, "CENTER", 0, 0)
    hintText:SetWidth(140)
    hintText:SetJustifyH("CENTER")
    hintText:SetText("|cffff8020" .. L["Select any tab"] .. "|r " .. L["to customise\nthis profile's settings"])
    hintText:SetTextColor(0.75, 0.75, 0.75)

    -- Subtle pulse animation on the border
    local pulseAlpha = 0.4
    local pulseDir = 1
    sidebarHint:SetScript("OnUpdate", function(self, elapsed)
        pulseAlpha = pulseAlpha + elapsed * pulseDir * 0.6
        if pulseAlpha >= 0.8 then
            pulseAlpha = 0.8
            pulseDir = -1
        elseif pulseAlpha <= 0.3 then
            pulseAlpha = 0.3
            pulseDir = 1
        end
        self:SetBackdropBorderColor(1, 0.5, 0.2, pulseAlpha)
    end)

    self.sidebarHint = sidebarHint
    self.sidebarHintDismissed = false

    -- =============================================
    -- OVERRIDE STAR INDICATORS ON TABS
    -- Small orange star on tabs that have overridden settings
    -- =============================================
    for tabName, tab in pairs(GUI.Tabs) do
        if not tab.overrideStar then
            local star = tab:CreateTexture(nil, "OVERLAY")
            star:SetSize(10, 10)
            star:SetPoint("LEFT", 12, 0)
            star:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
            star:SetVertexColor(1, 0.67, 0)
            star:Hide()
            tab.overrideStar = star
        end
    end

    -- Stars on category headers (visible when category is collapsed)
    for catName, cat in pairs(GUI.Categories) do
        if not cat.overrideStar then
            local star = cat:CreateTexture(nil, "OVERLAY")
            star:SetSize(8, 8)
            star:SetPoint("RIGHT", -6, 0)
            star:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
            star:SetVertexColor(1, 0.67, 0)
            star:Hide()
            cat.overrideStar = star
        end
    end

    -- Hook tab button clicks to dismiss sidebar hint and update banner
    -- Tab OnClick calls the local SelectTab (not GUI.SelectTab), so we must
    -- hook each button directly to detect user tab clicks
    for _, btn in pairs(GUI.Tabs) do
        btn:HookScript("OnClick", function()
            if AutoProfilesUI:IsEditing() then
                if not AutoProfilesUI.sidebarHintDismissed
                   and not AutoProfilesUI.suppressHintDismiss then
                    AutoProfilesUI:HideSidebarHint()
                end
                -- Update banner for page-specific elements (e.g. Aura Designer reset button)
                AutoProfilesUI:UpdateEditingBanner()
            end
        end)
    end

    -- Hook into page display to adjust offset when banner is shown
    local originalSelectTab = GUI.SelectTab
    GUI.SelectTab = function(name)
        originalSelectTab(name)

        -- After selecting tab, update banner and page offset
        AutoProfilesUI:UpdateEditingBanner()
        AutoProfilesUI:UpdatePageOffset()

        -- Re-apply disabled tab styling (SelectTab/UpdateThemeColors may have reset colors)
        if AutoProfilesUI:IsEditing() then
            local tabsToDisable = {"profiles_auto", "profiles_manage", "profiles_importexport"}
            for _, tabName in ipairs(tabsToDisable) do
                local tab = GUI.Tabs and GUI.Tabs[tabName]
                if tab then
                    tab.disabled = true
                    tab:EnableMouse(false)
                    tab.Text:SetTextColor(0.2, 0.2, 0.2)  -- Very dark grey
                    tab.Text:SetAlpha(0.8)  -- Also reduce alpha
                    if tab.accent then tab.accent:Hide() end
                    tab.isActive = false
                    tab:SetBackdropColor(0, 0, 0, 0)
                end
            end
        end
    end

    -- Also hook RefreshCurrentPage
    local originalRefresh = GUI.RefreshCurrentPage
    GUI.RefreshCurrentPage = function()
        originalRefresh()
        AutoProfilesUI:UpdateEditingBanner()
        AutoProfilesUI:UpdatePageOffset()
    end
end

function AutoProfilesUI:ShowSidebarHint()
    if self.sidebarHint then
        self.sidebarHintDismissed = false
        self.sidebarHint:Show()
    end
end

function AutoProfilesUI:HideSidebarHint()
    if self.sidebarHint then
        self.sidebarHintDismissed = true
        self.sidebarHint:Hide()
    end
end

-- Refresh orange star indicators on sidebar tabs/categories
-- Shows stars on tabs that contain overridden settings
function AutoProfilesUI:RefreshTabOverrideStars()
    local GUI = DF.GUI
    if not GUI or not GUI.Tabs then return end

    -- Determine which profile's overrides to display
    local profile
    if self:IsEditing() then
        profile = self.editingProfile
    elseif self.activeRuntimeProfile and GUI.SelectedMode == "raid" then
        profile = self.activeRuntimeProfile
    end

    -- Build set of tabIds with overrides
    local tabsWithOverrides = {}
    if profile and profile.overrides then
        for key in pairs(profile.overrides) do
            local tabId = GetOverrideTabId(key)
            if tabId then
                tabsWithOverrides[tabId] = true
            end
        end
    end

    -- Update tab stars
    for tabName, tab in pairs(GUI.Tabs) do
        if tab.overrideStar then
            if tabsWithOverrides[tabName] then
                tab.overrideStar:Show()
            else
                tab.overrideStar:Hide()
            end
        end
    end

    -- Update category stars (show if ANY child tab has overrides)
    if GUI.Categories then
        for catName, cat in pairs(GUI.Categories) do
            if cat.overrideStar then
                local hasOverride = false
                if cat.children then
                    for _, childBtn in ipairs(cat.children) do
                        if childBtn.tabName and tabsWithOverrides[childBtn.tabName] then
                            hasOverride = true
                            break
                        end
                    end
                end
                if hasOverride then
                    cat.overrideStar:Show()
                else
                    cat.overrideStar:Hide()
                end
            end
        end
    end
end

-- ============================================================
-- OVERRIDE SYSTEM FUNCTIONS
-- ============================================================

-- Get a raid setting value, checking profile overrides first
-- Returns: value, isOverridden
function AutoProfilesUI:GetRaidSetting(key)
    local globalValue = DF.db.raid[key]
    
    -- If editing a profile, check that profile's overrides
    if self.editingProfile then
        local overrides = self.editingProfile.overrides
        if overrides and overrides[key] ~= nil then
            return overrides[key], true  -- value, isOverridden
        end
        return globalValue, false
    end
    
    -- If auto-profiles enabled and not editing, check active profile
    if DF.db.raidAutoProfiles and DF.db.raidAutoProfiles.enabled then
        local activeProfile = self:GetActiveProfile()
        if activeProfile and activeProfile.overrides and activeProfile.overrides[key] ~= nil then
            return activeProfile.overrides[key], true
        end
    end
    
    return globalValue, false
end

function AutoProfilesUI:SetProfileSetting(key, value)
    if not self.editingProfile then return false end

    -- Ensure overrides table exists
    if not self.editingProfile.overrides then
        self.editingProfile.overrides = {}
    end

    -- Get the true global from snapshot (db.raid has been modified by the control already)
    local globalValue, found = GetSnapshotValue(self.globalSnapshot, key)
    if not found then
        globalValue = GetRaidValue(key)
    end

    -- Compare values (recursive deep compare handles nested tables like colors)
    local valuesMatch = DeepCompare(value, globalValue)

    if valuesMatch then
        -- Same as global, remove override
        self.editingProfile.overrides[key] = nil
        DF:Debug("LAYOUT", "SetProfileSetting: %s matches global, override removed", key)
    else
        -- Different from global, store override (deep copy to avoid reference issues)
        self.editingProfile.overrides[key] = DeepCopyValue(value)
        DF:Debug("LAYOUT", "SetProfileSetting: %s overridden (value=%s)", key, tostring(value))
    end

    -- Refresh tab stars so they update live as settings change
    self:RefreshTabOverrideStars()

    return true
end

-- Reset a setting to global (remove override)
function AutoProfilesUI:ResetProfileSetting(key)
    if not self.editingProfile then return false end
    DF:Debug("LAYOUT", "ResetProfileSetting: %s — restoring to global", key)

    if self.editingProfile.overrides then
        self.editingProfile.overrides[key] = nil
    end
    
    -- Restore the actual db value to the true global (from snapshot)
    local globalValue, found = GetSnapshotValue(self.globalSnapshot, key)
    if not found then
        globalValue = GetRaidValue(key)
    end
    
    -- Deep copy to avoid mutating the snapshot
    SetRaidValue(key, DeepCopyValue(globalValue))

    -- Refresh tab stars so they update live as overrides are removed
    self:RefreshTabOverrideStars()

    return true
end

-- Get the global value for a setting (for display purposes)
-- Returns a deep copy to prevent callers from mutating the snapshot
function AutoProfilesUI:GetGlobalValue(key)
    -- When editing, return the true global from snapshot (db.raid may have overridden values)
    local snapshotVal, found = GetSnapshotValue(self.globalSnapshot, key)
    if found then
        return DeepCopyValue(snapshotVal)
    end
    return GetRaidValue(key)
end

-- Check if a setting is currently overridden
function AutoProfilesUI:IsSettingOverridden(key)
    if not self.editingProfile or not self.editingProfile.overrides then
        return false
    end
    return self.editingProfile.overrides[key] ~= nil
end

-- Get active profile based on current content/raid size (for runtime, not editing)
-- Returns: profile, contentKey (or nil, nil if no match)
function AutoProfilesUI:GetActiveProfile()
    local autoDb = DF.db.raidAutoProfiles
    if not autoDb or not autoDb.enabled then
        DF:Debug("LAYOUT", "GetActiveProfile: disabled or no autoDb")
        return nil
    end

    -- Must be in a raid group for auto-profiles to apply
    if not IsInRaid() then
        DF:Debug("LAYOUT", "GetActiveProfile: not in raid")
        return nil
    end

    -- Use the existing content type detection from Core.lua
    local contentType = DF:GetContentType()
    if not contentType then
        DF:Debug("LAYOUT", "GetActiveProfile: no content type detected")
        return nil
    end

    local raidSize = GetNumGroupMembers()
    DF:Debug("LAYOUT", "GetActiveProfile: contentType=%s raidSize=%d", contentType, raidSize)

    -- Mythic: single profile, no range check needed
    if contentType == "mythic" then
        local mythicProfile = autoDb.mythic and autoDb.mythic.profile
        if mythicProfile then
            DF:Debug("LAYOUT", "GetActiveProfile: matched mythic layout \"%s\"", mythicProfile.name or "?")
            return mythicProfile, "mythic"
        end
        DF:Debug("LAYOUT", "GetActiveProfile: mythic content but no layout configured")
        return nil
    end
    
    -- Map content type to auto-profile key
    -- "battleground" falls under "instanced" (the "Instanced / PvP" category)
    local profileKey
    if contentType == "instanced" or contentType == "battleground" then
        profileKey = "instanced"
    elseif contentType == "openWorld" then
        profileKey = "openWorld"
    else
        DF:Debug("LAYOUT", "GetActiveProfile: unmapped content type \"%s\", no layout", contentType)
        return nil
    end

    -- Find matching profile by raid size within the content type
    local profile = FindMatchingProfile(profileKey, raidSize)
    if profile then
        return profile, profileKey
    end

    DF:Debug("LAYOUT", "GetActiveProfile: no matching range for %s (size %d)", profileKey, raidSize)
    return nil
end

-- ============================================================
-- RUNTIME PROFILE APPLICATION
-- Applies/removes auto-profile overrides at runtime based on
-- content type and raid size changes
-- ============================================================

-- Get a display name for a content key
local function GetContentDisplayName(contentKey)
    if contentKey == "mythic" then return "Mythic"
    elseif contentKey == "instanced" then return "Instanced/PvP"
    elseif contentKey == "openWorld" then return "Open World"
    end
    return contentKey or "Unknown"
end

-- Apply a profile's overrides as a read-through overlay (does NOT mutate the real raid table)
function AutoProfilesUI:ApplyRuntimeProfile(profile, contentKey)
    if not profile or not profile.overrides then return end
    DF:Debug("LAYOUT", "ApplyRuntimeProfile: \"%s\" (%s)", profile.name or "?", contentKey)

    -- Group nested overrides by parent table so multiple overrides on the same
    -- parent (e.g. raidGroupVisible_1 and raidGroupVisible_3) share one copy
    local tableGroups = {}   -- { [parentTable] = { [index] = value, ... } }
    local pinnedGroups = {}  -- { [setIndex] = { [setting] = value, ... } }
    local simpleKeys = {}    -- { [key] = value }

    for key, value in pairs(profile.overrides) do
        local setIndex, setting = ParsePinnedKey(key)
        if setIndex and setting then
            if not pinnedGroups[setIndex] then pinnedGroups[setIndex] = {} end
            pinnedGroups[setIndex][setting] = value
        else
            local tableName, index = ParseTableKey(key)
            if tableName and index then
                if not tableGroups[tableName] then tableGroups[tableName] = {} end
                tableGroups[tableName][index] = value
            else
                simpleKeys[key] = value
            end
        end
    end

    -- Build the overlay table
    local overlay = {}

    -- Simple keys: direct copy
    for key, value in pairs(simpleKeys) do
        overlay[key] = DeepCopyValue(value)
    end

    -- Table keys: deep-copy parent from real table, apply overrides
    for tableName, indices in pairs(tableGroups) do
        local parent = DeepCopyValue(DF._realRaidDB[tableName])
        if type(parent) ~= "table" then parent = {} end
        for index, value in pairs(indices) do
            parent[index] = DeepCopyValue(value)
        end
        overlay[tableName] = parent
    end

    -- Pinned keys: deep-copy pinnedFrames from real table, apply overrides
    if next(pinnedGroups) then
        local pf = DeepCopyValue(DF._realRaidDB.pinnedFrames)
        if type(pf) ~= "table" then pf = {} end
        if type(pf.sets) ~= "table" then pf.sets = {} end
        for setIdx, settings in pairs(pinnedGroups) do
            if not pf.sets[setIdx] then pf.sets[setIdx] = {} end
            for setting, value in pairs(settings) do
                pf.sets[setIdx][setting] = DeepCopyValue(value)
            end
        end
        overlay.pinnedFrames = pf
    end

    -- Activate the overlay (proxy reads this automatically)
    DF.raidOverrides = overlay

    -- Count overlay keys for debug
    local overlayCount = 0
    for _ in pairs(overlay) do overlayCount = overlayCount + 1 end
    local totalOverrides = 0
    for _ in pairs(profile.overrides) do totalOverrides = totalOverrides + 1 end
    DF:Debug("LAYOUT", "ApplyRuntimeProfile: overlay active — %d overrides, %d overlay keys", totalOverrides, overlayCount)

    -- Store active state
    self.activeRuntimeProfile = profile
    self.activeRuntimeContentKey = contentKey

    -- Refresh all frames to reflect new settings
    if DF.FullProfileRefresh then
        DF:FullProfileRefresh()
    end

    -- Chat notification
    local raidSize = GetNumGroupMembers()
    local contentName = GetContentDisplayName(contentKey)
    print("|cff00ff00DandersFrames:|r " .. format(L["Auto-profile \"%s\" activated (%s, %d players)"], profile.name or L["Unnamed"], contentName, raidSize))

    -- Update tab override stars
    self:RefreshTabOverrideStars()
end

-- Remove the active runtime profile overlay
function AutoProfilesUI:RemoveRuntimeProfile()
    if not self.activeRuntimeProfile then return end
    DF:Debug("LAYOUT", "RemoveRuntimeProfile: deactivating \"%s\" (%s)", self.activeRuntimeProfile.name or "?", self.activeRuntimeContentKey or "?")

    -- Clear overlay FIRST so any subsequent refresh reads global settings
    DF.raidOverrides = nil

    -- Clear runtime state
    self.activeRuntimeProfile = nil
    self.activeRuntimeContentKey = nil

    -- Snap frames to base settings immediately so they are never in a
    -- partially-configured state between overlay clear and the caller's refresh
    if not InCombatLockdown() and DF.FullProfileRefresh then
        DF:FullProfileRefresh()
    end

    print("|cff00ff00DandersFrames:|r " .. L["Auto-profile deactivated, using global settings"])
    self:RefreshTabOverrideStars()
end

-- ============================================================
-- RUNTIME WRITE INTERCEPTION
-- When a user changes a global setting via GUI while an auto-profile
-- overlay is active, the proxy __newindex already writes to the real
-- table. This function tells the caller whether the key is overridden
-- so the GUI can suppress visual refresh (the overlay value stays visible).
-- ============================================================

-- Intercept a GUI control write for an overridden key.
-- The proxy __newindex already wrote the user's value to the real table.
-- For nested keys we also need to update the real sub-table manually.
-- Returns true if the key is overridden (caller should skip frame refresh).
function AutoProfilesUI:HandleRuntimeWrite(key, value)
    if not key then return false end
    if not self.activeRuntimeProfile or not DF.raidOverrides then return false end

    -- Check if this key (or its parent) is covered by the overlay
    local setIndex, setting = ParsePinnedKey(key)
    if setIndex and setting then
        local pf = DF._realRaidDB.pinnedFrames
        if pf and pf.sets and pf.sets[setIndex] then
            pf.sets[setIndex][setting] = value
        end
        local isOverridden = DF.raidOverrides.pinnedFrames ~= nil
        DF:Debug("LAYOUT", "HandleRuntimeWrite: pinned key %s — overridden=%s, wrote to real table", key, tostring(isOverridden))
        return isOverridden
    end

    local tableName, index = ParseTableKey(key)
    if tableName and index then
        local tbl = DF._realRaidDB[tableName]
        if type(tbl) == "table" then
            tbl[index] = value
        end
        local isOverridden = DF.raidOverrides[tableName] ~= nil
        DF:Debug("LAYOUT", "HandleRuntimeWrite: table key %s — overridden=%s, wrote to real table", key, tostring(isOverridden))
        return isOverridden
    end

    -- Simple key: write to real table so user changes persist in the global profile
    if DF.raidOverrides[key] ~= nil then
        DF._realRaidDB[key] = value
        DF:Debug("LAYOUT", "HandleRuntimeWrite: %s — overridden, wrote value=%s to global", key, tostring(value))
        return true
    end
    return false
end

-- Check if a setting key is currently overridden by an active runtime profile.
-- Used by the GUI to show visual indicators on overridden controls.
function AutoProfilesUI:IsOverriddenByRuntime(key)
    if not self.activeRuntimeProfile or not DF.raidOverrides then return false end

    local setIndex, setting = ParsePinnedKey(key)
    if setIndex and setting then
        return DF.raidOverrides.pinnedFrames ~= nil
    end

    local tableName, index = ParseTableKey(key)
    if tableName and index then
        return DF.raidOverrides[tableName] ~= nil
    end

    return DF.raidOverrides[key] ~= nil
end

-- Get the global (baseline) value of an overridden key for display in indicators.
-- With the overlay proxy the real table is always clean, so just read from it.
function AutoProfilesUI:GetRuntimeGlobalValue(key)
    local setIndex, setting = ParsePinnedKey(key)
    if setIndex and setting then
        local pf = DF._realRaidDB and DF._realRaidDB.pinnedFrames
        local sets = pf and pf.sets
        if sets and sets[setIndex] then
            return sets[setIndex][setting]
        end
        return nil
    end

    local tableName, index = ParseTableKey(key)
    if tableName and index then
        local tbl = DF._realRaidDB[tableName]
        if type(tbl) == "table" then
            return tbl[index]
        end
        return nil
    end

    return DF._realRaidDB[key]
end

-- Evaluate current content/raid state and apply/remove profiles as needed
function AutoProfilesUI:EvaluateAndApply()
    if not DF.initialized then return end
    if self:IsEditing() then
        DF:Debug("LAYOUT", "EvaluateAndApply: skipped (editing mode)")
        return
    end

    -- Cannot modify secure frames during combat — queue for later
    if InCombatLockdown() then
        DF:Debug("LAYOUT", "EvaluateAndApply: in combat, queued for PLAYER_REGEN_ENABLED")
        self.pendingAutoProfileEval = true
        return
    end

    -- Determine what profile should be active
    local newProfile, contentKey = self:GetActiveProfile()
    local oldName = self.activeRuntimeProfile and self.activeRuntimeProfile.name or "none"
    local newName = newProfile and newProfile.name or "none"

    -- No change — same profile (or both nil)
    if newProfile == self.activeRuntimeProfile then
        DF:Debug("LAYOUT", "EvaluateAndApply: no change (active=\"%s\")", oldName)
        return
    end
    if newProfile == nil and self.activeRuntimeProfile == nil then return end

    DF:Debug("LAYOUT", "EvaluateAndApply: switching \"%s\" -> \"%s\"", oldName, newName)
    DF:Debug("RAIDPOS", "AutoProfile SWITCH: \"%s\" -> \"%s\" (raid size=%d)", oldName, newName, GetNumGroupMembers())

    -- Capture whether an old profile was active before clearing state
    local oldWasActive = (self.activeRuntimeProfile ~= nil)

    -- Remove old profile if one was active (clears overlay and state only)
    if self.activeRuntimeProfile then
        self:RemoveRuntimeProfile()
    end

    -- Apply new profile if one matches (sets overlay then calls FullProfileRefresh: 1 refresh)
    if newProfile then
        self:ApplyRuntimeProfile(newProfile, contentKey)
    elseif oldWasActive then
        -- Profile deactivated (profile→none): refresh once with clean global settings
        DF:FullProfileRefresh()
    end
end

-- ============================================================
-- EVENT FRAME & THROTTLE
-- Listens for content/roster changes and triggers evaluation
-- ============================================================

local autoProfileEventFrame = CreateFrame("Frame")
autoProfileEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
autoProfileEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
autoProfileEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
autoProfileEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Frame-based throttle: multiple events in the same frame collapse into one evaluation
local autoProfileThrottleFrame = CreateFrame("Frame")
autoProfileThrottleFrame:Hide()
autoProfileThrottleFrame:SetScript("OnUpdate", function(self)
    self:Hide()

    -- Suppress any pending roster update — we process it after overlay is settled
    local rosterPending = DF._rosterThrottleFrame and DF._rosterThrottleFrame:IsShown()
    if rosterPending then
        DF._rosterThrottleFrame:Hide()
    end

    DF:Debug("RAIDPOS", "AutoProfile throttle FIRE: rosterPending=%s combat=%s", tostring(rosterPending), tostring(InCombatLockdown()))

    AutoProfilesUI:EvaluateAndApply()

    -- Now process roster with correct overlay state
    if rosterPending then
        DF:Debug("RAIDPOS", "AutoProfile throttle: running deferred ProcessRosterUpdate after EvaluateAndApply")
        if not InCombatLockdown() then
            DF:ProcessRosterUpdate()
        else
            local raidDb = DF:GetRaidDB()
            if IsInRaid() and not raidDb.raidUseGroups then
                DF.pendingFlatLayoutRefresh = true
            else
                DF.pendingHeaderSettingsApply = true
            end
        end
    end
end)

local function QueueAutoProfileEval()
    autoProfileThrottleFrame:Show()
end

autoProfileEventFrame:SetScript("OnEvent", function(self, event)
    if not DF.initialized then return end
    if event == "PLAYER_REGEN_ENABLED" then
        if AutoProfilesUI.pendingAutoProfileEval then
            DF:Debug("LAYOUT", "Event: %s — processing queued evaluation", event)
            AutoProfilesUI.pendingAutoProfileEval = false
            QueueAutoProfileEval()
        end
        return
    end

    DF:Debug("LAYOUT", "Event: %s — queuing evaluation", event)
    QueueAutoProfileEval()
end)

-- ============================================================
-- PRINT OVERRIDES: /df overrides
-- Shows which settings are overridden, grouped by tab
-- ============================================================

function AutoProfilesUI:PrintOverrides()
    -- Determine which profile to report on
    local profile, source
    if self:IsEditing() then
        profile = self.editingProfile
        source = L["Editing"]
    elseif self.activeRuntimeProfile then
        profile = self.activeRuntimeProfile
        source = L["Runtime"]
    else
        local activeProfile = self:GetActiveProfile()
        if activeProfile then
            profile = activeProfile
            source = L["Matched (not applied)"]
        end
    end

    if not profile then
        print("|cffff8020DandersFrames:|r " .. L["No auto-profile is currently active or being edited."])
        return
    end

    if not profile.overrides or not next(profile.overrides) then
        print("|cffff8020DandersFrames:|r " .. format(L["Profile \"%s\" has no overrides."], profile.name or L["Unnamed"]))
        return
    end

    -- Count total
    local total = 0
    for _ in pairs(profile.overrides) do total = total + 1 end

    print("|cffff8020" .. L["DandersFrames Auto-Profile Overrides:"] .. "|r")
    print("  " .. L["Profile:"] .. " |cffffffff\"" .. (profile.name or L["Unnamed"]) .. "\"|r (" .. source .. ")")
    print("  " .. L["Total:"] .. " |cffffffff" .. format(total > 1 and L["%d overrides"] or L["%d override"], total) .. "|r")

    -- Group by tab
    local groups, unknownKeys = GroupOverridesByTab(profile.overrides)

    -- Sort tab IDs for consistent output
    local tabOrder = {}
    for tabId in pairs(groups) do
        tinsert(tabOrder, tabId)
    end
    table.sort(tabOrder)

    for _, tabId in ipairs(tabOrder) do
        local group = groups[tabId]
        print("  |cffffaa00" .. group.tabLabel .. "|r (" .. #group.keys .. "):")
        table.sort(group.keys)
        for _, key in ipairs(group.keys) do
            local value = profile.overrides[key]
            local displayValue
            if type(value) == "table" then
                if value.r and value.g and value.b then
                    displayValue = string.format("|cffffffff(%.2f, %.2f, %.2f)|r", value.r, value.g, value.b)
                else
                    displayValue = "|cffffffff{table}|r"
                end
            elseif type(value) == "boolean" then
                displayValue = value and "|cff00ff00true|r" or "|cffff4444false|r"
            else
                displayValue = "|cffffffff" .. tostring(value) .. "|r"
            end
            print("    " .. key .. " = " .. displayValue)
        end
    end

    if #unknownKeys > 0 then
        print("  |cff999999" .. L["Other"] .. "|r (" .. #unknownKeys .. "):")
        table.sort(unknownKeys)
        for _, key in ipairs(unknownKeys) do
            print("    " .. key .. " = " .. tostring(profile.overrides[key]))
        end
    end
end

-- ============================================================
-- DEBUG: Auto Profile Detection Test
-- Usage: /dfautotest - Print current detection results
-- ============================================================

SLASH_DFAUTOTEST1 = "/dfautotest"
SlashCmdList["DFAUTOTEST"] = function()
    local autoDb = DF.db and DF.db.raidAutoProfiles
    local enabled = autoDb and autoDb.enabled
    local inRaid = IsInRaid()
    local contentType = DF.GetContentType and DF:GetContentType() or "N/A"
    local raidSize = GetNumGroupMembers()
    
    print("|cffff8020DandersFrames Auto Profile Detection:|r")
    print("  Enabled: " .. (enabled and "|cff00ff00YES|r" or "|cffff4444NO|r"))
    print("  In Raid: " .. (inRaid and "|cff00ff00YES|r" or "|cffff4444NO|r"))
    print("  Content Type: |cffffffff" .. tostring(contentType) .. "|r")
    print("  Raid Size: |cffffffff" .. raidSize .. "|r")
    
    local profile, profileKey = AutoProfilesUI:GetActiveProfile()
    if profile then
        local overrideCount = 0
        if profile.overrides then
            for _ in pairs(profile.overrides) do
                overrideCount = overrideCount + 1
            end
        end
        print("  Active Profile: |cff00ff00\"" .. (profile.name or "Unnamed") .. "\"|r")
        print("  Matched Key: |cffffffff" .. tostring(profileKey) .. "|r")
        if profile.min and profile.max then
            print("  Range: |cffffffff" .. profile.min .. "-" .. profile.max .. " players|r")
        end
        print("  Overrides: |cffffffff" .. overrideCount .. "|r")
    else
        print("  Active Profile: |cff999999None (using global settings)|r")
    end

    -- Runtime state
    print("  --- Runtime State ---")
    local rtProfile = AutoProfilesUI.activeRuntimeProfile
    if rtProfile then
        local rtOverrides = 0
        if rtProfile.overrides then
            for _ in pairs(rtProfile.overrides) do rtOverrides = rtOverrides + 1 end
        end
        local overlayKeys = 0
        if DF.raidOverrides then
            for _ in pairs(DF.raidOverrides) do overlayKeys = overlayKeys + 1 end
        end
        print("  Runtime Profile: |cff00ff00\"" .. (rtProfile.name or "Unnamed") .. "\"|r ("
            .. tostring(AutoProfilesUI.activeRuntimeContentKey) .. ")")
        print("  Applied Overrides: |cffffffff" .. rtOverrides .. "|r, Overlay Keys: |cffffffff" .. overlayKeys .. "|r")
    else
        print("  Runtime Profile: |cff999999None|r")
    end
    print("  Pending Combat Eval: " .. (AutoProfilesUI.pendingAutoProfileEval and "|cffff8020YES|r" or "|cff999999No|r"))
    print("  Editing Mode: " .. (AutoProfilesUI:IsEditing() and "|cffff8020YES|r" or "|cff999999No|r"))

    -- Also list all configured profiles for context
    if autoDb then
        print("  --- Configured Profiles ---")
        for _, ctDef in ipairs(CONTENT_TYPES) do
            local key = ctDef.key
            if key == "mythic" then
                local mp = autoDb.mythic and autoDb.mythic.profile
                if mp then
                    print("  [Mythic] \"" .. (mp.name or "Unnamed") .. "\" (20 fixed)")
                end
            else
                local profiles = autoDb[key] and autoDb[key].profiles or {}
                for _, p in ipairs(profiles) do
                    print("  [" .. ctDef.title .. "] \"" .. p.name .. "\" (" .. p.min .. "-" .. p.max .. ")")
                end
            end
        end
    end
end
