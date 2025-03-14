
local addonId, wqtInternal = ...

--world quest tracker object
local WorldQuestTracker = WorldQuestTrackerAddon
if (not WorldQuestTracker) then
	return
end

--framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00World Quest Tracker: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

--localization
local L = DF.Language.GetLanguageTable(addonId)

local ff = WorldQuestTrackerFinderFrame

local _

local p = math.pi/2
local pi = math.pi
local pipi = math.pi*2
local GetPlayerFacing = GetPlayerFacing

local GetNumQuestLogRewardCurrencies = WorldQuestTrackerAddon.GetNumQuestLogRewardCurrencies
local GetQuestLogRewardInfo = GetQuestLogRewardInfo
local GetQuestLogRewardCurrencyInfo = WorldQuestTrackerAddon.GetQuestLogRewardCurrencyInfo
local GetQuestLogRewardMoney = GetQuestLogRewardMoney
local GetNumQuestLogRewards = GetNumQuestLogRewards
local GetQuestInfoByQuestID = C_TaskQuest.GetQuestInfoByQuestID

local MapRangeClamped = DF.MapRangeClamped
local FindLookAtRotation = DF.FindLookAtRotation
local GetDistance_Point = DF.GetDistance_Point

local LibWindow = LibStub ("LibWindow-1.1")
if (not LibWindow) then
	print ("|cFFFFAA00World Quest Tracker|r: libwindow not found, did you just updated the addon? try reopening the client.|r")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--> tracker quest --~tracker

local TRACKER_TITLE_TEXT_SIZE_INMAP = 12
local TRACKER_TITLE_TEXT_SIZE_OUTMAP = 10
local TRACKER_TITLE_TEXTWIDTH_MAX = 160
local TRACKER_ARROW_ALPHA_MAX = 1
local TRACKER_ARROW_ALPHA_MIN = .75
local TRACKER_BACKGROUND_ALPHA_MIN = .35
local TRACKER_BACKGROUND_ALPHA_MAX = .75
local TRACKER_FRAME_ALPHA_INMAP = 1
local TRACKER_FRAME_ALPHA_OUTMAP = .75

local worldFramePOIs = WorldQuestTrackerWorldMapPOI

--verifica se a quest ja esta na lista de track
function WorldQuestTracker.IsQuestBeingTracked (questID)
	for _, quest in ipairs (WorldQuestTracker.QuestTrackList) do
		if (quest.questID == questID) then
			return true
		end
	end
	return
end

function WorldQuestTracker.SetTomTomQuestToTrack(questID)
	local uid = WorldQuestTracker.TomTomUIDs[questID]
	if (uid) then
		TomTom:SetCrazyArrow(uid, TomTom.profile.arrow.arrival, uid.title)
		TomTom:ShowHideCrazyArrow()
	end
end

function WorldQuestTracker.AddQuestTomTom (questID, mapID, noRemove)
	local x, y = C_TaskQuest.GetQuestLocation (questID, mapID)
	local title, factionID, tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = WorldQuestTracker.GetQuest_Info (questID)

	local alreadyExists = TomTom:WaypointExists (mapID, x, y, title)

	if (alreadyExists and WorldQuestTracker.TomTomUIDs [questID]) then
		if (noRemove) then
			return
		end
		TomTom:RemoveWaypoint (WorldQuestTracker.TomTomUIDs [questID])
		WorldQuestTracker.TomTomUIDs [questID] = nil
		return
	end

	if (not alreadyExists) then
		local uid = TomTom:AddWaypoint (mapID, x, y, {title = title, persistent=false})
		WorldQuestTracker.TomTomUIDs [questID] = uid
	end

	return
end

--adiciona uma quest ao tracker
function WorldQuestTracker.AddQuestToTracker(self, questID, mapID)

	questID = self.questID or questID

	if (not HaveQuestData (questID)) then
		WorldQuestTracker:Msg (L["S_ERROR_NOTLOADEDYET"])
		return
	end

	if (WorldQuestTracker.IsQuestBeingTracked (questID)) then
		return
	end

	if (WorldQuestTracker.db.profile.tomtom.enabled and TomTom and C_AddOns.IsAddOnLoaded("TomTom")) then
		WorldQuestTracker.AddQuestTomTom (self.questID, self.mapID or mapID)
		--return true
	end

	local timeLeft = WorldQuestTracker.GetQuest_TimeLeft (questID)
	if (timeLeft and timeLeft > 0) then
		local mapID = self.mapID
		local iconTexture = self.IconTexture
		local iconText = self.IconText
		local questType = self.QuestType
		local numObjectives = self.numObjectives

		local conduitType, _, conduitBorderColor = WorldQuestTracker.GetConduitQuestData(questID)

		if (iconTexture) then
			tinsert (WorldQuestTracker.QuestTrackList, {
				questID = questID,
				mapID = mapID,
				mapIDSynthetic = WorldQuestTracker.db.profile.syntheticMapIdList [mapID] or 0,
				timeAdded = time(),
				timeFraction = GetTime(),
				timeLeft = timeLeft,
				expireAt = time() + (timeLeft*60),
				rewardTexture = iconTexture,
				rewardAmount = iconText,
				index = #WorldQuestTracker.QuestTrackList,
				questType = questType,
				numObjectives = numObjectives,
				conduitType = conduitType,
				conduitBorderColor = conduitBorderColor,
			})
			WorldQuestTracker.JustAddedToTracker [questID] = true
		else
			WorldQuestTracker:Msg (L["S_ERROR_NOTLOADEDYET"])
		end

		--atualiza os widgets para adicionar a quest no frame do tracker
		WorldQuestTracker.RefreshTrackerWidgets()
	else
		WorldQuestTracker:Msg (L["S_ERROR_NOTIMELEFT"])
	end
end

--remove uma quest que ja esta no tracker
--quando o addon iniciar e fazer a primeira chacagem de quests desatualizadas, mandar noUpdate = true
function WorldQuestTracker.RemoveQuestFromTracker (questID, noUpdate)
	for index, quest in ipairs (WorldQuestTracker.QuestTrackList) do
		if (quest.questID == questID) then
			--remove da tabela
			tremove (WorldQuestTracker.QuestTrackList, index)
			--atualiza os widgets para remover a quest do frame do tracker
			if (not noUpdate) then
				WorldQuestTracker.RefreshTrackerWidgets()
			end
			return true
		end
	end
end

--remove todas as quests do tracker
function WorldQuestTracker.RemoveAllQuestsFromTracker()
	local isShowingWorld = WorldQuestTrackerAddon.GetCurrentZoneType() == "world"

	for i = #WorldQuestTracker.QuestTrackList, 1, -1 do
		--get the quest table with info about the quest
		local quest = WorldQuestTracker.QuestTrackList [i]

		--remove the quest from the tracker
		tremove (WorldQuestTracker.QuestTrackList, i)

		--remove tracking indicator on the quest icon
		local questID = quest.questID

		if (isShowingWorld) then
			--quest locations
			for _, widget in pairs (WorldQuestTracker.WorldMapSmallWidgets) do
				if (widget:IsShown() and widget.questID == questID) then
					widget.onEndTrackAnimation:Play()
				end
			end
			--quest summary
			for _, summarySquare in pairs (WorldQuestTracker.WorldSummaryQuestsSquares) do
				if (summarySquare:IsShown() and summarySquare.questID == questID) then
					summarySquare.onEndTrackAnimation:Play()
				end
			end
		else
			--zone map widgets
			for _, widget in pairs (WorldQuestTracker.ZoneWidgetPool) do
				if (widget:IsShown() and widget.questID == questID) then
					widget.onEndTrackAnimation:Play()
				end
			end
		end
	end

	WorldQuestTracker.RefreshTrackerWidgets()
end

--o cliente n�o tem o tempo restante da quest na primeira execu��o
function WorldQuestTracker.CheckTimeLeftOnQuestsFromTracker_Load()
	for i = #WorldQuestTracker.QuestTrackList, 1, -1 do
		local quest = WorldQuestTracker.QuestTrackList [i]
		--if (HaveQuestData (quest.questID)) then
			local timeLeft = WorldQuestTracker.GetQuest_TimeLeft (quest.questID)
		--end
	end
end

--verifica o tempo restante de cada quest no tracker e a remove se o tempo estiver terminado
function WorldQuestTracker.CheckTimeLeftOnQuestsFromTracker()
	local now = time()
	local gotRemoval

	for i = #WorldQuestTracker.QuestTrackList, 1, -1 do
		local quest = WorldQuestTracker.QuestTrackList [i]
		local timeLeft = WorldQuestTracker.GetQuest_TimeLeft (quest.questID)

		if (quest.expireAt < now or not timeLeft or timeLeft <= 0) then -- or not allQuests [quest.questID]
			WorldQuestTracker.RemoveQuestFromTracker (quest.questID, true)
			gotRemoval = true
		end
	end
	if (gotRemoval) then
		WorldQuestTracker.RefreshTrackerWidgets()
	end
end



--organiza as quest para as quests do mapa atual serem jogadas para cima
local Sort_currentMapID = 0
local Sort_QuestsOnTracker = function(t1, t2)
	if (t1.mapID == Sort_currentMapID and t2.mapID == Sort_currentMapID) then
		return t1.LastDistance > t2.LastDistance
		--return t1.timeFraction > t2.timeFraction
	elseif (t1.mapID == Sort_currentMapID) then
		return true
	elseif (t2.mapID == Sort_currentMapID) then
		return false
	else
		if (t1.mapIDSynthetic == t2.mapIDSynthetic) then
			return t1.timeFraction > t2.timeFraction
		else
			return t1.mapIDSynthetic > t2.mapIDSynthetic
		end
	end
