---@diagnostic disable
-- luacheck: ignore 561

local ADDON_NAME = ...

local CreateFrame = _G.CreateFrame
local PlaySoundFile = _G.PlaySoundFile
local C_Timer = _G.C_Timer
local ColorPickerFrame = _G.ColorPickerFrame
local OpacitySliderFrame = _G.OpacitySliderFrame
local Enum = _G.Enum
local C_QuestLog = _G["C_QuestLog"]
local C_TaskQuest = _G["C_TaskQuest"]
local C_Map = _G["C_Map"]
local C_SuperTrack = _G["C_SuperTrack"]
local UIParent = _G.UIParent
local GetTime = _G.GetTime
local IsInInstance = _G.IsInInstance
local SlashCmdList = _G["SlashCmdList"]
local Settings = _G["Settings"]
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton

_G.SLASH_PREYDATOR1 = "/pd"
_G.SLASH_PREYDATOR2 = nil

local PREY_PROGRESS_FINAL = 3
local MAX_STAGE = 4
local MAX_TICK_MARKS = 3
local WIDGET_SHOWN = 1
-- local IDLE_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-idle.ogg"
local ALERT_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-alert.ogg"
local AMBUSH_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-ambush.ogg"
local TORMENT_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-torment.ogg"
local KILL_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-kill.ogg"
local DEBUG_LOG_LIMIT = 200
local DEFAULT_OUT_OF_ZONE_LABEL = _G.PreydatorL["No Sign in These Fields"]
local DEFAULT_AMBUSH_LABEL = _G.PreydatorL["AMBUSH"]
local DEFAULT_BLOODY_COMMAND_LABEL = _G.PreydatorL["Bloody Command"]
local PROGRESS_SEGMENTS_QUARTERS = "quarters"
local PROGRESS_SEGMENTS_THIRDS = "thirds"
local BAR_TICK_PCTS_BY_SEGMENT = {
    [PROGRESS_SEGMENTS_QUARTERS] = { 25, 50, 75 },
    [PROGRESS_SEGMENTS_THIRDS] = { 33, 66 },
}
local PERCENT_DISPLAY_INSIDE = "inside"
local PERCENT_DISPLAY_INSIDE_BELOW = "inside_below"
local PERCENT_DISPLAY_BELOW_BAR = "below_bar"
PERCENT_DISPLAY_ABOVE_BAR = "above_bar"
PERCENT_DISPLAY_ABOVE_TICKS = "above_ticks"
local PERCENT_DISPLAY_UNDER_TICKS = "under_ticks"
local PERCENT_DISPLAY_OFF = "off"
local PERCENT_FALLBACK_STAGE = "stage"
local LAYER_MODE_ABOVE = "above"
local LAYER_MODE_BELOW = "below"
local LABEL_MODE_CENTER = "center"
local LABEL_MODE_LEFT = "left"
LABEL_MODE_LEFT_COMBINED = "left_combined"
local LABEL_MODE_LEFT_SUFFIX = "left_suffix"
local LABEL_MODE_RIGHT = "right"
LABEL_MODE_RIGHT_COMBINED = "right_combined"
local LABEL_MODE_RIGHT_PREFIX = "right_prefix"
local LABEL_MODE_SEPARATE = "separate"
local LABEL_MODE_NONE = "none"
LABEL_ROW_ABOVE = "above"
LABEL_ROW_BELOW = "below"
ORIENTATION_HORIZONTAL = "horizontal"
ORIENTATION_VERTICAL = "vertical"
FILL_DIRECTION_UP = "up"
FILL_DIRECTION_DOWN = "down"
local FILL_INSET = 3
local AMBUSH_ALERT_DURATION_SECONDS = 6
local AMBUSH_SOUND_COOLDOWN_SECONDS = 80
local QUEST_LISTEN_BURST_SECONDS = 6
local ACTIVE_PREY_QUEST_CACHE_SECONDS = 0.75
local AMBUSH_SOUND_ALERT = "alert"
local AMBUSH_SOUND_AMBUSH = "ambush"
local AMBUSH_SOUND_TORMENT = "torment"
local AMBUSH_SOUND_KILL = "kill"
local SOUND_FOLDER_PREFIX = "Interface\\AddOns\\Preydator\\sounds\\"
local DEFAULT_SOUND_FILENAMES = {
    "predator-alert.ogg",
    "predator-ambush.ogg",
    "predator-snarl-01.ogg",
    "predator-torment.ogg",
    "predator-kill.ogg",
    "well-we-ve-prepared-a-trap-for-this-predator.ogg",
    "predator-kills-its-prey-to-survive.ogg",
    "echo-of-predation.ogg",
}
local PROTECTED_SOUND_FILENAMES = {
    ["predator-alert.ogg"] = true,
    ["predator-ambush.ogg"] = true,
    ["predator-snarl-01.ogg"] = true,
    ["predator-torment.ogg"] = true,
    ["predator-kill.ogg"] = true,
    ["well-we-ve-prepared-a-trap-for-this-predator.ogg"] = true,
    ["predator-kills-its-prey-to-survive.ogg"] = true,
    ["echo-of-predation.ogg"] = true,
}

local function GetExternalSoundCatalog()
    local entries = {}
    local seenPaths = {}

    local function addEntry(path, text)
        if type(path) ~= "string" or path == "" or type(text) ~= "string" or text == "" then
            return
        end

        local key = string.lower(path)
        if seenPaths[key] then
            return
        end

        seenPaths[key] = true
        entries[#entries + 1] = {
            key = path,
            text = text,
        }
    end

    local libStub = _G.LibStub
    if type(libStub) == "table" and type(libStub.GetLibrary) == "function" then
        local ok, lsm = pcall(libStub.GetLibrary, libStub, "LibSharedMedia-3.0", true)
        if ok and type(lsm) == "table" and type(lsm.List) == "function" and type(lsm.Fetch) == "function" then
            local soundNames = lsm:List("sound") or {}
            for _, soundName in ipairs(soundNames) do
                if soundName ~= "None" then
                    local path = lsm:Fetch("sound", soundName)
                    addEntry(path, "LSM: " .. soundName)
                end
            end
        end
    end

    table.sort(entries, function(left, right)
        local leftText = string.lower(tostring(left and left.text or ""))
        local rightText = string.lower(tostring(right and right.text or ""))
        if leftText == rightText then
            return tostring(left and left.key or "") < tostring(right and right.key or "")
        end
        return leftText < rightText
    end)

    return entries
end
local DEFAULT_STAGE_LABELS = {
    [1] = _G.PreydatorL["Scent in the Wind"],
    [2] = _G.PreydatorL["Blood in the Shadows"],
    [3] = _G.PreydatorL["Echoes of the Kill"],
    [4] = _G.PreydatorL["Feast of the Fang"],
}
local STAGE_PCT_BY_SEGMENT = {
    [PROGRESS_SEGMENTS_QUARTERS] = {
        [1] = 25,
        [2] = 50,
        [3] = 75,
        [4] = 100,
    },
    [PROGRESS_SEGMENTS_THIRDS] = {
        [1] = 0,
        [2] = 33,
        [3] = 66,
        [4] = 100,
    },
}

local TEXTURE_PRESETS = {
    default = "Interface\\TARGETINGFRAME\\UI-StatusBar",
    flat = "Interface\\Buttons\\WHITE8x8",
    raid = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
    classic = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
}

local FONT_PRESETS = {
    frizqt = "Fonts\\FRIZQT__.TTF",
    arialn = "Fonts\\ARIALN.TTF",
    skurri = "Fonts\\SKURRI.TTF",
    morpheus = "Fonts\\MORPHEUS.TTF",
}

-- Astalor Bloodsworn (Bloody Command) sound file IDs sourced from Blizzard game data.
-- Applied via MuteSoundFile / UnmuteSoundFile to suppress ambient dialogue during hunts.
local ARATOR_SOUND_IDS = {
    7507693, 7507690, 7507696, 7507699, 7507702, 7507712, 7507722,
    7525928, 7525931, 7525934, 7525937, 7525940,
    7250945, 7250953, 7250960, 7250968, 7250975, 7250984, 7250991, 7250998,
    7263657,
    7372781, 7372784, 7372787, 7372790, 7372793, 7372796, 7372802,
    7507617, 7507629, 7507632, 7507637, 7507641, 7507656, 7507659, 7507663, 7507666,
    7250819, 7250822, 7250825, 7250828, 7250831, 7250835, 7250840, 7250843,
    7250849, 7250855, 7250861, 7250864, 7250867, 7250870, 7250873, 7250879,
    7250883, 7250888, 7250895, 7250902, 7250907, 7250912, 7250919, 7250931, 7250938,
    7250657, 7250661, 7250670, 7250676, 7250681, 7250686, 7250691, 7250700,
    7250705, 7250720, 7250747, 7250753, 7250760, 7250766, 7250771, 7250774,
    7250777, 7250780, 7250783, 7250786, 7250792, 7250795, 7250798, 7250801, 7250816,
    7250516, 7250520, 7250526, 7250532, 7250535, 7250538, 7250541, 7250544,
    7250550, 7250559, 7250562, 7250577, 7250583, 7250586, 7250591, 7250599,
    7250608, 7250614, 7250618, 7250629, 7250635, 7250642, 7250646, 7250652,
}

-- Forward declaration for helpers used before their implementation block.
local NormalizeSoundSettings
local GetSoundPathForKey
local IsValidQuestID
local ShouldSuppressDefaultPreyEncounter
local ApplyAratorSilencing

local DEFAULTS = {
    point = { anchor = "CENTER", relativePoint = "CENTER", x = 0, y = 472 },
    width = 160,
    height = 30,
    horizontalWidth = 160,
    horizontalHeight = 30,
    verticalWidth = 40,
    verticalHeight = 160,
    scale = 0.9,
    verticalScale = 0.9,
    fontSize = 12,
    locked = true,
    onlyShowInPreyZone = false,
    disableDefaultPreyIcon = false,
    showInEditMode = true,
    fillColor = { 0.85, 0.2, 0.2, 0.95 },
    bgColor = { 0, 0, 0, 0.6 },
    titleColor = { 1, 0.82, 0, 1 },
    percentColor = { 1, 1, 1, 1 },
    tickColor = { 1, 1, 1, 0.35 },
    sparkColor = { 1, 0.95, 0.75, 0.9 },
    textureKey = "default",
    titleFontKey = "frizqt",
    percentFontKey = "frizqt",
    outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL,
    outOfZonePrefix = "",
    ambushLabel = DEFAULT_AMBUSH_LABEL,
    ambushPrefix = "AMBUSH: ",
    ambushSuffix = "preyTargetName",
    bloodyCommandPrefix = "Bloody Command: ",
    bloodyCommandSuffix = "bloodyCommandSourceName",
    stageLabels = {
        [1] = DEFAULT_STAGE_LABELS[1],
        [2] = DEFAULT_STAGE_LABELS[2],
        [3] = DEFAULT_STAGE_LABELS[3],
        [4] = DEFAULT_STAGE_LABELS[4],
    },
    stageSounds = {
        [1] = AMBUSH_SOUND_PATH,
        [2] = "Interface\\AddOns\\Preydator\\sounds\\predator-snarl-01.ogg",
        [3] = TORMENT_SOUND_PATH,
        [4] = KILL_SOUND_PATH,
    },
    soundsEnabled = true,
    soundChannel = "SFX",
    silenceArator = false,
    soundEnhance = 0,
    soundFileNames = {
        "predator-alert.ogg",
        "predator-ambush.ogg",
        "predator-snarl-01.ogg",
        "predator-torment.ogg",
        "predator-kill.ogg",
        "well-we-ve-prepared-a-trap-for-this-predator.ogg",
        "predator-kills-its-prey-to-survive.ogg",
        "echo-of-predation.ogg",
    },
    debugSounds = false,
    debugBloodyCommand = false,
    currencyDebugEvents = false,
    currencyWindowEnabled = false,
    currencyMinimapButton = true,
    currencyMinimapAngle = 225,
    currencyMinimap = {
        hide = false,
        minimapPos = 225,
    },
    currencyWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 340, y = -80 },
    currencyWindowWidth = 276,
    currencyWindowHeight = 236,
    currencyWindowFontSize = 14,
    currencyWindowScale = 1,
    currencyWindowHideInInstance = false,
    currencyWarbandWindowEnabled = false,
    currencyWarbandWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 660, y = -80 },
    currencyWarbandWidth = 420,
    currencyWarbandHeight = 250,
    currencyWarbandFontSize = 12,
    currencyWarbandScale = 1,
    currencyWarbandWindowHideInInstance = false,
    currencyWarbandCollapsedRealms = {},
    currencyWarbandShowPreyTrack = true,
    currencyWarbandPreyMode = "available",
    currencyWarbandTrackedIDs = {
        [3392] = true,
        [3316] = true,
        [3383] = true,
        [3341] = true,
        [3343] = true,
    },
    currencyWarbandUseCurrencyTheme = true,
    currencyWarbandTheme = "brown",
    currencyShowAffordableHunts = false,
    currencyShowRealmInWarband = false,
    currencyTheme = "brown",
    currencyDeltaGainColor = { 0.00, 0.56, 0.32, 1 },
    currencyDeltaLossColor = { 0.72, 0.24, 0.15, 1 },
    currencyTrackedIDs = {
        [3392] = true,
        [3316] = true,
        [3383] = true,
        [3341] = true,
        [3343] = true,
    },
    randomHuntCosts = {
        normal = 50,
        hard = 50,
        nightmare = 0,
    },
    huntScannerEnabled = true,
    huntScannerSide = "right",
    huntScannerMatchCurrencyTheme = true,
    huntScannerUseCurrencyTheme = true,
    huntScannerTheme = "brown",
    huntScannerGroupBy = "difficulty",
    huntScannerSortBy = "zone",
    huntScannerSortDir = "asc",
    huntScannerWidth = 336,
    huntScannerHeight = 460,
    huntScannerFontSize = 12,
    huntScannerScale = 1.00,
    huntScannerAnchorAlign = "top",
    huntScannerCollapsedGroups = {},
    huntScannerPreviewInOptions = false,
    huntScannerRewardStyle = "icon_text",
    huntScannerDifficultyColors = {
        normal = { 0.42, 1.00, 0.56, 1.00 },
        hard = { 1.00, 0.67, 0.24, 1.00 },
        nightmare = { 1.00, 0.35, 0.35, 1.00 },
    },
    huntScannerAchievementSignals = true,
    huntScannerAchievementSignalStyle = "icon_count",
    huntScannerAchievementBadgeColor = { 1.00, 0.86, 0.00, 1.00 },
    huntScannerAchievementIconSize = 18,
    huntScannerAchievementShowCount = true,
    huntScannerAchievementTooltip = true,
    ambushSoundEnabled = true,
    ambushVisualEnabled = true,
    ambushSoundPath = "Interface\\AddOns\\Preydator\\sounds\\well-we-ve-prepared-a-trap-for-this-predator.ogg",
    bloodyCommandSoundEnabled = true,
    bloodyCommandVisualEnabled = true,
    bloodyCommandSoundPath = "Interface\\AddOns\\Preydator\\sounds\\predator-kills-its-prey-to-survive.ogg",
    echoOfPredationSoundPath = "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg",
    soundDefaultsPromptSeenVersion = nil,
    showTicks = true,
    showSparkLine = false,
    tickLayerMode = LAYER_MODE_ABOVE,
    labelRowPosition = "above",
    orientation = "horizontal",
    verticalFillDirection = "up",
    verticalTextSide = "right",
    verticalPercentSide = "center",
    showVerticalTickPercent = false,
    verticalPercentDisplay = PERCENT_DISPLAY_INSIDE,
    verticalTextOffset = 10,
    verticalPercentOffset = 10,
    verticalTextAlign = "separate",
    showAlignmentDot = false,
    verticalSideOffset = 10,
    progressSegments = PROGRESS_SEGMENTS_THIRDS,
    stageLabelMode = LABEL_MODE_CENTER,
    stageSuffixLabels = {
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    borderColorLinked = true,
    borderColor = { 0.8, 0.2, 0.2, 0.85 },
    percentDisplay = PERCENT_DISPLAY_INSIDE,
    percentFallbackMode = PERCENT_FALLBACK_STAGE,
    customizationV2 = {
        moduleEnabled = {
            bar = true,
            sounds = true,
            currency = true,
            hunt = true,
            warband = true,
        },
    },
}

local settings
local debugDB
local Preydator = _G.Preydator or {}
_G.Preydator = Preydator
Preydator.modules = Preydator.modules or {}

function Preydator:RegisterModule(name, module)
    if type(name) ~= "string" or name == "" or type(module) ~= "table" then
        return
    end

    module.name = name
    self.modules[name] = module
end

function Preydator:GetModule(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return self.modules and self.modules[name] or nil
end

-- CustomizationStateV2: Manages module enable/disable state
local CustomizationStateV2 = {
    name = "CustomizationStateV2",
}

function CustomizationStateV2:IsModuleEnabled(moduleKey)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        return true
    end

    local db = settings or _G.PreydatorDB or {}
    local custV2 = db.customizationV2 or {}
    local moduleState = custV2.moduleEnabled or {}

    -- Default to true if not explicitly set to false
    if moduleState[moduleKey] == nil then
        return true
    end
    return moduleState[moduleKey] == true
end

function CustomizationStateV2:Set(path, value)
    if type(path) ~= "string" or path == "" then
        return
    end

    local db = settings or _G.PreydatorDB or {}
    db.customizationV2 = db.customizationV2 or {}
    db.customizationV2.moduleEnabled = db.customizationV2.moduleEnabled or {}

    -- Parse path like "customizationV2.moduleEnabled.bar"
    local parts = {}
    for part in string.gmatch(path, "[^.]+") do
        parts[#parts + 1] = part
    end

    if #parts == 3 and parts[1] == "customizationV2" and parts[2] == "moduleEnabled" then
        local moduleKey = parts[3]
        if type(moduleKey) == "string" and moduleKey ~= "" then
            db.customizationV2.moduleEnabled[moduleKey] = value and true or false
        end
    end
end

Preydator:RegisterModule("CustomizationStateV2", CustomizationStateV2)

local frame = CreateFrame("Frame")
local warnedMissingSoundPaths = {}

-- UI frame references grouped in a table to reduce local variable count from ~30 to 1
local UI = {
    barFrame = false,
    barFillContainer = false,
    barFill = false,
    barSpark = false,
    barText = false,
    stageText = false,
    stageSuffixText = false,
    barAlignmentDot = false,
    barBorder = false,
    barTickMarks = {},
    barTickLabels = {},
    optionsPanel = false,
    optionsCategoryID = false,
    optionsScrollFrame = false,
    optionsContentFrame = false,
    colorPickerSessionCounter = 0,
}

local EnsureOptionsPanel
local OpenOptionsPanel
local AddDebugLog
local TryPlaySound
local TryPlayStageSound
local TryPlayEchoOfPredationEncounter
local TryHandleEchoOfPredationNameplate
local UpdateBarDisplay
local ApplyBarSettings
local ApplyDefaultPreyIconVisibility
local TryOpenPreyQuestOnMap
local IsAnyTrackedPreyWidgetShown
local BarRuntimeApplyHandler
local BarRuntimeUpdateHandler
local OnBlizzardWidgetsLoaded
local OnPlayerRegenEnabled
function Preydator:ApplyNewSoundDefaults()
    if type(settings) ~= "table" then
        return false
    end

    settings.stageSounds = settings.stageSounds or {}
    settings.stageSounds[1] = AMBUSH_SOUND_PATH
    settings.stageSounds[2] = "Interface\\AddOns\\Preydator\\sounds\\predator-snarl-01.ogg"
    settings.stageSounds[3] = TORMENT_SOUND_PATH
    settings.stageSounds[4] = KILL_SOUND_PATH

    settings.ambushSoundPath = "Interface\\AddOns\\Preydator\\sounds\\well-we-ve-prepared-a-trap-for-this-predator.ogg"
    settings.bloodyCommandSoundPath = "Interface\\AddOns\\Preydator\\sounds\\predator-kills-its-prey-to-survive.ogg"
    settings.echoOfPredationSoundPath = "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg"

    settings.soundFileNames = settings.soundFileNames or {}
    local seen = {}
    for _, fileName in ipairs(settings.soundFileNames) do
        if type(fileName) == "string" and fileName ~= "" then
            seen[string.lower(fileName)] = true
        end
    end
    for _, fileName in ipairs(DEFAULT_SOUND_FILENAMES) do
        local key = string.lower(fileName)
        if not seen[key] then
            settings.soundFileNames[#settings.soundFileNames + 1] = fileName
            seen[key] = true
        end
    end

    NormalizeSoundSettings()
    if self and self.API and type(self.API.NormalizeAmbushSettings) == "function" then
        self.API.NormalizeAmbushSettings()
    end
    UpdateBarDisplay()
    return true
end

function Preydator:EnsureSoundDefaultsPromptFrame()
    if self and self._soundDefaultsPromptFrame then
        return self._soundDefaultsPromptFrame
    end

    local frame = CreateFrame("Frame", "PreydatorSoundDefaultsPromptFrame", UIParent, "BackdropTemplate")
    frame:SetSize(560, 230)
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
    frame:SetBackdropBorderColor(0.78, 0.62, 0.20, 1)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -18)
    title:SetText("Preydator Audio Defaults (2.2.0)")

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -52)
    body:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -52)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetWordWrap(true)
    body:SetText("We have created new default sounds. To move to these defaults, click New Defaults.\n\nTo keep your current defaults, just close this message.")

    local newDefaultsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    newDefaultsButton:SetSize(140, 24)
    newDefaultsButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 16)
    newDefaultsButton:SetText("New Defaults")

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(120, 24)
    closeButton:SetPoint("RIGHT", newDefaultsButton, "LEFT", -8, 0)
    closeButton:SetText("Close")

    newDefaultsButton:SetScript("OnClick", function()
        if Preydator:ApplyNewSoundDefaults() then
            print("Preydator: Applied 2.2.0 audio defaults.")
        end
        if settings then
            settings.soundDefaultsPromptSeenVersion = "2.2.0-sound-defaults"
        end
        frame:Hide()
    end)

    closeButton:SetScript("OnClick", function()
        if settings then
            settings.soundDefaultsPromptSeenVersion = "2.2.0-sound-defaults"
        end
        frame:Hide()
    end)

    frame:Hide()
    self._soundDefaultsPromptFrame = frame
    return frame
end

function Preydator:ShowSoundDefaultsPromptIfNeeded()
    if type(settings) ~= "table" then
        return
    end

    -- Retire the legacy 2.2.0 prompt so updates cannot accidentally replace
    -- existing user-selected sound mappings.
    settings.soundDefaultsPromptSeenVersion = "2.2.9-sound-prompt-retired"
end

local function RunModuleHook(hookName, ...)
    for _, module in pairs(Preydator.modules) do
        local fn = module and module[hookName]
        if type(fn) == "function" then
            pcall(fn, module, ...)
        end
    end
end

local state = {
    activeQuestID = nil,
    progressState = nil,
    progressPercent = nil,
    stageSoundPlayed = {},
    stageSoundAttempted = {},
    forceShowBar = false,
    killStageUntil = 0,
    stage = 1,
    preyZoneName = nil,
    preyZoneMapID = nil,
    confirmedPreyZoneMapID = nil,
    inPreyZone = nil,
    preyTooltipText = nil,
    elapsedSinceUpdate = 0,
    lastWidgetSeenAt = 0,
    lastWidgetSetupAt = 0,
    lastWidgetBoundQuestID = nil,
    lastStateDebugSnapshot = nil,
    lastDisplayPct = 0,
    lastDisplayReason = "init",
    lastPercentSource = "none",
    preyTargetName = nil,
    preyTargetDifficulty = nil,
    ambushAlertUntil = 0,
    lastAmbushSoundAt = 0,
    lastEchoOfPredationSoundAt = 0,
    lastAmbushSystemMessage = nil,
    ambushSourceName = nil,
    bloodyCommandAlertUntil = 0,
    bloodyCommandSourceName = nil,
    lastBloodyCommandSpellID = nil,
    lastNotifiedPreyEndQuestID = nil,
    questListenUntil = 0,
    cachedActivePreyQuestID = nil,
    cachedActivePreyQuestAt = 0,
    playerMapID = nil,
    playerMapHierarchy = nil,
    zoneCacheDirty = true,
    pollingActive = false,
    nextPollingEligibilityCheckAt = 0,
    pendingWidgetSuppressionAfterCombat = false,
    corePreyEventsRegistered = false,
}

