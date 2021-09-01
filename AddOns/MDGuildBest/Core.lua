----------------------
-- 显示公会大米记录
----------------------
local C_MythicPlus_GetRunHistory = C_MythicPlus.GetRunHistory
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = WEEKLY_REWARDS_MYTHIC_TOP_RUNS

local hasAngryKeystones
local frame
local WeeklyRunsThreshold = 10

local function AddFontString(self, fontSize, text, anchor)
	local fs = self:CreateFontString(nil, "OVERLAY")
	fs:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
	fs:SetText(text)
	fs:SetWordWrap(false)
	fs:SetPoint(unpack(anchor))

	return fs
end

local function UpdateTooltip(self)
	local leaderInfo = self.leaderInfo
	if not leaderInfo then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local name = C_ChallengeMode.GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(leaderInfo.keystoneLevel))
	for i = 1, #leaderInfo.members do
		local classColorStr = RAID_CLASS_COLORS[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(CHALLENGE_MODE_GUILD_BEST_LINE:format(classColorStr,leaderInfo.members[i].name));
	end
	GameTooltip:Show()
end

local function CreateBoard()
	frame = CreateFrame("Frame", nil, ChallengesFrame, "BackdropTemplate")
	frame:SetPoint("BOTTOMRIGHT", -8, 75)
	frame:SetSize(170, 105)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetAtlas("ChallengeMode-guild-background")
	bg:SetAlpha(.25)
	local header = AddFontString(frame, 16, CHALLENGE_MODE_THIS_WEEK, {"TOPLEFT", 16, -6})
	header:SetTextColor(1, .8, 0)

	frame.entries = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame)
		entry:SetPoint("LEFT", 10, 0)
		entry:SetPoint("RIGHT", -10, 0)
		entry:SetHeight(18)
		entry.CharacterName = AddFontString(entry, 14, "", {"LEFT", 6, 0})
		entry.CharacterName:SetPoint("RIGHT", -30, 0)
		entry.CharacterName:SetJustifyH("LEFT")
		entry.Level = AddFontString(entry, 14, "", {"LEFT", entry, "RIGHT", -22, 0})
		entry.Level:SetTextColor(1, .8, 0)
		entry.Level:SetJustifyH("LEFT")
		entry:SetScript("OnEnter", UpdateTooltip)
		entry:SetScript("OnLeave", GameTooltip_Hide)

		if i == 1 then
			entry:SetPoint("TOP", frame, 0, -26)
		else
			entry:SetPoint("TOP", frame.entries[i-1], "BOTTOM")
		end

		frame.entries[i] = entry
	end

	if not hasAngryKeystones then
		ChallengesFrame.WeeklyInfo.Child.Description:SetPoint("CENTER", 0, 20)
	end
end

local function SetUpRecord(self, leaderInfo)
	self.leaderInfo = leaderInfo
	local str = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = RAID_CLASS_COLORS[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(str:format(classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
local function UpdateGuildBest(self)
	if not frame then CreateBoard() end
	if self.leadersAvailable then
		local leaders = C_ChallengeMode.GetGuildLeaders()
		if leaders and #leaders > 0 then
			for i = 1, #leaders do
				SetUpRecord(frame.entries[i], leaders[i])
			end
			frame:Show()
		else
			frame:Hide()
		end
	end

	if not resize and hasAngryKeystones then
		hooksecurefunc(self.WeeklyInfo.Child.WeeklyChest, "SetPoint", function(frame, _, x, y)
			if x == 100 and y == -30 then
				frame:SetPoint("LEFT", 105, -5)
			end
		end)
		self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -135, -25)

		local schedule = AngryKeystones.Modules.Schedule
		frame:SetWidth(246)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", schedule.AffixFrame, "TOPLEFT", 0, 10)

		local keystoneText = schedule.KeystoneText
		keystoneText:SetFontObject(Game13Font)
		keystoneText:ClearAllPoints()
		keystoneText:SetPoint("TOP", self.WeeklyInfo.Child.DungeonScoreInfo.Score, "BOTTOM", 0, -3)

		local affix = self.WeeklyInfo.Child.Affixes[1]
		if affix then
			affix:ClearAllPoints()
			affix:SetPoint("TOPLEFT", 20, -55)
		end

		resize = true
	end
end

local function sortHistory(entry1, entry2)
	if entry1.level == entry2.level then
		return entry1.mapChallengeModeID < entry2.mapChallengeModeID
	else
		return entry1.level > entry2.level
	end
end

local function keystoneInfo_WeeklyRuns()
	local runHistory = C_MythicPlus_GetRunHistory(false, true)
	local numRuns = runHistory and #runHistory
	if numRuns > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold), "("..numRuns..")", .6,.8,1)
		sort(runHistory, sortHistory)

		for i = 1, WeeklyRunsThreshold do
			local runInfo = runHistory[i]
			if not runInfo then break end

			local name = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID)
			local r,g,b = 0,1,0
			if not runInfo.completed then r,g,b = 1,0,0 end
			GameTooltip:AddDoubleLine(name, "Lv."..runInfo.level, 1,1,1, r,g,b)
		end
		GameTooltip:Show()
	end
end

local function ChallengesOnLoad(self, event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hasAngryKeystones = IsAddOnLoaded("AngryKeystones")
		hooksecurefunc("ChallengesFrame_Update", UpdateGuildBest)
		ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", keystoneInfo_WeeklyRuns)
		self:UnregisterEvent(event)
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", ChallengesOnLoad)