end

--poe as quests em ordem de acordo com o mapa atual do jogador?
function WorldQuestTracker.ReorderQuestsOnTracker()
	--joga as quests do mapa atual pra cima
	Sort_currentMapID = WorldQuestTracker.GetCurrentStandingMapAreaID()

--	if (Sort_currentMapID == 1080 or Sort_currentMapID == 1072) then
--		--Thunder Totem or Trueshot Lodge
--		Sort_currentMapID = 1024
--	end

	for index, quest in ipairs (WorldQuestTracker.QuestTrackList) do
		quest.LastDistance = quest.LastDistance or 0
	end
	table.sort (WorldQuestTracker.QuestTrackList, Sort_QuestsOnTracker)
end

--~trackerframe
--this is the main frame for the quest tracker, every thing on the tracker is parent of this frame
local WorldQuestTrackerFrame = CreateFrame("frame", "WorldQuestTrackerScreenPanel", UIParent, "BackdropTemplate")
WorldQuestTrackerFrame:SetSize(235, 500)
WorldQuestTrackerFrame:SetFrameStrata("LOW") --thanks @p3lim on curseforge

function WorldQuestTracker.TrackerFrameOnInit()
	LibWindow.RegisterConfig(WorldQuestTrackerScreenPanel, WorldQuestTracker.db.profile)
	WorldQuestTrackerScreenPanel.RegisteredForLibWindow = true
	LibWindow.MakeDraggable(WorldQuestTrackerScreenPanel)

	if (not WorldQuestTracker.db.profile.tracker_attach_to_questlog) then
		LibWindow.RestorePosition(WorldQuestTrackerScreenPanel)
	end

	WorldQuestTracker.RefreshTrackerAnchor()
end

local WorldQuestTrackerFrame_QuestHolder = CreateFrame ("frame", "WorldQuestTrackerScreenPanel_QuestHolder", WorldQuestTrackerFrame, "BackdropTemplate")
WorldQuestTrackerFrame_QuestHolder:SetAllPoints()
WorldQuestTrackerFrame_QuestHolder:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
WorldQuestTrackerFrame_QuestHolder.MoveMeLabel = WorldQuestTracker:CreateLabel (WorldQuestTrackerFrame_QuestHolder, "== Move Me ==")

local lock_window = function()
	WorldQuestTracker.db.profile.tracker_is_locked = true
	WorldQuestTracker.RefreshTrackerAnchor()
end
WorldQuestTrackerFrame_QuestHolder.LockButton = WorldQuestTracker:CreateButton (WorldQuestTrackerFrame_QuestHolder, lock_window, 120, 24, "Lock Window", nil, nil, nil, nil, "WorldQuestTrackerLockTrackerButton", nil, WorldQuestTracker:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))

WorldQuestTrackerFrame_QuestHolder.MoveMeLabel:SetPoint("center", 0, 3)
WorldQuestTrackerFrame_QuestHolder.LockButton:SetPoint("center", 0, -16)
WorldQuestTrackerFrame_QuestHolder.MoveMeLabel:Hide()
WorldQuestTrackerFrame_QuestHolder.LockButton:Hide()

function WorldQuestTracker.UpdateTrackerScale()
	WorldQuestTrackerFrame:SetScale (WorldQuestTracker.db.profile.tracker_scale)
	--WorldQuestTrackerFrame_QuestHolder:SetScale (WorldQuestTracker.db.profile.tracker_scale) --aumenta s� as quests sem mexer no cabe�alho
end

--cria o header
local WorldQuestTrackerHeader = CreateFrame ("frame", "WorldQuestTrackerQuestsHeader", WorldQuestTrackerFrame, "ObjectiveTrackerContainerHeaderTemplate") -- "ObjectiveTrackerHeaderTemplate"
WorldQuestTrackerHeader.Text:SetText ("World Quest Tracker")
local minimizeButton = CreateFrame ("button", "WorldQuestTrackerQuestsHeaderMinimizeButton", WorldQuestTrackerFrame, "BackdropTemplate")
local minimizeButtonText = minimizeButton:CreateFontString (nil, "overlay", "GameFontNormal")

--hide the default minimize button from the blizz template
WorldQuestTrackerHeader.MinimizeButton:Hide()

minimizeButtonText:SetText (L["S_WORLDQUESTS"])
minimizeButtonText:SetPoint("right", minimizeButton, "left", -3, 1)
minimizeButtonText:Hide()

WorldQuestTrackerFrame.MinimizeButton = minimizeButton
minimizeButton:SetSize(16, 16)
minimizeButton:SetPoint("topright", WorldQuestTrackerHeader, "topright", 0, -4)
minimizeButton:SetScript("OnClick", function()
	if (WorldQuestTrackerFrame.collapsed) then
		WorldQuestTrackerFrame.collapsed = false
		minimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
		minimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
		WorldQuestTrackerFrame_QuestHolder:Show()
		WorldQuestTrackerHeader:Show()
		minimizeButtonText:Hide()
	else
		WorldQuestTrackerFrame.collapsed = true
		minimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
		minimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
		WorldQuestTrackerFrame_QuestHolder:Hide()
		WorldQuestTrackerHeader:Hide()
		minimizeButtonText:Show()
		minimizeButtonText:SetText ("World Quest Tracker")
	end
end)

minimizeButton:SetNormalTexture ([[Interface\Buttons\UI-Panel-QuestHideButton]])
minimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
minimizeButton:SetPushedTexture ([[Interface\Buttons\UI-Panel-QuestHideButton]])
minimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
minimizeButton:SetHighlightTexture ([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]])
minimizeButton:SetDisabledTexture ([[Interface\Buttons\UI-Panel-QuestHideButton-disabled]])

--store the created widgets on a table
local TrackerWidgetPool = {}
--height of the quest tracker
WorldQuestTracker.TrackerHeight = 0

--refresh the tracker positioning
function WorldQuestTracker.RefreshTrackerAnchor()
	--if not using the tracker, hide it and return
	if (not WorldQuestTracker.db.profile.use_tracker) then
		WorldQuestTrackerScreenPanel:Hide()
		return
	end

	--automatic calculate the tracker position based on the objective tracker
	--when attached to the objective tracker, it'll ignore the locked setting
	--also on automatic it should never save the position in the libwindow
	if (WorldQuestTracker.db.profile.tracker_attach_to_questlog) then
		WorldQuestTrackerScreenPanel:EnableMouse(false)
		WorldQuestTrackerScreenPanel:ClearAllPoints()

		for i = 1, ObjectiveTrackerFrame:GetNumPoints() do
			local point, relativeTo, relativePoint, xOfs, yOfs = ObjectiveTrackerFrame:GetPoint (i)
			WorldQuestTrackerScreenPanel:SetPoint(point, relativeTo, relativePoint, -10 + xOfs, yOfs - WorldQuestTracker.TrackerHeight - 20)
		end

		if (WorldQuestTracker.TrackerAttachToModule) then
			WorldQuestTrackerScreenPanel:ClearAllPoints()
			WorldQuestTrackerScreenPanel:SetPoint("top", WorldQuestTracker.TrackerAttachToModule.Header, "bottom", 0, -WorldQuestTracker.TrackerHeight + 10)
		end

		WorldQuestTrackerHeader:ClearAllPoints()
		WorldQuestTrackerHeader:SetPoint("bottom", WorldQuestTrackerFrame, "top", 0, -20)

		--hide the unlocked widgets
		WorldQuestTrackerFrame_QuestHolder.LockButton:Hide()
		WorldQuestTrackerFrame_QuestHolder.MoveMeLabel:Hide()
		WorldQuestTrackerFrame_QuestHolder:SetBackdrop(nil)

		WorldQuestTrackerScreenPanel:Show()
	else
		if (not WorldQuestTracker.db.profile.tracker_is_locked) then
			WorldQuestTrackerScreenPanel:EnableMouse(true)

			--show the unlocked widgets
			WorldQuestTrackerFrame_QuestHolder:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
			WorldQuestTrackerFrame_QuestHolder:SetBackdropColor(0, 0, 0, 0.75)
			WorldQuestTrackerFrame_QuestHolder.LockButton:Show()
			WorldQuestTrackerFrame_QuestHolder.MoveMeLabel:Show()
		else
			WorldQuestTrackerScreenPanel:EnableMouse(false)

			--hide the unlocked widgets
			WorldQuestTrackerFrame_QuestHolder.LockButton:Hide()
			WorldQuestTrackerFrame_QuestHolder.MoveMeLabel:Hide()
			WorldQuestTrackerFrame_QuestHolder:SetBackdrop(nil)
		end

		LibWindow.RestorePosition(WorldQuestTrackerScreenPanel)

		WorldQuestTrackerHeader:ClearAllPoints()
		WorldQuestTrackerHeader:SetPoint("bottom", WorldQuestTrackerFrame, "top", 0, -20)

		WorldQuestTrackerScreenPanel:Show()
	end
end

