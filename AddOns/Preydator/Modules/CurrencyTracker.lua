---@diagnostic disable

--[[
    Preydator: CurrencyTracker
    Tracks approved Prey currencies across the current character and all known warband alts.
    Styled after profession app panels: clean rows, delta indicators, warband roll-up.

    Approved currency IDs (allow-list):
        3392  Remnant of Anguish          (primary Prey currency)
        3316  Voidlight Marl              (expansion permanent)
        3383  Adventurer Dawncrest        (Season 1)
        3341  Veteran Dawncrest           (Season 1)
        3343  Champion Dawncrest          (Season 1)
]]

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable
local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })

local C_DateAndTime  = _G.C_DateAndTime
local C_CurrencyInfo   = _G.C_CurrencyInfo
local C_Timer          = _G.C_Timer
local CreateFrame      = _G.CreateFrame
local GameTooltip      = _G.GameTooltip
local GetServerTime    = _G.GetServerTime
local GetTime          = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsShiftKeyDown   = _G.IsShiftKeyDown
local LibStub          = _G.LibStub
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass        = _G.UnitClass
local UnitName         = _G.UnitName
local GetRealmName     = _G.GetRealmName
local GetZoneText      = _G.GetZoneText
local UIParent         = _G.UIParent
local math             = _G.math
local string           = _G.string
local table            = _G.table
local pairs            = _G.pairs
local ipairs           = _G.ipairs
local tostring         = _G.tostring
local tonumber         = _G.tonumber
local type             = _G.type
local date             = _G.date
local GetPreyWeeklyCompleted

local function IsModuleEnabled(moduleKey)
    local customization = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
    if customization and type(customization.IsModuleEnabled) == "function" then
        return customization:IsModuleEnabled(moduleKey) == true
    end
    return true
end

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local CURRENCY_ALLOW_LIST = {
    { id = 3392, name = "Remnant of Anguish", label = "Anguish", season = nil, group = "expansion" },
    { id = 3316, name = "Voidlight Marl", label = "Voidlight", season = nil, group = "expansion" },
    { id = 3376, name = "Shard of Dundun", label = "Dundun", season = nil, group = "expansion" },
    { id = 3385, name = "Luminous Dust", label = "Lum. Dust", season = nil, group = "expansion" },
    { id = 3377, name = "Unalloyed Abundance", label = "Abundance", season = nil, group = "expansion" },
    { id = 3379, name = "Brimming Arcana", label = "Arcana", season = nil, group = "expansion" },
    { id = 3400, name = "Uncontaminated Void Sample", label = "Void Sample", season = nil, group = "expansion" },
    { id = 3373, name = "Angler Pearls", label = "Pearls", season = nil, group = "expansion" },
    { id = 3352, name = "Party Favor", label = "Party Favor", season = nil, group = "expansion" },
    { id = 3383, name = "Adventurer Dawncrest", label = "Adv. Crest", season = "S1", group = "seasonal" },
    { id = 3341, name = "Veteran Dawncrest", label = "Vet. Crest", season = "S1", group = "seasonal" },
    { id = 3343, name = "Champion Dawncrest", label = "Champ. Crest", season = "S1", group = "seasonal" },
    { id = 3345, name = "Hero Dawncrest", label = "Hero Crest", season = "S1", group = "seasonal" },
    { id = 3347, name = "Myth Dawncrest", label = "Myth Crest", season = "S1", group = "seasonal" },
    { id = 3212, name = "Radiant Spark Dust", label = "Spark Dust", season = "S1", group = "seasonal" },
    { id = 3378, name = "Dawnlight Manaflux", label = "Manaflux", season = "S1", group = "seasonal" },
    { id = 2803, name = "Undercoin", label = "Undercoin", season = "S1", group = "seasonal" },
    { id = 3310, name = "Coffer Key Shards", label = "Coffer Shards", season = "S1", group = "seasonal" },
    { id = 3028, name = "Restored Coffer Key", label = "Coffer Key", season = "S1", group = "seasonal" },
    { id = 3356, name = "Untainted Mana-Crystals", label = "Mana-Crystals", season = "S1", group = "seasonal" },
    { id = 3256, name = "Artisan Alchemist's Moxie", label = "Alch. Moxie", season = nil, group = "crafting" },
    { id = 3260, name = "Artisan Herbalist's Moxie", label = "Herb. Moxie", season = nil, group = "crafting" },
    { id = 3258, name = "Artisan Enchanter's Moxie", label = "Ench. Moxie", season = nil, group = "crafting" },
    { id = 3264, name = "Artisan Miner's Moxie", label = "Miner Moxie", season = nil, group = "crafting" },
    { id = 3265, name = "Artisan Skinner's Moxie", label = "Skinner Moxie", season = nil, group = "crafting" },
    { id = 3257, name = "Artisan Blacksmith's Moxie", label = "Smith Moxie", season = nil, group = "crafting" },
    { id = 3266, name = "Artisan Tailor's Moxie", label = "Tailor Moxie", season = nil, group = "crafting" },
    { id = 3263, name = "Artisan Leatherworker's Moxie", label = "Leather Moxie", season = nil, group = "crafting" },
    { id = 3262, name = "Artisan Jewelcrafter's Moxie", label = "Jewel Moxie", season = nil, group = "crafting" },
    { id = 3259, name = "Artisan Engineer's Moxie", label = "Eng. Moxie", season = nil, group = "crafting" },
    { id = 3261, name = "Artisan Scribe's Moxie", label = "Scribe Moxie", season = nil, group = "crafting" },
}

local ALLOW_LIST_IDS = {}
for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
    ALLOW_LIST_IDS[entry.id] = entry
end

-- UI geometry
local PANEL_PAD        = 16
local ROW_HEIGHT       = 42
local ROW_GAP          = 6
local SECTION_TITLE_H  = 22
local SECTION_GAP      = 10
local COL_LEFT_W       = 340
local ICON_SIZE        = 28
local ICON_PAD         = 8
local WARBAND_ROW_H    = 24
local WARBAND_COL_CHAR = 160
local WARBAND_COL_W    = 68
local TRACKER_WINDOW_WIDTH = 276
local TRACKER_WINDOW_HEIGHT = 236
local TRACKER_ROW_WIDTH = 248
local TRACKER_ROW_HEIGHT = 28
local TRACKER_MIN_WIDTH = 240
local TRACKER_MAX_WIDTH = 520
local TRACKER_MIN_HEIGHT = 64
local TRACKER_MAX_HEIGHT = 700
local TRACKER_DEFAULT_FONT = 14
local TRACKER_MIN_FONT = 10
local TRACKER_MAX_FONT = 24
local TRACKER_DEFAULT_SCALE = 1.00
local TRACKER_MIN_SCALE = 0.70
local TRACKER_MAX_SCALE = 1.40
local RANDOM_HUNT_ANGUISH_COST = 50
local WARBAND_DEFAULT_WIDTH = 420
local WARBAND_DEFAULT_HEIGHT = 250
local WARBAND_MIN_WIDTH = 150
local WARBAND_MAX_WIDTH = 900
local WARBAND_MIN_HEIGHT = 80
local WARBAND_MAX_HEIGHT = 600
local WARBAND_DEFAULT_FONT = 12
local WARBAND_MIN_FONT = 10
local WARBAND_MAX_FONT = 24
local WARBAND_DEFAULT_SCALE = 1.00
local WARBAND_MIN_SCALE = 0.70
local WARBAND_MAX_SCALE = 1.40
local CURRENCY_WHATS_NEW_VERSION = "2.1.1"

-- Colors
local COLOR_SECTION_BG  = { 0.08, 0.06, 0.03, 0.92 }
local COLOR_ROW_BG      = { 0.14, 0.11, 0.06, 0.92 }
local COLOR_ROW_BG_ALT  = { 0.10, 0.08, 0.05, 0.92 }
local COLOR_HOVER       = { 0.35, 0.27, 0.12, 0.45 }
local COLOR_BORDER      = { 0.78, 0.62, 0.20, 0.95 }
local COLOR_HEADER_BG   = { 0.21, 0.15, 0.06, 1.00 }
local COLOR_GOLD        = { 1.00, 0.82, 0.00, 1.00 }
local COLOR_WHITE       = { 1.00, 1.00, 1.00, 1.00 }
local COLOR_MUTED       = { 0.65, 0.65, 0.70, 1.00 }
local COLOR_GREEN       = { 0.00, 0.56, 0.32, 1.00 }
local COLOR_RED         = { 0.72, 0.24, 0.15, 1.00 }
local COLOR_SEASON      = { 0.60, 0.80, 1.00, 1.00 }
local LEGACY_GAIN_COLOR = { 0.25, 0.90, 0.65, 1.00 }
local LEGACY_LOSS_COLOR = { 0.98, 0.56, 0.36, 1.00 }

local THEME_PRESETS = {
    light = {
        section = { 0.87, 0.84, 0.79, 0.94 },
        row = { 0.95, 0.93, 0.90, 0.95 },
        rowAlt = { 0.90, 0.87, 0.83, 0.95 },
        border = { 0.27, 0.24, 0.19, 1.00 },
        header = { 0.78, 0.72, 0.64, 0.96 },
        title = { 0.12, 0.10, 0.08, 1.00 },
        text = { 0.10, 0.09, 0.07, 1.00 },
        muted = { 0.28, 0.25, 0.21, 1.00 },
        season = { 0.13, 0.34, 0.67, 1.00 },
        fontKey = "frizqt",
    },
    brown = {
        section = { 0.08, 0.06, 0.03, 0.92 },
        row = { 0.14, 0.11, 0.06, 0.92 },
        rowAlt = { 0.10, 0.08, 0.05, 0.92 },
        border = { 0.78, 0.62, 0.20, 0.95 },
        header = { 0.21, 0.15, 0.06, 1.00 },
        title = { 1.00, 0.82, 0.00, 1 },
        text = { 1.00, 1.00, 1.00, 1 },
        muted = { 0.74, 0.70, 0.60, 1 },
        season = { 0.60, 0.80, 1.00, 1 },
        fontKey = "frizqt",
    },
    dark = {
        section = { 0.07, 0.07, 0.09, 0.92 },
        row = { 0.14, 0.14, 0.16, 0.92 },
        rowAlt = { 0.11, 0.11, 0.13, 0.92 },
        border = { 0.30, 0.30, 0.35, 0.90 },
        header = { 0.18, 0.18, 0.22, 1.00 },
        title = { 1.00, 0.82, 0.00, 1 },
        text = { 1.00, 1.00, 1.00, 1 },
        muted = { 0.65, 0.65, 0.70, 1 },
        season = { 0.60, 0.80, 1.00, 1 },
        fontKey = "frizqt",
    },
    -- Deuteranopia: blue/amber palette safe for green-weakness (most common, ~8% of males)
    deuteranopia = {
        section = { 0.06, 0.07, 0.14, 0.92 },
        row     = { 0.10, 0.12, 0.22, 0.92 },
        rowAlt  = { 0.08, 0.09, 0.17, 0.92 },
        border  = { 0.90, 0.60, 0.10, 0.95 },
        header  = { 0.14, 0.16, 0.30, 1.00 },
        title   = { 1.00, 0.74, 0.00, 1.00 },
        text    = { 1.00, 1.00, 1.00, 1.00 },
        muted   = { 0.65, 0.68, 0.84, 1.00 },
        season  = { 0.35, 0.65, 1.00, 1.00 },
        fontKey = "frizqt",
    },
    -- Protanopia: cyan/yellow palette safe for red-weakness (~2% of males)
    protanopia = {
        section = { 0.03, 0.10, 0.13, 0.92 },
        row     = { 0.06, 0.16, 0.20, 0.92 },
        rowAlt  = { 0.04, 0.12, 0.16, 0.92 },
        border  = { 0.00, 0.72, 0.82, 0.95 },
        header  = { 0.08, 0.20, 0.26, 1.00 },
        title   = { 0.00, 0.88, 1.00, 1.00 },
        text    = { 1.00, 1.00, 1.00, 1.00 },
        muted   = { 0.50, 0.74, 0.80, 1.00 },
        season  = { 1.00, 0.86, 0.00, 1.00 },
        fontKey = "frizqt",
    },
}

local THEME_COLOR_KEYS = { "section", "row", "rowAlt", "border", "header", "title", "text", "muted", "season" }
local FONT_PATHS = {
    frizqt = "Fonts\\FRIZQT__.TTF",
    arialn = "Fonts\\ARIALN.TTF",
    skurri = "Fonts\\skurri.ttf",
    morpheus = "Fonts\\MORPHEUS.TTF",
}

--------------------------------------------------------------------------------
-- Module skeleton
--------------------------------------------------------------------------------

local CurrencyTrackerModule = {}
Preydator:RegisterModule("CurrencyTracker", CurrencyTrackerModule)

local nextLightRefreshAt = 0

-- Internal state (not persisted to SavedVariables — that happens via OnAddonLoaded/OnEvent)
local db                -- reference to PreydatorDB.currency sub-table
local sessionStart      = {}   -- [currencyID] = quantity at login/reload
local sessionBaselineReady = false
local currencyPanelPage = nil  -- the Tab content frame, built lazily
local lastKnownQuantity = {}   -- [currencyID] = quantity
local warbandSortKey = "character"
local warbandSortAsc = true
local currencyWhatsNewFrame
local EnsureCurrencyWindow
local EnsureWarbandWindow
local warbandTextMeasure

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function CharacterKey()
    local name  = UnitName and UnitName("player") or "Unknown"
    local realm = GetRealmName and GetRealmName() or "Unknown"
    return name .. "-" .. realm
end

local preyTrackerUtil = {}

function preyTrackerUtil.NormalizeAvailabilityCounts(source)
    if type(source) ~= "table" then
        return nil
    end

    return {
        normal = math.max(0, select(2, pcall(tonumber, source.normal)) or 0),
        hard = math.max(0, select(2, pcall(tonumber, source.hard)) or 0),
        nightmare = math.max(0, select(2, pcall(tonumber, source.nightmare)) or 0),
        capturedAt = (select(2, pcall(tonumber, source.capturedAt))) or (GetTime and GetTime() or 0),
    }
end

function preyTrackerUtil.BuildScopeKey(charKey, level)
    local normalizedLevel = select(2, pcall(tonumber, level))
    if type(charKey) ~= "string" or charKey == "" or not normalizedLevel then
        return nil
    end
    return charKey .. "@" .. tostring(math.floor(normalizedLevel + 0.5))
end

function preyTrackerUtil.CanonicalizeWeeklyKey(rawKey)
    if type(rawKey) ~= "string" or rawKey == "" then
        return nil
    end

    if rawKey:match("^week%-%d%d%d%d%-%d%d$") then
        return rawKey
    end

    local suffix = rawKey:match("^(%d%d%d%d%-%d%d)$")
    if suffix then
        return "week-" .. suffix
    end

    return rawKey
end

function preyTrackerUtil.MergeWeeklyCounts(target, source)
    target.normal = math.max(0, select(2, pcall(tonumber, target.normal)) or 0) + math.max(0, select(2, pcall(tonumber, source and source.normal)) or 0)
    target.hard = math.max(0, select(2, pcall(tonumber, target.hard)) or 0) + math.max(0, select(2, pcall(tonumber, source and source.hard)) or 0)
    target.nightmare = math.max(0, select(2, pcall(tonumber, target.nightmare)) or 0) + math.max(0, select(2, pcall(tonumber, source and source.nightmare)) or 0)
    return target
end

function preyTrackerUtil.InferStoredWeeklyResetKey(currencyDB)
    if type(currencyDB) ~= "table" then
        return nil
    end

    local latestKey = nil
    local function consider(rawKey)
        local canonical = preyTrackerUtil.CanonicalizeWeeklyKey(rawKey)
        if canonical and (latestKey == nil or canonical > latestKey) then
            latestKey = canonical
        end
    end

    if type(currencyDB.preyWeeklyProgress) == "table" then
        for _, weeks in pairs(currencyDB.preyWeeklyProgress) do
            if type(weeks) == "table" then
                for rawKey in pairs(weeks) do
                    consider(rawKey)
                end
            end
        end
    end

    if type(currencyDB.preySnapshots) == "table" then
        for _, snap in pairs(currencyDB.preySnapshots) do
            if type(snap) == "table" then
                consider(snap.weeklyKey)
            end
        end
    end

    return latestKey
