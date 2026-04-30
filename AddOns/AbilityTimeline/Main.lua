local appName, app = ...
---@class AbilityTimeline
local private = app
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local CustomNames = C_AddOns.IsAddOnLoaded("CustomNames") and LibStub("CustomNames")
---@class MyAddon : AceAddon-3.0, AceConsole-3.0, AceConfig-3.0, AceGUI-3.0, AceConfigDialog-3.0
local AbilityTimeline = LibStub("AceAddon-3.0"):NewAddon("AbilityTimeline", "AceConsole-3.0", "AceEvent-3.0")

function AbilityTimeline:OnInitialize()
    local buildVersion, buildNumber, buildDate, interfaceVersion, localizedVersion, buildInfo = GetBuildInfo() -- Mainline
    assert(interfaceVersion >= 120000, private.getLocalisation("WrongWoWVersionMessage"))
    -- Called when the addon is loaded
    AbilityTimeline:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
    AbilityTimeline:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_REMOVED")
    AbilityTimeline:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
    AbilityTimeline:RegisterEvent("ENCOUNTER_START")
    AbilityTimeline:RegisterEvent("ENCOUNTER_END")
    AbilityTimeline:RegisterEvent("PLAYER_ENTERING_WORLD")
    AbilityTimeline:RegisterEvent("READY_CHECK")
    AbilityTimeline:RegisterEvent("READY_CHECK_FINISHED")
    AbilityTimeline:RegisterEvent("START_PLAYER_COUNTDOWN")
    AbilityTimeline:RegisterEvent("CANCEL_PLAYER_COUNTDOWN")
    AbilityTimeline:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    AbilityTimeline:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    AbilityTimeline:RegisterEvent("CHALLENGE_MODE_RESET")
    AbilityTimeline:RegisterEvent("CHALLENGE_MODE_START")
    AbilityTimeline:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED")
    private.db = LibStub("AceDB-3.0"):New("AbilityTimeline", private.OptionDefaults, true) -- Generates Saved Variables with default Values (if they don't already exist)
    private.Debug(private, "AT_Options")
    local OptionTable = {
        type = "group",
        args = {
            profile = AceDBOptions:GetOptionsTable(private.db),
            rest = private.options
        }
    }
    if not private.db.profile.disableLoginMessage then
        AbilityTimeline:Print(private.getLocalisation("AccessOptionsMessage"))
    end
    AceConfig:RegisterOptionsTable(appName, OptionTable) --
    AceConfigDialog:AddToBlizOptions(appName, appName)
    self:RegisterChatCommand("at", "SlashCommand")
    self:RegisterChatCommand("AT", "SlashCommand")
    self:RegisterChatCommand("pull", "PullCommand")
    if not private.TIMELINE_FRAME then
        private.createTimelineFrame()
    end
    SetCVar("encounterTimelineEnabled", "1")
    private.Debug(EncounterTimeline, "encounterTimeline")

    EncounterTimeline:UnregisterAllEvents()
    EncounterTimeline:Hide()
    EncounterTimeline:HookScript("OnShow", function() EncounterTimeline:Hide() end)
    -- SetCVar("encounterWarningsEnabled", "1")

    --init
    private.ToggleEventColorisation(private.db.profile.dispellTextColor)
    if private.initDbmSkin then
        private.initDbmSkin()
    end
end

function AbilityTimeline:OnEnable()
    -- Called when the addon is enabled
end

function AbilityTimeline:OnDisable()
    -- Called when the addon is disabled
end

function AbilityTimeline_AddonCompartmentFunction()
    AbilityTimeline:SlashCommand("AddonCompartmentFrame")
end

local function createTestBars(duration)
    local spellId = 376864
    local iconId = 135127

    local eventinfo = {
        duration = duration,
        maxQueueDuration = duration + 5,
        overrideName = "Test Spell",
        spellID = spellId,
        iconFileID = iconId,
        severity = 1,
        paused = false

    }


    local eventId = C_EncounterTimeline.AddScriptEvent(eventinfo)
    private.Debug("Creating test bar with duration: " .. duration .. " seconds")
end


function AbilityTimeline:SlashCommand(msg) -- called when slash command is used
    if not C_EncounterTimeline.IsFeatureEnabled() then
        AbilityTimeline:Print(private.getLocalisation("TimelineNotEnabledMessage"))
    elseif not C_EncounterTimeline.IsFeatureAvailable() then
        AbilityTimeline:Print(private.getLocalisation("TimelineNotSupportedMessage"))
    elseif msg == "iconeditor" then
        private.openSpellIconSettings()
    elseif msg == "version" then
        AbilityTimeline:Print("Ability Timeline Version: " ..  C_AddOns.GetAddOnMetadata(appName, "Version"))
    elseif msg == "test" then
        C_EncounterTimeline.AddEditModeEvents()
    elseif string.find(string.lower(msg), "test (.-)") then
        local duration = tonumber(string.match(string.lower(msg), "test (%d+)"))
        if duration then
            createTestBars(duration)
        end
    elseif string.find(string.lower(msg), "rect") then
        private.Debug(private.TIMELINE_FRAME.frame:GetBoundsRect())
    elseif msg == "eventlist" then
        private.Debug(C_EncounterTimeline.GetEventList(), "EventList")
    elseif string.find(string.lower(msg), "pause (.-)") then
        local eventID = tonumber(string.match(string.lower(msg), "pause (%d+)"))
        if eventID then
            C_EncounterTimeline.PauseScriptEvent(eventID)
            private.Debug(C_EncounterTimeline.GetEventInfo(eventID), "EventInfo")
        end
    elseif string.find(string.lower(msg), "resume (.-)") then
        local eventID = tonumber(string.match(string.lower(msg), "resume (%d+)"))
        if eventID then
            C_EncounterTimeline.ResumeScriptEvent(eventID)
        end
    else
        AceConfigDialog:Open(appName)
    end
end

function AbilityTimeline:ENCOUNTER_TIMELINE_EVENT_ADDED(event, eventInfo, initialState)
    C_Timer.After(0, function()
        -- we delay by 1 frame so script events have time to save their data
        private.ENCOUNTER_TIMELINE_EVENT_ADDED(self, eventInfo, initialState)
    end)
end

function AbilityTimeline:ENCOUNTER_TIMELINE_EVENT_REMOVED(self, eventID)
    C_Timer.After(0, function()
        -- we delay by 1 frame so script events have time to save their data
        private.ENCOUNTER_TIMELINE_EVENT_REMOVED(self, eventID)
    end)
end

function AbilityTimeline:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(event, eventID, newState)
    C_Timer.After(0, function()
        -- we delay by 1 frame so script events have time to save their data
        private.ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(self, eventID, newState)
    end)
end

function AbilityTimeline:ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED(event, eventID)
    C_Timer.After(0, function()
        -- we delay by 1 frame so script events have time to save their data
        private.ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED(self, eventID)
    end)
end

function AbilityTimeline:PLAYER_ENTERING_WORLD()
    private.buildInstanceOptions()
end

function AbilityTimeline:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, groupSize, playerDifficultyID)
    -- createTestBars(15)
    private.Debug("Encounter started: " .. tostring(encounterName) .. " " .. tostring(encounterID))
    -- store last encounter info
    private.lastEncounterInfo = {
        encounterID = encounterID,
        encounterName = encounterName,
    }

    if private.db.profile.debugMode and encounterID == 3463 then
        encounterID = 1701
    end
    if not C_ChatInfo.InChatMessagingLockdown() and private.db.profile.enableDNDMessage then
        local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minPlayers, maxPlayers =
        GetDifficultyInfo(difficultyID)
        private.db.global.active = true
        C_ChatInfo.SendChatMessage(private.getLocalisation("CurrentlyBusyInEncounter"):format(encounterName, name), "DND")
    end

    private.createReminders(encounterID)