local TrackerIconButtonOnClick = function(self, button)
	if (button == "MiddleButton") then
		--was middle button and our group finder is enabled
		if (WorldQuestTracker.db.profile.groupfinder.enabled) then
			WorldQuestTracker.FindGroupForQuest (self.questID)
			return
		end

		--middle click without our group finder enabled, check for other addons
		if (WorldQuestGroupFinderAddon) then
			WorldQuestGroupFinder.HandleBlockClick (self.questID)
			return
		end
	end

	if (self.questID == C_SuperTrack.GetSuperTrackedQuestID()) then
		WorldQuestTracker.SuperTracked = nil
		C_SuperTrack.SetSuperTrackedQuestID(0)
		C_SuperTrack.ClearSuperTrackedContent()
		C_SuperTrack.IsSuperTrackingMapPin()

		--started on wow 11.0, the objective tracker isn't always selecting a quest to supertrack.
		--[=[
		["SetSuperTrackedMapPin"] = function,
		["IsSuperTrackingMapPin"] = function,
		["ClearSuperTrackedContent"] = function,
		["ClearSuperTrackedMapPin"] = function,
		["GetSuperTrackedVignette"] = function,
		["GetHighestPrioritySuperTrackingType"] = function,
		["SetSuperTrackedContent"] = function,
		["SetSuperTrackedQuestID"] = function,
		["IsSuperTrackingAnything"] = function,
		["SetSuperTrackedVignette"] = function,
		["GetSuperTrackedMapPin"] = function,
		["IsSuperTrackingQuest"] = function,
		["GetSuperTrackedContent"] = function,
		["GetSuperTrackedQuestID"] = function,
		["SetSuperTrackedUserWaypoint"] = function,
		["IsSuperTrackingContent"] = function,
		["IsSuperTrackingUserWaypoint"] = function,
		["ClearAllSuperTracked"] = function,
		["IsSuperTrackingCorpse"] = function,
		--]=]

		return
	end

	if (HaveQuestData (self.questID)) then
		WorldQuestTracker.SelectSingleQuestInBlizzardWQTracker(self.questID) --thanks @ilintar on CurseForge
		WorldQuestTracker.RefreshTrackerWidgets()
		WorldQuestTracker.SuperTracked = self.questID
	end
end

--quando um widget for clicado, mostrar painel com op��o para parar de trackear
local TrackerFrameOnClick = function(self, button)
	--ao clicar em cima de uma quest mostrada no tracker
	--??--
	if (button == "RightButton") then
		WorldQuestTracker.RemoveQuestFromTracker (self.questID)
		---se o worldmap estiver aberto, dar refresh
		if (WorldMapFrame:IsShown()) then
			if (WorldQuestTracker.IsCurrentMapQuestHub()) then
				--refresh no world map
				WorldQuestTracker.UpdateWorldQuestsOnWorldMap (true)
			elseif (WorldQuestTracker.ZoneHaveWorldQuest()) then
				--refresh nos widgets
				WorldQuestTracker.UpdateZoneWidgets (true)
				WorldQuestTracker.WorldWidgets_NeedFullRefresh = true
			end
		else
			WorldQuestTracker.WorldWidgets_NeedFullRefresh = true
		end
	else
		if (button == "MiddleButton") then
			--was middle button and our group finder is enabled
			if (WorldQuestTracker.db.profile.groupfinder.enabled) then
				WorldQuestTracker.FindGroupForQuest (self.questID)
				return
			end

			--middle click without our group finder enabled, check for other addons
			if (WorldQuestGroupFinderAddon) then
				WorldQuestGroupFinder.HandleBlockClick (self.questID)
				return
			end
		end

		TrackerIconButtonOnClick(self, "leftbutton")
		WorldQuestTracker.CanLinkToChat(self, button)
	end
end