end

function preyTrackerUtil.GetBestScopedAvailabilityForCharacter(charKey, level)
    local api = Preydator and Preydator.API
    local settings = api and type(api.GetSettings) == "function" and api.GetSettings() or nil
    local huntData = settings and settings.huntScanner
    local cacheByScope = huntData and huntData.availabilityCacheByScope
    if type(cacheByScope) ~= "table" then
        return nil
    end

    local exactKey = preyTrackerUtil.BuildScopeKey(charKey, level)
    local exact = exactKey and preyTrackerUtil.NormalizeAvailabilityCounts(cacheByScope[exactKey])
    if exact then
        return exact
    end

    local prefix = type(charKey) == "string" and (charKey .. "@") or nil
    if not prefix then
        return nil
    end

    local bestCounts = nil
    local bestCapturedAt = -1
    for scopeKey, counts in pairs(cacheByScope) do
        if type(scopeKey) == "string" and scopeKey:sub(1, #prefix) == prefix then
            local normalized = preyTrackerUtil.NormalizeAvailabilityCounts(counts)
            local capturedAt = normalized and (select(2, pcall(tonumber, normalized.capturedAt)) or -1) or -1
            if normalized and capturedAt >= bestCapturedAt then
                bestCapturedAt = capturedAt
                bestCounts = normalized
            end
        end
    end

    return bestCounts
end

local function SafeToNumberLike(value)
    local okString, asString = pcall(tostring, value)
    if not okString or type(asString) ~= "string" then
        return nil
    end

    local numericToken = string.match(asString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
        or string.match(asString, "^%s*([%+%-]?%d*%.%d+)%s*$")
    if not numericToken then
        return nil
    end

    local okNumber, result = pcall(tonumber, numericToken)
    if okNumber and type(result) == "number" then
        return result
    end

    return nil
end

local function GetCurrencyInfoSafe(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil
    end

    local okInfo, info = pcall(C_CurrencyInfo.GetCurrencyInfo, currencyID)
    if not okInfo or type(info) ~= "table" then
        return nil
    end

    local name = type(info.name) == "string" and info.name or nil
    local quantity = SafeToNumberLike(info.quantity) or 0
    local iconFileID = SafeToNumberLike(info.iconFileID)

    return {
        name = name,
        quantity = quantity,
        iconFileID = iconFileID,
    }
end

local function GetCurrencyQuantity(currencyID)
    local info = GetCurrencyInfoSafe(currencyID)
    return (info and info.quantity) or 0
end

local function GetCurrencyIcon(currencyID)
    local info = GetCurrencyInfoSafe(currencyID)
    return info and info.iconFileID or nil
end

local function EnsureDB()
    _G.PreydatorDB = _G.PreydatorDB or {}
    _G.PreydatorDB.currency = _G.PreydatorDB.currency or {}
    local c = _G.PreydatorDB.currency
    c.snapshots    = c.snapshots    or {}
    c.warbandTotal = c.warbandTotal or {}
    c.preySnapshots = c.preySnapshots or {}
    c.preyWeeklyProgress = c.preyWeeklyProgress or {}
    c.preyAccountState = c.preyAccountState or {}

    local account = c.preyAccountState
    if account.nightmareUnlocked == nil then
        account.nightmareUnlocked = false
    end

    for _, snap in pairs(c.preySnapshots) do
        if type(snap) == "table" then
            local completed = type(snap.weeklyCompleted) == "table" and snap.weeklyCompleted or nil
            local available = type(snap.preyAvailableCounts) == "table" and snap.preyAvailableCounts or nil

            if (tonumber(completed and completed.nightmare) or 0) > 0 or (tonumber(available and available.nightmare) or 0) > 0 then
                account.nightmareUnlocked = true
            end
        end
    end

    if type(c.preyWeeklyProgress) == "table" then
        for charKey, weeks in pairs(c.preyWeeklyProgress) do
            if type(weeks) == "table" then
                local merged = {}
                for rawKey, entry in pairs(weeks) do
                    local canonicalKey = preyTrackerUtil.CanonicalizeWeeklyKey(rawKey) or rawKey
                    merged[canonicalKey] = preyTrackerUtil.MergeWeeklyCounts(merged[canonicalKey] or { normal = 0, hard = 0, nightmare = 0 }, entry)
                end
                c.preyWeeklyProgress[charKey] = merged
            end
        end
    end

    c.preyAccountState.available = nil

    c.lastWeeklyResetKey = preyTrackerUtil.CanonicalizeWeeklyKey(c.lastWeeklyResetKey)
        or preyTrackerUtil.InferStoredWeeklyResetKey(c)
        or ("week-" .. _G.date("%Y-%U"))

    db = c
end

local function GetPreyAccountState()
    EnsureDB()
    return db and db.preyAccountState
end

local function BuildAccountAvailabilityForLevel(level)
    local account = GetPreyAccountState()
    local now = GetTime and GetTime() or 0
    local normalizedLevel = tonumber(level) or 0
    local nightmareUnlocked = account and account.nightmareUnlocked == true

    local normal = (normalizedLevel >= 78) and 4 or 0
    local hard = (normalizedLevel >= 90) and 4 or 0
    local nightmare = (normalizedLevel >= 90 and nightmareUnlocked) and 4 or 0

    return {
        normal = normal,
        hard = hard,
        nightmare = nightmare,
        capturedAt = now,
    }
end

local function GetCurrentPreyState()
    if Preydator and type(Preydator.GetState) == "function" then
        return Preydator.GetState()
    end
    return nil
end

local function GetWeeklyCapsModule()
    return Preydator.GetModule and Preydator:GetModule("WeeklyCaps")
end

local function GetPreyDataModule()
    return Preydator.GetModule and Preydator:GetModule("PreyData")
end

local function BuildPreyRankLabel(stage, difficulty)
    if type(difficulty) == "string" and difficulty ~= "" then
        return difficulty
    end

    local stageNumber = tonumber(stage)
    if stageNumber and stageNumber > 0 then
        return string.format("Stage %d", stageNumber)
    end

    return L["No active prey"]
end

-- Weekly key ownership lives in WeeklyCaps; CurrencyTracker only consumes it.
local function GetWeeklyResetKey()
    local weeklyCaps = GetWeeklyCapsModule()
    if weeklyCaps and type(weeklyCaps.GetWeeklyResetKey) == "function" then
        return preyTrackerUtil.CanonicalizeWeeklyKey(weeklyCaps:GetWeeklyResetKey()) or ("week-" .. date("%Y-%U"))
    end

    if C_DateAndTime and type(C_DateAndTime.GetSecondsUntilWeeklyReset) == "function" and type(GetServerTime) == "function" then
        local okRemaining, remainingRaw = pcall(C_DateAndTime.GetSecondsUntilWeeklyReset)
        local remaining = okRemaining and tonumber(remainingRaw) or nil
        local serverNow = tonumber(GetServerTime()) or nil
        if remaining and remaining >= 0 and serverNow and serverNow > 0 then
            return "server-week-" .. tostring(math.floor(serverNow + remaining + 0.5))
        end
    end

    return "week-" .. date("%Y-%U")
end

-- Derives weekly caps from a character snapshot.
-- Normal: 4 if level >= 78.  Hard: 4 if level >= 90.
-- Nightmare: 4 only when the character has been seen doing nightmare difficulty
-- (nightmareUnlocked flag set by SnapshotCurrentPreyCharacter on level 90 + Renown 4).
local function GetWeeklyCapForSnap(snap)
    local level = tonumber(snap and snap.level) or 0
    local weeklyCaps = GetWeeklyCapsModule()
    if weeklyCaps and type(weeklyCaps.GetCapsForLevel) == "function" then
        return weeklyCaps:GetCapsForLevel(level)
    end
    return {
        normal = (level >= 78) and 4 or 0,
        hard = (level >= 90) and 4 or 0,
        nightmare = 0,
    }
end

-- Resets availability counts for every stored character to their weekly caps.
-- Called when a weekly reset is detected so warband totals immediately
-- reflect the freshly-restored availability without requiring a hunt-table scan.
local function ApplyWeeklyResetToSnapshots()
    if not db or type(db.preySnapshots) ~= "table" then
        return
    end
    local weeklyCaps = GetWeeklyCapsModule()
    local now = GetTime and GetTime() or 0
    if weeklyCaps and type(weeklyCaps.ApplyCapsToSnapshots) == "function" then
        weeklyCaps:ApplyCapsToSnapshots(db.preySnapshots, now)
        return
    end

    for charKey, snap in pairs(db.preySnapshots) do
        if type(snap) == "table" then
            local level = tonumber(snap.level) or 0
            snap.preyAvailableCounts = BuildAccountAvailabilityForLevel(level)
            snap.preyAvailabilityKnown = false
            snap.preyAvailabilitySource = "derived_reset"
            snap.weeklyKey = db.lastWeeklyResetKey or GetWeeklyResetKey()
            snap.weeklyCompleted = GetPreyWeeklyCompleted(charKey, snap.weeklyKey) or snap.weeklyCompleted
        end
    end
end

-- Detects whether a WoW weekly reset has occurred since the last recorded epoch
-- and resets cached availability counts when it has.
-- Gated: does nothing when the warband module is disabled.
local function CheckAndProcessWeeklyReset()
    EnsureDB()
    local weeklyCaps = GetWeeklyCapsModule()
    if weeklyCaps and type(weeklyCaps.ProcessReset) == "function" then
        weeklyCaps:ProcessReset(db.preySnapshots, GetTime and GetTime() or 0)
        return
    end

    local currentWeekKey = GetWeeklyResetKey()
    local previousWeekKey = preyTrackerUtil.CanonicalizeWeeklyKey(db.lastWeeklyResetKey)
        or preyTrackerUtil.InferStoredWeeklyResetKey(db)
        or currentWeekKey

    if previousWeekKey ~= currentWeekKey then
        db.lastWeeklyResetKey = currentWeekKey
        ApplyWeeklyResetToSnapshots()
        local scanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
        if scanner and type(scanner.ClearAvailabilityCache) == "function" then
            scanner:ClearAvailabilityCache()
        end
    else
        db.lastWeeklyResetKey = currentWeekKey
    end
end

local function NormalizePreyDifficultyKey(diff)
    local weeklyCaps = GetWeeklyCapsModule()
    if weeklyCaps and type(weeklyCaps.NormalizeDifficultyKey) == "function" then
        return weeklyCaps:NormalizeDifficultyKey(diff)
    end
    local text = tostring(diff or "")
    if text:find("Nightmare", 1, true) then return "nightmare" end
    if text:find("Hard", 1, true) then return "hard" end
    return "normal"
end

GetPreyWeeklyCompleted = function(charKey, weekKey)
    local preyData = GetPreyDataModule()
    if preyData and type(preyData.GetOrCreateWeeklyProgress) == "function" then
        return preyData:GetOrCreateWeeklyProgress(charKey, weekKey)
    end
    EnsureDB()
    local weeks = db.preyWeeklyProgress[charKey]
    if type(weeks) ~= "table" then
        weeks = {}
        db.preyWeeklyProgress[charKey] = weeks
    end

    local entry = weeks[weekKey]
    if type(entry) ~= "table" then
        entry = { normal = 0, hard = 0, nightmare = 0 }
        weeks[weekKey] = entry
    end

    entry.normal = math.max(0, tonumber(entry.normal) or 0)
    entry.hard = math.max(0, tonumber(entry.hard) or 0)
    entry.nightmare = math.max(0, tonumber(entry.nightmare) or 0)
    return entry
end

local function GetPreyAvailabilityFromHuntScanner()
    local scanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
    if not scanner or type(scanner.GetAvailabilityCounts) ~= "function" then
        return nil, false
    end

    local counts = scanner:GetAvailabilityCounts()
    if type(counts) ~= "table" then
        return nil, false
    end

    if counts.known == false then
        return nil, false
    end

    return {
        normal = math.max(0, tonumber(counts.normal) or 0),
        hard = math.max(0, tonumber(counts.hard) or 0),
        nightmare = math.max(0, tonumber(counts.nightmare) or 0),
        capturedAt = GetTime and GetTime() or 0,
    }, true
end

local function RecordPreyTurnIn(questID)
    local id = tonumber(questID)
    if not id or id < 1 then
        return
    end

    local state = GetCurrentPreyState()
    if not state or tonumber(state.activeQuestID) ~= id then
        return
    end

    EnsureDB()
    local key = CharacterKey()
    local weekKey = GetWeeklyResetKey()
    local preyData = GetPreyDataModule()
    if preyData and type(preyData.RecordWeeklyCompletion) == "function" then
        preyData:RecordWeeklyCompletion(key, weekKey, state.preyTargetDifficulty)
        return
    end

    -- Fallback: PreyData module unavailable, write weekly completion directly.
    local diffKey = NormalizePreyDifficultyKey(state.preyTargetDifficulty)
    local weeklyCompleted = GetPreyWeeklyCompleted(key, weekKey)
    weeklyCompleted[diffKey] = (tonumber(weeklyCompleted[diffKey]) or 0) + 1
    if db and db.preySnapshots and type(db.preySnapshots[key]) == "table" then
        local snap = db.preySnapshots[key]
        snap.weeklyCompleted = weeklyCompleted
        snap.weeklyKey = weekKey
        if type(snap.preyAvailableCounts) == "table" then
            snap.preyAvailableCounts[diffKey] = math.max(0, (tonumber(snap.preyAvailableCounts[diffKey]) or 0) - 1)
            snap.preyAvailableCounts.capturedAt = GetTime and GetTime() or 0
        end
    end
end

local function BuildPreyProgressTriplet(snap, mode)
    local level = tonumber(snap and snap.level) or 0
    local account = GetPreyAccountState()
    local maxNormal = (level >= 78) and 4 or 0
    local maxHard = (level >= 90) and 4 or 0
    local maxNightmare = (level >= 90 and account and account.nightmareUnlocked == true) and 4 or 0

    local completed = type(snap and snap.weeklyCompleted) == "table" and snap.weeklyCompleted or {}
    local normalDone = math.max(0, tonumber(completed.normal) or 0)
    local hardDone = math.max(0, tonumber(completed.hard) or 0)
    local nightmareDone = math.max(0, tonumber(completed.nightmare) or 0)
    local availabilityKnown = (snap and snap.preyAvailabilityKnown == true)

    if hardDone > 0 and maxHard == 0 then
        maxHard = 4
    end
    if nightmareDone > 0 and maxNightmare == 0 then
        maxNightmare = 4
    end
    if maxNightmare > 0 and maxHard == 0 then
        maxHard = 4
    end

    local available = type(snap and snap.preyAvailableCounts) == "table" and snap.preyAvailableCounts or nil

    if (tonumber(nightmareDone) or 0) > 0 and account and account.nightmareUnlocked ~= true then
        account.nightmareUnlocked = true
        maxNightmare = (level >= 90) and 4 or 0
    end

    if not availabilityKnown and not available and normalDone == 0 and hardDone == 0 and nightmareDone == 0 then
        return "?/?/?"
    end

    if available then
        local availableNormal = math.max(0, tonumber(available.normal) or 0)
        local availableHard = math.max(0, tonumber(available.hard) or 0)
        local availableNightmare = math.max(0, tonumber(available.nightmare) or 0)

        if level >= 90 then
            if availableHard > 0 and maxHard == 0 then
                maxHard = 4
            end
            if availableNightmare > 0 and maxNightmare == 0 then
                maxNightmare = 4
            end
            if maxNightmare > 0 and maxHard == 0 then
                maxHard = 4
            end
        end

        maxNormal = math.max(maxNormal, availableNormal + normalDone)
        maxHard = math.max(maxHard, availableHard + hardDone)
        maxNightmare = math.max(maxNightmare, availableNightmare + nightmareDone)
    end

    if mode ~= "completed" then
        local nLeft
        local hLeft
        local niLeft

        if available then
            nLeft = math.max(0, tonumber(available.normal) or 0)
            hLeft = (maxHard > 0) and math.max(0, tonumber(available.hard) or 0) or nil
            niLeft = (maxNightmare > 0) and math.max(0, tonumber(available.nightmare) or 0) or nil
        else
            nLeft = math.max(0, maxNormal - normalDone)
            hLeft = (maxHard > 0) and math.max(0, maxHard - hardDone) or nil
            niLeft = (maxNightmare > 0) and math.max(0, maxNightmare - nightmareDone) or nil
        end

        local n = tostring(nLeft)
        local h = (hLeft ~= nil) and tostring(hLeft) or "-"
        local ni = (niLeft ~= nil) and tostring(niLeft) or "-"
        return n .. "/" .. h .. "/" .. ni
    end

    local nDoneDisplay = normalDone
    local hDoneDisplay = hardDone
    local niDoneDisplay = nightmareDone

    if available then
        nDoneDisplay = math.max(normalDone, math.max(0, maxNormal - (tonumber(available.normal) or 0)))
        if maxHard > 0 then
            hDoneDisplay = math.max(hardDone, math.max(0, maxHard - (tonumber(available.hard) or 0)))
        end
        if maxNightmare > 0 then
            niDoneDisplay = math.max(nightmareDone, math.max(0, maxNightmare - (tonumber(available.nightmare) or 0)))
        end
    end

    local n = tostring(nDoneDisplay)
    local h = (maxHard > 0) and tostring(hDoneDisplay) or "-"
    local ni = (maxNightmare > 0) and tostring(niDoneDisplay) or "-"
    return n .. "/" .. h .. "/" .. ni
end

local function SnapshotCurrentPreyCharacter()
    EnsureDB()
    local state = GetCurrentPreyState()
    if not state then
        return
    end

    local key = CharacterKey()
    local availableCounts, availabilityKnown = GetPreyAvailabilityFromHuntScanner()
    local level = _G.UnitLevel and (tonumber(_G.UnitLevel("player")) or 0) or 0

    local account = GetPreyAccountState()
    if account then
        local diffKey = NormalizePreyDifficultyKey(state.preyTargetDifficulty)
        if diffKey == "nightmare" or ((type(availableCounts) == "table") and (tonumber(availableCounts.nightmare) or 0) > 0) then
            account.nightmareUnlocked = true
        end
    end

    local preyData = GetPreyDataModule()
    if preyData and type(preyData.CaptureSnapshot) == "function" then
        preyData:CaptureSnapshot(key, state, availableCounts, availabilityKnown)
    else
        -- Fallback: PreyData module unavailable, write snapshot directly.
        local zoneName = GetZoneText and (GetZoneText() or "") or ""
        local classFile = nil
        if UnitClass then
            local _, token = UnitClass("player")
            classFile = token
        end
        local weekKey = GetWeeklyResetKey()
        local weeklyCompleted = GetPreyWeeklyCompleted(key, weekKey)
        local existingSnap = db and db.preySnapshots and db.preySnapshots[key]
        local derivedAvailability = BuildAccountAvailabilityForLevel(level)
        local scopedAvailability = preyTrackerUtil.GetBestScopedAvailabilityForCharacter(key, level)
        local finalAvailability = (availabilityKnown == true and type(availableCounts) == "table") and availableCounts
            or scopedAvailability
            or (type(existingSnap) == "table" and existingSnap.preyAvailableCounts)
            or derivedAvailability
            or nil
        local finalAvailabilityKnown = availabilityKnown == true or scopedAvailability ~= nil
        if db and db.preySnapshots then
            db.preySnapshots[key] = {
                stage                = tonumber(state.stage) or 0,
                level                = level,
                zoneName             = zoneName,
                activeQuestID        = tonumber(state.activeQuestID) or 0,
                inPreyZone           = state.inPreyZone == true,
                preyTargetName       = state.preyTargetName,
                preyTargetDifficulty = state.preyTargetDifficulty,
                weeklyKey            = weekKey,
                weeklyCompleted      = weeklyCompleted or { normal = 0, hard = 0, nightmare = 0 },
                preyAvailableCounts  = preyTrackerUtil.NormalizeAvailabilityCounts(finalAvailability),
                preyAvailabilityKnown = finalAvailabilityKnown,
                preyAvailabilitySource = availabilityKnown == true and "live_huntscanner"
                    or (scopedAvailability ~= nil and "scoped_cache")
                    or "derived_default",
                capturedAt           = GetTime and GetTime() or 0,
                classFile            = classFile,
            }
        end
    end

    -- Promote any newly observed difficulty to permanent account-wide flags (never reset).
    local weeklyCaps = GetWeeklyCapsModule()
    if weeklyCaps and type(weeklyCaps.ObserveDifficulty) == "function" then
        weeklyCaps:ObserveDifficulty(state.preyTargetDifficulty)
    end
end

local function GetPreySnapshotRows()
    local preyData = GetPreyDataModule()
    if preyData and type(preyData.GetAllSnapshots) == "function" then
        return preyData:GetAllSnapshots()
    end

    if not db or type(db.preySnapshots) ~= "table" then
        return {}
    end

    local rows = {}
    for charKey, snap in pairs(db.preySnapshots) do
        rows[#rows + 1] = { charKey = charKey, snap = snap }
    end

    local currentKey = CharacterKey()
    table.sort(rows, function(a, b)
        local aIsCurrent = a.charKey == currentKey
        local bIsCurrent = b.charKey == currentKey
        if aIsCurrent ~= bIsCurrent then
            return aIsCurrent
        end
        return a.charKey < b.charKey
    end)

    return rows
end

local function IsCurrencyDebugEnabled()
    local api = Preydator and Preydator.API
    if not api or type(api.GetSettings) ~= "function" then
        return false
    end

    local settings = api.GetSettings()
    return settings and settings.currencyDebugEvents == true
end

local function LogCurrencyDebug(message)
    if not IsCurrencyDebugEnabled() then
        return
    end

    print("Preydator CurrencyDebug: " .. tostring(message))
end

local function SnapshotCurrentCharacter()
    EnsureDB()
    local key = CharacterKey()
    db.snapshots[key] = db.snapshots[key] or {}
    local classFile = nil
    if UnitClass then
        local _, token = UnitClass("player")
        classFile = token
    end

    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        local qty = GetCurrencyQuantity(entry.id)
        db.snapshots[key][entry.id] = { quantity = qty, lastSeen = GetTime(), classFile = classFile }
    end
end

local function PrimeSessionBaseline(source)
    EnsureDB()

    local key = CharacterKey()
    local existing = db and db.snapshots and db.snapshots[key] or nil
    local allZero = true
    local hasExistingNonZero = false

    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        local qty = GetCurrencyQuantity(entry.id)
        sessionStart[entry.id] = qty
        if qty ~= 0 then
            allZero = false
        end

        local prev = existing and existing[entry.id]
        if type(prev) == "table" and (tonumber(prev.quantity) or 0) > 0 then
            hasExistingNonZero = true
        end
    end

    -- If the API is still cold at login, keep deltas hidden until a valid baseline lands.
    if allZero and hasExistingNonZero then
        sessionBaselineReady = false
        LogCurrencyDebug("SessionBaseline pending [" .. tostring(source or "unknown") .. "]: API returned zeros while prior snapshot has non-zero totals")
        return false
    end

    sessionBaselineReady = true
    local parts = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        parts[#parts + 1] = entry.label .. "=" .. tostring(sessionStart[entry.id] or 0)
    end
    LogCurrencyDebug("SessionBaseline ready [" .. tostring(source or "unknown") .. "]: " .. table.concat(parts, ", "))
    return true
end

local function UpdateLastKnownQuantities()
    local changedEntries = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        local qty = GetCurrencyQuantity(entry.id)
        local oldQty = lastKnownQuantity[entry.id]
        if oldQty == nil then
            lastKnownQuantity[entry.id] = qty
        elseif oldQty ~= qty then
            changedEntries[#changedEntries + 1] = {
                id = entry.id,
                label = entry.label,
                old = oldQty,
                new = qty,
            }
            lastKnownQuantity[entry.id] = qty
        end
    end
    return changedEntries
end

local function SessionDelta(currencyID)
    if not sessionBaselineReady then
        return 0
    end
    local start = sessionStart[currencyID]
    if not start then return 0 end
    return GetCurrencyQuantity(currencyID) - start
end

-- Rebuild the warband aggregate from all known snapshots
local function RebuildWarbandTotals()
    if not db then return end
    db.warbandTotal = {}
    for _, charSnaps in pairs(db.snapshots) do
        for currencyID, snap in pairs(charSnaps) do
            db.warbandTotal[currencyID] = (db.warbandTotal[currencyID] or 0) + (snap.quantity or 0)
        end
    end
end

-- Returns sorted list of { charKey, snaps } for warband table display
local function GetWarbandRows()
    if not db then return {} end
    local rows = {}
    for charKey, snaps in pairs(db.snapshots) do
        rows[#rows + 1] = { charKey = charKey, snaps = snaps }
    end
    local currentKey = CharacterKey()
    table.sort(rows, function(a, b)
        -- Current character first, then alphabetical for stable ordering.
        local aIsCurrent = a.charKey == currentKey
        local bIsCurrent = b.charKey == currentKey
        if aIsCurrent ~= bIsCurrent then
            return aIsCurrent
        end
        return a.charKey < b.charKey
    end)
    return rows
end

local function IsWarbandCharacterShown(settings, charKey)
    if not settings or type(settings.currencyWarbandCharacterVisibility) ~= "table" then
        return true
    end
    return settings.currencyWarbandCharacterVisibility[charKey] ~= false
end

local function GetPreyLevelForCharacter(charKey)
    local snap = db and db.preySnapshots and db.preySnapshots[charKey]
    return tonumber(snap and snap.level)
end

local function GetKnownWarbandCharacters()
    local known = {}
    local rows = {}
    local currentKey = CharacterKey()

    if db and type(db.snapshots) == "table" then
        for charKey in pairs(db.snapshots) do
            known[charKey] = true
        end
    end
    if db and type(db.preySnapshots) == "table" then
        for charKey in pairs(db.preySnapshots) do
            known[charKey] = true
        end
    end

    for charKey in pairs(known) do
        local charName, realmName = charKey:match("^(.-)%-(.+)$")
        if not charName then
            charName = charKey
            realmName = "Unknown"
        end
        rows[#rows + 1] = {
            charKey = charKey,
            charName = charName,
            realmName = realmName,
            level = GetPreyLevelForCharacter(charKey),
            isCurrent = (charKey == currentKey),
        }
    end

    table.sort(rows, function(left, right)
        if left.isCurrent ~= right.isCurrent then
            return left.isCurrent
        end
        return left.charKey < right.charKey
    end)

    return rows
end

local function EnsureWarbandTextMeasure()
    if warbandTextMeasure then
        return warbandTextMeasure
    end

    local owner = UIParent or CreateFrame("Frame", nil)
    warbandTextMeasure = owner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    warbandTextMeasure:Hide()
    return warbandTextMeasure
end

local function MeasureWarbandTextWidth(text, fontSize, fontPath)
    local measure = EnsureWarbandTextMeasure()
    if measure.SetFont then
        measure:SetFont(fontPath, fontSize, "")
    end
    measure:SetText(text or "")
    return math.ceil((measure.GetStringWidth and measure:GetStringWidth() or 0) + 8)
end

local function GetWarbandCharacterColumnWidth(showRealm, fontSize, fontPath)
    local minWidth = showRealm and 76 or 124
    local textFontSize = math.max(10, fontSize - 1)
    local headerFontSize = math.max(10, fontSize - 2)
    local width = minWidth

    width = math.max(width, MeasureWarbandTextWidth(L["Character"], headerFontSize, fontPath))
    width = math.max(width, MeasureWarbandTextWidth(L["Totals"], headerFontSize, fontPath))

    for _, entry in ipairs(GetKnownWarbandCharacters()) do
        width = math.max(width, MeasureWarbandTextWidth(entry.charName, textFontSize, fontPath))
    end

    return width
end

-- UI helpers and tracker settings
--------------------------------------------------------------------------------

local function SetTextColor(fs, col)
    if col then
        fs:SetTextColor(col[1], col[2], col[3], col[4] or 1)
    end
end

local function ClampNumber(value, minValue, maxValue, fallback)
    local numeric = tonumber(value)
    if not numeric then
        return fallback
    end
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return math.floor(numeric + 0.5)
end

local function ClampFloat(value, minValue, maxValue, fallback, decimals)
    local numeric = tonumber(value)
    if not numeric then
        return fallback
    end
    if numeric < minValue then
        numeric = minValue
    elseif numeric > maxValue then
        numeric = maxValue
    end

    if type(decimals) == "number" and decimals >= 0 then
        local mult = 10 ^ decimals
        numeric = math.floor((numeric * mult) + 0.5) / mult
    end
    return numeric
end

local function SetFontSize(fs, size, fontPath)
    if not fs or type(fs.GetFont) ~= "function" or type(fs.SetFont) ~= "function" then
        return
    end
    local currentPath, _, flags = fs:GetFont()
    local resolvedPath = fontPath or currentPath
    if resolvedPath then
        fs:SetFont(resolvedPath, size, flags)
    end
end

local function ColorsClose(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return false
    end
    local epsilon = 0.001
    for i = 1, 4 do
        local l = tonumber(left[i] or 1) or 1
        local r = tonumber(right[i] or 1) or 1
        if math.abs(l - r) > epsilon then
            return false
        end
    end
    return true
end

local function GetSettings()
    local api = Preydator and Preydator.API
    if not api or type(api.GetSettings) ~= "function" then
        return nil
    end
    return api.GetSettings()
end

local function ResolveTheme(key, settings)
    local function BuildTheme(source, fallback)
        local out = {}
        for _, colorKey in ipairs(THEME_COLOR_KEYS) do
            local color = source and source[colorKey]
            if type(color) ~= "table" then
                color = fallback and fallback[colorKey]
            end
            if type(color) == "table" then
                out[colorKey] = {
                    tonumber(color[1]) or 1,
                    tonumber(color[2]) or 1,
                    tonumber(color[3]) or 1,
                    tonumber(color[4]) or 1,
                }
            else
                out[colorKey] = { 1, 1, 1, 1 }
            end
        end
        out.fontKey = type(source and source.fontKey) == "string" and source.fontKey
            or type(fallback and fallback.fontKey) == "string" and fallback.fontKey
            or "frizqt"
        return out
    end

    if THEME_PRESETS[key] then
        return BuildTheme(THEME_PRESETS[key], THEME_PRESETS.brown)
    end
    if settings and type(settings.customThemes) == "table" and type(settings.customThemes[key]) == "table" then
        return BuildTheme(settings.customThemes[key], THEME_PRESETS.brown)
    end
    return BuildTheme(THEME_PRESETS.brown, THEME_PRESETS.brown)
end

local function GetThemeFontPath(theme)
    local fontKey = theme and theme.fontKey
    local path = FONT_PATHS[fontKey] or FONT_PATHS.frizqt
    if _G.GetLocale and (_G.GetLocale() == "ruRU" or _G.GetLocale() == "koKR" or _G.GetLocale() == "zhCN" or _G.GetLocale() == "zhTW")
        and type(_G.STANDARD_TEXT_FONT) == "string" and _G.STANDARD_TEXT_FONT ~= ""
    then
        return _G.STANDARD_TEXT_FONT
    end
    return path
end

local function GetThemePreset()
    local settings = GetSettings()
    local key = settings and settings.currencyTheme or "brown"
    local theme = ResolveTheme(key, settings)
    
    -- Apply editor font when preview is enabled
    if settings and settings.themeEditorPreviewInOptions == true then
        theme.fontKey = settings.themeEditorFontKey or theme.fontKey or "frizqt"
    end
    
    return theme
end

local function GetWarbandThemePreset()
    local settings = GetSettings()
    local useCurrencyTheme = not settings or settings.currencyWarbandUseCurrencyTheme ~= false
    local key = useCurrencyTheme and (settings and settings.currencyTheme or "brown") or (settings and settings.currencyWarbandTheme or "brown")
    local theme = ResolveTheme(key, settings)
    
    -- Apply editor font when preview is enabled
    if settings and settings.themeEditorPreviewInOptions == true then
        theme.fontKey = settings.themeEditorFontKey or theme.fontKey or "frizqt"
    end
    
    return theme
end

local function EnsureTrackerSettings()
    local settings = GetSettings()
    if not settings then
        return
    end

    if settings.currencyWindowEnabled == nil then
        settings.currencyWindowEnabled = false
    end

    if settings.currencyMinimapButton == nil then
        settings.currencyMinimapButton = true
    end

    if type(settings.currencyMinimapAngle) ~= "number" then
        settings.currencyMinimapAngle = 225
    end

    if type(settings.currencyMinimap) ~= "table" then
        settings.currencyMinimap = {}
    end
    if settings.currencyMinimap.hide == nil then
        settings.currencyMinimap.hide = settings.currencyMinimapButton == false
    end
    if type(settings.currencyMinimap.minimapPos) ~= "number" then
        settings.currencyMinimap.minimapPos = settings.currencyMinimapAngle
    end
    settings.currencyMinimapButton = settings.currencyMinimap.hide ~= true
    settings.currencyMinimapAngle = settings.currencyMinimap.minimapPos

    if type(settings.currencyWindowPoint) ~= "table" then
        settings.currencyWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 340, y = -80 }
    end

    if settings.currencyWarbandWindowEnabled == nil then
        settings.currencyWarbandWindowEnabled = false
    end

    if type(settings.currencyWarbandWindowPoint) ~= "table" then
        settings.currencyWarbandWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 660, y = -80 }
    end

    if settings.currencyShowAffordableHunts == nil then
        settings.currencyShowAffordableHunts = false
    end

    if settings.currencyWarbandHideLowLevel == nil then
        settings.currencyWarbandHideLowLevel = false
    end

    if settings.currencyShowRealmInWarband == nil then
        settings.currencyShowRealmInWarband = false
    end

    if settings.currencyWarbandShowPreyTrack == nil then
        settings.currencyWarbandShowPreyTrack = true
    end

    if settings.currencyWindowMouseoverHide == nil then
        settings.currencyWindowMouseoverHide = false
    end

    if settings.currencyWarbandMouseoverHide == nil then
        settings.currencyWarbandMouseoverHide = false
    end

    if settings.currencyWindowHideInInstance == nil then
        settings.currencyWindowHideInInstance = false
    end

    if settings.currencyWarbandWindowHideInInstance == nil then
        settings.currencyWarbandWindowHideInInstance = false
    end

    if settings.currencyWarbandUseIcons == nil then
        settings.currencyWarbandUseIcons = false
    end

    if settings.currencyWarbandPreyMode ~= "completed" and settings.currencyWarbandPreyMode ~= "available" then
        settings.currencyWarbandPreyMode = "available"
    end

    if settings.currencyWarbandUseCurrencyTheme == nil then
        settings.currencyWarbandUseCurrencyTheme = true
    end

    if settings.themeUseClassColors == nil then
        settings.themeUseClassColors = true
    end

    if type(settings.currencyWarbandTheme) ~= "string" then
        settings.currencyWarbandTheme = "brown"
    end

    if type(settings.currencyTheme) ~= "string" then
        settings.currencyTheme = "brown"
    end

    if type(settings.currencyDeltaGainColor) ~= "table" then
        settings.currencyDeltaGainColor = { COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3], COLOR_GREEN[4] }
    elseif ColorsClose(settings.currencyDeltaGainColor, LEGACY_GAIN_COLOR) then
        settings.currencyDeltaGainColor = { COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3], COLOR_GREEN[4] }
    end

    if type(settings.currencyDeltaLossColor) ~= "table" then
        settings.currencyDeltaLossColor = { COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], COLOR_RED[4] }
    elseif ColorsClose(settings.currencyDeltaLossColor, LEGACY_LOSS_COLOR) then
        settings.currencyDeltaLossColor = { COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], COLOR_RED[4] }
    end

    if type(settings.currencyTrackedIDs) ~= "table" then
        settings.currencyTrackedIDs = {}
    end

    if type(settings.currencyWarbandTrackedIDs) ~= "table" then
        settings.currencyWarbandTrackedIDs = {}
    end

    if type(settings.currencyWarbandCharacterVisibility) ~= "table" then
        settings.currencyWarbandCharacterVisibility = {}
    end

    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        local defaultTracked = entry.group ~= "crafting"
        if settings.currencyTrackedIDs[entry.id] == nil then
            settings.currencyTrackedIDs[entry.id] = defaultTracked
        end
        if settings.currencyWarbandTrackedIDs[entry.id] == nil then
            settings.currencyWarbandTrackedIDs[entry.id] = defaultTracked
        end
    end

    if type(settings.currencyCategoryCollapsed) ~= "table" then
        settings.currencyCategoryCollapsed = {}
    end
    if settings.currencyCategoryCollapsed.expansion == nil then
        settings.currencyCategoryCollapsed.expansion = false
    end
    if settings.currencyCategoryCollapsed.seasonal == nil then
        settings.currencyCategoryCollapsed.seasonal = false
    end
    if settings.currencyCategoryCollapsed.crafting == nil then
        settings.currencyCategoryCollapsed.crafting = false
    end

    if type(settings.randomHuntCosts) ~= "table" then
        settings.randomHuntCosts = {}
    end
    if type(settings.randomHuntCosts.normal) ~= "number" or settings.randomHuntCosts.normal <= 0 then
        settings.randomHuntCosts.normal = 50
    end
    if type(settings.randomHuntCosts.hard) ~= "number" or settings.randomHuntCosts.hard <= 0 then
        settings.randomHuntCosts.hard = 50
    end
    if type(settings.randomHuntCosts.nightmare) ~= "number" or settings.randomHuntCosts.nightmare <= 0 then
        settings.randomHuntCosts.nightmare = 50
    end

    settings.currencyWindowWidth = ClampNumber(settings.currencyWindowWidth, TRACKER_MIN_WIDTH, TRACKER_MAX_WIDTH, TRACKER_WINDOW_WIDTH)
    settings.currencyWindowHeight = ClampNumber(settings.currencyWindowHeight, TRACKER_MIN_HEIGHT, TRACKER_MAX_HEIGHT, TRACKER_WINDOW_HEIGHT)
    settings.currencyWindowFontSize = ClampNumber(settings.currencyWindowFontSize, TRACKER_MIN_FONT, TRACKER_MAX_FONT, TRACKER_DEFAULT_FONT)
    settings.currencyWindowScale = ClampFloat(settings.currencyWindowScale, TRACKER_MIN_SCALE, TRACKER_MAX_SCALE, TRACKER_DEFAULT_SCALE, 2)

    settings.currencyWarbandWidth = ClampNumber(settings.currencyWarbandWidth, WARBAND_MIN_WIDTH, WARBAND_MAX_WIDTH, WARBAND_DEFAULT_WIDTH)
    settings.currencyWarbandHeight = ClampNumber(settings.currencyWarbandHeight, WARBAND_MIN_HEIGHT, WARBAND_MAX_HEIGHT, WARBAND_DEFAULT_HEIGHT)
    settings.currencyWarbandFontSize = ClampNumber(settings.currencyWarbandFontSize, WARBAND_MIN_FONT, WARBAND_MAX_FONT, WARBAND_DEFAULT_FONT)
    settings.currencyWarbandScale = ClampFloat(settings.currencyWarbandScale, WARBAND_MIN_SCALE, WARBAND_MAX_SCALE, WARBAND_DEFAULT_SCALE, 2)

    if type(settings.currencyWarbandCollapsedRealms) ~= "table" then
        settings.currencyWarbandCollapsedRealms = {}
    end
end

local function GetTrackedCurrencyEntries()
    local settings = GetSettings()
    if not settings or type(settings.currencyTrackedIDs) ~= "table" then
        return CURRENCY_ALLOW_LIST
    end

    local rows = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        if settings.currencyTrackedIDs[entry.id] ~= false then
            rows[#rows + 1] = entry
        end
    end

    if #rows == 0 then
        rows[1] = CURRENCY_ALLOW_LIST[1]
    end

    return rows
end

local function GetCurrencyEntriesForGroup(group)
    local rows = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        if entry.group == group then
            rows[#rows + 1] = entry
        end
    end
    return rows
end

local function IsCurrencyTracked(settings, currencyID)
    if not settings or type(settings.currencyTrackedIDs) ~= "table" then
        return true
    end
    return settings.currencyTrackedIDs[currencyID] ~= false
end

local function IsWarbandCurrencyTracked(settings, currencyID)
    if not settings or type(settings.currencyWarbandTrackedIDs) ~= "table" then
        return true
    end
    return settings.currencyWarbandTrackedIDs[currencyID] ~= false
end

local currencyWindow
local currencyWindowRows = {}
local currencyWindowSummary
local currencyPanelPage
local warbandWindow
local warbandWindowSummary
local warbandWindowRows = {}
local warbandHeaderTexts = {}
local warbandTotalTexts = {}
local warbandHeaderButtons = {}
local warbandHeaderIcons = {}
local warbandColumns = {}

local AUTO_HIDE_ALPHA = 0.02
local AUTO_HIDE_VERIFY_INTERVAL = 0.50

local function GetWindowAutoHideEnabled(settingKey)
    local settings = GetSettings()
    if not settings then
        return false
    end

    if settingKey == "currency" then
        return settings.currencyWindowMouseoverHide == true
    end
    if settingKey == "warband" then
        return settings.currencyWarbandMouseoverHide == true
    end
    return false
end

local function SetWindowAutoHideEnabled(settingKey, enabled)
    local settings = GetSettings()
    if not settings then
        return
    end

    if settingKey == "currency" then
        settings.currencyWindowMouseoverHide = enabled and true or false
    elseif settingKey == "warband" then
        settings.currencyWarbandMouseoverHide = enabled and true or false
    end
end

local function ApplyWindowAutoHideState(frame, settingKey)
    if not frame then
        return
    end

    local enabled = GetWindowAutoHideEnabled(settingKey)
    if not enabled then
        frame:SetAlpha(1)
        return
    end

    local inCombat = InCombatLockdown and InCombatLockdown() == true
    if inCombat then
        frame:SetAlpha(AUTO_HIDE_ALPHA)
        return
    end

    if frame.IsMouseOver and frame:IsMouseOver() then
        frame:SetAlpha(1)
    else
        frame:SetAlpha(AUTO_HIDE_ALPHA)
    end
end

local function AttachWindowAutoHideHooks(frame, settingKey)
    if not frame or frame.PreydatorAutoHideHooksAttached == true then
        return
    end

    frame.PreydatorAutoHideHooksAttached = true
    frame.PreydatorAutoHideSettingKey = settingKey

    frame:HookScript("OnEnter", function(self)
        ApplyWindowAutoHideState(self, self.PreydatorAutoHideSettingKey)
    end)

    frame:HookScript("OnLeave", function(self)
        ApplyWindowAutoHideState(self, self.PreydatorAutoHideSettingKey)
    end)

    frame:HookScript("OnShow", function(self)
        ApplyWindowAutoHideState(self, self.PreydatorAutoHideSettingKey)
    end)

    -- Add periodic verification in case OnLeave fails during quick mouse movements.
    -- This ensures the alpha state is always correct even if the event misses.
    frame:HookScript("OnUpdate", function(self, elapsed)
        if not self:IsShown() then
            return
        end
        if not GetWindowAutoHideEnabled(self.PreydatorAutoHideSettingKey) then
            self.PreydatorAutoHideElapsed = 0
            return
        end

        self.PreydatorAutoHideElapsed = (self.PreydatorAutoHideElapsed or 0) + (elapsed or 0)
        if self.PreydatorAutoHideElapsed < AUTO_HIDE_VERIFY_INTERVAL then
            return
        end
        self.PreydatorAutoHideElapsed = 0
        ApplyWindowAutoHideState(self, self.PreydatorAutoHideSettingKey)
    end)
end

local function CreateWindowAutoHideButton(parent, closeButton, settingKey)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(18, 18)
    button:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\ICONS\\Ability_Hunter_EagleEye")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local function RefreshVisual()
        local enabled = GetWindowAutoHideEnabled(settingKey)
        icon:SetDesaturated(not enabled)
        if enabled then
            icon:SetVertexColor(1, 1, 1, 1)
        else
            icon:SetVertexColor(0.65, 0.65, 0.65, 0.9)
        end
    end

    button:SetScript("OnClick", function()
        local enabled = not GetWindowAutoHideEnabled(settingKey)
        SetWindowAutoHideEnabled(settingKey, enabled)
        RefreshVisual()
        ApplyWindowAutoHideState(parent, settingKey)
    end)

    button:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L["Mouseover Hide"], 1.0, 0.82, 0)
        GameTooltip:AddLine(L["Panel hides until moused over."], 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine(L["In combat it stays hidden until out of combat."], 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine(L["Click to toggle."], 0.65, 0.95, 0.65)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    button.PreydatorRefresh = RefreshVisual
    RefreshVisual()
    return button
end

local function IsWarbandCurrencyColumn(columnKey)
    return type(columnKey) == "number"
end

local function GetWarbandCurrencyHeaderLabel(columnKey, fallbackLabel)
    if columnKey == 3310 then
        return L["Shards"]
    end
    if columnKey == 3028 then
        return L["Keys"]
    end
    return fallbackLabel
end

local function OpenOptionsPanel()
    local settingsModule = Preydator:GetModule("Settings")
    if settingsModule and type(settingsModule.OpenOptionsPanel) == "function" then
        settingsModule:OpenOptionsPanel()
    end
end

local function EnsureCurrencyWhatsNewFrame()
    if currencyWhatsNewFrame then
        return currencyWhatsNewFrame
    end

    local frame = CreateFrame("Frame", "PreydatorCurrencyWhatsNewFrame", UIParent, "BackdropTemplate")
    frame:SetSize(520, 320)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.04, 0.03, 0.96)
    frame:SetBackdropBorderColor(COLOR_BORDER[1], COLOR_BORDER[2], COLOR_BORDER[3], 1)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -18)
    title:SetText(L["Preydator Updates: New in 2.1.1"])
    SetTextColor(title, COLOR_GOLD)

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -52)
    body:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -52)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetText(L["WHATS_NEW_BODY"])

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(120, 24)
    closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 16)
    closeButton:SetText(L["Got It"])

    local settingsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    settingsButton:SetSize(140, 24)
    settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)
    settingsButton:SetText(L["Open Settings"])

    closeButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if settings then
            settings.currencyWhatsNewSeenVersion = CURRENCY_WHATS_NEW_VERSION
        end
        frame:Hide()
    end)

    settingsButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if settings then
            settings.currencyWhatsNewSeenVersion = CURRENCY_WHATS_NEW_VERSION
        end
        frame:Hide()
        OpenOptionsPanel()
    end)

    frame:Hide()
    currencyWhatsNewFrame = frame
    return frame