end

function AbilityTimeline:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, groupSize, playerDifficultyID,
                                       success)
    private.Debug("Encounter ended: " ..
    tostring(encounterName) .. " " .. tostring(encounterID) .. ", success: " .. tostring(success))

    private.cancelSheduledReminders()
    if private.db.profile.disableAllOnEncounterEnd then
        C_EncounterTimeline.CancelAllScriptEvents()
    end
    C_Timer.After(1, function() -- since for some reason encounter end fires before combat lockdown is over we delay
        if not C_ChatInfo.InChatMessagingLockdown() and private.db.profile.enableDNDMessage then
            if private.db.global.active then
                C_ChatInfo.SendChatMessage("", "DND") -- clear dnd message
                private.db.global.active = false
            end
        end
    end
    )
end

function AbilityTimeline:READY_CHECK(event, initiator, readyCheckTimeLeft)
    if private.db.profile.disableReadyCheck then
        private.Debug("Ready check detected but reminders on ready check are disabled, not showing reminder.")
        return
    end
    local timeleft = tonumber(readyCheckTimeLeft) or 35
    local _, classFilename, _ = UnitClass(initiator)
    local _, _, _, argbHex = GetClassColor(classFilename)
    local initiatorName
    if CustomNames and not issecretvalue(initiator) then
        initiatorName = CustomNames.Get(initiator)
    else
        initiatorName = initiator
    end
    local overrideName = private.getLocalisation("ReadyCheck")
    if issecretvalue(initiatorName) or initiatorName then
        overrideName = private.getLocalisation("ReadyCheckBy") .. " " .. WrapTextInColorCode(initiatorName, argbHex)
    end
    local eventinfo = {
        duration = timeleft,
        maxQueueDuration = 0,
        overrideName = overrideName,
        spellID = 0,
        iconFileID = 134400,
        severity = 1,
        paused = false

    }
    private.Debug("Ready check started by " ..
    WrapTextInColorCode(initiatorName, argbHex) .. ", time left: " .. tostring(readyCheckTimeLeft) .. " seconds.")
    private.ReadyCheckEventId = C_EncounterTimeline.AddScriptEvent(eventinfo)
