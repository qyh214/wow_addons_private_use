--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_Filters")
KT.Filters = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local ipairs = ipairs
local pairs = pairs
local strfind = string.find

-- WoW API
local _G = _G

local db
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"

local KTF = KT.frame
local OTF = ObjectiveTrackerFrame

local continents = { GetMapContinents() }
local achievCategory = GetCategoryList()
local instanceQuestDifficulty = {
	[DIFFICULTY_DUNGEON_NORMAL] = { QUEST_TAG_DUNGEON },
	[DIFFICULTY_DUNGEON_HEROIC] = { QUEST_TAG_DUNGEON, QUEST_TAG_HEROIC },
	[DIFFICULTY_RAID10_NORMAL] = { QUEST_TAG_RAID, QUEST_TAG_RAID10 },
	[DIFFICULTY_RAID25_NORMAL] = { QUEST_TAG_RAID, QUEST_TAG_RAID25 },
	[DIFFICULTY_RAID10_HEROIC] = { QUEST_TAG_RAID, QUEST_TAG_RAID10 },
	[DIFFICULTY_RAID25_HEROIC] = { QUEST_TAG_RAID, QUEST_TAG_RAID25 },
	[DIFFICULTY_RAID_LFR] = { QUEST_TAG_RAID },
	[DIFFICULTY_DUNGEON_CHALLENGE] = { QUEST_TAG_DUNGEON },
	[DIFFICULTY_RAID40] = { QUEST_TAG_RAID },
	[DIFFICULTY_PRIMARYRAID_NORMAL] = { QUEST_TAG_RAID },
	[DIFFICULTY_PRIMARYRAID_HEROIC] = { QUEST_TAG_RAID },
	[DIFFICULTY_PRIMARYRAID_MYTHIC] = { QUEST_TAG_RAID },
	[DIFFICULTY_PRIMARYRAID_LFR] = { QUEST_TAG_RAID },
}

local eventFrame
local DropDown

--------------
-- Internal --
--------------

local function SetHooks()
	local bck_ObjectiveTracker_OnEvent = OTF:GetScript("OnEvent")
	OTF:SetScript("OnEvent", function(self, event, ...)
		if event == "QUEST_ACCEPTED" then
			local _, questID = ...
			if not IsQuestTask(questID) and db.filterAuto[1] then
				return
			end
		end
		bck_ObjectiveTracker_OnEvent(self, event, ...)
	end)

	-- Quests
	local bck_QuestObjectiveTracker_UntrackQuest = QuestObjectiveTracker_UntrackQuest
	QuestObjectiveTracker_UntrackQuest = function(dropDownButton, questID)
		if not db.filterAuto[1] then
			bck_QuestObjectiveTracker_UntrackQuest(dropDownButton, questID)
		end
	end
	
	hooksecurefunc("QuestObjectiveTracker_OnOpenDropDown", function(self)
		if db.filterAuto[1] then
			UIDropDownMenu_DisableButton(1, 3)
		end
	end)
	
	local bck_QuestMapQuestOptions_TrackQuest = QuestMapQuestOptions_TrackQuest
	QuestMapQuestOptions_TrackQuest = function(questID)
		if not db.filterAuto[1] then
			bck_QuestMapQuestOptions_TrackQuest(questID)
		end
	end
	
	-- Achievements
	local bck_AchievementObjectiveTracker_UntrackAchievement = AchievementObjectiveTracker_UntrackAchievement
	AchievementObjectiveTracker_UntrackAchievement = function(dropDownButton, achievementID)
		if not db.filterAuto[2] then
			bck_AchievementObjectiveTracker_UntrackAchievement(dropDownButton, achievementID)
		end
	end
	
	hooksecurefunc("AchievementObjectiveTracker_OnOpenDropDown", function(self)
		if db.filterAuto[2] then
			UIDropDownMenu_DisableButton(1, 3)
		end
	end)
	
	-- Quest Log
	hooksecurefunc("QuestMapFrame_UpdateQuestDetailsButtons", function()
		if db.filterAuto[1] then
			QuestMapFrame.DetailsFrame.TrackButton:Disable()
			QuestLogPopupDetailFrame.TrackButton:Disable()
		else
			QuestMapFrame.DetailsFrame.TrackButton:Enable()
			QuestLogPopupDetailFrame.TrackButton:Enable()
		end
	end)
	
	-- POI
	local bck_QuestPOIButton_OnClick = QuestPOIButton_OnClick
	QuestPOIButton_OnClick = function(self)
		if not IsQuestWatched(GetQuestLogIndexByID(self.questID)) and db.filterAuto[1] then
			return
		end
		bck_QuestPOIButton_OnClick(self)
	end