end

local function ShowCurrencyWhatsNewIfNeeded()
    local settings = GetSettings()
    if settings then
        -- Splash disabled by request: keep version marked as seen and never show popup.
        settings.currencyWhatsNewSeenVersion = CURRENCY_WHATS_NEW_VERSION
    end
    if currencyWhatsNewFrame and currencyWhatsNewFrame.Hide then
        currencyWhatsNewFrame:Hide()
    end
end

function CurrencyTrackerModule:ShowCurrencyWhatsNew(force)
    local settings = GetSettings()
    if settings then
        settings.currencyWhatsNewSeenVersion = CURRENCY_WHATS_NEW_VERSION
    end
    if currencyWhatsNewFrame and currencyWhatsNewFrame.Hide then
        currencyWhatsNewFrame:Hide()
    end
end

local function ToggleCurrencyWindow()
    local settings = GetSettings()
    if not settings then
        return
    end

    if not IsModuleEnabled("currency") then
        settings.currencyWindowEnabled = false
        if currencyWindow then
            currencyWindow:Hide()
        end
        return
    end

    settings.currencyWindowEnabled = not (settings.currencyWindowEnabled == true)
    if currencyWindow then
        currencyWindow:SetShown(settings.currencyWindowEnabled == true)
    end
    if settings.currencyWindowEnabled then
        CurrencyTrackerModule:RefreshCurrencyPage()
    end
