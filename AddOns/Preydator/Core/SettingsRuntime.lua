local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local SettingsRuntime = {}
Preydator:RegisterModule("SettingsRuntime", SettingsRuntime)

local function Round(value)
    if value >= 0 then
        return math.floor(value + 0.5)
    end
    return math.ceil(value - 0.5)
end

local function Clamp(ctx, value, minValue, maxValue)
    if ctx and type(ctx.clamp) == "function" then
        return ctx.clamp(value, minValue, maxValue)
    end
    return math.max(minValue, math.min(maxValue, value))
end

function SettingsRuntime:NormalizeTransientSettings(settings)
    if type(settings) ~= "table" then
        return
    end

    -- Legacy migration: persisted debug/session flag should never stay true in SavedVariables.
    settings.forceShowBar = false
    settings.debugBloodyCommand = settings.debugBloodyCommand == true
end

function SettingsRuntime:NormalizeProgressSettings(settings, ctx)
    if type(settings) ~= "table" then
        return
    end

    local constants = ctx and ctx.constants or {}
    local quarters = constants.PROGRESS_SEGMENTS_QUARTERS or "quarters"
    local thirds = constants.PROGRESS_SEGMENTS_THIRDS or "thirds"
    local mode = settings.progressSegments
    if mode ~= quarters and mode ~= thirds then
        settings.progressSegments = quarters
        return
    end

    settings.progressSegments = mode
end

function SettingsRuntime:NormalizeLabelSettings(settings, ctx)
    if type(settings) ~= "table" then
        return
    end

    local maxStage = (ctx and ctx.maxStage) or 4
    local defaultStageLabels = (ctx and ctx.defaultStageLabels) or {}
    local defaultOutOfZoneLabel = (ctx and ctx.defaultOutOfZoneLabel) or ""
    local defaultAmbushLabel = (ctx and ctx.defaultAmbushLabel) or ""
    local defaultBloodyCommandLabel = (ctx and ctx.defaultBloodyCommandLabel) or ""

    if type(settings.stageLabels) ~= "table" then
        settings.stageLabels = {}
    end

    for stage = 1, maxStage do
        local label = settings.stageLabels[stage]
        if type(label) ~= "string" then
            local legacy = settings.stageLabels[tostring(stage)]
            if type(legacy) == "string" then
                label = legacy
            end
        end

        if type(label) ~= "string" then
            label = defaultStageLabels[stage] or ""
        end

        settings.stageLabels[stage] = label
    end

    if type(settings.outOfZoneLabel) ~= "string" or settings.outOfZoneLabel == "" then
        settings.outOfZoneLabel = defaultOutOfZoneLabel
    end

    if type(settings.outOfZonePrefix) ~= "string" then
        settings.outOfZonePrefix = ""
    end

    if type(settings.ambushLabel) ~= "string" or settings.ambushLabel == "" then
        settings.ambushLabel = defaultAmbushLabel
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

    -- One-way migration from legacy 2.2.7 text settings:
    -- if both prefix/suffix were effectively empty and no new suffix marker exists,
    -- seed the new default variable markers so alerts render as expected.
    if settings.ambushSuffix == "preyTargetName" and settings.ambushPrefix == "" then
        settings.ambushPrefix = "AMBUSH: "
    end

    if settings.bloodyCommandSuffix == "bloodyCommandSourceName" and settings.bloodyCommandPrefix == "" then
        settings.bloodyCommandPrefix = "Bloody Command: "
    end
end

function SettingsRuntime:NormalizeColorSettings(settings, ctx)
    if type(settings) ~= "table" then
        return
    end

    local defaults = (ctx and ctx.defaults) or {}

    local function normalizeColor(source, fallback)
        local color = type(source) == "table" and source or {}
        local fallbackColor = type(fallback) == "table" and fallback or { 1, 1, 1, 1 }
        local r = Clamp(ctx, tonumber(color[1] or color.r) or fallbackColor[1], 0, 1)
        local g = Clamp(ctx, tonumber(color[2] or color.g) or fallbackColor[2], 0, 1)
        local b = Clamp(ctx, tonumber(color[3] or color.b) or fallbackColor[3], 0, 1)
        local a = Clamp(ctx, tonumber(color[4] or color.a) or fallbackColor[4], 0, 1)
        return { r, g, b, a }
    end

    settings.fillColor = normalizeColor(settings.fillColor, defaults.fillColor)
    settings.bgColor = normalizeColor(settings.bgColor, defaults.bgColor)
    settings.titleColor = normalizeColor(settings.titleColor, defaults.titleColor)
    settings.percentColor = normalizeColor(settings.percentColor, defaults.percentColor)
    settings.tickColor = normalizeColor(settings.tickColor, defaults.tickColor)
    settings.sparkColor = normalizeColor(settings.sparkColor, defaults.sparkColor)
    settings.borderColor = normalizeColor(settings.borderColor, defaults.borderColor)
    if settings.borderColorLinked == nil then
        settings.borderColorLinked = true
    end
end