end

function AbilityTimeline:READY_CHECK_FINISHED()
    if private.ReadyCheckEventId then
        C_EncounterTimeline.CancelScriptEvent(private.ReadyCheckEventId)
        private.ReadyCheckEventId = nil
    end
end

function AbilityTimeline:PullCommand(msg)
    if msg and msg:lower():trim() == "cancel" then
        C_PartyInfo.DoCountdown(0)
        return
    end
    local inInstance, instanceType = IsInInstance()
    local smartSeconds = 10
    if inInstance then
        if instanceType == "raid" then
            smartSeconds = 10
        elseif instanceType == "party" then
            smartSeconds = 3
        end
    end
    local seconds = tonumber(msg) or smartSeconds
    C_PartyInfo.DoCountdown(seconds)
end

function AbilityTimeline:START_PLAYER_COUNTDOWN(event, initiatedBy, timeRemaining, totalTime, informChat, initiatedByName)
    local timeleft = tonumber(timeRemaining)
    local color
    local name = initiatedByName
    if issecretvalue(timeleft) or InCombatLockdown() then
        private.Debug("Received START_PLAYER_COUNTDOWN event while in combat or secret value for time left. Ignoring event.")
        return
    end
    if not issecretvalue(initiatedByName) and initiatedByName and UnitClass(initiatedByName) then
        local _, classFilename, _ = UnitClass(initiatedByName)
        local _, _, _, argbHex = GetClassColor(classFilename)
        color = argbHex
    else
        color = 'ffffffff'
    end

    if not issecretvalue(initiatedByName) and initiatedByName and CustomNames then
        name = CustomNames.Get(initiatedByName)
    end

    local overrideName = private.getLocalisation("PullTimer")

    if not issecretvalue(name) and name then
        overrideName = private.getLocalisation("PullTimerBy") .. " " .. WrapTextInColorCode(name, color)
    end

    if private.PullTimerEventId and C_EncounterTimeline.GetEventState(private.PullTimerEventId) and C_EncounterTimeline.GetEventState(private.PullTimerEventId) == Enum.EncounterTimelineEventState.Active then
        C_EncounterTimeline.CancelScriptEvent(private.PullTimerEventId)
        private.PullTimerEventId = nil
    end

    local eventinfo = {
        duration = timeleft,
        maxQueueDuration = 0,
        overrideName = overrideName,
        spellID = 0,
        iconFileID = 134376,
        severity = 1,
        paused = false

    }
    private.Debug("Pull timer started by " ..
    WrapTextInColorCode(name, color) .. ", time left: " .. tostring(timeRemaining) .. " seconds.")
    private.PullTimerEventId = C_EncounterTimeline.AddScriptEvent(eventinfo)