local UPDATE_INTERVAL_SECONDS = 0.5
local WIDGET_SETUP_FRESH_SECONDS = 2.0
local ExtractWidgetQuestID
local FindPreyWidgetProgressState

Preydator.GetState = function()
    return state
end

Preydator.GetSettings = function()
    return settings
end

Preydator.GetBarFrame = function()
    return UI.barFrame
end

Preydator.GetLabelFrames = function()
    return {
        prefix = UI.stageText,
        suffix = UI.stageSuffixText,
        percent = UI.barText,
        centerDot = UI.barAlignmentDot,
    }
end

Preydator.RequestRefresh = function()
    if type(UpdateBarDisplay) == "function" then
        UpdateBarDisplay()
    end
end

local function ApplyDefaults(dst, src)
    for key, value in pairs(src) do
        if type(value) == "table" then
            if type(dst[key]) ~= "table" then
                dst[key] = {}
            end
            ApplyDefaults(dst[key], value)
        elseif dst[key] == nil then
            dst[key] = value
        end
    end
end

local function GetStageLabel(stage)
    if settings and settings.stageLabels then
        local customLabel = settings.stageLabels[stage]
        if type(customLabel) == "string" and customLabel ~= "" then
            return customLabel
        end
    end

    return DEFAULT_STAGE_LABELS[stage] or "Unknown"
end

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function RoundToStep(value, step)
    if not step or step <= 0 then
        return value
    end

    return math.floor((value / step) + 0.5) * step
end

local function NormalizeSliderValue(value, minValue, maxValue, step)
    local numeric = tonumber(value)
    if not numeric then
        return nil
    end

    numeric = Clamp(numeric, minValue, maxValue)
    numeric = RoundToStep(numeric, step)
    return Clamp(numeric, minValue, maxValue)
end

local function CreateCheckboxControl(parent, x, y, label, getter, setter, options)
    options = type(options) == "table" and options or {}

    local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    check.Text:SetText(label)
    check:SetChecked(getter() and true or false)
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
    end)

    function check:PreydatorRefresh()
        self:SetChecked(getter() and true or false)
    end

    if options.withSetEnabled == true then
        function check:PreydatorSetEnabled(enabled)
            local isEnabled = enabled and true or false
            self:SetAlpha(isEnabled and 1 or 0.45)
            self:SetEnabled(isEnabled)
            if self.EnableMouse then
                self:EnableMouse(isEnabled)
            end
        end
    end

    return check
end

local function CreateSliderControl(parent, x, y, label, minValue, maxValue, step, getter, setter, formatValue, options)
    options = type(options) == "table" and options or {}

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(options.containerWidth or 250, options.containerHeight or 54)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(label)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetWidth(options.sliderWidth or 165)
    slider:SetScale(options.sliderScale or 1)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    if slider.Low then slider.Low:Hide() end
    if slider.High then slider.High:Hide() end

    local valueBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    valueBox:SetSize(options.valueBoxWidth or 52, options.valueBoxHeight or 20)
    valueBox:SetPoint("LEFT", slider, "RIGHT", options.valueBoxOffsetX or 10, 0)
    valueBox:SetAutoFocus(false)
    valueBox:SetTextInsets(6, 6, 0, 0)
    valueBox:SetJustifyH("CENTER")

    local formatter = formatValue or function(value)
        if step and step < 1 then
            return string.format("%.2f", value)
        end
        return tostring(math.floor(value + 0.5))
    end

    local function RefreshFromValue(rawValue)
        local normalized = NormalizeSliderValue(rawValue, minValue, maxValue, step)
        if normalized == nil then
            normalized = getter()
        end
        slider:SetValue(normalized)
        valueBox:SetText(formatter(normalized))
    end

    slider:SetScript("OnValueChanged", function(_, value)
        local normalized = NormalizeSliderValue(value, minValue, maxValue, step)
        if normalized == nil then
            return
        end

        valueBox:SetText(formatter(normalized))
        setter(normalized)
    end)

    valueBox:SetScript("OnEnterPressed", function(self)
        local normalized = NormalizeSliderValue(self:GetText(), minValue, maxValue, step)
        if normalized == nil then
            self:SetText(formatter(getter()))
            self:ClearFocus()
            return
        end

        slider:SetValue(normalized)
        self:ClearFocus()
    end)

    valueBox:SetScript("OnEditFocusLost", function(self)
        self:SetText(formatter(getter()))
    end)

    function container:PreydatorRefresh()
        RefreshFromValue(getter())
    end

    if options.withSetEnabled == true then
        function container:PreydatorSetEnabled(enabled)
            local isEnabled = enabled and true or false
            self:SetAlpha(isEnabled and 1 or 0.45)
            slider:SetEnabled(isEnabled)
            valueBox:SetEnabled(isEnabled)
            if valueBox.SetTextColor then
                local channel = isEnabled and 1 or 0.65
                valueBox:SetTextColor(channel, channel, channel)
            end
        end
    end

    container:PreydatorRefresh()
    return container
end

local function Round(value)
    if value >= 0 then
        return math.floor(value + 0.5)
    end

    return math.ceil(value - 0.5)
end

local function GetRuntimeModule(moduleName)
    if not (Preydator and type(Preydator.GetModule) == "function") then
        return nil
    end

    local runtime = Preydator:GetModule(moduleName)
    if type(runtime) == "table" then
        return runtime
    end

    return nil
end

local function NormalizeLabelSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeLabelSettings) == "function" then
        runtime:NormalizeLabelSettings(settings, {
            maxStage = MAX_STAGE,
            defaultStageLabels = DEFAULT_STAGE_LABELS,
            defaultOutOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL,
            defaultAmbushLabel = DEFAULT_AMBUSH_LABEL,
            defaultBloodyCommandLabel = DEFAULT_BLOODY_COMMAND_LABEL,
        })
        return
    end

    if type(settings.stageLabels) ~= "table" then
        settings.stageLabels = {}
    end

    for stage = 1, MAX_STAGE do
        local label = settings.stageLabels[stage]
        if type(label) ~= "string" then
            local legacy = settings.stageLabels[tostring(stage)]
            if type(legacy) == "string" then
                label = legacy
            end
        end

        if type(label) ~= "string" then
            label = DEFAULT_STAGE_LABELS[stage] or ""
        end

        settings.stageLabels[stage] = label
    end

    if type(settings.outOfZoneLabel) ~= "string" or settings.outOfZoneLabel == "" then
        settings.outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL
    end

    if type(settings.outOfZonePrefix) ~= "string" then
        settings.outOfZonePrefix = ""
    end

    if type(settings.ambushLabel) ~= "string" or settings.ambushLabel == "" then
        settings.ambushLabel = DEFAULT_AMBUSH_LABEL
    end

    if type(settings.ambushPrefix) ~= "string" then
        settings.ambushPrefix = "AMBUSH: "
    end

    if type(settings.ambushSuffix) ~= "string" then
        settings.ambushSuffix = "preyTargetName"
    end

    if type(settings.bloodyCommandPrefix) ~= "string" then
        settings.bloodyCommandPrefix = "Bloody Command: "
    end

    if type(settings.bloodyCommandSuffix) ~= "string" then
        settings.bloodyCommandSuffix = "bloodyCommandSourceName"
    end

    -- One-way migration from legacy 2.2.7 text settings.
    if settings.ambushSuffix == "preyTargetName" and settings.ambushPrefix == "" then
        settings.ambushPrefix = "AMBUSH: "
    end

    if settings.bloodyCommandSuffix == "bloodyCommandSourceName" and settings.bloodyCommandPrefix == "" then
        settings.bloodyCommandPrefix = "Bloody Command: "
    end
end

local function NormalizeColorSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeColorSettings) == "function" then
        runtime:NormalizeColorSettings(settings, {
            defaults = DEFAULTS,
            clamp = Clamp,
        })
        return
    end

    local function normalizeColor(source, fallback)
        local color = type(source) == "table" and source or {}
        local r = Clamp(tonumber(color[1] or color.r) or fallback[1], 0, 1)
        local g = Clamp(tonumber(color[2] or color.g) or fallback[2], 0, 1)
        local b = Clamp(tonumber(color[3] or color.b) or fallback[3], 0, 1)
        local a = Clamp(tonumber(color[4] or color.a) or fallback[4], 0, 1)
        return { r, g, b, a }
    end

    settings.fillColor = normalizeColor(settings.fillColor, DEFAULTS.fillColor)
    settings.bgColor = normalizeColor(settings.bgColor, DEFAULTS.bgColor)
    settings.titleColor = normalizeColor(settings.titleColor, DEFAULTS.titleColor)
    settings.percentColor = normalizeColor(settings.percentColor, DEFAULTS.percentColor)
    settings.tickColor = normalizeColor(settings.tickColor, DEFAULTS.tickColor)
    settings.sparkColor = normalizeColor(settings.sparkColor, DEFAULTS.sparkColor)
    settings.borderColor = normalizeColor(settings.borderColor, DEFAULTS.borderColor)
    if settings.borderColorLinked == nil then
        settings.borderColorLinked = true
    end
end

local function NormalizeDisplaySettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeDisplaySettings) == "function" then
        runtime:NormalizeDisplaySettings(settings, {
            constants = Preydator.Constants,
            defaults = DEFAULTS,
            maxStage = MAX_STAGE,
            clamp = Clamp,
        })
        return
    end

    settings.showTicks = settings.showTicks ~= false
    settings.showSparkLine = settings.showSparkLine == true
    settings.showInEditMode = settings.showInEditMode ~= false

    local mode = settings.percentDisplay
    if mode == "below" then
        mode = PERCENT_DISPLAY_BELOW_BAR
    end

    if mode ~= PERCENT_DISPLAY_INSIDE
        and mode ~= PERCENT_DISPLAY_BELOW_BAR
        and mode ~= "above_bar"
        and mode ~= "above_ticks"
        and mode ~= PERCENT_DISPLAY_UNDER_TICKS
        and mode ~= PERCENT_DISPLAY_OFF
    then
        settings.percentDisplay = PERCENT_DISPLAY_INSIDE
    else
        settings.percentDisplay = mode
    end

    settings.tickLayerMode = LAYER_MODE_ABOVE

    settings.percentFallbackMode = PERCENT_FALLBACK_STAGE

    local labelMode = settings.stageLabelMode
    if labelMode ~= LABEL_MODE_CENTER
        and labelMode ~= LABEL_MODE_LEFT
        and labelMode ~= "left_combined"
        and labelMode ~= LABEL_MODE_LEFT_SUFFIX
        and labelMode ~= LABEL_MODE_RIGHT
        and labelMode ~= "right_combined"
        and labelMode ~= LABEL_MODE_RIGHT_PREFIX
        and labelMode ~= LABEL_MODE_SEPARATE
        and labelMode ~= LABEL_MODE_NONE
    then
        settings.stageLabelMode = LABEL_MODE_CENTER
    end

    if settings.labelRowPosition ~= "above" and settings.labelRowPosition ~= "below" then
        settings.labelRowPosition = "above"
    end

    if settings.orientation ~= "horizontal" and settings.orientation ~= "vertical" then
        settings.orientation = "horizontal"
    end

    if settings.verticalFillDirection ~= "up" and settings.verticalFillDirection ~= "down" then
        settings.verticalFillDirection = "up"
    end

    if settings.verticalTextSide ~= "left" and settings.verticalTextSide ~= "right" then
        settings.verticalTextSide = "right"
    end

    -- migrate old "off" and "inside" values to new vocabulary
    if settings.verticalPercentSide == "off" then
        settings.verticalPercentSide = "center"
    elseif settings.verticalPercentSide == "inside" then
        settings.verticalPercentSide = "center"
    end
    if settings.verticalPercentSide ~= "left"
        and settings.verticalPercentSide ~= "center"
        and settings.verticalPercentSide ~= "right"
    then
        settings.verticalPercentSide = "center"
    end

    local verticalPercentDisplay = settings.verticalPercentDisplay
    if verticalPercentDisplay == PERCENT_DISPLAY_INSIDE_BELOW then
        verticalPercentDisplay = PERCENT_DISPLAY_INSIDE
    end
    if verticalPercentDisplay ~= PERCENT_DISPLAY_INSIDE
        and verticalPercentDisplay ~= PERCENT_DISPLAY_BELOW_BAR
        and verticalPercentDisplay ~= PERCENT_DISPLAY_ABOVE_BAR
        and verticalPercentDisplay ~= PERCENT_DISPLAY_OFF
    then
        settings.verticalPercentDisplay = PERCENT_DISPLAY_INSIDE
    else
        settings.verticalPercentDisplay = verticalPercentDisplay
    end

    if settings.percentDisplay == PERCENT_DISPLAY_INSIDE_BELOW then
        settings.percentDisplay = PERCENT_DISPLAY_INSIDE
    end

    settings.showAlignmentDot = false

    local verticalTextAlign = settings.verticalTextAlign
    if verticalTextAlign ~= "top"
        and verticalTextAlign ~= "middle"
        and verticalTextAlign ~= "bottom"
        and verticalTextAlign ~= "top_prefix_only"
        and verticalTextAlign ~= "top_suffix_only"
        and verticalTextAlign ~= "bottom_prefix_only"
        and verticalTextAlign ~= "bottom_suffix_only"
        and verticalTextAlign ~= "separate"
    then
        settings.verticalTextAlign = "separate"
    end

    local legacyWidth = tonumber(settings.width)
    local legacyHeight = tonumber(settings.height)

    local horizontalWidth = tonumber(settings.horizontalWidth)
    if not horizontalWidth then
        horizontalWidth = legacyWidth or DEFAULTS.horizontalWidth
    end
    settings.horizontalWidth = Clamp(math.floor(horizontalWidth + 0.5), 100, 350)

    local horizontalHeight = tonumber(settings.horizontalHeight)
    if not horizontalHeight then
        horizontalHeight = legacyHeight or DEFAULTS.horizontalHeight
    end
    settings.horizontalHeight = Clamp(math.floor(horizontalHeight + 0.5), 10, 60)

    local verticalWidth = tonumber(settings.verticalWidth)
    if not verticalWidth then
        if settings.orientation == ORIENTATION_VERTICAL and legacyWidth then
            verticalWidth = legacyWidth
        else
            verticalWidth = DEFAULTS.verticalWidth
        end
    end
    settings.verticalWidth = Clamp(math.floor(verticalWidth + 0.5), 10, 60)

    local verticalHeight = tonumber(settings.verticalHeight)
    if not verticalHeight then
        if settings.orientation == ORIENTATION_VERTICAL and legacyHeight then
            verticalHeight = legacyHeight
        else
            verticalHeight = DEFAULTS.verticalHeight
        end
    end
    settings.verticalHeight = Clamp(math.floor(verticalHeight + 0.5), 100, 350)

    local legacySideOffset = tonumber(settings.verticalSideOffset)
    if not legacySideOffset then
        legacySideOffset = 10
    end

    local verticalTextOffset = tonumber(settings.verticalTextOffset)
    if not verticalTextOffset then
        verticalTextOffset = legacySideOffset
    end
    settings.verticalTextOffset = Clamp(math.floor(verticalTextOffset + 0.5), 2, 60)

    local verticalPercentOffset = tonumber(settings.verticalPercentOffset)
    if not verticalPercentOffset then
        verticalPercentOffset = legacySideOffset
    end
    settings.verticalPercentOffset = Clamp(math.floor(verticalPercentOffset + 0.5), 2, 60)

    settings.verticalSideOffset = settings.verticalTextOffset

    if settings.orientation == ORIENTATION_VERTICAL then
        settings.width = settings.verticalWidth
        settings.height = settings.verticalHeight
    else
        settings.width = settings.horizontalWidth
        settings.height = settings.horizontalHeight
    end

    if type(settings.point) ~= "table" then
        settings.point = {}
    end
    settings.point.anchor = "CENTER"
    settings.point.relativePoint = "CENTER"
    if settings.point.x ~= nil then
        settings.point.x = Round(tonumber(settings.point.x) or 0)
    end
    if settings.point.y ~= nil then
        settings.point.y = Round(tonumber(settings.point.y) or 0)
    end

    if type(settings.stageSuffixLabels) ~= "table" then
        settings.stageSuffixLabels = {}
    end
    for i = 1, MAX_STAGE do
        if type(settings.stageSuffixLabels[i]) ~= "string" then
            settings.stageSuffixLabels[i] = ""
        end
    end
end

Preydator.GetRenderedVerticalPercent = function(rawPct, fillDirection)
    if fillDirection == FILL_DIRECTION_DOWN then
        return 100 - rawPct
    end

    return rawPct
end

Preydator.ResolveVerticalTextAnchor = function(side, align, offset, isSuffix)
    local sidePoint = (side == "left") and "LEFT" or "RIGHT"
    local topAnchor = "TOP" .. sidePoint
    local middleAnchor = sidePoint
    local bottomAnchor = "BOTTOM" .. sidePoint

    local relSidePoint = sidePoint
    local topRelative = "TOP" .. relSidePoint
    local middleRelative = relSidePoint
    local bottomRelative = "BOTTOM" .. relSidePoint
    local xOffset = (side == "left") and -(offset + FILL_INSET) or (offset + FILL_INSET)
    local gap = 14

    if align == "top" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return "TOPRIGHT", topRelative, xOffset, -(gap + 10)
        end
        local y = -2
        return "TOPLEFT", topRelative, xOffset, y
    end

    if align == "middle" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", middleRelative, xOffset, math.floor(gap / 2)
            end
            return "BOTTOMLEFT", middleRelative, xOffset, -math.floor(gap / 2)
        end
        if isSuffix then
            return "BOTTOM" .. sidePoint, middleRelative, xOffset, math.floor(gap / 2)
        end
        return "TOP" .. sidePoint, middleRelative, xOffset, -math.floor(gap / 2)
    end

    if align == "bottom" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", bottomRelative, xOffset, -(gap + 10)
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        local y = -10
        return bottomAnchor, bottomRelative, xOffset, y
    end

    if align == "top_prefix_only" then
        if side == "left" then
            if isSuffix then
                return bottomAnchor, bottomRelative, xOffset, -10
            end
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        if isSuffix then
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        return "TOPLEFT", topRelative, xOffset, -2
    end

    if align == "top_suffix_only" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        if isSuffix then
            return "TOPLEFT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if align == "bottom_prefix_only" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        if isSuffix then
            return "TOPLEFT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if align == "bottom_suffix_only" then
        if side == "left" then
            if isSuffix then
                return bottomAnchor, bottomRelative, xOffset, -10
            end
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        if isSuffix then
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        return "TOPLEFT", topRelative, xOffset, -2
    end

    if side == "left" then
        if isSuffix then
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if isSuffix then
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    return "TOPLEFT", topRelative, xOffset, -2
end

local function NormalizeProgressSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeProgressSettings) == "function" then
        runtime:NormalizeProgressSettings(settings, {
            constants = Preydator.Constants,
        })
        return
    end

    local mode = settings.progressSegments
    if mode ~= PROGRESS_SEGMENTS_QUARTERS and mode ~= PROGRESS_SEGMENTS_THIRDS then
        settings.progressSegments = PROGRESS_SEGMENTS_QUARTERS
        return
    end

    settings.progressSegments = mode
end

local function NormalizeTransientSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeTransientSettings) == "function" then
        runtime:NormalizeTransientSettings(settings)
        return
    end

    -- Legacy migration: older builds persisted this debug/session flag in SavedVariables.
    -- Keep an explicit false value so stale true values are always corrected on next save.
    settings.forceShowBar = false
    settings.debugBloodyCommand = settings.debugBloodyCommand == true
end

local function NormalizeAmbushSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeAmbushSettings) == "function" then
        runtime:NormalizeAmbushSettings(settings, {
            ambushDefaultSoundPath = "Interface\\AddOns\\Preydator\\sounds\\well-we-ve-prepared-a-trap-for-this-predator.ogg",
            bloodyDefaultSoundPath = "Interface\\AddOns\\Preydator\\sounds\\predator-kills-its-prey-to-survive.ogg",
            echoSoundPath = "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg",
            getSoundPathForKey = GetSoundPathForKey,
        })
        return
    end

    settings.ambushSoundEnabled = settings.ambushSoundEnabled ~= false
    settings.ambushVisualEnabled = settings.ambushVisualEnabled ~= false
    settings.bloodyCommandSoundEnabled = settings.bloodyCommandSoundEnabled ~= false
    settings.bloodyCommandVisualEnabled = settings.bloodyCommandVisualEnabled ~= false

    if type(settings.ambushSoundPath) ~= "string" or settings.ambushSoundPath == "" then
        local legacySoundKey = settings.ambushSoundKey
        settings.ambushSoundPath = GetSoundPathForKey(legacySoundKey, "Interface\\AddOns\\Preydator\\sounds\\well-we-ve-prepared-a-trap-for-this-predator.ogg")
    end

    if type(settings.bloodyCommandSoundPath) ~= "string" or settings.bloodyCommandSoundPath == "" then
        settings.bloodyCommandSoundPath = "Interface\\AddOns\\Preydator\\sounds\\predator-kills-its-prey-to-survive.ogg"
    end

    if type(settings.echoOfPredationSoundPath) ~= "string" or settings.echoOfPredationSoundPath == "" then
        settings.echoOfPredationSoundPath = "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg"
    end

    settings.ambushSoundKey = nil
    settings.ambushCustomSoundPath = nil
end

local FALLBACK_MAP_ID_EQUIVALENTS = {
    [2437] = 2437,
    [2536] = 2437,
    [2537] = 2437,
    [2413] = 2413,
    [2576] = 2413,
    [2405] = 2405,
    [2444] = 2405,
}

local function CanonicalizeFallbackMapID(mapID)
    local okString, asString = pcall(tostring, mapID)
    if not okString or type(asString) ~= "string" then
        return nil
    end

    local numericToken = string.match(asString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
        or string.match(asString, "^%s*([%+%-]?%d*%.%d+)%s*$")
    if not numericToken then
        return nil
    end

    local okNumber, parsedMapID = pcall(tonumber, numericToken)
    mapID = okNumber and parsedMapID or nil
    if not mapID or mapID < 1 then
        return nil
    end
    return FALLBACK_MAP_ID_EQUIVALENTS[mapID] or mapID
end

local function IsPreyQuestOnCurrentMap(questID)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.IsPreyQuestOnCurrentMap) == "function" then
        return runtime:IsPreyQuestOnCurrentMap(questID, {
            questLog = C_QuestLog,
            taskQuestApi = C_TaskQuest,
        })
    end

    if not (questID and C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo) then
        return nil
    end

    local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then
        return nil
    end

    local info = C_QuestLog.GetInfo(logIndex)
    if type(info) ~= "table" then
        return nil
    end

    if info.isOnMap == nil then
        return nil
    end

    return info.isOnMap == true
end