function SettingsRuntime:NormalizeDisplaySettings(settings, ctx)
    if type(settings) ~= "table" then
        return
    end

    local constants = (ctx and ctx.constants) or {}
    local defaults = (ctx and ctx.defaults) or {}
    local maxStage = (ctx and ctx.maxStage) or 4

    local percentInside = constants.PERCENT_DISPLAY_INSIDE or "inside"
    local percentInsideBelow = constants.PERCENT_DISPLAY_INSIDE_BELOW or "inside_below"
    local percentBelow = constants.PERCENT_DISPLAY_BELOW_BAR or "below_bar"
    local percentAboveBar = constants.PERCENT_DISPLAY_ABOVE_BAR or "above_bar"
    local percentAboveTicks = constants.PERCENT_DISPLAY_ABOVE_TICKS or "above_ticks"
    local percentUnderTicks = constants.PERCENT_DISPLAY_UNDER_TICKS or "under_ticks"
    local percentOff = constants.PERCENT_DISPLAY_OFF or "off"

    local labelCenter = constants.LABEL_MODE_CENTER or "center"
    local labelLeft = constants.LABEL_MODE_LEFT or "left"
    local labelLeftCombined = constants.LABEL_MODE_LEFT_COMBINED or "left_combined"
    local labelLeftSuffix = constants.LABEL_MODE_LEFT_SUFFIX or "left_suffix"
    local labelRight = constants.LABEL_MODE_RIGHT or "right"
    local labelRightCombined = constants.LABEL_MODE_RIGHT_COMBINED or "right_combined"
    local labelRightPrefix = constants.LABEL_MODE_RIGHT_PREFIX or "right_prefix"
    local labelSeparate = constants.LABEL_MODE_SEPARATE or "separate"
    local labelNone = constants.LABEL_MODE_NONE or "none"

    local orientationHorizontal = constants.ORIENTATION_HORIZONTAL or "horizontal"
    local orientationVertical = constants.ORIENTATION_VERTICAL or "vertical"
    local fillDirectionUp = constants.FILL_DIRECTION_UP or "up"
    local fillDirectionDown = constants.FILL_DIRECTION_DOWN or "down"

    settings.showTicks = settings.showTicks ~= false
    settings.showSparkLine = settings.showSparkLine == true
    settings.showInEditMode = settings.showInEditMode ~= false

    local mode = settings.percentDisplay
    if mode == "below" then
        mode = percentBelow
    end

    if mode ~= percentInside
        and mode ~= percentBelow
        and mode ~= percentAboveBar
        and mode ~= percentAboveTicks
        and mode ~= percentUnderTicks
        and mode ~= percentOff
    then
        settings.percentDisplay = percentInside
    else
        settings.percentDisplay = mode
    end

    settings.tickLayerMode = constants.LAYER_MODE_ABOVE or "above"
    settings.percentFallbackMode = "stage"

    local labelMode = settings.stageLabelMode
    if labelMode ~= labelCenter
        and labelMode ~= labelLeft
        and labelMode ~= labelLeftCombined
        and labelMode ~= labelLeftSuffix
        and labelMode ~= labelRight
        and labelMode ~= labelRightCombined
        and labelMode ~= labelRightPrefix
        and labelMode ~= labelSeparate
        and labelMode ~= labelNone
    then
        settings.stageLabelMode = labelCenter
    end

    if settings.labelRowPosition ~= "above" and settings.labelRowPosition ~= "below" then
        settings.labelRowPosition = "above"
    end

    if settings.orientation ~= orientationHorizontal and settings.orientation ~= orientationVertical then
        settings.orientation = orientationHorizontal
    end

    if settings.verticalFillDirection ~= fillDirectionUp and settings.verticalFillDirection ~= fillDirectionDown then
        settings.verticalFillDirection = fillDirectionUp
    end

    if settings.verticalTextSide ~= "left" and settings.verticalTextSide ~= "right" then
        settings.verticalTextSide = "right"
    end

    if settings.verticalPercentSide == "off" or settings.verticalPercentSide == "inside" then
        settings.verticalPercentSide = "center"
    end
    if settings.verticalPercentSide ~= "left"
        and settings.verticalPercentSide ~= "center"
        and settings.verticalPercentSide ~= "right"
    then
        settings.verticalPercentSide = "center"
    end

    local verticalPercentDisplay = settings.verticalPercentDisplay
    if verticalPercentDisplay == percentInsideBelow then
        verticalPercentDisplay = percentInside
    end
    if verticalPercentDisplay ~= percentInside
        and verticalPercentDisplay ~= percentBelow
        and verticalPercentDisplay ~= percentAboveBar
        and verticalPercentDisplay ~= percentOff
    then
        settings.verticalPercentDisplay = percentInside
    else
        settings.verticalPercentDisplay = verticalPercentDisplay
    end

    if settings.percentDisplay == percentInsideBelow then
        settings.percentDisplay = percentInside
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
        horizontalWidth = legacyWidth or defaults.horizontalWidth or 160
    end
    horizontalWidth = tonumber(horizontalWidth) or 160
    settings.horizontalWidth = Clamp(ctx, math.floor(horizontalWidth + 0.5), 100, 350)

    local horizontalHeight = tonumber(settings.horizontalHeight)
    if not horizontalHeight then
        horizontalHeight = legacyHeight or defaults.horizontalHeight or 30
    end
    horizontalHeight = tonumber(horizontalHeight) or 30
    settings.horizontalHeight = Clamp(ctx, math.floor(horizontalHeight + 0.5), 10, 60)

    local verticalWidth = tonumber(settings.verticalWidth)
    if not verticalWidth then
        if settings.orientation == orientationVertical and legacyWidth then
            verticalWidth = legacyWidth
        else
            verticalWidth = defaults.verticalWidth or 40
        end
    end
    verticalWidth = tonumber(verticalWidth) or 40
    settings.verticalWidth = Clamp(ctx, math.floor(verticalWidth + 0.5), 10, 60)

    local verticalHeight = tonumber(settings.verticalHeight)
    if not verticalHeight then
        if settings.orientation == orientationVertical and legacyHeight then
            verticalHeight = legacyHeight
        else
            verticalHeight = defaults.verticalHeight or 160
        end
    end
    verticalHeight = tonumber(verticalHeight) or 160
    settings.verticalHeight = Clamp(ctx, math.floor(verticalHeight + 0.5), 100, 350)

    local legacySideOffset = tonumber(settings.verticalSideOffset)
    if not legacySideOffset then
        legacySideOffset = 10
    end

    local verticalTextOffset = tonumber(settings.verticalTextOffset)
    if not verticalTextOffset then
        verticalTextOffset = legacySideOffset
    end
    settings.verticalTextOffset = Clamp(ctx, math.floor(verticalTextOffset + 0.5), 2, 60)

    local verticalPercentOffset = tonumber(settings.verticalPercentOffset)
    if not verticalPercentOffset then
        verticalPercentOffset = legacySideOffset
    end
    settings.verticalPercentOffset = Clamp(ctx, math.floor(verticalPercentOffset + 0.5), 2, 60)

    settings.verticalSideOffset = settings.verticalTextOffset

    if settings.orientation == orientationVertical then
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
    for i = 1, maxStage do
        if type(settings.stageSuffixLabels[i]) ~= "string" then
            settings.stageSuffixLabels[i] = ""
        end
    end