end

local function ToggleWarbandWindow()
    local settings = GetSettings()
    if not settings then
        return
    end

    if not IsModuleEnabled("warband") then
        settings.currencyWarbandWindowEnabled = false
        if warbandWindow then
            warbandWindow:Hide()
        end
        return
    end

    settings.currencyWarbandWindowEnabled = not (settings.currencyWarbandWindowEnabled == true)
    if warbandWindow then
        warbandWindow:SetShown(settings.currencyWarbandWindowEnabled == true)
    end
    if settings.currencyWarbandWindowEnabled then
        CurrencyTrackerModule:RefreshCurrencyPage()
    end
end

function CurrencyTrackerModule:ToggleWarbandWindow()
    EnsureTrackerSettings()
    EnsureWarbandWindow()
    ToggleWarbandWindow()
end

function CurrencyTrackerModule:ToggleCurrencyWindow()
    EnsureTrackerSettings()
    EnsureCurrencyWindow()
    ToggleCurrencyWindow()
end

function CurrencyTrackerModule:GetKnownWarbandCharacters()
    EnsureTrackerSettings()
    return GetKnownWarbandCharacters()
end

function CurrencyTrackerModule:IsWarbandCharacterShown(charKey)
    EnsureTrackerSettings()
    local settings = GetSettings()
    return IsWarbandCharacterShown(settings, charKey)