local function RefreshInPreyZoneStatus(questID, force)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.RefreshInPreyZoneStatus) == "function" then
        return runtime:RefreshInPreyZoneStatus(questID, force, state, {
            isValidQuestID = IsValidQuestID,
            getTime = GetTime,
            mapApi = C_Map,
            questLog = C_QuestLog,
            taskQuestApi = C_TaskQuest,
            isTrackedPreyWidgetShown = function()
                return IsAnyTrackedPreyWidgetShown()
            end,
            isTrackedPreyWidgetPresent = function()
                if preyHuntIconFrame ~= nil then
                    return true
                end

                for frameRef in pairs(PREY_WIDGET_FRAMES) do
                    if frameRef ~= nil then
                        return true
                    end
                end

                return false
            end,
            getQuestZoneMapIDFromHuntScanner = function(numericQuestID)
                if not IsValidQuestID(numericQuestID) then
                    return nil
                end

                local huntScanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
                if not (huntScanner and type(huntScanner.GetQuestZoneMapID) == "function") then
                    return nil
                end

                local okMapID, rawMapID = pcall(huntScanner.GetQuestZoneMapID, huntScanner, numericQuestID)
                if not okMapID then
                    return nil
                end

                return CanonicalizeFallbackMapID(rawMapID)
            end,
        })
    end

    if not IsValidQuestID(questID) then
        state.inPreyZone = nil
        return nil
    end

    local now = GetTime and GetTime() or 0

    local shouldRefresh = force == true or state.inPreyZone == nil or state.zoneCacheDirty == true
    if not shouldRefresh then
        return state.inPreyZone
    end

    local playerMapID = nil
    if C_Map and C_Map.GetBestMapForUnit then
        local okMapID, rawMapID = pcall(C_Map.GetBestMapForUnit, "player")
        if okMapID then
            local parsedMapID = nil
            local okMapString, mapAsString = pcall(tostring, rawMapID)
            if okMapString and type(mapAsString) == "string" then
                local numericToken = string.match(mapAsString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
                    or string.match(mapAsString, "^%s*([%+%-]?%d*%.%d+)%s*$")
                if numericToken then
                    local okNumber, numericValue = pcall(tonumber, numericToken)
                    if okNumber and type(numericValue) == "number" then
                        parsedMapID = numericValue
                    end
                end
            end
            playerMapID = CanonicalizeFallbackMapID(parsedMapID)
        end
    end

    local questMapID = CanonicalizeFallbackMapID(state.preyZoneMapID)
    if not questMapID then
        local zoneName, resolvedMapID = GetPreyZoneInfo(questID)
        if zoneName ~= nil then
            state.preyZoneName = zoneName
        end
        if resolvedMapID ~= nil then
            state.preyZoneMapID = resolvedMapID
            questMapID = CanonicalizeFallbackMapID(resolvedMapID)
        end
    end

    if not questMapID then
        if IsValidQuestID(questID) then
            local huntScanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
            if huntScanner and type(huntScanner.GetQuestZoneMapID) == "function" then
                local okMapID, rawMapID = pcall(huntScanner.GetQuestZoneMapID, huntScanner, questID)
                if okMapID then
                    local scannerMapID = CanonicalizeFallbackMapID(rawMapID)
                    if scannerMapID then
                        questMapID = scannerMapID
                        state.preyZoneMapID = scannerMapID
                    end
                end
            end
        end
    end

    if not questMapID then
        questMapID = CanonicalizeFallbackMapID(state.confirmedPreyZoneMapID)
    end

    -- Do not infer quest zone from the current player map when quest-map APIs
    -- are unresolved. This can incorrectly mark in-zone when the player is in a
    -- different prey zone than the active quest.

    local inPreyZone = nil
    if questMapID and playerMapID then
        inPreyZone = (playerMapID == questMapID)
    end

    if inPreyZone == true then
        state.confirmedPreyZoneMapID = questMapID
    end

    state.playerMapID = nil
    state.playerMapHierarchy = nil
    state.zoneCacheDirty = false

    state.inPreyZone = inPreyZone
    state.lastZoneStatusRefreshAt = now
    return inPreyZone
end

GetSoundPathForKey = function(soundKey, fallbackPath)
    local runtime = GetRuntimeModule("SoundsRuntime")
    if runtime and type(runtime.GetSoundPathForKey) == "function" then
        return runtime:GetSoundPathForKey(soundKey, fallbackPath, {
            soundKeys = {
                alert = AMBUSH_SOUND_ALERT,
                ambush = AMBUSH_SOUND_AMBUSH,
                torment = AMBUSH_SOUND_TORMENT,
                kill = AMBUSH_SOUND_KILL,
            },
            soundPaths = {
                alert = ALERT_SOUND_PATH,
                ambush = AMBUSH_SOUND_PATH,
                torment = TORMENT_SOUND_PATH,
                kill = KILL_SOUND_PATH,
            },
        })
    end

    return fallbackPath
end

local function GetCurrentActivePreyQuest()
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.GetCurrentActivePreyQuest) == "function" then
        return runtime:GetCurrentActivePreyQuest({
            questLog = C_QuestLog,
        })
    end

    if C_QuestLog and C_QuestLog.GetActivePreyQuest then
        return C_QuestLog.GetActivePreyQuest()
    end

    return nil
end