end

function AbilityTimeline:CANCEL_PLAYER_COUNTDOWN()
    if private.PullTimerEventId then
        C_EncounterTimeline.CancelScriptEvent(private.PullTimerEventId)
        private.PullTimerEventId = nil
    end
end

function AbilityTimeline:CHALLENGE_MODE_RESET(event, mapID)
    if not C_ChatInfo.InChatMessagingLockdown() and private.db.profile.enableDNDMessage and private.db.global.active then
        C_ChatInfo.SendChatMessage(private.getLocalisation("CurrentlyDoingMplusKeyFallback"), "DND")
        private.db.global.active = false
    end
end

function AbilityTimeline:CHALLENGE_MODE_START()
    if not C_ChatInfo.InChatMessagingLockdown() and private.db.profile.enableDNDMessage then
        local message = private.getLocalisation("CurrentlyDoingMplusKeyFallback")
        local activeKeystoneLevel, activeAffixIDs, wasActiveKeystoneCharged = C_ChallengeMode.GetActiveKeystoneInfo()
        local challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
        if challengeMapID then
            local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(challengeMapID)
            if name and timeLimit then
                local serverTime = C_DateAndTime.GetServerTimeLocal()
                local finishTime = serverTime + (timeLimit or 0)
                local calenderTime = C_DateAndTime.GetCalendarTimeFromEpoch(finishTime * 1000)
                local timeToDisplay = calenderTime.hour .. ":" .. (calenderTime.minute)
                message = private.getLocalisation("CurrentlyDoingMplusKey"):format(activeKeystoneLevel, name,
                    timeToDisplay)
            end
        end
        C_ChatInfo.SendChatMessage(message, "DND")
        private.db.global.active = true
    end
end

function AbilityTimeline:CHALLENGE_MODE_COMPLETED()
    if private.db.profile.enableKeyRerollTimer then
        local info = C_ChallengeMode.GetChallengeCompletionInfo()
        if not info or not info.onTime then
            private.Debug("Challenge mode completed but not on time. Not adding timer.")
            return
        end
        local eventinfo = {
            duration = 300,
            maxQueueDuration = 0,
            overrideName = private.getLocalisation("RerollKey"),
            spellID = 0,
            iconFileID = 525134,
            severity = 1,
            paused = false

        }
        private.Debug("Challenge mode completed Adding timer for key reroll: 5 minutes.")
        private.RerollKeyEventId = C_EncounterTimeline.AddScriptEvent(eventinfo)
    end
    if private.db.profile.enableDNDMessage and private.db.global.active then
        C_ChatInfo.SendChatMessage("", "DND")
        private.db.global.active = false
    end
end

-- TODO cancel the event if the player actually rerolls the key before the timer ends
function AbilityTimeline:ZONE_CHANGED_NEW_AREA()
    if private.RerollKeyEventId then
        C_EncounterTimeline.CancelScriptEvent(private.RerollKeyEventId)
        private.RerollKeyEventId = nil
    end
    if private.db.profile.enableDNDMessage and private.db.global.active then
        C_ChatInfo.SendChatMessage("", "DND")
        private.db.global.active = false
    end
end