end

function CurrencyTrackerModule:SetWarbandCharacterShown(charKey, shown)
    EnsureTrackerSettings()
    local settings = GetSettings()
    if not settings then
        return
    end
    settings.currencyWarbandCharacterVisibility = settings.currencyWarbandCharacterVisibility or {}
    settings.currencyWarbandCharacterVisibility[charKey] = shown and true or false
    CurrencyTrackerModule:RefreshCurrencyPage()
end

function CurrencyTrackerModule:SetAllWarbandCharactersShown(shown)
    EnsureTrackerSettings()
    EnsureDB()

    local settings = GetSettings()
    if not settings then
        return
    end

    settings.currencyWarbandCharacterVisibility = settings.currencyWarbandCharacterVisibility or {}

    local rows = GetKnownWarbandCharacters()
    for _, entry in ipairs(rows) do
        settings.currencyWarbandCharacterVisibility[entry.charKey] = shown and true or false
    end

    self:RefreshCurrencyPage()
end

local function RemoveWarbandCharacterData(charKey)
    if type(charKey) ~= "string" or charKey == "" then
        return false
    end

    local removed = false
    if db and type(db.snapshots) == "table" and db.snapshots[charKey] ~= nil then
        db.snapshots[charKey] = nil
        removed = true
    end
    if db and type(db.preySnapshots) == "table" and db.preySnapshots[charKey] ~= nil then
        db.preySnapshots[charKey] = nil
        removed = true
    end
    if db and type(db.preyWeeklyProgress) == "table" and db.preyWeeklyProgress[charKey] ~= nil then
        db.preyWeeklyProgress[charKey] = nil
        removed = true
    end

    local settings = GetSettings()
    if settings and type(settings.currencyWarbandCharacterVisibility) == "table" then
        settings.currencyWarbandCharacterVisibility[charKey] = nil
    end

    if removed then
        RebuildWarbandTotals()
    end

    return removed
end

function CurrencyTrackerModule:RemoveWarbandCharacter(charKey)
    EnsureTrackerSettings()
    EnsureDB()

    if charKey == CharacterKey() then
        return false
    end

    local removed = RemoveWarbandCharacterData(charKey)
    if removed then
        self:RefreshCurrencyPage()
    end
    return removed
end

function CurrencyTrackerModule:PurgeHiddenWarbandCharacters()
    EnsureTrackerSettings()
    EnsureDB()

    local settings = GetSettings()
    if not settings then
        return 0
    end

    local visibility = settings.currencyWarbandCharacterVisibility
    if type(visibility) ~= "table" then
        return 0
    end

    local currentKey = CharacterKey()
    local removedCount = 0
    for charKey, isShown in pairs(visibility) do
        if isShown == false and charKey ~= currentKey then
            if RemoveWarbandCharacterData(charKey) then
                removedCount = removedCount + 1
            end
        end
    end

    if removedCount > 0 then
        self:RefreshCurrencyPage()
    end

    return removedCount
end

local function UpdateWindowPosition()
    if not currencyWindow then
        return
    end

    local settings = GetSettings()
    local point = settings and settings.currencyWindowPoint
    currencyWindow:ClearAllPoints()
    if type(point) == "table" then
        currencyWindow:SetPoint(point.anchor or "CENTER", UIParent, point.relativePoint or "CENTER", point.x or 340, point.y or -80)
    else
        currencyWindow:SetPoint("CENTER", UIParent, "CENTER", 340, -80)
    end
end

local function SaveWindowPosition(frame)
    local settings = GetSettings()
    if not settings then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.currencyWindowPoint = {
        anchor = point or "CENTER",
        relativePoint = relativePoint or "CENTER",
        x = math.floor((x or 0) + 0.5),
        y = math.floor((y or 0) + 0.5),
    }
end

local function IsCurrentlyInInstance()
    if not _G.IsInInstance then
        return false
    end
    local ok, inInstance = pcall(_G.IsInInstance)
    return ok and inInstance == true
end

local function UpdateVisibilityFromSettings()
    local settings = GetSettings()
    if not settings then
        return
    end

    local currencyModuleEnabled = IsModuleEnabled("currency")
    local warbandModuleEnabled = IsModuleEnabled("warband")

    if not currencyModuleEnabled then
        settings.currencyWindowEnabled = false
    end
    if not warbandModuleEnabled then
        settings.currencyWarbandWindowEnabled = false
    end

    local inInstance = IsCurrentlyInInstance()

    if currencyWindow then
        local shouldShow = currencyModuleEnabled and (settings.currencyWindowEnabled ~= false)
        if inInstance and settings.currencyWindowHideInInstance == true then
            shouldShow = false
        end
        currencyWindow:SetShown(shouldShow)
    end

    if warbandWindow then
        local shouldShow = warbandModuleEnabled and (settings.currencyWarbandWindowEnabled == true)
        if inInstance and settings.currencyWarbandWindowHideInInstance == true then
            shouldShow = false
        end
        warbandWindow:SetShown(shouldShow)
    end

end

local function UpdateWarbandWindowPosition()
    if not warbandWindow then
        return
    end

    local settings = GetSettings()
    local point = settings and settings.currencyWarbandWindowPoint
    warbandWindow:ClearAllPoints()
    if type(point) == "table" then
        warbandWindow:SetPoint(point.anchor or "CENTER", UIParent, point.relativePoint or "CENTER", point.x or 660, point.y or -80)
    else
        warbandWindow:SetPoint("CENTER", UIParent, "CENTER", 660, -80)
    end
end

local function SaveWarbandWindowPosition(frame)
    local settings = GetSettings()
    if not settings then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.currencyWarbandWindowPoint = {
        anchor = point or "CENTER",
        relativePoint = relativePoint or "CENTER",
        x = math.floor((x or 0) + 0.5),
        y = math.floor((y or 0) + 0.5),
    }
end

local function GetCurrencyWindowConfig()
    local settings = GetSettings()
    local width = ClampNumber(settings and settings.currencyWindowWidth, TRACKER_MIN_WIDTH, TRACKER_MAX_WIDTH, TRACKER_WINDOW_WIDTH)
    local height = ClampNumber(settings and settings.currencyWindowHeight, TRACKER_MIN_HEIGHT, TRACKER_MAX_HEIGHT, TRACKER_WINDOW_HEIGHT)
    local fontSize = ClampNumber(settings and settings.currencyWindowFontSize, TRACKER_MIN_FONT, TRACKER_MAX_FONT, TRACKER_DEFAULT_FONT)
    local scale = ClampFloat(settings and settings.currencyWindowScale, TRACKER_MIN_SCALE, TRACKER_MAX_SCALE, TRACKER_DEFAULT_SCALE, 2)
    return width, height, fontSize, scale
end

local function GetWarbandWindowConfig()
    local settings = GetSettings()
    local width = ClampNumber(settings and settings.currencyWarbandWidth, WARBAND_MIN_WIDTH, WARBAND_MAX_WIDTH, WARBAND_DEFAULT_WIDTH)
    local height = ClampNumber(settings and settings.currencyWarbandHeight, WARBAND_MIN_HEIGHT, WARBAND_MAX_HEIGHT, WARBAND_DEFAULT_HEIGHT)
    local fontSize = ClampNumber(settings and settings.currencyWarbandFontSize, WARBAND_MIN_FONT, WARBAND_MAX_FONT, WARBAND_DEFAULT_FONT)
    local scale = ClampFloat(settings and settings.currencyWarbandScale, WARBAND_MIN_SCALE, WARBAND_MAX_SCALE, WARBAND_DEFAULT_SCALE, 2)
    return width, height, fontSize, scale
end

local function CreateCurrencyWindowRow(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(TRACKER_ROW_WIDTH, TRACKER_ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(COLOR_ROW_BG[1], COLOR_ROW_BG[2], COLOR_ROW_BG[3], COLOR_ROW_BG[4])
    row.bg = bg

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("LEFT", row, "LEFT", 6, 0)
    icon:SetSize(20, 20)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    nameText:SetWidth(110)
    nameText:SetJustifyH("LEFT")

    local qtyText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    qtyText:SetPoint("RIGHT", row, "RIGHT", -8, 6)
    qtyText:SetJustifyH("RIGHT")

    local deltaText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    deltaText:SetPoint("RIGHT", row, "RIGHT", -8, -8)
    deltaText:SetJustifyH("RIGHT")

    row.icon = icon
    row.nameText = nameText
    row.qtyText = qtyText
    row.deltaText = deltaText
    return row
end

EnsureCurrencyWindow = function()
    if currencyWindow then
        return currencyWindow
    end

    local frame = CreateFrame("Frame", "PreydatorCurrencyTrackerWindow", UIParent, "BackdropTemplate")
    local windowWidth, windowHeight, _, windowScale = GetCurrencyWindowConfig()
    frame:SetSize(windowWidth, windowHeight)
    frame:SetScale(windowScale)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.03, 0.03, 0.04, 0.98)
    frame:SetBackdropBorderColor(COLOR_BORDER[1], COLOR_BORDER[2], COLOR_BORDER[3], 1)
    frame:SetClipsChildren(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveWindowPosition(self)
    end)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    bg:SetColorTexture(0.02, 0.02, 0.03, 0.94)

    local topBar = frame:CreateTexture(nil, "BORDER")
    topBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
    topBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, 0)
    topBar:SetHeight(26)
    topBar:SetColorTexture(0.20, 0.14, 0.06, 0.95)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", frame, "TOPLEFT", 10, -13)
    title:SetText(L["Preydator Currency"])
    SetTextColor(title, COLOR_GOLD)
    frame.PreydatorTitle = title

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if settings then
            settings.currencyWindowEnabled = false
        end
        frame:Hide()
    end)

    local autoHideButton = CreateWindowAutoHideButton(frame, closeButton, "currency")
    frame.PreydatorAutoHideButton = autoHideButton
    AttachWindowAutoHideHooks(frame, "currency")

    local summary = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -36)
    summary:SetWidth(windowWidth - 28)
    summary:SetJustifyH("LEFT")
    summary:SetWordWrap(true)
    currencyWindowSummary = summary

    frame.PreydatorBg = bg
    frame.PreydatorTopBar = topBar

    currencyWindowRows = {}
    for index = 1, #CURRENCY_ALLOW_LIST do
        currencyWindowRows[index] = CreateCurrencyWindowRow(frame, -68 - ((index - 1) * 30))
    end

    frame:SetScript("OnShow", function()
        CurrencyTrackerModule:RefreshCurrencyPage()
    end)

    currencyWindow = frame
    UpdateWindowPosition()
    ApplyWindowAutoHideState(frame, "currency")
    return frame
end

-- Generate difficulty abbreviation dynamically from localized difficulty names.
-- Checks for pre-translated abbreviation first, then builds from first characters.
-- Handles collisions: if two difficulties share first letter, second uses two chars.
GetDifficultyAbbreviation = function()
    -- Check if there's a pre-translated abbreviation in localization
    local preTranslated = L["N/H/Ni"]
    if preTranslated and preTranslated ~= "N/H/Ni" then
        return preTranslated
    end

    -- Get localized difficulty names
    local normal = L["Normal"]
    local hard = L["Hard"]
    local nightmare = L["Nightmare"]

    -- Extract first character from each
    local n = normal:sub(1, 1) or "N"
    local h = hard:sub(1, 1) or "H"
    local ni = nightmare:sub(1, 1) or "N"

    -- Handle collisions: if nightmare starts with same letter as normal, use two chars
    if ni == n then
        ni = nightmare:sub(1, 2) or "Ni"
    end

    return n .. "/" .. h .. "/" .. ni
end

