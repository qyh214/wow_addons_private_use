----------------------
-- 显示公会大米记录
----------------------
local _, ns = ...
local MDl = ns.Locales
MDdb = {}

local format, strsplit, tonumber, pairs, wipe = format, strsplit, tonumber, pairs, wipe
local Ambiguate = Ambiguate
local C_MythicPlus_GetRunHistory = C_MythicPlus.GetRunHistory
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_ChallengeMode_GetGuildLeaders = C_ChallengeMode.GetGuildLeaders
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local CHALLENGE_MODE_POWER_LEVEL = CHALLENGE_MODE_POWER_LEVEL
local CHALLENGE_MODE_GUILD_BEST_LINE = CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = WEEKLY_REWARDS_MYTHIC_TOP_RUNS

local hasAngryKeystones
local frame
local WeeklyRunsThreshold = 10

local MyClass = select(2, UnitClass("player"))
local MyFaction = UnitFactionGroup("player")
local MyFullName = UnitName("player").."-"..GetRealmName()
local RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

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
	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
	for i = 1, #leaderInfo.members do
		local classColorStr = RaidClassColors[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr,leaderInfo.members[i].name))
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

	local classColorStr = RaidClassColors[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
local function UpdateGuildBest(self)
	if not frame then CreateBoard() end
	if self.leadersAvailable then
		local leaders = C_ChallengeMode_GetGuildLeaders()
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

-- Weekly runs record
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

-- Account keystones
local function keystoneInfo_UpdateBag()
	local keystoneMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	if keystoneMapID then
		return keystoneMapID, C_MythicPlus_GetOwnedKeystoneLevel()
	end
end

local function keystoneInfo_Update()
	local mapID, keystoneLevel = keystoneInfo_UpdateBag()
	if mapID then
		MDdb["KeystoneInfo"][MyFullName] = mapID..":"..keystoneLevel..":"..MyClass..":"..MyFaction
	else
		MDdb["KeystoneInfo"][MyFullName] = nil
	end
end

local function keystoneInfo_Create()
	local texture = select(10, GetItemInfo(158923)) or 525134
	local iconColor = BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic or 4]
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 2, 67)
	button:SetSize(32, 32)

	button:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(.08, .92, .08, .92)
	icon:SetTexture(texture)
	local hl = button:CreateTexture(nil, "HIGHLIGHT")
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetAllPoints(icon)

	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(MDl["Account Keystones"])
		for fullName, info in pairs(MDdb["KeystoneInfo"]) do
			local name = Ambiguate(fullName, "none")
			local mapID, level, class, faction = strsplit(":", info)
			local color = "|c"..RaidClassColors[class or "PRIEST"].colorStr
			local factionColor = faction == "Horde" and "|cffff5040" or "|cff00adf0"
			local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))
			GameTooltip:AddDoubleLine(format(color.."%s:|r", name), format("%s%s(%s)|r", factionColor, dungeon, level))
		end
		GameTooltip:AddDoubleLine(" ", "----------")
		GameTooltip:AddDoubleLine(" ", " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "..MDl["Reset Info"].." ", 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			wipe(MDdb["KeystoneInfo"])
			keystoneInfo_Update()
		end
	end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, arg)
	if event == "ADDON_LOADED" and arg == "Blizzard_ChallengesUI" then
		hasAngryKeystones = IsAddOnLoaded("AngryKeystones")
		hooksecurefunc("ChallengesFrame_Update", UpdateGuildBest)
		ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", keystoneInfo_WeeklyRuns)
		keystoneInfo_Create()

		self:UnregisterEvent(event)
	else
		if not MDdb["KeystoneInfo"] then MDdb["KeystoneInfo"] = {} end
		keystoneInfo_Update()
	end
end)