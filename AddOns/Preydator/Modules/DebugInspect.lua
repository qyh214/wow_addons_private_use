---@diagnostic disable

local Preydator = _G.Preydator
if type(Preydator) ~= "table" or type(Preydator.RegisterModule) ~= "function" then
    return
end

local C_QuestLog = _G.C_QuestLog
local C_Map = _G.C_Map
local C_TaskQuest = _G.C_TaskQuest
local C_AddOns = _G.C_AddOns
local IsInInstance = _G.IsInInstance
local geterrorhandler = _G.geterrorhandler
local GetTime = _G.GetTime
local GetZoneText = _G.GetZoneText
local GetQuestLink = _G.GetQuestLink

local function IsRestrictedInstance()
    if type(IsInInstance) == "function" then
        local ok, inInstance, instanceType = pcall(IsInInstance)
        if ok and inInstance == true then
            return instanceType == "pvp"
                or instanceType == "arena"
                or instanceType == "party"
                or instanceType == "raid"
                or instanceType == "scenario"
                or instanceType == "delve"
        end
    end

    if type(_G.IsInScenario) == "function" then
        local okScenario, inScenario = pcall(_G.IsInScenario)
        if okScenario and inScenario == true then
            return true
        end
    end

    if _G.C_ScenarioInfo and type(_G.C_ScenarioInfo.GetScenarioInfo) == "function" then
        local okInfo, scenarioInfo = pcall(_G.C_ScenarioInfo.GetScenarioInfo)
        if okInfo and type(scenarioInfo) == "table" then
            local hasScenarioName = type(scenarioInfo.name) == "string" and scenarioInfo.name ~= ""
            local stage = SafeToNumber(scenarioInfo.currentStage)
            local stages = SafeToNumber(scenarioInfo.numStages)
            if hasScenarioName and (stage ~= nil or stages ~= nil) then
                return true
            end
        end
    end

    return false
end

local function GetAddonVersionSafe()
    if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
        local ok, version = pcall(C_AddOns.GetAddOnMetadata, "Preydator", "Version")
        if ok and type(version) == "string" and version ~= "" then
            return version
        end
    end
    return "?"
end

local function SafeToNumber(value)
    local ok, converted = pcall(tonumber, value)
    if ok then
        return converted
    end
    return nil
end

local function SafeValue(value)
    if value == nil then
        return "nil"
    end
    local ok, converted = pcall(tostring, value)
    if ok then
        return converted
    end
    return "<tostring failed>"
end

