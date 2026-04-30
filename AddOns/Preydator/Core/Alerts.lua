---@diagnostic disable: undefined-field, inject-field

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable

local Alerts = {}
Preydator:RegisterModule("Alerts", Alerts)

local BLOODY_COMMAND_CHAT_PHRASE = "kill for me. now!"
local BLOODY_COMMAND_CHAT_PHRASE_2 = "drain their anguish!"
local BLOODY_COMMAND_CHAT_SOURCE = "astalor bloodsworn"
local AMBUSH_CHAT_FALLBACK_PHRASES = {
    "ambush",
    "you've stumbled right into my trap",
    "a momentary setback",
}

local function IsAmbushRuntimeEnabled(api)
    local runtime = type(api.GetModuleRuntimeState) == "function" and api.GetModuleRuntimeState() or nil
    if type(runtime) ~= "table" then
        return true
    end

    local settings = runtime.settings
    local barEnabled = runtime.barEnabled == true
    local soundsRuntimeEnabled = runtime.soundsRuntimeEnabled == true
    local visualEnabled = barEnabled and (not settings or settings.ambushVisualEnabled ~= false)
    local soundEnabled = soundsRuntimeEnabled and (not settings or settings.ambushSoundEnabled ~= false)
    return visualEnabled or soundEnabled
end

local function IsBloodyRuntimeEnabled(api)
    local runtime = type(api.GetModuleRuntimeState) == "function" and api.GetModuleRuntimeState() or nil
    if type(runtime) ~= "table" then
        return true
    end

    local settings = runtime.settings
    local barEnabled = runtime.barEnabled == true
    local soundsRuntimeEnabled = runtime.soundsRuntimeEnabled == true
    local visualEnabled = barEnabled and (not settings or settings.bloodyCommandVisualEnabled ~= false)
    local soundEnabled = soundsRuntimeEnabled and (not settings or settings.bloodyCommandSoundEnabled ~= false)
    return visualEnabled or soundEnabled
end

local function StringContainsInsensitiveSafe(haystack, needle)
    if type(haystack) ~= "string" or type(needle) ~= "string" or needle == "" then
        return false
    end

    local ok, found = pcall(function()
        local haystackLower = string.lower(haystack)
        local needleLower = string.lower(needle)
        return string.find(haystackLower, needleLower, 1, true) ~= nil
    end)

    return ok and found or false
end

local function IsAmbushPreyNameTokenMatch(preyName, message, sender)
    if type(preyName) ~= "string" or preyName == "" then
        return false
    end

    local lowerName = string.lower(preyName)
    for token in string.gmatch(lowerName, "[%a%d]+") do
        if string.len(token) >= 4 then
            if StringContainsInsensitiveSafe(message, token) or StringContainsInsensitiveSafe(sender, token) then
                return true
            end
        end
    end

    return false
end

local function ResolveAlertContext(api)
    if type(api.GetBarRuntimeContext) ~= "function" then
        return nil
    end

    local ctx = api.GetBarRuntimeContext()
    if type(ctx) ~= "table" or type(ctx.state) ~= "table" then
        return nil
    end

    return ctx
end

local function AddAlertsDebugLog(api, message)
    if type(api.AddDebugLog) == "function" then
        api.AddDebugLog("BloodyCommand", tostring(message), true)
    end
end

local function AddAmbushLog(api, message, forcePrint)
    if type(api.AddDebugLog) == "function" then
        api.AddDebugLog("Ambush", tostring(message), forcePrint == true)
    end
end

local function IsBloodyVerboseDebugEnabled(api)
    if type(api.GetSettings) ~= "function" then
        return false
    end

    local settings = api.GetSettings()
    return type(settings) == "table" and settings.debugBloodyCommand == true
end

local function AddBloodyCommandLog(api, message, verboseOnly)
    if verboseOnly and not IsBloodyVerboseDebugEnabled(api) then
        return
    end

    AddAlertsDebugLog(api, message)
end

local function IsAmbushSystemMessage(ctx, message, sender)
    if type(message) ~= "string" then
        return false
    end

    local preyName = ctx.state and ctx.state.preyTargetName
    if type(preyName) == "string" and preyName ~= "" then
        if StringContainsInsensitiveSafe(message, preyName) or StringContainsInsensitiveSafe(sender, preyName) then
            return true
        end

        if IsAmbushPreyNameTokenMatch(preyName, message, sender) then
            return true
        end
    end

    return false
end

local function IsAmbushFallbackMessage(message)
    if type(message) ~= "string" then
        return false
    end

    local loweredMessage = string.lower(message)
    for _, phrase in ipairs(AMBUSH_CHAT_FALLBACK_PHRASES) do
        if string.find(loweredMessage, phrase, 1, true) then
            return true
        end
    end

    return false
end

local function ShouldScanAmbushChat(ctx)
    local state = ctx.state
    if type(state) ~= "table"
        or type(ctx.getCurrentActivePreyQuestCached) ~= "function"
        or type(ctx.isValidQuestID) ~= "function"
        or type(ctx.refreshInPreyZoneStatus) ~= "function"
        or type(ctx.isRestrictedInstanceForPreyBar) ~= "function"
    then
        return false
    end

    local liveQuestID = ctx.getCurrentActivePreyQuestCached(0)
    if not ctx.isValidQuestID(liveQuestID) then
        return false
    end

    if state.activeQuestID ~= liveQuestID then
        state.zoneCacheDirty = true
        if ctx.isValidQuestID(state.activeQuestID) then
            return false
        end
    end

    if tonumber(state.stage) == tonumber(ctx.maxStage) then
        return false
    end

    if state.zoneCacheDirty == true or state.inPreyZone == nil then
        ctx.refreshInPreyZoneStatus(liveQuestID, true)
    end

    -- inPreyZone == nil means the zone APIs haven't resolved yet (common just after
    -- /reload before the widget cycle delivers data). A player receiving an NPC
    -- ambush chat message is physically standing near that NPC, so nil (unknown)
    -- should not block the scan. Only block when the zone is explicitly false.
    if state.inPreyZone == false then
        return false
    end

    return not ctx.isRestrictedInstanceForPreyBar()
