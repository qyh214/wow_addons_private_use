---@diagnostic disable

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable
local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })
local addon = addonTable

local HuntScannerModule = {}
Preydator:RegisterModule("HuntScanner", HuntScannerModule)

local HookSecureFunc = _G.hooksecurefunc
local C_TaskQuest = _G.C_TaskQuest

local HUNT_TABLE_NPC_IDS = {
    [245824] = true,
    [246231] = true,
}
local HUNT_TABLE_CONTROLLER_SPELL_ID = 1271464
local ADVENTURE_PIN_POOL_TEMPLATE = "AdventureMap_QuestOfferPinTemplate"
local REWARD_STABLE_POLLS = 3
local REWARD_POLL_INTERVAL = 0.10
local REWARD_TIMEOUT_SECONDS = 4.0
local REWARD_MAX_EMPTY_RETRIES = 2
local REWARD_MIN_STABLE_SECONDS = 0.50
-- Reward warming must only run in live Hunt Table context (open mission frame/map tab).
-- CanInspectHuntRewardsNow() enforces that gate before any reward inspection work starts.
local HUNT_REWARD_WARMING_ENABLED = true

local panelFrame
local panelRows = {}
local lastSnapshot
local recentEvents = {}
local isHandlingSnapshot = false
local lastRichSnapshot
local snapshotSequence = 0
local lastInteractionType = nil
local missionHooksApplied = false
local liveHunts = {}
local huntByQuestID = {}
local rewardCache = {}
local difficultyRewardCache = {}
local rewardRetryCount = {}
local rewardWarmCancel = nil
local lastDebugPayload = nil
local lastOpenQuestID = nil
local lastOpenAt = 0
local lastObservedPreyQuestID = nil
local lastObservedPreyStage = nil
local lastAvailabilityNotifyKey = nil
local panelRowHeight = 52
local panelScrollViewport
local panelScrollContent
local panelScrollBar
local DIFFICULTY_NORMAL = "normal"
local DIFFICULTY_HARD = "hard"
local DIFFICULTY_NIGHTMARE = "nightmare"
local DEFAULT_DIFFICULTY_COLORS = {
    [DIFFICULTY_NORMAL] = { 0.42, 1.00, 0.56, 1.00 },
    [DIFFICULTY_HARD] = { 1.00, 0.67, 0.24, 1.00 },
    [DIFFICULTY_NIGHTMARE] = { 1.00, 0.35, 0.35, 1.00 },
}
local DEFAULT_ACHIEVEMENT_BADGE_COLOR = { 1.00, 0.86, 0.00, 1.00 }
local ACHIEVEMENT_CRITERIA_TYPE_QUEST = 27
local ACHIEVEMENT_BADGE_ICON = "Interface\\AchievementFrame\\UI-Achievement-TinyShield"
local ACHIEVEMENT_CACHE_MIN_REBUILD_SECONDS = 2.0
local TRACKED_PREY_ACHIEVEMENT_IDS = {
    42701, 42702, 42703,
    61386, 61387, 61388, 61389, 61391, 61392,
    62134, 62135, 62136, 62137, 62138, 62139, 62140, 62141, 62142, 62143, 62144,
    62153, 62154, 62155, 62156, 62157, 62158, 62159, 62160, 62161, 62162,
    62163, 62164, 62165, 62166, 62167, 62168, 62169,
    62173, 62174, 62175, 62176, 62177, 62178, 62179, 62180, 62181, 62182, 62183, 62184,
    62351, 62383, 62403,
}
local availabilityCache = {
    normal = 0,
    hard = 0,
    nightmare = 0,
    capturedAt = 0,
}
local availabilityTouched = false
local huntInteractionActive = false
local questZoneCache = {}
local questZoneNameCache = {}
local questCoords = {}
local cachedAdventureMapID = nil
local INFERRED_HUNT_ZONE_MAP_IDS = {
    ["Harandar"] = 2413,
    ["Voidstorm"] = 2405,
    ["Eversong Woods"] = 2395,
    ["Zul'Aman"] = 2437,
}
local queueDebounceUntil = 0
local SNAPSHOT_QUEUE_DEBOUNCE_SECONDS = 0.15
local achievementNeedsByQuestID = {}
local achievementNeedsByNameKey = {}
local completedAchievementCache = {}
local achievementCacheDirty = true
local lastAchievementCacheBuildAt = 0
local achievementRouteStats = {
    idHits = 0,
    fallbackHits = 0,
    misses = 0,
}
local PANEL_ROW_POOL_SIZE = 20

local HandleInteractionSnapshot
local QueueInteractionSnapshotPasses
local HidePanel
local GetSettings
local IsInRestrictedInstance
local huntEventFrame
local noisyEventsRegistered = false
local IsMissionFrameVisible
local IsOptionsPreviewVisible
local HasActivePreyQuest
local IsHuntRuntimeEnabled
local LoadCompletedAchievementCache
local MarkAchievementCompleted
local IsAchievementCompletedCached
local AddAchievementNameMatch
local NormalizeDifficultyKey
local NormalizeAchievementMatchText
local BuildAchievementMatchKey
local BuildAchievementCompactMatchKey
local AddAchievementNeed
local RewardListHasIconTags

local function SetNoisyEventSubscriptions(enabled)
    if not huntEventFrame then
        return
    end

    local shouldEnable = enabled == true
    if shouldEnable == noisyEventsRegistered then
        return
    end

    noisyEventsRegistered = shouldEnable
    if shouldEnable then
        huntEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
        huntEventFrame:RegisterEvent("UPDATE_UI_WIDGET")
        huntEventFrame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    else
        huntEventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
        huntEventFrame:UnregisterEvent("UPDATE_UI_WIDGET")
        huntEventFrame:UnregisterEvent("UPDATE_ALL_UI_WIDGETS")
    end
end

local function SyncNoisyEventSubscriptions()
    if not IsHuntRuntimeEnabled() then
        SetNoisyEventSubscriptions(false)
        return
    end

    if IsInRestrictedInstance() and not IsOptionsPreviewVisible() then
        SetNoisyEventSubscriptions(false)
        return
    end

    local enabled = IsMissionFrameVisible()
        or huntInteractionActive
        or IsOptionsPreviewVisible()
    SetNoisyEventSubscriptions(enabled)
end

local function SafeToString(value)
    local ok, result = pcall(tostring, value)
    if ok and type(result) == "string" then
        return result
    end

    if type(value) == "string" then
        return "<protected string>"
    end

    return "<unprintable>"
end

local function SafeToNumber(value)
    if type(value) == "number" then
        local okString, asString = pcall(tostring, value)
        if okString and type(asString) == "string" then
            local numericToken = string.match(asString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
                or string.match(asString, "^%s*([%+%-]?%d*%.%d+)%s*$")
            if numericToken then
                local okNumber, result = pcall(tonumber, numericToken)
                if okNumber and type(result) == "number" then
                    return result
                end
            end
        end
        return nil
    end

    local ok, result = pcall(tonumber, value)
    if ok and type(result) == "number" then
        return result
    end

    return nil
end

local function SafeTableField(tbl, key)
    if type(tbl) ~= "table" then
        return nil
    end

    local ok, value = pcall(function()
        return tbl[key]
    end)
    if ok then
        return value
    end

    return nil
end

local function SafeTableMethodValue(tbl, methodName)
    local method = SafeTableField(tbl, methodName)
    if type(method) ~= "function" then
        return nil
    end

    local ok, value = pcall(method, tbl)
    if ok then
        return value
    end

    return nil
end

local function SafeFindLiteral(text, needle)
    if type(text) ~= "string" or text == "" or type(needle) ~= "string" or needle == "" then
        return false
    end

    local ok, startPos = pcall(string.find, text, needle, 1, true)
    return ok and startPos ~= nil
end

local function GetGossipOptionsSafe()
    if not (C_GossipInfo and type(C_GossipInfo.GetOptions) == "function") then
        return {}
    end

    local ok, options = pcall(C_GossipInfo.GetOptions)
    if ok and type(options) == "table" then
        return options
    end

    return {}
end

IsInRestrictedInstance = function()
    if type(IsInInstance) ~= "function" then
        -- Continue with fallback checks below.
    else
        local ok, inInstance, instanceType = pcall(IsInInstance)
        if ok and inInstance then
            return instanceType == "pvp"
                or instanceType == "arena"
                or instanceType == "party"
                or instanceType == "raid"
                or instanceType == "scenario"
                or instanceType == "delve"
        end
    end

    -- Some campaign scenarios can briefly report odd instance-type values.
    -- Treat explicit scenario APIs as authoritative when available.
    if type(IsInScenario) == "function" then
        local okScenario, inScenario = pcall(IsInScenario)
        if okScenario and inScenario == true then
            return true
        end
    end

    if C_ScenarioInfo and type(C_ScenarioInfo.GetScenarioInfo) == "function" then
        local okInfo, scenarioInfo = pcall(C_ScenarioInfo.GetScenarioInfo)
        if okInfo and type(scenarioInfo) == "table" then
            local stage = SafeToNumber(scenarioInfo.currentStage)
            local stages = SafeToNumber(scenarioInfo.numStages)
            local hasScenarioName = type(scenarioInfo.name) == "string" and scenarioInfo.name ~= ""
            if hasScenarioName and (stage ~= nil or stages ~= nil) then
                return true
            end
        end
    end

    -- Fallback for short transition windows where IsInInstance lags behind map state.
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local okPlayerMapID, rawPlayerMapID = pcall(C_Map.GetBestMapForUnit, "player")
        local playerMapID = okPlayerMapID and SafeToNumber(rawPlayerMapID) or nil
        playerMapID = (playerMapID and playerMapID > 0) and playerMapID or nil
        if playerMapID then
            local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, playerMapID)
            mapInfo = okMapInfo and mapInfo or nil
            local mapType = SafeToNumber(mapInfo and mapInfo.mapType)
            mapType = (mapType and mapType > 0) and mapType or nil
            if mapType == 4 then
                return true
            end
        end
    end

    return false
end