local function RefreshCurrentActivePreyQuestCache()
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.RefreshCurrentActivePreyQuestCache) == "function" then
        return runtime:RefreshCurrentActivePreyQuestCache(state, {
            getTime = GetTime,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
    end

    local now = GetTime and GetTime() or 0
    state.cachedActivePreyQuestID = GetCurrentActivePreyQuest()
    state.cachedActivePreyQuestAt = now
    return state.cachedActivePreyQuestID
end

local function GetCurrentActivePreyQuestCached(maxAgeSeconds)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.GetCurrentActivePreyQuestCached) == "function" then
        return runtime:GetCurrentActivePreyQuestCached(maxAgeSeconds, state, {
            getTime = GetTime,
            defaultMaxAgeSeconds = ACTIVE_PREY_QUEST_CACHE_SECONDS,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
    end

    local now = GetTime and GetTime() or 0
    local maxAge = tonumber(maxAgeSeconds)
    if not maxAge or maxAge < 0 then
        maxAge = ACTIVE_PREY_QUEST_CACHE_SECONDS
    end

    if (now - (state.cachedActivePreyQuestAt or 0)) > maxAge then
        return RefreshCurrentActivePreyQuestCache()
    end

    return state.cachedActivePreyQuestID
end

local function ArmQuestListenBurst(durationSeconds)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.ArmQuestListenBurst) == "function" then
        runtime:ArmQuestListenBurst(durationSeconds, state, {
            getTime = GetTime,
            defaultBurstSeconds = QUEST_LISTEN_BURST_SECONDS,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
        return
    end

    local now = GetTime and GetTime() or 0
    local duration = tonumber(durationSeconds)
    if not duration or duration <= 0 then
        duration = QUEST_LISTEN_BURST_SECONDS
    end
    local untilTime = now + duration
    if untilTime > (state.questListenUntil or 0) then
        state.questListenUntil = untilTime
    end
    -- Force a fresh quest sample when a relevant interaction starts.
    RefreshCurrentActivePreyQuestCache()
end

local function GetQuestTitle(questID)
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local titleInfo = C_QuestLog.GetTitleForQuestID(questID)
        if type(titleInfo) == "table" and type(titleInfo.title) == "string" and titleInfo.title ~= "" then
            return titleInfo.title
        end

        if type(titleInfo) == "string" and titleInfo ~= "" then
            return titleInfo
        end
    end

    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if logIndex then
            local info = C_QuestLog.GetInfo(logIndex)
            if type(info) == "table" and type(info.title) == "string" and info.title ~= "" then
                return info.title
            end
        end
    end

    return nil
end

local function ExtractPreyTargetFromQuestTitle(questID)
    if type(questID) ~= "number" or questID < 1 then
        return nil, nil
    end

    local title = GetQuestTitle(questID)
    if type(title) ~= "string" or title == "" then
        return nil, nil
    end

    local preyName, difficulty = title:match("^%s*[Pp]rey:%s*(.-)%s*%((.-)%)%s*$")
    if preyName and preyName ~= "" then
        return preyName, difficulty
    end

    preyName = title:match("^%s*[Pp]rey:%s*(.-)%s*$")
    if preyName and preyName ~= "" then
        return preyName, nil
    end

    return nil, nil
end

local function IsRestrictedInstanceForPreyBar()
    local inInstance = false
    local instanceType = nil

    if IsInInstance then
        local ok, inInst, instType = pcall(IsInInstance)
        if ok then
            inInstance = inInst == true
            instanceType = instType
        end
    end

    if inInstance then
        return instanceType == "pvp"
            or instanceType == "arena"
            or instanceType == "party"
            or instanceType == "raid"
            or instanceType == "scenario"
            or instanceType == "delve"
    end

    -- Some delve/scenario transitions can lag IsInInstance() type reporting.
    if type(IsInScenario) == "function" then
        local okScenario, inScenario = pcall(IsInScenario)
        if okScenario and inScenario == true then
            return true
        end
    end

    if C_ScenarioInfo and type(C_ScenarioInfo.GetScenarioInfo) == "function" then
        local okInfo, scenarioInfo = pcall(C_ScenarioInfo.GetScenarioInfo)
        if okInfo and type(scenarioInfo) == "table" then
            local function parseScenarioNumber(value)
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

            local hasScenarioName = type(scenarioInfo.name) == "string" and scenarioInfo.name ~= ""
            local stage = parseScenarioNumber(scenarioInfo.currentStage)
            local stages = parseScenarioNumber(scenarioInfo.numStages)
            -- Require explicit stage metadata to avoid false positives from stale names.
            if hasScenarioName and (stage ~= nil or stages ~= nil) then
                return true
            end
        end
    end

    return false
end

local function TriggerAmbushAlert(message, source, senderName)
    local now = GetTime and GetTime() or 0
    state.lastAmbushSystemMessage = message
    if type(senderName) == "string" and senderName ~= "" then
        state.ambushSourceName = senderName
    end

    if settings.ambushVisualEnabled ~= false then
        state.ambushAlertUntil = now + AMBUSH_ALERT_DURATION_SECONDS
    end

    if settings.ambushSoundEnabled ~= false then
        local nextSoundAt = (state.lastAmbushSoundAt or 0) + AMBUSH_SOUND_COOLDOWN_SECONDS
        if now >= nextSoundAt then
            local ambushPath = Preydator.API.ResolveAmbushSoundPath()
            TryPlaySound(ambushPath)
            state.lastAmbushSoundAt = now
        else
            AddDebugLog("Ambush", "Sound skipped by cooldown | remaining=" .. string.format("%.1f", nextSoundAt - now) .. "s", true)
        end
    end

    AddDebugLog("Ambush", "Detected from " .. tostring(source) .. ": " .. tostring(message), true)
    UpdateBarDisplay()
end

local function ClearBloodyCommandAlert()
    state.bloodyCommandAlertUntil = 0
    state.bloodyCommandSourceName = nil
    state.lastBloodyCommandSpellID = nil
end

local function TriggerBloodyCommandAlert(spellID, sourceName, source)
    local now = GetTime and GetTime() or 0

    state.lastBloodyCommandSpellID = tonumber(spellID)
    state.bloodyCommandSourceName = sourceName

    if settings.bloodyCommandVisualEnabled ~= false then
        state.bloodyCommandAlertUntil = now + 20
    else
        state.bloodyCommandAlertUntil = 0
    end

    if settings.bloodyCommandSoundEnabled ~= false then
        local path = Preydator.API.ResolveBloodyCommandSoundPath()
        if path then
            TryPlaySound(path)
        end
    end

    AddDebugLog("BloodyCommand", "Detected from " .. tostring(source) .. " | spellID=" .. tostring(spellID) .. " | sourceName=" .. tostring(sourceName), true)
    UpdateBarDisplay()
end

local function IsNightmarePreyQuest(questID)
    local huntScanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
    if huntScanner and type(huntScanner.GetQuestMetadata) == "function" then
        local metadata = huntScanner:GetQuestMetadata(questID)
        if metadata and metadata.difficulty == "nightmare" then
            return true
        end
    end

    local fallbackDifficulty = state and state.preyTargetDifficulty
    if type(fallbackDifficulty) == "string" then
        return string.find(string.lower(fallbackDifficulty), "nightmare", 1, true) ~= nil
    end

    return false
end

local function SafeToNumber(value)
    -- Some Blizzard APIs can return protected "secret number" values.
    -- Converting those directly via tonumber taints and can error in map UI.
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

local function SafeExtractNPCIDFromGUIDValue(guidValue)
    local ok, result = pcall(function()
        local s = tostring(guidValue)
        if type(s) ~= "string" then
            return nil
        end
        local p = string.match(s, "^[^-]*%-[^-]*%-[^-]*%-[^-]*%-[^-]*%-([^-]+)")
        if type(p) ~= "string" then
            return nil
        end
        return SafeToNumber(p)
    end)
    if not ok then
        return nil
    end
    return result
end

TryPlayEchoOfPredationEncounter = function(npcID, source)
    local numericNPCID = SafeToNumber(npcID)
    if numericNPCID ~= 248365 then
        return false
    end

    local activeQuestID = GetCurrentActivePreyQuestCached(0)
    if not IsValidQuestID(activeQuestID) then
        AddDebugLog("EchoOfPredation", "rejected | no active prey quest | source=" .. tostring(source), false)
        return false
    end

    if not IsNightmarePreyQuest(activeQuestID) then
        AddDebugLog("EchoOfPredation", "rejected | active prey quest is not nightmare | questID=" .. tostring(activeQuestID), false)
        return false
    end

    local inPreyZone = RefreshInPreyZoneStatus(activeQuestID, true)
    if inPreyZone ~= true then
        AddDebugLog("EchoOfPredation", "rejected | not in prey zone | questID=" .. tostring(activeQuestID), false)
        return false
    end

    local now = GetTime and GetTime() or 0
    local nextSoundAt = (state.lastEchoOfPredationSoundAt or 0) + 30
    if now < nextSoundAt then
        AddDebugLog("EchoOfPredation", "rejected | cooldown active | secondsRemaining=" .. tostring(math.max(0, math.floor(nextSoundAt - now))), false)
        return false
    end

    local path = Preydator.API.ResolveEchoOfPredationSoundPath()
    if not path then
        AddDebugLog("EchoOfPredation", "rejected | no sound configured", true)
        return false
    end

    if TryPlaySound(path, false) then
        state.lastEchoOfPredationSoundAt = now
        AddDebugLog("EchoOfPredation", "accepted | npcID=" .. tostring(numericNPCID) .. " | questID=" .. tostring(activeQuestID) .. " | source=" .. tostring(source), true)
        return true
    end

    AddDebugLog("EchoOfPredation", "failed | npcID=" .. tostring(numericNPCID) .. " | path=" .. tostring(path), true)
    return false
end

TryHandleEchoOfPredationNameplate = function(unitToken, source)
    local unitGUID = _G.UnitGUID
    if type(unitToken) ~= "string" or unitToken == "" or type(unitGUID) ~= "function" then
        return false
    end

    if IsRestrictedInstanceForPreyBar() then
        return false
    end

    local activeQuestID = GetCurrentActivePreyQuestCached(0)
    if not IsValidQuestID(activeQuestID) then
        return false
    end

    local okGUID, rawGUID = pcall(unitGUID, unitToken)
    if not okGUID then
        return false
    end

    -- Instance gate must remain before GUID parsing to avoid secret-string paths.
    -- Parse directly from raw value via the taint-safe helper.
    local npcID = SafeExtractNPCIDFromGUIDValue(rawGUID)

    if npcID ~= 248365 then
        return false
    end

    return TryPlayEchoOfPredationEncounter(npcID, source)
end

local function IsQuestStillActive(questID)
    if not questID or questID < 1 then
        return false
    end

    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID) and true or false
    end

    return true
end

IsValidQuestID = function(questID)
    return type(questID) == "number" and questID > 0
end

local function EnsureDebugDB()
    _G.PreydatorDebugDB = _G.PreydatorDebugDB or {}
    debugDB = _G.PreydatorDebugDB
    if type(debugDB.entries) ~= "table" then
        debugDB.entries = {}
    end
    if debugDB.enabled == nil then
        debugDB.enabled = true
    end
end

AddDebugLog = function(kind, message, forcePrint)
    if not debugDB then
        return
    end

    if not debugDB.enabled then
        return
    end

    local now = GetTime and GetTime() or 0
    local entry = string.format("%0.3f | %s | %s", now, tostring(kind or "?"), tostring(message or ""))
    table.insert(debugDB.entries, entry)

    while #debugDB.entries > DEBUG_LOG_LIMIT do
        table.remove(debugDB.entries, 1)
    end

    if forcePrint then
        print("Preydator DEBUG: " .. entry)
    end
end

TryPlaySound = function(path, ignoreSoundToggle)
    local runtime = GetRuntimeModule("SoundsRuntime")
    if runtime and type(runtime.TryPlaySound) == "function" then
        return runtime:TryPlaySound(path, ignoreSoundToggle, settings, {
            isSoundsModuleEnabled = function()
                local customization = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
                if customization and type(customization.IsModuleEnabled) == "function" then
                    return customization:IsModuleEnabled("sounds") == true
                end
                return true
            end,
            addDebugLog = AddDebugLog,
            playSoundFile = PlaySoundFile,
            timerAfter = C_Timer and C_Timer.After or nil,
            warnedMissingSoundPaths = warnedMissingSoundPaths,
            printFn = print,
        })
    end

    local customization = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
    if customization and type(customization.IsModuleEnabled) == "function" and customization:IsModuleEnabled("sounds") ~= true then
        AddDebugLog("TryPlaySound", "blocked by sounds module disabled | path=" .. tostring(path), false)
        return false
    end

    if not ignoreSoundToggle and settings and settings.soundsEnabled == false then
        AddDebugLog("TryPlaySound", "blocked by soundsEnabled=false | path=" .. tostring(path), false)
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
        pushChannel("SFX")
        pushChannel("Master")
    end

    local willPlay = false
    local usedChannel = nil
    for _, tryChannel in ipairs(channelsToTry) do
        local result = PlaySoundFile(path, tryChannel)
        AddDebugLog("TryPlaySound", "path=" .. tostring(path) .. " | channel=" .. tostring(tryChannel) .. " | ignoreToggle=" .. tostring(ignoreSoundToggle) .. " | result=" .. tostring(result), false)
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
        if enhance > 0 and C_Timer and C_Timer.After then
            local extraPlays = math.min(4, math.max(0, math.floor(enhance / 25)))
            for i = 1, extraPlays do
                local delay = i * 0.03
                C_Timer.After(delay, function()
                    PlaySoundFile(path, usedChannel or channel)
                end)
            end
            if extraPlays > 0 then
                AddDebugLog("TryPlaySound", "enhance=" .. tostring(enhance) .. " | extraPlays=" .. tostring(extraPlays), false)
            end
        end
        return true
    end

    local warnedKey = tostring(path or "")
    if warnedMissingSoundPaths[warnedKey] ~= true then
        warnedMissingSoundPaths[warnedKey] = true
        print("Preydator: Sound failed to play: '" .. warnedKey .. "'. Ensure the .ogg exists in Interface\\AddOns\\Preydator\\sounds\\ and is listed in Custom Sound Files.")
    end

    return false
end

TryPlayStageSound = function(stage, ignoreSoundToggle)
    local path = Preydator.API.ResolveStageSoundPath(stage)
    if not path then
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | no resolved path", true)
        return false
    end

    if state.stageSoundPlayed[stage] then
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | skipped already played", false)
        return false
    end

    if state.stageSoundAttempted[stage] then
        return false
    end

    state.stageSoundAttempted[stage] = true

    if TryPlaySound(path, ignoreSoundToggle) then
        state.stageSoundPlayed[stage] = true
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | success", false)
        return true
    end

    if stage == MAX_STAGE then
        local fallbackPath = Preydator.API.ResolveStageSoundPath(MAX_STAGE - 1)
        if fallbackPath then
            AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | primary failed, trying fallback stage=" .. tostring(MAX_STAGE - 1) .. " | path=" .. tostring(fallbackPath), true)
            if TryPlaySound(fallbackPath, ignoreSoundToggle) then
                state.stageSoundPlayed[stage] = true
                AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | fallback stage=" .. tostring(MAX_STAGE - 1) .. " success", true)
                return true
            end
            AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | fallback stage=" .. tostring(MAX_STAGE - 1) .. " also failed", true)
        end
    end

    local channel = (settings and settings.soundChannel) or "SFX"
    AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | path=" .. tostring(path) .. " | channel=" .. tostring(channel) .. " | PlaySoundFile returned false", true)

    return false
end

local barPositionUtil = {
    defaultX = 0,
    defaultY = 472,
}

function barPositionUtil.GetDefaultPoint(frameWidth, frameHeight)
    return barPositionUtil.defaultX, barPositionUtil.defaultY
end

function barPositionUtil.ClampToScreen(x, y, frameWidth, frameHeight)
    local parentWidth = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 0
    local parentHeight = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 0
    local width = math.max(1, tonumber(frameWidth) or 0)
    local height = math.max(1, tonumber(frameHeight) or 0)
    local margin = 8

    if parentWidth <= 0 or parentHeight <= 0 then
        local defaultX, defaultY = barPositionUtil.GetDefaultPoint(width, height)
        return Round(tonumber(x) or defaultX), Round(tonumber(y) or defaultY)
    end

    local maxX = math.max(0, math.floor(((parentWidth - width) / 2) - margin))
    local maxY = math.max(0, math.floor(((parentHeight - height) / 2) - margin))
    local defaultX, defaultY = barPositionUtil.GetDefaultPoint(width, height)
    local clampedX = Clamp(Round(tonumber(x) or defaultX), -maxX, maxX)
    local clampedY = Clamp(Round(tonumber(y) or defaultY), -maxY, maxY)
    return clampedX, clampedY
end

function barPositionUtil.GetCurrentDimensions()
    local orientation = settings and settings.orientation or ORIENTATION_HORIZONTAL
    local frameScale
    local baseWidth
    local baseHeight

    if orientation == ORIENTATION_VERTICAL then
        frameScale = Clamp(tonumber(settings and settings.verticalScale) or DEFAULTS.verticalScale, 0.5, 2)
        baseWidth = Clamp(math.floor((tonumber(settings and settings.verticalWidth) or DEFAULTS.verticalWidth) + 0.5), 10, 60)
        baseHeight = Clamp(math.floor((tonumber(settings and settings.verticalHeight) or DEFAULTS.verticalHeight) + 0.5), 100, 350)
    else
        frameScale = Clamp(tonumber(settings and settings.scale) or DEFAULTS.scale, 0.5, 2)
        baseWidth = Clamp(math.floor((tonumber(settings and settings.horizontalWidth) or DEFAULTS.horizontalWidth) + 0.5), 100, 350)
        baseHeight = Clamp(math.floor((tonumber(settings and settings.horizontalHeight) or DEFAULTS.horizontalHeight) + 0.5), 10, 60)
    end

    return math.max(1, Round(baseWidth * frameScale)), math.max(1, Round(baseHeight * frameScale))
end

function barPositionUtil.Reset()
    settings.point = settings.point or {}
    settings.point.anchor = "CENTER"
    settings.point.relativePoint = "CENTER"

    local width, height = barPositionUtil.GetCurrentDimensions()
    settings.point.x, settings.point.y = barPositionUtil.GetDefaultPoint(width, height)
    do
        local runtime = GetRuntimeModule("SettingsRuntime")
        if runtime and type(runtime.SyncBarPointToBackup) == "function" then
            runtime:SyncBarPointToBackup(settings)
        end
    end

    ApplyBarSettings()
    UpdateBarDisplay()
end

ApplyBarSettings = function()
    if type(BarRuntimeApplyHandler) == "function" then
        return BarRuntimeApplyHandler()
    end

    if Preydator and type(Preydator.PrintDebug) == "function" then
        Preydator:PrintDebug("Bar runtime handler missing; skipping ApplyBarSettings delegate.")
    end
end

ApplyAratorSilencing = function()
    if settings and settings.silenceArator then
        for _, soundID in ipairs(ARATOR_SOUND_IDS) do
            MuteSoundFile(soundID)
        end
    else
        for _, soundID in ipairs(ARATOR_SOUND_IDS) do
            UnmuteSoundFile(soundID)
        end
    end
end

local function EnsureBar()
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    local barEnabled = true
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        barEnabled = customizationV2:IsModuleEnabled("bar") == true
    end
    if not barEnabled then
        if UI.barFrame then
            UI.barFrame:Hide()
        end
        return
    end

    if UI.barFrame then
        return
    end

    local createdBar = CreateFrame("Frame", "PreydatorProgressBar", UIParent)
    if not createdBar then
        return
    end

    createdBar:SetSize(260, 18)
    createdBar:SetFrameStrata("MEDIUM")
    createdBar:SetFrameLevel(5)
    do
        local defaultX, defaultY = barPositionUtil.GetDefaultPoint(260, 18)
        createdBar:SetPoint("CENTER", UIParent, "CENTER", defaultX, defaultY)
    end
    createdBar:Hide()
    createdBar:SetClampedToScreen(true)
    createdBar:RegisterForDrag("LeftButton")
    UI.barFrame = createdBar

    local function SaveBarPosition(self)
        settings.point.anchor = "CENTER"
        settings.point.relativePoint = "CENTER"

        local frameWidth = self and self.GetWidth and self:GetWidth() or 0
        local frameHeight = self and self.GetHeight and self:GetHeight() or 0

        local frameCenterX, frameCenterY = self:GetCenter()
        local parentCenterX, parentCenterY = UIParent:GetCenter()
        if frameCenterX and frameCenterY and parentCenterX and parentCenterY then
            settings.point.x, settings.point.y = barPositionUtil.ClampToScreen(frameCenterX - parentCenterX, frameCenterY - parentCenterY, frameWidth, frameHeight)
            do
                local runtime = GetRuntimeModule("SettingsRuntime")
                if runtime and type(runtime.SyncBarPointToBackup) == "function" then
                    runtime:SyncBarPointToBackup(settings)
                end
            end
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", settings.point.x, settings.point.y)
            return
        end

        local _, _, _, x, y = self:GetPoint(1)
        settings.point.x, settings.point.y = barPositionUtil.ClampToScreen(x, y, frameWidth, frameHeight)
        do
            local runtime = GetRuntimeModule("SettingsRuntime")
            if runtime and type(runtime.SyncBarPointToBackup) == "function" then
                runtime:SyncBarPointToBackup(settings)
            end
        end
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", settings.point.x, settings.point.y)
    end

    UI.barFrame:SetScript("OnMouseDown", function(self, button)
        self.PreydatorWasDragging = false
        self.PreydatorHandledMapClick = false
        self.PreydatorClickStartX = nil
        self.PreydatorClickStartY = nil
        self.PreydatorClickStartTime = nil

        if button ~= "LeftButton" then
            return
        end

        local editModeFrame = _G.EditModeManagerFrame
        local isEditModePreview = editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown()
        local allowStageFourMapClickFallback = settings
            and state
            and state.stage == MAX_STAGE

        if allowStageFourMapClickFallback and not isEditModePreview and button == "LeftButton" then
            self.PreydatorHandledMapClick = true
            TryOpenPreyQuestOnMap()
            return
        end

        if isEditModePreview then
            self.PreydatorClickStartX, self.PreydatorClickStartY = _G.GetCursorPosition()
            self.PreydatorClickStartTime = GetTime and GetTime() or 0
        end
    end)

    UI.barFrame:SetScript("OnDragStart", function(self)
        if settings and not settings.locked then
            self.PreydatorWasDragging = true
            self:StartMoving()
        end
    end)

    UI.barFrame:SetScript("OnDragStop", function(self)
        if not self.PreydatorWasDragging then
            return
        end

        self:StopMovingOrSizing()
        self.PreydatorWasDragging = false
        SaveBarPosition(self)
    end)

    UI.barFrame:SetScript("OnMouseUp", function(self, button)
        if self.PreydatorHandledMapClick then
            self.PreydatorHandledMapClick = false
            return
        end

        if button ~= "LeftButton" then
            return
        end

        local editModeFrame = _G.EditModeManagerFrame
        if editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown() then
            local startX = self.PreydatorClickStartX
            local startY = self.PreydatorClickStartY
            local startTime = self.PreydatorClickStartTime or 0
            local endX, endY = GetCursorPosition()
            local now = GetTime and GetTime() or 0

            local dx = (startX and endX) and math.abs(endX - startX) or 999
            local dy = (startY and endY) and math.abs(endY - startY) or 999
            local dt = now - startTime

            if dx <= 3 and dy <= 3 and dt <= 0.20 then
                local editModeModule = Preydator.GetModule and Preydator:GetModule("EditMode")
                if editModeModule and editModeModule.ShowWindow then
                    editModeModule:ShowWindow()
                else
                    OpenOptionsPanel()
                end
            end
            return
        end

        if button == "LeftButton"
            and settings
            and state
            and state.stage == MAX_STAGE
        then
            TryOpenPreyQuestOnMap()
        end
    end)

    local bg = UI.barFrame:CreateTexture(nil, "background")
    bg:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    bg:SetPoint("TOPRIGHT", UI.barFrame, "TOPRIGHT", -FILL_INSET, -FILL_INSET)
    bg:SetColorTexture(0, 0, 0, 0.6)
    UI.barFrame.BackgroundTexture = bg

    UI.barFill = UI.barFrame:CreateTexture(nil, "artwork")
    UI.barFill:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    UI.barFill:SetSize(0, 18)
    UI.barFill:SetTexCoord(0, 1, 0, 1)
    UI.barFill:SetHorizTile(false)
    UI.barFill:SetVertTile(false)
    UI.barFill:SetColorTexture(0.85, 0.2, 0.2, 0.95)

    UI.barSpark = UI.barFrame:CreateTexture(nil, "overlay")
    UI.barSpark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    UI.barSpark:SetSize(2, 18)
    UI.barSpark:SetColorTexture(1, 0.95, 0.75, 0.9)
    UI.barSpark:SetDrawLayer("OVERLAY", 3)
    UI.barSpark:Hide()

    local border = CreateFrame("Frame", nil, UI.barFrame, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    border:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.85)
    UI.barBorder = border

    UI.stageText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    UI.stageText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, 4)
    UI.stageText:SetJustifyH("CENTER")
    UI.stageText:SetText("Preydator")

    UI.stageSuffixText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    UI.stageSuffixText:SetPoint("BOTTOMRIGHT", UI.barFrame, "TOPRIGHT", -2, 4)
    UI.stageSuffixText:SetJustifyH("RIGHT")
    UI.stageSuffixText:SetText("")
    UI.stageSuffixText:Hide()

    UI.barText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    UI.barText:SetPoint("center", UI.barFrame, "center", 0, 0)
    UI.barText:SetDrawLayer("OVERLAY", 9)
    UI.barText:SetText("0%")

    UI.barAlignmentDot = UI.barFrame:CreateTexture(nil, "OVERLAY")
    UI.barAlignmentDot:SetSize(6, 6)
    UI.barAlignmentDot:SetColorTexture(0, 1, 0, 1)
    UI.barAlignmentDot:SetPoint("CENTER", UI.barFrame, "CENTER", 0, 0)
    UI.barAlignmentDot:SetDrawLayer("OVERLAY", 7)
    UI.barAlignmentDot:Hide()

    for index = 1, MAX_TICK_MARKS do
        local pct = (index * 25)
        local tickMark = UI.barFrame:CreateTexture(nil, "overlay")
        tickMark:SetColorTexture(1, 1, 1, 0.35)
        tickMark:SetDrawLayer("OVERLAY", 4)
        UI.barTickMarks[index] = tickMark

        local tickLabel = UI.barFrame:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tickLabel:SetDrawLayer("OVERLAY", 8)
        tickLabel:SetText(tostring(pct))
        UI.barTickLabels[index] = tickLabel
    end

    ApplyBarSettings()
end

local function GetStageFromState(progressState)
    if progressState == nil then
        return 1
    end

    if progressState == 0 then
        return 1
    end

    if progressState == 1 then
        return 2
    end

    if progressState == 2 then
        return 3
    end

    if progressState == PREY_PROGRESS_FINAL then
        return 4
    end

    return 1
end

local function CoerceSafeNumeric(value)
    local okString, asString = pcall(tostring, value)
    if not okString or type(asString) ~= "string" then
        return nil
    end

    local numericToken = string.match(asString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
        or string.match(asString, "^%s*([%+%-]?%d*%.%d+)%s*$")
    if not numericToken then
        return nil
    end

    local okNumber, asNumber = pcall(tonumber, numericToken)
    if okNumber and type(asNumber) == "number" then
        return asNumber
    end

    return nil
end

local function ExtractProgressPercentFromInfoScan(info)
    if type(info) ~= "table" then
        return nil
    end

    for key, value in pairs(info) do
        value = CoerceSafeNumeric(value)
        if value ~= nil then
            local keyText = string.lower(tostring(key))
            if string.find(keyText, "percent", 1, true) then
                local pct = nil
                if value >= 0 and value <= 1 then
                    pct = Clamp(value * 100, 0, 100)
                else
                    pct = Clamp(value, 0, 100)
                end
                if pct ~= nil then
                    return pct
                end
            end
        end
    end

    local currentValues = {}
    local maxValues = {}
    for key, value in pairs(info) do
        value = CoerceSafeNumeric(value)
        if value ~= nil and value >= 0 then
            local keyText = string.lower(tostring(key))
            if string.find(keyText, "current", 1, true)
                or string.find(keyText, "value", 1, true)
                or string.find(keyText, "progress", 1, true)
                or string.find(keyText, "fulfilled", 1, true)
                or string.find(keyText, "completed", 1, true)
            then
                currentValues[#currentValues + 1] = value
            end

            if string.find(keyText, "max", 1, true)
                or string.find(keyText, "total", 1, true)
                or string.find(keyText, "required", 1, true)
            then
                maxValues[#maxValues + 1] = value
            end
        end
    end

    for _, current in ipairs(currentValues) do
        for _, maxValue in ipairs(maxValues) do
            if maxValue > 0 and current <= maxValue then
                local pct = Clamp((current / maxValue) * 100, 0, 100)
                if pct >= 0 and pct <= 100 then
                    return pct
                end
            end
        end
    end

    return nil
end

local function ExtractProgressPercent(info, tooltipText)
    if type(info) == "table" then
        local directFields = {
            "progressPercentage",
            "progressPercent",
            "fillPercentage",
            "percentage",
            "percent",
            "progress",
            "progressValue",
        }

        for _, fieldName in ipairs(directFields) do
            local rawValue = CoerceSafeNumeric(info[fieldName])
            local pct = nil
            if rawValue ~= nil then
                if rawValue >= 0 and rawValue <= 1 then
                    pct = Clamp(rawValue * 100, 0, 100)
                else
                    pct = Clamp(rawValue, 0, 100)
                end
            end
            if pct ~= nil then
                return pct
            end
        end

        local valueFields = { "barValue", "value", "currentValue" }
        local maxFields = { "barMax", "maxValue", "totalValue", "total", "max" }
        for _, valueField in ipairs(valueFields) do
            local current = CoerceSafeNumeric(info[valueField])
            if current ~= nil then
                for _, maxField in ipairs(maxFields) do
                    local maxValue = CoerceSafeNumeric(info[maxField])
                    if maxValue ~= nil and maxValue > 0 then
                        return Clamp((current / maxValue) * 100, 0, 100)
                    end
                end
            end
        end
    end

    local scannedPct = ExtractProgressPercentFromInfoScan(info)
    if scannedPct ~= nil then
        return scannedPct
    end

    if type(tooltipText) == "string" then
        local pctText = tooltipText:match("(%d+)%s*%%")
        local pctValue = CoerceSafeNumeric(tonumber(pctText))
        if pctValue then
            return Clamp(pctValue, 0, 100)
        end
    end

    return nil
end

local function ExtractQuestObjectivePercent(questID)
    if not IsValidQuestID(questID) then
        return nil
    end

    local questBarPct = nil
    if _G.GetQuestProgressBarPercent then
        local okQuestBarPct, rawQuestBarPct = pcall(function()
            return CoerceSafeNumeric(_G.GetQuestProgressBarPercent(questID))
        end)
        if not okQuestBarPct then
            rawQuestBarPct = nil
        end
        if rawQuestBarPct ~= nil then
            questBarPct = Clamp(rawQuestBarPct, 0, 100)
        end
    end

    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then
        return nil
    end

    local objectives = C_QuestLog.GetQuestObjectives(questID)
    if type(objectives) ~= "table" or #objectives == 0 then
        return nil
    end

    local totalFulfilled = 0
    local totalRequired = 0
    local anyNumericObjective = false

    for _, objective in ipairs(objectives) do
        if type(objective) == "table" then
            local okFulfilled, fulfilled = pcall(function()
                return CoerceSafeNumeric(objective.numFulfilled)
            end)
            local okRequired, required = pcall(function()
                return CoerceSafeNumeric(objective.numRequired)
            end)

            if not okFulfilled then
                fulfilled = nil
            end
            if not okRequired then
                required = nil
            end

            if fulfilled == nil then
                local okLegacyFulfilled, legacyFulfilled = pcall(function()
                    return CoerceSafeNumeric(objective.fulfilled)
                end)
                if okLegacyFulfilled then
                    fulfilled = legacyFulfilled
                end
            end
            if required == nil then
                local okLegacyRequired, legacyRequired = pcall(function()
                    return CoerceSafeNumeric(objective.required)
                end)
                if okLegacyRequired then
                    required = legacyRequired
                end
            end

            if fulfilled ~= nil and required == nil and objective.finished ~= nil then
                required = 1
                fulfilled = objective.finished and 1 or math.max(0, fulfilled)
            end

            if fulfilled and required and required > 0 then
                anyNumericObjective = true
                totalFulfilled = totalFulfilled + math.max(0, fulfilled)
                totalRequired = totalRequired + math.max(0, required)
            else
                local text = objective.text
                if type(text) == "string" and text ~= "" then
                    local curText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                    local curValue = CoerceSafeNumeric(tonumber(curText))
                    local maxValue = CoerceSafeNumeric(tonumber(maxText))
                    if curValue and maxValue and maxValue > 0 then
                        anyNumericObjective = true
                        totalFulfilled = totalFulfilled + math.max(0, curValue)
                        totalRequired = totalRequired + math.max(0, maxValue)
                    else
                        local pctText = text:match("(%d+)%s*%%")
                        local pctValue = CoerceSafeNumeric(tonumber(pctText))
                        if pctValue then
                            return Clamp(pctValue, 0, 100)
                        end
                    end
                end
            end
        end
    end

    local objectivePct = nil
    if anyNumericObjective and totalRequired > 0 then
        objectivePct = Clamp((totalFulfilled / totalRequired) * 100, 0, 100)
    end

    if objectivePct ~= nil and questBarPct ~= nil then
        return math.max(objectivePct, questBarPct)
    end

    if objectivePct ~= nil then
        return objectivePct
    end

    if questBarPct ~= nil then
        return questBarPct
    end

    return nil
end

UpdateBarDisplay = function()
    if type(BarRuntimeUpdateHandler) == "function" then
        return BarRuntimeUpdateHandler()
    end

    if Preydator and type(Preydator.PrintDebug) == "function" then
        Preydator:PrintDebug("Bar runtime handler missing; skipping UpdateBarDisplay delegate.")
    end

    RunModuleHook("OnAfterUpdateBarDisplay", {
        shouldShowBar = false,
        forceAmbushAlert = false,
        forceBloodyCommandAlert = false,
        forceKillStage = false,
        hasActiveQuest = false,
        displayPercent = 0,
        stage = state.stage,
    })
end

OpenOptionsPanel = function()
    local settingsModule = Preydator.GetModule and Preydator:GetModule("Settings")
    if settingsModule and settingsModule.OpenOptionsPanel then
        settingsModule:OpenOptionsPanel()
        return
    end

    EnsureOptionsPanel()

    if Settings and Settings.OpenToCategory then
        if type(UI.optionsCategoryID) == "number" then
            Settings.OpenToCategory(UI.optionsCategoryID)
            return
        end

        if UI.optionsPanel and type(UI.optionsPanel.categoryID) == "number" then
            Settings.OpenToCategory(UI.optionsPanel.categoryID)
            return
        end
    end

    if _G.InterfaceOptionsFrame_OpenToCategory then
        _G.InterfaceOptionsFrame_OpenToCategory("Preydator")
    end
end

local function ClearPreyStateAndDisplay()
    state.activeQuestID = nil
    state.progressState = nil
    state.progressPercent = 0
    state.preyZoneName = nil
    state.preyZoneMapID = nil
    state.confirmedPreyZoneMapID = nil
    state.inPreyZone = nil
    state.preyTooltipText = nil
    state.stage = 1
    state.killStageUntil = 0
    state.lastWidgetSeenAt = 0
    state.lastWidgetSetupAt = 0
    state.lastWidgetBoundQuestID = nil
    preyWidgetInfoCache = nil
    state.stageSoundPlayed = {}
    state.stageSoundAttempted = {}
    state.lastStateDebugSnapshot = nil
    state.preyTargetName = nil
    state.preyTargetDifficulty = nil
    state.ambushAlertUntil = 0
    state.lastAmbushSoundAt = 0
    state.lastEchoOfPredationSoundAt = 0
    state.lastAmbushSystemMessage = nil
    state.ambushSourceName = nil
    state.bloodyCommandAlertUntil = 0
    state.bloodyCommandSourceName = nil
    state.lastBloodyCommandSpellID = nil

    if UI.barFill then
        UI.barFill:SetWidth(0)
    end
end

local function IsRelevantWidgetUpdateEvent(arg1, arg2)
    -- Taint-safe fail-open: do not touch UPDATE_UI_WIDGET payload fields.
    -- Some client paths provide secret-number payload values; reading/coercing
    -- them in addon code can taint subsequent Blizzard tooltip/layout flows.
    return true
end

local function DebugLogPreyState(origin, questID, hasWidgetData, progressState, progressPercent, inPreyZone)
    if not (debugDB and debugDB.enabled) then
        return
    end

    local snapshot = table.concat({
        tostring(origin),
        tostring(questID),
        tostring(hasWidgetData),
        tostring(progressState),
        tostring(progressPercent),
        tostring(inPreyZone),
    }, "|")

    if snapshot == state.lastStateDebugSnapshot then
        return
    end

    state.lastStateDebugSnapshot = snapshot
    AddDebugLog("PreyState", "origin=" .. tostring(origin)
        .. " | questID=" .. tostring(questID)
        .. " | widget=" .. tostring(hasWidgetData)
        .. " | state=" .. tostring(progressState)
        .. " | pct=" .. tostring(progressPercent)
        .. " | inZone=" .. tostring(inPreyZone), false)
end

local function IsLikelyIconName(value)
    if type(value) ~= "string" then
        return false
    end

    return string.find(string.lower(value), "icon", 1, true) ~= nil
end

local function SetRegionShown(region, shouldShow)
    if not region then
        return false
    end

    if region.SetShown then
        region:SetShown(shouldShow)
        return true
    end

    if shouldShow and region.Show then
        region:Show()
        return true
    end

    if (not shouldShow) and region.Hide then
        region:Hide()
        return true
    end

    return false
end

local AttachStageFourMapClick

local WIDGET_SUPPRESSION_WAS_SHOWN = setmetatable({}, { __mode = "k" })
local WIDGET_SUPPRESSION_WAS_ALPHA = setmetatable({}, { __mode = "k" })
local WIDGET_SUPPRESSION_HOOKED = setmetatable({}, { __mode = "k" })
local STAGE_FOUR_CLICK_HOOKED = setmetatable({}, { __mode = "k" })
local PREY_WIDGET_FRAMES = setmetatable({}, { __mode = "k" })
local preyHuntMixinHooked = false
local preyHuntIconFrame = nil
local preyWidgetInfoCache = nil  -- snapshot from mixin Setup hook; avoids taint-prone GetAllWidgetsBySetID scans
local suppressionRetryPending = false
local suppressionRetryCount = 0

local function CancelFrameScriptedEffect(frameRef)
    local effectController = frameRef and frameRef.effectController or nil
    if effectController and type(effectController.CancelEffect) == "function" then
        pcall(effectController.CancelEffect, effectController)
    end
end

-- Safe: identifies prey hunt frames by checking mixin-specific function presence.
-- Does NOT read any secret-number fields (widgetID, widgetType, etc.).
local function IsPreyHuntProgressFrame(frameRef)
    if not frameRef then
        return false
    end
    -- ResetAnimState and AnimIn are defined only in UIWidgetTemplatePreyHuntProgressMixin.
    return type(frameRef.ResetAnimState) == "function"
        and type(frameRef.AnimIn) == "function"
end

local function CaptureLivePreyHuntFrames()
    local container = _G.UIWidgetPowerBarContainerFrame
    if not container or not container.GetChildren then
        return
    end

    local okChildren, children = pcall(function()
        return { container:GetChildren() }
    end)
    if not okChildren or type(children) ~= "table" then
        return
    end

    for _, child in ipairs(children) do
        if IsPreyHuntProgressFrame(child) then
            PREY_WIDGET_FRAMES[child] = true
            preyHuntIconFrame = child
        end
    end
end

IsAnyTrackedPreyWidgetShown = function()
    if preyHuntIconFrame and preyHuntIconFrame.IsShown and preyHuntIconFrame:IsShown() then
        return true
    end

    for frameRef in pairs(PREY_WIDGET_FRAMES) do
        if frameRef and frameRef.IsShown and frameRef:IsShown() then
            return true
        end
    end

    return false
end

local function IsLikelyAnimatedVisualRegion(region)
    if not region then
        return false
    end

    local objectType = region.GetObjectType and region:GetObjectType() or nil
    if objectType ~= "Texture" and objectType ~= "FontString" then
        return false
    end

    local name = region.GetName and region:GetName() or nil
    if type(name) ~= "string" then
        return false
    end

    local lowered = string.lower(name)
    return string.find(lowered, "icon", 1, true) ~= nil
        or string.find(lowered, "glow", 1, true) ~= nil
        or string.find(lowered, "pulse", 1, true) ~= nil
end

local function StopFrameAnimations(frameRef, depth, visited)
    if not frameRef or (depth or 0) > 3 then
        return
    end

    visited = visited or {}
    if visited[frameRef] then
        return
    end
    visited[frameRef] = true
    CancelFrameScriptedEffect(frameRef)

    if frameRef.GetAnimationGroups then
        local okGroups, groups = pcall(function()
            return { frameRef:GetAnimationGroups() }
        end)
        if okGroups and type(groups) == "table" then
            for _, group in ipairs(groups) do
                if group and group.Stop then
                    pcall(group.Stop, group)
                end
            end
        end
    end

    local commonAnimFields = {
        "AnimIn", "AnimOut", "GlowAnim", "PulseAnim", "Loop", "LoopingGlow", "Shine",
    }
    for _, fieldName in ipairs(commonAnimFields) do
        local candidate = frameRef[fieldName]
        if candidate and type(candidate) ~= "function" and candidate.Stop then
            pcall(candidate.Stop, candidate)
        end
    end

    if frameRef.GetRegions then
        local okRegions, regions = pcall(function()
            return { frameRef:GetRegions() }
        end)
        if okRegions and type(regions) == "table" then
            for _, region in ipairs(regions) do
                if IsLikelyAnimatedVisualRegion(region) then
                    SetRegionShown(region, false)
                end
            end
        end
    end

    if frameRef.GetChildren then
        local okChildren, children = pcall(function()
            return { frameRef:GetChildren() }
        end)
        if okChildren and type(children) == "table" then
            for _, child in ipairs(children) do
                StopFrameAnimations(child, (depth or 0) + 1, visited)
            end
        end
    end
end

local function ApplyWidgetFrameSuppression(frameRef, suppress)
    if not frameRef then
        return
    end

    local wasShown = WIDGET_SUPPRESSION_WAS_SHOWN[frameRef]

    if suppress then
        StopFrameAnimations(frameRef, 0)
        if wasShown == nil and frameRef.IsShown then
            WIDGET_SUPPRESSION_WAS_SHOWN[frameRef] = frameRef:IsShown() and true or false
        end
        if WIDGET_SUPPRESSION_WAS_ALPHA[frameRef] == nil and frameRef.GetAlpha then
            local okAlpha, alpha = pcall(frameRef.GetAlpha, frameRef)
            if okAlpha and type(alpha) == "number" then
                WIDGET_SUPPRESSION_WAS_ALPHA[frameRef] = alpha
            end
        end
        if frameRef.SetAlpha then
            pcall(frameRef.SetAlpha, frameRef, 0)
        end
        if frameRef.Hide then
            pcall(frameRef.Hide, frameRef)
        end
    else
        local storedAlpha = WIDGET_SUPPRESSION_WAS_ALPHA[frameRef]
        if storedAlpha ~= nil and frameRef.SetAlpha then
            pcall(frameRef.SetAlpha, frameRef, storedAlpha)
            WIDGET_SUPPRESSION_WAS_ALPHA[frameRef] = nil
        elseif frameRef.SetAlpha then
            pcall(frameRef.SetAlpha, frameRef, 1)
        end
        if wasShown == true
            and state
            and state.inPreyZone == true
            and frameRef.Show then
            pcall(frameRef.Show, frameRef)
        end
        if wasShown ~= nil then
            WIDGET_SUPPRESSION_WAS_SHOWN[frameRef] = nil
        end
    end

end

local function ScheduleSuppressionRetry()
    if suppressionRetryPending then
        return
    end
    if not (type(C_Timer) == "table" and type(C_Timer.After) == "function") then
        return
    end
    if suppressionRetryCount >= 6 then
        suppressionRetryCount = 0
        return
    end

    suppressionRetryPending = true
    suppressionRetryCount = suppressionRetryCount + 1
    C_Timer.After(0.20, function()
        suppressionRetryPending = false
        if not (settings and settings.disableDefaultPreyIcon == true) then
            suppressionRetryCount = 0
            return
        end
        if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then
            state.pendingWidgetSuppressionAfterCombat = true
            return
        end
        ApplyDefaultPreyIconVisibility()
    end)
end

local function GetWidgetSuppressionDebugSnapshot()
    local trackedFrames = 0
    local shownFrames = 0
    local hiddenFrames = 0
    local effectControllers = 0

    for frameRef in pairs(PREY_WIDGET_FRAMES) do
        trackedFrames = trackedFrames + 1
        if frameRef and frameRef.IsShown and frameRef:IsShown() then
            shownFrames = shownFrames + 1
        else
            hiddenFrames = hiddenFrames + 1
        end
        if frameRef and frameRef.effectController then
            effectControllers = effectControllers + 1
        end
    end

    local preyIconTracked = preyHuntIconFrame and PREY_WIDGET_FRAMES[preyHuntIconFrame] == true or false
    local preyIconShown = nil
    if preyHuntIconFrame and preyHuntIconFrame.IsShown then
        preyIconShown = preyHuntIconFrame:IsShown() and true or false
    end

    return {
        trackedFrames = trackedFrames,
        shownFrames = shownFrames,
        hiddenFrames = hiddenFrames,
        effectControllers = effectControllers,
        preyIconTracked = preyIconTracked,
        preyIconShown = preyIconShown,
        suppressionRetryPending = suppressionRetryPending,
        suppressionRetryCount = suppressionRetryCount,
        pendingAfterCombat = state and state.pendingWidgetSuppressionAfterCombat == true,
    }
end

Preydator.GetWidgetSuppressionDebug = GetWidgetSuppressionDebugSnapshot

local function ReadPreyValueFromObject(obj, keyName)
    if type(obj) ~= "table" then
        return nil
    end

    local okDirect, directValue = pcall(function()
        return obj[keyName]
    end)
    if okDirect and directValue ~= nil then
        return directValue
    end

    local getterName = "Get" .. string.upper(string.sub(keyName, 1, 1)) .. string.sub(keyName, 2)
    local okGetter, getter = pcall(function()
        return obj[getterName]
    end)
    if okGetter and type(getter) == "function" then
        local okCall, value = pcall(getter, obj)
        if okCall and value ~= nil then
            return value
        end
    end

    return nil
end

local function CoerceSanitizedNumber(value)
    -- Accept number-like protected values too (secret-number wrappers).
    -- Always sanitize via string-token roundtrip before tonumber.
    local okString, asString = pcall(tostring, value)
    if not okString or type(asString) ~= "string" then
        return nil
    end

    local numericToken = string.match(asString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
        or string.match(asString, "^%s*([%+%-]?%d*%.%d+)%s*$")
    if not numericToken then
        return nil
    end

    local okNumber, asNumber = pcall(tonumber, numericToken)
    if okNumber and type(asNumber) == "number" then
        return asNumber
    end

    return nil
end

local function ResolvePreyFieldsFromFrame(self)
    if type(self) ~= "table" then
        return nil, nil, nil, nil
    end

    local sources = {
        { name = "frame", value = self },
        { name = "frame.widgetInfo", value = ReadPreyValueFromObject(self, "widgetInfo") },
        { name = "frame.widgetData", value = ReadPreyValueFromObject(self, "widgetData") },
        { name = "frame.dataSource", value = ReadPreyValueFromObject(self, "dataSource") },
        { name = "frame.info", value = ReadPreyValueFromObject(self, "info") },
    }

    for _, source in ipairs(sources) do
        local obj = source.value
        if type(obj) == "table" then
            local shownState = CoerceSanitizedNumber(ReadPreyValueFromObject(obj, "shownState"))
            local progressState = CoerceSanitizedNumber(ReadPreyValueFromObject(obj, "progressState"))
            local tooltip = ReadPreyValueFromObject(obj, "tooltip")
            if type(tooltip) ~= "string" then
                tooltip = nil
            end

            if shownState ~= nil or progressState ~= nil or tooltip ~= nil then
                return shownState, progressState, tooltip, source.name
            end
        end
    end

    return nil, nil, nil, nil
end

local function ShouldSuppressEncounterNow()
    return settings
        and settings.disableDefaultPreyIcon == true
        and ShouldSuppressDefaultPreyEncounter()
end

local function EnsureWidgetSuppressionHook(frameRef)
    if not frameRef or WIDGET_SUPPRESSION_HOOKED[frameRef] or not frameRef.HookScript then
        return
    end

    WIDGET_SUPPRESSION_HOOKED[frameRef] = true
    frameRef:HookScript("OnShow", function(self)
        -- DISABLED: Calling SetAlpha/Hide in this hook creates a taint context that
        -- propagates to downstream Blizzard code (e.g., tooltip layout math), causing
        -- "attempt to compare secret number" errors in SharedTooltipTemplates.lua
        -- and other layout code. Suppression is handled exclusively in the 
        -- settings/state update handlers outside the widget event context.
        --
        -- local ok = pcall(function()
        --   if ShouldSuppressEncounterNow() then
        --       ApplyWidgetFrameSuppression(self, true)
        --       if self.IsShown and self:IsShown() then
        --           state.pendingWidgetSuppressionAfterCombat = true
        --       end
        --   end
        -- end)
    end)
end

ApplyDefaultPreyIconVisibility = function()
    if not settings then
        return
    end

    -- Gate: do not manipulate prey widget frames until the bar UI is initialized.
    -- On reload, running this before EnsureBar() completes can corrupt frame visibility
    -- and cascade to break bar rendering.
    if not UI.barFrame then
        return
    end

    CaptureLivePreyHuntFrames()

    if settings.disableDefaultPreyIcon ~= true then
        local function restoreFrame(frameRef)
            if not frameRef then
                return
            end

            ApplyWidgetFrameSuppression(frameRef, false)
            if frameRef.IsShown
                and not frameRef:IsShown()
                and frameRef.Show then
                pcall(frameRef.Show, frameRef)
            end
        end

        if preyHuntIconFrame then
            restoreFrame(preyHuntIconFrame)
        end

        for frameRef in pairs(PREY_WIDGET_FRAMES) do
            if frameRef and frameRef ~= preyHuntIconFrame then
                restoreFrame(frameRef)
            end
        end

        state.pendingWidgetSuppressionAfterCombat = false
        suppressionRetryPending = false
        suppressionRetryCount = 0
        return
    end

    local touchedAnyFrame = false

    if preyHuntIconFrame then
        touchedAnyFrame = true
        EnsureWidgetSuppressionHook(preyHuntIconFrame)
        ApplyWidgetFrameSuppression(preyHuntIconFrame, true)
        if preyHuntIconFrame.IsShown and preyHuntIconFrame:IsShown()
            and type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown()
        then
            state.pendingWidgetSuppressionAfterCombat = true
        end
    end

    for frameRef in pairs(PREY_WIDGET_FRAMES) do
        if frameRef and frameRef ~= preyHuntIconFrame then
            touchedAnyFrame = true
            EnsureWidgetSuppressionHook(frameRef)
            ApplyWidgetFrameSuppression(frameRef, true)
            if frameRef.IsShown and frameRef:IsShown()
                and type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown()
            then
                state.pendingWidgetSuppressionAfterCombat = true
            end
        end
    end

    if not touchedAnyFrame then
        ScheduleSuppressionRetry()
    else
        suppressionRetryPending = false
        suppressionRetryCount = 0
    end
end

local function EnsurePreyHuntMixinSuppressionHook()
    if preyHuntMixinHooked then
        return
    end

    local mixin = _G.UIWidgetTemplatePreyHuntProgressMixin
    if not mixin or type(hooksecurefunc) ~= "function" then
        return
    end

    local ok = pcall(hooksecurefunc, mixin, "Setup", function(self, widgetInfo)
        preyHuntIconFrame = self
        PREY_WIDGET_FRAMES[self] = true
        state.lastWidgetSetupAt = (GetTime and GetTime()) or 0

        local shownState = nil
        local progressState = nil
        local tooltipText = nil
        local captureSource = "none"

        if type(widgetInfo) == "table" then
            shownState = CoerceSanitizedNumber(widgetInfo.shownState)
            progressState = CoerceSanitizedNumber(widgetInfo.progressState)
            local widgetQuestID = ExtractWidgetQuestID(widgetInfo)
            if IsValidQuestID(widgetQuestID) then
                state.lastWidgetBoundQuestID = widgetQuestID
            elseif IsValidQuestID(state.activeQuestID) then
                -- Some clients omit questID from widget payloads. Bind to the
                -- currently tracked prey quest at Setup-time to keep updates
                -- stable without carrying state across new quest handoffs.
                state.lastWidgetBoundQuestID = state.activeQuestID
            end
            if type(widgetInfo.tooltip) == "string" then
                tooltipText = widgetInfo.tooltip
            end
            if shownState ~= nil or progressState ~= nil or tooltipText ~= nil then
                captureSource = "widgetInfo"
            end
        end

        if shownState ~= nil or progressState ~= nil or tooltipText ~= nil then
            preyWidgetInfoCache = {
                shownState = shownState,
                progressState = progressState,
                tooltip = tooltipText,
                questID = state.lastWidgetBoundQuestID,
                captureSource = captureSource,
                argType = type(widgetInfo),
            }
            -- Setup indicates widget payload freshness, not authoritative zone.
            -- Force a zone recompute on the normal runtime pass instead of
            -- certifying in-zone directly from widget visibility.
            state.zoneCacheDirty = true
            if type(UpdateBarDisplay) == "function" then
                UpdateBarDisplay()
            end
        else
            preyWidgetInfoCache = nil
        end

        -- Hide immediately after Blizzard Setup when the option is enabled.
        if settings and settings.disableDefaultPreyIcon == true then
            ApplyWidgetFrameSuppression(self, true)
            if self.IsShown and self:IsShown()
                and type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown()
            then
                state.pendingWidgetSuppressionAfterCombat = true
            end
        end
    end)

    if ok then
        preyHuntMixinHooked = true
        CaptureLivePreyHuntFrames()
    end
end

ShouldSuppressDefaultPreyEncounter = function()
    return settings and settings.disableDefaultPreyIcon == true
end

local function SafeFieldRead(tbl, key)
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

TryOpenPreyQuestOnMap = function()
    local questID = SafeToNumber(state and state.activeQuestID)
    if not IsValidQuestID(questID) then
        return false
    end

    -- Stage 4 bar click behavior: only super-track the active prey quest.
    -- Do not open the world map or set user waypoints here.
    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedQuestID) == "function" then
        local ok = pcall(C_SuperTrack.SetSuperTrackedQuestID, questID)
        return ok == true
    end

    return false
end

local function UpdatePreyDisplay()
    if not settings then
        return
    end

    EnsurePreyHuntMixinSuppressionHook()
    CaptureLivePreyHuntFrames()

    -- Do not touch widget systems while idle; only process when we are actively
    -- tracking prey or when icon suppression is enabled.
    if settings.disableDefaultPreyIcon ~= true
        and not IsValidQuestID(state and state.activeQuestID)
        and not IsValidQuestID(state and state.cachedActivePreyQuestID)
    then
        return
    end

    -- Set up OnShow hook to suppress the icon when it appears, if suppression is enabled.
    if preyHuntIconFrame and settings.disableDefaultPreyIcon == true then
        EnsureWidgetSuppressionHook(preyHuntIconFrame)
        -- Re-apply suppression to any currently-shown frame.
        ApplyWidgetFrameSuppression(preyHuntIconFrame, true)
        if preyHuntIconFrame.IsShown and preyHuntIconFrame:IsShown() then
            state.pendingWidgetSuppressionAfterCombat = true
        end
    elseif preyHuntIconFrame then
        -- Restore the icon if suppression is disabled.
        ApplyWidgetFrameSuppression(preyHuntIconFrame, false)
    end

    suppressionRetryPending = false
    suppressionRetryCount = 0
end

NormalizeSoundSettings = function()
    settings.soundsEnabled = settings.soundsEnabled ~= false

    local rawChannel = settings.soundChannel
    if type(rawChannel) ~= "string" then
        rawChannel = ""
    end

    local channelLower = string.lower(rawChannel)
    if channelLower == "master" then
        settings.soundChannel = "Master"
    elseif channelLower == "sfx" then
        settings.soundChannel = "SFX"
    elseif channelLower == "dialog" then
        settings.soundChannel = "Dialog"
    elseif channelLower == "ambience" then
        settings.soundChannel = "Ambience"
    elseif channelLower == "music" then
        settings.soundChannel = "Music"
    else
        settings.soundChannel = "SFX"
    end

    settings.soundEnhance = Clamp(math.floor((tonumber(settings.soundEnhance) or 0) + 0.5), 0, 100)

    if type(settings.soundFileNames) ~= "table" then
        settings.soundFileNames = {}
    end

    local runtime = GetRuntimeModule("SoundsRuntime")
    local soundContext = {
        soundFolderPrefix = SOUND_FOLDER_PREFIX,
    }

    local mergedNames = {}
    local seen = {}

    local function pushFileName(fileName)
        local normalized = nil
        if runtime and type(runtime.NormalizeSoundFileName) == "function" then
            normalized = runtime:NormalizeSoundFileName(fileName, soundContext)
        end
        if not normalized or seen[normalized] then
            return
        end
        seen[normalized] = true
        table.insert(mergedNames, normalized)
    end

    local function pushConfiguredSoundPath(path)
        if type(path) ~= "string" or path == "" or path == "__NONE__" then
            return
        end

        local fileName = nil
        if runtime and type(runtime.ExtractAddonSoundFileName) == "function" then
            fileName = runtime:ExtractAddonSoundFileName(path, soundContext)
        end

        if not fileName and runtime and type(runtime.NormalizeSoundFileName) == "function" then
            fileName = runtime:NormalizeSoundFileName(path, soundContext)
        end

        pushFileName(fileName)
    end

    local function canonicalizeConfiguredSoundPath(path)
        if type(path) ~= "string" or path == "" or path == "__NONE__" then
            return path
        end

        if not runtime or type(runtime.BuildAddonSoundPath) ~= "function" then
            return path
        end

        local fileName = nil
        if type(runtime.ExtractAddonSoundFileName) == "function" then
            fileName = runtime:ExtractAddonSoundFileName(path, soundContext)
        end

        if not fileName and type(runtime.NormalizeSoundFileName) == "function" then
            fileName = runtime:NormalizeSoundFileName(path, soundContext)
        end

        if not fileName then
            return path
        end

        return runtime:BuildAddonSoundPath(fileName, soundContext) or path
    end

    for _, defaultName in ipairs(DEFAULT_SOUND_FILENAMES) do
        pushFileName(defaultName)
    end

    for _, configuredName in ipairs(settings.soundFileNames) do
        pushFileName(configuredName)
    end

    for stage = 1, MAX_STAGE do
        local existingPath = settings.stageSounds and settings.stageSounds[stage]
        pushConfiguredSoundPath(existingPath)
    end

    pushConfiguredSoundPath(settings.ambushSoundPath)
    pushConfiguredSoundPath(settings.bloodyCommandSoundPath)
    pushConfiguredSoundPath(settings.echoOfPredationSoundPath)
    settings.soundFileNames = mergedNames

    local allowedPathLower = {}
    for _, fileName in ipairs(settings.soundFileNames) do
        local fullPath = nil
        if runtime and type(runtime.BuildAddonSoundPath) == "function" then
            fullPath = runtime:BuildAddonSoundPath(fileName, soundContext)
        end
        if type(fullPath) == "string" and fullPath ~= "" then
            allowedPathLower[string.lower(fullPath)] = true
        end
    end

    for _, entry in ipairs(GetExternalSoundCatalog()) do
        if type(entry) == "table" and type(entry.key) == "string" and entry.key ~= "" then
            allowedPathLower[string.lower(entry.key)] = true
        end
    end

    if type(settings.stageSounds) ~= "table" then
        settings.stageSounds = {}
    end

    for stage = 1, MAX_STAGE do
        local configuredPath = settings.stageSounds[stage]
        if type(configuredPath) ~= "string" or configuredPath == "" then
            local legacyPath = settings.stageSounds[tostring(stage)]
            if type(legacyPath) == "string" and legacyPath ~= "" then
                configuredPath = legacyPath
            end
        end

        configuredPath = canonicalizeConfiguredSoundPath(configuredPath)

        if type(configuredPath) == "string" and string.find(string.lower(configuredPath), "predator%-idle%.ogg", 1, false) then
            configuredPath = nil
        end

        if configuredPath ~= "__NONE__" then
            if type(configuredPath) ~= "string" or configuredPath == "" then
                configuredPath = (stage == 1 and ALERT_SOUND_PATH)
                    or (stage == 2 and AMBUSH_SOUND_PATH)
                    or (stage == 3 and TORMENT_SOUND_PATH)
                    or (stage == 4 and KILL_SOUND_PATH)
            end

            if type(configuredPath) ~= "string" or not allowedPathLower[string.lower(configuredPath)] then
                configuredPath = (stage == 1 and ALERT_SOUND_PATH)
                    or (stage == 2 and AMBUSH_SOUND_PATH)
                    or (stage == 3 and TORMENT_SOUND_PATH)
                    or (stage == 4 and KILL_SOUND_PATH)
            end
        end

        settings.stageSounds[stage] = configuredPath
    end

    settings.ambushSoundPath = canonicalizeConfiguredSoundPath(settings.ambushSoundPath)

    if settings.ambushSoundPath ~= "__NONE__"
        and (type(settings.ambushSoundPath) ~= "string" or not allowedPathLower[string.lower(settings.ambushSoundPath)])
    then
        settings.ambushSoundPath = KILL_SOUND_PATH
    end

    settings.bloodyCommandSoundPath = canonicalizeConfiguredSoundPath(settings.bloodyCommandSoundPath)

    if settings.bloodyCommandSoundPath ~= "__NONE__"
        and (type(settings.bloodyCommandSoundPath) ~= "string" or not allowedPathLower[string.lower(settings.bloodyCommandSoundPath)])
    then
        settings.bloodyCommandSoundPath = KILL_SOUND_PATH
    end

    settings.echoOfPredationSoundPath = canonicalizeConfiguredSoundPath(settings.echoOfPredationSoundPath)

    if settings.echoOfPredationSoundPath ~= "__NONE__"
        and (type(settings.echoOfPredationSoundPath) ~= "string" or not allowedPathLower[string.lower(settings.echoOfPredationSoundPath)])
    then
        settings.echoOfPredationSoundPath = "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg"
    end

    settings.stageSounds[5] = nil
end

local function ResetAllSettings()
    for key in pairs(settings) do
        settings[key] = nil
    end

    ApplyDefaults(settings, DEFAULTS)
    NormalizeTransientSettings()
    NormalizeLabelSettings()
    NormalizeColorSettings()
    NormalizeDisplaySettings()
    NormalizeProgressSettings()
    NormalizeAmbushSettings()
    NormalizeSoundSettings()

    state.forceShowBar = false
    state.stageSoundPlayed = {}
    state.stageSoundAttempted = {}
    ClearBloodyCommandAlert()

    ApplyBarSettings()
    UpdateBarDisplay()

    if UI.optionsPanel and UI.optionsPanel.PreydatorRefreshControls then
        UI.optionsPanel.PreydatorRefreshControls()
    end
end

ExtractWidgetQuestID = function(info)
    if type(info) ~= "table" then
        return nil
    end

    local possibleFields = {
        "questID",
        "questId",
        "associatedQuestID",
        "associatedQuestId",
    }

    for _, fieldName in ipairs(possibleFields) do
        local value = info[fieldName]
        if type(value) == "number" and value > 0 then
            return value
        end
    end

    return nil
end

-- Reads prey widget state from the snapshot captured by the mixin Setup hook.
-- Never calls GetAllWidgetsBySetID or reads widgetID/widgetType fields; those are
-- secret numbers that taint subsequent Blizzard layout/widget operations even inside pcall.
FindPreyWidgetProgressState = function(activeQuestID)
    local function TryBuildCacheFromFrame(frameRef, sourceTag)
        if not frameRef then
            return nil
        end

        local frameShown = frameRef.IsShown and frameRef:IsShown() or false
        local now = (GetTime and GetTime()) or 0
        local setupFresh = (now - (state.lastWidgetSetupAt or 0)) <= WIDGET_SETUP_FRESH_SECONDS
        if not frameShown and not setupFresh then
            return nil
        end

        local shownState, progressState, tooltipText, fieldSource = ResolvePreyFieldsFromFrame(frameRef)
        if shownState == nil and progressState == nil and tooltipText == nil then
            return nil
        end

        local captureSource = sourceTag
        if fieldSource and fieldSource ~= "" then
            captureSource = captureSource .. ":" .. fieldSource
        end

        return {
            shownState = shownState,
            progressState = progressState,
            tooltip = tooltipText,
            questID = state.lastWidgetBoundQuestID,
            captureSource = captureSource,
            argType = "frame-fallback",
        }
    end

    local function BuildCacheFromTrackedFrames()
        local refreshed = TryBuildCacheFromFrame(preyHuntIconFrame, "liveFrame")
        if refreshed then
            return refreshed
        end

        for frameRef in pairs(PREY_WIDGET_FRAMES) do
            refreshed = TryBuildCacheFromFrame(frameRef, "trackedFrame")
            if refreshed then
                return refreshed
            end
        end

        return nil
    end

    local info = preyWidgetInfoCache
    -- Keep the cache synchronized with live/tracked prey frames each pass.
    -- Some clients stop delivering full Setup payloads after the first update,
    -- which can freeze progression if we only trust stale cached state.
    local refreshed = BuildCacheFromTrackedFrames()
    if refreshed then
        if info ~= nil then
            if refreshed.questID == nil and info.questID ~= nil then
                refreshed.questID = info.questID
            end

            local existingProgressState = CoerceSanitizedNumber(info.progressState)
            local refreshedProgressState = CoerceSanitizedNumber(refreshed.progressState)
            if existingProgressState ~= nil and (refreshedProgressState == nil or refreshedProgressState < existingProgressState) then
                refreshed.progressState = info.progressState
            end
        end

        info = refreshed
        preyWidgetInfoCache = refreshed
    elseif not info then
        return nil, nil, nil, nil
    elseif info.progressState == nil then
        return nil, nil, nil, nil
    end

    local shownStateShown = (Enum and Enum.WidgetShownState and Enum.WidgetShownState.Shown) or WIDGET_SHOWN
    -- Only reject if shownState is explicitly a non-shown value; nil is allowed because
    -- shownState can be a protected number that reads as nil in insecure context.
    if info.shownState ~= nil and info.shownState ~= shownStateShown then
        return nil, nil, nil, nil
    end

    local pct = ExtractProgressPercent(info, info.tooltip)
    if IsValidQuestID(activeQuestID) then
        local widgetQuestID = ExtractWidgetQuestID(info)
        if widgetQuestID == activeQuestID or widgetQuestID == nil then
            return info.progressState, info.tooltip, pct, nil
        end
        return nil, nil, nil, nil
    end

    return info.progressState, info.tooltip, pct, nil
end

local function ResetStateForNewQuest(questID, forceReset)
    if forceReset == true or state.activeQuestID ~= questID then
        local cachedWidgetQuestID = CoerceSanitizedNumber(state.lastWidgetBoundQuestID)
            or CoerceSanitizedNumber(preyWidgetInfoCache and preyWidgetInfoCache.questID)
        local hasMatchingWidgetCache = forceReset ~= true
            and cachedWidgetQuestID == questID
            and preyWidgetInfoCache ~= nil

        state.activeQuestID = questID
        state.lastNotifiedPreyEndQuestID = nil
        state.progressState = nil
        state.progressPercent = nil
        if not hasMatchingWidgetCache then
            state.lastWidgetSeenAt = 0
            state.lastWidgetSetupAt = 0
            state.lastWidgetBoundQuestID = nil
            preyWidgetInfoCache = nil
        end
        state.stageSoundPlayed = {}
        state.stageSoundAttempted = {}
        state.stage = 1
        local runtime = GetRuntimeModule("PreyContextRuntime")
        if runtime and type(runtime.GetPreyZoneInfo) == "function" then
            state.preyZoneName, state.preyZoneMapID = runtime:GetPreyZoneInfo(questID, {
                taskQuestApi = C_TaskQuest,
                mapApi = C_Map,
                questLog = C_QuestLog,
            })
        else
            state.preyZoneName = nil
            state.preyZoneMapID = nil
        end
        state.inPreyZone = nil
        state.confirmedPreyZoneMapID = nil
        state.zoneCacheDirty = true
        RefreshInPreyZoneStatus(questID, true)
        state.preyTooltipText = nil
        state.preyTargetName, state.preyTargetDifficulty = ExtractPreyTargetFromQuestTitle(questID)
        state.ambushAlertUntil = 0
        state.lastAmbushSoundAt = 0
        state.lastEchoOfPredationSoundAt = 0
        state.lastAmbushSystemMessage = nil
        state.ambushSourceName = nil
    end
end

local function UpdatePreyState()
    local now = GetTime and GetTime() or 0
    local questID = GetCurrentActivePreyQuestCached(0)
    local hasActiveQuest = IsValidQuestID(questID)
    local forceKillStage = (state.killStageUntil or 0) > now
    local forceAmbushAlert = (state.ambushAlertUntil or 0) > now
    local enteredPreyZoneThisPass = false

    if not hasActiveQuest and not forceKillStage then
        local endingQuestID = state.activeQuestID or questID
        local completedTransition = tonumber(state.stage) == MAX_STAGE
        if endingQuestID and endingQuestID > 0 then
            if completedTransition ~= true or state.lastNotifiedPreyEndQuestID ~= endingQuestID then
                RunModuleHook("OnPreyQuestEnded", {
                    questID = endingQuestID,
                    completed = completedTransition == true,
                    stage = tonumber(state.stage),
                    difficulty = state.preyTargetDifficulty,
                })
                if completedTransition == true then
                    state.lastNotifiedPreyEndQuestID = endingQuestID
                end
            end
        end
        DebugLogPreyState("clear", questID, false, state.progressState, state.progressPercent, state.inPreyZone)
        ClearPreyStateAndDisplay()
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    if hasActiveQuest then
        ResetStateForNewQuest(questID)
        local inZoneBeforeRefresh = state.inPreyZone == true
        RefreshInPreyZoneStatus(questID, false)
        enteredPreyZoneThisPass = (state.inPreyZone == true and not inZoneBeforeRefresh)

        -- While out of prey zone, skip expensive widget/objective scans.
        if state.inPreyZone == false and not forceKillStage and not forceAmbushAlert then
            state.lastPercentSource = "none"
            state.preyTooltipText = nil
            ApplyDefaultPreyIconVisibility()
            UpdateBarDisplay()
            return
        end
    end

    local newProgressState, tooltipText, newProgressPercent = nil, nil, nil
    if hasActiveQuest then
        newProgressState, tooltipText, newProgressPercent = FindPreyWidgetProgressState(questID)
    end
    local hasWidgetData = newProgressState ~= nil

    if hasWidgetData then
        state.lastWidgetSeenAt = now
    end

    local effectiveQuestID = hasActiveQuest and questID or nil

    local questCompleted = false
    if questID and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        questCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
    end

    local questStillActive = IsQuestStillActive(questID)
    if questCompleted or (hasActiveQuest and not questStillActive and not hasWidgetData) then
        local endingQuestID = effectiveQuestID or state.activeQuestID or questID
        local completedTransition = questCompleted or (((not hasActiveQuest) or (not questStillActive)) and tonumber(state.stage) == MAX_STAGE)
        if endingQuestID and endingQuestID > 0 then
            if completedTransition ~= true or state.lastNotifiedPreyEndQuestID ~= endingQuestID then
                RunModuleHook("OnPreyQuestEnded", {
                    questID = endingQuestID,
                    completed = completedTransition == true,
                    stage = tonumber(state.stage),
                    difficulty = state.preyTargetDifficulty,
                })
                if completedTransition == true then
                    state.lastNotifiedPreyEndQuestID = endingQuestID
                end
            end
        end
        DebugLogPreyState("clear", questID, hasWidgetData, state.progressState, state.progressPercent, state.inPreyZone)
        ClearPreyStateAndDisplay()
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    local oldProgressState = state.progressState
    local percentSource = "none"
    newProgressState = CoerceSanitizedNumber(newProgressState)
    newProgressPercent = CoerceSanitizedNumber(newProgressPercent)
    -- Allow objective inference whenever widget state is unresolved or reports
    -- progressState=0. Setup can re-fire frequently for the same frame and keep
    -- setup freshness hot, so freshness-gating inference can permanently block
    -- stage advancement.
    if (newProgressState == nil or newProgressState == 0)
        and hasActiveQuest and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local objectives = C_QuestLog.GetQuestObjectives(questID)
        if type(objectives) == "table" and #objectives >= 1 then
            local first = objectives[1]
            local second = objectives[2]

            local function IsObjectiveDone(objective)
                if type(objective) ~= "table" then
                    return false
                end
                if objective.finished == true then
                    return true
                end

                local fulfilled = CoerceSafeNumeric(objective.numFulfilled)
                local required = CoerceSafeNumeric(objective.numRequired)
                if fulfilled ~= nil and required ~= nil and required > 0 then
                    return fulfilled >= required
                end

                local text = objective.text
                if type(text) == "string" and text ~= "" then
                    local curText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                    local curValue = CoerceSafeNumeric(tonumber(curText))
                    local maxValue = CoerceSafeNumeric(tonumber(maxText))
                    if curValue ~= nil and maxValue ~= nil and maxValue > 0 then
                        return curValue >= maxValue
                    end
                end

                return false
            end

            local firstDone = IsObjectiveDone(first)
            local secondDone = IsObjectiveDone(second)
            local secondObjectivePresent = type(second) == "table"
                and ((type(second.text) == "string" and second.text ~= "")
                    or (CoerceSafeNumeric(second.numRequired) ~= nil))

            if secondDone or (firstDone and secondObjectivePresent) then
                newProgressState = PREY_PROGRESS_FINAL
            elseif firstDone then
                newProgressState = 1
            else
                newProgressState = 0
            end
        end
    end

    if newProgressState ~= nil then
        -- Never regress progressState within a hunt. Stale widget reads can produce
        -- lower values than the inference or mixin-hook previously established.
        if state.progressState == nil or newProgressState > state.progressState then
            state.progressState = newProgressState
        end
    end
    if newProgressPercent ~= nil then
        state.progressPercent = Clamp(newProgressPercent, 0, 100)
        percentSource = "widget"
    elseif newProgressState == nil then
        -- Keep objective percent out of display when stage is unknown.
        -- Objective rows can report 50% while true prey stage is 3/4, which causes
        -- misleading half-bar regressions after reload.
        state.progressPercent = nil
    end

    if newProgressPercent == nil and percentSource == "none" and newProgressState ~= nil then
        if newProgressState == PREY_PROGRESS_FINAL then
            state.progressPercent = 100
            percentSource = "final"
        else
            state.progressPercent = nil
        end
    elseif newProgressPercent == nil and percentSource == "none" and (now - (state.lastWidgetSeenAt or 0)) > 2 then
        -- Preserve last known stage/progress when widget payloads are temporarily
        -- unavailable after reload. Clearing progressState here regresses the bar
        -- back to stage 1 even while the hunt context remains valid.
        state.progressPercent = nil
    end
    state.lastPercentSource = percentSource
    state.preyTooltipText = tooltipText
    DebugLogPreyState("update", effectiveQuestID, hasWidgetData, state.progressState, state.progressPercent, state.inPreyZone)

    local oldStage = state.stage
    local newStage = GetStageFromState(state.progressState)
    state.stage = newStage

    local stageChanged = newStage ~= oldStage
    if stageChanged then
        TryPlayStageSound(newStage)
    elseif enteredPreyZoneThisPass
        and state.inPreyZone == true
        and not state.stageSoundPlayed[newStage]
        and not state.stageSoundAttempted[newStage]
    then
        TryPlayStageSound(newStage)
    end

    if newProgressState ~= PREY_PROGRESS_FINAL or oldProgressState == PREY_PROGRESS_FINAL then
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    if state.stageSoundPlayed[MAX_STAGE] or state.stageSoundAttempted[MAX_STAGE] then
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    TryPlayStageSound(MAX_STAGE)

    ApplyDefaultPreyIconVisibility()
    UpdateBarDisplay()
end

function Preydator:ShouldUseActivePolling()
    if IsRestrictedInstanceForPreyBar() then
        return false
    end

    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    local barModuleEnabled = true
    local soundsModuleEnabled = true
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        barModuleEnabled = customizationV2:IsModuleEnabled("bar") == true
        soundsModuleEnabled = customizationV2:IsModuleEnabled("sounds") == true
    end

    local soundsRuntimeEnabled = soundsModuleEnabled and settings and settings.soundsEnabled ~= false
    if not barModuleEnabled and not soundsRuntimeEnabled then
        return false
    end

    local now = GetTime and GetTime() or 0
    local trackedQuestID = state and state.activeQuestID or nil
    local hasTrackedQuest = IsValidQuestID(trackedQuestID) and IsQuestStillActive(trackedQuestID)
    local liveQuestID = GetCurrentActivePreyQuestCached(ACTIVE_PREY_QUEST_CACHE_SECONDS)
    local hasLiveQuest = IsValidQuestID(liveQuestID) and IsQuestStillActive(liveQuestID)
    local needsQuestBootstrap = hasLiveQuest and not hasTrackedQuest
    local needsStaleQuestCleanup = IsValidQuestID(trackedQuestID) and not hasTrackedQuest and not hasLiveQuest
    local inKillCarry = ((state and state.killStageUntil) or 0) > now
    local inAmbushAlert = ((state and state.ambushAlertUntil) or 0) > now
    local inBloodyCommandAlert = ((state and state.bloodyCommandAlertUntil) or 0) > now
    local inQuestListenBurst = ((state and state.questListenUntil) or 0) > now
    local editModeFrame = _G.EditModeManagerFrame
    local inEditPreview = settings
        and settings.showInEditMode == true
        and editModeFrame
        and editModeFrame.IsShown
        and editModeFrame:IsShown()
    local forceShowBar = state and state.forceShowBar == true
    local hasHotQuestContext = hasTrackedQuest and state and state.inPreyZone == true

    return needsQuestBootstrap
        or needsStaleQuestCleanup
        or inKillCarry
        or inAmbushAlert
        or inBloodyCommandAlert
        or inQuestListenBurst
        or inEditPreview
        or forceShowBar
        or hasHotQuestContext
end

function Preydator:SetPollingActive(enabled)
    if not frame then
        return
    end

    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        local barModuleEnabled = customizationV2:IsModuleEnabled("bar") == true
        local soundsModuleEnabled = customizationV2:IsModuleEnabled("sounds") == true
        local soundsRuntimeEnabled = soundsModuleEnabled and settings and settings.soundsEnabled ~= false
        if not barModuleEnabled and not soundsRuntimeEnabled then
            enabled = false
        end
    end

    local shouldEnable = enabled == true
    if shouldEnable == (state.pollingActive == true) then
        return
    end

    state.pollingActive = shouldEnable

    if shouldEnable then
        state.nextPollingEligibilityCheckAt = 0
        frame:SetScript("OnUpdate", function(_, elapsed)
            state.elapsedSinceUpdate = (state.elapsedSinceUpdate or 0) + (elapsed or 0)
            local now = GetTime and GetTime() or 0
            local inKillCarry = ((state and state.killStageUntil) or 0) > now
            local inAmbushAlert = ((state and state.ambushAlertUntil) or 0) > now
            local inBloodyCommandAlert = ((state and state.bloodyCommandAlertUntil) or 0) > now
            local inQuestListenBurst = ((state and state.questListenUntil) or 0) > now
            local editModeFrame = _G.EditModeManagerFrame
            local inEditPreview = settings
                and settings.showInEditMode == true
                and editModeFrame
                and editModeFrame.IsShown
                and editModeFrame:IsShown()
            local recentlySawWidget = (now - ((state and state.lastWidgetSeenAt) or 0)) <= 2.0
            local progressState = tonumber(state and state.progressState)
            local isIdleInZone = IsValidQuestID(state and state.activeQuestID)
                and state.inPreyZone == true
                and (progressState == nil or progressState == 0)
                and not recentlySawWidget
                and not inKillCarry
                and not inAmbushAlert
                and not inBloodyCommandAlert
                and not inQuestListenBurst
                and not (state and state.forceShowBar == true)
                and not inEditPreview
            local interval = isIdleInZone and 2.0 or UPDATE_INTERVAL_SECONDS
            if state.elapsedSinceUpdate < interval then
                return
            end

            state.elapsedSinceUpdate = 0
            UpdatePreyState()

            if now >= (state.nextPollingEligibilityCheckAt or 0) then
                state.nextPollingEligibilityCheckAt = now + 2.0
                if not Preydator:ShouldUseActivePolling() then
                    -- Final reconcile before detaching OnUpdate so completed/ended
                    -- prey quests do not leave stale stage-4 visibility latched.
                    UpdatePreyState()
                    if not Preydator:ShouldUseActivePolling() then
                        Preydator:SetPollingActive(false)
                    end
                end
            end
        end)
    else
        state.elapsedSinceUpdate = 0
        state.nextPollingEligibilityCheckAt = 0
        frame:SetScript("OnUpdate", nil)
    end
end

function Preydator:ApplyRuntimeSettings(nextSettings, emitProfileHook, refreshUi)
    if type(nextSettings) == "table" then
        settings = nextSettings
    end

    if type(settings) ~= "table" then
        return
    end

    ApplyDefaults(settings, DEFAULTS)
    EnsureDebugDB()
    debugDB.enabled = settings.debugSounds and true or false

    NormalizeTransientSettings()
    NormalizeSoundSettings()
    NormalizeLabelSettings()
    NormalizeColorSettings()
    do
        local runtime = GetRuntimeModule("SettingsRuntime")
        if runtime and type(runtime.RestoreBarPointFromBackup) == "function" then
            runtime:RestoreBarPointFromBackup(settings)
        end
    end
    NormalizeDisplaySettings()
    NormalizeProgressSettings()
    NormalizeAmbushSettings()
    ApplyDefaultPreyIconVisibility()

    state.forceShowBar = false

    if refreshUi then
        ApplyBarSettings()
        UpdateBarDisplay()
        Preydator:SetPollingActive(Preydator:ShouldUseActivePolling())
    end

    if emitProfileHook then
        RunModuleHook("OnProfileChanged", settings)
    end
end

-- ===========================================================================
-- Addon Launcher: Minimap Button + Blizzard Addon Compartment
-- Decoupled from CurrencyTracker — the launcher persists regardless of which
-- feature modules are enabled.
-- ===========================================================================

local LAUNCHER_ICON_PATH = "Interface\\AddOns\\Preydator\\media\\Preydator_64.png"
local LAUNCHER_LDB_NAME  = "Preydator"

local launcherMinimapButton
local launcherLdbObject
local launcherLdbRegistered = false

local function LauncherAtan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end
    if x > 0 then
        return math.atan(y / x)
    end
    if x < 0 then
        if y >= 0 then
            return math.atan(y / x) + math.pi
        end
        return math.atan(y / x) - math.pi
    end
    if y > 0 then
        return math.pi / 2
    end
    if y < 0 then
        return -math.pi / 2
    end
    return 0
end

local function LauncherNormalizeAngle(angle)
    if type(angle) ~= "number" then
        return 225
    end
    angle = angle % 360
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

local function GetLauncherSettings()
    local api = Preydator and Preydator.API
    if not api or type(api.GetSettings) ~= "function" then
        return nil
    end
    return api.GetSettings()
end

local function HandleAddonLauncherClick(mouseButton)
    local ct = Preydator and Preydator.GetModule and Preydator:GetModule("CurrencyTracker")
    if mouseButton == "LeftButton" then
        if ct and type(ct.ToggleCurrencyWindow) == "function" then
            ct:ToggleCurrencyWindow()
        end
        return
    end
    if mouseButton == "RightButton" and _G.IsShiftKeyDown and _G.IsShiftKeyDown() then
        OpenOptionsPanel()
        return
    end
    if mouseButton == "RightButton" then
        if ct and type(ct.ToggleWarbandWindow) == "function" then
            ct:ToggleWarbandWindow()
        end
    end
end

local function UpdateLauncherMinimapPosition()
    if not launcherMinimapButton then
        return
    end
    local addonSettings = GetLauncherSettings()
    local angle = 225
    if addonSettings and type(addonSettings.currencyMinimap) == "table" and type(addonSettings.currencyMinimap.minimapPos) == "number" then
        angle = addonSettings.currencyMinimap.minimapPos
    elseif addonSettings and type(addonSettings.currencyMinimapAngle) == "number" then
        angle = addonSettings.currencyMinimapAngle
    end
    angle = LauncherNormalizeAngle(angle)
    local minimap = _G.Minimap
    if not minimap then
        return
    end
    local radians = math.rad(angle)
    local minimapRadius = math.min(minimap:GetWidth(), minimap:GetHeight()) / 2
    local radius = minimapRadius + 8
    local x = math.cos(radians) * radius
    local y = math.sin(radians) * radius
    launcherMinimapButton:ClearAllPoints()
    launcherMinimapButton:SetPoint("CENTER", minimap, "CENTER", x, y)
end

local function UpdateLauncherButtonVisibility()
    local addonSettings = GetLauncherSettings()
    if not addonSettings then
        return
    end
    local LibStub = _G.LibStub
    local dbIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)
    local hide = addonSettings.currencyMinimapButton == false
    if dbIcon and launcherLdbRegistered then
        if hide then
            dbIcon:Hide(LAUNCHER_LDB_NAME)
        else
            dbIcon:Show(LAUNCHER_LDB_NAME)
        end
    elseif launcherMinimapButton then
        launcherMinimapButton:SetShown(not hide)
    end
end

-- Expose so Settings.lua can trigger an immediate visibility update when the
-- "Disable Minimap Button" checkbox is toggled.
Preydator.UpdateLauncherButtonVisibility = UpdateLauncherButtonVisibility

local function EnsureLauncherLdb()
    if launcherLdbObject then
        return launcherLdbObject
    end
    local LibStub = _G.LibStub
    local ldb = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
    if not ldb then
        return nil
    end
    local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })
    launcherLdbObject = ldb:NewDataObject(LAUNCHER_LDB_NAME, {
        type = "launcher",
        text = "Preydator",
        icon = LAUNCHER_ICON_PATH,
        OnClick = function(_, mouseButton)
            HandleAddonLauncherClick(mouseButton)
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip then
                return
            end
            tooltip:AddLine("Preydator")
            tooltip:AddLine(L["Left Click: Toggle Currency Window"], 1, 1, 1)
            tooltip:AddLine(L["Right Click: Toggle Warband Window"], 1, 1, 1)
            tooltip:AddLine(L["Shift + Right Click: Open Options"], 1, 1, 1)
        end,
    })
    return launcherLdbObject
end

local function EnsureLauncherMinimapButton()
    local addonSettings = GetLauncherSettings()
    local LibStub = _G.LibStub
    local dbIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)
    local ldb = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
    if addonSettings and type(addonSettings.currencyMinimap) ~= "table" then
        addonSettings.currencyMinimap = {}
    end
    if ldb and addonSettings then
        EnsureLauncherLdb()
    end
    if dbIcon and launcherLdbObject and addonSettings then
        if not launcherLdbRegistered then
            dbIcon:Register(LAUNCHER_LDB_NAME, launcherLdbObject, addonSettings.currencyMinimap)
            launcherLdbRegistered = true
        end
        return nil
    end
    if launcherLdbObject then
        return nil
    end
    if launcherMinimapButton or not _G.Minimap then
        return launcherMinimapButton
    end

    local button = CreateFrame("Button", "PreydatorMinimapButton", _G.Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:EnableMouse(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetSize(20, 20)
    background:SetPoint("CENTER", button, "CENTER", 0, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(LAUNCHER_ICON_PATH)
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(self, mouseButton)
        if self.wasDragged then
            return
        end
        HandleAddonLauncherClick(mouseButton)
    end)

    button:SetScript("OnDragStart", function(self)
        self.dragging = true
        self.wasDragged = false
        self:SetScript("OnUpdate", function(s)
            local minimap = _G.Minimap
            if not minimap then
                return
            end
            local mx, my = _G.GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            mx, my = mx / scale, my / scale
            local cx, cy = minimap:GetCenter()
            if not cx or not cy then
                return
            end
            local angle = LauncherNormalizeAngle(math.deg(LauncherAtan2(my - cy, mx - cx)))
            local s_settings = GetLauncherSettings()
            if s_settings then
                if type(s_settings.currencyMinimap) ~= "table" then
                    s_settings.currencyMinimap = {}
                end
                s_settings.currencyMinimap.minimapPos = angle
                s_settings.currencyMinimapAngle = angle
            end
            s.wasDragged = true
            UpdateLauncherMinimapPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self.dragging = nil
        self:SetScript("OnUpdate", nil)
        C_Timer.After(0.05, function()
            if launcherMinimapButton then
                launcherMinimapButton.wasDragged = nil
            end
        end)
    end)

    launcherMinimapButton = button
    UpdateLauncherMinimapPosition()
    -- Apply initial hide state from settings
    UpdateLauncherButtonVisibility()
    return button
end

function _G.Preydator_OnAddonCompartmentClick(_, buttonName)
    HandleAddonLauncherClick(buttonName or "LeftButton")
end

function _G.Preydator_OnAddonCompartmentEnter()
    local gt = _G.GameTooltip
    if not gt or type(gt.SetOwner) ~= "function" then
        return
    end
    local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })
    gt:SetOwner(_G.AddonCompartmentFrame or UIParent, "ANCHOR_LEFT")
    gt:ClearLines()
    gt:AddLine("Preydator")
    gt:AddLine(L["Left Click: Toggle Currency Window"], 1, 1, 1)
    gt:AddLine(L["Right Click: Toggle Warband Window"], 1, 1, 1)
    gt:AddLine(L["Shift + Right Click: Open Options"], 1, 1, 1)
    gt:Show()
end

function _G.Preydator_OnAddonCompartmentLeave()
    local gt = _G.GameTooltip
    if gt and type(gt.Hide) == "function" then
        gt:Hide()
    end
end

-- Minimal module so the launcher button is created on PLAYER_LOGIN,
-- independent of whether CurrencyTracker is enabled.
local AddonLauncherModule = {}
Preydator:RegisterModule("AddonLauncher", AddonLauncherModule)

function AddonLauncherModule:OnEvent(event)
    if event == "PLAYER_LOGIN" then
        EnsureLauncherMinimapButton()
        UpdateLauncherMinimapPosition()
    end
end

local function OnAddonLoaded()
    _G.PreydatorDB = _G.PreydatorDB or {}
    local profileSystem = Preydator and Preydator.ProfileSystem
    if profileSystem and type(profileSystem.EnsureProfiles) == "function" then
        profileSystem:EnsureProfiles()
        if type(profileSystem.GetActiveProfileTable) == "function" then
            settings = profileSystem:GetActiveProfileTable()
        end
    end
    if type(settings) ~= "table" then
        settings = _G.PreydatorDB
    end

    Preydator:ApplyRuntimeSettings(settings, false, false)
    ApplyAratorSilencing()
    Preydator:ShowSoundDefaultsPromptIfNeeded()
    AddDebugLog("OnAddonLoaded", "debug=" .. tostring(debugDB.enabled) .. " | stage" .. tostring(MAX_STAGE) .. "=" .. tostring(settings.stageSounds[MAX_STAGE]), true)

    -- Reload/login bootstrap from live quest context only.
    -- Do not seed stage/progress from snapshots here because prey quest IDs are
    -- reused and stale snapshots can incorrectly force stage 4 / 100%.
    do
        local liveQuestID = GetCurrentActivePreyQuestCached(0)
        if IsValidQuestID(liveQuestID) then
            state.activeQuestID = liveQuestID
            RefreshInPreyZoneStatus(liveQuestID, true)
            if type(ArmQuestListenBurst) == "function" then
                ArmQuestListenBurst(10)
            end
            UpdatePreyState()
        end
    end

    state.pollingActive = false

    EnsurePreyHuntMixinSuppressionHook()
    if type(_G.IsAddOnLoaded) == "function" and _G.IsAddOnLoaded("Blizzard_UIWidgets") then
        OnBlizzardWidgetsLoaded()
    end
    RunModuleHook("OnAddonLoaded")
end

OnBlizzardWidgetsLoaded = function()
    EnsurePreyHuntMixinSuppressionHook()
    ApplyDefaultPreyIconVisibility()
end

OnPlayerRegenEnabled = function()
    if state.pendingWidgetSuppressionAfterCombat == true then
        state.pendingWidgetSuppressionAfterCombat = false
        ApplyDefaultPreyIconVisibility()
    end
end

local function AddCheckbox(parent, label, x, y, getter, setter)
    local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    checkbox.Text:SetText(label)
    checkbox:SetChecked(getter())
    checkbox:SetScript("OnClick", function(self)
        setter(self:GetChecked())
    end)
    return checkbox
end

local function AddSlider(parent, label, x, y, minValue, maxValue, step, getter, setter)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetWidth(240)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(getter())
    slider.Text:SetText(label)
    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))
    slider:SetScript("OnValueChanged", function(self, value)
        setter(value)
    end)
    return slider
