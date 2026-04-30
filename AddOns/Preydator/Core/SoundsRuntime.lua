local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local SoundsRuntime = {}
Preydator:RegisterModule("SoundsRuntime", SoundsRuntime)

function SoundsRuntime:BuildAddonSoundPath(fileName, ctx)
    if type(fileName) ~= "string" then
        return nil
    end

    local trimmed = fileName:match("^%s*(.-)%s*$")
    if type(trimmed) ~= "string" or trimmed == "" then
        return nil
    end

    if string.find(trimmed, "\\", 1, true) then
        return trimmed
    end

    local soundFolderPrefix = (ctx and ctx.soundFolderPrefix) or ""
    return soundFolderPrefix .. trimmed
end

function SoundsRuntime:ExtractAddonSoundFileName(path, ctx)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    local soundFolderPrefix = (ctx and ctx.soundFolderPrefix) or ""
    local lower = string.lower(path)
    local prefixLower = string.lower(soundFolderPrefix)
    if string.sub(lower, 1, #prefixLower) ~= prefixLower then
        return nil
    end

    local fileName = string.sub(path, #soundFolderPrefix + 1)
    if fileName == "" then
        return nil
    end

    return fileName
end

function SoundsRuntime:NormalizeSoundFileName(fileName, ctx)
    if type(fileName) ~= "string" then
        return nil
    end

    local normalized = string.lower(fileName:match("^%s*(.-)%s*$") or "")
    if normalized == "" then
        return nil
    end

    local soundFolderPrefix = (ctx and ctx.soundFolderPrefix) or ""
    local prefixLower = string.lower(soundFolderPrefix)
    if string.sub(normalized, 1, #prefixLower) == prefixLower then
        normalized = string.sub(normalized, #prefixLower + 1)
    end

    if normalized == "" then
        return nil
    end

    if normalized:find("[/\\]") then
        return nil
    end

    if not normalized:match("%.ogg$") then
        normalized = normalized .. ".ogg"
    end

    return normalized
end

function SoundsRuntime:BuildSoundDisplayName(fileName)
    local short = tostring(fileName or "")
    short = short:gsub("%.ogg$", "")
    short = short:gsub("[_%-]+", " ")
    short = short:gsub("%s+", " ")
    short = short:gsub("^%l", string.upper)
    short = short:gsub("%s%l", function(s)
        return string.upper(s)
    end)
    return short
end

function SoundsRuntime:GetSoundPathForKey(soundKey, fallbackPath, ctx)
    local keys = (ctx and ctx.soundKeys) or {}
    local paths = (ctx and ctx.soundPaths) or {}

    if soundKey == keys.alert then
        return paths.alert
    end
    if soundKey == keys.ambush then
        return paths.ambush
    end
    if soundKey == keys.torment then
        return paths.torment
    end
    if soundKey == keys.kill then
        return paths.kill
    end

    return fallbackPath
end

function SoundsRuntime:AddSoundFileName(fileName, settings, ctx)
    local normalized = self:NormalizeSoundFileName(fileName, ctx)
    if not normalized then
        return false, "Use a valid sound filename (optionally with .ogg)"
    end

    if type(settings) ~= "table" then
        return false, "Sound settings are unavailable"
    end

    settings.soundFileNames = settings.soundFileNames or {}
    for _, existing in ipairs(settings.soundFileNames) do
        if self:NormalizeSoundFileName(existing, ctx) == normalized then
            return false, "File is already in the list"
        end
    end

    table.insert(settings.soundFileNames, normalized)

    if ctx and type(ctx.normalizeSoundSettings) == "function" then
        ctx.normalizeSoundSettings()
    end

    return true, normalized
end

function SoundsRuntime:RemoveSoundFileName(fileName, settings, ctx)
    local normalized = self:NormalizeSoundFileName(fileName, ctx)
    if not normalized then
        return false, "Use a valid sound filename (optionally with .ogg)"
    end

    local protected = (ctx and ctx.protectedSoundFileNames) or {}
    if protected[normalized] then
        return false, "Default sound files cannot be removed"
    end

    if type(settings) ~= "table" then
        return false, "Sound settings are unavailable"
    end

    settings.soundFileNames = settings.soundFileNames or {}
    local removed = false
    for index = #settings.soundFileNames, 1, -1 do
        local existing = self:NormalizeSoundFileName(settings.soundFileNames[index], ctx)
        if existing == normalized then
            table.remove(settings.soundFileNames, index)
            removed = true
            break
        end
    end

    if not removed then
        local rawInput = string.lower((tostring(fileName or ""):match("^%s*(.-)%s*$") or ""))
        local candidates = {}

        if rawInput ~= "" then
            for index = #settings.soundFileNames, 1, -1 do
                local existing = self:NormalizeSoundFileName(settings.soundFileNames[index], ctx)
                if existing then
                    local existingNoExt = existing:gsub("%.ogg$", "")
                    if rawInput == existing
                        or rawInput == existingNoExt
                        or string.sub(existingNoExt, -#rawInput) == rawInput
                    then
                        table.insert(candidates, { index = index, name = existing })
                    end
                end
            end
        end

        if #candidates == 1 then
            table.remove(settings.soundFileNames, candidates[1].index)
            removed = true
            normalized = candidates[1].name
        elseif #candidates > 1 then
            return false, "Multiple matches found. Type more of the file name."
        end
    end

    if not removed then
        return false, "File is not in the custom list"
    end

    if ctx and type(ctx.normalizeSoundSettings) == "function" then
        ctx.normalizeSoundSettings()
    end

    return true, normalized
end

function SoundsRuntime:BuildSoundDropdownOptions(settings, ctx)
    local options = {}
    local defaults = (ctx and ctx.defaultSoundFileNames) or {}
    local files = (settings and settings.soundFileNames) or defaults
    local noneLabel = (ctx and ctx.noneLabel) or "None"
    local additionalEntries = (ctx and ctx.additionalSoundEntries) or {}
    local defaultSet = {}
    local seenKeys = {
        ["__NONE__"] = true,
    }

    local function NormalizePathKey(value)
        if type(value) ~= "string" or value == "" then
            return nil
        end
        return string.lower(value)
    end

    local function PushOption(key, text)
        if key == nil then
            return
        end

        local normalizedKey = NormalizePathKey(key)
        if normalizedKey and seenKeys[normalizedKey] then
            return
        end

        if normalizedKey then
            seenKeys[normalizedKey] = true
        end

        options[#options + 1] = {
            key = key,
            text = text,
        }
    end

    for _, defaultName in ipairs(defaults) do
        local normalizedDefault = self:NormalizeSoundFileName(defaultName, ctx)
        if normalizedDefault then
            defaultSet[normalizedDefault] = true
        end
    end

    PushOption("__NONE__", noneLabel)

    local customOptions = {}
    local defaultOptions = {}

    for _, fileName in ipairs(files) do
        local normalized = self:NormalizeSoundFileName(fileName, ctx)

        if normalized then
            local path = self:BuildAddonSoundPath(normalized, ctx)

            if type(path) == "string" and path ~= "" then
                local target = defaultSet[normalized] and defaultOptions or customOptions
                target[#target + 1] = {
                    key = path,
                    text = self:BuildSoundDisplayName(normalized),
                }
            end
        end
    end

    table.sort(customOptions, function(left, right)
        return tostring(left and left.text or "") < tostring(right and right.text or "")
    end)

    for _, entry in ipairs(customOptions) do
        PushOption(entry.key, entry.text)
    end

    for _, defaultName in ipairs(defaults) do
        local normalized = self:NormalizeSoundFileName(defaultName, ctx)
        if normalized then
            local path = self:BuildAddonSoundPath(normalized, ctx)
            if type(path) == "string" and path ~= "" then
                PushOption(path, self:BuildSoundDisplayName(normalized))
            end
        end
    end

    local sortedAdditional = {}
    for _, entry in ipairs(additionalEntries) do
        if type(entry) == "table" and type(entry.key) == "string" and entry.key ~= "" and type(entry.text) == "string" and entry.text ~= "" then
            sortedAdditional[#sortedAdditional + 1] = {
                key = entry.key,
                text = entry.text,
            }
        end
    end

    table.sort(sortedAdditional, function(left, right)
        local leftText = string.lower(tostring(left and left.text or ""))
        local rightText = string.lower(tostring(right and right.text or ""))
        if leftText == rightText then
            return tostring(left and left.key or "") < tostring(right and right.key or "")
        end
        return leftText < rightText
    end)

    for _, entry in ipairs(sortedAdditional) do
        PushOption(entry.key, entry.text)
    end

    return options
end

function SoundsRuntime:ResolveAmbushAlertSoundPath(settings, ctx)
    local path = settings and settings.ambushSoundPath
    if path == "__NONE__" then
        return nil
    end
    if type(path) == "string" and path ~= "" then
        return path
    end

    return (ctx and ctx.killSoundPath) or ""
end

function SoundsRuntime:ResolveBloodyCommandAlertSoundPath(settings, ctx)
    local path = settings and settings.bloodyCommandSoundPath
    if path == "__NONE__" then
        return nil
    end
    if type(path) == "string" and path ~= "" then
        return path
    end

    return (ctx and ctx.killSoundPath) or ""
end

function SoundsRuntime:TryPlaySound(path, ignoreSoundToggle, settings, ctx)
    local addDebugLog = ctx and ctx.addDebugLog
    local function Log(message)
        if type(addDebugLog) == "function" then
            addDebugLog("TryPlaySound", message, false)
        end
    end

    if ctx and type(ctx.isSoundsModuleEnabled) == "function" and ctx.isSoundsModuleEnabled() ~= true then
        Log("blocked by sounds module disabled | path=" .. tostring(path))
        return false
    end

    if not ignoreSoundToggle and settings and settings.soundsEnabled == false then
        Log("blocked by soundsEnabled=false | path=" .. tostring(path))
        return false
    end

    local playSoundFile = ctx and ctx.playSoundFile
    if type(playSoundFile) ~= "function" then
        Log("missing playSoundFile function | path=" .. tostring(path))
        return false
    end

    local requestedChannel = (settings and settings.soundChannel) or "SFX"
    local channel = requestedChannel
    if type(channel) ~= "string" or channel == "" then
        channel = "SFX"
    end

    local lowerChannel = string.lower(channel)
    if lowerChannel == "master" then
        channel = "Master"
    elseif lowerChannel == "sfx" then
        channel = "SFX"
    elseif lowerChannel == "dialog" then
        channel = "Dialog"
    elseif lowerChannel == "ambience" then
        channel = "Ambience"
    elseif lowerChannel == "music" then
        channel = "Music"
    end

    local validChannels = {
        Master = true,
        SFX = true,
        Dialog = true,
        Ambience = true,
        Music = true,
    }

    local channelsToTry = {}
    local seenChannels = {}
    local function pushChannel(candidate)
        if type(candidate) ~= "string" or candidate == "" or seenChannels[candidate] then
            return
        end
        seenChannels[candidate] = true
        channelsToTry[#channelsToTry + 1] = candidate
    end

    if validChannels[channel] then
        pushChannel(channel)
    else
        -- Self-heal corrupted/legacy values by trying canonical channels.
        pushChannel("SFX")
        pushChannel("Master")
    end

    local willPlay = false
    local usedChannel = nil
    for _, tryChannel in ipairs(channelsToTry) do
        local result = playSoundFile(path, tryChannel)
        Log("path=" .. tostring(path) .. " | channel=" .. tostring(tryChannel) .. " | ignoreToggle=" .. tostring(ignoreSoundToggle) .. " | result=" .. tostring(result))
        if result then
            willPlay = true
            usedChannel = tryChannel
            break
        end
    end

    if willPlay and usedChannel and settings and settings.soundChannel ~= usedChannel then
        settings.soundChannel = usedChannel
    end

    if willPlay then
        local enhance = (settings and tonumber(settings.soundEnhance)) or 0
        local timerAfter = ctx and ctx.timerAfter
        if enhance > 0 and type(timerAfter) == "function" then
            local extraPlays = math.min(4, math.max(0, math.floor(enhance / 25)))
            for i = 1, extraPlays do
                local delay = i * 0.03
                timerAfter(delay, function()
                    playSoundFile(path, usedChannel or channel)
                end)
            end
            if extraPlays > 0 then
                Log("enhance=" .. tostring(enhance) .. " | extraPlays=" .. tostring(extraPlays))
            end
        end
        return true
    end

    local warnedMissingSoundPaths = ctx and ctx.warnedMissingSoundPaths
    local warnedKey = tostring(path or "")
    if type(warnedMissingSoundPaths) == "table" and warnedMissingSoundPaths[warnedKey] ~= true then
        warnedMissingSoundPaths[warnedKey] = true
        local printFn = (ctx and ctx.printFn) or print
        if type(printFn) == "function" then
            printFn("Preydator: Sound failed to play: '" .. warnedKey .. "'. Ensure the .ogg exists in Interface\\AddOns\\Preydator\\sounds\\ and is listed in Custom Sound Files.")
        end
    end

    return false
end

function SoundsRuntime:ResolveStageSoundPath(stage, settings, ctx)
    local addDebugLog = ctx and ctx.addDebugLog
    local function Log(message, forcePrint)
        if type(addDebugLog) == "function" then
            addDebugLog("ResolveStageSoundPath", message, forcePrint == true)
        end
    end

    stage = tonumber(stage)
    if not stage then
        Log("invalid stage", false)
        return nil
    end

    local getDefaultStageSoundPath = ctx and ctx.getDefaultStageSoundPath
    local defaultPath = nil
    if type(getDefaultStageSoundPath) == "function" then
        defaultPath = getDefaultStageSoundPath(stage)
    end

    if not settings then
        return defaultPath
    end

    settings.stageSounds = settings.stageSounds or {}
    local sounds = settings.stageSounds

    local savedPath = sounds[stage]
    if savedPath == "__NONE__" then
        Log("stage=" .. stage .. " | source=saved | path=none", false)
        return nil
    end
    if type(savedPath) == "string" and savedPath ~= "" then
        Log("stage=" .. stage .. " | source=saved | path=" .. savedPath, false)
        return savedPath
    end

    if type(defaultPath) == "string" and defaultPath ~= "" then
        sounds[stage] = defaultPath
        Log("stage=" .. stage .. " | source=default | path=" .. defaultPath, false)
        return defaultPath
    end

    Log("stage=" .. stage .. " | source=none | default=nil", true)

    return nil
end