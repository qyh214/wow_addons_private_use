local appName, app = ...
---@class AbilityTimeline
local private = app

if not C_AddOns.IsAddOnLoaded("BigWigs") then return end

private.BWTimers = {}
private.ActiveBossModTimers = private.ActiveBossModTimers or {}
private.BossModsSpellIndicators = private.BossModsSpellIndicators or {}
private.BossModsColors = private.BossModsColors or {}

local excludedTimers = {
    ["Pull"] = true,
    ["Llamada de jefe"] = true, -- ES-Ex for Pull
    ["Ingaggio"] = true, -- IT-IT for Pull
    ["전투 예정"] = true, -- KO-KR for Pull
    ["Атака"] = true, -- RU-RU for Pull
    ["开怪倒数"] = true, -- CN-ZH for Pull
    ["開怪倒數"] = true, -- CN-ZH-TW for Pull
}

local function TimerStarted(event, module, timerKey, timerMsg, timerDuration, icon, timerIsApprox, timerMaxDuration, eventID, spellIndicators)
    private.Debug("!!!!!!!!!!!!!!!!!!!!!!!!")
    if eventID then
        local eventInfo = C_EncounterTimeline.GetEventInfo(eventID)
        if eventInfo and eventInfo.source ~= Enum.EncounterTimelineEventSource.Script and eventInfo.source ~= Enum.EncounterTimelineEventSource.EditMode then
            private.Debug("Bigwigs timer started for default event, adding to timeline".. eventID)
            private.addEvent(eventInfo)
            private.ActiveBossModTimers[eventID] = true
        end
        return
    end
    if excludedTimers[timerMsg] then return end
    if type(icon) == "string" then
        -- bigwigs uses filepaths for icons but the script event expects fileIDs, so we need to convert it 
        local iconpath = string.gsub(icon, "\\", "/")
        icon = GetFileIDFromPath(iconpath)
    end

    if private.BWTimers[timerMsg] and C_EncounterTimeline.GetEventInfo(private.BWTimers[timerMsg].eventID) then
        C_EncounterTimeline.CancelScriptEvent(private.BWTimers[timerMsg].eventID)
    end
        
    local eventinfo = {
        duration = timerDuration,
        maxQueueDuration = 0,
        overrideName = timerMsg,
        spellID = timerKey and type(timerKey) == "number" and timerKey or 58984,
        iconFileID = icon and type (icon) == "number" and icon or 134400,
        severity = 1,
        paused = false,
    }
    private.Debug("BigWigs Timer Started: " .. timerMsg .. " Duration: " .. timerDuration)
    local eventID = C_EncounterTimeline.AddScriptEvent(eventinfo)
    local color = BigWigs:GetPlugin("Colors"):GetColorTable("barText", module, timerKey)
    if color then
        local r,g,b,a = unpack(color)
        if r ~= 1 or g ~= 1 or b ~= 1 or a ~= 1 then
            local actualColor = CreateColor(r, g, b, a)
            local colorTable = private.BossModsColors[eventID] or {}
            colorTable.textColor = actualColor
            private.BossModsColors[eventID] = colorTable
            private.Debug("Found color for bar text, saving to timer event")
            private.Debug("Color values - R: " .. r .. " G: " .. g .. " B: " .. b .. " A: " .. a)
        else
            private.Debug("Color for bar text is default, not saving to timer event")
        end
    else
        private.Debug("No color found for bar text or spell ID, not saving color for timer event")
    end
    private.ActiveBossModTimers[eventID] = true
    if spellIndicators then
        private.BossModsSpellIndicators[eventID] = spellIndicators
    end
    local barColor = BigWigs:GetPlugin("Colors"):GetColorTable("barBackground", module, timerKey)
    if barColor then
        local r,g,b,a = unpack(barColor)
        if r ~= 1 or g ~= 1 or b ~= 1 or a ~= 1 then
            local actualColor = CreateColor(r, g, b, a)
            local colorTable = private.BossModsColors[eventID] or {}
            colorTable.borderColor = actualColor
            private.BossModsColors[eventID] = colorTable
            private.Debug("Found color for bar background, saving border color for timer event")
        else
            private.Debug("Color for bar background is default, not saving border color for timer event")
        end
    else
        private.Debug("No color found for bar background, not adding border color for timer event")
    end
    private.BWTimers[timerMsg] = {
        eventID = eventID,
        info = {
            timerMsg = timerMsg,
            timerDuration = timerDuration,
            timerIcon = icon,
        }
    }
end

local function TimerStopped(event, module, text, eventID)
    if private.BWTimers[text] and C_EncounterTimeline.GetEventInfo(private.BWTimers[text].eventID) then
        C_EncounterTimeline.CancelScriptEvent(private.BWTimers[text].eventID)
        private.ActiveBossModTimers[private.BWTimers[text].eventID] = nil
        private.BWTimers[text] = nil
    end
end

local function TimerUpdated(event, module, text, timerId)
    if event =="BigWigs_PauseBar" then
        if private.BWTimers[text] and C_EncounterTimeline.GetEventInfo(private.BWTimers[text].eventID) then
            C_EncounterTimeline.PauseScriptEvent(private.BWTimers[text].eventID)
        end
    elseif event =="BigWigs_ResumeBar" then
        if private.BWTimers[text] and C_EncounterTimeline.GetEventInfo(private.BWTimers[text].eventID) then
            C_EncounterTimeline.ResumeScriptEvent(private.BWTimers[text].eventID)
        end
    end
end

local function StopAllTimers()
    private.Debug("BigWigs Stop All Timers")
    C_EncounterTimeline.CancelAllScriptEvents()
    for timerId, timerData in pairs(private.BWTimers) do
        private.BWTimers[timerId] = nil
        private.ActiveBossModTimers[timerData.eventID] = nil
    end
    private.removeAllFrames()
end

local BWCallbackObj = {}
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StartBar", TimerStarted);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StopBar", TimerStopped);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_PauseBar", TimerUpdated);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_ResumeBar", TimerUpdated);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StopBars", StopAllTimers);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_OnBossDisable", StopAllTimers);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_OnPluginDisable", StopAllTimers);

local function hideBWBar(_, _, bar)
    if private.db.profile.disableBossModsBars then
        bar:SetAlpha(0)
    else
        bar:SetAlpha(1)
    end
end

local function hideBWEmphasizedBar(_, _, bar)
    if private.db.profile.disableBossModsEmphasisedBars then
        bar:SetAlpha(0)
    else
        bar:SetAlpha(1)
    end
end

BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_BarCreated", hideBWBar);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_BarEmphasized", hideBWEmphasizedBar);


local function DisableBlizApi(event)
    private.DisableBlizzTimersBW= true
end

local function EnableBlizApi(event)
    private.DisableBlizzTimersBW = false
end

BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_HideBlizzTimers", DisableBlizApi);
BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_ShowBlizzTimers", EnableBlizApi);