EnsureWarbandWindow = function()
    if warbandWindow then
        return warbandWindow
    end

    local frame = CreateFrame("Frame", "PreydatorCurrencyWarbandWindow", UIParent, "BackdropTemplate")
    local windowWidth, windowHeight, _, windowScale = GetWarbandWindowConfig()
    frame:SetSize(windowWidth, windowHeight)
    frame:SetScale(windowScale)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(11)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.03, 0.03, 0.04, 0.98)
    frame:SetBackdropBorderColor(0.44, 0.56, 0.80, 1)
    frame:SetClipsChildren(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveWarbandWindowPosition(self)
    end)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    bg:SetColorTexture(0.02, 0.03, 0.05, 0.94)

    local topBar = frame:CreateTexture(nil, "BORDER")
    topBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
    topBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, 0)
    topBar:SetHeight(26)
    topBar:SetColorTexture(0.16, 0.20, 0.30, 0.97)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", frame, "TOPLEFT", 10, -13)
    title:SetText(L["Preydator Warband"])
    SetTextColor(title, COLOR_GOLD)
    frame.PreydatorTitle = title

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if settings then
            settings.currencyWarbandWindowEnabled = false
        end
        frame:Hide()
    end)

    local autoHideButton = CreateWindowAutoHideButton(frame, closeButton, "warband")
    frame.PreydatorAutoHideButton = autoHideButton
    AttachWindowAutoHideHooks(frame, "warband")

    local summary = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -36)
    summary:SetWidth(windowWidth - 24)
    summary:SetJustifyH("LEFT")
    summary:SetWordWrap(true)
    warbandWindowSummary = summary
    frame.PreydatorBg = bg
    frame.PreydatorTopBar = topBar

    warbandColumns = {
        { key = "realm",     label = L["Realm"],     width = 96 },
        { key = "character", label = L["Character"], width = 112 },
        { key = "prey",      label = GetDifficultyAbbreviation(), width = 56 },
    }
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        warbandColumns[#warbandColumns + 1] = { key = entry.id, label = entry.label, width = 52 }
    end

    warbandHeaderTexts = {}
    warbandHeaderButtons = {}
    warbandHeaderIcons = {}
    warbandTotalTexts = {}
    local x = 12
    for _, headerData in ipairs(warbandColumns) do
        local totalText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        totalText:SetPoint("TOPLEFT", frame, "TOPLEFT", x + 2, -40)
        totalText:SetWidth(headerData.width - 4)
        totalText:SetJustifyH((headerData.key == "character" or headerData.key == "realm") and "LEFT" or "RIGHT")
        totalText:SetText(headerData.key == "character" and L["Total"] or "0")
        warbandTotalTexts[headerData.key] = totalText

        local headerButton = CreateFrame("Button", nil, frame)
        headerButton:SetSize(headerData.width, 16)
        headerButton:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -56)
        local text = headerButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetAllPoints()
        text:SetJustifyH((headerData.key == "character" or headerData.key == "realm") and "LEFT" or "RIGHT")
        text:SetText(GetWarbandCurrencyHeaderLabel(headerData.key, headerData.label))
        SetTextColor(text, COLOR_GOLD)
        local icon = headerButton:CreateTexture(nil, "ARTWORK")
        icon:SetSize(14, 14)
        icon:SetPoint("CENTER", headerButton, "CENTER", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:Hide()
        warbandHeaderTexts[headerData.key] = text
        warbandHeaderButtons[headerData.key] = headerButton
        warbandHeaderIcons[headerData.key] = icon
        headerButton:SetScript("OnClick", function()
            if warbandSortKey == headerData.key then
                warbandSortAsc = not warbandSortAsc
            else
                warbandSortKey = headerData.key
                warbandSortAsc = true
            end
            CurrencyTrackerModule:RefreshCurrencyPage()
        end)
        headerButton:SetScript("OnEnter", function(self)
            if not GameTooltip then
                return
            end
            if not IsWarbandCurrencyColumn(headerData.key) then
                return
            end
            local settings = GetSettings()
            if not settings or settings.currencyWarbandUseIcons ~= true then
                return
            end

            local iconTexture = warbandHeaderIcons[headerData.key]
            if not (iconTexture and iconTexture:IsShown()) then
                return
            end

            local info = GetCurrencyInfoSafe(headerData.key)
            local currencyName = (info and info.name) or headerData.label or ("Currency " .. tostring(headerData.key))
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(currencyName, 1.0, 0.82, 0)
            GameTooltip:Show()
        end)
        headerButton:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        x = x + headerData.width
    end

    warbandWindowRows = {}

    frame:SetScript("OnShow", function()
        CurrencyTrackerModule:RefreshCurrencyPage()
    end)

    warbandWindow = frame
    UpdateWarbandWindowPosition()
    ApplyWindowAutoHideState(frame, "warband")
    return frame
end

local function EnsureWarbandRows(minCount)
    if not warbandWindow then
        return
    end

    while #warbandWindowRows < minCount do
        local index = #warbandWindowRows + 1
        local row = CreateFrame("Button", nil, warbandWindow)
        row:SetSize(396, 16)
        row:RegisterForClicks("LeftButtonUp")

        local rowBg = row:CreateTexture(nil, "BACKGROUND")
        rowBg:SetAllPoints()
        if index % 2 == 0 then
            rowBg:SetColorTexture(COLOR_ROW_BG_ALT[1], COLOR_ROW_BG_ALT[2], COLOR_ROW_BG_ALT[3], 0.55)
        else
            rowBg:SetColorTexture(COLOR_ROW_BG[1], COLOR_ROW_BG[2], COLOR_ROW_BG[3], 0.45)
        end
        row.bg = rowBg

        local cells = {}
        for _, headerData in ipairs(warbandColumns) do
            local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            cell:SetJustifyH((headerData.key == "character" or headerData.key == "realm") and "LEFT" or "RIGHT")
            if cell.SetWordWrap then
                cell:SetWordWrap(false)
            end
            if cell.SetNonSpaceWrap then
                cell:SetNonSpaceWrap(false)
            end
            if cell.SetMaxLines then
                cell:SetMaxLines(1)
            end
            cells[headerData.key] = cell
        end

        warbandWindowRows[index] = { frame = row, cells = cells }
    end
end

local function ApplyWarbandColumnLayout(showRealm, displayRowCount)
    if not warbandWindow then
        return
    end

    local settings = GetSettings()
    local windowWidth, windowHeight, fontSize, windowScale = GetWarbandWindowConfig()
    local themeFont = GetThemeFontPath(GetWarbandThemePreset())
    local orderedCurrencyIDs = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        orderedCurrencyIDs[#orderedCurrencyIDs + 1] = entry.id
    end
    local trackedCurrencyIDs = {}
    for _, currencyID in ipairs(orderedCurrencyIDs) do
        if IsWarbandCurrencyTracked(settings, currencyID) then
            trackedCurrencyIDs[#trackedCurrencyIDs + 1] = currencyID
        end
    end
    if #trackedCurrencyIDs == 0 then
        trackedCurrencyIDs[1] = 3392
    end

    local rowCount = math.max(1, tonumber(displayRowCount) or 0)

    local realmWidth = showRealm and 128 or 0
    local charWidth = GetWarbandCharacterColumnWidth(showRealm, fontSize, themeFont)
    local maxRealmWidth = showRealm and 188 or 0
    local currencyDefaults = {}
    for _, entry in ipairs(CURRENCY_ALLOW_LIST) do
        currencyDefaults[entry.id] = 52
    end
    currencyDefaults[3392] = 56
    currencyDefaults[3316] = 64
    currencyDefaults[3383] = 48
    currencyDefaults[3341] = 48
    currencyDefaults[3343] = 56
    currencyDefaults[3345] = 48
    currencyDefaults[3310] = 54

    local preyWidth = (settings and settings.currencyWarbandShowPreyTrack ~= false) and 56 or 0
    local requiredTableWidth = charWidth + realmWidth + preyWidth
    for _, currencyID in ipairs(trackedCurrencyIDs) do
        requiredTableWidth = requiredTableWidth + (currencyDefaults[currencyID] or 48)
    end
    local requiredWindowWidth = math.max(WARBAND_MIN_WIDTH, requiredTableWidth + 24)
    local configuredWidth = tonumber(settings and settings.currencyWarbandWidth)
    local useAutoWidth = configuredWidth == nil or math.abs(configuredWidth - WARBAND_DEFAULT_WIDTH) < 0.01
    local finalWindowWidth = useAutoWidth and requiredWindowWidth or math.max(windowWidth, requiredWindowWidth)

    local rowHeight = math.max(16, fontSize + 4)
    local requiredWindowHeight = 86 + (math.max(1, rowCount) * rowHeight) + 12
    local finalWindowHeight = math.max(windowHeight, requiredWindowHeight)

    warbandWindow:SetSize(finalWindowWidth, finalWindowHeight)
    warbandWindow:SetScale(windowScale)

    local tableWidth = finalWindowWidth - 24

    local currencyWidth = 0
    for _, currencyID in ipairs(trackedCurrencyIDs) do
        currencyWidth = currencyWidth + (currencyDefaults[currencyID] or 48)
    end

    local widthSlack = tableWidth - realmWidth - preyWidth - currencyWidth - charWidth
    if widthSlack > 0 then
        local realmGrow = math.min(maxRealmWidth - realmWidth, widthSlack)
        if realmGrow > 0 then
            realmWidth = realmWidth + realmGrow
            widthSlack = widthSlack - realmGrow
        end
        if widthSlack > 0 then
            charWidth = charWidth + widthSlack
        end
    end

    local currencyWidths = {}
    for _, currencyID in ipairs(orderedCurrencyIDs) do
        if IsWarbandCurrencyTracked(settings, currencyID) then
            currencyWidths[currencyID] = currencyDefaults[currencyID] or 48
        else
            currencyWidths[currencyID] = 0
        end
    end

    local effectiveWidths = {
        ["realm"] = realmWidth,
        ["character"] = charWidth,
        ["prey"] = preyWidth,
    }
    for _, currencyID in ipairs(orderedCurrencyIDs) do
        effectiveWidths[currencyID] = currencyWidths[currencyID]
    end

    if warbandWindowSummary then
        warbandWindowSummary:SetWidth(tableWidth)
        SetFontSize(warbandWindowSummary, math.max(10, fontSize - 2), themeFont)
    end
    if warbandWindow.PreydatorTitle then
        SetFontSize(warbandWindow.PreydatorTitle, fontSize, themeFont)
    end

    local showWarbandIcons = settings and settings.currencyWarbandUseIcons == true

    local x = 12
    for _, column in ipairs(warbandColumns) do
        local key = column.key
        local width = effectiveWidths[key] or column.width
        local visible = not (key == "realm" and not showRealm)
        local headerButton = warbandHeaderButtons[key]
        local headerText = warbandHeaderTexts[key]
        local headerIcon = warbandHeaderIcons[key]
        local totalText = warbandTotalTexts[key]

        if headerButton and headerText and totalText then
            headerButton:SetShown(visible)
            headerText:SetShown(visible)
            if headerIcon then
                headerIcon:SetShown(false)
            end
            totalText:SetShown(visible)
            if visible then
                headerButton:ClearAllPoints()
                headerButton:SetPoint("TOPLEFT", warbandWindow, "TOPLEFT", x, -56)
                headerButton:SetSize(width, 16)
                totalText:ClearAllPoints()
                totalText:SetPoint("TOPLEFT", warbandWindow, "TOPLEFT", x + 2, -40)
                totalText:SetWidth(width - 4)
                totalText:SetJustifyH((key == "character" or key == "realm") and "LEFT" or "RIGHT")
                SetFontSize(totalText, math.max(10, fontSize - 2), themeFont)
                SetFontSize(headerText, math.max(10, fontSize - 2), themeFont)
                if IsWarbandCurrencyColumn(key) and showWarbandIcons and headerIcon then
                    local iconID = GetCurrencyIcon(key)
                    if iconID and iconID > 0 then
                        headerText:SetJustifyH("CENTER")
                        headerText:SetText("")
                        headerIcon:SetTexture(iconID)
                        headerIcon:ClearAllPoints()
                        headerIcon:SetPoint("CENTER", headerButton, "CENTER", 0, 0)
                        local scaledIconSize = math.max(10, fontSize - 2)
                        headerIcon:SetSize(scaledIconSize, scaledIconSize)
                        headerIcon:SetShown(true)
                    else
                        headerText:SetJustifyH("RIGHT")
                        headerText:SetText(GetWarbandCurrencyHeaderLabel(key, column.label))
                    end
                else
                    headerText:SetJustifyH((key == "character" or key == "realm") and "LEFT" or "RIGHT")
                    headerText:SetText(GetWarbandCurrencyHeaderLabel(key, column.label))
                end
                x = x + width
            end
        end
    end

    local visibleRows = math.max(1, math.floor((finalWindowHeight - 86) / rowHeight))
    EnsureWarbandRows(visibleRows)

    for index, rowData in ipairs(warbandWindowRows) do
        local row = rowData.frame
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", warbandWindow, "TOPLEFT", 12, -76 - ((index - 1) * rowHeight))
        row:SetSize(tableWidth, rowHeight)

        local cellX = 0
        for _, column in ipairs(warbandColumns) do
            local key = column.key
            local width = effectiveWidths[key] or column.width
            local cell = rowData.cells[key]
            local visible = not (key == "realm" and not showRealm)
            if visible then
                cell:Show()
                cell:ClearAllPoints()
                cell:SetPoint("TOPLEFT", row, "TOPLEFT", cellX + 2, -1)
                cell:SetWidth(width - 4)
                cell:SetJustifyH((key == "character" or key == "realm") and "LEFT" or "RIGHT")
                SetFontSize(cell, math.max(10, fontSize - 1), themeFont)
                cellX = cellX + width
            else
                cell:Hide()
            end
        end
    end
end

local function RefreshWarbandWindowDisplay()
    if not warbandWindow then
        return
    end

    local settings = GetSettings()
    local theme = GetWarbandThemePreset()
    local useClassColors = not settings or settings.themeUseClassColors ~= false
    local showRealm = settings and settings.currencyShowRealmInWarband == true
    if warbandWindow.SetBackdropColor then
        warbandWindow:SetBackdropColor(theme.section[1], theme.section[2], theme.section[3], theme.section[4] or 1)
    end
    if warbandWindow.PreydatorBg then
        warbandWindow.PreydatorBg:SetColorTexture(theme.section[1], theme.section[2], theme.section[3], 0.88)
    end
    if warbandWindow.PreydatorTopBar then
        warbandWindow.PreydatorTopBar:SetColorTexture(theme.header[1], theme.header[2], theme.header[3], 0.95)
    end
    if warbandWindow.SetBackdropBorderColor then
        warbandWindow:SetBackdropBorderColor(theme.border[1], theme.border[2], theme.border[3], theme.border[4] or 1)
    end
    if warbandWindow.PreydatorTitle then
        SetTextColor(warbandWindow.PreydatorTitle, theme.title)
    end
    if warbandWindowSummary then
        SetTextColor(warbandWindowSummary, theme.muted)
    end
    for _, text in pairs(warbandHeaderTexts) do
        SetTextColor(text, theme.title)
    end
    for _, text in pairs(warbandTotalTexts) do
        SetTextColor(text, theme.text)
    end

    RebuildWarbandTotals()
    local rows = GetWarbandRows()
    local hideLowLevel = settings and settings.currencyWarbandHideLowLevel == true

    if settings then
        local filteredRows = {}
        for _, rowData in ipairs(rows) do
            local isShown = IsWarbandCharacterShown(settings, rowData.charKey)
            local level = GetPreyLevelForCharacter(rowData.charKey)
            local isLowLevel = hideLowLevel and level and level < 78
            if isShown and not isLowLevel then
                filteredRows[#filteredRows + 1] = rowData
            end
        end
        rows = filteredRows
    end

    local function compareValues(leftValue, rightValue, fallbackLeft, fallbackRight)
        if leftValue == rightValue then
            return (fallbackLeft or "") < (fallbackRight or "")
        end
        if warbandSortAsc then
            return leftValue < rightValue
        end
        return leftValue > rightValue
    end

    table.sort(rows, function(left, right)
        local key = warbandSortKey
        if key == "realm" then
            local _, leftRealm = left.charKey:match("^(.-)%-(.+)$")
            local _, rightRealm = right.charKey:match("^(.-)%-(.+)$")
            leftRealm = leftRealm or "Unknown"
            rightRealm = rightRealm or "Unknown"
            return compareValues(leftRealm, rightRealm, left.charKey, right.charKey)
        end

        local leftValue
        local rightValue
        if key == "character" then
            leftValue = left.charKey
            rightValue = right.charKey
        elseif key == "prey" then
            local leftSnap = db and db.preySnapshots and db.preySnapshots[left.charKey] or nil
            local rightSnap = db and db.preySnapshots and db.preySnapshots[right.charKey] or nil
            leftValue = BuildPreyProgressTriplet(leftSnap, (settings and settings.currencyWarbandPreyMode) or "available")
            rightValue = BuildPreyProgressTriplet(rightSnap, (settings and settings.currencyWarbandPreyMode) or "available")
        else
            leftValue = (left.snaps[key] and left.snaps[key].quantity) or 0
            rightValue = (right.snaps[key] and right.snaps[key].quantity) or 0
        end
        return compareValues(leftValue, rightValue, left.charKey, right.charKey)
    end)

    local displayRows = {}
    if showRealm then
        local collapsedRealms = settings and settings.currencyWarbandCollapsedRealms or {}
        local groups = {}
        local orderedGroups = {}

        for _, rowData in ipairs(rows) do
            local charName, realmName = rowData.charKey:match("^(.-)%-(.+)$")
            if not charName then
                charName = rowData.charKey
                realmName = "Unknown"
            end

            local group = groups[realmName]
            if not group then
                local totals = {}
                for _, e in ipairs(CURRENCY_ALLOW_LIST) do totals[e.id] = 0 end
                group = {
                    realm = realmName,
                    chars = {},
                    totals = totals,
                }
                groups[realmName] = group
                orderedGroups[#orderedGroups + 1] = group
            end

            local charEntry = {
                type = "character",
                realm = realmName,
                charName = charName,
                charKey = rowData.charKey,
                snaps = rowData.snaps,
                preyTriplet = (settings and settings.currencyWarbandShowPreyTrack ~= false and db and db.preySnapshots and db.preySnapshots[rowData.charKey])
                    and BuildPreyProgressTriplet(db.preySnapshots[rowData.charKey], (settings and settings.currencyWarbandPreyMode) or "available")
                    or "",
            }
            group.chars[#group.chars + 1] = charEntry
            for _, e in ipairs(CURRENCY_ALLOW_LIST) do
                group.totals[e.id] = group.totals[e.id] + ((rowData.snaps[e.id] and rowData.snaps[e.id].quantity) or 0)
            end
        end

        table.sort(orderedGroups, function(left, right)
            if warbandSortKey == "realm" or warbandSortKey == "character" then
                return compareValues(left.realm, right.realm, left.realm, right.realm)
            end
            if type(warbandSortKey) == "number" then
                return compareValues(left.totals[warbandSortKey] or 0, right.totals[warbandSortKey] or 0, left.realm, right.realm)
            end
            return compareValues(left.realm, right.realm, left.realm, right.realm)
        end)

        for _, group in ipairs(orderedGroups) do
            table.sort(group.chars, function(left, right)
                if warbandSortKey == "character" then
                    return compareValues(left.charName, right.charName, left.charKey, right.charKey)
                end
                if warbandSortKey == "prey" then
                    return compareValues(left.preyTriplet or "", right.preyTriplet or "", left.charName, right.charName)
                end
                if type(warbandSortKey) == "number" then
                    local leftValue = (left.snaps[warbandSortKey] and left.snaps[warbandSortKey].quantity) or 0
                    local rightValue = (right.snaps[warbandSortKey] and right.snaps[warbandSortKey].quantity) or 0
                    return compareValues(leftValue, rightValue, left.charName, right.charName)
                end
                return compareValues(left.charName, right.charName, left.charKey, right.charKey)
            end)

            displayRows[#displayRows + 1] = {
                type = "realm",
                realm = group.realm,
                totals = group.totals,
                collapsed = collapsedRealms[group.realm] == true,
            }

            if collapsedRealms[group.realm] ~= true then
                for _, charEntry in ipairs(group.chars) do
                    displayRows[#displayRows + 1] = charEntry
                end
            end
        end
    else
        for _, rowData in ipairs(rows) do
            local charName, realmName = rowData.charKey:match("^(.-)%-(.+)$")
            if not charName then
                charName = rowData.charKey
                realmName = "Unknown"
            end
            local snap = db and db.preySnapshots and db.preySnapshots[rowData.charKey] or nil
            displayRows[#displayRows + 1] = {
                type = "character",
                realm = realmName,
                charName = charName,
                charKey = rowData.charKey,
                snaps = rowData.snaps,
                preyTriplet = (settings and settings.currencyWarbandShowPreyTrack ~= false and snap) and BuildPreyProgressTriplet(snap, (settings and settings.currencyWarbandPreyMode) or "available") or "",
            }
        end
    end

    ApplyWarbandColumnLayout(showRealm, #displayRows)

    for index, rowData in ipairs(warbandWindowRows) do
        local data = displayRows[index]
        if not data then
            rowData.frame:Hide()
        else
            rowData.frame:Show()
            if rowData.frame.bg then
                local rowColor = (index % 2 == 0) and theme.rowAlt or theme.row
                rowData.frame.bg:SetColorTexture(rowColor[1], rowColor[2], rowColor[3], rowColor[4] or 0.92)
            end

            if data.type == "realm" then
                local collapsed = data.collapsed == true
                local prefix = collapsed and "+ " or "- "
                rowData.cells.realm:SetText(prefix .. data.realm)
                rowData.cells.character:SetText("")
                rowData.cells.prey:SetText("")
                for _, e in ipairs(CURRENCY_ALLOW_LIST) do
                    if rowData.cells[e.id] then
                        rowData.cells[e.id]:SetText(tostring(data.totals[e.id] or 0))
                        SetTextColor(rowData.cells[e.id], theme.title)
                    end
                end
                SetTextColor(rowData.cells.realm, theme.title)
                SetTextColor(rowData.cells.character, theme.muted)
                SetTextColor(rowData.cells.prey, theme.muted)
                rowData.frame:SetScript("OnClick", function()
                    local collapsedRealms = settings.currencyWarbandCollapsedRealms
                    collapsedRealms[data.realm] = not (collapsedRealms[data.realm] == true)
                    CurrencyTrackerModule:RefreshCurrencyPage()
                end)
            else
                rowData.cells.realm:SetText("")  -- realm column blank on character rows; grouping is visual
                rowData.cells.character:SetText(data.charName)
                rowData.cells.prey:SetText(data.preyTriplet or "")
                for _, e in ipairs(CURRENCY_ALLOW_LIST) do
                    if rowData.cells[e.id] then
                        rowData.cells[e.id]:SetText(tostring((data.snaps[e.id] and data.snaps[e.id].quantity) or 0))
                        SetTextColor(rowData.cells[e.id], theme.text)
                    end
                end
                SetTextColor(rowData.cells.realm, theme.muted)
                local classFile = data.snaps[3392] and data.snaps[3392].classFile
                local classColor = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
                if useClassColors and classColor then
                    rowData.cells.character:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
                else
                    SetTextColor(rowData.cells.character, theme.text)
                end
                SetTextColor(rowData.cells.prey, theme.muted)
                rowData.frame:SetScript("OnClick", nil)
            end
        end
    end

    -- Always sum ALL shown characters regardless of realm collapse state.
    -- displayRows omits character rows for collapsed realms, so use rows instead.
    local displayTotals = {}
    for _, e in ipairs(CURRENCY_ALLOW_LIST) do displayTotals[e.id] = 0 end
    for _, data in ipairs(rows) do
        if data.snaps then
            for _, e in ipairs(CURRENCY_ALLOW_LIST) do
                displayTotals[e.id] = displayTotals[e.id] + ((data.snaps[e.id] and data.snaps[e.id].quantity) or 0)
            end
        end
    end

    if warbandTotalTexts.realm then
        warbandTotalTexts.realm:SetText(L["All Realms"])
        SetTextColor(warbandTotalTexts.realm, theme.muted)
    end
    if warbandTotalTexts.character then
        warbandTotalTexts.character:SetText(L["Totals"])
        SetTextColor(warbandTotalTexts.character, theme.muted)
    end
    if warbandTotalTexts.prey then
        warbandTotalTexts.prey:SetText("")
        SetTextColor(warbandTotalTexts.prey, theme.muted)
    end
    for _, e in ipairs(CURRENCY_ALLOW_LIST) do
        if warbandTotalTexts[e.id] then
            warbandTotalTexts[e.id]:SetText(tostring(displayTotals[e.id] or 0))
            SetTextColor(warbandTotalTexts[e.id], theme.title)
        end
    end

    for key, text in pairs(warbandHeaderTexts) do
        if key == warbandSortKey then
            SetTextColor(text, theme.title)
        else
            SetTextColor(text, theme.muted)
        end
    end
end

local function RefreshCurrencyWindowDisplay()
    if not currencyWindow then
        return
    end

    local settings = GetSettings()
    local theme = GetThemePreset()
    local showAffordableHunts = (not settings) or (settings.currencyShowAffordableHunts ~= false)
    local gainColor = (settings and settings.currencyDeltaGainColor) or COLOR_GREEN
    local lossColor = (settings and settings.currencyDeltaLossColor) or COLOR_RED
    local seasonColor = theme.season or COLOR_SEASON
    local themeFont = GetThemeFontPath(theme)
    local configuredWidth, configuredHeight, configuredFontSize, configuredScale = GetCurrencyWindowConfig()
    local tracked = GetTrackedCurrencyEntries()

    local topPad = 34
    local summaryHeight = showAffordableHunts and 24 or 0
    local rowTopGap = 8
    local rowSpacing = 30
    local bottomPad = 14
    local rowsHeight = #tracked * rowSpacing
    local requiredHeight = topPad + summaryHeight + rowTopGap + rowsHeight + bottomPad
    local finalHeight = (requiredHeight > configuredHeight) and requiredHeight or configuredHeight

    currencyWindow:SetSize(configuredWidth, finalHeight)
    currencyWindow:SetScale(configuredScale)

    if currencyWindow.SetBackdropColor then
        currencyWindow:SetBackdropColor(theme.section[1], theme.section[2], theme.section[3], theme.section[4] or 1)
    end
    if currencyWindow.PreydatorBg then
        currencyWindow.PreydatorBg:SetColorTexture(theme.section[1], theme.section[2], theme.section[3], 0.88)
    end
    if currencyWindow.PreydatorTopBar then
        currencyWindow.PreydatorTopBar:SetColorTexture(theme.header[1], theme.header[2], theme.header[3], 0.95)
    end
    if currencyWindow.SetBackdropBorderColor then
        currencyWindow:SetBackdropBorderColor(theme.border[1], theme.border[2], theme.border[3], theme.border[4] or 1)
    end
    if currencyWindow.PreydatorTitle then
        SetTextColor(currencyWindow.PreydatorTitle, theme.title)
    end

    if currencyWindowSummary then
        currencyWindowSummary:SetShown(showAffordableHunts)
        currencyWindowSummary:SetWidth(configuredWidth - 28)
        SetTextColor(currencyWindowSummary, theme.muted)
        SetFontSize(currencyWindowSummary, math.max(10, configuredFontSize - 2), themeFont)
    end

    local rowStartY = showAffordableHunts and -68 or -40
    for index, row in ipairs(currencyWindowRows) do
        local entry = tracked[index]
        if entry then
            row:Show()
            row:SetSize(configuredWidth - 28, TRACKER_ROW_HEIGHT)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", currencyWindow, "TOPLEFT", 12, rowStartY - ((index - 1) * 30))
            if row.bg then
                local rowColor = (index % 2 == 0) and theme.rowAlt or theme.row
                row.bg:SetColorTexture(rowColor[1], rowColor[2], rowColor[3], rowColor[4] or 0.92)
            end
            row.nameText:SetText(entry.label)
            SetTextColor(row.nameText, entry.season and seasonColor or theme.text)
            SetFontSize(row.nameText, configuredFontSize, themeFont)

            local iconID = GetCurrencyIcon(entry.id)
            if iconID and iconID > 0 then
                row.icon:SetTexture(iconID)
            else
                row.icon:SetColorTexture(0.35, 0.35, 0.4, 0.8)
            end

            local qty = GetCurrencyQuantity(entry.id)
            row.qtyText:SetText(tostring(qty))
            SetTextColor(row.qtyText, qty > 0 and theme.text or theme.muted)
            SetFontSize(row.qtyText, configuredFontSize, themeFont)

            local delta = SessionDelta(entry.id)
            if delta > 0 then
                row.deltaText:SetText("+" .. tostring(delta))
                SetTextColor(row.deltaText, gainColor)
                SetFontSize(row.deltaText, math.max(10, configuredFontSize - 2), themeFont)
                row.deltaText:Show()
            elseif delta < 0 then
                row.deltaText:SetText(tostring(delta))
                SetTextColor(row.deltaText, lossColor)
                SetFontSize(row.deltaText, math.max(10, configuredFontSize - 2), themeFont)
                row.deltaText:Show()
            else
                row.deltaText:SetText("")
                row.deltaText:Hide()
            end
        else
            row:Hide()
        end
    end

    local anguish = GetCurrencyQuantity(3392)
    local randomHuntCount = math.max(0, math.floor(anguish / RANDOM_HUNT_ANGUISH_COST))

    if currencyWindowSummary and showAffordableHunts then
        currencyWindowSummary:SetText(string.format(L["Random Hunts: %d"], randomHuntCount))
        SetTextColor(currencyWindowSummary, theme.muted)
    end

    if currencyWindow.PreydatorTitle then
        SetFontSize(currencyWindow.PreydatorTitle, configuredFontSize, themeFont)
    end
end

local function BuildCurrencyConfigPage(parent)
    local settings = GetSettings()
    if not settings then
        return
    end

    local function IsModuleEnabled(moduleKey)
        local customizationV2 = Preydator:GetModule("CustomizationStateV2")
        if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
            return customizationV2:IsModuleEnabled(moduleKey) == true
        end
        return true
    end

    settings.currencyCategoryCollapsed = settings.currencyCategoryCollapsed or {}

    local X_CATEGORY = 8
    local X_CURRENCY = 248
    local X_WARBAND = 324
    local X_BOTH = 400
    local LABEL_WIDTH = X_CURRENCY - X_CATEGORY - 44
    local Y_HEADER = -84
    local ROW_HEIGHT = 24
    local CATEGORY_GAP = 6

    local refreshables = {}
    local categoryRows = {}

    local contentViewport = CreateFrame("ScrollFrame", nil, parent)
    contentViewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    contentViewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    contentViewport:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, contentViewport)
    content:SetPoint("TOPLEFT", contentViewport, "TOPLEFT", 0, 0)
    content:SetSize(680, 900)
    contentViewport:SetScrollChild(content)

    local scrollSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    scrollSlider:SetOrientation("VERTICAL")
    scrollSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
    scrollSlider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 26)
    scrollSlider:SetWidth(16)
    scrollSlider:SetMinMaxValues(0, 100)
    scrollSlider:SetValueStep(1)
    scrollSlider:SetObeyStepOnDrag(true)
    scrollSlider:SetValue(0)
    if scrollSlider.Low then scrollSlider.Low:Hide() end
    if scrollSlider.High then scrollSlider.High:Hide() end
    if scrollSlider.Text then scrollSlider.Text:Hide() end

    local function RegisterRefreshable(control, refresher)
        control.PreydatorRefresh = refresher
        refreshables[#refreshables + 1] = control
        return control
    end

    local function IsEntryEnabled(entry, target)
        if target == "currency" then
            return settings.currencyTrackedIDs[entry.id] ~= false
        end
        if target == "warband" then
            return settings.currencyWarbandTrackedIDs[entry.id] ~= false
        end
        return (settings.currencyTrackedIDs[entry.id] ~= false) and (settings.currencyWarbandTrackedIDs[entry.id] ~= false)
    end

    local function SetEntryEnabled(entry, target, enabled)
        local checked = enabled and true or false
        if target == "currency" then
            settings.currencyTrackedIDs[entry.id] = checked
        elseif target == "warband" then
            settings.currencyWarbandTrackedIDs[entry.id] = checked
        else
            settings.currencyTrackedIDs[entry.id] = checked
            settings.currencyWarbandTrackedIDs[entry.id] = checked
        end
    end

    local function IsCategoryEnabled(entries, target)
        if #entries == 0 then
            return false
        end
        for _, entry in ipairs(entries) do
            if not IsEntryEnabled(entry, target) then
                return false
            end
        end
        return true
    end

    local function SetCategoryEnabled(entries, target, enabled)
        for _, entry in ipairs(entries) do
            SetEntryEnabled(entry, target, enabled)
        end
    end

    local function CreateMatrixCheckbox(host, x, y, getter, setter, enabledGetter)
        local check = CreateFrame("CheckButton", nil, host, "InterfaceOptionsCheckButtonTemplate")
        check:SetPoint("TOPLEFT", host, "TOPLEFT", x, y)
        check.Text:SetText("")
        check:SetScript("OnClick", function(self)
            setter(self:GetChecked() and true or false)
            CurrencyTrackerModule:RefreshCurrencyPage()
        end)
        RegisterRefreshable(check, function(control)
            control:SetChecked(getter() and true or false)
            local isEnabled = true
            if type(enabledGetter) == "function" then
                isEnabled = enabledGetter() and true or false
            end
            control:SetAlpha(isEnabled and 1 or 0.45)
            control:SetEnabled(isEnabled)
            if control.EnableMouse then
                control:EnableMouse(isEnabled)
            end
        end)
        return check
    end

    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", content, "TOPLEFT", X_CATEGORY, -12)
    title:SetText(L["Currency Selection"])

    local note = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", content, "TOPLEFT", X_CATEGORY, -40)
    note:SetWidth(620)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(L["Choose where each currency appears: Currency panel, Warband panel, or both. Category checkboxes apply to all currencies in that section."])

    local categoryHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    categoryHeader:SetPoint("TOPLEFT", content, "TOPLEFT", X_CATEGORY + 26, Y_HEADER)
    categoryHeader:SetText(L["Category"])
    SetTextColor(categoryHeader, COLOR_GOLD)

    local currencyHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currencyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", X_CURRENCY, Y_HEADER)
    currencyHeader:SetText(L["Currency"])
    SetTextColor(currencyHeader, COLOR_GOLD)

    local warbandHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    warbandHeader:SetPoint("TOPLEFT", content, "TOPLEFT", X_WARBAND, Y_HEADER)
    warbandHeader:SetText(L["Warband"])
    SetTextColor(warbandHeader, COLOR_GOLD)

    local bothHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bothHeader:SetPoint("TOPLEFT", content, "TOPLEFT", X_BOTH, Y_HEADER)
    bothHeader:SetText(L["Both"])
    SetTextColor(bothHeader, COLOR_GOLD)

    local function UpdateCategoryButtonText(category)
        category.expandButton:SetText(settings.currencyCategoryCollapsed[category.key] and "+" or "-")
    end

    local CATEGORY_ORDER = {
        { key = "expansion", label = L["Expansion"] },
        { key = "seasonal", label = L["Seasonal"] },
        { key = "crafting", label = L["Crafting"] },
    }

    for _, spec in ipairs(CATEGORY_ORDER) do
        local entries = GetCurrencyEntriesForGroup(spec.key)
        local category = {
            key = spec.key,
            entries = entries,
            row = CreateFrame("Frame", nil, content),
            children = {},
        }
        category.row:SetSize(640, ROW_HEIGHT)

        category.expandButton = CreateFrame("Button", nil, category.row, "UIPanelButtonTemplate")
        category.expandButton:SetSize(20, 18)
        category.expandButton:SetPoint("TOPLEFT", category.row, "TOPLEFT", 0, -2)
        category.expandButton:SetScript("OnClick", function()
            settings.currencyCategoryCollapsed[spec.key] = not (settings.currencyCategoryCollapsed[spec.key] == true)
            parent:PreydatorCurrencyRefresh()
        end)
        RegisterRefreshable(category.expandButton, function()
            UpdateCategoryButtonText(category)
        end)

        local name = category.row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOPLEFT", category.row, "TOPLEFT", 26, -6)
        name:SetText(spec.label)
        SetTextColor(name, COLOR_GOLD)

        CreateMatrixCheckbox(category.row, X_CURRENCY - X_CATEGORY, 0, function()
            return IsCategoryEnabled(entries, "currency")
        end, function(value)
            SetCategoryEnabled(entries, "currency", value)
        end, function()
            return IsModuleEnabled("currency")
        end)

        CreateMatrixCheckbox(category.row, X_WARBAND - X_CATEGORY, 0, function()
            return IsCategoryEnabled(entries, "warband")
        end, function(value)
            SetCategoryEnabled(entries, "warband", value)
        end, function()
            return IsModuleEnabled("warband")
        end)

        CreateMatrixCheckbox(category.row, X_BOTH - X_CATEGORY, 0, function()
            return IsCategoryEnabled(entries, "both")
        end, function(value)
            SetCategoryEnabled(entries, "both", value)
        end, function()
            return IsModuleEnabled("currency") and IsModuleEnabled("warband")
        end)

        for _, entry in ipairs(entries) do
            local child = CreateFrame("Frame", nil, content)
            child:SetSize(640, ROW_HEIGHT)

            local label = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            label:SetPoint("TOPLEFT", child, "TOPLEFT", 26, -6)
            label:SetWidth(LABEL_WIDTH)
            label:SetJustifyH("LEFT")
            local info = GetCurrencyInfoSafe(entry.id)
            label:SetText((info and info.name) or entry.name)

            CreateMatrixCheckbox(child, X_CURRENCY - X_CATEGORY, 0, function()
                return IsEntryEnabled(entry, "currency")
            end, function(value)
                SetEntryEnabled(entry, "currency", value)
            end, function()
                return IsModuleEnabled("currency")
            end)

            CreateMatrixCheckbox(child, X_WARBAND - X_CATEGORY, 0, function()
                return IsEntryEnabled(entry, "warband")
            end, function(value)
                SetEntryEnabled(entry, "warband", value)
            end, function()
                return IsModuleEnabled("warband")
            end)

            CreateMatrixCheckbox(child, X_BOTH - X_CATEGORY, 0, function()
                return IsEntryEnabled(entry, "both")
            end, function(value)
                SetEntryEnabled(entry, "both", value)
            end, function()
                return IsModuleEnabled("currency") and IsModuleEnabled("warband")
            end)

            category.children[#category.children + 1] = child
        end

        categoryRows[#categoryRows + 1] = category
    end

    local function LayoutCategoryRows()
        local y = Y_HEADER - 30

        for _, category in ipairs(categoryRows) do
            category.row:SetPoint("TOPLEFT", content, "TOPLEFT", X_CATEGORY, y)
            category.row:Show()
            y = y - ROW_HEIGHT

            local collapsed = settings.currencyCategoryCollapsed[category.key] == true
            for _, child in ipairs(category.children) do
                if collapsed then
                    child:Hide()
                else
                    child:SetPoint("TOPLEFT", content, "TOPLEFT", X_CATEGORY, y)
                    child:Show()
                    y = y - ROW_HEIGHT
                end
            end

            y = y - CATEGORY_GAP
        end

        local usedHeight = math.max(600, math.floor(-y + 30))
        content:SetHeight(usedHeight)
    end

    local function UpdateScrollBounds()
        local viewportHeight = contentViewport:GetHeight() or 0
        local contentHeight = content:GetHeight() or 0
        local maxScroll = math.max(0, math.floor(contentHeight - viewportHeight + 0.5))
        local currentScroll = math.max(0, math.min(maxScroll, contentViewport:GetVerticalScroll() or 0))
        scrollSlider:SetMinMaxValues(0, maxScroll)
        scrollSlider:SetValue(currentScroll)
        contentViewport:SetVerticalScroll(currentScroll)
        scrollSlider:SetShown(maxScroll > 0)
    end

    scrollSlider:SetScript("OnValueChanged", function(self, value)
        contentViewport:SetVerticalScroll(math.floor((value or 0) + 0.5))
    end)

    contentViewport:SetScript("OnMouseWheel", function(self, delta)
        local step = 42
        local current = scrollSlider:GetValue() or 0
        local minValue, maxValue = scrollSlider:GetMinMaxValues()
        local nextValue = current - (delta * step)
        if nextValue < minValue then
            nextValue = minValue
        end
        if nextValue > maxValue then
            nextValue = maxValue
        end
        scrollSlider:SetValue(nextValue)
        self:SetVerticalScroll(math.floor(nextValue + 0.5))
    end)

    contentViewport:HookScript("OnSizeChanged", function()
        UpdateScrollBounds()
    end)

    function parent:PreydatorCurrencyRefresh()
        for _, control in ipairs(refreshables) do
            if type(control.PreydatorRefresh) == "function" then
                control:PreydatorRefresh()
            end
        end
        LayoutCategoryRows()
        UpdateScrollBounds()
    end

    parent:PreydatorCurrencyRefresh()
end

function CurrencyTrackerModule:BuildCurrencyPage(owner, parent)
    currencyPanelPage = parent
    BuildCurrencyConfigPage(parent)
end

function CurrencyTrackerModule:RefreshCurrencyPage()
    CheckAndProcessWeeklyReset()

    local currencyModuleEnabled = IsModuleEnabled("currency")
    local warbandModuleEnabled = IsModuleEnabled("warband")

    if not (currencyModuleEnabled or warbandModuleEnabled) then
        local settings = GetSettings()
        if settings then
            settings.currencyWindowEnabled = false
            settings.currencyWarbandWindowEnabled = false
        end
        if currencyWindow then
            currencyWindow:Hide()
        end
        if warbandWindow then
            warbandWindow:Hide()
        end
        return
    end

    SnapshotCurrentCharacter()
    SnapshotCurrentPreyCharacter()
    UpdateLastKnownQuantities()
    if currencyModuleEnabled then
        if currencyWindow and currencyWindow:IsShown() then
            RefreshCurrencyWindowDisplay()
        end
    elseif currencyWindow then
        currencyWindow:Hide()
    end
    if warbandModuleEnabled then
        if warbandWindow and warbandWindow:IsShown() then
            RefreshWarbandWindowDisplay()
        end
    elseif warbandWindow then
        warbandWindow:Hide()
    end
    if currencyWindow and currencyWindow.PreydatorAutoHideButton and type(currencyWindow.PreydatorAutoHideButton.PreydatorRefresh) == "function" then
        currencyWindow.PreydatorAutoHideButton:PreydatorRefresh()
    end
    if warbandWindow and warbandWindow.PreydatorAutoHideButton and type(warbandWindow.PreydatorAutoHideButton.PreydatorRefresh) == "function" then
        warbandWindow.PreydatorAutoHideButton:PreydatorRefresh()
    end
    ApplyWindowAutoHideState(currencyWindow, "currency")
    ApplyWindowAutoHideState(warbandWindow, "warband")
    if currencyPanelPage and currencyPanelPage:IsVisible() and type(currencyPanelPage.PreydatorCurrencyRefresh) == "function" then
        currencyPanelPage:PreydatorCurrencyRefresh()
    end
end

function CurrencyTrackerModule:RefreshIfChanged(force, source)
    local changedEntries = UpdateLastKnownQuantities()
    local hasDelta = #changedEntries > 0

    if force or hasDelta then
        self:RefreshCurrencyPage()
    end

    if force or hasDelta then
        if hasDelta then
            local parts = {}
            for _, entry in ipairs(changedEntries) do
                parts[#parts + 1] = entry.label .. "(" .. tostring(entry.id) .. "): " .. tostring(entry.old) .. " -> " .. tostring(entry.new)
            end
            LogCurrencyDebug(tostring(source or "unknown") .. " | " .. table.concat(parts, ", "))
        else
            LogCurrencyDebug(tostring(source or "unknown") .. " | forced refresh, no allow-list delta")
        end
    end
end

local pendingCurrencyRefreshChecks = {}

local function ScheduleRefreshIfChanged(delaySeconds, source)
    if not C_Timer or type(C_Timer.After) ~= "function" then
        CurrencyTrackerModule:RefreshIfChanged(false, source)
        return
    end

    local delayKey = tostring(delaySeconds)
    if pendingCurrencyRefreshChecks[delayKey] then
        return
    end

    pendingCurrencyRefreshChecks[delayKey] = true
    C_Timer.After(delaySeconds, function()
        pendingCurrencyRefreshChecks[delayKey] = nil
        CurrencyTrackerModule:RefreshIfChanged(false, source)
    end)
end

function CurrencyTrackerModule:QueueRefreshSweep(source, immediate)
    if not (IsModuleEnabled("currency") or IsModuleEnabled("warband")) then
        return
    end

    if immediate == true then
        self:RefreshCurrencyPage()
        LogCurrencyDebug(tostring(source or "unknown") .. " | immediate sweep")
    else
        LogCurrencyDebug(tostring(source or "unknown") .. " | deferred change-check")
    end

    if not C_Timer or type(C_Timer.After) ~= "function" then
        if immediate ~= true then
            self:RefreshIfChanged(false, tostring(source or "unknown") .. "+fallback")
        end
        return
    end

    -- Delayed passes catch server-delayed currency updates that land after the event tick.
    ScheduleRefreshIfChanged(0.2, tostring(source or "unknown") .. "+200ms")
    ScheduleRefreshIfChanged(1.0, tostring(source or "unknown") .. "+1000ms")
end

-- Live refresh via CURRENCY_DISPLAY_UPDATE
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        ApplyWindowAutoHideState(currencyWindow, "currency")
        ApplyWindowAutoHideState(warbandWindow, "warband")
        return
    end

    if event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID = ...
        if type(currencyID) == "number" and ALLOW_LIST_IDS[currencyID] then
            CurrencyTrackerModule:QueueRefreshSweep("CURRENCY_DISPLAY_UPDATE(" .. tostring(currencyID) .. ")", true)
            return
        end
        CurrencyTrackerModule:QueueRefreshSweep("CURRENCY_DISPLAY_UPDATE", false)
        return
    end

    if event == "QUEST_TURNED_IN" then
        local questID = ...
        RecordPreyTurnIn(questID)
    end

    if event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" then
        -- Loot/currency chat should feel immediate in the tracker UI.
        CurrencyTrackerModule:QueueRefreshSweep(event, true)
        return
    end

    if event == "QUEST_TURNED_IN" or event == "BAG_UPDATE_DELAYED" then
        CurrencyTrackerModule:QueueRefreshSweep(event, false)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Re-apply instance-hide state every time the player crosses a loading screen.
        UpdateVisibilityFromSettings()
        -- Gate the full sweep so it doesn't double-fire immediately after PLAYER_LOGIN.
        local now = GetTime and (tonumber(GetTime()) or 0) or 0
        if now >= (nextLightRefreshAt or 0) then
            nextLightRefreshAt = now + 2.0
            CurrencyTrackerModule:QueueRefreshSweep(event, true)
        end
    end
end)

-- No polling: currency refresh is event-driven via loot/currency/update events.

--------------------------------------------------------------------------------
-- Module lifecycle hooks
--------------------------------------------------------------------------------

function CurrencyTrackerModule:OnAddonLoaded()
    EnsureDB()
    EnsureTrackerSettings()
    CheckAndProcessWeeklyReset()
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    eventFrame:RegisterEvent("QUEST_TURNED_IN")
    eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    -- Keep refresh event-driven (no polling), but include direct currency signals
    -- so gains/losses are reflected immediately.
    sessionStart = {}
    sessionBaselineReady = false
    UpdateLastKnownQuantities()
    SnapshotCurrentPreyCharacter()
end

function CurrencyTrackerModule:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        EnsureDB()
        EnsureTrackerSettings()
        CheckAndProcessWeeklyReset()
        sessionStart = {}
        sessionBaselineReady = false
        PrimeSessionBaseline("PLAYER_LOGIN")
        SnapshotCurrentCharacter()
        UpdateLastKnownQuantities()
        if IsModuleEnabled("currency") then
            EnsureCurrencyWindow()
        end
        if IsModuleEnabled("warband") then
            EnsureWarbandWindow()
        end
        UpdateVisibilityFromSettings()
        UpdateWindowPosition()
        UpdateWarbandWindowPosition()
        self:RefreshCurrencyPage()
        -- Arm the gate so the PLAYER_ENTERING_WORLD that fires right after login
        -- doesn't immediately trigger a redundant full QueueRefreshSweep.
        do
            local now = GetTime and (tonumber(GetTime()) or 0) or 0
            nextLightRefreshAt = now + 4.0
        end

        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0.5, function()
                if PrimeSessionBaseline("PLAYER_LOGIN+0.5s") then
                    CurrencyTrackerModule:RefreshCurrencyPage()
                end
            end)
            C_Timer.After(1.5, function()
                if PrimeSessionBaseline("PLAYER_LOGIN+1.5s") then
                    CurrencyTrackerModule:RefreshCurrencyPage()
                end
            end)
            C_Timer.After(3.0, function()
                if PrimeSessionBaseline("PLAYER_LOGIN+3.0s") then
                    CurrencyTrackerModule:RefreshCurrencyPage()
                end
            end)
        end

        ShowCurrencyWhatsNewIfNeeded()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        local now = GetTime and (tonumber(GetTime()) or 0) or 0
        if now >= (nextLightRefreshAt or 0) then
            nextLightRefreshAt = now + 2.0
            CheckAndProcessWeeklyReset()
            SnapshotCurrentPreyCharacter()
            RefreshWarbandWindowDisplay()
            if currencyPanelPage and currencyPanelPage:IsVisible() then
                self:RefreshCurrencyPage()
            end
        end
    end
end