end

local function SetHooks_AchievementUI()
	local bck_AchievementButton_ToggleTracking = AchievementButton_ToggleTracking
	AchievementButton_ToggleTracking = function(id)
		if not db.filterAuto[2] then
			return bck_AchievementButton_ToggleTracking(id)
		end
	end
	
	hooksecurefunc("AchievementButton_DisplayAchievement", function(button, category, achievement, selectionID, renderOffScreen)
		if not button.completed then
			if db.filterAuto[2] then
				button.tracked:Disable()
			else
				button.tracked:Enable()
			end
		end
	end)
end

local function GetActiveWorldEvents()
	local events = ""
	local _, month, day, year = CalendarGetDate()
	CalendarSetAbsMonth(month, year)
	local numEvents = CalendarGetNumDayEvents(0, day)
	for i=1, numEvents do
		local title, hour, minute, calendarType, sequenceType = CalendarGetDayEvent(0, day, i)
		if calendarType == "HOLIDAY" then
			local gameHour, gameMinute = GetGameTime()
			if sequenceType == "START" then
				if gameHour >= hour and gameMinute >= minute then
					events = events..title.." "
				end
			elseif sequenceType == "END" then
				if gameHour <= hour and gameMinute <= minute then
					events = events..title.." "
				end
			else
				events = events..title.." "
			end
		end
	end
	return events
end

local function IsInstanceQuest(questID)
	local _, _, difficulty, _ = GetInstanceInfo()
	local difficultyTags = instanceQuestDifficulty[difficulty]
	if difficultyTags then
		local questTag, tagName = GetQuestTagInfo(questID)
		for _, tag in ipairs(difficultyTags) do
			_DBG(difficulty.." ... "..tag, true)
			if tag == questTag then
				return true
			end
		end
	end
	return false
end

local function Filter_Quests(self, spec, idx)
	if not spec then return end
	local numEntries, _ = GetNumQuestLogEntries()
	
	if GetNumQuestWatches() > 0 then
		for i=1, numEntries do
			local _, _, _, isHeader = GetQuestLogTitle(i)
			if not isHeader then
				RemoveQuestWatch(i)
			end
		end
	end

	if spec == "All" then
		for i=numEntries, 1, -1 do
			local _, _, _, isHeader, _, _, _, _, _, _, _, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask then
				AddQuestWatch(i, true)
			end
		end
	elseif spec == "Group" then
		for i=idx, 1, -1 do
			local _, _, _, isHeader, _, _, _, _, _, _, _, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask then
				AddQuestWatch(i, true)
			else
				break
			end
		end
		CloseDropDownMenus()
	elseif spec == "Zone" then
		SetMapToCurrentZone()
		local levels = { GetNumDungeonMapLevels() }
		if #levels > 0 then
			SetDungeonMapLevel(1)
		end
		for i=numEntries, 1, -1 do
			local _, _, _, isHeader, _, _, _, questID, _, _, isOnMap, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask and isOnMap then
				if KT.inInstance then
					if GetQuestWorldMapAreaID(questID) == GetCurrentMapAreaID() then
						if IsInstanceQuest(questID) then
							AddQuestWatch(i, true)
						end
					end
				else
					AddQuestWatch(i, true)
				end
			end
		end
	elseif spec == "Daily" then
		for i=numEntries, 1, -1 do
			local _, _, _, isHeader, _, _, frequency, _, _, _, _, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask and frequency >= 2 then
				AddQuestWatch(i, true)
			end
		end
	elseif spec == "Instance" then
		for i=numEntries, 1, -1 do
			local _, _, _, isHeader, _, _, _, questID, _, _, _, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask then
				local tagID, _ = GetQuestTagInfo(questID)
				if tagID == QUEST_TAG_DUNGEON or
					tagID == QUEST_TAG_HEROIC or
					tagID == QUEST_TAG_RAID or
					tagID == QUEST_TAG_RAID10 or
					tagID == QUEST_TAG_RAID25 then
					AddQuestWatch(i, true)
				end
			end
		end
	elseif spec == "Complete" then
		for i=numEntries, 1, -1 do
			local _, _, _, isHeader, _, _, _, questID, _, _, _, _, isTask = GetQuestLogTitle(i)
			if not isHeader and not isTask and IsQuestComplete(questID) then
				AddQuestWatch(i, true)
			end
		end
	end

	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST)
	QuestSuperTracking_ChooseClosestQuest()