end

local function AddDropdown(parent, label, x, y, width, options, getter, setter)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    title:SetText(label)

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -4)

    local function GetOptions()
        if type(options) == "function" then
            return options() or {}
        end
        return options or {}
    end

    local function RefreshText()
        local key = getter()
        local entry = GetOptions()[key]
        UIDropDownMenu_SetText(dropdown, entry and entry.text or "Select")
    end

    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_Initialize(dropdown, function(_, _, _)
        local optionList = {}
        for key, entry in pairs(GetOptions()) do
            table.insert(optionList, { key = key, entry = entry })
        end

        table.sort(optionList, function(a, b)
            local left = tostring(a.entry and a.entry.text or "")
            local right = tostring(b.entry and b.entry.text or "")
            return left < right
        end)

        for _, item in ipairs(optionList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.entry.text
            info.func = function()
                setter(item.key)
                RefreshText()
            end
            info.checked = getter() == item.key
            UIDropDownMenu_AddButton(info)
        end
    end)

    dropdown.PreydatorRefreshText = RefreshText
    RefreshText()
    return dropdown
end

local function AddColorSwatch(parent, x, y, getter, setter, allowAlpha)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(28, 22)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText("")

    local swatch = button:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    swatch:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)

    local function Refresh()
        local c = getter()
        local a = (allowAlpha and c[4]) or 1
        swatch:SetColorTexture(c[1], c[2], c[3], a)
    end

    local function NormalizeColorInput(value, fallback)
        local fb = fallback or { 1, 1, 1, 1 }
        local r = value and (value[1] or value.r) or fb[1]
        local g = value and (value[2] or value.g) or fb[2]
        local b = value and (value[3] or value.b) or fb[3]

        local a = fb[4]
        if allowAlpha then
            if value then
                if value[4] ~= nil then
                    a = value[4]
                elseif value.a ~= nil then
                    a = value.a
                elseif value.opacity ~= nil then
                    a = 1 - value.opacity
                end
            end
        else
            a = 1
        end

        r = Clamp(tonumber(r) or fb[1] or 1, 0, 1)
        g = Clamp(tonumber(g) or fb[2] or 1, 0, 1)
        b = Clamp(tonumber(b) or fb[3] or 1, 0, 1)
        a = Clamp(tonumber(a) or fb[4] or 1, 0, 1)

        return { r, g, b, a }
    end

    local function GetPickerColor(defaultA)
        local r, g, b
        if ColorPickerFrame.GetColorRGB then
            r, g, b = ColorPickerFrame:GetColorRGB()
        elseif ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.GetColorRGB then
            r, g, b = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
        else
            r, g, b = 1, 1, 1
        end

        local a = defaultA
        if allowAlpha then
            if ColorPickerFrame.GetColorAlpha then
                a = ColorPickerFrame:GetColorAlpha()
            elseif OpacitySliderFrame and OpacitySliderFrame.GetValue then
                a = 1 - OpacitySliderFrame:GetValue()
            end
        end

        return r, g, b, a
    end

    button:SetScript("OnClick", function()
        if not ColorPickerFrame then
            return
        end

        UI.colorPickerSessionCounter = UI.colorPickerSessionCounter + 1
        local sessionID = UI.colorPickerSessionCounter
        ColorPickerFrame.preydatorSessionID = sessionID

        local start = getter()
        local startColor = {
            start[1] or 1,
            start[2] or 1,
            start[3] or 1,
            start[4] or 1,
        }

        local function ApplyColor()
            if ColorPickerFrame.preydatorSessionID ~= sessionID then
                return
            end

            local r, g, b, a = GetPickerColor(startColor[4])

            setter(NormalizeColorInput({ r, g, b, a }, startColor))
            Refresh()
        end

        local function CancelColor(previousValues)
            if ColorPickerFrame.preydatorSessionID ~= sessionID then
                return
            end

            local pr, pg, pb, pa = nil, nil, nil, nil
            if type(previousValues) == "table" then
                pr = previousValues.r or previousValues[1]
                pg = previousValues.g or previousValues[2]
                pb = previousValues.b or previousValues[3]
                pa = previousValues.a or previousValues[4]
            elseif ColorPickerFrame.GetPreviousValues then
                pr, pg, pb, pa = ColorPickerFrame:GetPreviousValues()
            end

            if pr == nil or pg == nil or pb == nil then
                pr, pg, pb, pa = startColor[1], startColor[2], startColor[3], startColor[4]
            end

            setter(NormalizeColorInput({ pr, pg, pb, pa }, startColor))
            Refresh()
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
            local info = {
                r = startColor[1],
                g = startColor[2],
                b = startColor[3],
                opacity = allowAlpha and startColor[4] or 0,
                hasOpacity = allowAlpha and true or false,
                func = ApplyColor,
                swatchFunc = ApplyColor,
                opacityFunc = ApplyColor,
                cancelFunc = CancelColor,
            }
            ColorPickerFrame:SetupColorPickerAndShow(info)
            return
        end

        ColorPickerFrame.hasOpacity = allowAlpha and true or false
        ColorPickerFrame.opacity = allowAlpha and (1 - startColor[4]) or 0
        ColorPickerFrame.previousValues = { startColor[1], startColor[2], startColor[3], startColor[4] }
        if ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:SetColorRGB(startColor[1], startColor[2], startColor[3])
        elseif ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.SetColorRGB then
            ColorPickerFrame.Content.ColorPicker:SetColorRGB(startColor[1], startColor[2], startColor[3])
        end
        ColorPickerFrame.func = ApplyColor
        ColorPickerFrame.swatchFunc = ApplyColor
        ColorPickerFrame.opacityFunc = ApplyColor
        ColorPickerFrame.cancelFunc = CancelColor

        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end)

    button.PreydatorRefresh = Refresh
    Refresh()
    return button
