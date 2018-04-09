--- Kaliel's Tracker
--- Copyright (c) 2012-2018, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

local dropDownFrame

--------------
-- Internal --
--------------

local function SetHooks()
	hooksecurefunc("QuestLogQuests_Update", function(poiTable)
		local titleIndex = 0
		local headerCollapsed, button, height, prevHeight, tagID
		local numEntries, _ = GetNumQuestLogEntries()
		for questLogIndex=1, numEntries do
			local title, level, _, isHeader, isCollapsed, _, frequency, questID, _, _, _, _, isTask, isBounty = GetQuestLogTitle(questLogIndex)
			if isHeader then
				headerCollapsed = isCollapsed
			elseif not isTask and not isBounty and not headerCollapsed then
				tagID, _ = GetQuestTagInfo(questID)
				title = KT:CreateQuestTag(level, tagID, frequency)..title
				titleIndex = titleIndex + 1
				button = QuestLogQuests_GetTitleButton(titleIndex)
				prevHeight = button.Text:GetHeight()
				button.Text:SetText(title)
				height = button.Text:GetHeight()
				if height > prevHeight then
					button:SetHeight(button:GetHeight() + (height - prevHeight))
				end
				
				local colorStyle
				if IsQuestComplete(questID) then
					colorStyle = OBJECTIVE_TRACKER_COLOR["Complete"]
				elseif not db.colorDifficulty then
					colorStyle = OBJECTIVE_TRACKER_COLOR["Header"]
				end
				if colorStyle then
					button.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
				end
				
				if IsQuestHardWatched(questLogIndex) then
					button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0)
				end
			end
		end
	end)
	
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
		local colorStyle
		if IsQuestComplete(self.questID) then
			colorStyle = OBJECTIVE_TRACKER_COLOR["CompleteHighlight"]
		elseif not db.colorDifficulty then
			colorStyle = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"]
		end
		if colorStyle then
			self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end)
	
	hooksecurefunc("QuestMapLogTitleButton_OnLeave", function(self)
		local colorStyle
		if IsQuestComplete(self.questID) then
			colorStyle = OBJECTIVE_TRACKER_COLOR["Complete"]
		elseif not db.colorDifficulty then
			colorStyle = OBJECTIVE_TRACKER_COLOR["Header"]
		end
		if colorStyle then
			self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end)

	-- DropDown
	function QuestMapQuestOptionsDropDown_Initialize(self)	-- R
		local questLogIndex = GetQuestLogIndexByID(self.questID);
		local info = MSA_DropDownMenu_CreateInfo();
		info.isNotRadio = true;
		info.notCheckable = true;

		info.text = TRACK_QUEST;
		if ( IsQuestWatched(questLogIndex) ) then
			info.text = UNTRACK_QUEST;
		end
		info.disabled = (db.filterAuto[1])
		info.func =function(_, questID) QuestMapQuestOptions_TrackQuest(questID) end;
		info.arg1 = self.questID;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);

		info.text = SHARE_QUEST;
		info.func = function(_, questID) QuestMapQuestOptions_ShareQuest(questID) end;
		info.arg1 = self.questID;
		if ( not GetQuestLogPushable(questLogIndex) or not IsInGroup() ) then
			info.disabled = 1;
		end
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);

		if CanAbandonQuest(self.questID) then
			info.text = ABANDON_QUEST;
			info.func = function(_, questID) QuestMapQuestOptions_AbandonQuest(questID) end;
			info.arg1 = self.questID;
			info.disabled = nil;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);
		end

		if db.menuWowheadURL then
			info.text = "|cff33ff99Wowhead|r URL";
			info.func = KT.ShowPopup;
			info.arg1 = "quest";
			info.arg2 = self.questID;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
		end
	end

	function QuestMapLogTitleButton_OnClick(self, button)	-- R
		if ( ChatEdit_TryInsertQuestLinkForQuestID(self.questID) ) then
			return;
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		if ( IsShiftKeyDown() ) then
			QuestMapQuestOptions_TrackQuest(self.questID);
		else
			if ( button == "RightButton" ) then
				if ( self.questID ~= dropDownFrame.questID ) then
					MSA_CloseDropDownMenus();
				end
				dropDownFrame.questID = self.questID;
				MSA_ToggleDropDownMenu(1, nil, dropDownFrame, "cursor", 6, -6, nil, nil, MSA_DROPDOWNMENU_SHOW_TIME);
			else
				if IsModifiedClick(db.menuWowheadURLModifier) then
					KT:ShowPopup("quest", self.questID)
				else
					QuestMapFrame_ShowQuestDetails(self.questID);
				end
			end
		end
	end

	-- Set scripts for 1st button
	local firstButton = QuestLogQuests_GetTitleButton(1)
	firstButton:SetScript("OnEnter", QuestMapLogTitleButton_OnEnter)
	firstButton:SetScript("OnLeave", QuestMapLogTitleButton_OnLeave)
	firstButton:SetScript("OnClick", QuestMapLogTitleButton_OnClick)
end

local function SetFrames()
	-- DropDown frame
	dropDownFrame = CreateFrame("Frame", addonName.."QuestLogDropDown", QuestMapFrame, "MSA_DropDownMenuTemplate")
	dropDownFrame.questID = 0	-- for QuestMapQuestOptionsDropDown_Initialize
	MSA_DropDownMenu_Initialize(dropDownFrame, QuestMapQuestOptionsDropDown_Initialize, "MENU")
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetHooks()
	SetFrames()
end