end

local function Filter_Achievements(self, spec)
	if not spec then return end
	local trackedAchievements = { GetTrackedAchievements() }
	
	if GetNumTrackedAchievements() > 0 then
		for i=1, #trackedAchievements do
			RemoveTrackedAchievement(trackedAchievements[i])
		end
	end
	
	if spec == "Zone" then
		SetMapToCurrentZone()
		local continentName = (GetCurrentMapContinent() <= 0) and "" or continents[2*GetCurrentMapContinent()]
		local zoneName = IsMapGarrisonMap(GetCurrentMapAreaID()) and GARRISON_LOCATION_TOOLTIP or (GetRealZoneText() or "")
		local instance = KT.inInstance and 168 or nil
		_DBG(zoneName.." ... "..GetCurrentMapAreaID(), true)
		
		-- Dungeons & Raids
		local type, difficulty, difficultyName
		if instance and db.filterAchievCat[instance] then
			_, type, difficulty, difficultyName = GetInstanceInfo()
			local _, _, sufix = strfind(difficultyName, "^.* %((.*)%)$")
			if sufix then
				difficultyName = sufix
			end
			_DBG(type.." ... "..difficulty.." ... "..difficultyName, true)
		end
		
		-- World Events
		local events = ""
		if db.filterAchievCat[155] then
			events = GetActiveWorldEvents()
		end
		
		for i=1, #achievCategory do
			local category = achievCategory[i]
			local name, parentID, _ = GetCategoryInfo(category)

			if db.filterAchievCat[parentID] then
				if (parentID == 92) or	-- General
					(parentID == 96 and name == continentName) or	-- Quests
					(parentID == 97 and name == continentName) or	-- Exploration
					(parentID == 95 and strfind(zoneName, name)) or	-- Player vs. Player
					(category == instance or parentID == instance) or	-- Dungeons & Raids
					(parentID == 169) or	-- Professions
					(parentID == 201) or	-- Reputation
					(parentID == 15165) or	-- Scenarios
					(parentID == 155 and strfind(events, name)) or	-- World Events
					(category == 15117 or parentID == 15117) or	-- Pet Battles
					(parentID == 15246) or	-- Collections
					(parentID == 15275) or	-- Class Hall
					((category == 15237 or parentID == 15237) and zoneName == GARRISON_LOCATION_TOOLTIP) then	-- Draenor Garrison
					local aNumItems, _ = GetCategoryNumAchievements(category)
					for i=1, aNumItems do
						local track = false
						local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(category, i)
						if aId and not aCompleted then
							--_DBG(aId.." ... "..aName, true)
							if parentID == 95 or category == 15237 or parentID == 15237 or
								(not instance and (category == 15117 or parentID == 15117) and strfind(aName.." - "..aDescription, continentName)) then
								track = true
							elseif strfind(aName.." - "..aDescription, zoneName) then
								if category == instance or parentID == instance then
									if strfind(strlower(aName.." - "..aDescription), strlower(difficultyName)) or
										strfind(aName.." - "..aDescription, "difficulty or higher") then	-- TODO: other languages
										track = true
									end
								else
									track = true
								end
							elseif strfind(aDescription, " capita") then	-- capital city (TODO: de, ru strings)
								local cNumItems = GetAchievementNumCriteria(aId)
								for i=1, cNumItems do
									local cDescription, _, cCompleted = GetAchievementCriteriaInfo(aId, i)
									if not cCompleted and strfind(cDescription, zoneName) then
										track = true
										break
									end
								end
							end
							if track then
								AddTrackedAchievement(aId)
							end
						end
						if GetNumTrackedAchievements() == MAX_TRACKED_ACHIEVEMENTS then
							break
						end
					end
				end
			end
			if GetNumTrackedAchievements() == MAX_TRACKED_ACHIEVEMENTS then
				break
			end
			if parentID == -1 then
				--_DBG(category.." ... "..name, true)
			end
		end
	elseif spec == "WEvent" then
		local events = GetActiveWorldEvents()
		local eventName = ""
		
		for i=1, #achievCategory do
			local category = achievCategory[i]
			local name, parentID, _ = GetCategoryInfo(category)
			
			if parentID == 155 and strfind(events, name) then	-- World Events
				eventName = eventName..(eventName ~= "" and ", " or "")..name
				local aNumItems, _ = GetCategoryNumAchievements(category)
				for i=1, aNumItems do
					local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(category, i)
					if aId and not aCompleted then					
						AddTrackedAchievement(aId)
					end
					if GetNumTrackedAchievements() == MAX_TRACKED_ACHIEVEMENTS then
						break
					end
				end
			end
			if GetNumTrackedAchievements() == MAX_TRACKED_ACHIEVEMENTS then
				break
			end
			if parentID == -1 then
				--_DBG(category.." ... "..name, true)
			end
		end
		
		local numTracked = GetNumTrackedAchievements()
		if numTracked == 0 then
			KT:Pour("There is currently no World Event.", 1, 1, 0)
		elseif numTracked > 0 then
			KT:Pour("World Event - "..eventName, 1, 1, 0)
		end
	end
	
	if AchievementFrame then
		AchievementFrameAchievements_ForceUpdate()
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_ACHIEVEMENT)
end