end

EnsureOptionsPanel = function()
    local settingsModule = Preydator.GetModule and Preydator:GetModule("Settings")
    if settingsModule and settingsModule.EnsureOptionsPanel then
        local panelRef, categoryID = settingsModule:EnsureOptionsPanel()
        if panelRef then
            UI.optionsPanel = panelRef
        end
        if categoryID ~= nil then
            UI.optionsCategoryID = categoryID
        end
        return
    end

    if UI.optionsPanel then
        return
    end

    local panel = CreateFrame("Frame", "PreydatorOptionsPanel")
    panel.name = "Preydator"
    local panelRoot = panel

    local scrollFrame = CreateFrame("ScrollFrame", "PreydatorOptionsScrollFrame", panelRoot, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panelRoot, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", panelRoot, "BOTTOMRIGHT", -30, 8)

    local content = CreateFrame("Frame", "PreydatorOptionsContent", scrollFrame)
    content:SetSize(760, 900)
    scrollFrame:SetScrollChild(content)

    UI.optionsScrollFrame = scrollFrame
    UI.optionsContentFrame = content
    panel = content

    NormalizeLabelSettings()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Preydator")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Bar movement, scale, font, texture, and sound settings.")
    subtitle:SetWidth(700)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetWordWrap(true)

    local lockCheckbox = AddCheckbox(panel, "Lock Bar", 20, -55, function() return settings.locked end, function(value)
        settings.locked = value
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local onlyShowInPreyZoneCheckbox = AddCheckbox(panel, "Only show in prey zone", 20, -83, function() return settings.onlyShowInPreyZone end, function(value)
        settings.onlyShowInPreyZone = value
        UpdateBarDisplay()
    end)

    local showInEditModeCheckbox = AddCheckbox(panel, "Show in Edit Mode preview", 20, -195, function() return settings.showInEditMode ~= false end, function(value)
        settings.showInEditMode = value
        NormalizeDisplaySettings()
        UpdateBarDisplay()
    end)

    local disableDefaultPreyIconCheckbox = AddCheckbox(panel, "Disable Default Prey Icon", 20, -139, function() return settings.disableDefaultPreyIcon == true end, function(value)
        settings.disableDefaultPreyIcon = value
        ApplyDefaultPreyIconVisibility()
    end)

    local scaleSlider = AddSlider(panel, "Scale", 20, -435, 0.5, 2, 0.05, function() return settings.scale end, function(value)
        settings.scale = Clamp(value, 0.5, 2)
        ApplyBarSettings()
    end)

    local widthSlider = AddSlider(panel, "Width", 20, -470, 160, 500, 1, function() return settings.width end, function(value)
        settings.width = Clamp(math.floor(value + 0.5), 160, 500)
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local heightSlider = AddSlider(panel, "Height", 20, -505, 10, 40, 1, function() return settings.height end, function(value)
        settings.height = Clamp(math.floor(value + 0.5), 10, 40)
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local fontSizeSlider = AddSlider(panel, "Font Size", 20, -540, 8, 24, 1, function() return settings.fontSize end, function(value)
        settings.fontSize = Clamp(math.floor(value + 0.5), 8, 24)
        ApplyBarSettings()
    end)

    local stageNamesTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    stageNamesTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -407)
    stageNamesTitle:SetText("Stage Names")

    local stageNameEdits = {}
    for stageIndex = 1, (MAX_STAGE - 1) do
        local rowY = -442 - ((stageIndex - 1) * 35)
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, rowY)
        label:SetText(tostring(stageIndex) .. ":")

        local edit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        edit:SetSize(180, 20)
        edit:SetAutoFocus(false)
        edit:SetTextInsets(6, 6, 0, 0)
        edit:SetPoint("TOPLEFT", panel, "TOPLEFT", 350, -441 - ((stageIndex - 1) * 35))
        edit:SetText(GetStageLabel(stageIndex))
        edit:SetScript("OnEnterPressed", function(self)
            settings.stageLabels[stageIndex] = self:GetText()
            NormalizeLabelSettings()
            self:SetText(settings.stageLabels[stageIndex])
            self:ClearFocus()
            UpdateBarDisplay()
        end)
        edit:SetScript("OnEditFocusLost", function(self)
            settings.stageLabels[stageIndex] = self:GetText()
            NormalizeLabelSettings()
            self:SetText(settings.stageLabels[stageIndex])
            UpdateBarDisplay()
        end)
        stageNameEdits[stageIndex] = edit
    end

    local outZoneRowY = -547
    local outZoneLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    outZoneLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, outZoneRowY)
    outZoneLabel:SetText("Zone:")

    local outZoneEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    outZoneEdit:SetSize(156, 20)
    outZoneEdit:SetAutoFocus(false)
    outZoneEdit:SetTextInsets(6, 6, 0, 0)
    outZoneEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 365, -546)
    outZoneEdit:SetText(settings.outOfZoneLabel or DEFAULT_OUT_OF_ZONE_LABEL)
    outZoneEdit:SetScript("OnEnterPressed", function(self)
        settings.outOfZoneLabel = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.outOfZoneLabel)
        self:ClearFocus()
        UpdateBarDisplay()
    end)
    outZoneEdit:SetScript("OnEditFocusLost", function(self)
        settings.outOfZoneLabel = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.outOfZoneLabel)
        UpdateBarDisplay()
    end)

    local ambushLabelText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ambushLabelText:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -575)
    ambushLabelText:SetText("Ambush:")

    local ambushLabelEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    ambushLabelEdit:SetSize(156, 20)
    ambushLabelEdit:SetAutoFocus(false)
    ambushLabelEdit:SetTextInsets(6, 6, 0, 0)
    ambushLabelEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 380, -574)
    ambushLabelEdit:SetText(settings.ambushSuffix or "preyTargetName")
    ambushLabelEdit:SetScript("OnEnterPressed", function(self)
        settings.ambushSuffix = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.ambushSuffix)
        self:ClearFocus()
        UpdateBarDisplay()
    end)
    ambushLabelEdit:SetScript("OnEditFocusLost", function(self)
        settings.ambushSuffix = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.ambushSuffix)
        UpdateBarDisplay()
    end)

    local restoreNamesButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    restoreNamesButton:SetSize(180, 24)
    restoreNamesButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -764)
    restoreNamesButton:SetText("Restore Default Names")
    restoreNamesButton:SetScript("OnClick", function()
        for stageIndex = 1, (MAX_STAGE - 1) do
            settings.stageLabels[stageIndex] = DEFAULT_STAGE_LABELS[stageIndex]
            stageNameEdits[stageIndex]:SetText(DEFAULT_STAGE_LABELS[stageIndex])
        end
        settings.outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL
        settings.ambushPrefix = "AMBUSH: "
        settings.ambushSuffix = "preyTargetName"
        settings.bloodyCommandPrefix = "Bloody Command: "
        settings.bloodyCommandSuffix = "bloodyCommandSourceName"
        outZoneEdit:SetText(DEFAULT_OUT_OF_ZONE_LABEL)
        ambushLabelEdit:SetText("preyTargetName")
        UpdateBarDisplay()
    end)

    local restoreSoundsButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    restoreSoundsButton:SetSize(180, 24)
    restoreSoundsButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -793)
    restoreSoundsButton:SetText("Restore Default Sounds")
    restoreSoundsButton:SetScript("OnClick", function()
        settings.soundsEnabled = DEFAULTS.soundsEnabled
        settings.soundChannel = DEFAULTS.soundChannel
        settings.soundEnhance = DEFAULTS.soundEnhance
        settings.ambushSoundEnabled = DEFAULTS.ambushSoundEnabled
        settings.ambushVisualEnabled = DEFAULTS.ambushVisualEnabled
        settings.ambushSoundPath = DEFAULTS.ambushSoundPath
        settings.soundFileNames = {}
        for _, fileName in ipairs(DEFAULT_SOUND_FILENAMES) do
            table.insert(settings.soundFileNames, fileName)
        end
        for stageIndex = 1, MAX_STAGE do
            settings.stageSounds[stageIndex] = DEFAULTS.stageSounds[stageIndex]
        end
        NormalizeSoundSettings()
        NormalizeAmbushSettings()
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
    end)

    local resetAllButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetAllButton:SetSize(180, 24)
    resetAllButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -821)
    resetAllButton:SetText("Reset All Defaults")
    resetAllButton:SetScript("OnClick", function()
        ResetAllSettings()
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
    end)

    local customSoundTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    customSoundTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -659)
    customSoundTitle:SetText("Custom Sound Files: No Spaces")

    local customSoundPathLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    customSoundPathLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -687)
    customSoundPathLabel:SetText("Interface\\AddOns\\Preydator\\sounds\\")

    local customSoundEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    customSoundEdit:SetSize(210, 20)
    customSoundEdit:SetAutoFocus(false)
    customSoundEdit:SetTextInsets(6, 6, 0, 0)
    customSoundEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -715)
    customSoundEdit:SetText("")

    local addCustomSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addCustomSoundButton:SetSize(100, 22)
    addCustomSoundButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -743)
    addCustomSoundButton:SetText("Add File")
    addCustomSoundButton:SetScript("OnClick", function()
        local ok, message = Preydator.API.AddSoundFileName(customSoundEdit:GetText())
        if not ok then
            print("Preydator: " .. tostring(message))
            return
        end

        customSoundEdit:SetText("")
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
        print("Preydator: Added sound file '" .. tostring(message) .. "'.")
    end)

    local removeCustomSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    removeCustomSoundButton:SetSize(110, 22)
    removeCustomSoundButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -743)
    removeCustomSoundButton:SetText("Remove File")
    removeCustomSoundButton:SetScript("OnClick", function()
        local ok, message = Preydator.API.RemoveSoundFileName(customSoundEdit:GetText())
        if not ok then
            print("Preydator: " .. tostring(message))
            return
        end

        customSoundEdit:SetText("")
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
        print("Preydator: Removed sound file '" .. tostring(message) .. "'.")
    end)

    panelRoot:SetScript("OnShow", function()
        NormalizeLabelSettings()
        if panelRoot.PreydatorRefreshControls then
            panelRoot.PreydatorRefreshControls()
        end
    end)

    local textureOptions = {
        default = { text = "Default" },
        flat = { text = "Flat" },
        raid = { text = "Raid HP Fill" },
        classic = { text = "Classic Skill Bar" },
    }

    local fontOptions = {
        frizqt = { text = "Friz Quadrata" },
        arialn = { text = "Arial Narrow" },
        skurri = { text = "Skurri" },
        morpheus = { text = "Morpheus" },
    }

    local channelOptions = {
        Master = { text = "Master" },
        SFX = { text = "SFX" },
        Dialog = { text = "Dialog" },
        Ambience = { text = "Ambience" },
    }

    local percentDisplayOptions = {
        [PERCENT_DISPLAY_INSIDE] = { text = "In Bar" },
        [PERCENT_DISPLAY_UNDER_TICKS] = { text = "Under Ticks" },
        [PERCENT_DISPLAY_BELOW_BAR] = { text = "Below Bar" },
        [PERCENT_DISPLAY_OFF] = { text = "Off" },
    }

    local layerModeOptions = {
        [LAYER_MODE_ABOVE] = { text = "Above Fill" },
        [LAYER_MODE_BELOW] = { text = "Below Fill" },
    }

    local progressSegmentOptions = {
        [PROGRESS_SEGMENTS_QUARTERS] = { text = "Quarters (25/50/75/100)" },
        [PROGRESS_SEGMENTS_THIRDS] = { text = "Thirds (33/66/100)" },
    }

    local textureDropdown = AddDropdown(panel, "Texture", 20, -271, 170, textureOptions, function()
        return settings.textureKey
    end, function(key)
        settings.textureKey = key
        ApplyBarSettings()
    end)
    local fillColorSwatch = AddColorSwatch(panel, 230, -291, function()
        return settings.fillColor
    end, function(color)
        settings.fillColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
    end, true)

    local titleFontDropdown = AddDropdown(panel, "Title Font", 20, -323, 170, fontOptions, function()
        return settings.titleFontKey
    end, function(key)
        settings.titleFontKey = key
        ApplyBarSettings()
    end)
    local titleColorSwatch = AddColorSwatch(panel, 230, -343, function()
        return settings.titleColor
    end, function(color)
        settings.titleColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
        UpdateBarDisplay()
    end, true)

    local percentFontDropdown = AddDropdown(panel, "Percent Font", 20, -375, 170, fontOptions, function()
        return settings.percentFontKey
    end, function(key)
        settings.percentFontKey = key
        ApplyBarSettings()
    end)
    local percentColorSwatch = AddColorSwatch(panel, 230, -395, function()
        return settings.percentColor
    end, function(color)
        settings.percentColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
        UpdateBarDisplay()
    end, true)

    local soundsCheckbox = AddCheckbox(panel, "Enable sounds", 20, -111, function() return settings.soundsEnabled end, function(value)
        settings.soundsEnabled = value
    end)

    local ambushSoundCheckbox = AddCheckbox(panel, "Ambush sound alert", 320, -55, function() return settings.ambushSoundEnabled ~= false end, function(value)
        settings.ambushSoundEnabled = value
    end)

    local ambushVisualCheckbox = AddCheckbox(panel, "Ambush visual alert", 320, -83, function() return settings.ambushVisualEnabled ~= false end, function(value)
        settings.ambushVisualEnabled = value
        if not value then
            state.ambushAlertUntil = 0
            UpdateBarDisplay()
        end
    end)

    local stage1SoundDropdown = AddDropdown(panel, "Stage 1 Sound", 320, -191, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[1]
    end, function(key)
        settings.stageSounds[1] = key
        NormalizeSoundSettings()
    end)

    local stage2SoundDropdown = AddDropdown(panel, "Stage 2 Sound", 320, -243, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[2]
    end, function(key)
        settings.stageSounds[2] = key
        NormalizeSoundSettings()
    end)

    local stage3SoundDropdown = AddDropdown(panel, "Stage 3 Sound", 320, -295, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[3]
    end, function(key)
        settings.stageSounds[3] = key
        NormalizeSoundSettings()
    end)

    local ambushSoundDropdown = AddDropdown(panel, "Ambush Sound", 320, -347, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.ambushSoundPath
    end, function(key)
        settings.ambushSoundPath = key
        NormalizeAmbushSettings()
    end)

    local testAmbushAlertButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testAmbushAlertButton:SetSize(170, 24)
    testAmbushAlertButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -715)
    testAmbushAlertButton:SetText("Test Ambush")
    testAmbushAlertButton:SetScript("OnClick", function()
        TriggerAmbushAlert("Manual test", "options")
    end)

    local soundChannelDropdown = AddDropdown(panel, "Sound Channel", 320, -139, 170, channelOptions, function()
        return settings.soundChannel
    end, function(key)
        settings.soundChannel = key
    end)

    local enhanceSlider = AddSlider(panel, "Enhance Sounds", 20, -575, 0, 100, 5, function()
        return settings.soundEnhance or 0
    end, function(value)
        settings.soundEnhance = Clamp(math.floor(value + 0.5), 0, 100)
    end)

    local showTicksCheckbox = AddCheckbox(panel, "Show tick marks", 320, -111, function() return settings.showTicks end, function(value)
        settings.showTicks = value
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local tickLayerDropdown = AddDropdown(panel, "Tick Mark Layer", 320, -399, 170, layerModeOptions, function()
        return settings.tickLayerMode
    end, function(key)
        settings.tickLayerMode = key
        NormalizeDisplaySettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local percentDisplayDropdown = AddDropdown(panel, "Percent Display", 20, -219, 170, percentDisplayOptions, function()
        return settings.percentDisplay
    end, function(key)
        settings.percentDisplay = key
        NormalizeDisplaySettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local progressSegmentsDropdown = AddDropdown(panel, "Progress Segments", 20, -167, 170, progressSegmentOptions, function()
        return settings.progressSegments
    end, function(key)
        settings.progressSegments = key
        NormalizeProgressSettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local function RefreshOptionsControls()
        if lockCheckbox then lockCheckbox:SetChecked(settings.locked) end
        if onlyShowInPreyZoneCheckbox then onlyShowInPreyZoneCheckbox:SetChecked(settings.onlyShowInPreyZone) end
        if showInEditModeCheckbox then showInEditModeCheckbox:SetChecked(settings.showInEditMode ~= false) end
        if disableDefaultPreyIconCheckbox then disableDefaultPreyIconCheckbox:SetChecked(settings.disableDefaultPreyIcon == true) end
        if soundsCheckbox then soundsCheckbox:SetChecked(settings.soundsEnabled) end
        if ambushSoundCheckbox then ambushSoundCheckbox:SetChecked(settings.ambushSoundEnabled ~= false) end
        if ambushVisualCheckbox then ambushVisualCheckbox:SetChecked(settings.ambushVisualEnabled ~= false) end
        if showTicksCheckbox then showTicksCheckbox:SetChecked(settings.showTicks) end

        if scaleSlider then scaleSlider:SetValue(settings.scale) end
        if widthSlider then widthSlider:SetValue(settings.width) end
        if heightSlider then heightSlider:SetValue(settings.height) end
        if fontSizeSlider then fontSizeSlider:SetValue(settings.fontSize) end
        if enhanceSlider then enhanceSlider:SetValue(settings.soundEnhance or 0) end

        if textureDropdown and textureDropdown.PreydatorRefreshText then textureDropdown.PreydatorRefreshText() end
        if titleFontDropdown and titleFontDropdown.PreydatorRefreshText then titleFontDropdown.PreydatorRefreshText() end
        if percentFontDropdown and percentFontDropdown.PreydatorRefreshText then percentFontDropdown.PreydatorRefreshText() end
        if soundChannelDropdown and soundChannelDropdown.PreydatorRefreshText then soundChannelDropdown.PreydatorRefreshText() end
        if percentDisplayDropdown and percentDisplayDropdown.PreydatorRefreshText then percentDisplayDropdown.PreydatorRefreshText() end
        if tickLayerDropdown and tickLayerDropdown.PreydatorRefreshText then tickLayerDropdown.PreydatorRefreshText() end
        if progressSegmentsDropdown and progressSegmentsDropdown.PreydatorRefreshText then progressSegmentsDropdown.PreydatorRefreshText() end
        if ambushSoundDropdown and ambushSoundDropdown.PreydatorRefreshText then ambushSoundDropdown.PreydatorRefreshText() end
        if stage1SoundDropdown and stage1SoundDropdown.PreydatorRefreshText then stage1SoundDropdown.PreydatorRefreshText() end
        if stage2SoundDropdown and stage2SoundDropdown.PreydatorRefreshText then stage2SoundDropdown.PreydatorRefreshText() end
        if stage3SoundDropdown and stage3SoundDropdown.PreydatorRefreshText then stage3SoundDropdown.PreydatorRefreshText() end

        if fillColorSwatch and fillColorSwatch.PreydatorRefresh then fillColorSwatch.PreydatorRefresh() end
        if titleColorSwatch and titleColorSwatch.PreydatorRefresh then titleColorSwatch.PreydatorRefresh() end
        if percentColorSwatch and percentColorSwatch.PreydatorRefresh then percentColorSwatch.PreydatorRefresh() end

        for stageIndex = 1, (MAX_STAGE - 1) do
            stageNameEdits[stageIndex]:SetText(settings.stageLabels[stageIndex])
        end
        outZoneEdit:SetText(settings.outOfZoneLabel)
        ambushLabelEdit:SetText(settings.ambushSuffix or "preyTargetName")
    end

    panelRoot.PreydatorRefreshControls = RefreshOptionsControls

    local function AddSoundTestButton(text, x, y, stageIndex)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(140, 24)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        button:SetText(text)
        button:SetScript("OnClick", function()
            state.stageSoundPlayed[stageIndex] = nil
            state.stageSoundAttempted[stageIndex] = nil
            local path = Preydator.API.ResolveStageSoundPath(stageIndex)
            if not path then
                print("Preydator: No stage " .. stageIndex .. " sound configured.")
                return
            end

            if not TryPlayStageSound(stageIndex, true) then
                print("Preydator: Stage " .. stageIndex .. " sound file failed to play. Ensure this file exists as .ogg: " .. tostring(path))
            end
        end)
    end

    AddSoundTestButton("Test Stage 1", 320, -631, 1)
    AddSoundTestButton("Test Stage 2", 320, -659, 2)
    AddSoundTestButton("Test Stage 3", 320, -687, 3)

    local note = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -603)
    note:SetWidth(260)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText("Enhance Sounds layers extra plays for perceived loudness. WoW does not expose true per-addon file volume.")

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panelRoot, "Preydator", "Preydator")
        Settings.RegisterAddOnCategory(category)
        if type(category) == "table" then
            UI.optionsCategoryID = category.ID or (category.GetID and category:GetID())
            panelRoot.categoryID = UI.optionsCategoryID
        end
    elseif _G.InterfaceOptions_AddCategory then
        _G.InterfaceOptions_AddCategory(panelRoot)
    end

    UI.optionsPanel = panelRoot
end

Preydator.Constants = {
    MAX_STAGE = MAX_STAGE,
    DEFAULT_OUT_OF_ZONE_LABEL = DEFAULT_OUT_OF_ZONE_LABEL,
    DEFAULT_AMBUSH_LABEL = DEFAULT_AMBUSH_LABEL,
    DEFAULT_STAGE_LABELS = DEFAULT_STAGE_LABELS,
    DEFAULT_SOUND_FILENAMES = DEFAULT_SOUND_FILENAMES,
    PROTECTED_SOUND_FILENAMES = PROTECTED_SOUND_FILENAMES,
    PROGRESS_SEGMENTS_QUARTERS = PROGRESS_SEGMENTS_QUARTERS,
    PROGRESS_SEGMENTS_THIRDS = PROGRESS_SEGMENTS_THIRDS,
    PERCENT_DISPLAY_INSIDE = PERCENT_DISPLAY_INSIDE,
    PERCENT_DISPLAY_INSIDE_BELOW = PERCENT_DISPLAY_INSIDE_BELOW,
    PERCENT_DISPLAY_BELOW_BAR = PERCENT_DISPLAY_BELOW_BAR,
    PERCENT_DISPLAY_ABOVE_BAR = PERCENT_DISPLAY_ABOVE_BAR,
    PERCENT_DISPLAY_ABOVE_TICKS = PERCENT_DISPLAY_ABOVE_TICKS,
    PERCENT_DISPLAY_UNDER_TICKS = PERCENT_DISPLAY_UNDER_TICKS,
    PERCENT_DISPLAY_OFF = PERCENT_DISPLAY_OFF,
    LAYER_MODE_ABOVE = LAYER_MODE_ABOVE,
    LAYER_MODE_BELOW = LAYER_MODE_BELOW,
    LABEL_MODE_CENTER = LABEL_MODE_CENTER,
    LABEL_MODE_LEFT = LABEL_MODE_LEFT,
    LABEL_MODE_LEFT_COMBINED = LABEL_MODE_LEFT_COMBINED,
    LABEL_MODE_RIGHT = LABEL_MODE_RIGHT,
    LABEL_MODE_RIGHT_COMBINED = LABEL_MODE_RIGHT_COMBINED,
    LABEL_MODE_SEPARATE = LABEL_MODE_SEPARATE,
    LABEL_MODE_LEFT_SUFFIX = LABEL_MODE_LEFT_SUFFIX,
    LABEL_MODE_RIGHT_PREFIX = LABEL_MODE_RIGHT_PREFIX,
    LABEL_MODE_NONE = LABEL_MODE_NONE,
    LABEL_ROW_ABOVE = LABEL_ROW_ABOVE,
    LABEL_ROW_BELOW = LABEL_ROW_BELOW,
    ORIENTATION_HORIZONTAL = ORIENTATION_HORIZONTAL,
    ORIENTATION_VERTICAL = ORIENTATION_VERTICAL,
    FILL_DIRECTION_UP = FILL_DIRECTION_UP,
    FILL_DIRECTION_DOWN = FILL_DIRECTION_DOWN,
    TEXTURE_PRESETS = TEXTURE_PRESETS,
    FONT_PRESETS = FONT_PRESETS,
}

Preydator.API = {
    GetSettings = function()
        return settings
    end,
    GetDefaults = function()
        return DEFAULTS
    end,
    GetState = function()
        return state
    end,
    Clamp = Clamp,
    RoundToStep = RoundToStep,
    NormalizeSliderValue = NormalizeSliderValue,
    CreateCheckboxControl = CreateCheckboxControl,
    CreateSliderControl = CreateSliderControl,
    ApplyBarSettings = function()
        ApplyBarSettings()
    end,
    UpdateBarDisplay = function()
        UpdateBarDisplay()
    end,
    RequestBarRefresh = function()
        ApplyBarSettings()
        UpdateBarDisplay()
    end,
    ApplyRuntimeSettings = function(nextSettings, emitProfileHook, refreshUi)
        Preydator:ApplyRuntimeSettings(nextSettings, emitProfileHook == true, refreshUi == true)
    end,
    ResetBarPosition = function()
        barPositionUtil.Reset()
    end,
    NormalizeSoundSettings = function()
        NormalizeSoundSettings()
    end,
    ApplyAratorSilencing = function()
        ApplyAratorSilencing()
    end,
    NormalizeLabelSettings = function()
        NormalizeLabelSettings()
    end,
    NormalizeColorSettings = function()
        NormalizeColorSettings()
    end,
    NormalizeDisplaySettings = function()
        NormalizeDisplaySettings()
    end,
    NormalizeProgressSettings = function()
        NormalizeProgressSettings()
    end,
    NormalizeAmbushSettings = function()
        NormalizeAmbushSettings()
    end,
    ApplyDefaultPreyIconVisibility = function()
        ApplyDefaultPreyIconVisibility()
    end,
    ResetAllSettings = function()
        ResetAllSettings()
    end,
    BuildSoundDropdownOptions = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.BuildSoundDropdownOptions) == "function" then
            return runtime:BuildSoundDropdownOptions(settings, {
                defaultSoundFileNames = DEFAULT_SOUND_FILENAMES,
                additionalSoundEntries = GetExternalSoundCatalog(),
                noneLabel = _G.PreydatorL["None"],
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
            })
        end

        local options = {
            {
                key = "__NONE__",
                text = _G.PreydatorL["None"],
            },
        }
        local files = (settings and settings.soundFileNames) or DEFAULT_SOUND_FILENAMES
        for _, fileName in ipairs(files) do
            local path = SOUND_FOLDER_PREFIX .. tostring(fileName or "")
            options[#options + 1] = {
                key = path,
                text = tostring(fileName or ""),
            }
        end
        for _, entry in ipairs(GetExternalSoundCatalog()) do
            options[#options + 1] = entry
        end
        return options
    end,
    AddSoundFileName = function(fileName)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.AddSoundFileName) == "function" then
            return runtime:AddSoundFileName(fileName, settings, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
                normalizeSoundSettings = NormalizeSoundSettings,
            })
        end

        return false, "Sound runtime is unavailable"
    end,
    RemoveSoundFileName = function(fileName)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.RemoveSoundFileName) == "function" then
            return runtime:RemoveSoundFileName(fileName, settings, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
                protectedSoundFileNames = PROTECTED_SOUND_FILENAMES,
                normalizeSoundSettings = NormalizeSoundSettings,
            })
        end

        return false, "Sound runtime is unavailable"
    end,
    ResolveStageSoundPath = function(stage)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveStageSoundPath) == "function" then
            return runtime:ResolveStageSoundPath(stage, settings, {
                addDebugLog = AddDebugLog,
                getDefaultStageSoundPath = function(stageIndex)
                    return (stageIndex == 1 and ALERT_SOUND_PATH)
                        or (stageIndex == 2 and AMBUSH_SOUND_PATH)
                        or (stageIndex == 3 and TORMENT_SOUND_PATH)
                        or (stageIndex == 4 and KILL_SOUND_PATH)
                end,
            })
        end

        stage = tonumber(stage)
        if not stage then
            AddDebugLog("ResolveStageSoundPath", "invalid stage", false)
            return nil
        end

        local defaultPath = (stage == 1 and ALERT_SOUND_PATH)
            or (stage == 2 and AMBUSH_SOUND_PATH)
            or (stage == 3 and TORMENT_SOUND_PATH)
            or (stage == 4 and KILL_SOUND_PATH)
        if not settings then
            return defaultPath
        end

        settings.stageSounds = settings.stageSounds or {}
        local sounds = settings.stageSounds
        local savedPath = sounds[stage]
        if savedPath == "__NONE__" then
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=saved | path=none", false)
            return nil
        end
        if type(savedPath) == "string" and savedPath ~= "" then
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=saved | path=" .. savedPath, false)
            return savedPath
        end
        if defaultPath and defaultPath ~= "" then
            sounds[stage] = defaultPath
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=default | path=" .. defaultPath, false)
            return defaultPath
        end

        AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=none | default=nil", true)
        return nil
    end,
    ResolveAmbushSoundPath = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveAmbushAlertSoundPath) == "function" then
            return runtime:ResolveAmbushAlertSoundPath(settings, {
                killSoundPath = KILL_SOUND_PATH,
            })
        end

        local path = settings and settings.ambushSoundPath
        if path == "__NONE__" then
            return nil
        end
        if type(path) == "string" and path ~= "" then
            return path
        end

        return KILL_SOUND_PATH
    end,
    ResolveBloodyCommandSoundPath = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveBloodyCommandAlertSoundPath) == "function" then
            return runtime:ResolveBloodyCommandAlertSoundPath(settings, {
                killSoundPath = KILL_SOUND_PATH,
            })
        end

        local path = settings and settings.bloodyCommandSoundPath
        if path == "__NONE__" then
            return nil
        end
        if type(path) == "string" and path ~= "" then
            return path
        end

        return KILL_SOUND_PATH
    end,
    ResolveEchoOfPredationSoundPath = function()
        local path = settings and settings.echoOfPredationSoundPath
        if path == "__NONE__" then
            return nil
        end
        if type(path) == "string" and path ~= "" then
            return path
        end

        return "Interface\\AddOns\\Preydator\\sounds\\echo-of-predation.ogg"
    end,
    PlayTestSound = function(path)
        return TryPlaySound(path, true)
    end,
    TryPlayEchoOfPredationSound = function(npcID, source)
        return TryPlayEchoOfPredationEncounter(npcID, source)
    end,
    ExtractNPCIDFromGUID = function(guidValue)
        return SafeExtractNPCIDFromGUIDValue(guidValue)
    end,
    TryPlayStageSound = function(stageIndex, force)
        return TryPlayStageSound(stageIndex, force)
    end,
    GetModuleRuntimeState = function()
        local runtime = {
            settings = settings,
            barEnabled = true,
            soundsEnabled = true,
            soundsRuntimeEnabled = (settings and settings.soundsEnabled ~= false) and true or false,
        }

        local customization = Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
        if customization and type(customization.IsModuleEnabled) == "function" then
            runtime.barEnabled = customization:IsModuleEnabled("bar") == true
            runtime.soundsEnabled = customization:IsModuleEnabled("sounds") == true
            runtime.soundsRuntimeEnabled = runtime.soundsEnabled and runtime.soundsRuntimeEnabled
        end

        return runtime
    end,
    SetBarRuntimeHandlers = function(handlers)
        if type(handlers) ~= "table" then
            return
        end

        if type(handlers.ApplyBarSettings) == "function" then
            BarRuntimeApplyHandler = handlers.ApplyBarSettings
        end

        if type(handlers.UpdateBarDisplay) == "function" then
            BarRuntimeUpdateHandler = handlers.UpdateBarDisplay
        end
    end,
    GetBarRuntimeContext = function()
        return {
            UI = UI,
            settings = settings,
            state = state,
            defaults = DEFAULTS,
            constants = Preydator.Constants,
            fillInset = FILL_INSET,
            maxTickMarks = MAX_TICK_MARKS,
            clamp = Clamp,
            round = Round,
            getTime = function()
                return (GetTime and GetTime()) or 0
            end,
            getModule = function(moduleName)
                return Preydator:GetModule(moduleName)
            end,
            runModuleHook = RunModuleHook,
            ensureBar = EnsureBar,
            applyDefaultPreyIconVisibility = ApplyDefaultPreyIconVisibility,
            isEditModePreviewActive = function()
                local editModeFrame = _G.EditModeManagerFrame
                return editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown()
            end,
            isRestrictedInstanceForPreyBar = IsRestrictedInstanceForPreyBar,
            getStageFromState = GetStageFromState,
            getStageFallbackPercent = function(stage)
                local mode = (settings and settings.progressSegments) or PROGRESS_SEGMENTS_QUARTERS
                local stagePercents = STAGE_PCT_BY_SEGMENT[mode] or STAGE_PCT_BY_SEGMENT[PROGRESS_SEGMENTS_QUARTERS]
                return stagePercents[stage] or 0
            end,
            getStageLabel = GetStageLabel,
            getProgressTickPercents = function()
                local mode = (settings and settings.progressSegments) or PROGRESS_SEGMENTS_QUARTERS
                local tickPercents = BAR_TICK_PCTS_BY_SEGMENT[mode]
                if type(tickPercents) ~= "table" then
                    return BAR_TICK_PCTS_BY_SEGMENT[PROGRESS_SEGMENTS_QUARTERS]
                end

                return tickPercents
            end,
            getPercentTextLayerSettings = function()
                local mode = settings and settings.percentDisplay or PERCENT_DISPLAY_INSIDE
                if settings and settings.orientation == ORIENTATION_VERTICAL and type(settings.verticalPercentDisplay) == "string" then
                    mode = settings.verticalPercentDisplay
                end

                if mode == PERCENT_DISPLAY_INSIDE_BELOW then
                    mode = PERCENT_DISPLAY_INSIDE
                end

                if mode == PERCENT_DISPLAY_ABOVE_TICKS then
                    return "OVERLAY", 10
                end

                return "OVERLAY", 7
            end,
            getTickLayerSettings = function()
                return "OVERLAY", 4
            end,
            maxStage = MAX_STAGE,
            getCurrentActivePreyQuestCached = GetCurrentActivePreyQuestCached,
            refreshInPreyZoneStatus = RefreshInPreyZoneStatus,
            isAnyTrackedPreyWidgetShown = IsAnyTrackedPreyWidgetShown,
            isValidQuestID = IsValidQuestID,
            barPositionUtil = barPositionUtil,
        }
    end,
    TriggerAmbushAlert = function(message, source, senderName)
        TriggerAmbushAlert(message, source, senderName)
    end,
    TriggerBloodyCommandAlert = function(spellID, sourceName, source)
        TriggerBloodyCommandAlert(spellID, sourceName, source)
    end,
    ClearBloodyCommandAlert = function()
        ClearBloodyCommandAlert()
    end,
    AddDebugLog = function(kind, message, forcePrint)
        AddDebugLog(kind, message, forcePrint)
    end,
}

