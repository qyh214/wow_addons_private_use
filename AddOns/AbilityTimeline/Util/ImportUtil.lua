local appName, app = ...
---@class AbilityTimeline
local private = app
local CustomNames = C_AddOns.IsAddOnLoaded("CustomNames") and LibStub("CustomNames")
private.ImportUtil = private.ImportUtil or {}
local ImportUtil = private.ImportUtil
local IMPORT_PREFIX = "!AT:"

-- Parse time string in mm:ss or seconds format
---@param timeStr string Time as "mm:ss" or "seconds"
---@return number|nil parsed time in seconds
local function parseTime(timeStr)
    if not timeStr then return nil end

    -- Remove leading/trailing whitespace
    timeStr = timeStr:gsub("^%s+", ""):gsub("%s+$", "")

    -- Try to match mm:ss format
    local minutes, seconds = string.match(timeStr, "^(%d+):(%d+)$")
    if minutes and seconds then
        return tonumber(minutes) * 60 + tonumber(seconds)
    end

    -- Try as plain seconds
    local secs = tonumber(timeStr)
    if secs then
        return secs
    end

    return nil
end

-- Parse single MRT note line
---@param line string MRT note line
---@return table|nil parsed reminder data
local function parseMRTLine(line)
    if not line or line == "" then return nil end

    -- Remove leading/trailing whitespace
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line == "" then return nil end

    -- Skip empty lines and pure section markers (not lines with {time:})
    if not string.find(line, "{time:") then
        return nil
    end

    private.Debug("Parsing MRT line: " .. line)

    -- Parse {time:XX} or {time:MM:SS}
    local timeStr = string.match(line, "{time:([^}]+)}")
    private.Debug("Found timeStr: " .. tostring(timeStr))
    if not timeStr then return nil end

    local time = parseTime(timeStr)
    private.Debug("Parsed time: " .. tostring(time))
    if not time then return nil end

    -- Parse {spell:XXXXX}
    local spellIdStr = string.match(line, "{spell:(%d+)}")
    private.Debug("Found spellIdStr: " .. tostring(spellIdStr))
    local spellId = spellIdStr and tonumber(spellIdStr) or nil

    if not spellId then
        private.Debug("No spell ID found")
        return nil
    end

    local spellInfo = C_Spell.GetSpellInfo(spellId)
    local spellName = spellInfo and spellInfo.name
    local icon = spellInfo and spellInfo.iconID
    private.Debug("Got spell info for " .. spellId .. ": " .. tostring(spellName))

    -- Extract optional player name (first word that's not in brackets)
    local playerName = string.match(line, "%s([%w]+)%s{")
    if not playerName then
        playerName = string.match(line, "^%s*([%w]+)%s{")
    end

    local reminder = {
        name = playerName or spellName or "Unknown",
        spellId = spellId,
        spellName = spellName,
        iconId = icon or 134400,
        CombatTime = time,
        CombatTimeDelay = 0,
        StartTimerAfter = 0,
        severity = 1,
        effectTypes = 0,
    }

    private.Debug("Successfully parsed reminder: " .. reminder.name)
    return reminder
end

-- Parse MRT note format (plain text with {time:} and {spell:} markers)
---@param mrtText string Complete MRT note text
---@return table array of parsed reminders
function ImportUtil:ParseMRTFormat(mrtText)
    local reminders = {}

    private.Debug("ParseMRTFormat called with text: " .. mrtText)

    -- Split by lines
    local lines = {}
    for line in mrtText:gmatch("[^\n\r]+") do
        table.insert(lines, line)
    end

    private.Debug("Split into " .. #lines .. " lines")

    for i, line in ipairs(lines) do
        private.Debug("Line " .. i .. ": " .. line)
        local reminder = parseMRTLine(line)
        if reminder then
            private.Debug("Successfully added reminder from line " .. i)
            table.insert(reminders, reminder)
        else
            private.Debug("Failed to parse line " .. i)
        end
    end

    private.Debug("ParseMRTFormat returning " .. #reminders .. " reminders")
    return reminders
end

-- Parse Viserio format
---@param viserioText string Viserio format text
---@return table array of parsed reminders
---@return number|nil encounterID from first line
---@return string|nil encounterName from first line
function ImportUtil:ParseViserioFormat(viserioText)
    local reminders = {}
    local encounterID = nil
    local encounterName = nil

    -- Split by lines
    local lines = {}
    for line in viserioText:gmatch("[^\n\r]+") do
        table.insert(lines, line)
    end

    if #lines == 0 then
        return reminders, encounterID, encounterName
    end

    -- First line should be "EncounterID:number;Name:string" or just "EncounterID:number"
    local firstLine = lines[1]
    encounterID = tonumber(firstLine:match("EncounterID:(%d+)"))
    encounterName = firstLine:match("Name:([^;]+)")

    if not encounterID then
        private.Debug("Viserio format: No valid EncounterID found in first line")
        return reminders, encounterID, encounterName
    end

    -- Parse remaining lines as reminders
    for i = 2, #lines do
        local line = lines[i]
        if line and line ~= "" then
            -- Parse parameters separated by semicolons
            local params = {}
            for param in line:gmatch("([^;]+)") do
                local key, value = param:match("^%s*([%w]+)%s*:%s*(.+)%s*$")
                if key and value then
                    params[key] = value
                end
            end

            local time = tonumber(params.time)
            if time then
                local spellId = tonumber(params.spellid)
                local text = params.text
                local dur = tonumber(params.dur) or 0
                local tag = params.tag
                local phase = tonumber(params.ph) or 1

                local spellName, icon
                if spellId then
                    local spellInfo = C_Spell.GetSpellInfo(spellId)
                    if spellInfo then
                        spellName = spellInfo.name
                        icon = spellInfo.iconID
                    end
                end

                local name = "Unknown"
                if text and type(text) == "string" and text ~= "" then
                    name = text
                elseif spellId and spellId > 0 then
                    name = spellName or ("Spell " .. tostring(spellId))
                end

                local reminder = {
                    name = name,
                    spellId = spellId or 0,
                    spellName = spellName,
                    iconId = icon or 134400,
                    CombatTime = time,
                    CombatTimeDelay = dur,
                    StartTimerAfter = 0,
                    severity = 1,
                    effectTypes = 0,
                    -- Store all additional Viserio params even if we are not using them right now
                    tag = tag,
                    phase = phase,
                    text = text,
                    TTS = params.TTS,
                    countdown = tonumber(params.countdown),
                    sound = params.sound,
                    glowunit = params.glowunit,
                }

                table.insert(reminders, reminder)
            end
        end
    end

    return reminders, encounterID, encounterName
end

-- Parse JSON format
---@param jsonText string JSON text containing reminder data
---@return table array of parsed reminders
function ImportUtil:ParseJSONFormat(jsonText)
    local reminders = {}
    local encounterID = nil

    -- Extract encounterID from top-level JSON
    local encounterId = tonumber(jsonText:match('"encounterId"%s*:%s*(%d+)')) or
    tonumber(jsonText:match('encounterId%s*:%s*(%d+)'))
    if encounterId then
        encounterID = encounterId
    end

    local function findRemindersInJSON(text)
        local results = {}

        -- Look for array elements: {time:X,spellId:X,...} or {"time":X,"spellId":X,...}
        -- Pattern matches JSON objects with curly braces, handling nested structures
        local pattern = "{[^{}]*}"

        for match in text:gmatch(pattern) do
            local time = tonumber(match:match('"time"%s*:%s*(%d+)'))
            local spellId = tonumber(match:match('"spellId"%s*:%s*(%d+)'))
            local name = match:match('"name"%s*:%s*"([^"]*)"')
            local severity = tonumber(match:match('"severity"%s*:%s*(%d+)'))
            local duration = tonumber(match:match('"duration"%s*:%s*(%d+)'))
            local iconId = tonumber(match:match('"iconId"%s*:%s*(%d+)'))
            local effectTypes = tonumber(match:match('"effectTypes"%s*:%s*(%d+)'))

            if time and spellId ~= nil then
                local spellInfo = spellId > 0 and C_Spell.GetSpellInfo(spellId) or nil
                local spellName = spellInfo and spellInfo.name
                local icon = spellInfo and spellInfo.iconID

                local reminder = {
                    name = name or spellName or "Unknown",
                    spellId = spellId,
                    spellName = spellName,
                    iconId = iconId or icon or 134400,
                    CombatTime = time,
                    CombatTimeDelay = duration,
                    StartTimerAfter = 0,
                    severity = severity,
                    effectTypes = effectTypes,
                }

                table.insert(results, reminder)
            end
        end

        return results
    end

    return findRemindersInJSON(jsonText), encounterID
end

-- Auto-detect format and parse
---@param importText string Raw import text
---@return table parsed reminders
---@return string|nil error message if parsing failed
function ImportUtil:ParseImportText(importText)
    if not importText or importText == "" then
        return {}, "Empty import text"
    end

    -- Trim whitespace
    importText = importText:gsub("^%s+", ""):gsub("%s+$", "")

    -- Try encoded format first (base64 encoded string)
    if importText:match("^[A-Za-z0-9+/=!:]+$") and importText:sub(1, IMPORT_PREFIX:len()) == IMPORT_PREFIX and #importText > 50 then
        private.Debug("Detected encoded format")
        local reminders = self:ParseEncodedFormat(importText)
        if #reminders > 0 then
            return reminders
        end
    end

    -- Try Viserio format (starts with "EncounterID:")
    if importText:match("^EncounterID:%d+") then
        private.Debug("Detected Viserio format")
        local reminders, encounterID, encounterName = self:ParseViserioFormat(importText)
        if #reminders > 0 then
            -- Store encounter info for later use
            self.lastParsedEncounterID = encounterID
            self.lastParsedEncounterName = encounterName
            return reminders
        end
    end

    -- Try JSON format (starts with { and contains quoted keys or unquoted keys with colons)
    if importText:sub(1, 1) == "{" and (importText:match('"[%w_]+"%s*:') or importText:match('[%w_]+%s*:')) then
        private.Debug("Detected JSON format")
        local reminders, encounterID = self:ParseJSONFormat(importText)
        if #reminders > 0 then
            -- Store encounter ID if found in JSON
            if encounterID then
                self.lastParsedEncounterID = encounterID
            end
            return reminders
        end
    end

    -- Try MRT format (contains {time:} markers)
    if string.find(importText, "{time:") then
        private.Debug("Detected MRT format")
        local reminders = self:ParseMRTFormat(importText)
        if #reminders > 0 then
            return reminders
        end
    end

    return {}, private.getLocalisation("ImportParseError")
end

-- Check if a tag applies to the current player
---@param tag string Tag string (can contain multiple values separated by space)
---@return boolean True if tag applies to player
function ImportUtil:DoesTagApplyToPlayer(tag)
    if not tag or tag == "" or tag == "everyone" then
        return true
    end

    -- Get player info
    local playerName = UnitName("player")
    local playerClass, classFile = UnitClass("player")
    local playerSpecID, playerSpec, _, _, playerRole, _, _, _, _, _ = C_SpecializationInfo.GetSpecializationInfo(
    C_SpecializationInfo.GetSpecialization())
    local _, subgroup
    if UnitInRaid("player") then
        _, _, subgroup, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(UnitInRaid("player"))
    end
    local playerNickname = nil
    if CustomNames then
        playerNickname = CustomNames.Get("self")
    end

    -- Normalize role name to lowercase
    if playerRole == "TANK" then playerRole = "tank" end
    if playerRole == "HEALER" then playerRole = "healer" end
    if playerRole == "DAMAGER" then playerRole = "damager" end

    -- Split tag by spaces to allow multiple conditions
    for tagValue in tag:gmatch("[^%s]+") do
        tagValue = tagValue:gsub("^%s+", ""):gsub("%s+$", "") -- trim

        -- Check various tag types
        if tagValue == playerName then
            return true
        end

        if playerNickname and tagValue == playerNickname then
            return true
        end

        if tagValue == playerRole then
            return true
        end

        if tagValue:lower() == classFile:lower() then
            return true
        end

        if string.find(tagValue:lower(), "group") then
            local subGroupTag = tagValue:sub(6)
            if subGroupTag == subgroup then
                return true
            end
        end

        if tagValue == "melee" and private.SpecPosition.melee and tContains(private.SpecPosition.melee, playerSpecID) then
            return true
        end

        if tagValue == "ranged" and private.SpecPosition.ranged and tContains(private.SpecPosition.ranged, playerSpecID) then
            return true
        end

        if playerSpec and tagValue:lower() == playerSpec:lower() then
            return true
        end
    end

    return false
end

-- Filter reminders to only include ones relevant for the current player
---@param reminders table array of reminders
---@return table filtered reminders
function ImportUtil:FilterReminders(reminders)
    local filtered = {}

    for _, reminder in ipairs(reminders) do
        -- Get tag from reminder.tag field (where it's stored)
        local tag = reminder.tag or "everyone"

        -- Add reminder if it applies to the player
        if self:DoesTagApplyToPlayer(tag) then
            table.insert(filtered, reminder)
        end
    end

    return filtered
end

-- Parse encoded format (CBOR + compression + base64)
---@param encodedText string Encoded string
---@return table array of parsed reminders
function ImportUtil:ParseEncodedFormat(text)
    local reminders = {}

    local encodedText = text:sub(IMPORT_PREFIX:len() + 1)

    -- Decode from base64
    local success, compressed = pcall(C_EncodingUtil.DecodeBase64, encodedText)
    if not success then
        private.Debug("Failed to decode base64")
        return reminders
    end

    -- Decompress
    private.Debug(compressed)
    local success, serialized = pcall(C_EncodingUtil.DecompressString, compressed)
    if not success then
        private.Debug("Failed to decompress data")
        return reminders
    end

    -- Deserialize CBOR
    local success, data = pcall(C_EncodingUtil.DeserializeCBOR, serialized)
    if not success or type(data) ~= "table" then
        private.Debug("Failed to deserialize CBOR data")
        return reminders
    end

    self.lastParsedEncounterID = data.encounterID
    local reminderData = data.reminders or {}

    -- Convert to reminder format
    for _, item in ipairs(reminderData) do
        if type(item) == "table" and item.spellId and item.CombatTime then
            local spellInfo = C_Spell.GetSpellInfo(item.spellId)
            local spellName = spellInfo and spellInfo.name
            local icon = spellInfo and spellInfo.iconID

            local reminder = {
                name = item.name or spellName or "Unknown",
                spellId = item.spellId,
                spellName = spellName,
                iconId = item.iconId or icon or 134400,
                CombatTime = item.CombatTime,
                CombatTimeDelay = item.CombatTimeDelay or 0,
                StartTimerAfter = item.StartTimerAfter or 0,
                severity = item.severity or 1,
                effectTypes = item.effectTypes or 0,
                -- Save additional parameters if present
                tag = item.tag,
                phase = item.phase,
                text = item.text,
                TTS = item.TTS,
                countdown = item.countdown,
                sound = item.sound,
                glowunit = item.glowunit,
            }

            table.insert(reminders, reminder)
        end
    end

    return reminders
end

---@param reminders table array of reminder tables
---@return boolean valid
---@return string|nil validation message
function ImportUtil:ValidateReminders(reminders)
    if type(reminders) ~= "table" then
        return false, "Invalid reminders format"
    end

    if #reminders == 0 then
        return false, "No valid reminders found in import"
    end

    for i, reminder in ipairs(reminders) do
        if not reminder.CombatTime or type(reminder.CombatTime) ~= "number" then
            return false, string.format("Reminder %d: Invalid or missing combat time", i)
        end

        if reminder.CombatTime < 0 then
            return false, string.format("Reminder %d: Combat time cannot be negative", i)
        end

        if not reminder.spellId or type(reminder.spellId) ~= "number" then
            return false, string.format("Reminder %d: Invalid or missing spell ID", i)
        end
    end

    return true
end

-- Apply imported reminders to an encounter
---@param encounterID number encounter ID
---@param reminders table array of reminder tables
---@param mergeMode boolean if true, merge with existing; if false, replace
---@return boolean success
function ImportUtil:ApplyReminders(encounterID, reminders, mergeMode)
    if not private.db or not private.db.profile or not private.db.profile.reminders then
        return false
    end

    -- Validate before applying
    local valid, msg = self:ValidateReminders(reminders)
    if not valid then
        private.Debug("Validation failed: " .. tostring(msg))
        return false
    end

    if not mergeMode then
        -- Replace mode
        private.db.profile.reminders[encounterID] = {}
    else
        -- Merge mode
        if not private.db.profile.reminders[encounterID] then
            private.db.profile.reminders[encounterID] = {}
        end
    end

    for _, reminder in ipairs(reminders) do
        table.insert(private.db.profile.reminders[encounterID], reminder)
    end

    -- Sort reminders by time
    table.sort(private.db.profile.reminders[encounterID], function(a, b)
        return (a.CombatTime or 0) < (b.CombatTime or 0)
    end)

    return true
end

-- Format reminders for export
---@param reminders table array of reminder tables
---@param format string "encoded", "viserio", "json", or "mrt"
---@param encounterID number|nil Required for viserio format
---@param encounterName string|nil Optional for viserio format
---@return string formatted export text
function ImportUtil:ExportReminders(reminders, format, encounterID, encounterName)
    format = format or "encoded"

    if format == "encoded" then
        return self:ExportAsEncoded(reminders, encounterID)
    elseif format == "viserio" then
        if not encounterID then
            private.Debug("EncounterID required for Viserio export")
            return ""
        end
        return self:ExportAsViserio(reminders, encounterID, encounterName)
    elseif format == "json" then
        return self:ExportAsJSON(reminders, encounterID)
    elseif format == "mrt" then
        return self:ExportAsMRT(reminders)
    end

    return ""
end

-- Export as JSON
---@param reminders table
---@param encounterID number|nil
---@return string
function ImportUtil:ExportAsJSON(reminders, encounterID)
    local export = {}

    if encounterID then
        export.encounterId = encounterID
    end

    export.reminders = {}

    for _, reminder in ipairs(reminders) do
        table.insert(export.reminders, {
            time = reminder.CombatTime,
            spellId = reminder.spellId,
            name = reminder.name,
            duration = reminder.CombatTimeDelay,
            severity = reminder.severity,
            effectTypes = reminder.effectTypes,
        })
    end

    local function tableToJson(tbl, indent, isArray)
        indent = indent or 0
        local indentStr = string.rep("  ", indent)
        local nextIndentStr = string.rep("  ", indent + 1)

        -- Detect if this should be an array (check if all keys are numeric and sequential)
        local isArrayTable = false
        if not isArray then
            isArrayTable = true
            local maxKey = 0
            for k, v in pairs(tbl) do
                if type(k) ~= "number" then
                    isArrayTable = false
                    break
                end
                maxKey = math.max(maxKey, k)
            end
            if isArrayTable and maxKey > 0 then
                for i = 1, maxKey do
                    if tbl[i] == nil then
                        isArrayTable = false
                        break
                    end
                end
            end
        end

        if isArrayTable then
            -- Encode as JSON array
            local result = "[\n"
            for i, v in ipairs(tbl) do
                if i > 1 then result = result .. ",\n" end
                result = result .. nextIndentStr

                if type(v) == "table" then
                    result = result .. tableToJson(v, indent + 1, false)
                elseif type(v) == "string" then
                    result = result .. '"' .. v:gsub('"', '\\"') .. '"'
                elseif type(v) == "number" then
                    result = result .. tostring(v)
                elseif type(v) == "boolean" then
                    result = result .. (v and "true" or "false")
                else
                    result = result .. "null"
                end
            end
            result = result .. "\n" .. indentStr .. "]"
            return result
        else
            -- Encode as JSON object
            local result = "{\n"
            local first = true

            for k, v in pairs(tbl) do
                if not first then result = result .. ",\n" end
                first = false

                result = result .. nextIndentStr .. '"' .. k .. '"'
                result = result .. ": "

                if type(v) == "table" then
                    result = result .. tableToJson(v, indent + 1, false)
                elseif type(v) == "string" then
                    result = result .. '"' .. v:gsub('"', '\\"') .. '"'
                elseif type(v) == "number" then
                    result = result .. tostring(v)
                elseif type(v) == "boolean" then
                    result = result .. (v and "true" or "false")
                else
                    result = result .. "null"
                end
            end

            result = result .. "\n" .. indentStr .. "}"
            return result
        end
    end

    return tableToJson(export)
end

-- Export as MRT format
---@param reminders table
---@return string
function ImportUtil:ExportAsMRT(reminders)
    local result = ""

    for _, reminder in ipairs(reminders) do
        local minutes = math.floor(reminder.CombatTime / 60)
        local seconds = reminder.CombatTime % 60
        local timeStr = string.format("%d:%02d", minutes, seconds)

        result = result .. string.format("{time:%s} %s {spell:%d}\n", timeStr, reminder.name, reminder.spellId)
    end

    return result
end

-- Export as Viserio format
---@param reminders table
---@param encounterID number
---@param encounterName string|nil
---@return string
function ImportUtil:ExportAsViserio(reminders, encounterID, encounterName)
    local result = "EncounterID:" .. tostring(encounterID)

    if encounterName and encounterName ~= "" then
        result = result .. ";Name:" .. encounterName
    end

    result = result .. "\n"

    for _, reminder in ipairs(reminders) do
        local line = ""

        local phase = reminder.phase or 1
        line = line .. "ph:" .. tostring(phase) .. ";"

        line = line .. "time:" .. tostring(math.floor(reminder.CombatTime)) .. ";"

        if reminder.tag and reminder.tag ~= "" then
            line = line .. "tag:" .. reminder.tag .. ";"
        else
            line = line .. "tag:everyone;"
        end

        if reminder.spellId and reminder.spellId > 0 then
            line = line .. "spellid:" .. tostring(reminder.spellId) .. ";"
        end

        if reminder.text and reminder.text ~= "" then
            line = line .. "text:" .. reminder.text .. ";"
        elseif not reminder.text and reminder.name and reminder.name ~= "" and reminder.name ~= "Unknown" then
            line = line .. "text:" .. reminder.name .. ";"
        end

        if reminder.TTS then
            line = line .. "TTS:" .. tostring(reminder.TTS) .. ";"
        end

        if reminder.countdown then
            line = line .. "countdown:" .. tostring(reminder.countdown) .. ";"
        end

        if reminder.CombatTimeDelay and reminder.CombatTimeDelay > 0 then
            line = line .. "dur:" .. tostring(reminder.CombatTimeDelay) .. ";"
        end

        if reminder.sound then
            line = line .. "sound:" .. reminder.sound .. ";"
        end

        if reminder.glowunit then
            line = line .. "glowunit:" .. reminder.glowunit .. ";"
        end

        result = result .. line .. "\n"
    end

    return result
end

-- Export as encoded format (CBOR + compression + base64)
---@param reminders table
---@param encounterID number|nil
---@return string
function ImportUtil:ExportAsEncoded(reminders, encounterID)
    local data = {
        encounterID = encounterID,
        reminders = {}
    }

    for _, reminder in ipairs(reminders) do
        table.insert(data.reminders, {
            name = reminder.name,
            spellId = reminder.spellId,
            CombatTime = reminder.CombatTime,
            CombatTimeDelay = reminder.CombatTimeDelay,
            StartTimerAfter = reminder.StartTimerAfter,
            severity = reminder.severity,
            effectTypes = reminder.effectTypes,
            -- Include additional Viserio/MRT parameters
            tag = reminder.tag,
            phase = reminder.phase,
            text = reminder.text,
            TTS = reminder.TTS,
            countdown = reminder.countdown,
            sound = reminder.sound,
            glowunit = reminder.glowunit,
        })
    end

    local serialized = C_EncodingUtil.SerializeCBOR(data)
    if not serialized then
        private.Debug("Failed to serialize data")
        return ""
    end

    local compressed = C_EncodingUtil.CompressString(serialized)
    if not compressed then
        private.Debug("Failed to compress data")
        return ""
    end

    local encoded = C_EncodingUtil.EncodeBase64(compressed)
    return encoded and IMPORT_PREFIX .. encoded or ""
end
