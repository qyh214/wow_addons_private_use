local L = DBM_GUI_L

local spamPanel = DBM_GUI.Cat_Filters:CreateNewPanel(L.Panel_SpamFilter, "option")

local spamSpecAnnounceFeat = spamPanel:CreateArea(L.Area_SpamFilter_SpecFeatures)
spamSpecAnnounceFeat:CreateCheckButton(L.SpamBlockNoShowAnnounce, true, nil, "DontShowBossAnnounces")
spamSpecAnnounceFeat:CreateCheckButton(L.SpamBlockNoSpecWarnText, true, nil, "DontShowSpecialWarningText")
spamSpecAnnounceFeat:CreateCheckButton(L.SpamBlockNoSpecWarnFlash, true, nil, "DontShowSpecialWarningFlash")
spamSpecAnnounceFeat:CreateCheckButton(L.SpamBlockNoSpecWarnVibrate, true, nil, "DontDoSpecialWarningVibrate")
spamSpecAnnounceFeat:CreateCheckButton(L.SpamBlockNoSpecWarnSound, true, nil, "DontPlaySpecialWarningSound")

local spamTimers = spamPanel:CreateArea(L.Area_SpamFilter_Timers)
spamTimers:CreateCheckButton(L.SpamBlockNoShowTimers, true, nil, "DontShowBossTimers")
spamTimers:CreateCheckButton(L.SpamBlockNoShowUTimers, true, nil, "DontShowUserTimers")
spamTimers:CreateCheckButton(L.SpamBlockNoCountdowns, true, nil, "DontPlayCountdowns")

local spamMisc = spamPanel:CreateArea(L.Area_SpamFilter_Misc)
spamMisc:CreateCheckButton(L.SpamBlockNoSetIcon, true, nil, "DontSetIcons")
spamMisc:CreateCheckButton(L.SpamBlockNoRangeFrame, true, nil, "DontShowRangeFrame")
spamMisc:CreateCheckButton(L.SpamBlockNoInfoFrame, true, nil, "DontShowInfoFrame")
spamMisc:CreateCheckButton(L.SpamBlockNoHudMap, true, nil, "DontShowHudMap2")
spamMisc:CreateCheckButton(L.SpamBlockNoNameplate, true, nil, "DontShowNameplateIcons")
spamMisc:CreateCheckButton(L.SpamBlockNoYells, true, nil, "DontSendYells")
spamMisc:CreateCheckButton(L.SpamBlockNoNoteSync, true, nil, "BlockNoteShare")
spamMisc:CreateCheckButton(L.SpamBlockAutoGossip, true, nil, "DontAutoGossip")

local spamRestoreArea = spamPanel:CreateArea(L.Area_Restore)
spamRestoreArea:CreateCheckButton(L.SpamBlockNoIconRestore, true, nil, "DontRestoreIcons")
spamRestoreArea:CreateCheckButton(L.SpamBlockNoRangeRestore, true, nil, "DontRestoreRange")

local spamPTArea = spamPanel:CreateArea(L.Area_PullTimer)
spamPTArea:CreateCheckButton(L.DontShowPTNoID, true, nil, "DontShowPTNoID")
spamPTArea:CreateCheckButton(L.DontShowPT, true, nil, "DontShowPT2")
spamPTArea:CreateCheckButton(L.DontShowPTText, true, nil, "DontShowPTText")
spamPTArea:CreateCheckButton(L.DontShowPTCountdownText, true, nil, "DontShowPTCountdownText")
local SPTCDA = spamPTArea:CreateCheckButton(L.DontPlayPTCountdown, true, nil, "DontPlayPTCountdown")

local PTSlider = spamPTArea:CreateSlider(L.PT_Threshold, 1, 10, 1, 300)
PTSlider:SetPoint("BOTTOMLEFT", SPTCDA, "BOTTOMLEFT", 80, -40)
PTSlider:SetValue(math.floor(DBM.Options.PTCountThreshold2))
PTSlider:HookScript("OnValueChanged", function(self)
	DBM.Options.PTCountThreshold2 = math.floor(self:GetValue())
end)