end

function SettingsRuntime:NormalizeAmbushSettings(settings, ctx)
    if type(settings) ~= "table" then
        return
    end

    settings.ambushSoundEnabled = settings.ambushSoundEnabled ~= false
    settings.ambushVisualEnabled = settings.ambushVisualEnabled ~= false
    settings.bloodyCommandSoundEnabled = settings.bloodyCommandSoundEnabled ~= false
    settings.bloodyCommandVisualEnabled = settings.bloodyCommandVisualEnabled ~= false

    local legacyFallbackPath = (ctx and ctx.killSoundPath) or ""
    local ambushDefaultSoundPath = (ctx and ctx.ambushDefaultSoundPath) or legacyFallbackPath
    local bloodyDefaultSoundPath = (ctx and ctx.bloodyDefaultSoundPath) or legacyFallbackPath
    local echoSoundPath = (ctx and ctx.echoSoundPath) or bloodyDefaultSoundPath
    if type(settings.ambushSoundPath) ~= "string" or settings.ambushSoundPath == "" then
        local legacySoundKey = settings.ambushSoundKey
        if ctx and type(ctx.getSoundPathForKey) == "function" then
            settings.ambushSoundPath = ctx.getSoundPathForKey(legacySoundKey, ambushDefaultSoundPath)
        else
            settings.ambushSoundPath = ambushDefaultSoundPath
        end
    end

    if type(settings.bloodyCommandSoundPath) ~= "string" or settings.bloodyCommandSoundPath == "" then
        settings.bloodyCommandSoundPath = bloodyDefaultSoundPath
    end

    if type(settings.echoOfPredationSoundPath) ~= "string" or settings.echoOfPredationSoundPath == "" then
        settings.echoOfPredationSoundPath = echoSoundPath
    end

    settings.ambushSoundKey = nil
    settings.ambushCustomSoundPath = nil
end

function SettingsRuntime:SyncBarPointToBackup(settings)
    if not settings or type(settings.point) ~= "table" then
        return
    end

    local x = tonumber(settings.point.x)
    local y = tonumber(settings.point.y)
    if x == nil or y == nil then
        return
    end

    settings.barPointX = Round(x)
    settings.barPointY = Round(y)
end

function SettingsRuntime:RestoreBarPointFromBackup(settings)
    if not settings then
        return
    end

    settings.point = settings.point or {}
    local pointX = tonumber(settings.point.x)
    local pointY = tonumber(settings.point.y)

    -- Do not overwrite valid point coordinates with backup values.
    -- Backup restore is only for recovering missing/invalid point data.
    if pointX ~= nil and pointY ~= nil then
        return
    end

    local x = tonumber(settings.barPointX)
    local y = tonumber(settings.barPointY)
    if x == nil or y == nil then
        return
    end

    settings.point.anchor = "CENTER"
    settings.point.relativePoint = "CENTER"
    settings.point.x = Round(x)
    settings.point.y = Round(y)
end
