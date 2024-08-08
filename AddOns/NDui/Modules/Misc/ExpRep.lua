local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

--[[
	一个工具条用来替代系统的经验条、声望条、神器经验等等
]]
local format, pairs, select = string.format, pairs, select
local min, mod, floor = math.min, mod, math.floor
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local REPUTATION_PROGRESS_FORMAT = REPUTATION_PROGRESS_FORMAT
local HONOR, LEVEL, TUTORIAL_TITLE26, SPELLBOOK_AVAILABLE_AT = HONOR, LEVEL, TUTORIAL_TITLE26, SPELLBOOK_AVAILABLE_AT
local ARTIFACT_POWER, ARTIFACT_RETIRED = ARTIFACT_POWER, ARTIFACT_RETIRED

local UnitLevel, UnitXP, UnitXPMax, GetXPExhaustion, IsXPUserDisabled = UnitLevel, UnitXP, UnitXPMax, GetXPExhaustion, IsXPUserDisabled
local BreakUpLargeNumbers, GetNumFactions, GetFactionInfo = BreakUpLargeNumbers, GetNumFactions, GetFactionInfo
local HasArtifactEquipped, ArtifactBarGetNumArtifactTraitsPurchasableFromXP = HasArtifactEquipped, ArtifactBarGetNumArtifactTraitsPurchasableFromXP
local IsWatchingHonorAsXP, UnitHonor, UnitHonorMax, UnitHonorLevel = IsWatchingHonorAsXP, UnitHonor, UnitHonorMax, UnitHonorLevel
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_ArtifactUI_IsEquippedArtifactDisabled = C_ArtifactUI.IsEquippedArtifactDisabled
local C_ArtifactUI_GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local C_GossipInfo_GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks

local function IsAzeriteAvailable()
	local itemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	return itemLocation and itemLocation:IsEquipmentSlot() and not C_AzeriteItem_IsAzeriteItemAtMaxLevel()
end

function M:ExpBar_Update()
	local rest = self.restBar
	if rest then rest:Hide() end

	local factionData = C_Reputation.GetWatchedFactionData()

	if not IsPlayerAtEffectiveMaxLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self:SetStatusBarColor(0, .7, 1)
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:Show()
		if rxp then
			rest:SetMinMaxValues(0, mxp)
			rest:SetValue(min(xp + rxp, mxp))
			rest:Show()
		end
		if IsXPUserDisabled() then self:SetStatusBarColor(.7, 0, 0) end
	elseif factionData then
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		if factionID and C_Reputation_IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			value = majorFactionData.renownReputationEarned or 0
			barMin, barMax = 0, majorFactionData.renownLevelThreshold
		else
			local repInfo = C_GossipInfo_GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			if C_Reputation_IsFactionParagon(factionID) then
				local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
				currentValue = mod(currentValue, threshold)
				barMin, barMax, value = 0, threshold, currentValue
			elseif friendID and friendID ~= 0 then
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMin, barMax, value = 0, 1, 1
				end
				standing = 5
			else
				if standing == MAX_REPUTATION_REACTION then barMin, barMax, value = 0, 1, 1 end
			end
		end
		local color = FACTION_BAR_COLORS[standing] or FACTION_BAR_COLORS[5]
		self:SetStatusBarColor(color.r, color.g, color.b, .85)
		self:SetMinMaxValues(barMin, barMax)
		self:SetValue(value)
		self:Show()
	elseif IsWatchingHonorAsXP() then
		local current, barMax = UnitHonor("player"), UnitHonorMax("player")
		self:SetStatusBarColor(1, .24, 0)
		self:SetMinMaxValues(0, barMax)
		self:SetValue(current)
		self:Show()
	elseif IsAzeriteAvailable() then
		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		self:SetStatusBarColor(.9, .8, .6)
		self:SetMinMaxValues(0, totalLevelXP)
		self:SetValue(xp)
		self:Show()
	elseif HasArtifactEquipped() then
		if C_ArtifactUI_IsEquippedArtifactDisabled() then
			self:SetStatusBarColor(.6, .6, .6)
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)
		else
			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
			local _, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
			xp = xpForNextPoint == 0 and 0 or xp
			self:SetStatusBarColor(.9, .8, .6)
			self:SetMinMaxValues(0, xpForNextPoint)
			self:SetValue(xp)
		end
		self:Show()
	else
		self:Hide()
	end
end