local function GetRestrictedInstanceDebugSummary()
    local parts = {}

    local instancePart = "instance=n/a"
    if type(IsInInstance) == "function" then
        local okInst, inInstance, instanceType = pcall(IsInInstance)
        if okInst then
            instancePart = "instance=" .. SafeToString(inInstance) .. "/" .. SafeToString(instanceType)
        else
            instancePart = "instance=error"
        end
    end
    parts[#parts + 1] = instancePart

    if type(IsInScenario) == "function" then
        local okScenario, inScenario = pcall(IsInScenario)
        if okScenario then
            parts[#parts + 1] = "inScenario=" .. SafeToString(inScenario)
        else
            parts[#parts + 1] = "inScenario=error"
        end
    end

    if C_ScenarioInfo and type(C_ScenarioInfo.GetScenarioInfo) == "function" then
        local okInfo, info = pcall(C_ScenarioInfo.GetScenarioInfo)
        if okInfo and type(info) == "table" then
            parts[#parts + 1] = "scenarioName=" .. SafeToString(info.name)
            parts[#parts + 1] = "scenarioStage=" .. SafeToString(info.currentStage)
            parts[#parts + 1] = "scenarioStages=" .. SafeToString(info.numStages)
        elseif okInfo then
            parts[#parts + 1] = "scenarioInfo=nil"
        else
            parts[#parts + 1] = "scenarioInfo=error"
        end
    end

    return table.concat(parts, " ")
end

IsOptionsPreviewVisible = function()
    if IsInRestrictedInstance() then
        return false
    end

    local settings = GetSettings()
    if not settings then
        return false
    end
    if settings.huntScannerPreviewInOptions ~= true and settings.themeEditorPreviewInOptions ~= true then
        return false
    end

    local settingsModule = Preydator and Preydator.GetModule and Preydator:GetModule("Settings")
    local panel = settingsModule and settingsModule.optionsPanel
    if not (panel and panel.IsVisible and panel:IsVisible() == true) then
        return false
    end

    -- Preview should never override live hunt anchoring while hunt UI is active.
    if (_G.CovenantMissionFrame and _G.CovenantMissionFrame.IsShown and _G.CovenantMissionFrame:IsShown())
        or (_G.GossipFrame and _G.GossipFrame.IsShown and _G.GossipFrame:IsShown())
        or (_G.QuestFrame and _G.QuestFrame.IsShown and _G.QuestFrame:IsShown()) then
        return false
    end

    return true
end

local function StripRewardIconTags(text)
    if type(text) ~= "string" then
        return ""
    end

    local withoutTexture = text:gsub("|T[^|]+|t%s*", "")
    return (withoutTexture:gsub("|A[^|]+|a%s*", ""))
end

local function ExtractInlineRewardIconTag(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end

    local textureTag = text:match("(|T[^|]+|t)")
    if textureTag and textureTag ~= "" then
        return textureTag
    end

    local atlasTag = text:match("(|A[^|]+|a)")
    if atlasTag and atlasTag ~= "" then
        return atlasTag
    end

    return nil
end

local function ExtractRewardAmountText(text)
    if type(text) ~= "string" then
        return nil
    end

    local amount = text:match("^%s*(%d[%d%,%.]*)")
    if amount then
        return amount
    end

    return text:match("[xX]%s*(%d[%d%,%.]*)%s*$")
end

local function GetRewardListScore(list)
    if type(list) ~= "table" then
        return 0
    end

    local score = 0
    for _, text in ipairs(list) do
        local value = SafeToString(text or "")
        if value ~= "" then
            score = score + 1
            if not value:find(" XP", 1, true) then
                score = score + 10
            end
        end
    end

    return score
end

local function ShouldReplaceRewardList(candidateList, existingList)
    if type(candidateList) ~= "table" then
        return false
    end

    if type(existingList) ~= "table" then
        return true
    end

    local candidateScore = GetRewardListScore(candidateList)
    local existingScore = GetRewardListScore(existingList)
    if candidateScore > existingScore then
        return true
    end

    if candidateScore == existingScore then
        local candidateHasIcons = RewardListHasIconTags(candidateList)
        local existingHasIcons = RewardListHasIconTags(existingList)
        if candidateHasIcons and not existingHasIcons then
            return true
        end
    end

    return false
end

local function IsRewardCacheMissingOrEmpty(cachedRewards)
    return cachedRewards == nil or (type(cachedRewards) == "table" and #cachedRewards == 0)
end

local function RewardStyleShowsIcons(style)
    return style == "icon_text" or style == "icon_only" or style == "icon_count"
end

local function GetConfiguredHuntRewardStyle()
    local settings = GetSettings() or {}
    return settings.huntScannerRewardStyle or "icon_text"
end

function RewardListHasIconTags(list)
    if type(list) ~= "table" then
        return false
    end

    for _, entry in ipairs(list) do
        local text = SafeToString(entry or "")
        if text:find("|T", 1, true) or text:find("|A", 1, true) then
            return true
        end
    end

    return false
end

local function FormatRewardEntriesForStyle(list, rewardStyle)
    if type(list) ~= "table" then
        return ""
    end

    local style = rewardStyle or "icon_text"
    local showIcons = RewardStyleShowsIcons(style)
    local iconOnly = style == "icon_only"
    local iconCount = style == "icon_count"
    local entries = {}

    for _, entry in ipairs(list) do
        local text = SafeToString(entry or "")
        if text ~= "" then
            if not showIcons then
                text = StripRewardIconTags(text)
            elseif iconCount then
                local iconTag = ExtractInlineRewardIconTag(text)
                local stripped = StripRewardIconTags(text)
                local amount = ExtractRewardAmountText(stripped)
                if iconTag and amount then
                    text = iconTag .. " x" .. amount
                elseif iconTag then
                    text = iconTag
                else
                    text = stripped
                end
            elseif iconOnly then
                local iconTag = ExtractInlineRewardIconTag(text)
                text = iconTag or StripRewardIconTags(text)
            end

            if text ~= "" then
                entries[#entries + 1] = text
            end
        end
    end

    return table.concat(entries, ", ")
end

local function BuildPreviewRows()
    local rewardStyle = GetConfiguredHuntRewardStyle()

    return {
        {
            questID = nil,
            title = L["Preview: Normal Hunt"],
            baseTitle = L["Preview: Normal Hunt"],
            reward = FormatRewardEntriesForStyle({
                "|T237274:14:14:0:0|t 1,250 " .. L["Experience"],
                "|T4638297:14:14:0:0|t 50 Anguish",
                "|T134063:14:14:0:0|t Preview Cache Reward",
            }, rewardStyle),
            zone = "Dawnshore Coast",
            difficultyKey = DIFFICULTY_NORMAL,
            difficulty = L["Normal"],
            achievementCount = 1,
            achievementNames = {
                "Prey: Normal Mode I",
            },
            canAccept = false,
        },
        {
            questID = nil,
            title = L["Preview: Hard Hunt"],
            baseTitle = L["Preview: Hard Hunt"],
            reward = FormatRewardEntriesForStyle({
                "|T4638297:14:14:0:0|t 62 Anguish",
                "|T4638530:14:14:0:0|t 1 Voidlight Marl",
                "|T132625:14:14:0:0|t Preview Trinket",
            }, rewardStyle),
            zone = "Twilight Ridge",
            difficultyKey = DIFFICULTY_HARD,
            difficulty = L["Hard"],
            achievementCount = 2,
            achievementNames = {
                "Prey: Hard Mode I",
                "Prey: Ethereal Assassins (Hard)",
            },
            canAccept = false,
        },
        {
            questID = nil,
            title = L["Preview: Nightmare Hunt"],
            baseTitle = L["Preview: Nightmare Hunt"],
            reward = FormatRewardEntriesForStyle({
                "|T4638297:14:14:0:0|t 78 Anguish",
                "|T4638548:14:14:0:0|t 1 Champ. Crest",
                "|T135274:14:14:0:0|t Preview Weapon",
            }, rewardStyle),
            zone = "Umbral Wastes",
            difficultyKey = DIFFICULTY_NIGHTMARE,
            difficulty = L["Nightmare"],
            achievementCount = 4,
            achievementNames = {
                "Prey: Nightmare Mode I",
                "Prey: Chasing Death (Nightmare)",
                "Prey: No Rest for the Wretched (Nightmare)",
                "Prey: Ethereal Assassins (Nightmare)",
            },
            canAccept = false,
        },
    }
end

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
        season = { 1.00, 0.86, 0.00, 1.00 },
        fontKey = "frizqt",
    },
    brown = {
        section = { 0.08, 0.06, 0.03, 0.92 },
        row = { 0.14, 0.11, 0.06, 0.92 },
        rowAlt = { 0.10, 0.08, 0.05, 0.92 },
        border = { 0.78, 0.62, 0.20, 0.95 },
        header = { 0.21, 0.15, 0.06, 1.00 },
        title = { 1.00, 0.82, 0.00, 1.00 },
        text = { 1.00, 1.00, 1.00, 1.00 },
        muted = { 0.74, 0.70, 0.60, 1.00 },
        season = { 1.00, 0.86, 0.00, 1.00 },
        fontKey = "frizqt",
    },
    dark = {
        section = { 0.07, 0.07, 0.09, 0.92 },
        row = { 0.14, 0.14, 0.16, 0.92 },
        rowAlt = { 0.11, 0.11, 0.13, 0.92 },
        border = { 0.30, 0.30, 0.35, 0.90 },
        header = { 0.18, 0.18, 0.22, 1.00 },
        title = { 1.00, 0.82, 0.00, 1.00 },
        text = { 1.00, 1.00, 1.00, 1.00 },
        muted = { 0.65, 0.65, 0.70, 1.00 },
        season = { 1.00, 0.86, 0.00, 1.00 },
        fontKey = "frizqt",
    },
    deuteranopia = {
        section = { 0.06, 0.07, 0.14, 0.92 },
        row = { 0.10, 0.12, 0.22, 0.92 },
        rowAlt = { 0.08, 0.09, 0.17, 0.92 },
        border = { 0.90, 0.60, 0.10, 0.95 },
        header = { 0.14, 0.16, 0.30, 1.00 },
        title = { 1.00, 0.74, 0.00, 1.00 },
        text = { 1.00, 1.00, 1.00, 1.00 },
        muted = { 0.65, 0.68, 0.84, 1.00 },
        season = { 0.35, 0.65, 1.00, 1.00 },
        fontKey = "frizqt",
    },
    protanopia = {
        section = { 0.03, 0.10, 0.13, 0.92 },
        row = { 0.06, 0.16, 0.20, 0.92 },
        rowAlt = { 0.04, 0.12, 0.16, 0.92 },
        border = { 0.00, 0.72, 0.82, 0.95 },
        header = { 0.08, 0.20, 0.26, 1.00 },
        title = { 0.00, 0.88, 1.00, 1.00 },
        text = { 1.00, 1.00, 1.00, 1.00 },
        muted = { 0.50, 0.74, 0.80, 1.00 },
        season = { 1.00, 0.86, 0.00, 1.00 },
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

local function CopyThemeColors(source, fallback)
    local out = {}
    for _, key in ipairs(THEME_COLOR_KEYS) do
        local color = source and source[key]
        if type(color) ~= "table" then
            color = fallback and fallback[key]
        end
        if type(color) == "table" then
            out[key] = {
                tonumber(color[1]) or 1,
                tonumber(color[2]) or 1,
                tonumber(color[3]) or 1,
                tonumber(color[4]) or 1,
            }
        else
            out[key] = { 1, 1, 1, 1 }
        end
    end
    out.fontKey = type(source and source.fontKey) == "string" and source.fontKey
        or type(fallback and fallback.fontKey) == "string" and fallback.fontKey
        or "frizqt"
    return out
end

local function ResolveThemeValue(key, settings)
    local preset = THEME_PRESETS[key]
    if preset then
        return CopyThemeColors(preset, THEME_PRESETS.brown)
    end

    local custom = settings and settings.customThemes and settings.customThemes[key]
    if type(custom) == "table" then
        return CopyThemeColors(custom, THEME_PRESETS.brown)
    end

    return CopyThemeColors(THEME_PRESETS.brown, THEME_PRESETS.brown)
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

GetSettings = function()
    local api = Preydator and Preydator.API
    if not api or type(api.GetSettings) ~= "function" then
        return nil
    end
    return api.GetSettings()
end

local function IsHuntModuleEnabled()
    local customizationV2 = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        return customizationV2:IsModuleEnabled("hunt") == true
    end
    return true
end

IsHuntRuntimeEnabled = function()
    if not IsHuntModuleEnabled() then
        return false
    end

    local settings = GetSettings()
    if not settings then
        return false
    end

    return settings.huntScannerEnabled ~= false
end

local function EnsureSettings()
    local settings = GetSettings()
    if not settings then
        return
    end

    local function NormalizeDifficultyColor(color, fallback)
        local source = type(color) == "table" and color or fallback
        local base = type(fallback) == "table" and fallback or { 1, 1, 1, 1 }
        return {
            math.max(0, math.min(1, tonumber(source and source[1]) or base[1] or 1)),
            math.max(0, math.min(1, tonumber(source and source[2]) or base[2] or 1)),
            math.max(0, math.min(1, tonumber(source and source[3]) or base[3] or 1)),
            math.max(0, math.min(1, tonumber(source and source[4]) or base[4] or 1)),
        }
    end

    if settings.huntScannerEnabled == nil then
        settings.huntScannerEnabled = true
    end

    if settings.huntScannerSide ~= "left" and settings.huntScannerSide ~= "right" then
        settings.huntScannerSide = "right"
    end

    if settings.huntScannerMatchCurrencyTheme == nil then
        settings.huntScannerMatchCurrencyTheme = true
    end

    if settings.huntScannerUseCurrencyTheme == nil then
        settings.huntScannerUseCurrencyTheme = settings.huntScannerMatchCurrencyTheme ~= false
    end

    if type(settings.huntScannerTheme) ~= "string" or settings.huntScannerTheme == "" then
        settings.huntScannerTheme = settings.currencyTheme or "brown"
    end

    if settings.huntScannerPreviewInOptions == nil then
        settings.huntScannerPreviewInOptions = false
    end

    if settings.huntScannerShowRewardIcons == nil then
        settings.huntScannerShowRewardIcons = true
    end

    if settings.huntScannerRewardStyle ~= "icon_text"
        and settings.huntScannerRewardStyle ~= "icon_count"
        and settings.huntScannerRewardStyle ~= "text_only"
        and settings.huntScannerRewardStyle ~= "icon_only" then
        settings.huntScannerRewardStyle = (settings.huntScannerShowRewardIcons == false) and "text_only" or "icon_text"
    end

    if type(settings.huntScannerDifficultyColors) ~= "table" then
        settings.huntScannerDifficultyColors = {}
    end
    settings.huntScannerDifficultyColors.normal = NormalizeDifficultyColor(
        settings.huntScannerDifficultyColors.normal,
        DEFAULT_DIFFICULTY_COLORS[DIFFICULTY_NORMAL]
    )
    settings.huntScannerDifficultyColors.hard = NormalizeDifficultyColor(
        settings.huntScannerDifficultyColors.hard,
        DEFAULT_DIFFICULTY_COLORS[DIFFICULTY_HARD]
    )
    settings.huntScannerDifficultyColors.nightmare = NormalizeDifficultyColor(
        settings.huntScannerDifficultyColors.nightmare,
        DEFAULT_DIFFICULTY_COLORS[DIFFICULTY_NIGHTMARE]
    )

    if settings.huntScannerAchievementSignals == nil then
        settings.huntScannerAchievementSignals = true
    end

    if settings.huntScannerAchievementSignalStyle ~= "icon_only"
        and settings.huntScannerAchievementSignalStyle ~= "icon_count"
        and settings.huntScannerAchievementSignalStyle ~= "count_only" then
        if settings.huntScannerAchievementShowCount == false then
            settings.huntScannerAchievementSignalStyle = "icon_only"
        else
            settings.huntScannerAchievementSignalStyle = "icon_count"
        end
    end

    if settings.huntScannerAchievementShowCount == nil then
        settings.huntScannerAchievementShowCount = true
    end

    if settings.huntScannerAchievementTooltip == nil then
        settings.huntScannerAchievementTooltip = true
    end

    settings.huntScannerAchievementBadgeColor = NormalizeDifficultyColor(
        settings.huntScannerAchievementBadgeColor,
        DEFAULT_ACHIEVEMENT_BADGE_COLOR
    )

    settings.huntScannerAchievementIconSize = math.max(12, math.min(32, tonumber(settings.huntScannerAchievementIconSize) or 18))

    if settings.themeEditorPreviewInOptions == nil then
        settings.themeEditorPreviewInOptions = false
    end

    if settings.huntScannerGroupBy ~= "none" and settings.huntScannerGroupBy ~= "difficulty" and settings.huntScannerGroupBy ~= "zone" then
        settings.huntScannerGroupBy = "difficulty"
    end

    if settings.huntScannerSortBy ~= "difficulty" and settings.huntScannerSortBy ~= "zone" and settings.huntScannerSortBy ~= "title" then
        settings.huntScannerSortBy = "zone"
    end

    if settings.huntScannerSortDir ~= "asc" and settings.huntScannerSortDir ~= "desc" then
        settings.huntScannerSortDir = "asc"
    end

    if settings.huntScannerAnchorAlign ~= "top" and settings.huntScannerAnchorAlign ~= "middle" and settings.huntScannerAnchorAlign ~= "bottom" then
        settings.huntScannerAnchorAlign = "top"
    end

    if type(settings.huntScannerCollapsedGroups) ~= "table" then
        settings.huntScannerCollapsedGroups = {}
    end

    settings.huntScannerWidth = math.max(280, math.min(620, tonumber(settings.huntScannerWidth) or 336))
    settings.huntScannerHeight = math.max(320, math.min(900, tonumber(settings.huntScannerHeight) or 460))
    settings.huntScannerFontSize = math.max(10, math.min(24, tonumber(settings.huntScannerFontSize) or 12))
    settings.huntScannerScale = math.max(0.70, math.min(1.60, tonumber(settings.huntScannerScale) or 1.00))
end

local function AddUniqueString(target, value)
    if type(target) ~= "table" or type(value) ~= "string" or value == "" then
        return
    end

    for _, existing in ipairs(target) do
        if existing == value then
            return
        end
    end

    target[#target + 1] = value
end

local function AddUniqueNumber(target, value)
    if type(target) ~= "table" or type(value) ~= "number" then
        return
    end

    for _, existing in ipairs(target) do
        if existing == value then
            return
        end
    end

    target[#target + 1] = value
end

local function SortStrings(values)
    if type(values) ~= "table" or #values < 2 then
        return values
    end

    table.sort(values, function(left, right)
        return tostring(left or "") < tostring(right or "")
    end)
    return values
end

local function RebuildAchievementNeedsCache()
    wipe(achievementNeedsByQuestID)
    wipe(achievementNeedsByNameKey)
    lastAchievementCacheBuildAt = GetTime and (tonumber(GetTime()) or 0) or 0
    achievementCacheDirty = false

    if type(GetAchievementInfo) ~= "function"
        or type(GetAchievementNumCriteria) ~= "function"
        or type(GetAchievementCriteriaInfo) ~= "function" then
        return
    end

    -- Fast-path: use static questID mappings first. This remains locale-independent
    -- and avoids string matching for known prey achievements.
    if type(GetAchievementCriteriaInfoByID) == "function"
        and type(addon.PreyQuestData) == "table"
        and type(addon.PREY_HUNT_ACHIEVEMENT_IDS) == "table" then
        local criteriaByAchievement = {}

        local function BuildCriteriaMapForAchievement(achievementID)
            if criteriaByAchievement[achievementID] ~= nil then
                return criteriaByAchievement[achievementID]
            end

            local map = {}
            local okCount, criteriaCountRaw = pcall(GetAchievementNumCriteria, achievementID)
            local criteriaCount = (okCount and SafeToNumber(criteriaCountRaw)) or 0
            for criteriaIndex = 1, criteriaCount do
                local okCriteria, criteriaName, criteriaTypeRaw, criteriaCompleted, _, _, _, _, assetIDRaw =
                    pcall(GetAchievementCriteriaInfo, achievementID, criteriaIndex, true)
                local criteriaType = SafeToNumber(criteriaTypeRaw)
                local questID = SafeToNumber(assetIDRaw)
                if okCriteria
                    and criteriaType == ACHIEVEMENT_CRITERIA_TYPE_QUEST
                    and questID and questID > 0 then
                    local entries = map[questID]
                    if not entries then
                        entries = {}
                        map[questID] = entries
                    end
                    entries[#entries + 1] = {
                        completed = (criteriaCompleted == true),
                        name = criteriaName,
                    }
                end
            end

            criteriaByAchievement[achievementID] = map
            return map
        end

        local function GetQuestCriteriaLabelIfIncomplete(achievementID, questID, criteriaIDHint)
            if criteriaIDHint then
                local okByID, criteriaNameByID, _, criteriaCompletedByID =
                    pcall(GetAchievementCriteriaInfoByID, achievementID, criteriaIDHint)
                if okByID and criteriaCompletedByID ~= true then
                    return criteriaNameByID
                end
                if okByID then
                    return nil
                end
            end

            local criteriaMap = BuildCriteriaMapForAchievement(achievementID)
            local entries = criteriaMap and criteriaMap[questID] or nil
            if type(entries) ~= "table" then
                return nil
            end

            for _, entry in ipairs(entries) do
                if type(entry) == "table" and entry.completed ~= true then
                    return entry.name
                end
            end

            return nil
        end

        local function TryAddMappedQuestAchievement(questID, achievementID, criteriaIDHint)
            if type(achievementID) ~= "number" or achievementID <= 0 then
                return
            end
            if IsAchievementCompletedCached(achievementID) then
                return
            end

            local okInfo, _, achievementName, _, achievementCompleted = pcall(GetAchievementInfo, achievementID)
            if not okInfo then
                return
            end
            if achievementCompleted == true then
                MarkAchievementCompleted(achievementID)
                return
            end

            local criteriaName = GetQuestCriteriaLabelIfIncomplete(achievementID, questID, criteriaIDHint)
            if not criteriaName then
                return
            end

            local label = (type(achievementName) == "string" and achievementName ~= "" and achievementName)
                or (type(criteriaName) == "string" and criteriaName ~= "" and criteriaName)
                or ("Achievement " .. tostring(achievementID))
            AddAchievementNeed(achievementNeedsByQuestID, questID, achievementID, label)
        end

        local modeSeriesQuestSlotsByDifficulty = {}

        local function BuildModeSeriesQuestSlotsForDifficulty(difficultyIndex)
            if modeSeriesQuestSlotsByDifficulty[difficultyIndex] ~= nil then
                return modeSeriesQuestSlotsByDifficulty[difficultyIndex]
            end

            local slots = { byQuestID = {}, byCriteriaIndex = {} }
            local modeIIIAchievementID = type(addon.PREY_HUNT_ACHIEVEMENT_IDS) == "table"
                and addon.PREY_HUNT_ACHIEVEMENT_IDS[difficultyIndex]
                or nil

            if type(modeIIIAchievementID) ~= "number" or modeIIIAchievementID <= 0 then
                modeSeriesQuestSlotsByDifficulty[difficultyIndex] = slots
                return slots
            end

            local okCount, criteriaCountRaw = pcall(GetAchievementNumCriteria, modeIIIAchievementID)
            local criteriaCount = (okCount and SafeToNumber(criteriaCountRaw)) or 0
            for criteriaIndex = 1, criteriaCount do
                local okCriteria, _, criteriaTypeRaw, _, _, _, _, _, assetIDRaw =
                    pcall(GetAchievementCriteriaInfo, modeIIIAchievementID, criteriaIndex, true)
                local criteriaType = SafeToNumber(criteriaTypeRaw)
                local mappedQuestID = SafeToNumber(assetIDRaw)
                if okCriteria
                    and criteriaType == ACHIEVEMENT_CRITERIA_TYPE_QUEST
                    and mappedQuestID and mappedQuestID > 0 then
                    slots.byQuestID[mappedQuestID] = criteriaIndex
                    if slots.byCriteriaIndex[criteriaIndex] == nil then
                        slots.byCriteriaIndex[criteriaIndex] = mappedQuestID
                    end
                end
            end

            modeSeriesQuestSlotsByDifficulty[difficultyIndex] = slots
            return slots
        end

        local function GetCumulativeQuestIDsForDifficulty(questID, difficultyIndex)
            local result = { questID }
            if type(difficultyIndex) ~= "number" or difficultyIndex <= 1 then
                return result
            end

            local currentSlots = BuildModeSeriesQuestSlotsForDifficulty(difficultyIndex)
            local criteriaIndex = type(currentSlots) == "table"
                and type(currentSlots.byQuestID) == "table"
                and currentSlots.byQuestID[questID]
                or nil
            if type(criteriaIndex) ~= "number" then
                return result
            end

            local seen = { [questID] = true }
            for lowerDifficulty = 1, (difficultyIndex - 1) do
                local lowerSlots = BuildModeSeriesQuestSlotsForDifficulty(lowerDifficulty)
                local lowerQuestID = type(lowerSlots) == "table"
                    and type(lowerSlots.byCriteriaIndex) == "table"
                    and SafeToNumber(lowerSlots.byCriteriaIndex[criteriaIndex])
                    or nil
                if lowerQuestID and lowerQuestID > 0 and not seen[lowerQuestID] then
                    seen[lowerQuestID] = true
                    result[#result + 1] = lowerQuestID
                end
            end

            return result
        end

        for questID, data in pairs(addon.PreyQuestData) do
            local difficultyIndex = data[1]
            local criteriaID = data[2]

            -- Primary III-series criteria mapping from PreyQuestData.
            local modeIIIAchievementID = addon.PREY_HUNT_ACHIEVEMENT_IDS[difficultyIndex]
            if modeIIIAchievementID then
                TryAddMappedQuestAchievement(questID, modeIIIAchievementID, criteriaID)
            end

            -- Include per-difficulty I/II/III progress achievements when they expose
            -- quest criteria for this quest.
            local modeIDsByDifficulty = addon.PREY_HUNT_MODE_ACHIEVEMENT_IDS_BY_DIFFICULTY
            local modeIDs = type(modeIDsByDifficulty) == "table" and modeIDsByDifficulty[difficultyIndex] or nil
            if type(modeIDs) == "table" then
                for _, modeAchievementID in ipairs(modeIDs) do
                    if modeAchievementID ~= modeIIIAchievementID then
                        -- Use the same quest-specific criteria hint for lower mode tiers
                        -- so Mode II/III (or I/II/III) can stack on the same hunt row.
                        TryAddMappedQuestAchievement(questID, modeAchievementID, criteriaID)
                    end
                end
            end

            -- Include explicit non-meta tracked achievements mapped by quest.
            local mappedAchievementsByQuest = addon.PREY_HUNT_ACHIEVEMENTS_BY_QUEST
            local cumulativeQuestIDs = GetCumulativeQuestIDsForDifficulty(questID, difficultyIndex)
            if type(mappedAchievementsByQuest) == "table" and type(cumulativeQuestIDs) == "table" then
                for _, mappedQuestID in ipairs(cumulativeQuestIDs) do
                    local mappedAchievements = mappedAchievementsByQuest[mappedQuestID]
                    if type(mappedAchievements) == "table" then
                        local mappedQuestData = type(addon.PreyQuestData) == "table" and addon.PreyQuestData[mappedQuestID] or nil
                        local mappedCriteriaID = type(mappedQuestData) == "table" and SafeToNumber(mappedQuestData[2]) or nil
                        for _, mappedAchievementID in ipairs(mappedAchievements) do
                            TryAddMappedQuestAchievement(questID, mappedAchievementID, mappedCriteriaID)
                        end
                    end
                end
            end
        end
    end

    for _, achievementID in ipairs(TRACKED_PREY_ACHIEVEMENT_IDS) do
        if not IsAchievementCompletedCached(achievementID) then
            local okInfo, _, achievementName, _, achievementCompleted = pcall(GetAchievementInfo, achievementID)
            if okInfo and achievementCompleted == true then
                MarkAchievementCompleted(achievementID)
            elseif okInfo then
            local okCount, criteriaCountRaw = pcall(GetAchievementNumCriteria, achievementID)
            local criteriaCount = (okCount and SafeToNumber(criteriaCountRaw)) or 0

            for criteriaIndex = 1, criteriaCount do
                local okCriteria, criteriaName, criteriaTypeRaw, criteriaCompleted, _, _, _, _, assetIDRaw = pcall(GetAchievementCriteriaInfo, achievementID, criteriaIndex, true)
                local criteriaType = SafeToNumber(criteriaTypeRaw)
                local questID = SafeToNumber(assetIDRaw)

                if okCriteria
                    and criteriaType == ACHIEVEMENT_CRITERIA_TYPE_QUEST
                    and questID and questID > 0
                    and criteriaCompleted ~= true then
                    local label = (type(achievementName) == "string" and achievementName ~= "" and achievementName)
                        or (type(criteriaName) == "string" and criteriaName ~= "" and criteriaName)
                        or ("Achievement " .. tostring(achievementID))
                    AddAchievementNeed(achievementNeedsByQuestID, questID, achievementID, label)
                end
            end
            end
        end
    end

    for _, bucket in pairs(achievementNeedsByQuestID) do
        SortStrings(bucket.names)
        bucket.count = #bucket.ids
    end

    for _, bucket in pairs(achievementNeedsByNameKey) do
        SortStrings(bucket.names)
        bucket.count = #bucket.ids
    end
end

local function EnsureAchievementNeedsCache(force)
    local settings = GetSettings()
    if not settings or settings.huntScannerAchievementSignals == false then
        return
    end

    local now = GetTime and (tonumber(GetTime()) or 0) or 0
    if force == true
        or achievementCacheDirty == true
        or (now - (lastAchievementCacheBuildAt or 0)) >= ACHIEVEMENT_CACHE_MIN_REBUILD_SECONDS then
        RebuildAchievementNeedsCache()
    end
end

local function ResolveAchievementNameBucket(title, difficulty)
    if type(title) ~= "string" or title == "" then
        return nil, nil
    end

    local function BuildTitleVariants(sourceTitle)
        local variants = {}
        local seen = {}
        local function AddVariant(value)
            if type(value) ~= "string" or value == "" or seen[value] then
                return
            end
            seen[value] = true
            variants[#variants + 1] = value
        end

        AddVariant(sourceTitle)

        local lowered = string.lower(sourceTitle)
        if string.match(lowered, "^the%s+") then
            local withoutThe = string.gsub(sourceTitle, "^[Tt][Hh][Ee]%s+", "", 1)
            AddVariant(withoutThe)
        else
            AddVariant("The " .. sourceTitle)
        end

        -- Known Blizzard string drift: Jan'alai appears as Janali in some
        -- achievement criteria names. Add a scoped alias to avoid broad fuzzy
        -- matching across unrelated hunt titles.
        local normalizedSource = NormalizeAchievementMatchText(sourceTitle)
        if normalizedSource == "the talon of jan alai" or normalizedSource == "talon of jan alai" then
            AddVariant("The Talon of Janali")
            AddVariant("Talon of Janali")
        end

        return variants
    end

    local function HasBucket(candidate)
        return type(candidate) == "table" and (candidate.count or 0) > 0
    end

    local titleVariants = BuildTitleVariants(title)

    local function ResolveForDifficulty(difficultyKey)
        for _, candidateTitle in ipairs(titleVariants) do
            local strictKey = BuildAchievementMatchKey(candidateTitle, difficultyKey)
            local strictBucket = strictKey and achievementNeedsByNameKey[strictKey] or nil
            if HasBucket(strictBucket) then
                return strictBucket, (candidateTitle == title) and "diff" or "diff-title"
            end

            local compactKey = BuildAchievementCompactMatchKey(candidateTitle, difficultyKey)
            local compactBucket = compactKey and achievementNeedsByNameKey[compactKey] or nil
            if HasBucket(compactBucket) then
                return compactBucket, (candidateTitle == title) and "compact" or "compact-title"
            end
        end

        return nil, nil
    end

    local canonicalDifficulty = NormalizeDifficultyKey(difficulty)
    local bucket, source = ResolveForDifficulty(canonicalDifficulty)
    if HasBucket(bucket) then
        return bucket, source
    end

    for _, candidateTitle in ipairs(titleVariants) do
        local plainNameKey = BuildAchievementMatchKey(candidateTitle, nil)
        local plainBucket = plainNameKey and achievementNeedsByNameKey[plainNameKey] or nil
        if HasBucket(plainBucket) then
            return plainBucket, (candidateTitle == title) and "plain" or "plain-title"
        end

        local compactPlainKey = BuildAchievementCompactMatchKey(candidateTitle, nil)
        local compactPlainBucket = compactPlainKey and achievementNeedsByNameKey[compactPlainKey] or nil
        if HasBucket(compactPlainBucket) then
            return compactPlainBucket, (candidateTitle == title) and "compact-plain" or "compact-plain-title"
        end
    end

    return nil, nil
end

local function MergeAchievementBuckets(primaryBucket, secondaryBucket)
    local hasPrimary = type(primaryBucket) == "table" and (primaryBucket.count or 0) > 0
    local hasSecondary = type(secondaryBucket) == "table" and (secondaryBucket.count or 0) > 0

    if hasPrimary and not hasSecondary then
        return primaryBucket.count or 0, primaryBucket.names
    end
    if hasSecondary and not hasPrimary then
        return secondaryBucket.count or 0, secondaryBucket.names
    end
    if not hasPrimary and not hasSecondary then
        return 0, nil
    end

    local mergedIDs = {}
    local mergedNames = {}

    for _, achievementID in ipairs(primaryBucket.ids or {}) do
        AddUniqueNumber(mergedIDs, achievementID)
    end
    for _, achievementID in ipairs(secondaryBucket.ids or {}) do
        AddUniqueNumber(mergedIDs, achievementID)
    end

    for _, label in ipairs(primaryBucket.names or {}) do
        AddUniqueString(mergedNames, label)
    end
    for _, label in ipairs(secondaryBucket.names or {}) do
        AddUniqueString(mergedNames, label)
    end

    SortStrings(mergedNames)
    if #mergedIDs <= 0 then
        return 0, nil
    end

    return #mergedIDs, mergedNames
end

local function GetQuestAchievementNeeds(questID, title, difficulty)
    local id = SafeToNumber(questID)

    local settings = GetSettings()
    if not settings or settings.huntScannerAchievementSignals == false then
        return 0, nil
    end

    EnsureAchievementNeedsCache(false)
    local idBucket = id and achievementNeedsByQuestID[id] or nil
    local hasIDBucket = type(idBucket) == "table" and (idBucket.count or 0) > 0

    if hasIDBucket then
        achievementRouteStats.idHits = (achievementRouteStats.idHits or 0) + 1
        return idBucket.count or 0, idBucket.names
    end

    achievementRouteStats.misses = (achievementRouteStats.misses or 0) + 1
    return 0, nil
end

local function GetRewardScopeKey()
    local name = UnitName and UnitName("player") or "unknown"
    local realm = GetRealmName and GetRealmName() or "unknown"
    local level = UnitLevel and UnitLevel("player") or 0
    return tostring(name) .. "-" .. tostring(realm) .. "@" .. tostring(level)
end

local function GetPanelConfig()
    local settings = GetSettings()
    local width = math.max(280, math.min(620, tonumber(settings and settings.huntScannerWidth) or 336))
    local height = math.max(320, math.min(900, tonumber(settings and settings.huntScannerHeight) or 460))
    local fontSize = math.max(10, math.min(24, tonumber(settings and settings.huntScannerFontSize) or 12))
    local scale = math.max(0.70, math.min(1.60, tonumber(settings and settings.huntScannerScale) or 1.00))
    return width, height, fontSize, scale
end

local function GetTheme()
    local settings = GetSettings()

    if settings and settings.themeEditorPreviewInOptions == true and type(settings.themeEditorColors) == "table" then
        local baseKey = settings.themeEditorLoadKey or "brown"
        local baseTheme = ResolveThemeValue(baseKey, settings)
        local previewTheme = CopyThemeColors(settings.themeEditorColors, baseTheme)
        previewTheme.fontKey = settings.themeEditorFontKey or baseTheme.fontKey or "frizqt"
        return previewTheme
    end

    local useCurrencyTheme = not settings or settings.huntScannerUseCurrencyTheme ~= false
    local key = useCurrencyTheme and (settings and settings.currencyTheme or "brown") or (settings and settings.huntScannerTheme or "brown")
    return ResolveThemeValue(key, settings)
end

local function GetThemeKey()
    local settings = GetSettings()

    if settings and settings.themeEditorPreviewInOptions == true and type(settings.themeEditorColors) == "table" then
        return settings.themeEditorLoadKey or "brown"
    end

    local useCurrencyTheme = not settings or settings.huntScannerUseCurrencyTheme ~= false
    return useCurrencyTheme and (settings and settings.currencyTheme or "brown") or (settings and settings.huntScannerTheme or "brown")
end

local function GetCoreState()
    local api = Preydator and Preydator.API
    if not api or type(api.GetState) ~= "function" then
        return nil
    end
    return api.GetState()
end

local function GetRewardStorage()
    _G.PreydatorDB = _G.PreydatorDB or {}
    _G.PreydatorDB.huntScanner = _G.PreydatorDB.huntScanner or {}

    local storage = _G.PreydatorDB.huntScanner
    storage.rewardCache = storage.rewardCache or {}
    storage.difficultyRewardCache = storage.difficultyRewardCache or {}
    storage.questDifficultyByID = storage.questDifficultyByID or {}
    storage.availabilityCacheByScope = storage.availabilityCacheByScope or {}
    storage.availabilityTouchedByScope = storage.availabilityTouchedByScope or {}
    storage.completedAchievements = storage.completedAchievements or {}

    return storage
end

LoadCompletedAchievementCache = function()
    if wipe then
        wipe(completedAchievementCache)
    else
        for key in pairs(completedAchievementCache) do
            completedAchievementCache[key] = nil
        end
    end

    local storage = GetRewardStorage()
    for achievementIDText, isCompleted in pairs(storage.completedAchievements or {}) do
        local achievementID = SafeToNumber(achievementIDText)
        if achievementID and isCompleted == true then
            completedAchievementCache[achievementID] = true
        end
    end
end

local function SaveCompletedAchievementCache()
    local storage = GetRewardStorage()
    local persisted = {}
    for achievementID, isCompleted in pairs(completedAchievementCache) do
        if type(achievementID) == "number" and isCompleted == true then
            persisted[tostring(achievementID)] = true
        end
    end
    storage.completedAchievements = persisted
end

MarkAchievementCompleted = function(achievementID)
    local id = SafeToNumber(achievementID)
    if not id or completedAchievementCache[id] == true then
        return
    end

    completedAchievementCache[id] = true
    SaveCompletedAchievementCache()
end

IsAchievementCompletedCached = function(achievementID)
    local id = SafeToNumber(achievementID)
    return id and completedAchievementCache[id] == true or false
end

local function ClearCompletedAchievementCache()
    if wipe then
        wipe(completedAchievementCache)
        wipe(achievementNeedsByQuestID)
        wipe(achievementNeedsByNameKey)
    else
        for key in pairs(completedAchievementCache) do
            completedAchievementCache[key] = nil
        end
        for key in pairs(achievementNeedsByQuestID) do
            achievementNeedsByQuestID[key] = nil
        end
        for key in pairs(achievementNeedsByNameKey) do
            achievementNeedsByNameKey[key] = nil
        end
    end

    achievementCacheDirty = true
    lastAchievementCacheBuildAt = 0
    SaveCompletedAchievementCache()
end

local function ClearAvailabilityCache()
    availabilityCache = {
        normal = 0,
        hard = 0,
        nightmare = 0,
        capturedAt = 0,
    }
    availabilityTouched = false

    local storage = GetRewardStorage()
    storage.availabilityCacheByScope = {}
    storage.availabilityTouchedByScope = {}
end

local function SanitizeAvailabilityCounts(source)
    if type(source) ~= "table" then
        return {
            normal = 0,
            hard = 0,
            nightmare = 0,
            capturedAt = 0,
        }
    end

    return {
        normal = math.max(0, tonumber(source.normal) or 0),
        hard = math.max(0, tonumber(source.hard) or 0),
        nightmare = math.max(0, tonumber(source.nightmare) or 0),
        capturedAt = math.max(0, tonumber(source.capturedAt) or 0),
    }
end

local function SaveAvailabilityCache()
    local storage = GetRewardStorage()
    local scopeKey = GetRewardScopeKey()
    storage.availabilityCacheByScope[scopeKey] = SanitizeAvailabilityCounts(availabilityCache)
    storage.availabilityTouchedByScope[scopeKey] = availabilityTouched == true
end

local function LoadAvailabilityCache()
    local storage = GetRewardStorage()
    local scopeKey = GetRewardScopeKey()
    availabilityCache = SanitizeAvailabilityCounts(storage.availabilityCacheByScope[scopeKey])
    availabilityTouched = storage.availabilityTouchedByScope[scopeKey] == true
end

local function GetDifficultyDisplayName(canonicalDifficulty)
    if canonicalDifficulty == DIFFICULTY_HARD then
        return L["Hard"]
    elseif canonicalDifficulty == DIFFICULTY_NIGHTMARE then
        return L["Nightmare"]
    end

    return L["Normal"]
end

NormalizeDifficultyKey = function(value)
    if type(value) ~= "string" or value == "" then
        return DIFFICULTY_NORMAL
    end

    if value == DIFFICULTY_NORMAL or value == DIFFICULTY_HARD or value == DIFFICULTY_NIGHTMARE then
        return value
    end

    if value == L["Nightmare"] or value == "Nightmare" then
        return DIFFICULTY_NIGHTMARE
    end

    if value == L["Hard"] or value == "Hard" then
        return DIFFICULTY_HARD
    end

    return DIFFICULTY_NORMAL
end

local function EscapePattern(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    return (string.gsub(text, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function NormalizeToken(value)
    if type(value) ~= "string" then
        return nil
    end

    local text = string.gsub(value, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then
        return nil
    end

    return string.lower(text)
end

local function DetectDifficultyFromText(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local normalized = NormalizeToken(value)
    if not normalized then
        return nil
    end

    local nightmareToken = NormalizeToken(L["Nightmare"])
    local hardToken = NormalizeToken(L["Hard"])
    local normalToken = NormalizeToken(L["Normal"])

    if SafeFindLiteral(normalized, "nightmare") or (nightmareToken and SafeFindLiteral(normalized, nightmareToken)) then
        return DIFFICULTY_NIGHTMARE
    end
    if SafeFindLiteral(normalized, "hard") or (hardToken and SafeFindLiteral(normalized, hardToken)) then
        return DIFFICULTY_HARD
    end
    if SafeFindLiteral(normalized, "normal") or (normalToken and SafeFindLiteral(normalized, normalToken)) then
        return DIFFICULTY_NORMAL
    end

    return nil
end

NormalizeAchievementMatchText = function(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local text = value
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    -- Strip a short leading label prefix (e.g. "Prey:", localized equivalents).
    local fullWidthColon = "\239\188\154"
    local colonStart, colonEnd = string.find(text, ":", 1, true)
    if not colonStart then
        colonStart, colonEnd = string.find(text, fullWidthColon, 1, true)
    end
    if colonStart and colonEnd and colonStart <= 28 then
        local prefix = string.sub(text, 1, colonStart - 1)
        if not string.find(prefix, "%d") then
            text = string.sub(text, colonEnd + 1)
            text = string.gsub(text, "^%s+", "")
        end
    end

    text = string.gsub(text, "^Complete%s+", "")

    local trailingParen = string.match(text, "%s*(%b())%s*$")
    if trailingParen then
        local inner = string.sub(trailingParen, 2, -2)
        if DetectDifficultyFromText(inner) then
            local escaped = EscapePattern(trailingParen)
            text = string.gsub(text, "%s*" .. escaped .. "%s*$", "")
        end
    end

    -- Keep non-ASCII letters intact for locale-safe matching.
    text = string.gsub(text, "[%p%c]+", " ")
    text = string.lower(string.gsub(text, "%s+", " "))
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    if text == "" then
        return nil
    end

    return text
end

local function ExtractAchievementDifficultyKey(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if type(value) == "string" and value ~= "" then
            local difficulty = DetectDifficultyFromText(value)
            if difficulty then
                return difficulty
            end
        end
    end

    return nil
end

BuildAchievementMatchKey = function(title, difficulty)
    local normalizedTitle = NormalizeAchievementMatchText(title)
    if not normalizedTitle then
        return nil
    end

    local difficultyKey = difficulty and NormalizeDifficultyKey(difficulty) or nil
    if difficultyKey ~= DIFFICULTY_NORMAL and difficultyKey ~= DIFFICULTY_HARD and difficultyKey ~= DIFFICULTY_NIGHTMARE then
        difficultyKey = nil
    end

    return normalizedTitle .. "::" .. tostring(difficultyKey or "")
end

BuildAchievementCompactMatchKey = function(title, difficulty)
    local normalizedTitle = NormalizeAchievementMatchText(title)
    if not normalizedTitle then
        return nil
    end

    local compactTitle = string.gsub(normalizedTitle, "%s+", "")
    if compactTitle == "" then
        return nil
    end

    local difficultyKey = difficulty and NormalizeDifficultyKey(difficulty) or nil
    if difficultyKey ~= DIFFICULTY_NORMAL and difficultyKey ~= DIFFICULTY_HARD and difficultyKey ~= DIFFICULTY_NIGHTMARE then
        difficultyKey = nil
    end

    return compactTitle .. "::" .. tostring(difficultyKey or "")
end

AddAchievementNeed = function(bucketMap, bucketKey, achievementID, label)
    if type(bucketMap) ~= "table" or bucketKey == nil then
        return
    end

    local key = type(bucketKey) == "number" and bucketKey or tostring(bucketKey)
    if key == "" then
        return
    end

    local bucket = bucketMap[key]
    if not bucket then
        bucket = {
            ids = {},
            names = {},
            count = 0,
        }
        bucketMap[key] = bucket
    end

    AddUniqueNumber(bucket.ids, achievementID)
    AddUniqueString(bucket.names, label)
end

AddAchievementNameMatch = function(achievementID, achievementName, criteriaName, label)
    local difficultyKey = ExtractAchievementDifficultyKey(achievementName, criteriaName)
    local achievementKey = BuildAchievementMatchKey(achievementName, difficultyKey)
    if achievementKey then
        AddAchievementNeed(achievementNeedsByNameKey, achievementKey, achievementID, label)
    end

    local achievementCompactKey = BuildAchievementCompactMatchKey(achievementName, difficultyKey)
    if achievementCompactKey and achievementCompactKey ~= achievementKey then
        AddAchievementNeed(achievementNeedsByNameKey, achievementCompactKey, achievementID, label)
    end

    local criteriaKey = BuildAchievementMatchKey(criteriaName, difficultyKey)
    if criteriaKey and criteriaKey ~= achievementKey then
        AddAchievementNeed(achievementNeedsByNameKey, criteriaKey, achievementID, label)
    end

    local criteriaCompactKey = BuildAchievementCompactMatchKey(criteriaName, difficultyKey)
    if criteriaCompactKey
        and criteriaCompactKey ~= criteriaKey
        and criteriaCompactKey ~= achievementKey
        and criteriaCompactKey ~= achievementCompactKey then
        AddAchievementNeed(achievementNeedsByNameKey, criteriaCompactKey, achievementID, label)
    end
end

local function MarkAvailabilityTouched()
    if availabilityTouched then
        return
    end

    availabilityTouched = true
    SaveAvailabilityCache()
end

local function UpdateAvailabilityCacheFromHunts(hunts)
    local counts = {
        normal = 0,
        hard = 0,
        nightmare = 0,
        capturedAt = GetTime and (tonumber(GetTime()) or 0) or 0,
    }

    for _, hunt in ipairs(hunts or {}) do
        local questID = SafeToNumber(hunt and hunt.questID)
        if questID and questID > 0 then
            local isOnQuest = C_QuestLog and type(C_QuestLog.IsOnQuest) == "function" and C_QuestLog.IsOnQuest(questID) == true
            if not isOnQuest then
                local difficulty = NormalizeDifficultyKey(hunt and hunt.difficulty)
                if difficulty == DIFFICULTY_NIGHTMARE then
                    counts[DIFFICULTY_NIGHTMARE] = counts[DIFFICULTY_NIGHTMARE] + 1
                elseif difficulty == DIFFICULTY_HARD then
                    counts[DIFFICULTY_HARD] = counts[DIFFICULTY_HARD] + 1
                else
                    counts[DIFFICULTY_NORMAL] = counts[DIFFICULTY_NORMAL] + 1
                end
            end
        end
    end

    availabilityCache = SanitizeAvailabilityCounts(counts)
    SaveAvailabilityCache()
end

local function NotifyCurrencyTrackerAvailabilityChanged()
    local counts = HuntScannerModule:GetAvailabilityCounts()
    local key = tostring(counts.normal) .. "/" .. tostring(counts.hard) .. "/" .. tostring(counts.nightmare)
    if key == lastAvailabilityNotifyKey then
        return
    end

    lastAvailabilityNotifyKey = key
    local tracker = Preydator and Preydator.GetModule and Preydator:GetModule("CurrencyTracker")
    if tracker and type(tracker.QueueRefreshSweep) == "function" then
        tracker:QueueRefreshSweep("HUNT_SCANNER_AVAILABILITY")
    end
end

local function CopyStringList(list)
    local out = {}
    if type(list) ~= "table" then
        return out
    end

    for index, value in ipairs(list) do
        out[index] = SafeToString(value)
    end
    return out
end

local function GetRewardDayKey()
    if type(date) ~= "function" then
        return "unknown"
    end
    return tostring(date("%Y-%m-%d"))
end

local function SaveRewardCaches()
    local storage = GetRewardStorage()
    storage.lastRewardDay = GetRewardDayKey()

    local storedQuestRewards = {}
    for questID, rewards in pairs(rewardCache) do
        if type(questID) == "number" and type(rewards) == "table" then
            storedQuestRewards[tostring(questID)] = CopyStringList(rewards)
        end
    end
    storage.rewardCache = storedQuestRewards

    local storedDifficultyRewards = {}
    for difficulty, rewards in pairs(difficultyRewardCache) do
        if type(difficulty) == "string" and type(rewards) == "table" then
            storedDifficultyRewards[difficulty] = CopyStringList(rewards)
        end
    end
    storage.difficultyRewardCache = storedDifficultyRewards

    storage.questDifficultyByID = storage.questDifficultyByID or {}
    for questID, difficulty in pairs(huntByQuestID) do
        if type(questID) == "number" and type(difficulty) == "table" and type(difficulty.difficulty) == "string" then
            storage.questDifficultyByID[tostring(questID)] = difficulty.difficulty
        end
    end

    SaveAvailabilityCache()
end

local function ClearAllRewardCaches()
    if wipe then
        wipe(rewardCache)
        wipe(difficultyRewardCache)
    else
        for key in pairs(rewardCache) do
            rewardCache[key] = nil
        end
        for key in pairs(difficultyRewardCache) do
            difficultyRewardCache[key] = nil
        end
    end
    SaveRewardCaches()
end

local function ClearRewardCacheForDifficulty(difficulty)
    if type(difficulty) ~= "string" or difficulty == "" then
        return
    end

    difficultyRewardCache[difficulty] = nil
    for questID, hunt in pairs(huntByQuestID) do
        if type(hunt) == "table" and hunt.difficulty == difficulty then
            rewardCache[questID] = nil
        end
    end

    local storage = GetRewardStorage()
    if type(storage.questDifficultyByID) == "table" then
        for questIDText, storedDifficulty in pairs(storage.questDifficultyByID) do
            if storedDifficulty == difficulty then
                local questID = SafeToNumber(questIDText)
                if questID then
                    rewardCache[questID] = nil
                end
            end
        end
    end

    SaveRewardCaches()
end

local function RememberQuestDifficulty(questID, difficulty)
    local id = SafeToNumber(questID)
    if not id or id < 1 or type(difficulty) ~= "string" or difficulty == "" then
        return
    end

    local storage = GetRewardStorage()
    storage.questDifficultyByID[tostring(id)] = NormalizeDifficultyKey(difficulty)
end

local function GetRememberedQuestDifficulty(questID)
    local id = SafeToNumber(questID)
    if not id or id < 1 then
        return nil
    end

    local hunt = huntByQuestID[id]
    if type(hunt) == "table" and type(hunt.difficulty) == "string" and hunt.difficulty ~= "" then
        return NormalizeDifficultyKey(hunt.difficulty)
    end

    local storage = GetRewardStorage()
    local stored = storage.questDifficultyByID and storage.questDifficultyByID[tostring(id)]
    if type(stored) == "string" and stored ~= "" then
        return NormalizeDifficultyKey(stored)
    end

    return nil
end

local function MigrateDifficultyKeysFromLocalizedToCanonical()
    -- Migrate old persisted data from localized keys (L["Normal"], L["Hard"], L["Nightmare"])
    -- to canonical keys ("normal", "hard", "nightmare")
    local storage = GetRewardStorage()
    if not storage or not storage.difficultyRewardCache then
        return
    end

    local oldCache = storage.difficultyRewardCache
    local newCache = {}
    local needsMigration = false

    for key, rewards in pairs(oldCache) do
        -- Detect if this is a localized key (L[...] returns the key name itself in non-enUS locales)
        -- or English strings. Update to canonical form.
        local canonicalKey = key
        if key == L["Normal"] or key == "Normal" then
            canonicalKey = DIFFICULTY_NORMAL
            needsMigration = needsMigration or (key ~= DIFFICULTY_NORMAL)
        elseif key == L["Hard"] or key == "Hard" then
            canonicalKey = DIFFICULTY_HARD
            needsMigration = needsMigration or (key ~= DIFFICULTY_HARD)
        elseif key == L["Nightmare"] or key == "Nightmare" then
            canonicalKey = DIFFICULTY_NIGHTMARE
            needsMigration = needsMigration or (key ~= DIFFICULTY_NIGHTMARE)
        end

        if type(rewards) == "table" then
            local existingRewards = newCache[canonicalKey]
            -- Keep the version with better rewards (higher score)
            if not existingRewards then
                newCache[canonicalKey] = CopyStringList(rewards)
            else
                local newScore = 0
                local existingScore = 0
                for _, r in ipairs(rewards) do
                    if SafeToString(r or "") ~= "" then newScore = newScore + 1 end
                end
                for _, r in ipairs(existingRewards) do
                    if SafeToString(r or "") ~= "" then existingScore = existingScore + 1 end
                end
                if newScore > existingScore then
                    newCache[canonicalKey] = CopyStringList(rewards)
                end
            end
        end
    end

    if needsMigration then
        storage.difficultyRewardCache = newCache
    end

    -- Migrate questDifficultyByID: values from localized to canonical
    if storage.questDifficultyByID then
        for questIDStr, difficulty in pairs(storage.questDifficultyByID) do
            storage.questDifficultyByID[questIDStr] = NormalizeDifficultyKey(difficulty)
        end
    end
end

local function LoadRewardCaches()
    local storage = GetRewardStorage()
    local dayKey = GetRewardDayKey()
    local scopeKey = GetRewardScopeKey()

    if storage.lastRewardDay ~= dayKey or storage.lastRewardScope ~= scopeKey then
        storage.lastRewardDay = dayKey
        storage.lastRewardScope = scopeKey
        storage.rewardCache = {}
        storage.difficultyRewardCache = {}
    end

    -- Migrate old localized keys to canonical format
    MigrateDifficultyKeysFromLocalizedToCanonical()

    if wipe then
        wipe(rewardCache)
        wipe(difficultyRewardCache)
    end

    for questIDText, rewards in pairs(storage.rewardCache or {}) do
        local questID = SafeToNumber(questIDText)
        if questID and type(rewards) == "table" then
            rewardCache[questID] = CopyStringList(rewards)
        end
    end

    for difficulty, rewards in pairs(storage.difficultyRewardCache or {}) do
        if type(difficulty) == "string" and type(rewards) == "table" then
            difficultyRewardCache[difficulty] = CopyStringList(rewards)
        end
    end

    LoadAvailabilityCache()
end

local function GetActivePreyQuestID()
    local state = GetCoreState()
    local activeQuestID = SafeToNumber(state and state.activeQuestID)
    if activeQuestID and activeQuestID > 0 then
        return activeQuestID
    end

    if C_QuestLog and type(C_QuestLog.GetActivePreyQuest) == "function" then
        local rawQuestID = C_QuestLog.GetActivePreyQuest()
        local questID = SafeToNumber(rawQuestID)
        if questID and questID > 0 then
            return questID
        end
    end

    return nil
end

local function GetActivePreyStage()
    local state = GetCoreState()
    local stage = SafeToNumber(state and state.stage)
    if stage and stage >= 1 then
        return stage
    end

    local progressState = SafeToNumber(state and state.progressState)
    if progressState == 0 then return 1 end
    if progressState == 1 then return 2 end
    if progressState == 2 then return 3 end
    if progressState == 3 then return 4 end
    return nil
end

HasActivePreyQuest = function()
    return GetActivePreyQuestID() ~= nil
end

local function ProcessRewardCacheLifecycle()
    local storage = GetRewardStorage()
    local dayKey = GetRewardDayKey()
    local scopeKey = GetRewardScopeKey()
    if storage.lastRewardDay ~= dayKey or storage.lastRewardScope ~= scopeKey then
        ClearAllRewardCaches()
        storage.lastRewardDay = dayKey
        storage.lastRewardScope = scopeKey
    end

    local activeQuestID = GetActivePreyQuestID()
    local activeDifficulty = activeQuestID and GetRememberedQuestDifficulty(activeQuestID) or nil

    if activeQuestID and activeDifficulty then
        RememberQuestDifficulty(activeQuestID, activeDifficulty)
    end

    lastObservedPreyQuestID = activeQuestID
    lastObservedPreyStage = GetActivePreyStage()
end

local function BlockHuntTableWhileActivePrey()
    if not HasActivePreyQuest() then
        return false
    end

    local mission = _G.CovenantMissionFrame
    if mission and mission:IsShown() and type(HideUIPanel) == "function" then
        HideUIPanel(mission)
    end
    HidePanel()

    return true
end

local function SetTextColor(fontString, color)
    if fontString and color then
        fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end
end

local function ParseTargetNPCID()
    if IsInRestrictedInstance() then
        return nil
    end

    if not UnitGUID then
        return nil
    end

    local okGUID, guidValue = pcall(UnitGUID, "target")
    if not okGUID then
        return nil
    end

    if api and type(api.ExtractNPCIDFromGUID) == "function" then
        return api.ExtractNPCIDFromGUID(guidValue)
    end

    local okGUIDString, guidString = pcall(tostring, guidValue)
    if not okGUIDString or type(guidString) ~= "string" or guidString == "" then
        return nil
    end

    local npcID = guidString:match("^[^-]*%-[^-]*%-[^-]*%-[^-]*%-[^-]*%-([^-]+)")
    return SafeToNumber(npcID)
end

local function IsHuntTableContext(options)
    local npcID = ParseTargetNPCID()

    -- Explicit hunt-table gossip option is the primary signal (works before mission frame opens).
    for _, option in ipairs(options or {}) do
        if type(option) == "table" and option.spellID == HUNT_TABLE_CONTROLLER_SPELL_ID then
            return true, npcID
        end
    end

    -- NPC ID alone is not enough: Astalor and similar NPCs have regular gossip/quest
    -- dialogue unrelated to the Hunt Table.  Only treat the NPC as hunt-table context
    -- when the mission frame is already visible (i.e. the Table was actually opened).
    if npcID and HUNT_TABLE_NPC_IDS[npcID] and IsMissionFrameVisible() then
        return true, npcID
    end

    return false, npcID
end

local function CanInspectHuntRewardsNow()
    if IsInRestrictedInstance() then
        return false
    end

    if IsOptionsPreviewVisible() then
        return false
    end

    if not IsMissionFrameVisible() then
        return false
    end

    local mission = _G.CovenantMissionFrame
    local mapTab = mission and mission.MapTab
    if not (mapTab and mapTab.IsShown and mapTab:IsShown()) then
        return false
    end

    if huntInteractionActive ~= true then
        return false
    end

    -- Restrict reward inspection to Hunt Table interaction type only.
    local interactionType = (C_PlayerInteractionManager and C_PlayerInteractionManager.GetInteractionType and C_PlayerInteractionManager.GetInteractionType()) or nil
    if interactionType ~= nil then
        lastInteractionType = SafeToNumber(interactionType)
    end
    if lastInteractionType ~= 3 then
        return false
    end

    return true
end

local function SnapshotHasUsefulData(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    if snapshot.npcID and HUNT_TABLE_NPC_IDS[snapshot.npcID] then
        return true
    end

    local options = snapshot.options or {}
    local detail = snapshot.questDetail or {}

    return #options > 0 or ((SafeToNumber(detail.questID) or 0) > 0)
end

local function CopySnapshot(source)
    if type(source) ~= "table" then
        return nil
    end

    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function BuildRewardSummary(questID)
    local function BuildQuestCurrencyRewardList(_id)
        local rewards = {}

        if not CanInspectHuntRewardsNow() then
            return rewards
        end

        -- Taint hardening: avoid direct quest-reward currency API reads here.
        -- These payloads can carry protected/secret numeric fields and have
        -- previously tainted Blizzard tooltip money arithmetic paths.
        return rewards
    end

    local rewardStyle = GetConfiguredHuntRewardStyle()
    local showRewardIcons = RewardStyleShowsIcons(rewardStyle)

    if type(questID) ~= "number" or questID < 1 then
        return L["Rewards unknown"]
    end

    local cached = rewardCache[questID]
    if type(cached) == "table" then
        local difficulty = GetRememberedQuestDifficulty(questID)
        local sharedRewards = difficulty and difficultyRewardCache[difficulty] or nil
        if type(sharedRewards) == "table" and GetRewardListScore(sharedRewards) > GetRewardListScore(cached) then
            cached = CopyStringList(sharedRewards)
            rewardCache[questID] = cached
            SaveRewardCaches()
        end

        if showRewardIcons and not RewardListHasIconTags(cached) then
            local upgraded = BuildQuestCurrencyRewardList(questID)
            if #upgraded > 0 then
                cached = upgraded
                rewardCache[questID] = CopyStringList(upgraded)
                SaveRewardCaches()
            end
        end

        if #cached > 0 then
            return FormatRewardEntriesForStyle(cached, rewardStyle)
        end
        return L["Reward data pending"]
    end

    local difficulty = GetRememberedQuestDifficulty(questID)
    local sharedRewards = difficulty and difficultyRewardCache[difficulty] or nil
    if type(sharedRewards) == "table" then
        local effectiveRewards = sharedRewards
        if showRewardIcons and not RewardListHasIconTags(sharedRewards) then
            local upgraded = BuildQuestCurrencyRewardList(questID)
            if #upgraded > 0 then
                effectiveRewards = upgraded
            end
        end

        rewardCache[questID] = CopyStringList(effectiveRewards)
        SaveRewardCaches()
        if #effectiveRewards > 0 then
            return FormatRewardEntriesForStyle(effectiveRewards, rewardStyle)
        end
        return L["No tracked rewards"]
    end

    local rewards = BuildQuestCurrencyRewardList(questID)

    if #rewards == 0 then
        return L["Reward data pending"]
    end

    rewardCache[questID] = CopyStringList(rewards)
    SaveRewardCaches()
    return FormatRewardEntriesForStyle(rewards, rewardStyle)
end

IsMissionFrameVisible = function()
    local frame = _G.CovenantMissionFrame
    return frame and frame:IsShown() == true
end

local function HasVisibleHuntAnchor()
    if IsMissionFrameVisible() then
        return true
    end

    if _G.GossipFrame and _G.GossipFrame.IsShown and _G.GossipFrame:IsShown() then
        return true
    end

    if _G.QuestFrame and _G.QuestFrame.IsShown and _G.QuestFrame:IsShown() then
        return true
    end

    return false
end

local function ParseDifficulty(questID, description, title)
    local function BuildDifficultyTokens()
        local tokens = {}
        local function AddToken(key, value)
            local token = NormalizeToken(value)
            if token and token ~= "" then
                tokens[#tokens + 1] = { key = key, token = token }
            end
        end

        AddToken(DIFFICULTY_NIGHTMARE, "nightmare")
        AddToken(DIFFICULTY_HARD, "hard")
        AddToken(DIFFICULTY_NORMAL, "normal")
        AddToken(DIFFICULTY_NIGHTMARE, L and L["Nightmare"])
        AddToken(DIFFICULTY_HARD, L and L["Hard"])
        AddToken(DIFFICULTY_NORMAL, L and L["Normal"])

        return tokens
    end

    local difficultyTokens = BuildDifficultyTokens()

    local function DetectSingleDifficultyFromText(value)
        local normalized = NormalizeToken(value)
        if not normalized then
            return nil
        end

        local matched = {}
        for _, entry in ipairs(difficultyTokens) do
            if entry.token and SafeFindLiteral(normalized, entry.token) then
                matched[entry.key] = true
            end
        end

        local count = 0
        local winner = nil
        for _, key in ipairs({ DIFFICULTY_NIGHTMARE, DIFFICULTY_HARD, DIFFICULTY_NORMAL }) do
            if matched[key] then
                count = count + 1
                winner = key
            end
        end

        if count == 1 then
            return winner
        end

        return nil
    end

    local function DetectDifficultyFromParenSuffix(value)
        if type(value) ~= "string" or value == "" then
            return nil
        end

        local suffix = string.match(value, "%s*(%b())%s*$")
        if not suffix then
            return nil
        end

        local inner = string.sub(suffix, 2, -2)
        return DetectSingleDifficultyFromText(inner)
    end

    local id = SafeToNumber(questID)

    -- Prefer a previously confirmed questID->difficulty mapping. This is
    -- locale-neutral and avoids reclassifying from noisy pin text each refresh.
    if id and id > 0 then
        local remembered = GetRememberedQuestDifficulty(id)
        if remembered then
            return remembered, true
        end
    end

    local candidates = {}

    -- Prefer authoritative quest title text when available.
    if id and id > 0 and C_QuestLog and type(C_QuestLog.GetTitleForQuestID) == "function" then
        local okTitle, questTitle = pcall(C_QuestLog.GetTitleForQuestID, id)
        if okTitle and type(questTitle) == "string" and questTitle ~= "" then
            candidates[#candidates + 1] = questTitle
        end
    end

    if type(title) == "string" and title ~= "" then
        candidates[#candidates + 1] = title
    end

    if type(description) == "string" and description ~= "" then
        candidates[#candidates + 1] = description
        for line in string.gmatch(description, "([^\n\r]+)") do
            if type(line) == "string" and line ~= "" then
                candidates[#candidates + 1] = line
            end
        end
    end

    for _, text in ipairs(candidates) do
        local difficulty = DetectDifficultyFromParenSuffix(text)
        if difficulty then
            return difficulty, true
        end
    end

    for _, text in ipairs(candidates) do
        local difficulty = DetectSingleDifficultyFromText(text)
        if difficulty then
            return difficulty, true
        end
    end

    return DIFFICULTY_NORMAL, false
end

local function InferZoneFromCoords(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end

    -- Hardcoded coordinate buckets derived from all 12 hunt quest pins.
    -- Threshold calibration: Harandar (northeast: x>0.78), Voidstorm (southeast: x>0.50 && y<0.30),
    -- Eversong (southwest: x<0.35), Zul'Aman (northwest/center-high: else).
    if x > 0.78 then
        return "Harandar"
    end

    if x > 0.50 and y < 0.30 then
        return "Voidstorm"
    end

    if x < 0.35 then
        return "Eversong Woods"
    end

    return "Zul'Aman"
end

local function GetInferredZoneMapID(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then
        return nil
    end

    return INFERRED_HUNT_ZONE_MAP_IDS[zoneName]
end

local function GetAdventureMapID()
    local mission = _G.CovenantMissionFrame
    local mapTab = mission and mission.MapTab
    if not mapTab then
        return nil
    end
    local sc = mapTab.ScrollContainer
    if sc and type(sc.GetMapID) == "function" then
        return sc:GetMapID()
    end
    local mc = mapTab.MapCanvas
    if mc and type(mc.GetMapID) == "function" then
        return mc:GetMapID()
    end
    return nil
end

local function GetAdventurePinPool()
    local mission = _G.CovenantMissionFrame
    local mapTab = mission and mission.MapTab
    local pinPools = mapTab and mapTab.pinPools
    return pinPools and pinPools[ADVENTURE_PIN_POOL_TEMPLATE]
end

local function FindPinByQuestID(questID)
    local pool = GetAdventurePinPool()
    if not pool then
        return nil
    end

    for pin in pool:EnumerateActive() do
        if SafeToNumber(pin and pin.questID) == questID then
            return pin
        end
    end

    return nil
end

local function OpenMapQuestDialog(questID)
    local id = SafeToNumber(questID)
    if not id or id < 1 then
        return false
    end

    local now = GetTime and GetTime() or 0
    if lastOpenQuestID == id and (now - (lastOpenAt or 0)) < 0.15 then
        return true
    end

    local dialog = _G.AdventureMapQuestChoiceDialog
    if dialog and dialog:IsShown() and lastOpenQuestID == id then
        dialog:Hide()
        local mission = _G.CovenantMissionFrame
        local mapTab = mission and mission.MapTab
        local sc = mapTab and mapTab.ScrollContainer
        local mapCanvas = mapTab and mapTab.MapCanvas
        if sc and type(sc.ResetZoom) == "function" then
            pcall(function() sc:ResetZoom() end)
        end
        if mapCanvas and type(mapCanvas.ResetZoom) == "function" then
            pcall(function() mapCanvas:ResetZoom() end)
        end
        lastOpenQuestID = nil
        lastOpenAt = 0
        return true
    end

    if HasActivePreyQuest() and GetActivePreyQuestID() ~= id then
        return false
    end

    local mission = _G.CovenantMissionFrame
    if not (mission and mission:IsShown()) then
        return false
    end

    local pin = FindPinByQuestID(id)
    if not pin then
        return false
    end

    local provider = type(pin.GetDataProvider) == "function" and pin:GetDataProvider() or nil
    if provider and type(provider.OnQuestOfferPinClicked) == "function" then
        local difficulty = GetRememberedQuestDifficulty(id)
        if difficulty then
            RememberQuestDifficulty(id, difficulty)
        end
        provider:OnQuestOfferPinClicked(pin)
        lastOpenQuestID = id
        lastOpenAt = now
        return true
    end

    if dialog and type(dialog.ShowWithQuest) == "function" then
        dialog:SetAlpha(1)
        dialog:ClearAllPoints()
        dialog:SetPoint("CENTER", mission, "CENTER")
        dialog:ShowWithQuest(mission, pin, id)
        local difficulty = GetRememberedQuestDifficulty(id)
        if difficulty then
            RememberQuestDifficulty(id, difficulty)
        end
        lastOpenQuestID = id
        lastOpenAt = now
        return true
    end

    return false
end

local function AcceptMapQuest(questID)
    local id = SafeToNumber(questID)
    if not id or id < 1 then
        return false
    end

    if HasActivePreyQuest() and GetActivePreyQuestID() ~= id then
        return false
    end

    local mission = _G.CovenantMissionFrame
    local dialog = _G.AdventureMapQuestChoiceDialog
    local pin = FindPinByQuestID(id)
    if not (mission and mission:IsShown() and dialog and type(dialog.ShowWithQuest) == "function" and type(dialog.AcceptQuest) == "function" and pin) then
        return false
    end

    local difficulty = GetRememberedQuestDifficulty(id)
    if difficulty then
        RememberQuestDifficulty(id, difficulty)
    end

    local prevAlpha = dialog:GetAlpha()
    local dialogPoint = { dialog:GetPoint(1) }
    dialog:SetAlpha(0)
    dialog:ClearAllPoints()
    dialog:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -4000, 4000)
    dialog:Hide()
    dialog:ShowWithQuest(mission, pin, id)

    local ok = pcall(function()
        dialog:AcceptQuest()
    end)
    dialog:Hide()
    dialog:SetAlpha(prevAlpha)
    if dialogPoint[1] then
        dialog:ClearAllPoints()
        dialog:SetPoint(dialogPoint[1], dialogPoint[2], dialogPoint[3], dialogPoint[4], dialogPoint[5])
    end

    lastOpenQuestID = nil
    lastOpenAt = 0
    return ok == true
end

local function RefreshHuntsFromPins()
    local pool = GetAdventurePinPool()
    if not pool then
        if wipe then
            wipe(liveHunts)
            wipe(huntByQuestID)
        else
            for i = #liveHunts, 1, -1 do
                liveHunts[i] = nil
            end
            for questID in pairs(huntByQuestID) do
                huntByQuestID[questID] = nil
            end
        end
        return liveHunts
    end

    local nextHunts = {}
    local seenQuestIDs = {}
    local previousCount = #liveHunts
    local adventureMapID = SafeToNumber(GetAdventureMapID())
    if adventureMapID then
        cachedAdventureMapID = adventureMapID
    end

    for pin in pool:EnumerateActive() do
        local questID = SafeToNumber(pin and pin.questID)
        local title = pin and pin.title
        if questID and questID > 0 and type(title) == "string" and title ~= "" then
            seenQuestIDs[questID] = true
            local nx, ny = pin.normalizedX, pin.normalizedY
            -- Cache raw coords so zone can be resolved later even when map is closed.
            if type(nx) == "number" and type(ny) == "number" then
                questCoords[questID] = { nx = nx, ny = ny }
            end
            -- Primary: ask Blizzard directly for the zone map ID from quest metadata.
            -- This works for world/task quests before acceptance and is not affected
            -- by pin coordinate precision or zone-boundary ambiguity.
            local zoneMapID = nil
            local zoneSource = "infer"
            if C_TaskQuest and type(C_TaskQuest.GetQuestZoneID) == "function" then
                local okTaskZone, rawTaskZone = pcall(C_TaskQuest.GetQuestZoneID, questID)
                zoneMapID = okTaskZone and SafeToNumber(rawTaskZone) or nil
                if zoneMapID then zoneSource = "task" end
            end
            -- Fallback: derive zone map ID from pin position on the adventure map.
            if not zoneMapID and (adventureMapID or cachedAdventureMapID) and C_Map and C_Map.GetMapInfoAtPosition then
                local mapForLookup = adventureMapID or cachedAdventureMapID
                local okZoneInfo, zoneInfo = pcall(C_Map.GetMapInfoAtPosition, mapForLookup, nx or 0, ny or 0)
                zoneInfo = okZoneInfo and zoneInfo or nil
                zoneMapID = SafeToNumber(zoneInfo and zoneInfo.mapID)
                if zoneMapID then zoneSource = "mapapi" end
            end
            -- Resolve authoritative zone name from the map ID, then cache both.
            local zoneName = nil
            if zoneMapID then
                questZoneCache[questID] = zoneMapID
                if C_Map and C_Map.GetMapInfo then
                    local okInfo, mapInfo = pcall(C_Map.GetMapInfo, zoneMapID)
                    if okInfo and mapInfo and type(mapInfo.name) == "string" and mapInfo.name ~= "" then
                        zoneName = mapInfo.name
                        questZoneNameCache[questID] = zoneName
                    end
                end
            end
            if not zoneName then
                zoneName = questZoneNameCache[questID] or InferZoneFromCoords(nx, ny)
            end
            if not zoneMapID then
                zoneMapID = GetInferredZoneMapID(zoneName)
                if zoneMapID then
                    questZoneCache[questID] = zoneMapID
                    if zoneName and zoneName ~= "" then
                        questZoneNameCache[questID] = zoneName
                    end
                    zoneSource = "infer"
                end
            end
            local parsedDifficulty, parsedConfirmed = ParseDifficulty(questID, pin and pin.description, title)
            nextHunts[#nextHunts + 1] = {
                questID = questID,
                title = title,
                difficulty = parsedDifficulty,
                zone = zoneName,
                zoneMapID = zoneMapID,
                nx = nx,
                ny = ny,
                zoneSource = zoneSource,
            }
            if parsedConfirmed == true then
                RememberQuestDifficulty(questID, nextHunts[#nextHunts].difficulty)
            end
        end
    end

    -- The mission frame pin pool can be available before pins hydrate.
    -- Keep the previous snapshot in this transient state so availability
    -- counts do not flash to zero and then rebound a few seconds later.
    if #nextHunts == 0 and previousCount > 0 and (IsMissionFrameVisible() or huntInteractionActive or IsOptionsPreviewVisible()) then
        return liveHunts
    end

    for questID in pairs(rewardCache) do
        if not seenQuestIDs[questID] then
            rewardCache[questID] = nil
            rewardRetryCount[questID] = nil
        end
    end

    if wipe then
        wipe(liveHunts)
        wipe(huntByQuestID)
    else
        for i = #liveHunts, 1, -1 do
            liveHunts[i] = nil
        end
        for questID in pairs(huntByQuestID) do
            huntByQuestID[questID] = nil
        end
    end
    for _, hunt in ipairs(nextHunts) do
        liveHunts[#liveHunts + 1] = hunt
        if type(hunt.questID) == "number" then
            huntByQuestID[hunt.questID] = hunt
            local cachedRewards = rewardCache[hunt.questID]
            if IsRewardCacheMissingOrEmpty(cachedRewards) and type(difficultyRewardCache[hunt.difficulty]) == "table" then
                rewardCache[hunt.questID] = CopyStringList(difficultyRewardCache[hunt.difficulty])
            end
        end
    end

    UpdateAvailabilityCacheFromHunts(liveHunts)

    SaveRewardCaches()

    return liveHunts
end

local function SnapshotDialogRewards()
    local dialog = _G.AdventureMapQuestChoiceDialog
    if not (dialog and dialog.rewardPool) then
        return {}, 0, 0
    end

    local function IsNumericRewardText(text)
        local safeText = SafeToString(text)
        if safeText == "" or safeText == "<protected string>" then
            return false
        end

        local normalized = safeText:gsub("[%s,%.]", "")
        return normalized:match("^%d+$") ~= nil
    end

    local function NormalizeRewardName(name)
        local safeName = SafeToString(name)
        if safeName == "" or safeName == "<protected string>" then
            return nil
        end

        if IsNumericRewardText(safeName) then
            return safeName .. " XP"
        end
        return safeName
    end

    local function ExtractRewardIcon(reward)
        if type(reward) ~= "table" then
            return nil
        end

        local function GetSafeIconToken(value)
            if type(value) == "string" and value ~= "" then
                return value
            end

            if type(value) == "number" then
                local token = SafeToString(value)
                if token:match("^%d+$") then
                    return token
                end
            end

            return nil
        end

        local iconKeys = {
            "Icon", "icon", "IconTexture", "iconTexture", "ItemIcon", "itemIcon", "texture", "Texture",
        }

        for _, key in ipairs(iconKeys) do
            local value = SafeTableField(reward, key)
            local iconToken = GetSafeIconToken(value)
            if iconToken then
                return iconToken
            end
            if type(value) == "table" then
                local tex = SafeTableMethodValue(value, "GetTexture")
                iconToken = GetSafeIconToken(tex)
                if iconToken then
                    return iconToken
                end

                local atlas = SafeTableMethodValue(value, "GetAtlas")
                if type(atlas) == "string" and atlas ~= "" then
                    return "atlas:" .. atlas
                end
            end
        end

        return nil
    end

    local function ExtractRewardName(reward)
        if type(reward) ~= "table" then
            return nil
        end

        local nameKeys = { "Name", "name", "Label", "label", "Text", "text", "Title", "title" }
        for _, key in ipairs(nameKeys) do
            local value = SafeTableField(reward, key)
            if type(value) == "string" and value ~= "" then
                local safeValue = SafeToString(value)
                if safeValue ~= "" and safeValue ~= "<protected string>" then
                    return safeValue
                end
            end
            if type(value) == "table" then
                local text = SafeTableMethodValue(value, "GetText")
                if type(text) == "string" and text ~= "" then
                    local safeText = SafeToString(text)
                    if safeText ~= "" and safeText ~= "<protected string>" then
                        return safeText
                    end
                end
            end
        end

        return nil
    end

    local function ExtractRewardCount(reward)
        if type(reward) ~= "table" then
            return nil
        end

        local countKeys = { "Count", "count", "Quantity", "quantity", "Amount", "amount", "StackSize", "stackSize", "NumItems", "numItems" }
        for _, key in ipairs(countKeys) do
            local value = SafeTableField(reward, key)
            if type(value) == "string" and value ~= "" then
                local safeValue = SafeToString(value)
                if safeValue ~= "" and safeValue ~= "<protected string>" then
                    return safeValue
                end
            end
            if type(value) == "table" then
                local text = SafeTableMethodValue(value, "GetText")
                if type(text) == "string" and text ~= "" then
                    local safeText = SafeToString(text)
                    if safeText ~= "" and safeText ~= "<protected string>" then
                        return safeText
                    end
                end
            end
        end

        local textKeys = { "CountText", "countText", "AmountText", "amountText", "Text", "text" }
        for _, key in ipairs(textKeys) do
            local value = SafeTableField(reward, key)
            if type(value) == "string" and value ~= "" then
                local safeValue = SafeToString(value)
                if safeValue ~= "" and safeValue ~= "<protected string>" then
                    return safeValue
                end
            end
            if type(value) == "table" then
                local text = SafeTableMethodValue(value, "GetText")
                if type(text) == "string" and text ~= "" then
                    local safeText = SafeToString(text)
                    if safeText ~= "" and safeText ~= "<protected string>" then
                        return safeText
                    end
                end
            end
        end

        return nil
    end

    local rewards = {}
    local activeCount = 0
    local namedCount = 0
    for reward in dialog.rewardPool:EnumerateActive() do
        activeCount = activeCount + 1
        local name = ExtractRewardName(reward)
        local count = ExtractRewardCount(reward)
        local icon = ExtractRewardIcon(reward)

        if type(name) == "string" and name ~= "" then
            namedCount = namedCount + 1
            name = NormalizeRewardName(name)
            local iconTag = ""
            if type(icon) == "string" and icon ~= "" then
                if icon:sub(1, 6) == "atlas:" and #icon > 6 then
                    iconTag = "|A" .. icon:sub(7) .. ":14:14|a "
                else
                    iconTag = "|T" .. icon .. ":14:14:0:0|t "
                end
            end

            if type(count) == "string" and count ~= "" and count ~= "1" then
                rewards[#rewards + 1] = iconTag .. name .. " x" .. count
            else
                rewards[#rewards + 1] = iconTag .. name
            end
        end
    end

    return rewards, activeCount, namedCount
end

local function WarmRewardCacheFromPins()
    -- Hotfix: reward-frame introspection has repeatedly tainted Blizzard tooltip/money
    -- arithmetic paths (secret number values). Keep this disabled until rewards can be
    -- sourced from non-widget APIs only.
    if not HUNT_REWARD_WARMING_ENABLED then
        return
    end

    if not CanInspectHuntRewardsNow() then
        return
    end

    if rewardWarmCancel then
        return
    end

    local mission = _G.CovenantMissionFrame
    local dialog = _G.AdventureMapQuestChoiceDialog
    if not (mission and mission:IsShown() and dialog and type(dialog.ShowWithQuest) == "function") then
        return
    end

    local queue = {}
    local representativeByDifficulty = {}
    local rewardStyle = GetConfiguredHuntRewardStyle()
    local wantsIcons = RewardStyleShowsIcons(rewardStyle)
    for _, hunt in ipairs(liveHunts) do
        local cachedRewards = rewardCache[hunt.questID]
        local cacheMissingOrEmpty = IsRewardCacheMissingOrEmpty(cachedRewards)
        local cacheMissingIcons = wantsIcons
            and type(cachedRewards) == "table"
            and #cachedRewards > 0
            and not RewardListHasIconTags(cachedRewards)
        if type(hunt.questID) == "number" and (cacheMissingOrEmpty or cacheMissingIcons) then
            local difficulty = hunt.difficulty or DIFFICULTY_NORMAL
            if representativeByDifficulty[difficulty] == nil then
                representativeByDifficulty[difficulty] = {
                    questID = hunt.questID,
                    difficulty = difficulty,
                    mode = "quest",
                }
            end
        end
    end

    for _, difficulty in ipairs({ DIFFICULTY_NORMAL, DIFFICULTY_HARD, DIFFICULTY_NIGHTMARE }) do
        if representativeByDifficulty[difficulty] then
            queue[#queue + 1] = representativeByDifficulty[difficulty]
            representativeByDifficulty[difficulty] = nil
        end
    end

    for _, entry in pairs(representativeByDifficulty) do
        queue[#queue + 1] = entry
    end

    if #queue == 0 then
        return
    end

    local cancelled = false
    local ticker = nil
    local currentIndex = 1
    local prevAlpha = dialog:GetAlpha()

    local elapsed = 0
    local stablePolls = 0
    local lastSignature = nil

    local function CancelTicker()
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
    end

    local StartCurrentQuest

    local function FinishCurrentQuest(rewards, timedOutEmpty)
        CancelTicker()
        dialog:Hide()
        dialog:SetAlpha(prevAlpha)

        local entry = queue[currentIndex]
        local questID = entry and entry.questID
        if questID then
            if timedOutEmpty then
                rewardRetryCount[questID] = (rewardRetryCount[questID] or 0) + 1
                if rewardRetryCount[questID] >= REWARD_MAX_EMPTY_RETRIES then
                    rewardCache[questID] = {}
                else
                    rewardCache[questID] = nil
                end
            else
                rewardRetryCount[questID] = nil
                rewardCache[questID] = CopyStringList(rewards)

                if entry and entry.difficulty then
                    local existingDifficultyRewards = difficultyRewardCache[entry.difficulty]
                    if ShouldReplaceRewardList(rewards, existingDifficultyRewards) then
                        difficultyRewardCache[entry.difficulty] = CopyStringList(rewards)
                    end

                    local bestForDifficulty = difficultyRewardCache[entry.difficulty]
                    if type(bestForDifficulty) == "table" then
                        for _, hunt in ipairs(liveHunts) do
                            if hunt.difficulty == entry.difficulty and type(hunt.questID) == "number" then
                                local existingQuestRewards = rewardCache[hunt.questID]
                                if ShouldReplaceRewardList(bestForDifficulty, existingQuestRewards) then
                                    rewardCache[hunt.questID] = CopyStringList(bestForDifficulty)
                                end
                            end
                        end
                    end
                end
            end

            SaveRewardCaches()
        end

        currentIndex = currentIndex + 1
        if currentIndex > #queue then
            rewardWarmCancel = nil
            if HuntScannerModule and type(HuntScannerModule.RefreshNow) == "function" then
                HuntScannerModule:RefreshNow()
            end
            return
        end

        C_Timer.After(0.05, function()
            if cancelled then
                return
            end
            StartCurrentQuest()
        end)
    end

    StartCurrentQuest = function()
        if cancelled then
            return
        end

        elapsed = 0
        stablePolls = 0
        lastSignature = nil

        local entry = queue[currentIndex]
        local pin = entry and FindPinByQuestID(entry.questID)
        if not pin then
            FinishCurrentQuest({}, false)
            return
        end

        local dialogPoint = { dialog:GetPoint(1) }
        dialog:SetAlpha(0)
        dialog:ClearAllPoints()
        dialog:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -4000, 4000)
        dialog:Hide()
        dialog:ShowWithQuest(mission, pin, entry.questID)

        if dialogPoint[1] then
            dialog:ClearAllPoints()
            dialog:SetPoint(dialogPoint[1], dialogPoint[2], dialogPoint[3], dialogPoint[4], dialogPoint[5])
        end

        ticker = C_Timer.NewTicker(REWARD_POLL_INTERVAL, function()
            if cancelled then
                return
            end

            elapsed = elapsed + REWARD_POLL_INTERVAL
            local rewards, activeCount, namedCount = SnapshotDialogRewards()
            local signature = table.concat(rewards, "||") .. "|a=" .. tostring(activeCount) .. "|n=" .. tostring(namedCount)

            if activeCount > 0 and namedCount < activeCount and elapsed < REWARD_TIMEOUT_SECONDS then
                stablePolls = 0
                lastSignature = signature
            elseif #rewards > 0 and signature == lastSignature and elapsed >= REWARD_MIN_STABLE_SECONDS then
                stablePolls = stablePolls + 1
                if stablePolls >= REWARD_STABLE_POLLS then
                    FinishCurrentQuest(rewards, false)
                    return
                end
            else
                stablePolls = 0
                lastSignature = signature
            end

            if elapsed >= REWARD_TIMEOUT_SECONDS then
                FinishCurrentQuest(rewards, #rewards == 0)
            end
        end)
    end

    rewardWarmCancel = function()
        cancelled = true
        CancelTicker()
        dialog:Hide()
        dialog:SetAlpha(prevAlpha)
        rewardWarmCancel = nil
    end

    StartCurrentQuest()
end

local function CaptureSnapshot(options, npcID)
    local interactionType = (C_PlayerInteractionManager and C_PlayerInteractionManager.GetInteractionType and C_PlayerInteractionManager.GetInteractionType()) or nil
    if interactionType ~= nil then
        lastInteractionType = SafeToNumber(interactionType) or lastInteractionType
    else
        interactionType = lastInteractionType
    end

    local mapHuntCount = #liveHunts
    local mapDifficultyCounts = {}
    for _, hunt in ipairs(liveHunts) do
        local difficulty = hunt and hunt.difficulty or DIFFICULTY_NORMAL
        mapDifficultyCounts[difficulty] = (mapDifficultyCounts[difficulty] or 0) + 1
    end

    local mapRewardCachedCount = 0
    local mapRewardPendingCount = 0
    for _, hunt in ipairs(liveHunts) do
        local questID = hunt and hunt.questID
        if type(questID) == "number" then
            if type(rewardCache[questID]) == "table" then
                mapRewardCachedCount = mapRewardCachedCount + 1
            else
                mapRewardPendingCount = mapRewardPendingCount + 1
            end
        end
    end

    local mapPreview = {}
    for i = 1, #liveHunts do
        local hunt = liveHunts[i]
        mapPreview[#mapPreview + 1] = {
            questID = hunt.questID,
            title = hunt.title,
            difficulty = hunt.difficulty,
            zone = hunt.zone,
            zoneSource = hunt.zoneSource,
            nx = hunt.nx,
            ny = hunt.ny,
        }
    end

    local snapshot = {
        time = GetTime and GetTime() or 0,
        npcID = npcID,
        options = options,
        interactionType = interactionType,
        mapState = {
            missionVisible = IsMissionFrameVisible(),
            hunts = mapHuntCount,
            difficultyCounts = mapDifficultyCounts,
            cachedRewards = mapRewardCachedCount,
            pendingRewards = mapRewardPendingCount,
            warming = rewardWarmCancel ~= nil,
            preview = mapPreview,
        },
        questDetail = {
            questID = (GetQuestID and GetQuestID()) or nil,
            title = (GetTitleText and GetTitleText()) or nil,
            objective = (GetObjectiveText and GetObjectiveText()) or nil,
            choiceCount = (GetNumQuestChoices and GetNumQuestChoices()) or nil,
        },
    }

    lastSnapshot = snapshot
    if SnapshotHasUsefulData(snapshot) then
        lastRichSnapshot = CopySnapshot(snapshot)
    end
end

local function RecordEvent(event, ...)
    if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        local interaction = SafeToNumber(select(1, ...))
        if interaction then
            lastInteractionType = interaction
        end
    end

    recentEvents[#recentEvents + 1] = {
        t = GetTime and GetTime() or 0,
        event = event,
        a1 = SafeToString(select(1, ...)),
        a2 = SafeToString(select(2, ...)),
        a3 = SafeToString(select(3, ...)),
    }

    while #recentEvents > 30 do
        table.remove(recentEvents, 1)
    end
end

local function BuildDebugSnapshotLines(snapshot)
    local lines = {}
    lines[#lines + 1] = "Preydator HuntDebug: NPC=" .. SafeToString(snapshot.npcID) .. " time=" .. SafeToString(snapshot.time)
    lines[#lines + 1] = "Preydator HuntDebug: interactionType=" .. SafeToString(snapshot.interactionType)
    lines[#lines + 1] = "Preydator HuntDebug: previewEnabled=" .. SafeToString(IsOptionsPreviewVisible())
        .. " previewSetting=" .. SafeToString(GetSettings() and GetSettings().huntScannerPreviewInOptions)
        .. " hasAnchor=" .. SafeToString(HasVisibleHuntAnchor())
        .. " panelShown=" .. SafeToString(panelFrame and panelFrame.IsShown and panelFrame:IsShown() == true)

    local options = snapshot.options or {}
    lines[#lines + 1] = "Preydator HuntDebug: options=" .. SafeToString(#options)
    for index, option in ipairs(options) do
        local text = option and (option.name or option.text) or "?"
        local spellID = option and option.spellID
        lines[#lines + 1] = "  [O" .. SafeToString(index) .. "] spellID=" .. SafeToString(spellID) .. " text=" .. SafeToString(text)
    end

    local mapState = snapshot.mapState or {}
    lines[#lines + 1] = "Preydator HuntDebug: mapHunts=" .. SafeToString(mapState.hunts or 0)
        .. " cachedRewards=" .. SafeToString(mapState.cachedRewards or 0)
        .. " pendingRewards=" .. SafeToString(mapState.pendingRewards or 0)
        .. " warming=" .. SafeToString(mapState.warming)
        .. " mapVisible=" .. SafeToString(mapState.missionVisible)

    local idHits = SafeToNumber(achievementRouteStats.idHits) or 0
    local fallbackHits = SafeToNumber(achievementRouteStats.fallbackHits) or 0
    local misses = SafeToNumber(achievementRouteStats.misses) or 0
    local total = idHits + fallbackHits + misses
    local idPct = total > 0 and (idHits / total) * 100 or 0
    local fallbackPct = total > 0 and (fallbackHits / total) * 100 or 0
    lines[#lines + 1] = string.format(
        "Preydator HuntDebug: achievementRoute id=%d fallback=%d miss=%d total=%d idPct=%.1f fallbackPct=%.1f",
        idHits,
        fallbackHits,
        misses,
        total,
        idPct,
        fallbackPct
    )

    if type(mapState.difficultyCounts) == "table" then
        lines[#lines + 1] = "Preydator HuntDebug: mapDiffs normal=" .. SafeToString(mapState.difficultyCounts[DIFFICULTY_NORMAL] or 0)
            .. " hard=" .. SafeToString(mapState.difficultyCounts[DIFFICULTY_HARD] or 0)
            .. " nightmare=" .. SafeToString(mapState.difficultyCounts[DIFFICULTY_NIGHTMARE] or 0)
    end

    for index, hunt in ipairs(mapState.preview or {}) do
        lines[#lines + 1] = "  [M" .. SafeToString(index) .. "] questID=" .. SafeToString(hunt.questID)
            .. " title=" .. SafeToString(hunt.title)
            .. " diff=" .. SafeToString(hunt.difficulty)
            .. " zone=" .. SafeToString(hunt.zone)
            .. " src=" .. SafeToString(hunt.zoneSource)
            .. " nx=" .. SafeToString(hunt.nx)
            .. " ny=" .. SafeToString(hunt.ny)
    end

    local detail = snapshot.questDetail or {}
    lines[#lines + 1] = "Preydator HuntDebug: questDetail questID=" .. SafeToString(detail.questID)
        .. " title=" .. SafeToString(detail.title)
        .. " choices=" .. SafeToString(detail.choiceCount)

    if type(detail.objective) == "string" and detail.objective ~= "" then
        lines[#lines + 1] = "Preydator HuntDebug: questObjective=" .. SafeToString(detail.objective)
    end

    if #recentEvents > 0 then
        lines[#lines + 1] = "Preydator HuntDebug: recentEvents=" .. SafeToString(#recentEvents)
        local startIndex = math.max(1, #recentEvents - 9)
        for i = startIndex, #recentEvents do
            local e = recentEvents[i]
            lines[#lines + 1] = string.format("  [E] %.3f %s | %s | %s | %s", SafeToNumber(e.t) or 0, SafeToString(e.event), SafeToString(e.a1), SafeToString(e.a2), SafeToString(e.a3))
        end
    end

    return lines
end

local function SendLinesToBugSack(lines)
    if type(lines) ~= "table" or #lines == 0 then
        return false, "empty report"
    end

    local safeLines = {}
    for index, line in ipairs(lines) do
        safeLines[index] = SafeToString(line)
    end

    local payload = table.concat(safeLines, "\n")
    lastDebugPayload = payload

    _G.PreydatorLastHuntDebugReport = payload

    if type(geterrorhandler) ~= "function" then
        return false, "geterrorhandler unavailable"
    end

    local okHandler, handler = pcall(geterrorhandler)
    if not okHandler or type(handler) ~= "function" then
        return false, "error handler unavailable"
    end

    local header = "Preydator HuntDebug Report"
    local chunkSize = 1800
    local length = #payload
    local chunks = math.max(1, math.ceil(length / chunkSize))

    for index = 1, chunks do
        local startPos = ((index - 1) * chunkSize) + 1
        local endPos = math.min(index * chunkSize, length)
        local chunk = string.sub(payload, startPos, endPos)
        local okSend = pcall(function()
            handler(string.format("%s [%d/%d]\n%s", header, index, chunks, chunk))
        end)
        if not okSend then
            return false, "handler failed on chunk " .. tostring(index)
        end
    end

    return true, "sent"
end

local function RefreshDebugSnapshotFromLiveAPI()
    if IsInRestrictedInstance() then
        return false
    end

    local options = GetGossipOptionsSafe()

    local _, npcID = IsHuntTableContext(options)
    CaptureSnapshot(options, npcID)

    return (npcID ~= nil) or (#options > 0)
end

local function SelectBestSnapshotForDebug()
    if SnapshotHasUsefulData(lastSnapshot) then
        return lastSnapshot
    end

    if SnapshotHasUsefulData(lastRichSnapshot) then
        return lastRichSnapshot
    end

    return lastSnapshot
end

local function EnsurePanel()
    if panelFrame then
        return panelFrame
    end

    local frame = CreateFrame("Frame", "PreydatorHuntScannerPanel", UIParent, "BackdropTemplate")
    local panelWidth, panelHeight, _, panelScale = GetPanelConfig()
    frame:SetSize(panelWidth, panelHeight)
    frame:SetScale(panelScale)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    local header = frame:CreateTexture(nil, "BORDER")
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, 0)
    header:SetHeight(28)
    frame.PreydatorHeader = header

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    title:SetText(L["Preydator Hunt Tracker"])
    frame.PreydatorTitle = title

    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    subtitle:SetText("")
    frame.PreydatorSubtitle = subtitle

    local groupButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    groupButton:SetSize(68, 18)
    groupButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -80, -7)
    groupButton:SetText(L["Group"])
    groupButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if not settings then
            return
        end
        local order = { "none", "difficulty", "zone" }
        local nextIndex = 1
        for index, key in ipairs(order) do
            if settings.huntScannerGroupBy == key then
                nextIndex = (index % #order) + 1
                break
            end
        end
        settings.huntScannerGroupBy = order[nextIndex]
        HandleInteractionSnapshot()
    end)

    local sortButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    sortButton:SetSize(56, 18)
    sortButton:SetPoint("LEFT", groupButton, "RIGHT", 4, 0)
    sortButton:SetText(L["Sort"])
    sortButton:SetScript("OnClick", function()
        local settings = GetSettings()
        if not settings then
            return
        end
        local order = { "difficulty", "zone", "title" }
        local nextIndex = 1
        for index, key in ipairs(order) do
            if settings.huntScannerSortBy == key then
                nextIndex = (index % #order) + 1
                break
            end
        end
        settings.huntScannerSortBy = order[nextIndex]
        HandleInteractionSnapshot()
    end)

    local startY = -54

    -- ScrollFrame clips row content within the panel boundary
    local scrollViewport = CreateFrame("ScrollFrame", nil, frame)
    scrollViewport:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, startY)
    scrollViewport:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 4)
    scrollViewport:EnableMouseWheel(true)

    local scrollContent = CreateFrame("Frame", nil, scrollViewport)
    scrollContent:SetSize(panelWidth - 30, PANEL_ROW_POOL_SIZE * panelRowHeight)
    scrollViewport:SetScrollChild(scrollContent)

    local scrollBar = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    scrollBar:SetOrientation("VERTICAL")
    scrollBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, startY - 2)
    scrollBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)
    scrollBar:SetWidth(14)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValue(0)
    scrollBar:SetValueStep(1)
    scrollBar:SetObeyStepOnDrag(true)
    if scrollBar.Low then scrollBar.Low:Hide() end
    if scrollBar.High then scrollBar.High:Hide() end
    if scrollBar.Text then scrollBar.Text:Hide() end
    scrollBar:SetEnabled(false)
    scrollBar:SetAlpha(0.3)
    scrollBar:SetScript("OnValueChanged", function(self, value)
        local _, maxVal = self:GetMinMaxValues()
        local clamped = math.max(0, math.min(value or 0, maxVal or 0))
        scrollViewport:SetVerticalScroll(clamped)
    end)
    scrollViewport:SetScript("OnMouseWheel", function(_, delta)
        local _, maxVal = scrollBar:GetMinMaxValues()
        local cur = scrollBar:GetValue() or 0
        scrollBar:SetValue(math.max(0, math.min(cur - (delta * 20), maxVal or 0)))
    end)

    panelScrollViewport = scrollViewport
    panelScrollContent = scrollContent
    panelScrollBar = scrollBar
    frame.PreydatorScrollViewport = scrollViewport
    frame.PreydatorScrollContent = scrollContent
    frame.PreydatorScrollBar = scrollBar

    for index = 1, PANEL_ROW_POOL_SIZE do
        local row = CreateFrame("Frame", nil, scrollContent, "BackdropTemplate")
        row:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, -((index - 1) * panelRowHeight))
        row:SetSize(panelWidth - 30, panelRowHeight - 4)
        row:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        local achievementAnchor = CreateFrame("Frame", nil, row)
        achievementAnchor:SetHeight(22)

        local achievementIcon = row:CreateTexture(nil, "ARTWORK")
        achievementIcon:SetTexture(ACHIEVEMENT_BADGE_ICON)
        achievementIcon:SetSize(16, 16)
        achievementIcon:Hide()

        local achievement = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        achievement:SetJustifyH("RIGHT")
        achievement:SetText("")

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -7)
        name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, 0)
        name:SetJustifyH("LEFT")
        name:SetText("-")

        local zone = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        zone:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        zone:SetPoint("TOPRIGHT", row, "TOPRIGHT", -74, 0)
        zone:SetJustifyH("LEFT")
        zone:SetText("")

        local reward = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        reward:SetPoint("TOPLEFT", zone, "BOTTOMLEFT", 0, -2)
        reward:SetPoint("TOPRIGHT", row, "TOPRIGHT", -74, 0)
        reward:SetJustifyH("LEFT")
        reward:SetWordWrap(true)
        reward:SetText("-")

        local acceptButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        acceptButton:SetSize(58, 18)
        acceptButton:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -8, 4)
        acceptButton:SetText(L["Accept"])
        acceptButton:SetScript("OnClick", function(self)
            local questID = self:GetParent().PreydatorQuestID
            if not questID then
                return
            end

            if not AcceptMapQuest(questID) then
                print("Preydator Hunt: unable to accept this quest right now.")
            end
        end)

        -- Anchor spans the Accept button top exactly; pair is right-justified within it
        achievementAnchor:SetPoint("BOTTOMLEFT",  acceptButton, "TOPLEFT",  0, 2)
        achievementAnchor:SetPoint("BOTTOMRIGHT", acceptButton, "TOPRIGHT", 0, 2)
        -- Static defaults (overridden per-style each frame):
        -- text right-edge at anchor right, icon right-edge at text left; both y=0 (shared midline)
        achievement:SetPoint("RIGHT", achievementAnchor, "RIGHT", 0, 2)
        achievementIcon:SetPoint("RIGHT", achievement, "LEFT", -2, 0)

        row.PreydatorName = name
        row.PreydatorAchievementAnchor = achievementAnchor
        row.PreydatorAchievement = achievement
        row.PreydatorAchievementIcon = achievementIcon
        row.PreydatorAchievementCount = 0
        row.PreydatorAchievementNames = nil
        row.PreydatorZone = zone
        row.PreydatorReward = reward
        row.PreydatorAccept = acceptButton
        row.PreydatorQuestID = nil
        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            if not GameTooltip or type(GameTooltip.SetOwner) ~= "function" then
                return
            end

            local s = GetSettings()
            if not s or s.huntScannerAchievementTooltip == false then
                return
            end

            local count = SafeToNumber(self.PreydatorAchievementCount) or 0
            if count <= 0 then
                return
            end

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["Achievement Progress"], 1.0, 0.82, 0.0)
            GameTooltip:AddLine(L["This hunt helps:"], 0.85, 0.85, 0.85)
            for _, achievementName in ipairs(self.PreydatorAchievementNames or {}) do
                GameTooltip:AddLine(achievementName, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            if GameTooltip and type(GameTooltip.Hide) == "function" then
                GameTooltip:Hide()
            end
        end)
        row:SetScript("OnMouseUp", function(self, button)
            if button ~= "LeftButton" or not self.PreydatorQuestID then
                return
            end

            if not OpenMapQuestDialog(self.PreydatorQuestID) then
                print("Preydator Hunt: unable to open quest details from this row right now.")
            end
        end)
        panelRows[index] = row
    end

    frame:Hide()
    panelFrame = frame
    return frame
end

local function UpdatePanelTheme(frame)
    local theme = GetTheme()
    local themeKey = GetThemeKey()
    local settings = GetSettings()
    local _, _, fontSize = GetPanelConfig()
    local fontPath = GetThemeFontPath(theme)
    local acceptButtonColor = (themeKey == "deuteranopia" or themeKey == "protanopia")
        and { 1, 1, 1, 1 }
        or { 1.00, 0.82, 0.00, 1.00 }
    local achievementBadgeColor = (settings and settings.huntScannerAchievementBadgeColor)
        or theme.season
        or DEFAULT_ACHIEVEMENT_BADGE_COLOR

    frame:SetBackdropColor(theme.section[1], theme.section[2], theme.section[3], theme.section[4])
    frame:SetBackdropBorderColor(theme.border[1], theme.border[2], theme.border[3], theme.border[4])

    if frame.PreydatorHeader then
        frame.PreydatorHeader:SetColorTexture(theme.header[1], theme.header[2], theme.header[3], theme.header[4])
    end

    SetTextColor(frame.PreydatorTitle, theme.title)
    SetTextColor(frame.PreydatorSubtitle, theme.muted)
    if frame.PreydatorTitle and frame.PreydatorTitle.SetFont then
        frame.PreydatorTitle:SetFont(fontPath, math.max(11, fontSize), "")
    end
    if frame.PreydatorSubtitle and frame.PreydatorSubtitle.SetFont then
        frame.PreydatorSubtitle:SetFont(fontPath, math.max(10, fontSize - 1), "")
    end

    for index, row in ipairs(panelRows) do
        local bg = (index % 2 == 0) and theme.rowAlt or theme.row
        row:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        row:SetBackdropBorderColor(theme.border[1], theme.border[2], theme.border[3], 0.65)
        SetTextColor(row.PreydatorName, theme.title)
        if row.PreydatorAchievement then
            SetTextColor(row.PreydatorAchievement, achievementBadgeColor)
        end
        if row.PreydatorAchievementIcon then
            row.PreydatorAchievementIcon:SetVertexColor(
                achievementBadgeColor[1] or 1,
                achievementBadgeColor[2] or 1,
                achievementBadgeColor[3] or 1,
                achievementBadgeColor[4] or 1
            )
        end
        if row.PreydatorZone then
            SetTextColor(row.PreydatorZone, theme.muted)
        end
        SetTextColor(row.PreydatorReward, theme.text)
        if row.PreydatorName and row.PreydatorName.SetFont then
            row.PreydatorName:SetFont(fontPath, math.max(10, fontSize), "")
        end
        if row.PreydatorZone and row.PreydatorZone.SetFont then
            row.PreydatorZone:SetFont(fontPath, math.max(9, fontSize - 1), "")
        end
        if row.PreydatorAchievement and row.PreydatorAchievement.SetFont then
            row.PreydatorAchievement:SetFont(fontPath, math.max(9, fontSize - 1), "")
        end
        if row.PreydatorReward and row.PreydatorReward.SetFont then
            row.PreydatorReward:SetFont(fontPath, math.max(9, fontSize - 1), "")
        end

        if row.PreydatorAccept and row.PreydatorAccept.SetNormalFontObject then
            row.PreydatorAccept:SetNormalFontObject("GameFontNormalSmall")
            row.PreydatorAccept:SetHighlightFontObject("GameFontHighlightSmall")
            if row.PreydatorAccept.GetFontString then
                local fs = row.PreydatorAccept:GetFontString()
                if fs then
                    SetTextColor(fs, acceptButtonColor)
                end
            end
        end
    end
end

local function ApplyPanelAnchor(frame)
    local settings = GetSettings()
    local side = (settings and settings.huntScannerSide) or "right"
    local align = (settings and settings.huntScannerAnchorAlign) or "top"
    local settingsModule = Preydator and Preydator.GetModule and Preydator:GetModule("Settings")
    local previewAnchor = settingsModule and settingsModule.optionsPanel
    local liveAnchor = (_G.CovenantMissionFrame and _G.CovenantMissionFrame:IsShown() and _G.CovenantMissionFrame)
        or (_G.GossipFrame and _G.GossipFrame.IsShown and _G.GossipFrame:IsShown() and _G.GossipFrame)
        or (_G.QuestFrame and _G.QuestFrame.IsShown and _G.QuestFrame:IsShown() and _G.QuestFrame)
    local anchor = liveAnchor
        or (IsOptionsPreviewVisible() and previewAnchor)
        or UIParent

    frame:ClearAllPoints()
    if side == "left" then
        if align == "middle" then
            frame:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
        elseif align == "bottom" then
            frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -8, 0)
        else
            frame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -8, 0)
        end
    else
        if align == "middle" then
            frame:SetPoint("LEFT", anchor, "RIGHT", 8, 0)
        elseif align == "bottom" then
            frame:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", 8, 0)
        else
            frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 8, 0)
        end
    end
end

local function GetDifficultyBadge(difficulty)
    local canonicalDifficulty = NormalizeDifficultyKey(difficulty)

    local function GetConfiguredDifficultyColor(key)
        local settings = GetSettings()
        local colors = settings and settings.huntScannerDifficultyColors
        local fallback = DEFAULT_DIFFICULTY_COLORS[key] or { 0.60, 0.64, 0.68, 1.00 }
        local color = colors and colors[key]
        return {
            math.max(0, math.min(1, tonumber(color and color[1]) or fallback[1])),
            math.max(0, math.min(1, tonumber(color and color[2]) or fallback[2])),
            math.max(0, math.min(1, tonumber(color and color[3]) or fallback[3])),
            math.max(0, math.min(1, tonumber(color and color[4]) or fallback[4] or 1)),
        }
    end

    local function BuildColorCode(color, label)
        local a = math.floor((math.max(0, math.min(1, color[4] or 1)) * 255) + 0.5)
        local r = math.floor((math.max(0, math.min(1, color[1] or 1)) * 255) + 0.5)
        local g = math.floor((math.max(0, math.min(1, color[2] or 1)) * 255) + 0.5)
        local b = math.floor((math.max(0, math.min(1, color[3] or 1)) * 255) + 0.5)
        return string.format("|c%02x%02x%02x%02x%s|r", a, r, g, b, label)
    end

    if canonicalDifficulty == DIFFICULTY_NIGHTMARE then
        return BuildColorCode(GetConfiguredDifficultyColor(DIFFICULTY_NIGHTMARE), "[Ni]")
    end
    if canonicalDifficulty == DIFFICULTY_HARD then
        return BuildColorCode(GetConfiguredDifficultyColor(DIFFICULTY_HARD), "[H]")
    end
    if canonicalDifficulty == DIFFICULTY_NORMAL then
        return BuildColorCode(GetConfiguredDifficultyColor(DIFFICULTY_NORMAL), "[N]")
    end
    return BuildColorCode({ 0.60, 0.64, 0.68, 1.00 }, "[?]")
end

local function BuildQuestRows(mapHunts)
    local rows = {}
    EnsureAchievementNeedsCache(false)

    for _, hunt in ipairs(mapHunts or {}) do
        local title = hunt.title or ((hunt.questID and ("Quest " .. tostring(hunt.questID))) or L["Unknown"])
        local difficulty = NormalizeDifficultyKey(hunt.difficulty)
        local badge = GetDifficultyBadge(difficulty)
        local achievementCount, achievementNames = GetQuestAchievementNeeds(hunt.questID, hunt.title, hunt.difficulty)

        rows[#rows + 1] = {
            questID = hunt.questID,
            title = badge .. " " .. title,
            reward = BuildRewardSummary(hunt.questID),
            canAccept = not (C_QuestLog and type(C_QuestLog.IsOnQuest) == "function" and C_QuestLog.IsOnQuest(hunt.questID) == true),
            difficultyKey = difficulty,
            difficulty = GetDifficultyDisplayName(difficulty),
            zone = hunt.zone or L["Unknown"],
            baseTitle = title,
            achievementCount = achievementCount,
            achievementNames = achievementNames,
        }
    end

    if #rows > 0 then
        local settings = GetSettings() or {}
        local sortBy = settings.huntScannerSortBy or "zone"
        local groupBy = settings.huntScannerGroupBy or "difficulty"
        local sortDir = settings.huntScannerSortDir or "asc"
        local descending = sortDir == "desc"

        local function GetDifficultyRank(value)
            local key = NormalizeDifficultyKey(value)
            if key == DIFFICULTY_NORMAL then
                return 1
            end
            if key == DIFFICULTY_HARD then
                return 2
            end
            if key == DIFFICULTY_NIGHTMARE then
                return 3
            end
            return 99
        end

        local function SortRows(rowList, keyOverride)
            local effectiveSortBy = keyOverride or sortBy
            table.sort(rowList, function(left, right)
                local cmp = 0
                if effectiveSortBy == "zone" then
                    local l = tostring(left.zone or "")
                    local r = tostring(right.zone or "")
                    if l == r then
                        local lt = tostring(left.baseTitle or left.title or "")
                        local rt = tostring(right.baseTitle or right.title or "")
                        if lt < rt then
                            cmp = -1
                        elseif lt > rt then
                            cmp = 1
                        end
                    else
                        cmp = (l < r) and -1 or 1
                    end
                elseif effectiveSortBy == "title" then
                    local l = tostring(left.baseTitle or left.title or "")
                    local r = tostring(right.baseTitle or right.title or "")
                    if l == r then
                        local lz = tostring(left.zone or "")
                        local rz = tostring(right.zone or "")
                        if lz < rz then
                            cmp = -1
                        elseif lz > rz then
                            cmp = 1
                        end
                    else
                        cmp = (l < r) and -1 or 1
                    end
                else
                    local lRank = GetDifficultyRank(left.difficultyKey or left.difficulty)
                    local rRank = GetDifficultyRank(right.difficultyKey or right.difficulty)
                    if lRank == rRank then
                        local lt = tostring(left.baseTitle or left.title or "")
                        local rt = tostring(right.baseTitle or right.title or "")
                        if lt < rt then
                            cmp = -1
                        elseif lt > rt then
                            cmp = 1
                        end
                    else
                        cmp = (lRank < rRank) and -1 or 1
                    end
                end

                if descending then
                    return cmp > 0
                end
                return cmp < 0
            end)
        end

        SortRows(rows)

        if groupBy ~= "difficulty" and groupBy ~= "zone" then
            return rows
        end

        local grouped = {}
        local collapsedGroups = settings.huntScannerCollapsedGroups or {}
        local buckets = {}
        local bucketOrder = {}

        for _, row in ipairs(rows) do
            local key = (groupBy == "zone") and tostring(row.zone or L["Unknown"]) or tostring(row.difficulty or L["Normal"])
            if not buckets[key] then
                buckets[key] = {}
                bucketOrder[#bucketOrder + 1] = key
            end
            buckets[key][#buckets[key] + 1] = row
        end

        table.sort(bucketOrder, function(left, right)
            if groupBy == "difficulty" then
                local lRank = GetDifficultyRank(left)
                local rRank = GetDifficultyRank(right)
                if lRank == rRank then
                    return tostring(left) < tostring(right)
                end
                return lRank > rRank
            end
            return tostring(left) < tostring(right)
        end)

        for _, key in ipairs(bucketOrder) do
            local collapseKey = tostring(groupBy) .. ":" .. key
            local collapsed = collapsedGroups[collapseKey] == true
            local bucketRows = buckets[key]
            local bucketSort = sortBy
            if bucketSort == groupBy then
                bucketSort = "title"
            end
            SortRows(bucketRows, bucketSort)

            grouped[#grouped + 1] = {
                title = (collapsed and "+ " or "- ") .. (groupBy == "zone" and (L["Zone"] .. ": ") or (L["Difficulty"] .. ": ")) .. key,
                reward = "",
                canAccept = false,
                groupKey = collapseKey,
                collapsed = collapsed,
            }

            if not collapsed then
                for _, row in ipairs(bucketRows) do
                    grouped[#grouped + 1] = row
                end
            end
        end

        return grouped
    end

    return rows
end

local function ReflowHuntRows()
    if not panelScrollViewport or not panelScrollContent or not panelScrollBar or not panelFrame then
        return
    end

    local rowWidth = panelScrollContent:GetWidth()
    if rowWidth < 10 then
        return
    end

    local yOffset = 0
    local gap = 4
    local nameLineH = 16
    local rewardLineH = 13
    local rowPadTop = 7
    local rowPadBottom = 6

    for index = 1, PANEL_ROW_POOL_SIZE do
        local row = panelRows[index]
        if not row then
            break
        end
        if row:IsShown() then
            local rewardH = (row.PreydatorReward and row.PreydatorReward:GetStringHeight()) or rewardLineH
            local zoneH = 0
            if row.PreydatorZone then
                local zt = row.PreydatorZone:GetText()
                if zt and zt ~= "" then
                    zoneH = math.ceil(row.PreydatorZone:GetStringHeight() or 13) + 2
                end
            end
            local rowH = math.max(panelRowHeight - 4, rowPadTop + nameLineH + zoneH + 3 + math.ceil(rewardH) + rowPadBottom)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", panelScrollContent, "TOPLEFT", 0, -yOffset)
            row:SetSize(rowWidth, rowH)
            yOffset = yOffset + rowH + gap
        end
    end

    panelScrollContent:SetHeight(math.max(1, yOffset))
    panelScrollViewport:UpdateScrollChildRect()

    local scrollRange = panelScrollViewport:GetVerticalScrollRange() or 0
    scrollRange = math.max(0, scrollRange)
    if scrollRange > 0 then
        panelScrollBar:SetMinMaxValues(0, scrollRange)
        local cur = math.min(panelScrollBar:GetValue() or 0, scrollRange)
        panelScrollBar:SetValue(cur)
        panelScrollBar:SetEnabled(true)
        panelScrollBar:SetAlpha(1)
    else
        panelScrollBar:SetMinMaxValues(0, 0)
        panelScrollBar:SetValue(0)
        panelScrollBar:SetEnabled(false)
        panelScrollBar:SetAlpha(0.3)
    end
end

local reflowScheduled = false

local function QueueReflowRows()
    if reflowScheduled then
        return
    end
    reflowScheduled = true

    if C_Timer then
        C_Timer.After(0, function()
            reflowScheduled = false
            ReflowHuntRows()
        end)
        return
    end

    reflowScheduled = false
    ReflowHuntRows()
end

local function RenderPanel(questRows)
    if not IsOptionsPreviewVisible() and not HasVisibleHuntAnchor() then
        HidePanel()
        return
    end

    local frame = EnsurePanel()
    local panelWidth, panelHeight, _, panelScale = GetPanelConfig()
    frame:SetSize(panelWidth, panelHeight)
    frame:SetScale(panelScale)
    if panelScrollContent then
        panelScrollContent:SetWidth(panelWidth - 30)
    end
    UpdatePanelTheme(frame)
    ApplyPanelAnchor(frame)

    local settings = GetSettings() or {}
    if frame.PreydatorSubtitle then
        local groupLabel = settings.huntScannerGroupBy or "difficulty"
        local sortLabel = settings.huntScannerSortBy or "zone"
        local sortDirLabel = settings.huntScannerSortDir or "asc"
        frame.PreydatorSubtitle:SetText("Group: " .. tostring(groupLabel) .. " | Sort: " .. tostring(sortLabel) .. " (" .. tostring(sortDirLabel) .. ")")
    end

    if not questRows or #questRows == 0 then
        questRows = {
            {
                title = L["No available hunts"],
                reward = "",
            },
        }
    end

    for index, row in ipairs(panelRows) do
        local data = questRows[index]
        if data then
            row:Show()
            row.PreydatorQuestID = SafeToNumber(data.questID)
            local displayTitle = data.title or "-"
            if data.difficultyKey and data.baseTitle then
                displayTitle = GetDifficultyBadge(data.difficultyKey) .. " " .. tostring(data.baseTitle)
            end
            row.PreydatorName:SetText(displayTitle)
            row.PreydatorAchievementCount = SafeToNumber(data.achievementCount) or 0
            row.PreydatorAchievementNames = data.achievementNames
            if row.PreydatorAchievement then
                if row.PreydatorAchievementCount > 0 and settings.huntScannerAchievementSignals ~= false then
                    local style = settings.huntScannerAchievementSignalStyle or "icon_count"
                    local iconSize = math.max(12, math.min(32, tonumber(settings.huntScannerAchievementIconSize) or 18))
                    local showIcon = (style == "icon_only" or style == "icon_count")
                    local showCount = (style == "count_only") or (style == "icon_count" and row.PreydatorAchievementCount > 1)

                    if row.PreydatorAchievement then
                        row.PreydatorAchievement:ClearAllPoints()
                    end
                    if row.PreydatorAchievementIcon then
                        row.PreydatorAchievementIcon:ClearAllPoints()
                    end

                    if row.PreydatorAchievementIcon then
                        row.PreydatorAchievementIcon:SetSize(iconSize, iconSize)
                        row.PreydatorAchievementIcon:SetShown(showIcon)
                    end

                    local anch = row.PreydatorAchievementAnchor or row
                    if style == "icon_only" then
                        if row.PreydatorAchievementIcon then
                            -- single icon: centre it in the anchor
                            row.PreydatorAchievementIcon:SetPoint("CENTER", anch, "CENTER", 0, 0)
                        end
                    elseif style == "count_only" then
                        -- text only: right-edge at anchor right, midline shared
                        row.PreydatorAchievement:SetPoint("RIGHT", anch, "RIGHT", 0, 2)
                    else
                        -- icon + count: keep the icon's right edge fixed to the slot,
                        -- then place text relative to the icon using the tuned offsets.
                        if row.PreydatorAchievementIcon then
                            row.PreydatorAchievementIcon:SetPoint("RIGHT", anch, "RIGHT", -16, 0)
                            row.PreydatorAchievement:SetPoint("LEFT", row.PreydatorAchievementIcon, "RIGHT", -12, 6)
                        else
                            row.PreydatorAchievement:SetPoint("RIGHT", anch, "RIGHT", 0, 2)
                        end
                    end

                    if showCount then
                        row.PreydatorAchievement:SetText("x" .. tostring(row.PreydatorAchievementCount))
                        row.PreydatorAchievement:Show()
                    else
                        row.PreydatorAchievement:SetText("")
                        row.PreydatorAchievement:Hide()
                    end
                else
                    row.PreydatorAchievement:SetText("")
                    row.PreydatorAchievement:Hide()
                    if row.PreydatorAchievementIcon then
                        row.PreydatorAchievementIcon:Hide()
                    end
                end
            end
            if row.PreydatorZone then
                local showZone = not data.groupKey and data.zone and data.zone ~= "" and data.zone ~= L["Unknown"]
                row.PreydatorZone:SetText(showZone and data.zone or "")
            end
            row.PreydatorReward:SetText(data.reward or "")
            if row.PreydatorAccept then
                if data.canAccept and row.PreydatorQuestID then
                    row.PreydatorAccept:Show()
                    row.PreydatorAccept:Enable()
                else
                    row.PreydatorAccept:Hide()
                    row.PreydatorAccept:Disable()
                end
            end
            if data.groupKey and row.PreydatorQuestID == nil then
                row:SetScript("OnMouseUp", function(self, button)
                    if button ~= "LeftButton" then
                        return
                    end
                    local s = GetSettings()
                    if not s then
                        return
                    end
                    s.huntScannerCollapsedGroups = s.huntScannerCollapsedGroups or {}
                    s.huntScannerCollapsedGroups[data.groupKey] = not (s.huntScannerCollapsedGroups[data.groupKey] == true)
                    HandleInteractionSnapshot()
                end)
            else
                row:SetScript("OnMouseUp", function(self, button)
                    if button ~= "LeftButton" or not self.PreydatorQuestID then
                        return
                    end

                    if not OpenMapQuestDialog(self.PreydatorQuestID) then
                        print("Preydator Hunt: unable to open quest details from this row right now.")
                    end
                end)
            end
        else
            row.PreydatorQuestID = nil
            row.PreydatorAchievementCount = 0
            row.PreydatorAchievementNames = nil
            if row.PreydatorAchievement then
                row.PreydatorAchievement:SetText("")
                row.PreydatorAchievement:Hide()
            end
            if row.PreydatorAchievementIcon then
                row.PreydatorAchievementIcon:Hide()
            end
            if row.PreydatorAccept then
                row.PreydatorAccept:Hide()
                row.PreydatorAccept:Disable()
            end
            row:ClearAllPoints()
            row:SetScript("OnMouseUp", nil)
            row:Hide()
        end
    end

    frame:Show()
    QueueReflowRows()
end

HidePanel = function(cancelQueuedPasses)
    if panelFrame then
        panelFrame:Hide()
    end
    if panelScrollBar then
        panelScrollBar:SetValue(0)
    end
    if panelScrollViewport then
        panelScrollViewport:SetVerticalScroll(0)
    end
    huntInteractionActive = false
    if cancelQueuedPasses ~= false then
        snapshotSequence = snapshotSequence + 1
    end
    lastOpenQuestID = nil
    lastOpenAt = 0
    SyncNoisyEventSubscriptions()
end

HandleInteractionSnapshot = function()
    if isHandlingSnapshot then
        return
    end

    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    isHandlingSnapshot = true

    local ok, err = pcall(function()
        EnsureSettings()
        ProcessRewardCacheLifecycle()

        if not IsHuntRuntimeEnabled() then
            HidePanel(false)
            return
        end

        local options = GetGossipOptionsSafe()

        local isHuntContext, npcID = IsHuntTableContext(options)

        local mapHunts = RefreshHuntsFromPins()
        if #mapHunts > 0 and IsMissionFrameVisible() then
            isHuntContext = true
        end
        huntInteractionActive = isHuntContext == true
        SyncNoisyEventSubscriptions()
        if isHuntContext then
            MarkAvailabilityTouched()
        end
        CaptureSnapshot(options, npcID)
        NotifyCurrencyTrackerAvailabilityChanged()

        if not isHuntContext then
            if IsOptionsPreviewVisible() then
                RenderPanel(BuildPreviewRows())
                return
            end
            HidePanel(false)
            return
        end

        if not IsOptionsPreviewVisible() and not HasVisibleHuntAnchor() then
            HidePanel(false)
            return
        end

        if BlockHuntTableWhileActivePrey() then
            return
        end

        local rows = BuildQuestRows(mapHunts)
        RenderPanel(rows)
        if #mapHunts > 0 then
            WarmRewardCacheFromPins()
        end
    end)

    if not ok then
        print("Preydator HuntScanner: snapshot error: " .. SafeToString(err))
        print("Preydator HuntScanner: snapshot context: " .. GetRestrictedInstanceDebugSummary())
    end

    isHandlingSnapshot = false
end

local function ApplyMissionHooks()
    if missionHooksApplied or type(HookSecureFunc) ~= "function" then
        return
    end

    HookSecureFunc("ShowUIPanel", function(frame)
        if not frame or frame:GetName() ~= "CovenantMissionFrame" then
            return
        end

        if QueueInteractionSnapshotPasses then
            QueueInteractionSnapshotPasses()
        else
            HandleInteractionSnapshot()
        end
    end)

    HookSecureFunc("HideUIPanel", function(frame)
        if not frame or frame:GetName() ~= "CovenantMissionFrame" then
            return
        end

        if rewardWarmCancel then
            rewardWarmCancel()
        end
        HidePanel()
    end)

    missionHooksApplied = true
end

function HuntScannerModule:ApplySettings()
    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    EnsureSettings()
    ProcessRewardCacheLifecycle()
    if IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end

    if panelFrame and panelFrame:IsShown() then
        if not HasVisibleHuntAnchor() then
            HidePanel()
            return
        end
        UpdatePanelTheme(panelFrame)
        ApplyPanelAnchor(panelFrame)
    end
end

function HuntScannerModule:SetPreviewEnabled(enabled)
    local settings = GetSettings()
    if settings then
        settings.huntScannerPreviewInOptions = enabled == true
    end

    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    if enabled == true and IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end

    if not HasVisibleHuntAnchor() then
        HidePanel()
        return
    end

    self:RefreshNow()
end

function HuntScannerModule:HandleOptionsPanelVisibility(isVisible)
    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    if isVisible == true then
        if IsOptionsPreviewVisible() then
            RenderPanel(BuildPreviewRows())
            return
        end

        if not HasVisibleHuntAnchor() then
            HidePanel()
            return
        end

        self:RefreshNow()
        return
    end

    local settings = GetSettings()
    if settings then
        settings.themeEditorPreviewInOptions = false
    end

    if not HasVisibleHuntAnchor() then
        HidePanel()
        return
    end

    self:RefreshNow()
end

function HuntScannerModule:SetThemePreviewEnabled(enabled)
    local settings = GetSettings()
    if settings then
        settings.themeEditorPreviewInOptions = enabled == true
    end

    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    if IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end

    if not HasVisibleHuntAnchor() then
        HidePanel()
        return
    end

    self:RefreshNow()
end

function HuntScannerModule:PrintDebugSnapshot()
    if IsInRestrictedInstance() then
        print("Preydator HuntDebug: unavailable in restricted instances.")
        return
    end

    if (not lastSnapshot) or (not lastSnapshot.npcID and #(lastSnapshot.available or {}) == 0 and #(lastSnapshot.active or {}) == 0 and #(lastSnapshot.options or {}) == 0) then
        RefreshDebugSnapshotFromLiveAPI()
    end

    local snapshot = SelectBestSnapshotForDebug()
    if not snapshot then
        print("Preydator HuntDebug: no hunt snapshot captured yet.")
        return
    end

    local lines = BuildDebugSnapshotLines(snapshot)
    for _, line in ipairs(lines) do
        print(line)
    end
end

function HuntScannerModule:OnSlashCommand(text, rest)
    if text == "hinspect" then
        if IsInRestrictedInstance() then
            print("Preydator HuntDebug: unavailable in restricted instances.")
            return true
        end

        if (not lastSnapshot) or (not lastSnapshot.npcID and #(lastSnapshot.available or {}) == 0 and #(lastSnapshot.active or {}) == 0 and #(lastSnapshot.options or {}) == 0) then
            RefreshDebugSnapshotFromLiveAPI()
        end

        local mode = string.lower((rest or ""):match("^%s*(.-)%s*$") or "")
        if mode == "bs" then
            local snapshot = SelectBestSnapshotForDebug()
            if not snapshot then
                print("Preydator HuntDebug: no hunt snapshot captured yet.")
                return true
            end

            local lines = BuildDebugSnapshotLines(snapshot)
            local sent, reason = SendLinesToBugSack(lines)
            if sent then
                print("Preydator HuntDebug: sent to BugSack via error handler.")
            else
                print("Preydator HuntDebug: Could not send to BugSack: " .. tostring(reason))
                for _, line in ipairs(lines) do
                    print(line)
                end
            end
            return true
        elseif mode ~= "" then
            return false
        end

        self:PrintDebugSnapshot()
        return true
    end

    if text == "hinspectcopy" then
        local mode = string.lower((rest or ""):match("^%s*(.-)%s*$") or "")
        if type(lastDebugPayload) == "string" and lastDebugPayload ~= "" then
            if mode == "bs" then
                local lines = {}
                for line in string.gmatch(lastDebugPayload, "([^\n]+)") do
                    lines[#lines + 1] = line
                end
                if #lines == 0 then
                    lines[1] = lastDebugPayload
                end

                local sent, reason = SendLinesToBugSack(lines)
                if sent then
                    print("Preydator HuntDebug: sent to BugSack via error handler.")
                else
                    print("Preydator HuntDebug: Could not send to BugSack: " .. tostring(reason))
                    print(lastDebugPayload)
                end
            elseif mode == "" then
                print(lastDebugPayload)
            else
                return false
            end
        else
            print("Preydator HuntDebug: no payload captured yet.")
        end
        return true
    end

    if text == "ainspect" then
        local mode = string.lower((rest or ""):match("^%s*(.-)%s*$") or "")
        EnsureAchievementNeedsCache(true)

        local questIDCount, nameKeyCount, completedCount = 0, 0, 0
        for _ in pairs(achievementNeedsByQuestID) do questIDCount = questIDCount + 1 end
        for _ in pairs(achievementNeedsByNameKey) do nameKeyCount = nameKeyCount + 1 end
        for _ in pairs(completedAchievementCache) do completedCount = completedCount + 1 end

        local suffixNightmare, suffixHard, suffixNormal, suffixNone = 0, 0, 0, 0
        for key in pairs(achievementNeedsByNameKey) do
            if string.match(key, "::nightmare$") then
                suffixNightmare = suffixNightmare + 1
            elseif string.match(key, "::hard$") then
                suffixHard = suffixHard + 1
            elseif string.match(key, "::normal$") then
                suffixNormal = suffixNormal + 1
            else
                suffixNone = suffixNone + 1
            end
        end

        local lines = {}
        local idHits = SafeToNumber(achievementRouteStats.idHits) or 0
        local fallbackHits = SafeToNumber(achievementRouteStats.fallbackHits) or 0
        local misses = SafeToNumber(achievementRouteStats.misses) or 0
        local routeTotal = idHits + fallbackHits + misses
        local idPct = routeTotal > 0 and (idHits / routeTotal) * 100 or 0
        local fallbackPct = routeTotal > 0 and (fallbackHits / routeTotal) * 100 or 0
        lines[#lines + 1] = string.format(
            "Preydator AchInspect: questIDs=%d nameKeys=%d completed=%d dirty=%s suffixes[nightmare=%d hard=%d normal=%d none=%d]",
            questIDCount,
            nameKeyCount,
            completedCount,
            tostring(achievementCacheDirty),
            suffixNightmare,
            suffixHard,
            suffixNormal,
            suffixNone
        )
        lines[#lines + 1] = string.format(
            "Preydator AchInspect: route id=%d fallback=%d miss=%d total=%d idPct=%.1f fallbackPct=%.1f",
            idHits,
            fallbackHits,
            misses,
            routeTotal,
            idPct,
            fallbackPct
        )

        if nameKeyCount == 0 and questIDCount == 0 then
            lines[#lines + 1] = "  (cache is empty — achievement API may not be ready or all tracked achievements are completed)"
        end

        local sortedName = {}
        for key in pairs(achievementNeedsByNameKey) do
            sortedName[#sortedName + 1] = key
        end
        table.sort(sortedName)
        for _, key in ipairs(sortedName) do
            local bucket = achievementNeedsByNameKey[key]
            local names = type(bucket) == "table" and table.concat(bucket.names or {}, ", ") or "?"
            lines[#lines + 1] = string.format("  [%s] → %s", key, names)
        end

        local sortedQ = {}
        for qid in pairs(achievementNeedsByQuestID) do
            sortedQ[#sortedQ + 1] = qid
        end
        table.sort(sortedQ)
        for _, qid in ipairs(sortedQ) do
            local bucket = achievementNeedsByQuestID[qid]
            local names = type(bucket) == "table" and table.concat(bucket.names or {}, ", ") or "?"
            lines[#lines + 1] = string.format("  questID=%d → %s", qid, names)
        end

        if #liveHunts > 0 then
            lines[#lines + 1] = "  -- Live Hunt Lookup --"
            for index, hunt in ipairs(liveHunts) do
                local questID = SafeToNumber(hunt and hunt.questID) or 0
                local title = SafeToString(hunt and hunt.title)
                local difficulty = NormalizeDifficultyKey(hunt and hunt.difficulty)
                local key = BuildAchievementMatchKey(title, difficulty)
                local compactKey = BuildAchievementCompactMatchKey(title, difficulty)
                local plainKey = BuildAchievementMatchKey(title, nil)
                local compactPlainKey = BuildAchievementCompactMatchKey(title, nil)

                local variantHits = {}
                local variantSeen = {}
                local function addVariantHit(variantKey)
                    if type(variantKey) ~= "string" or variantKey == "" or variantSeen[variantKey] then
                        return
                    end
                    local variantBucket = achievementNeedsByNameKey[variantKey]
                    if type(variantBucket) == "table" and (variantBucket.count or 0) > 0 then
                        variantSeen[variantKey] = true
                        variantHits[#variantHits + 1] = variantKey
                    end
                end

                addVariantHit(BuildAchievementMatchKey(title, DIFFICULTY_NIGHTMARE))
                addVariantHit(BuildAchievementCompactMatchKey(title, DIFFICULTY_NIGHTMARE))
                addVariantHit(BuildAchievementMatchKey(title, DIFFICULTY_HARD))
                addVariantHit(BuildAchievementCompactMatchKey(title, DIFFICULTY_HARD))
                addVariantHit(BuildAchievementMatchKey(title, DIFFICULTY_NORMAL))
                addVariantHit(BuildAchievementCompactMatchKey(title, DIFFICULTY_NORMAL))
                addVariantHit(BuildAchievementMatchKey(title, nil))
                addVariantHit(BuildAchievementCompactMatchKey(title, nil))

                local bucket, source = ResolveAchievementNameBucket(title, difficulty)
                source = source or "none"

                local matchCount = (type(bucket) == "table" and (bucket.count or 0)) or 0
                if matchCount > 0 then
                    local matchedNames = table.concat(bucket.names or {}, ", ")
                    lines[#lines + 1] = string.format(
                        "  [H%d] questID=%d title=%s diff=%s key=%s match=%d via=%s → %s",
                        index,
                        questID,
                        title,
                        difficulty,
                        SafeToString(key),
                        matchCount,
                        source,
                        matchedNames
                    )
                else
                    local variantSummary = #variantHits > 0 and table.concat(variantHits, " | ") or "(none)"
                    lines[#lines + 1] = string.format(
                        "  [H%d] questID=%d title=%s diff=%s key=%s compact=%s plain=%s compactPlain=%s match=0 variants=%s",
                        index,
                        questID,
                        title,
                        difficulty,
                        SafeToString(key),
                        SafeToString(compactKey),
                        SafeToString(plainKey),
                        SafeToString(compactPlainKey),
                        variantSummary
                    )
                end
            end
        end

        if mode == "bs" then
            local sent, reason = SendLinesToBugSack(lines)
            if sent then
                print("Preydator AchInspect: sent to BugSack via error handler.")
            else
                print("Preydator AchInspect: Could not send to BugSack: " .. tostring(reason))
                for _, line in ipairs(lines) do print(line) end
            end
        else
            for _, line in ipairs(lines) do print(line) end
        end

        return true
    end

    return false
end

QueueInteractionSnapshotPasses = function(force)
    if not IsHuntRuntimeEnabled() then
        HidePanel()
        return
    end

    if IsInRestrictedInstance() then
        HidePanel()
        return
    end

    if HasActivePreyQuest() and not IsOptionsPreviewVisible() then
        HidePanel()
        return
    end

    if not force and not IsOptionsPreviewVisible() and not IsMissionFrameVisible() and not huntInteractionActive then
        local options = GetGossipOptionsSafe()
        local isHuntContext = IsHuntTableContext(options)
        if not isHuntContext then
            return
        end
    end

    local now = GetTime and (tonumber(GetTime()) or 0) or 0
    if not force and now < queueDebounceUntil then
        HandleInteractionSnapshot()
        return
    end
    queueDebounceUntil = now + SNAPSHOT_QUEUE_DEBOUNCE_SECONDS

    snapshotSequence = snapshotSequence + 1
    local token = snapshotSequence

    HandleInteractionSnapshot()

    if not C_Timer or type(C_Timer.After) ~= "function" then
        return
    end

    -- Delays extend to 10s so pins that load slowly (server lag) are still caught.
    -- The snapshotSequence token cancels stale passes when the user leaves.
    for _, delay in ipairs({ 0.05, 0.20, 0.50, 1.00, 2.00, 4.00, 7.00, 10.00 }) do
        C_Timer.After(delay, function()
            if token ~= snapshotSequence then
                return
            end
            HandleInteractionSnapshot()
        end)
    end
end

function HuntScannerModule:RefreshNow()
    if not IsHuntRuntimeEnabled() or IsInRestrictedInstance() then
        HidePanel()
        return
    end

    ProcessRewardCacheLifecycle()
    if IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end
    HandleInteractionSnapshot()
end

function HuntScannerModule:RefreshRewardCache()
    if not IsHuntRuntimeEnabled() or IsInRestrictedInstance() then
        HidePanel()
        return
    end

    ClearAllRewardCaches()
    if IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end
    HandleInteractionSnapshot()
    WarmRewardCacheFromPins()
end

function HuntScannerModule:ClearAchievementCache()
    ClearCompletedAchievementCache()
    achievementRouteStats.idHits = 0
    achievementRouteStats.fallbackHits = 0
    achievementRouteStats.misses = 0
    if IsOptionsPreviewVisible() then
        RenderPanel(BuildPreviewRows())
        return
    end
    self:RefreshNow()
end

function HuntScannerModule:ClearAvailabilityCache()
    ClearAvailabilityCache()
end

function HuntScannerModule:OnPreyQuestEnded(payload)
    if type(payload) ~= "table" then
        return
    end

    local questID = SafeToNumber(payload.questID)
    if not questID or questID < 1 then
        return
    end

    local completed = payload.completed == true or tonumber(payload.stage) == 4
    if completed then
        local difficulty = GetRememberedQuestDifficulty(questID)
        if type(difficulty) ~= "string" or difficulty == "" then
            difficulty = type(payload.difficulty) == "string" and payload.difficulty or nil
        end
        if difficulty then
            ClearRewardCacheForDifficulty(difficulty)
        end
    end

    rewardRetryCount[questID] = nil
    HidePanel()
end

function HuntScannerModule:GetAvailabilityCounts()
    local counts = {
        normal = 0,
        hard = 0,
        nightmare = 0,
    }

    for _, hunt in ipairs(liveHunts or {}) do
        local questID = SafeToNumber(hunt and hunt.questID)
        if questID and questID > 0 then
            local isOnQuest = C_QuestLog and type(C_QuestLog.IsOnQuest) == "function" and C_QuestLog.IsOnQuest(questID) == true
            if not isOnQuest then
                local difficulty = NormalizeDifficultyKey(hunt and hunt.difficulty)
                if difficulty == DIFFICULTY_NIGHTMARE then
                    counts.nightmare = counts.nightmare + 1
                elseif difficulty == DIFFICULTY_HARD then
                    counts.hard = counts.hard + 1
                else
                    counts.normal = counts.normal + 1
                end
            end
        end
    end

    if #liveHunts > 0 then
        availabilityTouched = true
        availabilityCache = {
            normal = counts.normal,
            hard = counts.hard,
            nightmare = counts.nightmare,
            capturedAt = GetTime and (tonumber(GetTime()) or 0) or 0,
        }
        SaveAvailabilityCache()
        return {
            normal = counts.normal,
            hard = counts.hard,
            nightmare = counts.nightmare,
            capturedAt = availabilityCache.capturedAt,
            known = true,
        }
    end

    local cached = SanitizeAvailabilityCounts(availabilityCache)
    return {
        normal = cached.normal,
        hard = cached.hard,
        nightmare = cached.nightmare,
        capturedAt = cached.capturedAt,
        known = availabilityTouched == true,
    }
end

function HuntScannerModule:GetQuestZoneMapID(questID)
    local id = SafeToNumber(questID)
    if not id then
        return nil
    end
    local fromCache = questZoneCache[id]
    if type(fromCache) == "number" then
        return fromCache
    end
    local hunt = huntByQuestID[id]
    if hunt and type(hunt.zoneMapID) == "number" then
        return hunt.zoneMapID
    end
    if hunt and type(hunt.zone) == "string" and hunt.zone ~= "" then
        local inferredZoneMapID = GetInferredZoneMapID(hunt.zone)
        if inferredZoneMapID then
            questZoneCache[id] = inferredZoneMapID
            if not questZoneNameCache[id] then
                questZoneNameCache[id] = hunt.zone
            end
            return inferredZoneMapID
        end
    end
    -- Primary on-demand: query zone directly from task quest metadata.
    if C_TaskQuest and type(C_TaskQuest.GetQuestZoneID) == "function" then
        local okTaskZone, rawTaskZone = pcall(C_TaskQuest.GetQuestZoneID, id)
        local taskZoneMapID = okTaskZone and SafeToNumber(rawTaskZone) or nil
        if taskZoneMapID then
            questZoneCache[id] = taskZoneMapID
            if not questZoneNameCache[id] and C_Map and C_Map.GetMapInfo then
                local okInfo, mapInfo = pcall(C_Map.GetMapInfo, taskZoneMapID)
                if okInfo and mapInfo and type(mapInfo.name) == "string" and mapInfo.name ~= "" then
                    questZoneNameCache[id] = mapInfo.name
                end
            end
            return taskZoneMapID
        end
    end
    -- Fallback: derive from cached pin coordinates if we have a parent map ID.
    local coords = questCoords[id]
    local parentMapID = SafeToNumber(cachedAdventureMapID)
    if coords and parentMapID and C_Map and C_Map.GetMapInfoAtPosition then
        local okZoneInfo, zoneInfo = pcall(C_Map.GetMapInfoAtPosition, parentMapID, coords.nx, coords.ny)
        zoneInfo = okZoneInfo and zoneInfo or nil
        local zoneMapID = SafeToNumber(zoneInfo and zoneInfo.mapID)
        if zoneMapID then
            questZoneCache[id] = zoneMapID
            if not questZoneNameCache[id] and C_Map.GetMapInfo then
                local okInfo, mapInfo = pcall(C_Map.GetMapInfo, zoneMapID)
                if okInfo and mapInfo and type(mapInfo.name) == "string" and mapInfo.name ~= "" then
                    questZoneNameCache[id] = mapInfo.name
                end
            end
            return zoneMapID
        end
    end
    return nil
end

function HuntScannerModule:GetQuestMetadata(questID)
    local id = SafeToNumber(questID)
    if not id then
        return nil
    end

    local hunt = huntByQuestID[id]
    local zoneMapID = self:GetQuestZoneMapID(id)
    local zoneName = (hunt and hunt.zone) or questZoneNameCache[id] or nil
    local difficulty = hunt and hunt.difficulty or GetRememberedQuestDifficulty(id)
    local title = hunt and hunt.title or nil
    local sourceType = hunt and "weekly" or "random"

    return {
        questID = id,
        title = title,
        difficulty = NormalizeDifficultyKey(difficulty),
        zoneName = zoneName,
        zoneMapID = zoneMapID,
        sourceType = sourceType,
    }
end

function HuntScannerModule:GetAchievementRouteStats()
    local idHits = SafeToNumber(achievementRouteStats.idHits) or 0
    local fallbackHits = SafeToNumber(achievementRouteStats.fallbackHits) or 0
    local misses = SafeToNumber(achievementRouteStats.misses) or 0
    local total = idHits + fallbackHits + misses
    return {
        idHits = idHits,
        fallbackHits = fallbackHits,
        misses = misses,
        total = total,
        idPct = total > 0 and (idHits / total) * 100 or 0,
        fallbackPct = total > 0 and (fallbackHits / total) * 100 or 0,
    }
end

function HuntScannerModule:OnAddonLoaded()
    EnsureSettings()
    LoadRewardCaches()
    LoadCompletedAchievementCache()
    ProcessRewardCacheLifecycle()
    achievementCacheDirty = true
    ApplyMissionHooks()
    SyncNoisyEventSubscriptions()
end

huntEventFrame = CreateFrame("Frame")
huntEventFrame:RegisterEvent("PLAYER_LOGIN")
huntEventFrame:RegisterEvent("GOSSIP_SHOW")
huntEventFrame:RegisterEvent("GOSSIP_CLOSED")
huntEventFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
huntEventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
huntEventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
huntEventFrame:RegisterEvent("QUEST_DETAIL")
huntEventFrame:RegisterEvent("QUEST_PROGRESS")
huntEventFrame:RegisterEvent("QUEST_COMPLETE")
huntEventFrame:RegisterEvent("QUEST_FINISHED")
huntEventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
huntEventFrame:RegisterEvent("CRITERIA_UPDATE")

huntEventFrame:SetScript("OnEvent", function(_, event, ...)
    local noisyEvent = (event == "QUEST_LOG_UPDATE" or event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS")
    local isRestrictedInstance = IsInRestrictedInstance()
    local runtimeEnabled = nil
    local function IsRuntimeEnabled()
        if runtimeEnabled ~= nil then
            return runtimeEnabled
        end

        runtimeEnabled = IsHuntRuntimeEnabled()
        return runtimeEnabled
    end

    local hasHuntContext = nil
    local function GetHasHuntContext()
        if hasHuntContext ~= nil then
            return hasHuntContext
        end

        hasHuntContext = IsRuntimeEnabled()
            and (not isRestrictedInstance)
            and (IsMissionFrameVisible() or huntInteractionActive or IsOptionsPreviewVisible())
        return hasHuntContext
    end

    if (not noisyEvent) or GetHasHuntContext() then
        if noisyEvent then
            -- Do not read noisy widget payload args; they can be secret values.
            RecordEvent(event)
        else
            RecordEvent(event, ...)
        end
    end

    if event == "PLAYER_LOGIN" then
        EnsureSettings()
        LoadRewardCaches()
        LoadCompletedAchievementCache()
        ProcessRewardCacheLifecycle()
        achievementCacheDirty = true
        -- Do NOT force EnsureAchievementNeedsCache here. The dirty flag above defers
        -- the expensive 52-achievement/criteria pcall rebuild to the first panel open,
        -- eliminating the synchronous login CPU spike.
        ApplyMissionHooks()
        SyncNoisyEventSubscriptions()
        return
    end

    -- Blanket restricted-instance gate for all non-login events.
    -- This prevents stale huntInteractionActive state from queuing snapshot passes on
    -- achievement/criteria/quest-data updates while in delve/instance combat.
    if isRestrictedInstance then
        if huntInteractionActive then
            huntInteractionActive = false
            SyncNoisyEventSubscriptions()
        end
        HidePanel()
        return
    end

    if event == "ACHIEVEMENT_EARNED" or event == "CRITERIA_UPDATE" then
        if event == "ACHIEVEMENT_EARNED" then
            MarkAchievementCompleted(select(1, ...))
        end
        achievementCacheDirty = true
        if IsMissionFrameVisible() or huntInteractionActive or IsOptionsPreviewVisible() then
            QueueInteractionSnapshotPasses(true)
        end
        return
    end

    if not IsRuntimeEnabled() then
        if huntInteractionActive then
            huntInteractionActive = false
        end
        HidePanel()
        return
    end

    if (event == "QUEST_LOG_UPDATE" or event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS") and GetHasHuntContext() then
        ProcessRewardCacheLifecycle()
    end

    if event == "GOSSIP_SHOW" then
        -- Pre-flag hunt context eagerly so UPDATE_UI_WIDGET events refire while pins load.
        local gossipOptions = GetGossipOptionsSafe()
        if IsHuntTableContext(gossipOptions) then
            huntInteractionActive = true
            SyncNoisyEventSubscriptions()
            QueueInteractionSnapshotPasses()
        end
        return
    end

    if event == "GOSSIP_CLOSED" then
        HidePanel()
        return
    end

    if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if IsMissionFrameVisible() then
            -- Only the hunt table mission frame needs snapshot work.
            huntInteractionActive = true
            SyncNoisyEventSubscriptions()
            QueueInteractionSnapshotPasses(true)
        else
            huntInteractionActive = false
            SyncNoisyEventSubscriptions()
        end
        return
    end

    if event == "QUEST_DETAIL"
        or event == "QUEST_PROGRESS"
        or event == "QUEST_COMPLETE"
    then
        if IsMissionFrameVisible() or huntInteractionActive or IsOptionsPreviewVisible() then
            QueueInteractionSnapshotPasses()
            return
        end

        local options = GetGossipOptionsSafe()
        local isHuntContext = IsHuntTableContext(options)
        if isHuntContext then
            QueueInteractionSnapshotPasses()
        end
        return
    end

    if event == "UPDATE_UI_WIDGET"
        or event == "UPDATE_ALL_UI_WIDGETS"
        or event == "QUEST_LOG_UPDATE"
    then
        if GetHasHuntContext() then
            QueueInteractionSnapshotPasses()
        end
        return
    end

    if event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" or event == "QUEST_FINISHED" then
        HidePanel()
        return
    end

    if event == "QUEST_DATA_LOAD_RESULT" then
        if IsMissionFrameVisible() or huntInteractionActive or IsOptionsPreviewVisible() then
            QueueInteractionSnapshotPasses()
        end
        return
    end
end)