local function HandleSlashCommand(message)
    local slashModule = GetRuntimeModule("SlashCommands")
    if slashModule and type(slashModule.HandleSlashCommand) == "function" then
        slashModule:HandleSlashCommand(message, {
            ensureDebugDB = EnsureDebugDB,
            settings = settings,
            debugDB = debugDB,
            state = state,
            updateBarDisplay = UpdateBarDisplay,
            openOptionsPanel = OpenOptionsPanel,
            printMemoryUsage = function()
                local runtime = GetRuntimeModule("DebugRuntime")
                if runtime and type(runtime.PrintMemoryUsage) == "function" then
                    runtime:PrintMemoryUsage({
                        collectgarbageFn = _G.collectgarbage,
                        printFn = print,
                    })
                    return
                end

                print("Preydator: Debug runtime is unavailable.")
            end,
            modules = Preydator.modules,
            printFn = print,
        })
        return
    end

    print("Preydator: Slash command module is unavailable.")
end

state.coreAlwaysEvents = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "QUEST_ACCEPTED",
}

state.corePreyRuntimeEvents = {
    "UPDATE_UI_WIDGET",
    "UPDATE_ALL_UI_WIDGETS",
    "QUEST_TURNED_IN",
    "QUEST_REMOVED",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_EMOTE",
    "RAID_BOSS_EMOTE",
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
    "QUEST_DETAIL",
    "NAME_PLATE_UNIT_ADDED",
    "ZONE_CHANGED",
    "ZONE_CHANGED_INDOORS",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_REGEN_ENABLED",
}