local function DropDown_OnClick(level, button)
	ToggleDropDownMenu(level or 1, button and UIDROPDOWNMENU_MENU_VALUE or nil, DropDown, KTF.FilterButton, -15, -1, nil, button or nil, UIDROPDOWNMENU_SHOW_TIME)
	if button then
		_G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL].showTimer = nil
	end
end

local function Filter_AutoTrack(self, id, spec)
	db.filterAuto[id] = (db.filterAuto[id] ~= spec) and spec or nil
	if db.filterAuto[id] then
		if id == 1 then
			Filter_Quests(self, spec)
		elseif id == 2 then
			Filter_Achievements(self, spec)
		end
		KTF.FilterButton:GetNormalTexture():SetVertexColor(0, 1, 0)
	else
		if id == 1 then
			QuestMapFrame_UpdateQuestDetailsButtons()
		elseif id == 2 and AchievementFrame then
			AchievementFrameAchievements_ForceUpdate()
		end
		if not db.filterAuto[(id == 1) and 2 or 1] then
			KTF.FilterButton:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		end
	end
	DropDown_OnClick()
end

local function Filter_AchievCat_CheckAll(self, state)
	for id, _ in pairs(db.filterAchievCat) do
		db.filterAchievCat[id] = state
	end
	if db.filterAuto[2] then
		Filter_Achievements(_, db.filterAuto[2])
		CloseDropDownMenus()
	else
		local listFrame = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL]
		DropDown_OnClick(UIDROPDOWNMENU_MENU_LEVEL, _G["DropDownList"..listFrame.parentLevel.."Button"..listFrame.parentID])
	end
end