end

local function HandleAmbushChat(api, event, message, sender)
    if not IsAmbushRuntimeEnabled(api) then
        return
    end

    local ctx = ResolveAlertContext(api)
    if not ctx then
        return
    end

    if not ShouldScanAmbushChat(ctx) then
        return
    end

    local matchedByPreyName = IsAmbushSystemMessage(ctx, message, sender)
    local matchedByFallbackPhrase = IsAmbushFallbackMessage(message)
    if not matchedByPreyName and not matchedByFallbackPhrase then
        AddAmbushLog(api,
            "chat ignored: no ambush match"
                .. " | event=" .. tostring(event)
                .. " | sender=" .. tostring(sender)
                .. " | message=" .. tostring(message),
            false
        )
        return
    end

    AddAmbushLog(api,
        "chat matched"
            .. " | event=" .. tostring(event)
            .. " | sender=" .. tostring(sender)
            .. " | matchedByPreyName=" .. tostring(matchedByPreyName)
            .. " | matchedByFallbackPhrase=" .. tostring(matchedByFallbackPhrase),
        true
    )

    if type(api.TriggerAmbushAlert) == "function" then
        api.TriggerAmbushAlert(message, event, sender)
    end
end

local function IsBloodyCommandStageAndDifficultyMatch(ctx)
    local state = ctx and ctx.state
    if type(state) ~= "table" then
        return false
    end

    local stage = tonumber(state.stage) or 0
    if stage < 1 or stage > 3 then
        return false
    end

    local difficulty = state.preyTargetDifficulty
    if type(difficulty) ~= "string" or difficulty == "" then
        return false
    end

    local loweredDifficulty = string.lower(difficulty)
    return string.find(loweredDifficulty, "nightmare", 1, true) ~= nil
end

local function IsBloodyCommandChatMessage(message, sender)
    if type(message) ~= "string" then
        return false
    end

    local loweredMessage = string.lower(message)
    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE, 1, true) then
        return true
    end

    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE_2, 1, true) then
        return true
    end

    -- Some chat payloads include the full speaker prefix in arg1.
    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_SOURCE .. " says: " .. BLOODY_COMMAND_CHAT_PHRASE, 1, true) then
        return true
    end

    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_SOURCE .. " says: " .. BLOODY_COMMAND_CHAT_PHRASE_2, 1, true) then
        return true
    end

    if type(sender) == "string" and sender ~= "" then
        local loweredSender = string.lower(sender)
        if string.find(loweredSender, BLOODY_COMMAND_CHAT_SOURCE, 1, true) then
            if string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE, 1, true)
                or string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE_2, 1, true) then
                return true
            end
        end
    end

    return false
end

local function HandleBloodyCommandChat(api, event, message, sender)
    if not IsBloodyCommandChatMessage(message, sender) then
        return
    end

    local ctx = ResolveAlertContext(api)
    local stageAndDifficultyMatch = IsBloodyCommandStageAndDifficultyMatch(ctx)
    local runtimeEnabled = IsBloodyRuntimeEnabled(api)
    local inRestrictedInstance = ctx
        and type(ctx.isRestrictedInstanceForPreyBar) == "function"
        and ctx.isRestrictedInstanceForPreyBar() == true

    AddBloodyCommandLog(api,
        "chat matched"
            .. " | event=" .. tostring(event)
            .. " | sender=" .. tostring(sender)
            .. " | stage=" .. tostring(ctx and ctx.state and ctx.state.stage)
            .. " | difficulty=" .. tostring(ctx and ctx.state and ctx.state.preyTargetDifficulty),
        false
    )

    AddBloodyCommandLog(api,
        "chat gate details"
            .. " | message=" .. tostring(message)
            .. " | runtimeEnabled=" .. tostring(runtimeEnabled)
            .. " | restricted=" .. tostring(inRestrictedInstance)
            .. " | stageAndDifficultyMatch=" .. tostring(stageAndDifficultyMatch),
        true
    )

    if inRestrictedInstance then
        AddBloodyCommandLog(api, "chat ignored: restricted instance", true)
        return
    end

    if not runtimeEnabled then
        AddBloodyCommandLog(api, "chat ignored: runtime disabled", true)
        return
    end

    if not stageAndDifficultyMatch then
        AddBloodyCommandLog(api, "chat ignored: stage/difficulty gate failed", true)
        return
    end

    if type(api.TriggerBloodyCommandAlert) == "function" then
        api.TriggerBloodyCommandAlert(nil, sender, event)
    end
end

function Alerts:OnEvent(event, arg1, arg2)
    local api = Preydator.API
    if type(api) ~= "table" then
        return
    end

    if event == "CHAT_MSG_SYSTEM"
        or event == "CHAT_MSG_MONSTER_SAY"
        or event == "CHAT_MSG_MONSTER_YELL"
        or event == "CHAT_MSG_MONSTER_EMOTE"
        or event == "RAID_BOSS_EMOTE"
    then
        HandleAmbushChat(api, event, arg1, arg2)
        HandleBloodyCommandChat(api, event, arg1, arg2)
        return
    end

end