function Preydator:SetCorePreyRuntimeEventsRegistered(enabled)
    local shouldRegister = enabled == true
    for _, eventName in ipairs(state.corePreyRuntimeEvents or {}) do
        if shouldRegister then
            frame:RegisterEvent(eventName)
        else
            frame:UnregisterEvent(eventName)
        end
    end
end

function Preydator:ShouldEnableCorePreyRuntimeEvents()
    local trackedQuestID = state and state.activeQuestID or nil
    if IsValidQuestID(trackedQuestID) and IsQuestStillActive(trackedQuestID) then
        return true
    end

    local liveQuestID = GetCurrentActivePreyQuestCached(0)
    if IsValidQuestID(liveQuestID) and IsQuestStillActive(liveQuestID) then
        return true
    end

    return false
end

function Preydator:SyncCorePreyRuntimeEvents()
    local shouldEnable = self:ShouldEnableCorePreyRuntimeEvents()
    if shouldEnable == (state.corePreyEventsRegistered == true) then
        return
    end

    self:SetCorePreyRuntimeEventsRegistered(shouldEnable)
    state.corePreyEventsRegistered = shouldEnable
end

frame:SetScript("OnEvent", function(_, event, arg1, arg2)
    -- Taint safety: nil widget event payload args before any cross-boundary call.
    -- UPDATE_UI_WIDGET args are secret-number widget IDs; passing them as function
    -- arguments propagates taint into the callee even if they are not used there.
    if event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS" then
        arg1, arg2 = nil, nil
    end
    local runtime = GetRuntimeModule("EventRuntime")
    if runtime and type(runtime.HandleEvent) == "function" then
        runtime:HandleEvent(event, arg1, arg2, {
            addonName = ADDON_NAME,
            state = state,
            ui = UI,
            preyProgressFinal = PREY_PROGRESS_FINAL,
            activePreyQuestCacheSeconds = ACTIVE_PREY_QUEST_CACHE_SECONDS,
            onAddonLoaded = OnAddonLoaded,
            onBlizzardWidgetsLoaded = OnBlizzardWidgetsLoaded,
            onPlayerRegenEnabled = OnPlayerRegenEnabled,
            ensureOptionsPanel = EnsureOptionsPanel,
            handleSlashCommand = HandleSlashCommand,
            applyBarSettings = ApplyBarSettings,
            applyAratorSilencing = ApplyAratorSilencing,
            updateBarDisplay = UpdateBarDisplay,
            runModuleHook = RunModuleHook,
            ensureBar = EnsureBar,
            getCustomizationModule = function()
                return Preydator:GetModule("CustomizationStateV2")
            end,
            armQuestListenBurst = ArmQuestListenBurst,
            getCurrentActivePreyQuestCached = GetCurrentActivePreyQuestCached,
            updatePreyState = UpdatePreyState,
            isRelevantWidgetUpdateEvent = IsRelevantWidgetUpdateEvent,
            isValidQuestID = IsValidQuestID,
            isRestrictedInstanceForPreyBar = IsRestrictedInstanceForPreyBar,
            getTime = GetTime,
            setPollingActive = function(enabled)
                Preydator:SetPollingActive(enabled)
            end,
            shouldUseActivePolling = function()
                return Preydator:ShouldUseActivePolling()
            end,
            tryHandleEchoOfPredationNameplate = function(unitToken, source)
                return TryHandleEchoOfPredationNameplate(unitToken, source)
            end,
            clearPreyWidgetInfoCache = function()
                preyWidgetInfoCache = nil
                state.progressState = nil
            end,
        })
        Preydator:SyncCorePreyRuntimeEvents()
        return
    end

    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        OnAddonLoaded()
        EnsureOptionsPanel()
        SlashCmdList["PREYDATOR"] = HandleSlashCommand
    end
    if event == "ADDON_LOADED" and arg1 == "Blizzard_UIWidgets" then
        OnBlizzardWidgetsLoaded()
    end

    Preydator:SyncCorePreyRuntimeEvents()
end)

-- Register addon events once during file load so we do not call RegisterEvent from runtime initialization paths.
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("PLAYER_ALIVE")

Preydator:SetCorePreyRuntimeEventsRegistered(false)