function M:ExpBar_UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)

	if not IsPlayerAtEffectiveMaxLevel() then
		GameTooltip:AddLine(" ")
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddDoubleLine(XP..":", BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(mxp).." ("..format("%.1f%%)", xp/mxp*100), .6,.8,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", "+"..BreakUpLargeNumbers(rxp).." ("..format("%.1f%%)", rxp/mxp*100), .6,.8,1, 1,1,1)
		end
		if IsXPUserDisabled() then GameTooltip:AddLine("|cffff0000"..XP..LOCKED) end
	end

	local factionData = C_Reputation.GetWatchedFactionData()
	if factionData then
		local name = factionData.name
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		local standingtext
		if factionID and C_Reputation_IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			name = majorFactionData.name
			value = majorFactionData.renownReputationEarned or 0
			barMin, barMax = 0, majorFactionData.renownLevelThreshold
			standingtext = RENOWN_LEVEL_LABEL..majorFactionData.renownLevel
		else
			local repInfo = C_GossipInfo_GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			local repRankInfo = C_GossipInfo_GetFriendshipReputationRanks(factionID)
			local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
			if friendID and friendID ~= 0 then
				if maxRank > 0 then
					name = name.." ("..currentRank.." / "..maxRank..")"
				end
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = repInfo.reaction
			else
				if standing == MAX_REPUTATION_REACTION then
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,.6,1)
		GameTooltip:AddDoubleLine(standingtext, value - barMin.." / "..barMax - barMin.." ("..floor((value - barMin)/(barMax - barMin)*100).."%)", .6,.8,1, 1,1,1)

		if C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			local paraCount = floor(currentValue/threshold)
			currentValue = mod(currentValue, threshold)
			GameTooltip:AddDoubleLine(L["Paragon"]..paraCount, currentValue.." / "..threshold.." ("..floor(currentValue/threshold*100).."%)", .6,.8,1, 1,1,1)
		end

		if factionID == 2465 then -- 荒猎团
			local repInfo = C_GossipInfo_GetFriendshipReputation(2463) -- 玛拉斯缪斯
			local rep, name, reaction, threshold, nextThreshold = repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
			if nextThreshold and rep > 0 then
				local current = rep - threshold
				local currentMax = nextThreshold - threshold
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(name, 0,.6,1)
				GameTooltip:AddDoubleLine(reaction, current.." / "..currentMax.." ("..floor(current/currentMax*100).."%)", .6,.8,1, 1,1,1)
			end
		end
	end

	if IsWatchingHonorAsXP() then
		local current, barMax, level = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(HONOR, 0,.6,1)
		GameTooltip:AddDoubleLine(LEVEL.." "..level, current.." / "..barMax, .6,.8,1, 1,1,1)
	end

	if IsAzeriteAvailable() then
		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
		azeriteItem:ContinueWithCancelOnItemLoad(function()
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(azeriteItem:GetItemName().." ("..format(SPELLBOOK_AVAILABLE_AT, currentLevel)..")", 0,.6,1)
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(totalLevelXP).." ("..floor(xp/totalLevelXP*100).."%)", .6,.8,1, 1,1,1)
		end)
	end

	if HasArtifactEquipped() then
		local _, _, name, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
		local num, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
		GameTooltip:AddLine(" ")
		if C_ArtifactUI_IsEquippedArtifactDisabled() then
			GameTooltip:AddLine(name, 0,.6,1)
			GameTooltip:AddLine(ARTIFACT_RETIRED, .6,.8,1, 1)
		else
			GameTooltip:AddLine(name.." ("..format(SPELLBOOK_AVAILABLE_AT, pointsSpent)..")", 0,.6,1)
			local numText = num > 0 and " ("..num..")" or ""
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, BreakUpLargeNumbers(totalXP)..numText, .6,.8,1, 1,1,1)
			if xpForNextPoint ~= 0 then
				local perc = " ("..floor(xp/xpForNextPoint*100).."%)"
				GameTooltip:AddDoubleLine(L["Next Trait"], BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(xpForNextPoint)..perc, .6,.8,1, 1,1,1)
			end
		end
	end
	GameTooltip:Show()
end

function M:SetupScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"ARTIFACT_XP_UPDATE",
		"PLAYER_EQUIPMENT_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
		"AZERITE_ITEM_EXPERIENCE_CHANGED",
		"HONOR_XP_UPDATE",
	}
	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end
	bar:SetScript("OnEvent", M.ExpBar_Update)
	bar:SetScript("OnEnter", M.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", B.HideTooltip)
	bar:SetScript("OnMouseUp", function(_, btn)
		if not HasArtifactEquipped() or btn ~= "LeftButton" then return end
		if not ArtifactFrame or not ArtifactFrame:IsShown() then
			SocketInventoryItem(16)
		else
			B:TogglePanel(ArtifactFrame)
		end
	end)
	hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
		M.ExpBar_Update(bar)
	end)
end

function M:Expbar()
	if C.db["Map"]["DisableMinimap"] then return end
	if not C.db["Misc"]["ExpRep"] then return end

	local bar = CreateFrame("StatusBar", "NDuiExpRepBar", MinimapCluster)
	bar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 5, -5)
	bar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -5, -5)
	bar:SetHeight(5)
	bar:SetHitRectInsets(0, 0, 0, -10)
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	M:SetupScript(bar)
end
M:RegisterMisc("ExpRep", M.Expbar)

-- Paragon reputation info
function M:ParagonReputationSetup()
	if DB.isWW then return end -- FIXME
	if not C.db["Misc"]["ParagonRep"] then return end

	hooksecurefunc("ReputationFrame_InitReputationRow", function(factionRow, elementData)
		local factionID = factionRow.factionID
		local factionContainer = factionRow.Container
		local factionBar = factionContainer.ReputationBar
		local factionStanding = factionBar.FactionStanding

		if factionContainer.Paragon:IsShown() then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue then
				local barValue = mod(currentValue, threshold)
				local factionStandingtext = L["Paragon"]..floor(currentValue/threshold)

				factionBar:SetMinMaxValues(0, threshold)
				factionBar:SetValue(barValue)
				factionStanding:SetText(factionStandingtext)
				factionRow.standingText = factionStandingtext
				factionRow.rolloverText = format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(threshold))
			end
		end
	end)
end
M:RegisterMisc("ParagonRep", M.ParagonReputationSetup)