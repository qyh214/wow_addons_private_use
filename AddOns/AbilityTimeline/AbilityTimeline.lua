local appName, app                             = ...
---@class AbilityTimeline
local private                                  = app
local AceGUI                                   = LibStub("AceGUI-3.0")

private.activeFrames                             = {}
---comment
---@param self AbilityTimeline
---@param eventInfo EncounterTimelineEventInfo
private.ENCOUNTER_TIMELINE_EVENT_ADDED         = function(self, eventInfo)
   if not private.TIMELINE_FRAME.frame:IsVisible() then
      private.handleFrame(true)
   end
   if C_EncounterTimeline.GetEventState(eventInfo.id) == 1 then -- Paused
      --private.Debug("Event added in paused state, ignoring for now, eventID".. eventInfo.id)
		return -- ignore paused bars when added, they are always canceled some time later
	end

   if eventInfo.source == Enum.EncounterTimelineEventSource.Script then
      private.Debug("Adding event to timeline from script event, eventID".. eventInfo.id)
      private.addEvent(eventInfo)
      return
   end

   if eventInfo.source == Enum.EncounterTimelineEventSource.EditMode then
      private.Debug("Adding event to timeline from edit mode, eventID".. eventInfo.id)
      private.addEvent(eventInfo)
      return
   end
   -- According to moores law we could also do not (bwdisabled or dbmdisabled) but this is easier to read
   if not private.DisableBlizzTimersBW and not private.DisableBlizzTimersDBM then
      private.Debug("Adding event to timeline from timeline event ".. eventInfo.id .. " : ".. eventInfo.spellName)
      private.addEvent(eventInfo)
      return
   end
end

private.TIMELINE_TICKS                         = { 5 }
private.AT_THRESHHOLD                          = 0.8
private.AT_THRESHHOLD_TIME                     = 10

private.BIGICON_THRESHHOLD_TIME                = 5

private.createTimelineIcon                     = function(eventInfo)
   if private.activeFrames[eventInfo.id] then
     -- private.Debug("Frame already exists for eventID".. eventInfo.id.. "removing existing frame")
      private.removeAtIconFrame(eventInfo.id)
   end
   local frame = AceGUI:Create("AtAbilitySpellIcon")
   frame:SetEventInfo(eventInfo)
   private.activeFrames[eventInfo.id] = frame
   frame.frame:Show()

   -- private.Debug(frame, "AT_TIMELINE_ICON")
   -- private.Debug(eventInfo, "Event info for new icon")
   -- local copyTable = CopyTable(private.activeFrames, true)
   -- private.Debug(copyTable, "Active frames after adding new icon")
end
local activeEvents                             = {}
---comment
---@param eventInfo EncounterTimelineEventInfo
private.addEvent                               = function(eventInfo)
   --local durationObject = C_EncounterTimeline.GetEventTimer(eventInfo.id)
   --activeEvents[eventInfo.id]=durationObject
   if not eventInfo.id then
      private.Debug("Event info has no id, cannot check track or track type")
      return
   end
   local trackID = C_EncounterTimeline.GetEventTrack(eventInfo.id)
   if not trackID then
      private.Debug("Event has no trackID, cannot check track or track type")
      return
   end
   local trackType = C_EncounterTimeline.GetTrackType(trackID)
   if eventInfo.source ~= Enum.EncounterTimelineEventSource.Script and eventInfo.source ~= Enum.EncounterTimelineEventSource.EditMode and (trackType == Enum.EncounterTimelineTrackType.Hidden or trackID == Enum.EncounterTimelineTrack.Indeterminate) then
      private.Debug("Hidden track, not adding icon for eventID".. eventInfo.id.. " trackID: ".. trackID.. " trackType: ".. trackType)
      return
   end
   if eventInfo.source ~= Enum.EncounterTimelineEventSource.Script and eventInfo.source ~= Enum.EncounterTimelineEventSource.EditMode and C_EncounterTimeline.GetEventState(eventInfo.id) == 1 then -- Paused
      private.Debug("Event added in paused state, ignoring for now, eventID".. eventInfo.id)
		return -- ignore paused bars when added, they are always canceled some time later
	end
   private.createTimelineIcon(eventInfo)
end

private.removeEvent                            = function(eventInfo)
   private.removeAtIconFrame(eventInfo.id)
end

private.ENCOUNTER_STATES                       = {
   Active = Enum.EncounterTimelineEventState.Active,
   Paused = Enum.EncounterTimelineEventState.Paused,
   Finished = Enum.EncounterTimelineEventState.Finished,
   Canceled = Enum.EncounterTimelineEventState.Canceled,
   Blocked = 4,
}