local buildTooltip = function(self)
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -20, 0)
	GameTooltip:SetOwner (self, "ANCHOR_PRESERVE")
	local questID = self.questID

	if ( not HaveQuestData (questID) ) then
		GameTooltip:SetText (RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		GameTooltip:Show()
		return
	end

	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID (questID)
	local tagInfo = C_QuestLog.GetQuestTagInfo(questID)

	if (not tagInfo and WorldQuestTracker.__debug) then
		WorldQuestTracker:Msg("no tagInfo(2) for quest", questID)
	end

	local color = WORLD_QUEST_QUALITY_COLORS [tagInfo.quality or LE_WORLD_QUEST_QUALITY_COMMON]
	GameTooltip:SetText (title, color.r, color.g, color.b)

	--belongs to what faction
	if (factionID) then
		local factionName = WorldQuestTracker.GetFactionDataByID (factionID)
		if (factionName) then
			if (capped) then
				GameTooltip:AddLine (factionName, GRAY_FONT_COLOR:GetRGB())
			else
				GameTooltip:AddLine (factionName, 0.4, 0.733, 1.0)
			end
			GameTooltip:AddLine (" ")
		end
	end

	--time left
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes (questID)
	if (timeLeftMinutes) then
		local color = NORMAL_FONT_COLOR
		local timeString
		if (timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			color = RED_FONT_COLOR
			timeString = SecondsToTime (timeLeftMinutes * 60)
		elseif (timeLeftMinutes <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			timeString = SecondsToTime ((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60)
		elseif (timeLeftMinutes < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			timeString = D_HOURS:format (math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60)
		else
			local days = math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440
			local hours = math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60
			timeString = D_DAYS:format (days) .. " " .. D_HOURS:format (hours - (floor (days)*24))
		end
		GameTooltip:AddLine (BONUS_OBJECTIVE_TIME_LEFT:format (timeString), color.r, color.g, color.b)
	end

	--all objectives
	for objectiveIndex = 1, self.numObjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false);
		if ( objectiveText and #objectiveText > 0 ) then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end

	--percentage bar
	local percent = C_TaskQuest.GetQuestProgressBarInfo (questID)
	if ( percent ) then
	-- WorldMapTaskTooltipStatusBar removed on 8.0
	--	GameTooltip_InsertFrame(GameTooltip, WorldMapTaskTooltipStatusBar);
	--	WorldMapTaskTooltipStatusBar.Bar:SetValue(percent);
	--	WorldMapTaskTooltipStatusBar.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	end

	-- rewards
	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(QUEST_REWARDS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		local hasAnySingleLineRewards = false;
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			GameTooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- money
		local money = GetQuestLogRewardMoney(questID);
		if ( money > 0 ) then
			SetTooltipMoney(GameTooltip, money, nil);
			hasAnySingleLineRewards = true;
		end
		local artifactXP = GetQuestLogRewardArtifactXP(questID);
		if ( artifactXP > 0 ) then
			GameTooltip:AddLine(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- currency
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(texture, numItems, name);
			GameTooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- items
		local numQuestRewards = GetNumQuestLogRewards (questID)
		for i = 1, numQuestRewards do
			local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i, questID);
			local text;
			if ( numItems > 1 ) then
				text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, numItems, name);
			elseif( texture and name ) then
				text = string.format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name);
			end
			if( text ) then
				local color = ITEM_QUALITY_COLORS[quality];
				GameTooltip:AddLine(text, color.r, color.g, color.b);
			end
		end

	end

	GameTooltip:Show()
--	if (GameTooltip.ItemTooltip) then
--		GameTooltip:SetHeight (GameTooltip:GetHeight() + GameTooltip.ItemTooltip:GetHeight())
--	end
end
WorldQuestTracker.BuildTooltip = buildTooltip

local TrackerFrameOnEnter = function(self)
	local color = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"]
	self.Title:SetTextColor (color.r, color.g, color.b)

	local color = OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
	self.Zone:SetTextColor (color.r, color.g, color.b)

	self.RightBackground:SetAlpha(TRACKER_BACKGROUND_ALPHA_MAX)
	self.Arrow:SetAlpha(TRACKER_ARROW_ALPHA_MAX)
	buildTooltip (self)

	self.HasOverHover = true
end

local TrackerFrameOnLeave = function(self)
	local color = OBJECTIVE_TRACKER_COLOR["Header"]
	self.Title:SetTextColor (color.r, color.g, color.b)

	local color = OBJECTIVE_TRACKER_COLOR["Normal"]
	self.Zone:SetTextColor (color.r, color.g, color.b)

	self.RightBackground:SetAlpha(TRACKER_BACKGROUND_ALPHA_MIN)
	self.Arrow:SetAlpha(TRACKER_ARROW_ALPHA_MIN)
	GameTooltip:Hide()

	self.HasOverHover = nil
	self.QuestInfomation.text = ""
end

local TrackerIconButtonOnEnter = function(self)

end
local TrackerIconButtonOnLeave = function(self)

end


--~arrow ãrrow

--from the user @ilintar on CurseForge
--Doing that instead of just SetSuperTrackedQuestID(questID) will make the arrow stay. The code also ensures that only the selected world quest is present in the Blizzard window, as to not make it cluttered.
	function WorldQuestTracker.SelectSingleQuestInBlizzardWQTracker (questID)
		--for i = 1, C_QuestLog.GetNumWorldQuestWatches() do --removed on 9.0, looks like doesn't need to remove super tracked before adding
			--local watchedWorldQuestID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
			--if (watchedWorldQuestID) then
			--	BonusObjectiveTracker_UntrackWorldQuest(watchedWorldQuestID)
			--end
		--end
		--BonusObjectiveTracker_TrackWorldQuest(questID, 0)
		QuestUtil.TrackWorldQuest(questID, Enum.QuestWatchType.Automatic) --0
		C_SuperTrack.SetSuperTrackedQuestID(questID)
	end
--

local TrackerIconButtonOnMouseDown = function(self, button)
	self.Icon:SetPoint("topleft", self:GetParent(), "topleft", -12, -3)
end
local TrackerIconButtonOnMouseUp = function(self, button)
	self.Icon:SetPoint("topleft", self:GetParent(), "topleft", -13, -2)
end


--pega um widget j� criado ou cria um novo ~trackercreate ~trackerwidget
function WorldQuestTracker.GetOrCreateTrackerWidget (index)
	if (TrackerWidgetPool [index]) then
		return TrackerWidgetPool [index]
	end

	local f = CreateFrame ("button", "WorldQuestTracker_Tracker" .. index, WorldQuestTrackerFrame_QuestHolder, "BackdropTemplate")
	--f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
	--f:SetBackdropColor(0, 0, 0, .2)
	f:SetSize(235, 30)
	f:SetScript("OnClick", TrackerFrameOnClick)
	f:SetScript("OnEnter", TrackerFrameOnEnter)
	f:SetScript("OnLeave", TrackerFrameOnLeave)
	f:RegisterForClicks("LeftButtonDown", "MiddleButtonDown", "RightButtonDown")

	f.RightBackground = f:CreateTexture(nil, "background")
	f.RightBackground:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
	f.RightBackground:SetTexCoord(1, 61/128, 0, 1)
	f.RightBackground:SetDesaturated (true)
	f.RightBackground:SetPoint("topright", f, "topright")
	f.RightBackground:SetPoint("bottomright", f, "bottomright")
	f.RightBackground:SetWidth (200)
	f.RightBackground:SetAlpha(TRACKER_BACKGROUND_ALPHA_MIN)

	--f.module = _G ["WORLD_QUEST_TRACKER_MODULE"]
	f.worldQuest = true

	f.Title = DF:CreateLabel (f)
	f.Title.textsize = TRACKER_TITLE_TEXT_SIZE_INMAP
	--f.Title = f:CreateFontString (nil, "overlay", "ObjectiveFont")
	f.Title:SetPoint("topleft", f, "topleft", 10, -1)
	local titleColor = OBJECTIVE_TRACKER_COLOR["Header"]
	f.Title:SetTextColor (titleColor.r, titleColor.g, titleColor.b)
	f.Zone = DF:CreateLabel (f)
	f.Zone.textsize = TRACKER_TITLE_TEXT_SIZE_INMAP
	--f.Zone = f:CreateFontString (nil, "overlay", "ObjectiveFont")
	f.Zone:SetPoint("topleft", f, "topleft", 10, -17)

	f.QuestInfomation = DF:CreateLabel (f)
	f.QuestInfomation:SetPoint("topright", f, "topleft", -10, 50)

	f.YardsDistance = f:CreateFontString (nil, "overlay", "GameFontNormal")
	f.YardsDistance:SetPoint("left", f.Zone.widget, "right", 2, 0)
	f.YardsDistance:SetJustifyH ("left")
	DF:SetFontColor (f.YardsDistance, "white")
	DF:SetFontSize (f.YardsDistance, 12)
	f.YardsDistance:SetAlpha(.5)

	f.TimeLeft = f:CreateFontString (nil, "overlay", "GameFontNormal")
	f.TimeLeft:SetPoint("left", f.YardsDistance, "right", 2, 0)
	f.TimeLeft:SetJustifyH ("left")
	DF:SetFontColor (f.TimeLeft, "white")
	DF:SetFontSize (f.TimeLeft, 12)
	f.TimeLeft:SetAlpha(.5)

	f.Icon = f:CreateTexture(nil, "artwork")
	f.Icon:SetPoint("topleft", f, "topleft", -13, -2)
	f.Icon:SetSize(16, 16)
	f.Icon:SetMask ([[Interface\CharacterFrame\TempPortraitAlphaMask]])

	local IconButton = CreateFrame ("button", "$parentIconButton", f, "BackdropTemplate")
	IconButton:SetSize(18, 18)
	IconButton:SetPoint("center", f.Icon, "center")
	IconButton:SetScript("OnEnter", TrackerIconButtonOnEnter)
	IconButton:SetScript("OnLeave", TrackerIconButtonOnLeave)
	IconButton:SetScript("OnClick", TrackerIconButtonOnClick)
	IconButton:SetScript("OnMouseDown", TrackerIconButtonOnMouseDown)
	IconButton:SetScript("OnMouseUp", TrackerIconButtonOnMouseUp)
	IconButton:RegisterForClicks("LeftButtonDown", "MiddleButtonDown")
	IconButton.Icon = f.Icon
	f.IconButton = IconButton

	f.Circle = f:CreateTexture(nil, "overlay")
	f.Circle:SetAtlas("transmog-nav-slot-selected")
	f.Circle:SetSize(22, 22)
	f.Circle:SetPoint("topleft", f, "topleft", -16, 0)
	f.Circle:SetDesaturated (true)
	f.Circle:SetAlpha(.7)

	f.RewardAmount = f:CreateFontString (nil, "overlay", "ObjectiveFont")
	f.RewardAmount:SetTextColor (titleColor.r, titleColor.g, titleColor.b)
	f.RewardAmount:SetPoint("top", f.Circle, "bottom", 1, 3)
	DF:SetFontSize (f.RewardAmount, 10)

	f.BackgroupTexture = f:CreateTexture(nil, "background")
	f.BackgroupTexture:SetPoint("topleft", f, "topleft", -25, 2)
	f.BackgroupTexture:SetPoint("bottomright", f, "bottomright", 20, -2)
	f.BackgroupTexture:SetTexture([[Interface\AddOns\WorldQuestTracker\media\background_gradient.png]])
	f.BackgroupTexture:SetVertexColor(0, 0, 0, .5)

	local overlayBorder = f:CreateTexture(nil, "overlay", nil, 5)
	local overlayBorder2 = f:CreateTexture(nil, "overlay", nil, 6)
	overlayBorder:SetDrawLayer("overlay", 5)
	overlayBorder2:SetDrawLayer("overlay", 6)
	overlayBorder:SetTexture([[Interface\Soulbinds\SoulbindsConduitIconBorder]])
	overlayBorder2:SetTexture([[Interface\Soulbinds\SoulbindsConduitIconBorder]])
	overlayBorder:SetTexCoord(0/256, 66/256, 0, 0.5)
	overlayBorder2:SetTexCoord(67/256, 132/256, 0, 0.5)
	overlayBorder:SetPoint("topleft", f.Circle, "topleft", 0, 0)
	overlayBorder:SetPoint("bottomright", f.Circle, "bottomright", 0, 0)
	overlayBorder2:SetPoint("topleft", f.Circle, "topleft", 0, 0)
	overlayBorder2:SetPoint("bottomright", f.Circle, "bottomright", 0, 0)
	overlayBorder:Hide()
	overlayBorder2:Hide()
	f.overlayBorder = overlayBorder
	f.overlayBorder2 = overlayBorder2

	f.Shadow = f:CreateTexture(nil, "BACKGROUND")
	f.Shadow:SetSize(26, 26)
	f.Shadow:SetPoint("center", f.Circle, "center")
	f.Shadow:SetTexture([[Interface\PETBATTLES\BattleBar-AbilityBadge-Neutral]])
	f.Shadow:SetAlpha(.3)
	f.Shadow:SetDrawLayer("BACKGROUND", -5)

	f.SuperTracked = f:CreateTexture(nil, "background")
	f.SuperTracked:SetPoint("center", f.Circle, "center")
	f.SuperTracked:SetAlpha(1)
	f.SuperTracked:SetTexture([[Interface\Worldmap\UI-QuestPoi-IconGlow]])
	f.SuperTracked:SetBlendMode("ADD")
	f.SuperTracked:SetSize(42, 42)
	f.SuperTracked:SetDrawLayer("BACKGROUND", -6)
	f.SuperTracked:Hide()

	local highlight = IconButton:CreateTexture(nil, "highlight")
	highlight:SetPoint("center", f.Circle, "center")
	highlight:SetAlpha(1)
	highlight:SetTexture([[Interface\Worldmap\UI-QuestPoi-NumberIcons]])
	--highlight:SetTexCoord(167/256, 185/256, 103/256, 121/256) --low light
	highlight:SetTexCoord(167/256, 185/256, 231/256, 249/256)
	highlight:SetBlendMode("ADD")
	highlight:SetSize(14, 14)

	f.SuperTrackButton = CreateFrame("button", nil, f) --no need backdrop
	f.SuperTrackButton:SetPoint("right", f, "right", 2, 0)
	f.SuperTrackButton:SetSize(18, 24)
	f.SuperTrackButton:SetAlpha(.5)
	f.SuperTrackButton.Icon = f.SuperTrackButton:CreateTexture(nil, "overlay")
	f.SuperTrackButton.Icon:SetAllPoints()
	f.SuperTrackButton.Icon:SetAtlas("Navigation-Tracked-Icon", true)

	f.Arrow = f:CreateTexture(nil, "overlay")
	f.Arrow:SetPoint("right", f.SuperTrackButton, "left", 0, 0)
	f.Arrow:SetSize(32, 32)
	f.Arrow:SetAlpha(.6)
	f.Arrow:SetTexture([[Interface\AddOns\WorldQuestTracker\media\ArrowGridT]])

	f.ArrowDistance = f:CreateTexture(nil, "overlay")
	f.ArrowDistance:SetPoint("center", f.Arrow, "center", 0, 0)
	f.ArrowDistance:SetSize(34, 34)
	f.ArrowDistance:SetAlpha(.5)
	f.ArrowDistance:SetTexture([[Interface\AddOns\WorldQuestTracker\media\ArrowGridTGlow]])
	f.ArrowDistance:SetDrawLayer("overlay", 4)
	f.Arrow:SetDrawLayer("overlay", 5)

	f.SuperTrackButton:SetScript("OnClick", function(self, button)
		TrackerIconButtonOnClick(f, button)
		--C_Timer.After(.2, function() WorldQuestTracker.RefreshTrackerWidgets() end)
	end)

	f.SuperTrackButton:SetScript("OnEnter", function()
		f.SuperTrackButton:SetAlpha(1)
	end)
	f.SuperTrackButton:SetScript("OnLeave", function()
		if (not f.SuperTracked:IsShown()) then
			f.SuperTrackButton:SetAlpha(.3)
		end
	end)

	f.TomTomTrackerIcon = CreateFrame("button", nil, f) --no need backdrop
	f.TomTomTrackerIcon:SetPoint("right", f.Arrow, "left", -6, 0)
	f.TomTomTrackerIcon:SetSize(24, 24)
	f.TomTomTrackerIcon:SetAlpha(.5)
	f.TomTomTrackerIcon.Icon = f.TomTomTrackerIcon:CreateTexture(nil, "overlay")
	f.TomTomTrackerIcon.Icon:SetAllPoints()
	f.TomTomTrackerIcon.Icon:SetTexture([[Interface\AddOns\TomTom\Images\StaticArrow]])
	f.TomTomTrackerIcon:SetScript("OnClick", function()
		WorldQuestTracker.AddQuestTomTom (f.questID, f.questMapID, true)
		WorldQuestTracker.SetTomTomQuestToTrack(f.questID)
	end)
	f.TomTomTrackerIcon:SetScript("OnEnter", function()
		f.TomTomTrackerIcon:SetAlpha(1)
	end)
	f.TomTomTrackerIcon:SetScript("OnLeave", function()
		f.TomTomTrackerIcon:SetAlpha(.5)
	end)

	------------------------

	f.AnimationFrame = CreateFrame ("frame", "$parentAnimation", f, "BackdropTemplate")
	f.AnimationFrame:SetAllPoints()
	f.AnimationFrame:SetFrameLevel(f:GetFrameLevel()-1)
	f.AnimationFrame:Hide()

	local star = f.AnimationFrame:CreateTexture(nil, "overlay")
	star:SetTexture([[Interface\Cooldown\star4]])
	star:SetSize(168, 168)
	star:SetPoint("center", f.Icon, "center", 1, -1)
	star:SetBlendMode("ADD")
	star:Hide()

	local flash = f.AnimationFrame:CreateTexture(nil, "overlay")
	flash:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Alert-Glow]])
	flash:SetTexCoord(0, 400/512, 0, 170/256)
	flash:SetPoint("topleft", -60, 30)
	flash:SetPoint("bottomright", 40, -30)
	flash:SetBlendMode("ADD")

	local spark = f.AnimationFrame:CreateTexture(nil, "overlay")
	spark:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Alert-Glow]])
	spark:SetTexCoord(400/512, 470/512, 0, 70/256)
	spark:SetSize(50, 34)
	spark:SetBlendMode("ADD")
	spark:SetPoint("left")

	local iconoverlay = f:CreateTexture(nil, "overlay")
	iconoverlay:SetTexture([[Interface\COMMON\StreamBackground]])
	iconoverlay:SetPoint("center", f.Icon, "center", 0, 0)
	iconoverlay:Hide()
	--iconoverlay:SetSize(256, 256)
	iconoverlay:SetDrawLayer("overlay", 7)

	--iconoverlay:SetSize(50, 34)
	--iconoverlay:SetBlendMode("ADD")


	local StarShowAnimation = DF:CreateAnimationHub (star, function() star:Show() end, function() star:Hide() end)
	DF:CreateAnimation (StarShowAnimation, "alpha", 1, .3, 0, .2)
	DF:CreateAnimation (StarShowAnimation, "rotation", 1, .3, 90)
	DF:CreateAnimation (StarShowAnimation, "scale", 1, .3, 0, 0, 1.2, 1.2)
	DF:CreateAnimation (StarShowAnimation, "alpha", 2, .3, .2, 0)
	DF:CreateAnimation (StarShowAnimation, "rotation", 2, .3, .8)
	DF:CreateAnimation (StarShowAnimation, "scale", 1, .3, 1.2, 1.2, 0, 0)

	local FlashAnimation = DF:CreateAnimationHub (flash, function() flash:Show() end, function() flash:Hide() end)
	DF:CreateAnimation (FlashAnimation, "alpha", 1, .05, 0, .3)
	DF:CreateAnimation (FlashAnimation, "alpha", 2, .5, .3, 0)

	local SparkAnimation = DF:CreateAnimationHub (spark, function() spark:Show() end, function() spark:Hide() end)
	DF:CreateAnimation (SparkAnimation, "alpha", 1, .2, 0, .1)
	DF:CreateAnimation (SparkAnimation, "translation", 2, .3, 255, 0)

	local CircleOverlayAnimation = DF:CreateAnimationHub (iconoverlay, function() iconoverlay:Show() end, function() iconoverlay:Hide() end)
	DF:CreateAnimation (CircleOverlayAnimation, "alpha", 1, .05, 0, 1)
	DF:CreateAnimation (CircleOverlayAnimation, "alpha", 2, .5, 1, 0)

	f.AnimationFrame.ShowAnimation = function()
		f.AnimationFrame:Show()
		StarShowAnimation:Play()
		spark:SetPoint("left", -40, 0)
		SparkAnimation:Play()
		FlashAnimation:Play()
		CircleOverlayAnimation:Play()
	end

	------------------------

	TrackerWidgetPool [index] = f
	return f
