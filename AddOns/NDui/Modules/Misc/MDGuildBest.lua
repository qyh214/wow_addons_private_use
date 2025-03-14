local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

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
local CHALLENGE_MODE_THIS_WEEK = CHALLENGE_MODE_THIS_WEEK
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = WEEKLY_REWARDS_MYTHIC_TOP_RUNS

local hasAngryKeystones
local frame
local WeeklyRunsThreshold = 8

function M:GuildBest_UpdateTooltip()
	local leaderInfo = self.leaderInfo
	if not leaderInfo then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
	for i = 1, #leaderInfo.members do
		local classColorStr = DB.ClassColors[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr,leaderInfo.members[i].name))
	end
	GameTooltip:Show()
end

function M:GuildBest_Create()
	frame = CreateFrame("Frame", nil, ChallengesFrame, "BackdropTemplate")
	frame:SetPoint("BOTTOMRIGHT", -8, 75)
	frame:SetSize(170, 105)
	B.CreateBD(frame, .25)
	B.CreateFS(frame, 16, GUILD, "system", "TOPLEFT", 16, -6)

	frame.entries = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame)
		entry:SetPoint("LEFT", 10, 0)
		entry:SetPoint("RIGHT", -10, 0)
		entry:SetHeight(18)
		entry.CharacterName = B.CreateFS(entry, 14, "", false, "LEFT", 6, 0)
		entry.CharacterName:SetPoint("RIGHT", -30, 0)
		entry.CharacterName:SetJustifyH("LEFT")
		entry.Level = B.CreateFS(entry, 14, "", "system")
		entry.Level:SetJustifyH("LEFT")
		entry.Level:ClearAllPoints()
		entry.Level:SetPoint("LEFT", entry, "RIGHT", -22, 0)
		entry:SetScript("OnEnter", self.GuildBest_UpdateTooltip)
		entry:SetScript("OnLeave", B.HideTooltip)
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

	if SlashCmdList.KEYSTONE then -- Details key window
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(20, 20)
		button:SetPoint("TOPRIGHT", -12, -5)
		button:SetScript("OnClick", function()
			if DetailsKeystoneInfoFrame and DetailsKeystoneInfoFrame:IsShown() then
				DetailsKeystoneInfoFrame:Hide()
			else
				SlashCmdList.KEYSTONE()
			end
		end)
		local tex = button:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture(DB.copyTex)
		tex:SetVertexColor(0, 1, 0)
		local hl = button:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture(DB.copyTex)
	end

	if RaiderIO_GuildWeeklyFrame then
		B.HideObject(RaiderIO_GuildWeeklyFrame)
	end
end

function M:GuildBest_SetUp(leaderInfo)
	self.leaderInfo = leaderInfo
	local str = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = DB.ClassColors[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
function M:GuildBest_Update()
	if not frame then M:GuildBest_Create() end
	if self.leadersAvailable then
		local leaders = C_ChallengeMode_GetGuildLeaders()
		if leaders and #leaders > 0 then
			for i = 1, #leaders do
				M.GuildBest_SetUp(frame.entries[i], leaders[i])
			end
			frame:Show()
		else
			frame:Hide()
		end
	end

	if not resize and hasAngryKeystones then
		hooksecurefunc(self.WeeklyInfo.Child.WeeklyChest, "SetPoint", function(frame, _, x, y)
			if x == 100 and y == 0 then
				frame:SetPoint("LEFT", 110, -5)
			end
		end)
		self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -125, -25)

		local schedule = AngryKeystones.Modules.Schedule
		frame:SetWidth(246)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", schedule.AffixFrame, "TOPLEFT", 0, 10)

		local keystoneText = schedule.KeystoneText
		if keystoneText then
			keystoneText:SetFontObject(Game13Font)
			keystoneText:ClearAllPoints()
			keystoneText:SetPoint("TOP", self.WeeklyInfo.Child.DungeonScoreInfo.Score, "BOTTOM", 0, -3)
		end

		resize = true
	end
end

function M.GuildBest_OnLoad(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hooksecurefunc(ChallengesFrame, "Update", M.GuildBest_Update)
		M:KeystoneInfo_Create()
		ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", M.KeystoneInfo_WeeklyRuns)

		B:UnregisterEvent(event, M.GuildBest_OnLoad)
	end
end

local function sortHistory(entry1, entry2)
	if entry1.level == entry2.level then
		return entry1.mapChallengeModeID < entry2.mapChallengeModeID
	else
		return entry1.level > entry2.level
	end
end

function M:KeystoneInfo_WeeklyRuns()
	local runHistory = C_MythicPlus_GetRunHistory(false, true)
	local numRuns = runHistory and #runHistory
	if numRuns > 0 then
		local isShiftKeyDown = IsShiftKeyDown()

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(isShiftKeyDown and CHALLENGE_MODE_THIS_WEEK or format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold), "("..numRuns..")", .6,.8,1)
		sort(runHistory, sortHistory)

		for i = 1, isShiftKeyDown and numRuns or WeeklyRunsThreshold do
			local runInfo = runHistory[i]
			if not runInfo then break end

			local name = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID)
			local r,g,b = 0,1,0
			if not runInfo.completed then r,g,b = 1,0,0 end
			GameTooltip:AddDoubleLine(name, "Lv."..runInfo.level, 1,1,1, r,g,b)
		end
		if not isShiftKeyDown then
			GameTooltip:AddLine(L["Hold Shift"], .6,.8,1)
		end
		GameTooltip:Show()
	end
end

function M:KeystoneInfo_Create()
	local texture = C_Item.GetItemIconByID(158923) or 525134
	local iconColor = DB.QualityColors[Enum.ItemQuality.Epic or 4]
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 2, 67)
	button:SetSize(32, 32)
	B.PixelIcon(button, texture, true)
	button.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Account Keystones"])
		for fullName, info in pairs(NDuiADB["KeystoneInfo"]) do
			local name = Ambiguate(fullName, "none")
			local mapID, level, class, faction = strsplit(":", info)
			local color = B.HexRGB(B.ClassColor(class))
			local factionColor = faction == "Horde" and "|cffff5040" or "|cff00adf0"
			local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))
			GameTooltip:AddDoubleLine(format(color.."%s:|r", name), format("%s%s(%s)|r", factionColor, dungeon, level))
		end
		GameTooltip:AddDoubleLine(" ", DB.LineString)
		GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Reset Gold"].." ", 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			wipe(NDuiADB["KeystoneInfo"])
			M:KeystoneInfo_Update() -- update own keystone info after reset
		end
	end)
end

function M:KeystoneInfo_UpdateBag()
	local keystoneMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	if keystoneMapID then
		return keystoneMapID, C_MythicPlus_GetOwnedKeystoneLevel()
	end
end

function M:KeystoneInfo_Update()
	local mapID, keystoneLevel = M:KeystoneInfo_UpdateBag()
	if mapID then
		NDuiADB["KeystoneInfo"][DB.MyFullName] = mapID..":"..keystoneLevel..":"..DB.MyClass..":"..DB.MyFaction
	else
		NDuiADB["KeystoneInfo"][DB.MyFullName] = nil
	end
end

function M:GuildBest()
	if not C.db["Misc"]["MDGuildBest"] then return end

	hasAngryKeystones = C_AddOns.IsAddOnLoaded("AngryKeystones")
	B:RegisterEvent("ADDON_LOADED", M.GuildBest_OnLoad)

	M:KeystoneInfo_Update()
	B:RegisterEvent("BAG_UPDATE", M.KeystoneInfo_Update)
end
M:RegisterMisc("GuildBest", M.GuildBest)