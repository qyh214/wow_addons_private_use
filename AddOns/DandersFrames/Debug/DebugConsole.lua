local addonName, DF = ...

-- ============================================================
-- DEBUG CONSOLE
-- Persistent debug logging system with settings UI integration
-- Provides DF:Debug(), DF:DebugWarn(), DF:DebugError() API
-- Logs persist in SavedVariables across /rl
-- ============================================================

local pairs, ipairs, type, tostring = pairs, ipairs, type, tostring
local tinsert, tremove, wipe = table.insert, table.remove, wipe
local format = string.format
local date = date

local DebugConsole = {}
DF.DebugConsole = DebugConsole

-- ============================================================
-- CONSTANTS
-- ============================================================

local SEVERITY = {
    INFO  = { level = 1, label = "INFO",  color = "|cff88ccff" },  -- Light blue
    WARN  = { level = 2, label = "WARN",  color = "|cffffff66" },  -- Yellow
    ERROR = { level = 3, label = "ERROR", color = "|cffff6666" },  -- Red
}

local SEVERITY_ORDER = { "INFO", "WARN", "ERROR" }

-- ============================================================
-- DECLARED CATEGORY REGISTRY
-- All categories used by DF:Debug calls anywhere in the addon are
-- declared here so the Debug Console can show them BEFORE any logs
-- exist. The user can pre-disable noisy categories before triggering
-- the bug they're trying to capture, ensuring the relevant trace
-- never gets evicted by the maxLines cap.
--
-- New categories that aren't in this registry are still auto-
-- discovered the first time they log, and appear under "Other".
-- Order within each group is preserved as written.
-- ============================================================

local CATEGORY_GROUPS = {
    {
        name = "Frames & Layout",
        categories = {
            { key = "ROSTER",     desc = "Group composition changes, throttling, sorting decisions" },
            { key = "RAIDPOS",    desc = "Raid container position writes (jumping/stuck-position bug)" },
            { key = "POSITION",   desc = "Secure position handler trigger and snippet runs" },
            { key = "LAYOUT",     desc = "Frame size, spacing, growth direction, container resize" },
            { key = "VISIBILITY", desc = "Header show/hide and state-driver changes" },
            { key = "FLATRAID",   desc = "Flat raid layout and sorting" },
            { key = "FRAMESORT",  desc = "FrameSort addon integration" },
            { key = "PINNED",     desc = "Pinned frames init, layout changes, boss handler, test mode" },
        },
    },
    {
        name = "Profiles",
        categories = {
            { key = "PROFILE",     desc = "Profile load, save, switch, full refresh" },
            { key = "AUTOPROFILE", desc = "Auto-profile evaluation and runtime overlay" },
        },
    },
    {
        name = "Auras",
        categories = {
            { key = "AD",       desc = "Aura Designer" },
            { key = "BLIZAURA", desc = "Blizzard aura source pipeline" },
        },
    },
    {
        name = "Other",
        categories = {
            { key = "API",          desc = "External API callback fires (OnFramesSorted, etc.)" },
            { key = "CLICK",        desc = "Click-casting binding apply, hover, PreClick state" },
            { key = "PET",          desc = "Pet frame lifecycle and visibility" },
            { key = "SCRIPT",       desc = "Lua script errors and pcall failures" },
            { key = "SYSTEM",       desc = "Reload separators and init confirmation" },
            { key = "TARGETEDLIST", desc = "Targeted List cast pickup, stop, and interrupter lookup (alpha/beta only)" },
        },
    },
}

local DEFAULTS = {
    enabled = false,
    logLevel = "INFO",
    maxLines = 10000,
    chatEcho = false,
    filters = {},  -- absent category = visible; explicit false = hidden
}

-- ============================================================
-- RUNTIME STATE
-- ============================================================

local debugDb       -- reference to DandersFramesDB_v2.debug
local debugLog      -- reference to DandersFramesDB_v2.debugLog
local knownCategories = {}  -- set: { ["PET"] = true, ["FONT"] = true, ... }
local liveEditBox         -- EditBox reference when debug tab is visible
local needsRefresh = false  -- flag to batch refresh when tab is visible