private.removeAtIconFrame                      = function(eventID)
   local frame = private.activeFrames[eventID]
   if frame then
      frame.frame:Hide()
      frame:Release()
      private.activeFrames[eventID] = nil
   else
      -- private.Debug("No frame found for eventID".. eventID)
   end
end

private.ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED = function(self, eventID)
   local newState = C_EncounterTimeline.GetEventState(eventID)
   if newState == private.ENCOUNTER_STATES.Finished then
      private.removeAtIconFrame(eventID)
      if not C_EncounterTimeline.HasAnyEvents() then
         private.handleFrame(false)
      end
   elseif newState == private.ENCOUNTER_STATES.Canceled then
      private.removeAtIconFrame(eventID)
      if not C_EncounterTimeline.HasAnyEvents() then
         private.handleFrame(false)
      end
   elseif newState == private.ENCOUNTER_STATES.Paused then
   elseif newState == private.ENCOUNTER_STATES.Active then
   end
end

private.ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED = function(self, eventID)
   local trackID = C_EncounterTimeline.GetEventTrack(eventID)
   local trackType = C_EncounterTimeline.GetTrackType(trackID)
   local isPaused = C_EncounterTimeline.GetEventState(eventID) == private.ENCOUNTER_STATES.Paused
   if (trackType == Enum.EncounterTimelineTrackType.Hidden or trackID == Enum.EncounterTimelineTrack.Indeterminate) and not isPaused then
      -- private.Debug("Hidden track, removing icon if exists for eventID", eventID)
      private.removeAtIconFrame(eventID)
      if not C_EncounterTimeline.HasAnyEvents() then
         private.handleFrame(false)
      end
   elseif not private.activeFrames[eventID] and ((not private.DisableBlizzTimersBW and not private.DisableBlizzTimersDBM) or private.ActiveBossModTimers[eventID]) then
      local remainingTime = C_EncounterTimeline.GetEventTimeRemaining(eventID)
      if remainingTime <= 1 then
         return
      end
      private.Debug("New event tracked, adding icon for eventID" .. eventID)
      private.addEvent(C_EncounterTimeline.GetEventInfo(eventID))
   end
end

private.HIGHLIGHT_EVENTS                       = {
   BigIcons = {},
   HighlightTexts = {}
}
local highlightsTriggered                      = {}
-- private.EventTicker = C_Timer.NewTicker(0.1, function ()
--    for eventID, durationObject in pairs(activeEvents) do
--       local timeLeft = durationObject:GetRemainingDuration()
--       if timeLeft <= private.BIGICON_THRESHHOLD_TIME and timeLeft > 0 and not highlightsTriggered[eventID] then
--          private.TRIGGER_HIGHLIGHT(C_EncounterTimeline.GetEventInfo(eventID))
--       end
--    end
-- end)


private.TRIGGER_HIGHLIGHT = function(eventInfo)
   highlightsTriggered[eventInfo.id] = true
   if private.db.global.bigicon_enabled[private.ACTIVE_EDITMODE_LAYOUT] and not private.HIGHLIGHT_EVENTS.BigIcons[eventInfo.id] then
      private.createBigIcon(eventInfo)
   end
   if private.db.global.text_highlight_enabled[private.ACTIVE_EDITMODE_LAYOUT] and not private.HIGHLIGHT_EVENTS.HighlightTexts[eventInfo.id] then
      private.createTextHighlight(eventInfo)
   end
   if private.db.profile.useAudioCountdowns then
      private.playAudioAlert(eventInfo)
   end
end
private.ENCOUNTER_TIMELINE_EVENT_REMOVED = function(self, eventID)
   if not C_EncounterTimeline.HasAnyEvents() then
      private.handleFrame(false)
   end
   private.removeAtIconFrame(eventID)
end


private.createTimelineFrame = function()
   private.TIMELINE_FRAME = AceGUI:Create("AtTimelineFrame")

   private.BIGICON_FRAME = AceGUI:Create("AtBigIconFrame")


   private.TEXT_HIGHLIGHT_FRAME = AceGUI:Create("AtTextHighlightFrame")
end

private.handleFrame = function(show)
   if show then
      if not private.TIMELINE_FRAME.frame then
         private.createTimelineFrame()
      end
      private.TIMELINE_FRAME.frame:Show()
   else
      if private.TIMELINE_FRAME.frame then
         private.TIMELINE_FRAME.frame:Hide()
      end
      private.removeAllFrames()
   end
end

private.removeAllFrames = function()
   for eventID, frame in pairs(private.activeFrames) do
      private.removeAtIconFrame(eventID)
   end
end
