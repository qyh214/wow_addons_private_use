---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.ContextIcon; addon.ContextIcon = NS

--------------------------------

NS.Script = {}

--------------------------------

local function MissingAPI()
	return false
end

local function ReadyForTurnInMakeshiftAPI(questID)
	local result = false

	--------------------------------

	if (addon.C.Variables.IS_WOW_VERSION_RETAIL and C_QuestLog.IsQuestComplete(questID)) or (not addon.C.Variables.IS_WOW_VERSION_RETAIL and IsQuestComplete(questID)) then
		result = true
	else
		if QuestFrameCompleteQuestButton:IsVisible() or QuestFrameCompleteButton:IsVisible() and QuestFrameCompleteButton:IsEnabled() then
			result = true
		end
	end

	--------------------------------

	return result
end

local IsOnQuest = C_QuestLog.IsOnQuest or MissingAPI
local IsReadyForTurnIn = C_QuestLog.ReadyForTurnIn or ReadyForTurnInMakeshiftAPI or MissingAPI
local IsAutoAccept = addon.C.API.Util.IsAutoAccept

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS
	--------------------------------

	do
		do -- UTILITIES
			function Callback:ConvertToInlineIcon(name, isTexture)
				local iconPath = isTexture and name or (NS.Variables.PATH .. name .. ".png")
				return addon.C.API.Util:InlineIcon(iconPath, 16, 16, 0, 0)
			end
		end

		do -- REPLACEMENT
			function Callback:ReplaceIcon(texture)
				local result = texture

				--------------------------------

				for k, v in pairs(NS.Variables.ICON_MAP) do
					if tostring(texture) == tostring(k) then
						result = NS.Variables.PATH .. v .. ".png"
					end
				end

				--------------------------------

				return result
			end

			function Callback:ChangeIcon(texture)
				return Callback:ReplaceIcon(texture)
			end
		end

		do -- GET
			function Callback:GetQuestInfo(questID, gossipButtonInfo)
				local results = {}

				--------------------------------

				if addon.C.Variables.IS_WOW_VERSION_RETAIL then
					local questClassification = C_QuestInfoSystem.GetQuestClassification(questID)
					local questType = C_QuestLog.GetQuestType(questID)

					-- QUEST CLASSIFICATION
					local isAvailable = (QuestFrameAcceptButton:IsVisible() or IsAutoAccept())
					local isCompleted = (IsReadyForTurnIn(questID)) and not isAvailable
					local isOnQuest = (C_QuestLog.IsOnQuest(questID) and not isAvailable)
					local isDefault = (questClassification == Enum.QuestClassification.Normal)
					local isImportant = (questClassification == Enum.QuestClassification.Important)
					local isCampaign = (questClassification == Enum.QuestClassification.Campaign)
					local isCalling = (questClassification == Enum.QuestClassification.Calling)
					local isMeta = (questClassification == Enum.QuestClassification.Meta)
					local isRecurring = (questClassification == Enum.QuestClassification.Recurring)
					local isRepeatable = (C_QuestLog.IsQuestRepeatableType(questID))

					-- QUEST TYPE
					local isAccount = (questType == Enum.QuestTag.Account)
					local isCombatAlly = (questType == Enum.QuestTag.CombatAlly)
					local isDelve = (questType == Enum.QuestTag.Delve)
					local isDungeon = (questType == Enum.QuestTag.Dungeon)
					local isGroup = (questType == Enum.QuestTag.Group)
					local isHeroic = (questType == Enum.QuestTag.Heroic)
					local isLegendary = (questClassification == Enum.QuestClassification.Legendary or questType == Enum.QuestTag.Legendary)
					local isArtifact = (questType == 107) -- Artifact
					local isPvP = (questType == Enum.QuestTag.PvP)
					local isRaid = (questType == Enum.QuestTag.Raid)
					local isRaid10 = (questType == Enum.QuestTag.Raid10)
					local isRaid25 = (questType == Enum.QuestTag.Raid25)
					local isScenario = (questType == Enum.QuestTag.Scenario)

					results = {
						isAvailable = isAvailable,
						isCompleted = isCompleted,
						isOnQuest = isOnQuest,
						isDefault = isDefault,
						isImportant = isImportant,
						isCampaign = isCampaign,
						isCalling = isCalling,
						isMeta = isMeta,
						isRecurring = isRecurring,
						isRepeatable = isRepeatable,
						isAccount = isAccount,
						isCombatAlly = isCombatAlly,
						isDelve = isDelve,
						isDungeon = isDungeon,
						isGroup = isGroup,
						isHeroic = isHeroic,
						isLegendary = isLegendary,
						isArtifact = isArtifact,
						isPvP = isPvP,
						isRaid = isRaid,
						isRaid10 = isRaid10,
						isRaid25 = isRaid25,
						isScenario = isScenario,
					}
				elseif addon.C.Variables.IS_WOW_VERSION_CLASSIC_ALL then
					local results = {}
					local questInfo = {}

					--------------------------------

					if gossipButtonInfo then
						-- FILL DATA
						--------------------------------
						questInfo.title,
						questInfo.level,
						questInfo.suggestedGroup,
						questInfo.isHeader,
						questInfo.isCollapsed,
						questInfo.isComplete,
						questInfo.frequency,
						questInfo.questID,
						questInfo.startEvent,
						questInfo.displayQuestID,
						questInfo.isOnMap,
						questInfo.hasLocalPOI,
						questInfo.isTask,
						questInfo.isBounty,
						questInfo.isStory,
						questInfo.isHidden,
						questInfo.isScaling = GetQuestLogTitle(GetQuestLogIndexByID(questID))

						-- QUERY MISSING REFERENCES
						--------------------------------
						questInfo.isComplete = (gossipButtonInfo.isComplete or questInfo.isComplete)
						questInfo.isOnQuest = (gossipButtonInfo.isOnQuest or false)
					else
						-- FILL DATA
						--------------------------------
						questInfo.title,
						questInfo.level,
						questInfo.suggestedGroup,
						questInfo.isHeader,
						questInfo.isCollapsed,
						questInfo.isComplete,
						questInfo.frequency,
						questInfo.questID,
						questInfo.startEvent,
						questInfo.displayQuestID,
						questInfo.isOnMap,
						questInfo.hasLocalPOI,
						questInfo.isTask,
						questInfo.isBounty,
						questInfo.isStory,
						questInfo.isHidden,
						questInfo.isScaling = GetQuestLogTitle(GetQuestLogIndexByID(questID))

						-- QUERY MISSING REFERENCES
						--------------------------------
						if questInfo.isOnQuest == nil then
							questInfo.isOnQuest = (IsOnQuest and IsOnQuest(questID)) or false
						end

						if questInfo.frequency == nil then
							questInfo.frequency = 0
						end

						if not questInfo.isComplete then
							questInfo.isComplete = (IsReadyForTurnIn and IsReadyForTurnIn(questID)) or false
						end

						if QuestFrameAcceptButton:IsVisible() then
							questInfo.isComplete = false
						end
					end

					--------------------------------

					local FREQUENCY_DEFAULT = 1
					local FREQUENCY_DAILY = 2
					local FREQUENCY_WEEKLY = 3

					local QuestType = GetQuestTagInfo(questID)

					local isAvailable = (QuestFrameAcceptButton:IsVisible() or IsAutoAccept())
					local isCompleted = (((questInfo.isComplete) or (IsReadyForTurnIn and IsReadyForTurnIn(questID))) and not isAvailable)
					local isOnQuest = (((questInfo.isOnQuest) or (IsOnQuest and IsOnQuest(questID)) or questInfo.missingQuestID) and not isAvailable)
					-- local isRecurring = (questInfo.frequency > FREQUENCY_DEFAULT)
					local isRecurring = false -- Classic frequency is inaccurate when using GetQuestLogTitle info...
					local isDefault = (not isRecurring)

					local isGroup = (QuestType == 1)
					local isPvP = (QuestType == 41)
					local isRaid = (QuestType == 62)
					local isDungeon = (QuestType == 81)
					local isLegendary = (QuestType == 83)
					local isHeroic = (QuestType == 85)
					local isScenario = (QuestType == 98)
					local isAccount = (QuestType == 102)
					local isLeatherworkingWorldQuest = (QuestType == 117)

					--------------------------------

					results = {
						isAvailable = isAvailable,
						isCompleted = isCompleted,
						isOnQuest = isOnQuest,
						isRecurring = isRecurring,
						isDefault = isDefault,
						isGroup = isGroup,
						isPvP = isPvP,
						isRaid = isRaid,
						isDungeon = isDungeon,
						isLegendary = isLegendary,
						isHeroic = isHeroic,
						isScenario = isScenario,
						isAccount = isAccount,
						isLeatherworkingWorldQuest = isLeatherworkingWorldQuest,
					}

					--------------------------------

					return results
				end

				--------------------------------

				return results
			end

			function Callback:GetQuestIconFromInfo(data)
				local isCompleted, isOnQuest, isDefault, isImportant, isCampaign, isLegendary, isArtifact, isCalling, isMeta, isRecurring, isRepeatable = data.isCompleted, data.isOnQuest, data.isDefault, data.isImportant, data.isCampaign, data.isLegendary, data.isArtifact, data.isCalling, data.isMeta, data.isRecurring, data.isRepeatable
				local result = nil

				--------------------------------

				if isCompleted then
					if isDefault then
						result = "quest-complete"
					elseif isImportant then
						result = "quest-important-complete"
					elseif isCampaign then
						result = "quest-campaign-complete"
					elseif isLegendary then
						result = "quest-legendary-complete"
					elseif isArtifact then
						result = "quest-artifact-complete"
					elseif isCalling then
						result = "quest-campaign-recurring-complete"
					elseif isMeta then
						result = "quest-meta-complete"
					elseif isRecurring then
						result = "quest-recurring-complete"
					elseif isRepeatable then
						result = "quest-repeatable-complete"
					end
				elseif isOnQuest then
					if isDefault then
						result = "quest-active"
					elseif isImportant then
						result = "quest-important-active"
					elseif isCampaign then
						result = "quest-campaign-active"
					elseif isLegendary then
						result = "quest-legendary-active"
					elseif isArtifact then
						result = "quest-artifact-active"
					elseif isCalling then
						result = "quest-campaign-recurring-active"
					elseif isMeta then
						result = "quest-meta-active"
					elseif isRecurring then
						result = "quest-recurring-active"
					elseif isRepeatable then
						result = "quest-repeatable-active"
					end
				else
					if isDefault then
						result = "quest-available"
					elseif isImportant then
						result = "quest-important-available"
					elseif isCampaign then
						result = "quest-campaign-available"
					elseif isLegendary then
						result = "quest-legendary-available"
					elseif isArtifact then
						result = "quest-artifact-available"
					elseif isCalling then
						result = "quest-campaign-recurring-available"
					elseif isMeta then
						result = "quest-meta-available"
					elseif isRecurring then
						result = "quest-recurring-available"
					elseif isRepeatable then
						result = "quest-repeatable-available"
					end
				end

				--------------------------------

				return result
			end

			function Callback:GetContextIcon(gossipButtonInfo, gossipButtonOptionTexture, customQuestID)
				local isGossip = (GossipFrame:IsVisible() or QuestFrameGreetingPanel:IsVisible())
				local isQuest = ((QuestFrame:IsVisible() and not QuestFrameGreetingPanel:IsVisible()) or (customQuestID ~= nil))

				local queryQuest = (gossipButtonInfo ~= nil or isQuest)
				local queryGossip = (not queryQuest)

				--------------------------------

				local resultString
				local resultTexture

				--------------------------------

				do -- RETAIL
					if addon.C.Variables.IS_WOW_VERSION_RETAIL then
						local resultPath

						--------------------------------

						if queryQuest then
							local questID

							--------------------------------

							if gossipButtonInfo then
								questID = gossipButtonInfo.questID or nil
							else
								questID = customQuestID or GetQuestID()
							end

							--------------------------------

							if questID then
								local questInfo = Callback:GetQuestInfo(questID)
								local isAvailable, isCompleted, isOnQuest, isDefault, isImportant,
								isCampaign, isCalling, isMeta, isRecurring, isRepeatable, isAccount,
								isCombatAlly, isDelve, isDungeon, isGroup, isHeroic, isLegendary, isArtifact,
								isPvP, isRaid, isRaid10, isRaid25, isScenario =
									questInfo.isAvailable, questInfo.isCompleted, questInfo.isOnQuest, questInfo.isDefault, questInfo.isImportant,
									questInfo.isCampaign, questInfo.isCalling, questInfo.isMeta, questInfo.isRecurring, questInfo.isRepeatable, questInfo.isAccount,
									questInfo.isCombatAlly, questInfo.isDelve, questInfo.isDungeon, questInfo.isGroup, questInfo.isHeroic, questInfo.isLegendary, questInfo.isArtifact,
									questInfo.isPvP, questInfo.isRaid, questInfo.isRaid10, questInfo.isRaid25, questInfo.isScenario

								--------------------------------

								resultPath = Callback:GetQuestIconFromInfo({
									isCompleted = isCompleted,
									isOnQuest = isOnQuest,
									isDefault = isDefault,
									isImportant = isImportant,
									isCampaign = isCampaign,
									isLegendary = isLegendary,
									isArtifact = isArtifact,
									isCalling = isCalling,
									isMeta = isMeta,
									isRecurring = isRecurring,
									isRepeatable = isRepeatable,
								})
							else
								if gossipButtonOptionTexture then
									local new = Callback:ReplaceIcon(gossipButtonOptionTexture)
									resultPath = nil
									resultTexture = new
								end
							end

							--------------------------------

							if resultPath and not resultTexture then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end

						if queryGossip then
							resultPath = "gossip-bubble"

							--------------------------------

							if resultPath then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end
					end
				end

				do -- CLASSIC CATA
					if addon.C.Variables.IS_WOW_VERSION_CLASSIC_PROGRESSION then
						local resultPath

						--------------------------------

						if queryQuest then
							local questID; if gossipButtonInfo then questID = gossipButtonInfo.questID or nil else questID = GetQuestID() end

							--------------------------------

							if questID then
								local questInfo = Callback:GetQuestInfo(questID, gossipButtonInfo)
								local isAvailable, isCompleted, isOnQuest, isDefault,
								isRecurring, isGroup, isPvP, isRaid, isDungeon, isLegendary,
								isHeroic, isScenario, isAccount, isLeatherworkingWorldQuest =
									questInfo.isAvailable, questInfo.isCompleted, questInfo.isOnQuest, questInfo.isDefault,
									questInfo.isRecurring, questInfo.isGroup, questInfo.isPvP, questInfo.isRaid, questInfo.isDungeon, questInfo.isLegendary,
									questInfo.isHeroic, questInfo.isScenario, questInfo.isAccount, questInfo.isLeatherworkingWorldQuest

								--------------------------------

								resultPath = Callback:GetQuestIconFromInfo({
									isCompleted = isCompleted,
									isOnQuest = isOnQuest,
									isDefault = isDefault,
									isRecurring = isRecurring,
								})
							else
								if gossipButtonOptionTexture then
									local new = Callback:ReplaceIcon(gossipButtonOptionTexture)
									resultPath = nil
									resultTexture = new
								end
							end

							--------------------------------

							if resultPath and not resultTexture then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end

						if queryGossip then
							resultPath = "gossip-bubble"

							--------------------------------

							if resultPath then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end
					end
				end

				do -- CLASSIC ERA
					if addon.C.Variables.IS_WOW_VERSION_CLASSIC_ERA then
						local resultPath

						--------------------------------

						if queryQuest then
							local questID; if gossipButtonInfo then questID = gossipButtonInfo.questID or nil else questID = GetQuestID() end

							--------------------------------

							if questID then
								local questInfo = Callback:GetQuestInfo(questID, gossipButtonInfo)
								local isAvailable, isCompleted, isOnQuest, isDefault,
								isRecurring, isGroup, isPvP, isRaid, isDungeon, isLegendary,
								isHeroic, isScenario, isAccount, isLeatherworkingWorldQuest =
									questInfo.isAvailable, questInfo.isCompleted, questInfo.isOnQuest, questInfo.isDefault,
									questInfo.isRecurring, questInfo.isGroup, questInfo.isPvP, questInfo.isRaid, questInfo.isDungeon, questInfo.isLegendary,
									questInfo.isHeroic, questInfo.isScenario, questInfo.isAccount, questInfo.isLeatherworkingWorldQuest

								--------------------------------

								resultPath = Callback:GetQuestIconFromInfo({
									isCompleted = isCompleted,
									isOnQuest = isOnQuest,
									isDefault = isDefault,
									isRecurring = isRecurring,
								})
							else
								if gossipButtonOptionTexture then
									local new = Callback:ReplaceIcon(gossipButtonOptionTexture)
									resultPath = nil
									resultTexture = new
								end
							end

							--------------------------------

							if resultPath and not resultTexture then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end

						if queryGossip then
							resultPath = "gossip-bubble"

							--------------------------------

							if resultPath then
								resultString = Callback:ConvertToInlineIcon(resultPath)
								resultTexture = NS.Variables.PATH .. resultPath .. ".png"
							end
						end
					end
				end

				--------------------------------

				return resultString, resultTexture
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do

	end

	--------------------------------
	-- SETUP
	--------------------------------

	do

	end
end