local function FormatTablePairs(tbl)
    if type(tbl) ~= "table" then
        return SafeValue(tbl)
    end

    local parts = {}
    for key, value in pairs(tbl) do
        parts[#parts + 1] = tostring(key) .. "=" .. SafeValue(value)
    end
    table.sort(parts)
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function SendToErrorHandler(reportText, headerText)
    if type(reportText) ~= "string" or reportText == "" then
        return false, "empty report"
    end

    if type(geterrorhandler) ~= "function" then
        return false, "geterrorhandler unavailable"
    end

    local okHandler, handler = pcall(geterrorhandler)
    if not okHandler or type(handler) ~= "function" then
        return false, "error handler unavailable"
    end

    local header = type(headerText) == "string" and headerText ~= "" and headerText or "Preydator Inspect Report"
    local chunkSize = 1800
    local length = #reportText
    local chunks = math.max(1, math.ceil(length / chunkSize))
    for index = 1, chunks do
        local startPos = ((index - 1) * chunkSize) + 1
        local endPos = math.min(index * chunkSize, length)
        local chunk = string.sub(reportText, startPos, endPos)
        local payload = nil
        local okPayload, builtPayload = pcall(string.format, "%s [%d/%d]\n%s", header, index, chunks, chunk)
        if okPayload and type(builtPayload) == "string" and builtPayload ~= "" then
            payload = builtPayload
        else
            payload = header .. " [" .. tostring(index) .. "/" .. tostring(chunks) .. "]\n" .. chunk
        end

        local okSend = pcall(function()
            handler(payload)
        end)

        if not okSend then
            return false, "handler failed on chunk " .. tostring(index)
        end
    end

    return true, "sent"
end

local function BuildQuestInspectReport(requestedQuestID)
    local lines = {}
    local function add(line)
        lines[#lines + 1] = tostring(line or "")
    end

    local state = (type(Preydator.GetState) == "function") and Preydator.GetState() or {}
    local liveQuestID = nil
    if C_QuestLog and type(C_QuestLog.GetActivePreyQuest) == "function" then
        local okLiveQuestID, rawLiveQuestID = pcall(C_QuestLog.GetActivePreyQuest)
        liveQuestID = okLiveQuestID and SafeToNumber(rawLiveQuestID) or nil
    end
    local questID = SafeToNumber(requestedQuestID) or liveQuestID or SafeToNumber(state.activeQuestID)

    local now = GetTime and GetTime() or 0
    local playerMapID = nil
    if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
        local okPlayerMapID, rawPlayerMapID = pcall(C_Map.GetBestMapForUnit, "player")
        playerMapID = okPlayerMapID and SafeToNumber(rawPlayerMapID) or nil
    end
    local playerMapName = nil
    local playerMapType = nil
    if playerMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, playerMapID)
        mapInfo = okMapInfo and mapInfo or nil
        playerMapName = mapInfo and mapInfo.name or nil
        playerMapType = mapInfo and mapInfo.mapType or nil
    end

    local inInstance = nil
    local instanceType = nil
    if IsInInstance then
        local okInstance, rawInInstance, rawInstanceType = pcall(IsInInstance)
        if okInstance then
            inInstance = rawInInstance == true
            instanceType = rawInstanceType
        end
    end

    add("Preydator Quest Inspect (module) | addon=" .. GetAddonVersionSafe())
    add("- time=" .. string.format("%.3f", now) .. " | zone=" .. tostring(GetZoneText and GetZoneText() or "?") .. " | playerMapID=" .. SafeValue(playerMapID) .. " | playerMap=" .. SafeValue(playerMapName))
    add("- requestedQuestID=" .. SafeValue(requestedQuestID) .. " | livePreyQuestID=" .. SafeValue(liveQuestID) .. " | trackedQuestID=" .. SafeValue(state.activeQuestID) .. " | inspectQuestID=" .. SafeValue(questID))

    if not questID or questID <= 0 then
        add("- No valid quest ID available to inspect.")
        local reportText = table.concat(lines, "\n")
        _G.PreydatorLastQuestInspectReport = reportText
        return lines, reportText
    end

    local logIndex = nil
    if C_QuestLog and type(C_QuestLog.GetLogIndexForQuestID) == "function" then
        logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    end

    local titleForQuestID = nil
    if C_QuestLog and type(C_QuestLog.GetTitleForQuestID) == "function" then
        local titleInfo = C_QuestLog.GetTitleForQuestID(questID)
        if type(titleInfo) == "table" then
            titleForQuestID = titleInfo.title
        else
            titleForQuestID = titleInfo
        end
    end

    local questLink = nil
    if type(GetQuestLink) == "function" then
        questLink = GetQuestLink(questID)
    end

    local questZoneMapID = nil
    if C_TaskQuest and type(C_TaskQuest.GetQuestZoneID) == "function" then
        local okQuestZoneMapID, rawQuestZoneMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
        questZoneMapID = okQuestZoneMapID and SafeToNumber(rawQuestZoneMapID) or nil
    end

    local questZoneName = nil
    if questZoneMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local okZoneInfo, zoneInfo = pcall(C_Map.GetMapInfo, questZoneMapID)
        zoneInfo = okZoneInfo and zoneInfo or nil
        questZoneName = zoneInfo and zoneInfo.name or nil
    end

    add("- basic | logIndex=" .. SafeValue(logIndex) .. " | title=" .. SafeValue(titleForQuestID) .. " | link=" .. SafeValue(questLink))
    add("- zoneHint | taskQuestMapID=" .. SafeValue(questZoneMapID) .. " | taskQuestZone=" .. SafeValue(questZoneName) .. " | state.preyZoneMapID=" .. SafeValue(state.preyZoneMapID) .. " | state.preyZoneName=" .. SafeValue(state.preyZoneName) .. " | state.inPreyZone=" .. SafeValue(state.inPreyZone))

    if C_QuestLog then
        if type(C_QuestLog.IsOnQuest) == "function" then
            local okIsOnQuest, isOnQuest = pcall(C_QuestLog.IsOnQuest, questID)
            add("- flags | isOnQuest=" .. SafeValue(okIsOnQuest and isOnQuest or nil))
        end
        if type(C_QuestLog.IsQuestFlaggedCompleted) == "function" then
            local okIsCompleted, isCompleted = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
            add("- flags | isFlaggedCompleted=" .. SafeValue(okIsCompleted and isCompleted or nil))
        end
    end

    if logIndex and C_QuestLog and type(C_QuestLog.GetInfo) == "function" then
        local okInfo, info = pcall(C_QuestLog.GetInfo, logIndex)
        info = okInfo and info or nil
        add("- GetInfo(" .. tostring(logIndex) .. ")=" .. FormatTablePairs(info))
    else
        add("- GetInfo unavailable: no logIndex")
    end

    if C_QuestLog and type(C_QuestLog.GetQuestTagInfo) == "function" then
        local okTagInfo, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        tagInfo = okTagInfo and tagInfo or nil
        add("- GetQuestTagInfo=" .. FormatTablePairs(tagInfo))
    end

    if C_QuestLog and type(C_QuestLog.GetQuestObjectives) == "function" then
        local okObjectives, objectives = pcall(C_QuestLog.GetQuestObjectives, questID)
        objectives = okObjectives and objectives or nil
        if type(objectives) == "table" and #objectives > 0 then
            local function IsObjectiveDone(objective)
                if type(objective) ~= "table" then
                    return false
                end
                if objective.finished == true then
                    return true
                end
                local fulfilled = SafeToNumber(objective.numFulfilled)
                local required = SafeToNumber(objective.numRequired)
                if fulfilled ~= nil and required ~= nil and required > 0 then
                    return fulfilled >= required
                end

                local text = objective.text
                if type(text) == "string" and text ~= "" then
                    local curText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                    local curValue = SafeToNumber(curText)
                    local maxValue = SafeToNumber(maxText)
                    if curValue ~= nil and maxValue ~= nil and maxValue > 0 then
                        return curValue >= maxValue
                    end
                end

                return false
            end

            local inferredProgressState = nil
            local first = objectives[1]
            local second = objectives[2]
            local firstDone = IsObjectiveDone(first)
            local secondDone = IsObjectiveDone(second)
            local secondPresent = type(second) == "table"
                and ((type(second.text) == "string" and second.text ~= "")
                    or (SafeToNumber(second.numRequired) ~= nil))

            if secondDone or (firstDone and secondPresent) then
                inferredProgressState = 3
            elseif firstDone then
                inferredProgressState = 2
            elseif state.inPreyZone == true then
                inferredProgressState = 1
            else
                inferredProgressState = 0
            end

            local inferredStage = inferredProgressState + 1
            add("- objectiveInference | progressState=" .. SafeValue(inferredProgressState)
                .. " | stage=" .. SafeValue(inferredStage)
                .. " | firstDone=" .. SafeValue(firstDone)
                .. " | secondPresent=" .. SafeValue(secondPresent)
                .. " | secondDone=" .. SafeValue(secondDone)
                .. " | inPreyZone=" .. SafeValue(state.inPreyZone))

            add("- objectives count=" .. tostring(#objectives))
            for idx, obj in ipairs(objectives) do
                add("  - [" .. tostring(idx) .. "] " .. FormatTablePairs(obj))
            end
        else
            add("- objectives count=0")
        end
    end

    local reportText = table.concat(lines, "\n")
    _G.PreydatorLastQuestInspectReport = reportText
    return lines, reportText
end

local function BuildInspectReport()
    local lines = {}
    local function add(line)
        lines[#lines + 1] = tostring(line or "")
    end

    local state = (type(Preydator.GetState) == "function") and Preydator.GetState() or {}
    local settings = (type(Preydator.GetSettings) == "function") and Preydator.GetSettings() or {}
    local barFrame = (type(Preydator.GetBarFrame) == "function") and Preydator.GetBarFrame() or nil
    local labelFrames = (type(Preydator.GetLabelFrames) == "function") and Preydator.GetLabelFrames() or nil

    local function FormatPoint(frameRef)
        if not frameRef or not frameRef.GetPoint then
            return "<no-frame>"
        end

        local ok, point, relativeTo, relativePoint, xOfs, yOfs = pcall(frameRef.GetPoint, frameRef, 1)
        if not ok then
            return "<point-error>"
        end

        local relName = "<nil>"
        if relativeTo and relativeTo.GetName then
            relName = relativeTo:GetName() or "<unnamed>"
        end

        return string.format("%s -> %s:%s (%s,%s)", tostring(point), tostring(relName), tostring(relativePoint), tostring(xOfs), tostring(yOfs))
    end

    local liveQuestID = nil
    if C_QuestLog and type(C_QuestLog.GetActivePreyQuest) == "function" then
        local okLiveQuestID, rawLiveQuestID = pcall(C_QuestLog.GetActivePreyQuest)
        liveQuestID = okLiveQuestID and SafeToNumber(rawLiveQuestID) or nil
    end
    local hasActiveQuest = type(liveQuestID) == "number" and liveQuestID > 0
    local now = GetTime and GetTime() or 0

    local playerMapID = nil
    if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
        local okPlayerMapID, rawPlayerMapID = pcall(C_Map.GetBestMapForUnit, "player")
        playerMapID = okPlayerMapID and SafeToNumber(rawPlayerMapID) or nil
    end
    local playerMapName = nil
    local playerMapType = nil
    if playerMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, playerMapID)
        mapInfo = okMapInfo and mapInfo or nil
        playerMapName = mapInfo and mapInfo.name or nil
        playerMapType = mapInfo and mapInfo.mapType or nil
    end

    local inInstance = nil
    local instanceType = nil
    if IsInInstance then
        local okInstance, rawInInstance, rawInstanceType = pcall(IsInInstance)
        if okInstance then
            inInstance = rawInInstance == true
            instanceType = rawInstanceType
        end
    end

    add("Preydator Inspect (module) | addon=" .. GetAddonVersionSafe())
    add("- time=" .. string.format("%.3f", now) .. " | zone=" .. tostring(GetZoneText and GetZoneText() or "?") .. " | playerMapID=" .. tostring(playerMapID) .. " | playerMap=" .. tostring(playerMapName))
    add("- instance inInstance=" .. tostring(inInstance) .. " | instanceType=" .. tostring(instanceType) .. " | playerMapType=" .. tostring(playerMapType))
    add("- quest live=" .. tostring(liveQuestID) .. " | hasActive=" .. tostring(hasActiveQuest) .. " | tracked=" .. tostring(state.activeQuestID))
    add("- state stage=" .. tostring(state.stage) .. " | progressState=" .. tostring(state.progressState) .. " | progressPercent=" .. tostring(state.progressPercent))
    add("- preyZone mapID=" .. tostring(state.preyZoneMapID) .. " | preyZoneName=" .. tostring(state.preyZoneName) .. " | zoneCacheDirty=" .. tostring(state.zoneCacheDirty))
    add("- inPreyZone=" .. tostring(state.inPreyZone)
        .. " | onlyShowInPreyZone=" .. tostring(settings and settings.onlyShowInPreyZone == true)
        .. " | disableDefaultPreyIcon=" .. tostring(settings and settings.disableDefaultPreyIcon == true))

    local huntScanner = Preydator and Preydator.GetModule and Preydator:GetModule("HuntScanner")
    if huntScanner and type(huntScanner.GetAchievementRouteStats) == "function" then
        local okRouteStats, routeStats = pcall(huntScanner.GetAchievementRouteStats, huntScanner)
        if okRouteStats and type(routeStats) == "table" then
            add(string.format(
                "- achievementRoute id=%d fallback=%d miss=%d total=%d idPct=%.1f fallbackPct=%.1f",
                SafeToNumber(routeStats.idHits) or 0,
                SafeToNumber(routeStats.fallbackHits) or 0,
                SafeToNumber(routeStats.misses) or 0,
                SafeToNumber(routeStats.total) or 0,
                SafeToNumber(routeStats.idPct) or 0,
                SafeToNumber(routeStats.fallbackPct) or 0
            ))
        end
    end

    local suppressionDebug = nil
    if type(Preydator.GetWidgetSuppressionDebug) == "function" then
        local okSuppression, data = pcall(Preydator.GetWidgetSuppressionDebug)
        if okSuppression and type(data) == "table" then
            suppressionDebug = data
        end
    end

    local preyWidgetVisible = suppressionDebug and suppressionDebug.preyIconShown == true
    local hasResolvedPreyZoneEvidence = state and (state.preyZoneMapID ~= nil or state.confirmedPreyZoneMapID ~= nil)
    local hasCertifiedWidgetZoneSignal = state and state.inPreyZone == nil
        and preyWidgetVisible
        and hasResolvedPreyZoneEvidence
    local onlyShowInPreyZone = settings and settings.onlyShowInPreyZone == true
    local forceShowBar = state and state.forceShowBar == true
    local forceKillStage = now < ((state and state.killStageUntil) or 0)
    local forceAmbushAlert = now < ((state and state.ambushAlertUntil) or 0)
    local forceBloodyCommandAlert = now < ((state and state.bloodyCommandAlertUntil) or 0)
    local isOutOfPreyZone = hasActiveQuest and state and state.inPreyZone == false
    local inStageFourInZone = state and state.stage == 4
        and (state.inPreyZone == true or hasCertifiedWidgetZoneSignal)
    local editModePreview = settings and settings.showInEditMode == true and _G.EditModeManagerFrame and _G.EditModeManagerFrame.IsShown and _G.EditModeManagerFrame:IsShown()
    local isRestrictedInstance = inInstance == true and (
        instanceType == "pvp"
        or instanceType == "arena"
        or instanceType == "party"
        or instanceType == "raid"
        or instanceType == "scenario"
        or instanceType == "delve"
    )

    local shouldShowBar = false
    local visibilityReason = "default"
    if isRestrictedInstance and not editModePreview then
        shouldShowBar = false
        visibilityReason = "restricted-instance"
    elseif forceShowBar then
        shouldShowBar = true
        visibilityReason = "forceShowBar"
    elseif forceKillStage then
        shouldShowBar = true
        visibilityReason = "killStage"
    elseif forceAmbushAlert then
        shouldShowBar = true
        visibilityReason = "ambushAlert"
    elseif forceBloodyCommandAlert then
        shouldShowBar = true
        visibilityReason = "bloodyCommandAlert"
    elseif editModePreview then
        shouldShowBar = true
        visibilityReason = "editModePreview"
    elseif onlyShowInPreyZone then
        local inZoneSignal = (state and state.inPreyZone == true)
            or hasCertifiedWidgetZoneSignal
        shouldShowBar = (hasActiveQuest and inZoneSignal) or inStageFourInZone
        visibilityReason = shouldShowBar and "onlyShowInPreyZone-pass" or "onlyShowInPreyZone-block"
    else
        shouldShowBar = true
        visibilityReason = "always-show"
    end

    add("- visibility shouldShowBar=" .. tostring(shouldShowBar)
        .. " | reason=" .. tostring(visibilityReason)
        .. " | forceShowBar=" .. tostring(forceShowBar)
        .. " | forceKillStage=" .. tostring(forceKillStage)
        .. " | forceAmbushAlert=" .. tostring(forceAmbushAlert)
        .. " | forceBloodyCommandAlert=" .. tostring(forceBloodyCommandAlert)
        .. " | outOfPreyZone=" .. tostring(isOutOfPreyZone)
        .. " | stage4InZone=" .. tostring(inStageFourInZone)
        .. " | preyWidgetVisible=" .. tostring(preyWidgetVisible)
        .. " | restricted=" .. tostring(isRestrictedInstance)
        .. " | editModePreview=" .. tostring(editModePreview))

    if suppressionDebug then
        add("- suppression trackedFrames=" .. SafeValue(suppressionDebug.trackedFrames)
            .. " | shownFrames=" .. SafeValue(suppressionDebug.shownFrames)
            .. " | hiddenFrames=" .. SafeValue(suppressionDebug.hiddenFrames)
            .. " | effectControllers=" .. SafeValue(suppressionDebug.effectControllers))
        add("- suppression preyIconTracked=" .. SafeValue(suppressionDebug.preyIconTracked)
            .. " | preyIconShown=" .. SafeValue(suppressionDebug.preyIconShown)
            .. " | retryPending=" .. SafeValue(suppressionDebug.suppressionRetryPending)
            .. " | retryCount=" .. SafeValue(suppressionDebug.suppressionRetryCount)
            .. " | pendingAfterCombat=" .. SafeValue(suppressionDebug.pendingAfterCombat))
    else
        add("- suppression debug unavailable")
    end

    add("- settings size width=" .. tostring(settings and settings.width)
        .. " | height=" .. tostring(settings and settings.height)
        .. " | scale=" .. tostring(settings and settings.scale))
    add("- settings layout"
        .. " | orientation=" .. tostring(settings and settings.orientation)
        .. " | fillDir=" .. tostring(settings and settings.verticalFillDirection)
        .. " | labelMode=" .. tostring(settings and settings.stageLabelMode)
        .. " | labelRow=" .. tostring(settings and settings.labelRowPosition)
        .. " | vTextAlign=" .. tostring(settings and settings.verticalTextAlign)
        .. " | vTextSide=" .. tostring(settings and settings.verticalTextSide)
        .. " | vTextOffset=" .. tostring(settings and settings.verticalTextOffset)
        .. " | vPctDisplay=" .. tostring(settings and settings.verticalPercentDisplay)
        .. " | vPctSide=" .. tostring(settings and settings.verticalPercentSide)
        .. " | vPctOffset=" .. tostring(settings and settings.verticalPercentOffset))

    if barFrame then
        local liveWidth = barFrame.GetWidth and barFrame:GetWidth() or "?"
        local liveHeight = barFrame.GetHeight and barFrame:GetHeight() or "?"
        local liveScale = barFrame.GetScale and barFrame:GetScale() or "?"
        local liveEffectiveScale = barFrame.GetEffectiveScale and barFrame:GetEffectiveScale() or "?"
        local savedPoint = settings and settings.point or {}
        local savedX = savedPoint and savedPoint.x
        local savedY = savedPoint and savedPoint.y
        local liveX = nil
        local liveY = nil
        if barFrame.GetCenter and UIParent and UIParent.GetCenter then
            local okCenter, frameCenterX, frameCenterY = pcall(barFrame.GetCenter, barFrame)
            local okParentCenter, parentCenterX, parentCenterY = pcall(UIParent.GetCenter, UIParent)
            if okCenter and okParentCenter and frameCenterX and frameCenterY and parentCenterX and parentCenterY then
                liveX = frameCenterX - parentCenterX
                liveY = frameCenterY - parentCenterY
            end
        end
        add("- bar shown=" .. tostring(barFrame.IsShown and barFrame:IsShown() or false)
            .. " | mouse=" .. tostring(barFrame.IsMouseEnabled and barFrame:IsMouseEnabled() or false)
            .. " | width=" .. tostring(liveWidth)
            .. " | height=" .. tostring(liveHeight)
            .. " | scale=" .. tostring(liveScale)
            .. " | effectiveScale=" .. tostring(liveEffectiveScale))
        add("- bar position savedX=" .. tostring(savedX)
            .. " | savedY=" .. tostring(savedY)
            .. " | liveX=" .. tostring(liveX and math.floor((liveX * 100) + 0.5) / 100 or nil)
            .. " | liveY=" .. tostring(liveY and math.floor((liveY * 100) + 0.5) / 100 or nil)
            .. " | point=" .. FormatPoint(barFrame))
    else
        add("- bar frame unavailable")
    end

    if type(labelFrames) == "table" then
        local prefix = labelFrames.prefix
        local suffix = labelFrames.suffix
        local percent = labelFrames.percent

        add("- prefix"
            .. " | shown=" .. tostring(prefix and prefix.IsShown and prefix:IsShown() or false)
            .. " | text='" .. tostring(prefix and prefix.GetText and prefix:GetText() or "") .. "'"
            .. " | point=" .. FormatPoint(prefix))
        add("- suffix"
            .. " | shown=" .. tostring(suffix and suffix.IsShown and suffix:IsShown() or false)
            .. " | text='" .. tostring(suffix and suffix.GetText and suffix:GetText() or "") .. "'"
            .. " | point=" .. FormatPoint(suffix))
        add("- percent"
            .. " | shown=" .. tostring(percent and percent.IsShown and percent:IsShown() or false)
            .. " | text='" .. tostring(percent and percent.GetText and percent:GetText() or "") .. "'"
            .. " | point=" .. FormatPoint(percent))
    end

    local reportText = table.concat(lines, "\n")
    _G.PreydatorLastInspectReport = reportText
    return lines, reportText
end

local DebugInspectModule = {}

function DebugInspectModule:OnSlashCommand(text, rest)
    if text ~= "inspect" and text ~= "qinspect" then
        return false
    end

    if IsRestrictedInstance() then
        print("Preydator: inspect is unavailable in restricted instances.")
        return true
    end

    local isQuestInspect = (text == "qinspect")
    local tokens = {}
    for token in tostring(rest or ""):gmatch("%S+") do
        tokens[#tokens + 1] = string.lower(token)
    end

    local mode = "chat"
    local requestedQuestID = nil

    for _, token in ipairs(tokens) do
        if token == "bs" then
            mode = "bugsack"
        elseif isQuestInspect and requestedQuestID == nil then
            local parsedQuestID = tonumber(token)
            if parsedQuestID and parsedQuestID > 0 then
                requestedQuestID = parsedQuestID
            else
                return false
            end
        else
            return false
        end
    end

    local lines, reportText
    if isQuestInspect then
        lines, reportText = BuildQuestInspectReport(requestedQuestID)
    else
        lines, reportText = BuildInspectReport()
    end

    if mode == "chat" then
        for _, line in ipairs(lines) do
            print(line)
        end
    end

    if mode == "bugsack" then
        local header = isQuestInspect and "Preydator Quest Inspect Report" or "Preydator Inspect Report"
        local okSendCall, sent, reason = pcall(SendToErrorHandler, reportText, header)
        if not okSendCall then
            sent = false
            reason = "handler dispatch fault"
        end
        if sent then
            if isQuestInspect then
                print("Preydator: Quest inspect report sent to BugSack via error handler (debug module).")
            else
                print("Preydator: Inspect report sent to BugSack via error handler (debug module).")
            end
        else
            print("Preydator: Could not send inspect report to BugSack: " .. tostring(reason))
            for _, line in ipairs(lines) do
                print(line)
            end
        end
    end

    if isQuestInspect then
        print("Preydator: Quest inspect report cached in PreydatorLastQuestInspectReport (debug module).")
    else
        print("Preydator: Inspect report cached in PreydatorLastInspectReport (debug module).")
    end
    return true
end

Preydator:RegisterModule("DebugInspect", DebugInspectModule)