local function DropDown_Initialize(self, level)
	local numEntries, numQuests = GetNumQuestLogEntries()
	local info = UIDropDownMenu_CreateInfo()
	info.isNotRadio = true
	
	if level == 1 then
		info.notCheckable = true
		
		-- Quests
		info.text = TRACKER_HEADER_QUESTS
		info.isTitle = true
		UIDropDownMenu_AddButton(info)
		
		info.isTitle = false
		info.disabled = (db.filterAuto[1] or numQuests == 0)
		info.func = Filter_Quests

		info.text = "All ("..numQuests..")"
		info.hasArrow = not (db.filterAuto[1] or numQuests == 0)
		info.value = 1
		info.arg1 = "All"
		UIDropDownMenu_AddButton(info)

		info.hasArrow = false

		info.text = "Zone"
		info.arg1 = "Zone"
		UIDropDownMenu_AddButton(info)

		info.text = "Daily"
		info.arg1 = "Daily"
		UIDropDownMenu_AddButton(info)
		
		info.text = "Instance"
		info.arg1 = "Instance"
		UIDropDownMenu_AddButton(info)
		
		info.text = "Complete"
		info.arg1 = "Complete"
		UIDropDownMenu_AddButton(info)
		
		info.text = "Untrack All"
		info.disabled = (db.filterAuto[1] or GetNumQuestWatches() == 0)
		info.arg1 = ""
		UIDropDownMenu_AddButton(info)
		
		info.text = "|cff00ff00Auto|r Zone"
		info.notCheckable = false
		info.disabled = false
		info.leftPadding = 3
		info.arg1 = 1
		info.arg2 = "Zone"
		info.checked = (db.filterAuto[info.arg1] == info.arg2)
		info.func = Filter_AutoTrack
		UIDropDownMenu_AddButton(info)
		
		info.text = ""
		info.notCheckable = true
		info.leftPadding = nil
		info.disabled = true
		UIDropDownMenu_AddButton(info)
		
		-- Achievements
		info.text = TRACKER_HEADER_ACHIEVEMENTS
		info.isTitle = true
		UIDropDownMenu_AddButton(info)
		
		info.isTitle = false
		info.disabled = false
				
		info.text = "Categories"
		info.keepShownOnClick = true
		info.hasArrow = true
		info.value = 2
		info.func = nil
		UIDropDownMenu_AddButton(info)

		info.keepShownOnClick = false
		info.hasArrow = false
		info.disabled = (db.filterAuto[2])
		info.func = Filter_Achievements
		
		info.text = "Zone"
		info.arg1 = "Zone"
		UIDropDownMenu_AddButton(info)
		
		info.text = "World Event"
		info.arg1 = "WEvent"
		UIDropDownMenu_AddButton(info)
		
		info.text = "Untrack All"
		info.disabled = (db.filterAuto[2] or GetNumTrackedAchievements() == 0)
		info.arg1 = ""
		UIDropDownMenu_AddButton(info)
		
		info.text = "|cff00ff00Auto|r Zone"
		info.notCheckable = false
		info.disabled = false
		info.leftPadding = 3
		info.arg1 = 2
		info.arg2 = "Zone"
		info.checked = (db.filterAuto[info.arg1] == info.arg2)
		info.func = Filter_AutoTrack
		UIDropDownMenu_AddButton(info)
		
		-- Addon - PetTracker
		if KT.AddonPetTracker.isLoaded then
			info.text = ""
			info.notCheckable = true
			info.leftPadding = nil
			info.disabled = true
			UIDropDownMenu_AddButton(info)
			
			info.text = PETS
			info.isTitle = true
			UIDropDownMenu_AddButton(info)
			
			info.isTitle = false
			info.disabled = false
			info.notCheckable = false
			info.leftPadding = 3
			
			info.text = PetTracker.Locals.TrackPets
			info.checked = (not PetTracker.Sets.HideTracker)
			info.func = function()
				PetTracker.Tracker.Toggle()
				if db.collapsed and not PetTracker.Sets.HideTracker then
					ObjectiveTracker_MinimizeButton_OnClick()
				end
			end
			UIDropDownMenu_AddButton(info)
			
			info.text = PetTracker.Locals.CapturedPets
			info.checked = (PetTracker.Sets.CapturedPets)
			info.func = function()
				PetTracker.Sets.CapturedPets = not PetTracker.Sets.CapturedPets
				PetTracker:ForAllModules("TrackingChanged")
			end
			UIDropDownMenu_AddButton(info)
		end
	elseif level == 2 then
		info.notCheckable = true

		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.arg1 = "Group"
			info.func = Filter_Quests

			if numEntries > 0 then
				for i=1, numEntries do
					local title, _, _, isHeader, _, _, _, _, _, _, isOnMap = GetQuestLogTitle(i)
					if isHeader then
						if i > 1 then
							info.arg2 = i - 1
							UIDropDownMenu_AddButton(info, level)
						end
						info.text = (isOnMap and "|cff00ff00" or "")..title
					end
				end
				info.arg2 = numEntries
				UIDropDownMenu_AddButton(info, level)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			info.func = Filter_AchievCat_CheckAll

			info.text = "Check All"
			info.arg1 = true
			UIDropDownMenu_AddButton(info, level)

			info.text = "Uncheck All"
			info.arg1 = false
			UIDropDownMenu_AddButton(info, level)

			info.keepShownOnClick = true
			info.notCheckable = false
			info.leftPadding = 3

			for i=1, #achievCategory do
				local id = achievCategory[i]
				local name, parentID, _ = GetCategoryInfo(id)
				if parentID == -1 and id ~= 15234 and id ~= 81 then		-- Skip "Legacy" and "Feats of Strength"
					info.text = name
					info.checked = (db.filterAchievCat[id])
					info.arg1 = id
					info.func = function(_, arg)
						db.filterAchievCat[arg] = not db.filterAchievCat[arg]
						if db.filterAuto[2] then
							Filter_Achievements(_, db.filterAuto[2])
							CloseDropDownMenus()
						end
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end