end

local zoneXLength, zoneYLength = 0, 0
local playerIsMoving = true

function WorldQuestTracker:PLAYER_STARTED_MOVING()
	playerIsMoving = true
end
function WorldQuestTracker:PLAYER_STOPPED_MOVING()
	playerIsMoving = false
end

--making a cooldown to update the player position to avoid creating a table on tick due to C_Map.GetPlayerMapPosition call
local nextPlayerPositionUpdateCooldown = -1
local currentPlayerX = 0
local currentPlayerY = 0

-- ~trackertick ~trackeronupdate ~tick ~onupdate ~ontick �ntick �nupdate
local TrackerOnTick = function(self, deltaTime)
	if (self.NextPositionUpdate < 0) then
		if (Sort_currentMapID ~= WorldQuestTracker.GetCurrentStandingMapAreaID()) then
			self.Arrow:SetAlpha(.3)
			self.Arrow:SetTexture([[Interface\AddOns\WorldQuestTracker\media\ArrowFrozen]])
			self.Arrow:SetTexCoord(0, 1, 0, 1)
			self.ArrowDistance:Hide()
			self.Arrow.Frozen = true
			return
		elseif (self.Arrow.Frozen) then
			self.Arrow:SetTexture([[Interface\AddOns\WorldQuestTracker\media\ArrowGridT]])
			self.ArrowDistance:Show()
			self.Arrow.Frozen = nil
		end
	end

	if (nextPlayerPositionUpdateCooldown < 0) then
		--reset cooldown
		nextPlayerPositionUpdateCooldown = 1

		--update the player position
		local mapPosition = C_Map.GetPlayerMapPosition(WorldQuestTracker.GetCurrentStandingMapAreaID(), "player")
		if (not mapPosition) then
			return
		end
		currentPlayerX, currentPlayerY = mapPosition.x, mapPosition.y
	else
		nextPlayerPositionUpdateCooldown = nextPlayerPositionUpdateCooldown - deltaTime
	end

	if (self.NextArrowUpdate < 0) then
		local questYaw = (FindLookAtRotation (_, currentPlayerX, currentPlayerY, self.questX, self.questY) + p)%pipi
		local playerYaw = GetPlayerFacing() or 0
		local angle = (((questYaw + playerYaw)%pipi)+pi)%pipi
		local imageIndex = 1+(floor (MapRangeClamped (_, 0, pipi, 1, 144, angle)) + 48)%144 --48� quadro � o que aponta para o norte
		local line = ceil (imageIndex / 12)
		local coord = (imageIndex - ((line-1) * 12)) / 12
		self.Arrow:SetTexCoord(coord-0.0833, coord, 0.0833 * (line-1), 0.0833 * line)
		self.ArrowDistance:SetTexCoord(coord-0.0833, coord, 0.0833 * (line-1), 0.0833 * line) -- 0.0763

		self.NextArrowUpdate = ARROW_UPDATE_FREQUENCE
	else
		self.NextArrowUpdate = self.NextArrowUpdate - deltaTime
	end

	self.NextPositionUpdate = self.NextPositionUpdate - deltaTime

	if ((playerIsMoving or self.ForceUpdate) and self.NextPositionUpdate < 0) then
		local distance = GetDistance_Point(_, currentPlayerX, currentPlayerY, self.questX, self.questY)
		--local x = zoneXLength * distance
		--local y = zoneYLength * distance
		--local yards = (x*x + y*y) ^ 0.5

		local dist = CalculateDistance(currentPlayerX, currentPlayerY, self.questX, self.questY)
		local yards = ((zoneXLength*dist) * (zoneYLength*dist)) ^ 0.5
		yards = floor(yards)

		if (yards > 1000) then
			yards = format("%.2f", yards / 1000) .. "km"
		else
			yards = yards .. "yds"
		end
		self.YardsDistance:SetText ("[|cFFC0C0C0" .. yards .. "|r]")

		--super tracked
		--	local worldPinPositionText = SuperTrackedFrame and SuperTrackedFrame.DistanceText:GetText() or ""
		--	print ("------------------")
		--	for key, value in pairs(SuperTrackedFrame) do
		--		print(key, value)
		--	end
		--	print ("------------------")
		--/dump SuperTrackedFrame:SetAlpha(1)

		distance = abs (distance - 1)
		self.info.LastDistance = distance

		distance = Saturate (distance - 0.75) * 4
		local alpha = MapRangeClamped (_, 0, 1, 0, 0.5, distance)
		self.Arrow:SetAlpha(.5 + (alpha))
		self.ArrowDistance:SetVertexColor(distance, distance, distance)

		self.NextPositionUpdate = .5
		self.ForceUpdate = nil

		if (self.HasOverHover) then
			if (IsAltKeyDown()) then
				self.QuestInfomation.text = "ID: " .. self.questID .. "\nMapID: " .. self.info.mapID .. "\nTimeLeft: " .. self.info.timeLeft .. "\nType: " .. self.info.questType .. "\nNumObjetives: " .. self.info.numObjectives
			else
				self.QuestInfomation.text = ""
			end
		end
	end

	self.NextTimeUpdate = self.NextTimeUpdate - deltaTime

	if (self.NextTimeUpdate < 0) then
		if (HaveQuestData (self.questID)) then
			local timeLeft = WorldQuestTracker.GetQuest_TimeLeft (self.questID)
			if (timeLeft and timeLeft > 0) then
				local timeLeft2 =  WorldQuestTracker.GetQuest_TimeLeft (self.questID, true)
				--local str = timeLeft > 1440 and floor (timeLeft/1440) .. "d" or timeLeft > 60 and floor (timeLeft/60) .. "h" or timeLeft .. "m"
				local color = "FFC0C0C0"
				if (timeLeft < 30) then
					color = "FFFF2200"
				elseif (timeLeft < 60) then
					color = "FFFF9900"
				end
				self.TimeLeft:SetText ("[|c" .. color .. timeLeft2 .. "|r]")
			else
				self.TimeLeft:SetText ("[0m]")
			end
		end
		self.NextTimeUpdate = 60
	end

