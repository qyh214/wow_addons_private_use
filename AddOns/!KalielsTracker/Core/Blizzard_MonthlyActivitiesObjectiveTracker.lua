
KT_MONTHLY_ACTIVITIES_TRACKER_MODULE = KT_ObjectiveTracker_GetModuleInfoTable("KT_MONTHLY_ACTIVITIES_TRACKER_MODULE");
KT_MONTHLY_ACTIVITIES_TRACKER_MODULE.updateReasonModule = KT_OBJECTIVE_TRACKER_UPDATE_MODULE_MONTHLY_ACTIVITIES;
KT_MONTHLY_ACTIVITIES_TRACKER_MODULE:SetHeader(KT_ObjectiveTrackerFrame.BlocksFrame.MonthlyActivitiesHeader, TRACKER_HEADER_MONTHLY_ACTIVITIES, OBJECTIVE_TRACKER_UPDATE_MONTHLY_ACTIVITY_ADDED);

function KT_MONTHLY_ACTIVITIES_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(block.id);
		ChatEdit_InsertLink(perksActivityLink);
	elseif ( mouseButton ~= "RightButton" ) then
		--CloseDropDownMenus();
		if ( not EncounterJournal ) then
			EncounterJournal_LoadUI();
		end
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			KT_MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(_, block.id);
		else
			MonthlyActivitiesFrame_OpenFrameToActivity(block.id);
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		KT_ObjectiveTracker_ToggleDropDown(block, KT_MonthlyActivitiesObjectiveTracker_OnOpenDropDown);
	end
end

function KT_MONTHLY_ACTIVITIES_TRACKER_MODULE:GetDebugReportInfo(block)
	return { debugType = "TrackedPerksAcitivity", perksActivityID = block.id, };
end

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

function KT_MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(activityID)
	if ( not EncounterJournal ) then
		EncounterJournal_LoadUI();
	end
	MonthlyActivitiesFrame_OpenFrameToActivity(activityID);
end

function KT_MonthlyActivitiesObjectiveTracker_OnOpenDropDown(self)
	--[[local block = self.activeFrame;

	local info = UIDropDownMenu_CreateInfo();
	info.text = block.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = function (button, ...) KT_MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(...); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = KT_MonthlyActivitiesObjectiveTracker_UntrackPerksActivity;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);]]
end

function KT_MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(dropDownButton, perksActivityID)
	C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID);
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function KT_MONTHLY_ACTIVITIES_TRACKER_MODULE:Update()

	self:BeginLayout();

	local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;

	for i = 1, #trackedActivities do
		local activityID = trackedActivities[i];
		local activityInfo = C_PerksActivities.GetPerksActivityInfo(activityID);
		if activityInfo and not activityInfo.completed then
			local activityName = activityInfo.activityName;
			local requirements = activityInfo.requirementsList;

			local block = self:GetBlock(activityID);
			block.name = activityName;
			self:SetBlockHeader(block, activityName);
			-- criteria
			for index, requirement in ipairs(requirements) do
				if not requirement.completed then
					local criteriaString = requirement.requirementText;
					criteriaString = string.gsub(criteriaString, " / ", "/");
					criteriaString = string.gsub(criteriaString, "- ", "", 1);  -- MSA
					self:AddObjective(block, index, criteriaString, nil, nil, KT_OBJECTIVE_DASH_STYLE_SHOW, KT_OBJECTIVE_TRACKER_COLOR["Normal"]);  -- MSA
				end
			end
			block:SetHeight(block.height);

			if ( KT_ObjectiveTracker_AddBlock(block) ) then
				block:Show();
				self:FreeUnusedLines(block);
			else
				block.used = false;
				break;
			end
		end
	end

	self:EndLayout();
end

function KT_MonthlyActivitiesObjectiveTracker_OnActivityCompleted(perksActivityID)
	local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;
	for i = 1, #trackedActivities do
		local activityID = trackedActivities[i];
		if ( activityID == perksActivityID ) then
			PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES);
			break;
		end
	end
end