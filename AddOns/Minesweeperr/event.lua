local MS = Minesweeperr


function MS:CustomEventHandler(event, type, ...)
    if type == "PANEL_CLICK" then
        local idx = ...
        local guid = MS.Data.partyMembers[MS.Const.partyMembersTempl[idx+1]]
        local unitInfo = MS.Data:selectUnitfromDB(guid)
        MS.Frame:onPanelClick(idx, unitInfo)
    elseif type == "INIT_DATA_ENGINE" then
        MS.Data:Initialize()
    elseif type == "INIT_FRAME" then
        MS.Frame:Create(...)
    elseif type == "INIT_ANIMATION" then
        MS.Animation:setupAnimations()
    elseif type == "TOGGLE_MAIN_FRAME" then
        MS.Frame:ToggleMainFrame()
    elseif type == "REFRESH_ALL" then
        MS.Data:refreshAll(...)
    elseif type == "REFRESH_UNIT" then
        MS.Data:refreshUnit(...)
    elseif type == "REFRESH_PANEL" then
        MS.Frame:RefreshUnitPanel(...)
    elseif type == "REFRESH_DETAILS" then
        MS.Frame:onPanelClick(nil, ...)
    elseif type == "UPDATE_DETAILS" then
        MS.Frame:updateDetails(...)
    elseif type == "REFRESH_QC" then
        MS.Frame:RefreshQCFrame(MS.Data.partyMembers)
    elseif type == "REFRESH_QC_PANEL" then
        local guid = MS.Data.partyMembers[...]
        local unitInfo = MS.Data:selectUnitfromDB(guid)
        MS.Frame:RefreshUnitQCPanel(unitInfo)
    elseif type == "TOGGLE_PANEL" then
        MS.Frame:onTogglePanel(...)
    elseif type == "TRIGGER_REFRESH_ICON" then
        MS.Frame:triggerRefreshIcon(...)
    elseif type == "SHUTDOWN_REFRESH_ICON" then
        MS.Frame:shutdownRefreshIcon(...)
    elseif type == "SAVE_GOOD_RATING" then
        local guid = ...
        MS.Data:saveRating(guid, 1)
    elseif type == "SAVE_BAD_RATING" then
        local guid = ...
        MS.Data:saveRating(guid, 0)
    elseif type == "SAVE_GOOD_RATING_FROM_HISTORY" then
        local guid = ...
        MS.Data:saveRatingFromHistory(guid, 1)
    elseif type == "SAVE_BAD_RATING_FROM_HISTORY" then
        local guid = ...
        MS.Data:saveRatingFromHistory(guid, 0)
    elseif type == "REFRESH_HISTORY" then
        MS.Frame:RefreshHistoryFrame()
    elseif type == "SAVE_GOOD_RATING_FROM_QC" then
        local guid = ...
        MS.Data:saveRatingFromQC(guid, 1)
    elseif type == "SAVE_BAD_RATING_FROM_QC" then
        local guid = ...
        MS.Data:saveRatingFromQC(guid, 0)
    end
end

MS:RegisterMessage("MSCustomEvent", "CustomEventHandler")


function MS:ChallengeStartHandler()
    MS:wait(10, MS.Frame.RefreshQCFrame, MS.Frame, MS.Data.partyMembers)
end

function MS:ChallengeCompletedHandler()
    if self.db.profile.autoShow then
        MS.Frame.qcFrame:ClearAllPoints()
        MS.Frame.qcFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
        MS.Frame.qcFrame:Show()
    end
end

MS:RegisterEvent("CHALLENGE_MODE_START", "ChallengeStartHandler")
MS:RegisterEvent("CHALLENGE_MODE_COMPLETED", "ChallengeCompletedHandler")