end

local TrackerOnTick_TimeLeft = function(self, deltaTime)
	self.NextTimeUpdate = self.NextTimeUpdate - deltaTime

	if (self.NextTimeUpdate < 0) then
		if (HaveQuestData (self.questID)) then
			local timeLeft = WorldQuestTracker.GetQuest_TimeLeft (self.questID)
			if (timeLeft and timeLeft > 0) then
				local timeLeft2 =  WorldQuestTracker.GetQuest_TimeLeft (self.questID, true)
				--local str = timeLeft > 1440 and floor (timeLeft/1440) .. "d" or timeLeft > 60 and floor (timeLeft/60) .. "h" or timeLeft .. "m"
				local color = "FFC0C0C0"
				if (timeLeft < 30) then
					color = "FFFF2200"
				elseif (timeLeft < 60) then
					color = "FFFF9900"
				end
				self.TimeLeft:SetText ("[|c" .. color .. timeLeft2 .. "|r]")
			else
				self.TimeLeft:SetText ("[0m]")
			end
		end
		self.NextTimeUpdate = 60
	end
end


function WorldQuestTracker.SortTrackerByQuestDistance()
	WorldQuestTracker.ReorderQuestsOnTracker()
	WorldQuestTracker.RefreshTrackerWidgets()
end


