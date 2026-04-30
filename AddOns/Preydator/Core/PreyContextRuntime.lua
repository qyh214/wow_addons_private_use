local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local PreyContextRuntime = {}
Preydator:RegisterModule("PreyContextRuntime", PreyContextRuntime)

local MAP_ID_EQUIVALENTS = {
    -- Canonicalize equivalent map pairs to one stable ID so comparisons
    -- succeed regardless of which side returns parent vs sub-map.
    [2437] = 2437,
    [2536] = 2437,
    [2537] = 2437,
    [2413] = 2413,
    [2576] = 2413,
    [2405] = 2405,
    [2444] = 2405,
    [2395] = 2395, -- Eversong Woods
}

local function CanonicalizeMapID(mapID)
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
    return MAP_ID_EQUIVALENTS[mapID] or mapID
end

local function IsKnownPreyMapID(mapID)
    local canonicalMapID = CanonicalizeMapID(mapID)
    if not canonicalMapID then
        return false
    end

    -- Known prey maps are maintained in MAP_ID_EQUIVALENTS keys/values.
    return MAP_ID_EQUIVALENTS[canonicalMapID] ~= nil
end

local function SafeToNumber(value)
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

local function ResolveExpectedQuestMapID(questID, ctx)
    local numericQuestID = SafeToNumber(questID)
    if not numericQuestID then
        return nil
    end

    local taskQuestApi = ctx and ctx.taskQuestApi
    if taskQuestApi and type(taskQuestApi.GetQuestZoneID) == "function" then
        local okZoneMapID, rawZoneMapID = pcall(taskQuestApi.GetQuestZoneID, numericQuestID)
        if okZoneMapID then
            local parsedZoneMapID = nil
            local okZoneString, zoneAsString = pcall(tostring, rawZoneMapID)
            if okZoneString and type(zoneAsString) == "string" then
                local numericToken = string.match(zoneAsString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
                    or string.match(zoneAsString, "^%s*([%+%-]?%d*%.%d+)%s*$")
                if numericToken then
                    local okNumber, numericValue = pcall(tonumber, numericToken)
                    if okNumber and type(numericValue) == "number" then
                        parsedZoneMapID = numericValue
                    end
                end
            end

            local zoneMapID = CanonicalizeMapID(parsedZoneMapID)
            if zoneMapID then
                return zoneMapID
            end
        end
    end

    -- Fallback: waypoint map often exists even when GetQuestZoneID is nil.
    local questLog = ctx and ctx.questLog
    if questLog and type(questLog.GetNextWaypoint) == "function" then
        local okWaypoint, waypoint = pcall(questLog.GetNextWaypoint, numericQuestID)
        if okWaypoint and type(waypoint) == "table" then
            local waypointMapID = SafeToNumber(waypoint.uiMapID) or SafeToNumber(waypoint.mapID)
            local canonicalWaypointMapID = CanonicalizeMapID(waypointMapID)
            if canonicalWaypointMapID then
                return canonicalWaypointMapID
            end
        end
    end

    -- Fallback: HuntScanner keeps a quest->zone map cache from Hunt Table rows.
    local getQuestZoneMapIDFromHuntScanner = ctx and ctx.getQuestZoneMapIDFromHuntScanner
    if type(getQuestZoneMapIDFromHuntScanner) == "function" then
        local okScannerMapID, rawScannerMapID = pcall(getQuestZoneMapIDFromHuntScanner, numericQuestID)
        if okScannerMapID then
            local parsedScannerMapID = nil
            local okScannerString, scannerAsString = pcall(tostring, rawScannerMapID)
            if okScannerString and type(scannerAsString) == "string" then
                local numericToken = string.match(scannerAsString, "^%s*([%+%-]?%d+%.?%d*)%s*$")
                    or string.match(scannerAsString, "^%s*([%+%-]?%d*%.%d+)%s*$")
                if numericToken then
                    local okNumber, numericValue = pcall(tonumber, numericToken)
                    if okNumber and type(numericValue) == "number" then
                        parsedScannerMapID = numericValue
                    end
                end
            end

            local scannerMapID = CanonicalizeMapID(parsedScannerMapID)
            if scannerMapID then
                return scannerMapID
            end
        end
    end

    return nil
end

function PreyContextRuntime:GetPreyZoneInfo(questID, ctx)
    -- Get the quest's zone map ID using safe numeric coercion to avoid taint.
    local mapID = ResolveExpectedQuestMapID(questID, ctx)
    if not mapID then
        return nil, nil
    end

    -- Fetch zone name safely via pcall wrapper to prevent taint propagation.
    local mapApi = ctx and ctx.mapApi
    if mapApi and type(mapApi.GetMapInfo) == "function" then
        local okMapInfo, mapInfo = pcall(mapApi.GetMapInfo, mapID)
        if okMapInfo and type(mapInfo) == "table" and mapInfo.name then
            return mapInfo.name, mapID
        end
    end

    return nil, mapID
end

function PreyContextRuntime:GetCurrentActivePreyQuest(ctx)
    local questLog = ctx and ctx.questLog
    if questLog and questLog.GetActivePreyQuest then
        return questLog.GetActivePreyQuest()
    end

    return nil
end

function PreyContextRuntime:IsPlayerInPreyZone(preyMapID, state, ctx)
    return nil
end

function PreyContextRuntime:IsPreyQuestOnCurrentMap(questID, ctx)
    local numericQuestID = SafeToNumber(questID)
    if not numericQuestID then
        return nil
    end

    -- Prefer explicit map ID matching when available.
    local expectedMapID = ResolveExpectedQuestMapID(numericQuestID, ctx)
    local mapApi = ctx and ctx.mapApi
    local questLog = ctx and ctx.questLog
    local playerMapID = nil
    if mapApi and type(mapApi.GetBestMapForUnit) == "function" then
        local okMapID, rawMapID = pcall(mapApi.GetBestMapForUnit, "player")
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
            playerMapID = CanonicalizeMapID(parsedMapID)
        end
    end

    if expectedMapID ~= nil then
        if playerMapID and playerMapID == expectedMapID then
            return true
        else
            return false
        end
    end

    -- No reliable zone map ID available yet (common during reload/login races).
    -- Return nil (unknown) instead of false so callers do not hard-mark the player
    -- out of zone before widget/mixin signals have a chance to initialize.
    -- We still never fall back to isOnMap because that flag is true across the
    -- world map hierarchy and causes cross-zone false positives.
    return nil
end

local function ResolveWidgetCertifiedQuestMapID(questID, state, playerMapID, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local numericQuestID = SafeToNumber(questID)
    if not numericQuestID then
        return nil
    end

    local canonicalPlayerMapID = CanonicalizeMapID(playerMapID)
    if not canonicalPlayerMapID or not IsKnownPreyMapID(canonicalPlayerMapID) then
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local lastWidgetSetupAt = SafeToNumber(state.lastWidgetSetupAt) or 0

    local fallbackMaxAgeSeconds = SafeToNumber(ctx and ctx.widgetZoneFallbackMaxAgeSeconds) or 8
    if fallbackMaxAgeSeconds < 0 then
        fallbackMaxAgeSeconds = 0
    end

    local boundQuestID = SafeToNumber(state.lastWidgetBoundQuestID)
    if boundQuestID and boundQuestID ~= numericQuestID then
        return nil
    end

    local hasFreshSetup = lastWidgetSetupAt > 0 and (now - lastWidgetSetupAt) <= fallbackMaxAgeSeconds
    local hasBoundQuest = boundQuestID == numericQuestID

    local hasVisibleTrackedWidget = false
    local isTrackedPreyWidgetShown = ctx and ctx.isTrackedPreyWidgetShown
    if type(isTrackedPreyWidgetShown) == "function" then
        local okShown, widgetShown = pcall(isTrackedPreyWidgetShown)
        hasVisibleTrackedWidget = okShown and widgetShown == true
    end

    local hasTrackedWidgetPresent = false
    local isTrackedPreyWidgetPresent = ctx and ctx.isTrackedPreyWidgetPresent
    if type(isTrackedPreyWidgetPresent) == "function" then
        local okPresent, widgetPresent = pcall(isTrackedPreyWidgetPresent)
        hasTrackedWidgetPresent = okPresent and widgetPresent == true
    end

    if not (hasFreshSetup or hasBoundQuest or hasVisibleTrackedWidget or hasTrackedWidgetPresent) then
        return nil
    end

    if not hasVisibleTrackedWidget then
        local questLog = ctx and ctx.questLog
        if not (questLog and type(questLog.GetLogIndexForQuestID) == "function" and type(questLog.GetInfo) == "function") then
            return nil
        end

        local logIndex = questLog.GetLogIndexForQuestID(numericQuestID)
        if not logIndex then
            return nil
        end

        local okInfo, info = pcall(questLog.GetInfo, logIndex)
        if not okInfo or type(info) ~= "table" or info.isOnMap ~= true then
            return nil
        end
    end

    return canonicalPlayerMapID
end

function PreyContextRuntime:RefreshInPreyZoneStatus(questID, force, state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local isValidQuestID = ctx and ctx.isValidQuestID
    if type(isValidQuestID) ~= "function" or not isValidQuestID(questID) then
        state.inPreyZone = nil
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0

    local shouldRefresh = force == true
        or state.inPreyZone == nil
        or state.zoneCacheDirty == true
    if not shouldRefresh then
        return state.inPreyZone
    end

    local mapApi = ctx and ctx.mapApi
    local playerMapID = nil
    if mapApi and type(mapApi.GetBestMapForUnit) == "function" then
        local okMapID, rawMapID = pcall(mapApi.GetBestMapForUnit, "player")
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
            playerMapID = CanonicalizeMapID(parsedMapID)
        end
    end

    local questMapID = ResolveExpectedQuestMapID(questID, ctx)
    if questMapID then
        state.preyZoneMapID = questMapID
    else
        questMapID = CanonicalizeMapID(SafeToNumber(state.preyZoneMapID))
    end

    if not questMapID then
        questMapID = CanonicalizeMapID(SafeToNumber(state.confirmedPreyZoneMapID))
    end

    if not questMapID then
        local fallbackMapID = ResolveWidgetCertifiedQuestMapID(questID, state, playerMapID, ctx)
        if fallbackMapID then
            questMapID = fallbackMapID
            state.preyZoneMapID = fallbackMapID
        end
    end

    -- Do not infer quest zone from the current player map while quest-map APIs
    -- are unresolved. In practice this can certify the wrong prey zone when the
    -- player is physically in a different hunt zone.

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

function PreyContextRuntime:RefreshCurrentActivePreyQuestCache(state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local getCurrentActivePreyQuest = ctx and ctx.getCurrentActivePreyQuest

    if type(getCurrentActivePreyQuest) == "function" then
        state.cachedActivePreyQuestID = getCurrentActivePreyQuest()
    else
        state.cachedActivePreyQuestID = nil
    end
    state.cachedActivePreyQuestAt = now
    return state.cachedActivePreyQuestID
end

function PreyContextRuntime:GetCurrentActivePreyQuestCached(maxAgeSeconds, state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local maxAge = tonumber(maxAgeSeconds)
    if not maxAge or maxAge < 0 then
        maxAge = (ctx and tonumber(ctx.defaultMaxAgeSeconds)) or 0
    end

    if (now - (state.cachedActivePreyQuestAt or 0)) > maxAge then
        return self:RefreshCurrentActivePreyQuestCache(state, ctx)
    end

    return state.cachedActivePreyQuestID
end

function PreyContextRuntime:ArmQuestListenBurst(durationSeconds, state, ctx)
    if type(state) ~= "table" then
        return
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local duration = tonumber(durationSeconds)
    if not duration or duration <= 0 then
        duration = (ctx and tonumber(ctx.defaultBurstSeconds)) or 0
    end
    local untilTime = now + duration
    if untilTime > (state.questListenUntil or 0) then
        state.questListenUntil = untilTime
    end

    -- Force a fresh quest sample when a relevant interaction starts.
    self:RefreshCurrentActivePreyQuestCache(state, ctx)
end