local function SetFrames()
	-- Event frame
	if not eventFrame then
		eventFrame = CreateFrame("Frame")
		eventFrame:SetScript("OnEvent", function(_, event, arg1, ...)
			_DBG("Event - "..event.." - "..(arg1 or ""), true)
			if event == "ADDON_LOADED" and arg1 == "Blizzard_AchievementUI" then
				SetHooks_AchievementUI()
				eventFrame:UnregisterEvent(event)
			elseif event == "QUEST_POI_UPDATE" then
				if db.filterAuto[1] == "Zone" then
					Filter_Quests(_, "Zone")
				end
			elseif event == "ZONE_CHANGED_NEW_AREA" then
				if db.filterAuto[1] == "Zone" then
					Filter_Quests(_, "Zone")
				end
				if db.filterAuto[2] == "Zone" then
					Filter_Achievements(_, "Zone")
				end
			end
		end)
	end
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:RegisterEvent("QUEST_POI_UPDATE")
	eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	
	-- Filter button
	local button = CreateFrame("Button", addonName.."FilterButton", KTF)
	button:SetSize(16, 16)
	button:SetPoint("TOPRIGHT", -30, -8)
	button:SetFrameLevel(KTF:GetFrameLevel() + 10)
	button:SetNormalTexture(mediaPath.."UI-KT-HeaderButtons")
	button:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 0.75)
	
	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", function(self, btn)
		DropDown_OnClick()
	end)
	button:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Filter", 1, 1, 1)
		GameTooltip:AddLine(db.filterAuto[1] and db.filterAuto[1].." Quests", 0, 1, 0)
		GameTooltip:AddLine(db.filterAuto[2] and db.filterAuto[2].." Achievements", 0, 1, 0)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		if db.filterAuto[1] or db.filterAuto[2] then
			self:GetNormalTexture():SetVertexColor(0, 1, 0)
		else
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		end
		GameTooltip:Hide()
	end)
	KTF.FilterButton = button
	
	-- Filter dropdown
	DropDown = CreateFrame("Frame", addonName.."FilterDropDown", KTF, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(DropDown, DropDown_Initialize, "MENU")
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile

	local defaults = {
		profile = KT:MergeTables({
			filterAuto = {
				nil,	-- [1] Quests
				nil,	-- [2] Achievements
			},
			filterAchievCat = {
				[92] = true,	-- General
				[96] = true,	-- Quests
				[97] = true,	-- Exploration
				[95] = true,	-- Player vs. Player
				[168] = true,	-- Dungeons & Raids
				[169] = true,	-- Professions
				[201] = true,	-- Reputation
				[15165] = true,	-- Scenarios
				[155] = true,	-- World Events
				[15117] = true,	-- Pet Battles
				[15246] = true,	-- Collections
				[15275] = true,	-- Class Hall
				[15237] = true,	-- Draenor Garrison
			},
		}, KT.db.defaults.profile)
	}
	KT.db:RegisterDefaults(defaults)
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetHooks()
	SetFrames()
		
	Filter_Quests(_, db.filterAuto[1])
	Filter_Achievements(_, db.filterAuto[2])
end