--update quests on the quest tracker
function WorldQuestTracker.RefreshTrackerWidgets()
	if (WorldQuestTracker.LastTrackerRefresh and WorldQuestTracker.LastTrackerRefresh+0.2 > GetTime()) then
		return
	end
	WorldQuestTracker.LastTrackerRefresh = GetTime()

	--reorder quests in the tracker
	WorldQuestTracker.ReorderQuestsOnTracker()

	--do the update
	local y = -30
	local nextWidget = 1
	local needSortByDistance = 0
	local onlyCurrentMap = WorldQuestTracker.db.profile.tracker_only_currentmap
	local currentMap = WorldQuestTracker.GetCurrentStandingMapAreaID()

	for index, quest in ipairs (WorldQuestTracker.QuestTrackList) do
		--verifica se a quest esta ativa, ela pode ser desativada se o jogador estiver dentro da area da quest
		if (HaveQuestData(quest.questID)) then
			local title, factionID, tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = WorldQuestTracker.GetQuest_Info(quest.questID)

			--check if the quest has a continent map id and try to cast the continent id to zone id
			if (quest.mapID == WorldQuestTracker.MapData.ZoneIDs.ZANDALAR or quest.mapID == WorldQuestTracker.MapData.ZoneIDs.KULTIRAS) then
				if (WorldQuestTracker.CurrentZoneQuests [quest.questID] and WorldQuestTracker.CurrentZoneQuestsMapID == currentMap) then
					quest.mapID = currentMap
				end
			end

			if (not quest.isDisabled and title and (not onlyCurrentMap or (onlyCurrentMap and Sort_currentMapID == quest.mapID))) then
				local widget = WorldQuestTracker.GetOrCreateTrackerWidget(nextWidget)
				widget:ClearAllPoints()
				widget:SetPoint("topleft", WorldQuestTrackerFrame, "topleft", 0, y)
				widget.questID = quest.questID
				widget.questMapID = quest.mapID
				widget.info = quest
				widget.numObjectives = quest.numObjectives
				widget.SuperTrackButton.questID = quest.questID

				widget.BackgroupTexture:SetVertexColor (0, 0, 0, WorldQuestTracker.db.profile.tracker_background_alpha)

				widget.Title:SetText (title)
				while (widget.Title:GetStringWidth() > TRACKER_TITLE_TEXTWIDTH_MAX) do
					title = strsub (title, 1, #title-1)
					widget.Title:SetText (title)
				end

				local color = OBJECTIVE_TRACKER_COLOR["Header"]
				widget.Title:SetTextColor (color.r, color.g, color.b)

				widget.Zone:SetText ("- " .. WorldQuestTracker.GetZoneName (quest.mapID))
				local color = OBJECTIVE_TRACKER_COLOR["Normal"]
				widget.Zone:SetTextColor (color.r, color.g, color.b)

				widget.Icon:SetTexture(quest.rewardTexture)
				widget.IconButton.questID = quest.questID

				local conduitType = quest.conduitType
				local conduitBorderColor = quest.conduitBorderColor or {1, 1, 1, 1}

				if (conduitType) then
					widget.overlayBorder:Show()
					widget.overlayBorder2:Show()
					widget.overlayBorder:SetVertexColor(unpack(conduitBorderColor))
				else
					widget.overlayBorder:Hide()
					widget.overlayBorder2:Hide()
				end

				if (WorldMap_IsWorldQuestEffectivelyTracked(quest.questID)) then
					widget.SuperTracked:Show() --glow
					widget.SuperTrackButton:SetAlpha(1)
					widget.Circle:SetDesaturated (false)
				else
					widget.SuperTracked:Hide()
					widget.SuperTrackButton:SetAlpha(0.25)
					widget.Circle:SetDesaturated (true)
				end

				if (type (quest.rewardAmount) == "number" and quest.rewardAmount >= 1000) then --erro compare number witrh string
					widget.RewardAmount:SetText (WorldQuestTracker.ToK (quest.rewardAmount))
				else
					widget.RewardAmount:SetText (quest.rewardAmount)
				end

				if (WorldQuestTracker.db.profile.tomtom.enabled) then
					widget.TomTomTrackerIcon:Show()
				else
					widget.TomTomTrackerIcon:Hide()
				end

				widget:Show()

				WorldQuestTracker.db.profile.TutorialTracker = WorldQuestTracker.db.profile.TutorialTracker or 1

				if (WorldQuestTracker.db.profile.TutorialTracker == 1) then
					WorldQuestTracker.db.profile.TutorialTracker = WorldQuestTracker.db.profile.TutorialTracker + 1
				--	local alert = CreateFrame ("frame", "WorldQuestTrackerTrackerTutorialAlert1", worldFramePOIs, "AlertContainerTemplate")
				--	alert:SetFrameLevel(302)
				--	alert.label = "Tracked quests are shown here!"
				--	alert.Text:SetSpacing (4)
				--	alert:SetPoint("bottom", widget, "top", 0, 28)
				--
				--	MicroButtonAlert_SetText (alert, alert.label)
				--	alert:Show()
				end

				if (WorldQuestTracker.JustAddedToTracker [quest.questID]) then
					widget.AnimationFrame.ShowAnimation()
					WorldQuestTracker.JustAddedToTracker [quest.questID] = nil
				end

				if (Sort_currentMapID == quest.mapID) then
					local x, y = C_TaskQuest.GetQuestLocation (quest.questID, quest.mapID)
					widget.questX, widget.questY = x or 0, y or 0

					local HereBeDragons = LibStub ("HereBeDragons-2.0")
					zoneXLength, zoneYLength = HereBeDragons:GetZoneSize (quest.mapID)

					widget.NextPositionUpdate = -1
					widget.NextArrowUpdate = -1
					widget.NextTimeUpdate = -1

					widget.ForceUpdate = true

					widget:SetScript("OnUpdate", TrackerOnTick)
					widget.Arrow:Show()
					widget.ArrowDistance:Show()
					widget.RightBackground:Show()
					widget:SetAlpha(TRACKER_FRAME_ALPHA_INMAP)
					widget.Title.textsize = WorldQuestTracker.db.profile.tracker_textsize --TRACKER_TITLE_TEXT_SIZE_INMAP
					widget.Zone.textsize = WorldQuestTracker.db.profile.tracker_textsize --TRACKER_TITLE_TEXT_SIZE_INMAP
					needSortByDistance = needSortByDistance + 1

					if (WorldQuestTracker.db.profile.show_yards_distance) then
						DF:SetFontSize (widget.TimeLeft, TRACKER_TITLE_TEXT_SIZE_INMAP)
						widget.YardsDistance:Show()
					else
						widget.YardsDistance:Hide()
					end

					if (WorldQuestTracker.db.profile.tracker_show_time) then
						widget.TimeLeft:Show()
					else
						widget.TimeLeft:Hide()
					end
				else
					widget.Arrow:Hide()
					widget.ArrowDistance:Hide()
					widget.RightBackground:Hide()
					widget:SetAlpha(TRACKER_FRAME_ALPHA_OUTMAP)
					widget.Title.textsize = TRACKER_TITLE_TEXT_SIZE_OUTMAP
					widget.Zone.textsize = TRACKER_TITLE_TEXT_SIZE_OUTMAP
					widget.YardsDistance:SetText ("")
					widget:SetScript("OnUpdate", nil)

					if (WorldQuestTracker.db.profile.tracker_show_time) then
						widget.TimeLeft:Show()
						DF:SetFontSize (widget.TimeLeft, TRACKER_TITLE_TEXT_SIZE_OUTMAP)
						widget.NextTimeUpdate = -1
						widget:SetScript("OnUpdate", TrackerOnTick_TimeLeft)
					else
						widget.TimeLeft:Hide()
					end
				end

				y = y - 35
				nextWidget = nextWidget + 1
			end
		end
	end

	if (IsInInstance()) then
		nextWidget = 1
	end

	--se n�o h� nenhuma quest sendo mostrada, hidar o cabe�alho
	if (nextWidget == 1) then
		WorldQuestTrackerHeader:Hide()
		minimizeButton:Hide()
	else
		if (not WorldQuestTrackerFrame.collapsed) then
			WorldQuestTrackerHeader:Show()
		end
		minimizeButton:Show()
		WorldQuestTracker.UpdateTrackerScale()
	end

	if (WorldQuestTracker.SortingQuestByDistance) then
		WorldQuestTracker.SortingQuestByDistance:Cancel()
		WorldQuestTracker.SortingQuestByDistance = nil
	end
	if (needSortByDistance >= 2 and not IsInInstance()) then
		WorldQuestTracker.SortingQuestByDistance = C_Timer.NewTicker (10, WorldQuestTracker.SortTrackerByQuestDistance)
	end

	--esconde os widgets n�o usados
	for i = nextWidget, #TrackerWidgetPool do
		TrackerWidgetPool [i]:SetScript("OnUpdate", nil)
		TrackerWidgetPool [i]:Hide()
	end

	WorldQuestTracker.RefreshTrackerAnchor()
end



local TrackerAnimation_OnAccept = CreateFrame ("frame", nil, UIParent, "BackdropTemplate")
TrackerAnimation_OnAccept:SetSize(235, 30)
TrackerAnimation_OnAccept.Title = DF:CreateLabel (TrackerAnimation_OnAccept)
TrackerAnimation_OnAccept.Title.textsize = TRACKER_TITLE_TEXT_SIZE_INMAP
TrackerAnimation_OnAccept.Title:SetPoint("topleft", TrackerAnimation_OnAccept, "topleft", 10, -1)
local titleColor = OBJECTIVE_TRACKER_COLOR["Header"]
TrackerAnimation_OnAccept.Title:SetTextColor (titleColor.r, titleColor.g, titleColor.b)
TrackerAnimation_OnAccept.Zone = DF:CreateLabel (TrackerAnimation_OnAccept)
TrackerAnimation_OnAccept.Zone.textsize = TRACKER_TITLE_TEXT_SIZE_INMAP
TrackerAnimation_OnAccept.Zone:SetPoint("topleft", TrackerAnimation_OnAccept, "topleft", 10, -17)
TrackerAnimation_OnAccept.Icon = TrackerAnimation_OnAccept:CreateTexture(nil, "artwork")
TrackerAnimation_OnAccept.Icon:SetPoint("topleft", TrackerAnimation_OnAccept, "topleft", -13, -2)
TrackerAnimation_OnAccept.Icon:SetSize(16, 16)
TrackerAnimation_OnAccept.RewardAmount = TrackerAnimation_OnAccept:CreateFontString (nil, "overlay", "ObjectiveFont")
TrackerAnimation_OnAccept.RewardAmount:SetTextColor (titleColor.r, titleColor.g, titleColor.b)
TrackerAnimation_OnAccept.RewardAmount:SetPoint("top", TrackerAnimation_OnAccept.Icon, "bottom", 0, -2)
DF:SetFontSize (TrackerAnimation_OnAccept.RewardAmount, 10)
TrackerAnimation_OnAccept:Hide()

TrackerAnimation_OnAccept.FlashTexture = TrackerAnimation_OnAccept:CreateTexture(nil, "background")
TrackerAnimation_OnAccept.FlashTexture:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Alert-Glow]])
TrackerAnimation_OnAccept.FlashTexture:SetTexCoord(0, 400/512, 0, 168/256)
TrackerAnimation_OnAccept.FlashTexture:SetBlendMode("ADD")
TrackerAnimation_OnAccept.FlashTexture:SetPoint("topleft", -60, 40)
TrackerAnimation_OnAccept.FlashTexture:SetPoint("bottomright", 40, -35)

local TrackerAnimation_OnAccept_MoveAnimation = DF:CreateAnimationHub (TrackerAnimation_OnAccept, function (self)
	-- 3 movement started
		--seta textos e texturas
		local quest = self.QuestObject
		local widget = self.WidgetObject
		TrackerAnimation_OnAccept.Title.text = widget.Title.text
		TrackerAnimation_OnAccept.Zone.text = widget.Zone.text
		if (quest.questType == QUESTTYPE_ARTIFACTPOWER) then
			TrackerAnimation_OnAccept.Icon:SetMask (nil)
		else
			TrackerAnimation_OnAccept.Icon:SetMask ([[Interface\CharacterFrame\TempPortraitAlphaMask]])
		end
		TrackerAnimation_OnAccept.Icon:SetTexture(quest.rewardTexture)
		TrackerAnimation_OnAccept.RewardAmount:SetText (widget.RewardAmount:GetText())
	end,
	function (self)
	-- 4 movement end
		TrackerAnimation_OnAccept:Hide()
	end)
local ScreenWidth = -(floor (GetScreenWidth() / 2) - 200)
TrackerAnimation_OnAccept_MoveAnimation.Translation = DF:CreateAnimation (TrackerAnimation_OnAccept_MoveAnimation, "translation", 1, 2, ScreenWidth, 270)
DF:CreateAnimation (TrackerAnimation_OnAccept_MoveAnimation, "alpha", 1, 1.6, 1, 0)
--DF:CreateAnimation (TrackerAnimation_OnAccept_MoveAnimation, "scale", 1, 1.6, 1, 1, 0, 0)

local TrackerAnimation_OnAccept_FlashAnimation = DF:CreateAnimationHub (TrackerAnimation_OnAccept.FlashTexture,
	function (self)
		-- 1 Playing Flash
		TrackerAnimation_OnAccept.Title.text = ""
		TrackerAnimation_OnAccept.Zone.text = ""
		TrackerAnimation_OnAccept.Icon:SetTexture(nil)
		TrackerAnimation_OnAccept.RewardAmount:SetText ("")
		TrackerAnimation_OnAccept:Show()
		TrackerAnimation_OnAccept.FlashTexture:Show()
		TrackerAnimation_OnAccept:SetPoint("topleft", self.WidgetObject, "topleft", 0, 0)
	end,
	function (self)
		-- 2 Flash Finished
		local quest = self.QuestObject
		local widget = self.WidgetObject

		self.QuestObject.isDisabled = true
		self.QuestObject.enteringZone = nil

		local top = widget:GetTop()
		local distance = GetScreenHeight() - top - 150
		TrackerAnimation_OnAccept_MoveAnimation.Translation:SetOffset (ScreenWidth, distance)
		TrackerAnimation_OnAccept_MoveAnimation:Play()

		TrackerAnimation_OnAccept.FlashTexture:Hide()
		WorldQuestTracker.UpdateQuestsInArea()
	end)
