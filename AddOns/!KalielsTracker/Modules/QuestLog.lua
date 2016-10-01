--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

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
	
	local bck_QuestMapLogTitleButton_OnClick = QuestMapLogTitleButton_OnClick
	QuestMapLogTitleButton_OnClick = function(self, button)
		QuestMapQuestOptionsDropDown.initialize = QuestMapQuestOptionsDropDown_Initialize
		bck_QuestMapLogTitleButton_OnClick(self, button)
	end
	
	local firstButton = QuestLogQuests_GetTitleButton(1)
	firstButton:SetScript("OnEnter", QuestMapLogTitleButton_OnEnter)
	firstButton:SetScript("OnLeave", QuestMapLogTitleButton_OnLeave)
	firstButton:SetScript("OnClick", QuestMapLogTitleButton_OnClick)
	
	hooksecurefunc("QuestMapQuestOptionsDropDown_Initialize", function(self)
		if db.filterAuto[1] then
			UIDropDownMenu_DisableButton(1, 1)
		end
	end)
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
end