-- ============================================================
-- INITIALIZATION
-- ============================================================

function DebugConsole:Init()
    -- Ensure debug settings table exists
    if not DandersFramesDB_v2.debug then
        DandersFramesDB_v2.debug = {}
    end

    -- Apply missing defaults (migration-safe)
    for key, value in pairs(DEFAULTS) do
        if DandersFramesDB_v2.debug[key] == nil then
            if type(value) == "table" then
                DandersFramesDB_v2.debug[key] = {}
            else
                DandersFramesDB_v2.debug[key] = value
            end
        end
    end

    -- Ensure log array exists
    if not DandersFramesDB_v2.debugLog then
        DandersFramesDB_v2.debugLog = {}
    end

    -- Set live references
    debugDb = DandersFramesDB_v2.debug
    debugLog = DandersFramesDB_v2.debugLog

    -- Sync the ephemeral flag with persistent setting
    DF.debugEnabled = debugDb.enabled

    -- Rebuild known categories from existing log entries
    wipe(knownCategories)
    for _, entry in ipairs(debugLog) do
        local cat = entry[3]
        if cat and cat ~= "" then
            knownCategories[cat] = true
        end
    end

    -- Add reload separator if log has prior entries
    if #debugLog > 0 then
        tinsert(debugLog, {
            date("%H:%M:%S"),
            "INFO",
            "SYSTEM",
            "--- UI Reload ---"
        })
        knownCategories["SYSTEM"] = true
        self:PruneLog()
    end

    -- Log initialization status (confirms debug system is working)
    if debugDb.enabled then
        self:Log("INFO", "SYSTEM", "Debug Console initialized (enabled=%s, logLevel=%s, entries=%d)",
            tostring(debugDb.enabled), tostring(debugDb.logLevel), #debugLog)
    end
end

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Per-category logging gate. An explicit `false` in filters disables the
-- category at the source so it never enters the log buffer — preventing
-- noise categories from evicting the relevant trace under the maxLines cap.
-- Absent (nil) or `true` = log it. Auto-discovery still works because new
-- categories aren't in `filters` until the user explicitly disables them.
local function IsCategoryLogged(category)
    local filters = debugDb and debugDb.filters
    if not filters or not category then return true end
    return filters[category] ~= false
end

function DF:Debug(category, fmt, ...)
    if not debugDb or not debugDb.enabled then return end
    if not IsCategoryLogged(category) then return end
    DebugConsole:Log("INFO", category, fmt, ...)
end

function DF:DebugWarn(category, fmt, ...)
    if not debugDb or not debugDb.enabled then return end
    if not IsCategoryLogged(category) then return end
    DebugConsole:Log("WARN", category, fmt, ...)
end

function DF:DebugError(category, fmt, ...)
    if not debugDb or not debugDb.enabled then return end
    if not IsCategoryLogged(category) then return end
    DebugConsole:Log("ERROR", category, fmt, ...)
end

-- ============================================================
-- INTERNAL LOGGING
-- ============================================================

-- Returns true if the given value is a WoW "secret" (secret-tainted) value.
-- Secret values cannot be used in table.concat or most string operations
-- without errors. We use this to sanitize log messages so a tainted value
-- can never corrupt the debug log. Gracefully no-ops on builds without the API.
local isSecretValue = _G.issecretvalue or function() return false end

-- Sanitizes a message string for safe storage in the log. If the string
-- itself is secret-tainted (because one of the format args was a secret),
-- returns a non-secret placeholder instead.
local function sanitizeLogMessage(msg)
    if msg == nil then return "nil" end
    if type(msg) ~= "string" then
        msg = tostring(msg)
    end
    if isSecretValue(msg) then
        return "<SECRET — log arg was a secret value>"
    end
    return msg
end

function DebugConsole:Log(level, category, fmt, ...)
    -- Format the message. If any format arg is a secret-tainted value, the
    -- resulting string inherits the taint and cannot be safely concatenated
    -- later. sanitizeLogMessage replaces tainted messages with a placeholder.
    local msg
    if select("#", ...) > 0 then
        local ok, result = pcall(format, fmt, ...)
        msg = ok and result or (tostring(fmt) .. " [format error]")
    else
        msg = tostring(fmt)
    end
    msg = sanitizeLogMessage(msg)

    -- Create entry: {timestamp, level, category, message}
    local entry = {
        date("%H:%M:%S"),
        level,
        category or "GENERAL",
        msg,
    }

    tinsert(debugLog, entry)

    -- Track new categories
    local cat = entry[3]
    if not knownCategories[cat] then
        knownCategories[cat] = true
        -- New category discovered — if filters table doesn't have it, it defaults to visible
    end

    -- Prune if over limit
    self:PruneLog()

    -- Echo to chat if enabled
    if debugDb.chatEcho then
        local sev = SEVERITY[level] or SEVERITY.INFO
        print(format("%s[DF %s]|r [%s] %s", sev.color, sev.label, cat, msg))
    end

    -- Flag refresh for live display
    if liveEditBox then
        needsRefresh = true
        -- Defer refresh to avoid spam during rapid logging
        if not self.refreshTimer then
            self.refreshTimer = C_Timer.NewTimer(0.05, function()
                self.refreshTimer = nil
                if needsRefresh and liveEditBox then
                    self:RefreshDisplay()
                end
            end)
        end
    end
end

-- ============================================================
-- LOG MANAGEMENT
-- ============================================================

function DebugConsole:PruneLog()
    if not debugLog or not debugDb then return end
    local maxLines = debugDb.maxLines or 500
    while #debugLog > maxLines do
        tremove(debugLog, 1)
    end
end

function DebugConsole:ClearLog()
    if debugLog then
        wipe(debugLog)
    end
    wipe(knownCategories)
    if liveEditBox then
        self:RefreshDisplay()
    end
end

function DebugConsole:SetEnabled(enabled)
    if debugDb then
        debugDb.enabled = enabled
    end
    DF.debugEnabled = enabled
end

function DebugConsole:IsEnabled()
    return debugDb and debugDb.enabled or false
end

-- ============================================================
-- DISPLAY RENDERING
-- ============================================================

function DebugConsole:RefreshDisplay()
    needsRefresh = false
    if not liveEditBox or not debugLog then return end

    local minLevel = SEVERITY[debugDb.logLevel or "INFO"]
    if not minLevel then minLevel = SEVERITY.INFO end
    local minLevelNum = minLevel.level

    local filters = debugDb.filters or {}
    local lines = {}

    for _, entry in ipairs(debugLog) do
        local timestamp = entry[1] or "??:??:??"
        local level     = entry[2] or "INFO"
        local category  = entry[3] or "GENERAL"
        local message   = entry[4]

        -- Sanitize every field BEFORE passing to format. Legacy entries
        -- (logged before the write-time sanitizer existed) may have nil or
        -- secret-tainted messages which would crash format().
        if message == nil then
            message = "<nil>"
        elseif type(message) ~= "string" then
            message = tostring(message) or "<nonstring>"
        end
        if isSecretValue(message) then
            message = "<SECRET — legacy tainted entry>"
        end
        if type(timestamp) ~= "string" or isSecretValue(timestamp) then
            timestamp = "??:??:??"
        end
        if type(category) ~= "string" or isSecretValue(category) then
            category = "GENERAL"
        end

        -- Check severity filter
        local sev = SEVERITY[level]
        if sev and sev.level >= minLevelNum then
            -- Check category filter (absent = visible, explicit false = hidden)
            if filters[category] ~= false then
                local colorCode = sev.color or "|cffffffff"
                local ok, formatted = pcall(format, "%s %s[%s]|r [%s] %s",
                    timestamp, colorCode, sev.label, category, message)
                if ok and not isSecretValue(formatted) then
                    tinsert(lines, formatted)
                else
                    tinsert(lines, timestamp .. " [" .. (sev.label or "?") ..
                        "] [" .. category .. "] <unrenderable entry>")
                end
            end
        end
    end

    local text = #lines > 0 and table.concat(lines, "\n") or "|cff666666No log entries match current filters.|r"
    liveEditBox:SetText(text)

    -- Update EditBox height to fit all text (enables scroll frame scrolling)
    -- EditBox doesn't have GetStringHeight, so calculate from line count + font size
    local numLines = 1
    for _ in text:gmatch("\n") do numLines = numLines + 1 end
    local _, fontSize = liveEditBox:GetFont()
    local lineHeight = (fontSize or 10) + 2
    liveEditBox:SetHeight(math.max(390, numLines * lineHeight + 10))

    -- Auto-scroll to bottom (delay to let scroll range recalculate after height change)
    local scrollFrame = liveEditBox:GetParent()
    if scrollFrame and scrollFrame.SetVerticalScroll then
        C_Timer.After(0.02, function()
            if scrollFrame and scrollFrame.GetVerticalScrollRange then
                scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
            end
        end)
    end
end

function DebugConsole:SetLiveEditBox(editBox)
    liveEditBox = editBox
    if editBox then
        self:RefreshDisplay()
    end
end

-- ============================================================
-- CATEGORY ACCESS
-- ============================================================

function DebugConsole:GetKnownCategories()
    return knownCategories
end

-- Returns the declared category groups (ordered list of {name, categories}).
-- Used by the settings UI to render checkboxes grouped by feature.
function DebugConsole:GetCategoryGroups()
    return CATEGORY_GROUPS
end

-- Returns a set of every category declared in the registry.
-- Used to figure out which auto-discovered categories should appear under
-- the dynamic "Other" group (those not already in the registry).
function DebugConsole:GetRegisteredCategorySet()
    local set = {}
    for _, group in ipairs(CATEGORY_GROUPS) do
        for _, cat in ipairs(group.categories) do
            set[cat.key] = true
        end
    end
    return set
end

function DebugConsole:GetLogEntryCount()
    return debugLog and #debugLog or 0
end

-- ============================================================
-- EXPORT
-- ============================================================

function DebugConsole:GetExportText()
    if not debugLog then return "No debug log available." end

    -- Respect current severity and category filters so the export
    -- matches what the user sees in the debug console
    local minLevel = SEVERITY[(debugDb and debugDb.logLevel) or "INFO"]
    if not minLevel then minLevel = SEVERITY.INFO end
    local minLevelNum = minLevel.level
    local filters = (debugDb and debugDb.filters) or {}

    local entries = {}
    for _, entry in ipairs(debugLog) do
        local sev = SEVERITY[entry[2]]
        if sev and sev.level >= minLevelNum and filters[entry[3]] ~= false then
            -- Sanitize each field before format — legacy entries may have
            -- nil or secret-tainted values which would crash format/concat.
            local ts  = entry[1]
            local lvl = entry[2]
            local cat = entry[3]
            local msg = entry[4]
            if type(ts)  ~= "string" or isSecretValue(ts)  then ts  = "??:??:??" end
            if type(lvl) ~= "string" or isSecretValue(lvl) then lvl = "INFO" end
            if type(cat) ~= "string" or isSecretValue(cat) then cat = "GENERAL" end
            if msg == nil then
                msg = "<nil>"
            elseif type(msg) ~= "string" then
                msg = tostring(msg) or "<nonstring>"
            end
            if isSecretValue(msg) then msg = "<SECRET — legacy tainted entry>" end

            local ok, formatted = pcall(format, "%s [%s] [%s] %s", ts, lvl, cat, msg)
            if ok and not isSecretValue(formatted) then
                tinsert(entries, formatted)
            else
                tinsert(entries, ts .. " [" .. lvl .. "] [" .. cat .. "] <unrenderable entry>")
            end
        end
    end

    local result = {}
    tinsert(result, "DandersFrames Debug Log")
    tinsert(result, "Version: " .. (DF.VERSION or "unknown"))
    tinsert(result, "Exported: " .. date("%Y-%m-%d %H:%M:%S"))
    tinsert(result, "Entries: " .. #entries .. " (filtered from " .. #debugLog .. " total)")
    tinsert(result, "Min Level: " .. (debugDb and debugDb.logLevel or "INFO"))
    tinsert(result, "========================================")
    tinsert(result, "")
    for i = 1, #entries do
        local entry = entries[i]
        if isSecretValue(entry) then
            entry = "<SECRET — export line was tainted>"
        end
        result[#result + 1] = entry
    end

    return table.concat(result, "\n")
end