DF:CreateAnimation (TrackerAnimation_OnAccept_FlashAnimation, "alpha", 1, 0.15, 0, .68)
DF:CreateAnimation (TrackerAnimation_OnAccept_FlashAnimation, "scale", 1, 0.1, .1, .1, 1, 1, "center")
DF:CreateAnimation (TrackerAnimation_OnAccept_FlashAnimation, "alpha", 2, 0.15, .68, 0)

local get_widget_from_questID = function(questID)
	for i = 1, #TrackerWidgetPool do
		if (TrackerWidgetPool[i].questID == questID) then
			return TrackerWidgetPool[i]
		end
	end
end

--quando o tracker da interface atualizar, atualizar tbm o nosso tracker
--verifica se o jogador esta na area da quest
function WorldQuestTracker.UpdateQuestsInArea()
	for index, quest in ipairs (WorldQuestTracker.QuestTrackList) do
		if (HaveQuestData (quest.questID)) then
			--local questIndex = C_QuestLog.GetQuestLogIndexByID (quest.questID)
			if (isInArea) then --(questIndex and questIndex ~= 0) or
				--desativa pois o jogo ja deve estar mostrando a quest
				if (not quest.isDisabled and not quest.enteringZone) then
					local widget = get_widget_from_questID (quest.questID)
					if (widget and not WorldQuestTracker.IsQuestOnObjectiveTracker (widget.Title:GetText())) then
						--acabou de aceitar a quest
						quest.enteringZone = true
						TrackerAnimation_OnAccept:Show()
						TrackerAnimation_OnAccept_MoveAnimation.QuestObject = quest
						TrackerAnimation_OnAccept_FlashAnimation.QuestObject = quest

						TrackerAnimation_OnAccept_MoveAnimation.WidgetObject = widget
						TrackerAnimation_OnAccept_FlashAnimation.WidgetObject = widget

						TrackerAnimation_OnAccept_FlashAnimation:Play()
					else
						quest.isDisabled = true
					end
				end
				--quest.isDisabled = true
			else
				quest.isDisabled = nil
			end
		end
	end
	WorldQuestTracker.RefreshTrackerWidgets()
end


-- ~blizzard objective tracker
function WorldQuestTracker.IsQuestOnObjectiveTracker (quest)
	local tracker = ObjectiveTrackerFrame

	if (not tracker.initialized) then
		return
	end

	local CheckByType = type (quest)

	for i = 1, #tracker.MODULES do
		local module = tracker.MODULES [i]
		for blockName, usedBlock in pairs (module.usedBlocks) do

			local questID = usedBlock.id
			if (questID) then
				if (CheckByType == "string") then
					if (HaveQuestData (questID)) then
						local thisQuestName = GetQuestInfoByQuestID (questID)
						if (thisQuestName and thisQuestName == quest) then
							return true
						end
					end
				elseif (CheckByType == "number") then
					if (quest == questID) then
						return true
					end
				end
			end
		end
	end
end

local latestTrackerPositionUpdate = GetTime()
local bHasScheduledSizeUpdate = false

local onObjectiveTrackerChanges = function() --this will be called several times in a single frame
	if (ObjectiveTrackerFrame:IsCollapsed()) then
		return
	end

	local objectiveTrackerHeight = 0
    for moduleFrame in pairs (ObjectiveTrackerManager.moduleToContainerMap) do
		if (type(moduleFrame) == "table" and moduleFrame.GetObjectType and moduleFrame:GetObjectType() == "Frame" and moduleFrame:IsShown()) then
        	objectiveTrackerHeight = objectiveTrackerHeight + moduleFrame:GetHeight()
		end
    end
	WorldQuestTracker.TrackerHeight = objectiveTrackerHeight + 50

	WorldQuestTracker.RefreshTrackerAnchor()

	--need to refresh again on next tick due to some modules being updated after the tracker
	if (not bHasScheduledSizeUpdate) then
		C_Timer.After(0, WorldQuestTracker.OnObjectiveTrackerChanges)
		bHasScheduledSizeUpdate = true
	end
end

function WorldQuestTracker.OnObjectiveTrackerChanges()
	--check the time to make sure only one update is triggered
	if (GetTime() == latestTrackerPositionUpdate) then
		return
	end

	latestTrackerPositionUpdate = GetTime()
	onObjectiveTrackerChanges()
	bHasScheduledSizeUpdate = false
end

if (ObjectiveTrackerManager) then
	hooksecurefunc(ObjectiveTrackerManager, "ReleaseFrame", onObjectiveTrackerChanges)
	hooksecurefunc(ObjectiveTrackerManager, "AcquireFrame", onObjectiveTrackerChanges)

	ObjectiveTrackerFrame.Header.MinimizeButton:HookScript("OnClick", function()
		if (ObjectiveTrackerFrame:IsCollapsed()) then
			WorldQuestTracker.TrackerHeight = 35
			WorldQuestTracker.RefreshTrackerAnchor()
		end
	end)
else
	C_Timer.After(0, function()
		hooksecurefunc(ObjectiveTrackerManager, "ReleaseFrame", onObjectiveTrackerChanges)
		hooksecurefunc(ObjectiveTrackerManager, "AcquireFrame", onObjectiveTrackerChanges)
	end)
end

--ao completar uma world quest remover a quest do tracker e da refresh nos widgets
hooksecurefunc(BonusObjectiveTracker, "OnQuestTurnedIn", function(self, questID)
	for i = #WorldQuestTracker.QuestTrackList, 1, -1 do
		if (WorldQuestTracker.QuestTrackList[i].questID == questID) then
			local questRemoved = tremove(WorldQuestTracker.QuestTrackList, i)
			WorldQuestTracker.RefreshTrackerWidgets()
			onObjectiveTrackerChanges()
			break
		end
	end
end)

local questEventFrame = CreateFrame("frame")
questEventFrame:RegisterEvent("QUEST_TURNED_IN")
questEventFrame:SetScript("OnEvent", function(self, event, ...)
	C_Timer.After(0, onObjectiveTrackerChanges)
end)

hooksecurefunc(C_SuperTrack, "SetSuperTrackedQuestID", function()
	C_Timer.After(0, onObjectiveTrackerChanges)
end)

hooksecurefunc(QuestUtil, "TrackWorldQuest", function()
	C_Timer.After(0, onObjectiveTrackerChanges)
end)

hooksecurefunc(QuestUtil, "UntrackWorldQuest", function()
	C_Timer.After(0, onObjectiveTrackerChanges)
end)




--[=[
	["1"] = "ReleaseFrame",
	["2"] = "ShowRewardsToast",
	["3"] = "AddContainer",
	["4"] = "OnVariablesLoaded",
	["5"] = "HideRewardsToast",
	["6"] = "HasRewardsToastForBlock",
	["7"] = "UpdateModule",
	["8"] = "SetTextSize",
	["9"] = "OnCVarChanged",
	["10"] = "UpdateAll",
	["11"] = "UpdatePOIEnabled",
	["12"] = "AssignModulesOrder",
	["13"] = "OnPlayerEnteringWorld",
	["14"] = "GetContainerForModule",
	["15"] = "CanShowPOIs",
	["16"] = "SetModuleContainer",
	["17"] = "AcquireFrame",
	["18"] = "SetOpacity",
--]=]



local bHooked = false
--dispara quando o tracker da interface � atualizado, precisa dar refresh na nossa ancora
local On_ObjectiveTracker_Update = function()
	local blizzObjectiveTracker = ObjectiveTrackerFrame
	if (not blizzObjectiveTracker.init) then
		return
	end

	WorldQuestTracker.UpdateQuestsInArea()

	if (not bHooked) then
		bHooked = true
	end

	WorldQuestTracker.RefreshTrackerAnchor()

	--[=[]] v7 up to v10
		WorldQuestTracker.TrackerAttachToModule = nil

		if (blizzObjectiveTracker.collapsed) then
			WorldQuestTracker.TrackerHeight = 20
		else
			for moduleId = #blizzObjectiveTracker.MODULES_UI_ORDER, 1, -1 do
				local module = blizzObjectiveTracker.MODULES_UI_ORDER[moduleId]
				if (module.Header:IsShown()) then
					WorldQuestTracker.TrackerAttachToModule = module
					--for k,v in pairs(module) do
					--	print(k)
					--end
					WorldQuestTracker.TrackerHeight = module.contentsHeight
					break
				end
			end
		end
	--]=]
	--update world quest tracker anchor
	--WorldQuestTracker.RefreshTrackerAnchor()
	
end

--quando houver uma atualiza��o no quest tracker, atualizar as ancoras do nosso tracker
--hooksecurefunc ("ObjectiveTracker_Update", function (reason, id) --v10
--	On_ObjectiveTracker_Update()
--end)

hooksecurefunc(ObjectiveTrackerManager, "UpdateAll", function()
	On_ObjectiveTracker_Update() --v11
end)
hooksecurefunc(ObjectiveTrackerManager, "UpdateModule", function()
	On_ObjectiveTracker_Update() --v11
end)

ObjectiveTrackerFrame.Header.MinimizeButton:HookScript("OnClick", function() --v11
	On_ObjectiveTracker_Update()
end)
--quando o jogador clicar no bot�o de minizar o quest tracker, atualizar as ancores do nosso tracker
--ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript ("OnClick", function() --v10
--	On_ObjectiveTracker_Update()
--end)

function WorldQuestTracker:FullTrackerUpdate()
	On_ObjectiveTracker_Update()
end





