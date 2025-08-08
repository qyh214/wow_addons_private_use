---@class Private
local Private = select(2, ...)

--[[
	No Summary:     Warcraft Logs
	Retail: 		Warcraft Logs    2/8M    4 Kills
	Classic Wrath: 	Warcraft Logs    8/8 H25    16 Kills
	Classic TBC: 	Warcraft Logs    8/8    16 Kills
	Classic SoD:	Warcraft Logs    8/8 [difficultyIcon] HL2    16 Kills
	]]
--
---@param profile ProviderProfileV2
---@return string
local function GetHeader(profile)
	local header = "Warcraft Logs    "
	local summary = profile.summary

	if summary == nil then
		return WrapTextInColorCode(header, Private.Colors.Brand)
	end

	local progress = Private.GetProgressString(summary.zoneId, summary.difficultyId, summary.sizeId, summary.progressKilled, summary.progressPossible, false)

	return WrapTextInColorCode(string.format("%s%s    %d %s", header, progress, summary.totalKills, Private.L.Kills), Private.Colors.Brand)
end

--[[
	Retail: 		Main: [specIcon] 69.4    8/8M    23 Kills
	Classic Wrath: 	Main: [specIcon] 69.4    8/8 H25    23 Kills
	Classic TBC: 	Main: [specIcon] 69.4    8/8    23 Kills
	Classic SoD:	Main: [specIcon] 69.4    8/8 [difficultyIcon] HL2    23 Kills
	]]
--
---@param mainCharacter ProviderProfileV2MainCharacter
---@return string
local function GetMainCharacterLine(mainCharacter)
	local line = string.format("%s: ", Private.L.Main)

	if mainCharacter.spec ~= "Unknown-Unknown" then
		local formattedPercentile = Private.FormatAveragePercentile(mainCharacter.bestAverage)
		local formattedPercentileNumber = tonumber(formattedPercentile)

		line = string.format(
			"%s %s %s",
			line,
			Private.EncodeWithTexture(Private.GetSpecIcon(mainCharacter.spec)),
			Private.EncodeWithPercentileColor(formattedPercentileNumber, formattedPercentile)
		)
	end

	local progress =
		Private.GetProgressString(mainCharacter.zoneId, mainCharacter.difficultyId, mainCharacter.sizeId, mainCharacter.progressKilled, mainCharacter.progressPossible, false)
	line = string.format("%s    %s    %d %s", line, progress, mainCharacter.totalKills, Private.L.Kills)

	return WrapTextInColorCode(line, Private.Colors.White)
end

---@param section ProviderProfileV2Section
---@param isLastSection boolean
---@param lines string[]?
local function AddSection(section, isLastSection, lines)
	local header = ""

	local zone = Private.GetZoneById(section.zoneId)
	if zone and zone.name then
		header = string.format("%s   ", zone.name)
	end

	if zone and zone.hasMultipleDifficulties then
		if zone.hasMultipleSizes then
			header = string.format("%s%d %s", Private.L["Difficulty-" .. section.difficultyId] or "", section.sizeId, header)
		else
			local difficultyName = Private.L["DifficultyName-" .. section.difficultyId]
			if difficultyName ~= nil then
				header = string.format("%s %s", difficultyName, header)
			end
		end
	elseif zone and zone.hasMultipleSizes then
		header = string.format("%d %s", section.sizeId, header)
	end

	-- to scope formattedPercentile/formattedPercentileNumber
	do
		local formattedPercentile = Private.FormatAveragePercentile(section.anySpecRankings.bestAverage)
		local formattedPercentileNumber = tonumber(formattedPercentile)

		header = string.format(
			"%s%s   %s   %d %s",
			header,
			Private.EncodeWithPercentileColor(formattedPercentileNumber, formattedPercentile),
			Private.GetProgressString(section.zoneId, section.difficultyId, section.sizeId, section.anySpecRankings.progressKilled, section.anySpecRankings.progressPossible, true),
			section.totalKills,
			Private.L.Kills
		)
	end

	if lines then
		table.insert(lines, header)
	else
		GameTooltip:AddLine(header)
	end

	local maxAllStarPointsLength = 0
	local maxAllStarRankLength = 0
	local maxBestAverageLength = 0
	local maxProgressLength = 0

	for _, rankings in ipairs(section.perSpecRankings) do
		if Private.db.Settings.ShowAsp then
			maxAllStarPointsLength = math.max(maxAllStarPointsLength, #tostring(rankings.allStarPoints))
		end
		if Private.db.Settings.ShowRank then
			maxAllStarRankLength = math.max(maxAllStarRankLength, #tostring(rankings.allStarRank))
		end
		maxBestAverageLength = math.max(maxBestAverageLength, #Private.FormatAveragePercentile(rankings.bestAverage))
		maxProgressLength =
			math.max(maxProgressLength, #Private.GetProgressString(section.zoneId, section.difficultyId, section.sizeId, rankings.progressKilled, rankings.progressPossible, true))
	end

	local shiftIsDown = IsShiftKeyDown() or lines ~= nil
	if InCombatLockdown() and Private.db.Settings.ShowTooltipInCombat and not Private.db.Settings.AllowShiftExpansionInCombat then
		shiftIsDown = false
	end

	local hasEncounters = false

	for rankingsIndex, rankings in ipairs(section.perSpecRankings) do
		local bestAverage = rankings.bestAverage == 0 and "       " or Private.FormatAveragePercentile(rankings.bestAverage)
		local progress = Private.GetProgressString(section.zoneId, section.difficultyId, section.sizeId, rankings.progressKilled, rankings.progressPossible, true)
		local allStarPoints = tostring(rankings.allStarPoints)
		local allStarRank = tostring(rankings.allStarRank)

		local line = string.format(
			"%s %s   %s",
			Private.EncodeWithTexture(Private.GetSpecIcon(rankings.spec)),
			string.rep("  ", maxBestAverageLength - #bestAverage) .. bestAverage,
			string.rep("  ", maxProgressLength - #progress) .. progress
		)

		if Private.db.Settings.ShowAsp and Private.db.Settings.ShowRank then
			line = string.format(
				"%s   %s: %s   %s: %s",
				line,
				Private.L.AllStars,
				string.rep("  ", maxAllStarPointsLength - #allStarPoints) .. allStarPoints,
				Private.L.Rank,
				string.rep("  ", maxAllStarRankLength - #allStarRank) .. allStarRank
			)
		elseif Private.db.Settings.ShowAsp and not Private.db.Settings.ShowRank then
			line = string.format("%s   %s: %s", line, Private.L.AllStars, string.rep("  ", maxAllStarPointsLength - #allStarPoints) .. allStarPoints)
		elseif not Private.db.Settings.ShowAsp and Private.db.Settings.ShowRank then
			line = string.format("%s   %s: %s", line, Private.L.Rank, string.rep("  ", maxAllStarRankLength - #allStarRank) .. allStarRank)
		end

		if lines then
			table.insert(lines, rankings.bestAverage == 0 and WrapTextInColorCode(line, Private.Colors.White) or Private.EncodeWithPercentileColor(rankings.bestAverage, line))
		else
			GameTooltip:AddLine(rankings.bestAverage == 0 and WrapTextInColorCode(line, Private.Colors.White) or Private.EncodeWithPercentileColor(rankings.bestAverage, line))
		end

		if not hasEncounters then
			for _, _ in pairs(rankings.encountersById) do
				hasEncounters = true
				break
			end
		end

		if zone and hasEncounters and shiftIsDown then
			for _, encounter in ipairs(zone.encounters) do
				local encounterRanking = rankings.encountersById[encounter.id] or {
					kills = 0,
					best = 0,
					isHidden = false,
				}
				if not encounterRanking.isHidden then
					local color = encounterRanking.kills == 0 and Private.Colors.Common or "ffffffff"
					local encounterName = Private.L["Encounter-" .. encounter.id] or Private.L.Unknown
					local nameAndKills = WrapTextInColorCode(string.format("%s (%s)", encounterName, encounterRanking.kills), color)

					if encounterRanking.kills > 0 then
						local formattedPercentile = Private.FormatPercentile(encounterRanking.best)
						local formattedPercentileNumber = tonumber(formattedPercentile)
						if lines then
							table.insert(lines, string.format("%s %s", Private.EncodeWithPercentileColor(formattedPercentileNumber, formattedPercentile), nameAndKills))
						else
							GameTooltip:AddDoubleLine(nameAndKills, Private.EncodeWithPercentileColor(formattedPercentileNumber, formattedPercentile))
						end
					else
						if lines then
							table.insert(lines, string.format("%s %s", "----", nameAndKills))
						else
							GameTooltip:AddDoubleLine(nameAndKills)
						end
					end
				end
			end

			if lines == nil then
				if rankingsIndex ~= #section.perSpecRankings then
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
				elseif not isLastSection then
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
				end
			end
		end
	end

	if hasEncounters and not shiftIsDown and Private.db.Settings.ShowShiftHint then
		if lines then
			table.insert(lines, WrapTextInColorCode(Private.L.ShiftToExpand, Private.Colors.DeemphasizedText))
		else
			GameTooltip:AddLine(WrapTextInColorCode(Private.L.ShiftToExpand, Private.Colors.DeemphasizedText))
		end
	end
end

---@param profile ProviderProfileV2
---@return string[]
function Private.GetProfileLines(profile)
	local lines = {
		GetHeader(profile),
	}

	if profile.summary ~= nil then
		if not profile.progressOnly then
			table.insert(lines, WrapTextInColorCode(Private.L["addon.parse-gate-description"], Private.Colors.DeemphasizedText))
		end
	elseif #profile.sections > 0 then
		for i, section in ipairs(profile.sections) do
			AddSection(section, i == #profile.sections, lines)
		end
	end

	if profile.mainCharacter then
		table.insert(lines, GetMainCharacterLine(profile.mainCharacter))
	end

	return lines
end

---@param profile ProviderProfileV2
local function DoGameTooltipUpdate(profile)
	GameTooltip:AddLine(GetHeader(profile))

	if profile.summary ~= nil then
		if not profile.progressOnly then
			GameTooltip:AddLine(WrapTextInColorCode(Private.L["addon.parse-gate-description"], Private.Colors.DeemphasizedText))
		end
	elseif #profile.sections > 0 then
		for i, section in ipairs(profile.sections) do
			AddSection(section, i == #profile.sections)
		end
	end

	if profile.mainCharacter then
		GameTooltip:AddLine(GetMainCharacterLine(profile.mainCharacter))
	end
end

local hookCache = {}

---@param frames table<number, Frame>
---@param map table<string, function>
local function HookAllFrames(frames, map)
	for i = 1, #frames do
		local frame = frames[i]
		if hookCache[frame] == nil then
			hookCache[frame] = true
			for script, callback in pairs(map) do
				frame:HookScript(script, callback)
			end
		end
	end
end

if FriendsFrame then
	local hooked = false

	-- don't hook instantly to ensure other addons (namely Raider) can hook before us
	-- otherwise raider sets the owner after us, which hides the tooltip and clears its lines
	FriendsFrame:HookScript("OnShow", function()
		if hooked then
			return
		end

		hooked = true

		hooksecurefunc(FriendsTooltip, "Show", function(self)
			local button = self.button
			local name, realm

			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList.GetFriendInfoByIndex(button.id)

				if not info or not info.name then
					return
				end

				name = info.name
				realm = Private.CurrentRealm.name
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local info = C_BattleNet.GetFriendAccountInfo(button.id)

				if not info or not info.gameAccountInfo or info.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW then
					return
				end

				name = info.gameAccountInfo.characterName
				if info.gameAccountInfo.realmDisplayName then
					realm = info.gameAccountInfo.realmDisplayName
				else
					realm = Private.CurrentRealm.name
				end
			end

			if not name or not realm then
				return
			end

			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				return
			end

			if Private.AddOnUtils.RaiderIoLoaded then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
			else
				GameTooltip:SetOwner(FriendsTooltip, "ANCHOR_BOTTOMRIGHT", -FriendsTooltip:GetWidth(), -4)
			end
			DoGameTooltipUpdate(profile)

			GameTooltip:Show()
		end)

		if not Private.AddOnUtils.RaiderIoLoaded then
			hooksecurefunc(FriendsTooltip, "Hide", function()
				GameTooltip:Hide()
			end)
		end
	end)
end

if Private.IsRetail then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
		if not Private.IsInitialized or tooltip ~= GameTooltip or (InCombatLockdown() and not Private.db.Settings.ShowTooltipInCombat) or data.type ~= Enum.TooltipDataType.Unit then
			return
		end

		local unitToken = nil

		for _, line in pairs(data.lines) do
			if line.type == Enum.TooltipDataLineType.UnitName then
				unitToken = line.unitToken
				break
			end
		end

		if unitToken == nil and data.guid then
			unitToken = UnitTokenFromGUID(data.guid)
		end

		if unitToken == nil or not UnitIsPlayer(unitToken) then
			return
		end

		local name, realm = UnitName(unitToken)
		local profile = Private.GetProfile(name, realm)

		if profile == nil then
			return
		end

		GameTooltip_AddBlankLineToTooltip(tooltip)
		DoGameTooltipUpdate(profile)
	end)
else
	---@param self GameTooltip
	local function OnTooltipSetUnit(self)
		if self ~= GameTooltip or (InCombatLockdown() and not Private.db.Settings.ShowTooltipInCombat) then
			return
		end

		local unitToken = select(2, self:GetUnit())

		if not unitToken or not UnitIsPlayer(unitToken) then
			return
		end

		local name, realm = UnitName(unitToken)
		local profile = Private.GetProfile(name, realm)

		if profile == nil then
			return
		end

		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		DoGameTooltipUpdate(profile)
	end

	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

	EventRegistry:RegisterFrameEventAndCallback(
		"MODIFIER_STATE_CHANGED",
		---@param owner number
		---@param key string
		---@param down number
		function(owner, key, down)
			if
				string.match(key, "SHIFT") == nil
				or not GameTooltip:IsVisible()
				or (InCombatLockdown() and (not Private.db.Settings.ShowTooltipInCombat or not Private.db.Settings.AllowShiftExpansionInCombat))
			then
				return
			end

			local unit = select(2, GameTooltip:GetUnit())

			if unit then
				GameTooltip:SetUnit(unit)
			end
		end
	)
end

if WhoFrame and WhoFrame.ScrollBox then
	WhoFrame:HookScript("OnShow", function()
		local function OnListEnter(self)
			if not self.index then
				return
			end

			local info = C_FriendList.GetWhoInfo(self.index)

			if not info or not info.fullName then
				return
			end

			local name, realm = strsplit("-", info.fullName)
			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				return
			end

			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			DoGameTooltipUpdate(profile)
			GameTooltip:Show()
		end

		local frames = WhoFrame.ScrollBox:GetFrames()

		if frames and frames[1] then
			HookAllFrames(frames, { OnEnter = OnListEnter })
		end

		WhoFrame.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, function()
			frames = WhoFrame.ScrollBox:GetFrames()

			HookAllFrames(frames, { OnEnter = OnListEnter })
		end)

		WhoFrame.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, function(self)
			local focused = GetMouseFoci()

			if not focused then
				return
			end

			local focus = focused[1]

			if not focus or focus == WorldFrame then
				return
			end

			local parent = focus:GetParent()

			if parent ~= WhoFrame.ScrollBox.ScrollTarget then
				return
			end

			GameTooltip:Hide()

			local onEnter = focus:GetScript("OnEnter")
			pcall(onEnter, focus)
		end)
	end)
else
	WhoFrame:HookScript("OnShow", function()
		---@type Button?
		local hoveredWhoListButton

		---@param self Button
		local function OnListButtonEnter(self)
			hoveredWhoListButton = self

			local characterName = self.tooltip1
			local needsAnchoring = characterName == nil
			local secondLine

			-- for some reason, not always propagated
			if not characterName then
				local buttonName = self:GetName()

				if not buttonName then
					return
				end

				---@type FontString?
				local nameFrame = _G[buttonName .. "Name"]

				if not nameFrame then
					return
				end

				characterName = nameFrame:GetText()

				---@type FontString?
				local variableFrame = _G[buttonName .. "Variable"]

				if variableFrame then
					secondLine = variableFrame:GetText()
				end
			end

			if not characterName then
				return
			end

			-- this technically fixes a bug in the Who list where not every entry receives a GameTooltip
			-- but so ours looks consistent across the working and bugged ones, we repair this
			if needsAnchoring then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				GameTooltip:SetText(characterName)

				if secondLine then
					GameTooltip:AddLine(secondLine, 1, 1, 1)
				end
			end

			local name, realm = strsplit("-", characterName)
			local profile = Private.GetProfile(name, realm)

			if profile ~= nil then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				DoGameTooltipUpdate(profile)
			end

			GameTooltip:Show()
		end

		local function OnListButtonLeave(self)
			hoveredWhoListButton = nil
		end

		do
			local whoButtons = {}

			for i = 1, WHOS_TO_DISPLAY do
				local button = _G["WhoFrameButton" .. i]

				if button then
					table.insert(whoButtons, button)
				end
			end

			HookAllFrames(whoButtons, {
				OnEnter = OnListButtonEnter,
				OnLeave = OnListButtonLeave,
			})
		end

		EventRegistry:RegisterFrameEventAndCallback("MODIFIER_STATE_CHANGED", function(owner, key, down)
			if
				string.match(key, "SHIFT") == nil
				or not GameTooltip:IsVisible()
				or (InCombatLockdown() and (not Private.db.Settings.ShowTooltipInCombat or not Private.db.Settings.AllowShiftExpansionInCombat))
				or hoveredWhoListButton == nil
			then
				return
			end

			local onEnter = hoveredWhoListButton:GetScript("OnEnter")
			onEnter(hoveredWhoListButton)
		end)
	end)
end

table.insert(Private.LoginFnQueue, function()
	local usesBlizzardCommunities = Private.IsRetail or Private.IsCata

	if Private.IsClassicEra or (Private.IsWrath and Private.CurrentRealm.region == "CN") then
		if C_AddOns and C_AddOns.DoesAddOnExist then
			usesBlizzardCommunities = C_AddOns.DoesAddOnExist("Blizzard_Communities") and not C_CVar.GetCVarBool("useClassicGuildUI")
		else
			usesBlizzardCommunities = Private.AddOnUtils.IsAddOnLoaded("Blizzard_Communities")
		end
	end

	if (Private.IsClassicEra or (Private.IsWrath and Private.CurrentRealm.region == "CN")) and not usesBlizzardCommunities then
		---@type number|nil
		local lastSelectedGuildMemberIndex = nil
		---@type number|nil
		local lastHoveredGuildMemberIndex = nil

		---@param index number
		local function DoGuildFrameTooltipUpdate(index)
			local fullName, _, _, _, classDisplayName = GetGuildRosterInfo(index)

			local name, realm = strsplit("-", fullName)
			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				return
			end

			if GuildMemberDetailFrame:IsVisible() then
				-- the GuildMemberDetailFrame contains the tooltip info of a previously hovered guild member (and more)
				-- this frame doesn't have a tooltip by itself, so we add our info below
				GameTooltip:SetOwner(GuildMemberDetailFrame, "ANCHOR_BOTTOMRIGHT", -1 * GuildMemberDetailFrame:GetWidth())
			else
				GameTooltip:SetOwner(GuildFrame, "ANCHOR_NONE")
			end

			local coloredName = WrapTextInColorCode(name, select(4, GetClassColor(strupper(classDisplayName))))
			GameTooltip:AddLine(coloredName)
			DoGameTooltipUpdate(profile)

			GameTooltip:Show()

			-- can't know tooltip dimensions before showing, so adjust after.
			-- not needed for GuildMemberDetailFrame due to different anchor
			if GameTooltip:GetOwner() == GuildFrame then
				GameTooltip:SetPoint("TOPRIGHT", GuildFrame, GameTooltip:GetWidth(), 0)
			end
		end

		---@param self Frame
		local function OnGuildMemberDetailCloseButton(self)
			if GameTooltip:GetOwner() == GuildMemberDetailFrame then
				GameTooltip:SetOwner(GuildFrame, "ANCHOR_TOP")
				lastSelectedGuildMemberIndex = nil
			end
		end

		GuildMemberDetailCloseButton:HookScript("OnClick", OnGuildMemberDetailCloseButton)

		---@param self Frame
		local function OnGuildMemberDetailFrameEnter(self)
			if lastHoveredGuildMemberIndex or lastSelectedGuildMemberIndex then
				DoGuildFrameTooltipUpdate(lastSelectedGuildMemberIndex or lastHoveredGuildMemberIndex)
			end
		end

		GuildMemberDetailFrame:HookScript("OnEnter", OnGuildMemberDetailFrameEnter)

		---@param self Frame
		local function OnGuildFrameHide(self)
			lastSelectedGuildMemberIndex = nil
			lastHoveredGuildMemberIndex = nil
			GameTooltip:Hide()
		end

		FriendsFrame:HookScript("OnHide", OnGuildFrameHide)

		---@param self Frame
		local function OnGuildFrameButtonEnter(self)
			lastHoveredGuildMemberIndex = self.guildIndex
			DoGuildFrameTooltipUpdate(lastSelectedGuildMemberIndex or lastHoveredGuildMemberIndex)
		end

		---@param self Frame
		local function OnGuildFrameButtonLeave(self)
			lastHoveredGuildMemberIndex = nil
			GameTooltip:Hide()

			if GuildMemberDetailFrame:IsVisible() and lastSelectedGuildMemberIndex then
				DoGuildFrameTooltipUpdate(lastSelectedGuildMemberIndex)
			end
		end

		---@param self Frame
		---@param button string
		---@param down boolean
		local function OnGuildFrameButtonClick(self, button, down)
			if not down and button == "LeftButton" then
				local currentSelection = GetGuildRosterSelection()

				if currentSelection > 0 then
					lastSelectedGuildMemberIndex = currentSelection
					DoGuildFrameTooltipUpdate(lastSelectedGuildMemberIndex)
				else
					lastSelectedGuildMemberIndex = nil
					-- details no longer opened, but still hovering
					DoGuildFrameTooltipUpdate(lastHoveredGuildMemberIndex)
				end
			end
		end

		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			---@type Frame|nil
			local guildFrameButton = _G["GuildFrameButton" .. i]
			local statusButton = _G["GuildFrameGuildStatusButton" .. i]

			if guildFrameButton then
				guildFrameButton:HookScript("OnEnter", OnGuildFrameButtonEnter)
				guildFrameButton:HookScript("OnLeave", OnGuildFrameButtonLeave)
				guildFrameButton:HookScript("OnClick", OnGuildFrameButtonClick)
			end

			if statusButton then
				statusButton:HookScript("OnEnter", OnGuildFrameButtonEnter)
				statusButton:HookScript("OnLeave", OnGuildFrameButtonLeave)
				statusButton:HookScript("OnClick", OnGuildFrameButtonClick)
			end
		end

		EventRegistry:RegisterFrameEventAndCallback(
			"MODIFIER_STATE_CHANGED",
			---@param owner number
			---@param key string
			---@param down number
			function(owner, key, down)
				if
					string.match(key, "SHIFT") == nil
					or not GameTooltip:IsVisible()
					or (InCombatLockdown() and (not Private.db.Settings.ShowTooltipInCombat or not Private.db.Settings.AllowShiftExpansionInCombat))
				then
					return
				end

				if GuildFrame:IsVisible() and lastSelectedGuildMemberIndex then
					DoGuildFrameTooltipUpdate(lastSelectedGuildMemberIndex)
				end
			end
		)
	elseif Private.IsWrath or usesBlizzardCommunities then
		---@type ClubMemberInfo|nil
		local lastExpandedGuildMemberInfo = nil
		---@type ClubMemberInfo|nil
		local lastHoveredGuildMemberInfo = nil
		---@type CommunitiesMemberListEntryMixin|nil
		local hoveredCommunitiesMemberListEntry = nil
		---@type Frame|nil
		local lastHoveredLFGListApplicantMember = nil
		---@type number|nil
		local lastLFGListResultID = nil

		---@param memberInfo ClubMemberInfo
		local function DoGuildFrameTooltipUpdate(memberInfo)
			-- ignore deleted characters which may still show up
			if not memberInfo.name then
				return
			end

			local name, realm = strsplit("-", memberInfo.name)
			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				return
			end

			if memberInfo == lastHoveredGuildMemberInfo then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
			elseif CommunitiesFrame.GuildMemberDetailFrame:IsVisible() then
				-- the GuildMemberDetailFrame contains the tooltip info of a previously hovered guild member (and more)
				-- this frame doesn't have a tooltip by itself, so we add our info below
				GameTooltip:SetOwner(CommunitiesFrame.GuildMemberDetailFrame, "ANCHOR_BOTTOMRIGHT", -1 * CommunitiesFrame.GuildMemberDetailFrame:GetWidth() + 10)
			end

			if memberInfo == lastExpandedGuildMemberInfo and memberInfo.classID then
				local className = GetClassInfo(memberInfo.classID)
				local coloredName = WrapTextInColorCode(memberInfo.name, select(4, GetClassColor(strupper(className))))
				GameTooltip:AddLine(coloredName)
			end

			DoGameTooltipUpdate(profile)

			GameTooltip:Show()
		end

		---@param GuildMemberDetailFrame self
		---@param clubId number
		---@param memberInfo ClubMemberInfo
		local function OnGuildMemberDetailFrameDisplayed(self, clubId, memberInfo)
			lastExpandedGuildMemberInfo = memberInfo
			lastHoveredGuildMemberInfo = nil
			lastHoveredLFGListApplicantMember = nil

			DoGuildFrameTooltipUpdate(memberInfo)
		end

		local function OnGuildMemberDetailFrameEnter()
			if lastExpandedGuildMemberInfo then
				DoGuildFrameTooltipUpdate(lastExpandedGuildMemberInfo)
			end
		end

		local function OnGuildMemberDetailFrameClosed()
			lastExpandedGuildMemberInfo = nil
			hoveredCommunitiesMemberListEntry = nil

			if GameTooltip:GetOwner() == CommunitiesFrame.GuildMemberDetailFrame then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOP")
			end
		end

		local function OnCommunitiesFrameHidden()
			OnGuildMemberDetailFrameClosed()
		end

		---@param CommunitiesMemberListEntryMixin self
		---@param unknownBoolean boolean
		local function OnCommunitiesMemberListEntryEnter(self, unknownBoolean)
			local memberInfo = self:GetMemberInfo()

			if not memberInfo then
				return
			end

			hoveredCommunitiesMemberListEntry = self
			lastHoveredGuildMemberInfo = memberInfo
			lastHoveredLFGListApplicantMember = nil

			DoGuildFrameTooltipUpdate(memberInfo)
		end

		local function OnCommunitiesMemberListEntryLeave(self)
			hoveredCommunitiesMemberListEntry = nil
		end

		if not Private.IsRetail then
			---@param self Frame
			function LFGListApplicantMember_OnEnter(self)
				local applicantID = self:GetParent().applicantID
				local memberIdx = self.memberIdx

				local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
				if not activeEntryInfo then
					return
				end

				local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
				if not activityInfo then
					return
				end
				local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
				local name, class, localizedClass, level, itemLevel, honorLevel, _, _, _, _, _, dungeonScore, pvpItemLevel = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
				local bestDungeonScoreForEntry = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, memberIdx, activeEntryInfo.activityID)
				local pvpRatingForEntry = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, memberIdx, activeEntryInfo.activityID)

				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 105, 0)

				if name then
					local classTextColor = RAID_CLASS_COLORS[class]
					GameTooltip:SetText(name, classTextColor.r, classTextColor.g, classTextColor.b)
					-- patch applied to fix error thrown by the game
					-- if UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[factionGroup] then
					-- 	GameTooltip_AddHighlightLine(GameTooltip, UNIT_TYPE_LEVEL_FACTION_TEMPLATE:format(level, localizedClass, FACTION_STRINGS[factionGroup]))
					-- else
					GameTooltip_AddHighlightLine(GameTooltip, UNIT_TYPE_LEVEL_TEMPLATE:format(level, localizedClass))
				-- end
				else
					GameTooltip:SetText(" ") --Just make it empty until we get the name update
				end

				if activityInfo.isPvpActivity then
					GameTooltip_AddColoredLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT_PVP:format(pvpItemLevel), HIGHLIGHT_FONT_COLOR)
				else
					GameTooltip_AddColoredLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT:format(itemLevel), HIGHLIGHT_FONT_COLOR)
				end

				if activityInfo.useHonorLevel then
					GameTooltip:AddLine(string.format(LFG_LIST_HONOR_LEVEL_CURRENT_PVP, honorLevel), 1, 1, 1)
				end
				if applicantInfo.comment and applicantInfo.comment ~= "" then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(
						string.format(LFG_LIST_COMMENT_FORMAT, applicantInfo.comment),
						LFG_LIST_COMMENT_FONT_COLOR.r,
						LFG_LIST_COMMENT_FONT_COLOR.g,
						LFG_LIST_COMMENT_FONT_COLOR.b,
						true
					)
				end
				if LFGApplicationViewerRatingColumnHeader:IsShown() then
					if pvpRatingForEntry then
						GameTooltip_AddNormalLine(
							GameTooltip,
							PVP_RATING_GROUP_FINDER:format(pvpRatingForEntry.activityName, pvpRatingForEntry.rating, PVPUtil.GetTierName(pvpRatingForEntry.tier))
						)
					else
						if not dungeonScore then
							dungeonScore = 0
						end
						GameTooltip_AddBlankLineToTooltip(GameTooltip)
						local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore)
						if not color then
							color = HIGHLIGHT_FONT_COLOR
						end
						GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_LEADER:format(color:WrapTextInColorCode(dungeonScore)))
						if bestDungeonScoreForEntry then
							local overAllColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(bestDungeonScoreForEntry.mapScore)
							if not overAllColor then
								overAllColor = HIGHLIGHT_FONT_COLOR
							end
							if bestDungeonScoreForEntry.mapScore == 0 then
								GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_PER_DUNGEON_NO_RATING:format(bestDungeonScoreForEntry.mapName, bestDungeonScoreForEntry.mapScore))
							elseif bestDungeonScoreForEntry.finishedSuccess then
								GameTooltip_AddNormalLine(
									GameTooltip,
									DUNGEON_SCORE_DUNGEON_RATING:format(
										bestDungeonScoreForEntry.mapName,
										overAllColor:WrapTextInColorCode(bestDungeonScoreForEntry.mapScore),
										bestDungeonScoreForEntry.bestRunLevel
									)
								)
							else
								GameTooltip_AddNormalLine(
									GameTooltip,
									DUNGEON_SCORE_DUNGEON_RATING_OVERTIME:format(
										bestDungeonScoreForEntry.mapName,
										overAllColor:WrapTextInColorCode(bestDungeonScoreForEntry.mapScore),
										bestDungeonScoreForEntry.bestRunLevel
									)
								)
							end
						end
					end
				end

				--Add statistics
				local stats = C_LFGList.GetApplicantMemberStats(applicantID, memberIdx)
				local lastTitle = nil

				--Tank proving ground
				if stats[23690] and stats[23690] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				elseif stats[23687] and stats[23687] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				elseif stats[23684] and stats[23684] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				end

				--Healer proving ground
				if stats[23691] and stats[23691] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				elseif stats[23688] and stats[23688] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				elseif stats[23685] and stats[23685] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
					lastTitle = LFG_LIST_PROVING_GROUND_TITLE
				end

				--Damage proving ground
				if stats[23689] and stats[23689] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
				elseif stats[23686] and stats[23686] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
				elseif stats[23683] and stats[23683] > 0 then
					LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle)
				end

				GameTooltip:Show()
			end
		end

		---@see LFGList:1789 -> LFGListApplicantMember_OnEnter
		---@param self Frame
		local function OnLFGListApplicantMemberEnter(self)
			lastHoveredLFGListApplicantMember = self
			lastExpandedGuildMemberInfo = nil
			hoveredCommunitiesMemberListEntry = nil
			lastLFGListResultID = nil

			local applicantID = self:GetParent().applicantID
			local memberIdx = self.memberIdx

			local characterName = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)

			if characterName == nil then
				return
			end

			local name, realm = strsplit("-", characterName)
			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				return
			end

			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			DoGameTooltipUpdate(profile)
			GameTooltip:Show()
		end

		hooksecurefunc("LFGListApplicantMember_OnEnter", OnLFGListApplicantMemberEnter)

		local function OnBlizzardCommunitiesLoaded()
			hooksecurefunc(CommunitiesFrame.GuildMemberDetailFrame, "DisplayMember", OnGuildMemberDetailFrameDisplayed)
			CommunitiesFrame.GuildMemberDetailFrame:HookScript("OnEnter", OnGuildMemberDetailFrameEnter)
			CommunitiesFrame.GuildMemberDetailFrame.CloseButton:HookScript("OnClick", OnGuildMemberDetailFrameClosed)
			CommunitiesFrame:HookScript("OnHide", OnCommunitiesFrameHidden)
			hooksecurefunc(CommunitiesMemberListEntryMixin, "OnEnter", OnCommunitiesMemberListEntryEnter)
			hooksecurefunc(CommunitiesMemberListEntryMixin, "OnLeave", OnCommunitiesMemberListEntryLeave)
		end

		if EventUtil and EventUtil.ContinueOnAddOnLoaded then
			EventUtil.ContinueOnAddOnLoaded("Blizzard_Communities", OnBlizzardCommunitiesLoaded)
		else
			if Private.AddOnUtils.IsAddOnLoaded("Blizzard_Communities") then
				OnBlizzardCommunitiesLoaded()
			else
				EventRegistry:RegisterFrameEventAndCallback(
					"ADDON_LOADED",
					---@param owner number
					---@param loadedAddonName string
					function(owner, loadedAddonName)
						if loadedAddonName == "Blizzard_Communities" then
							EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", owner)
							OnBlizzardCommunitiesLoaded()
						end
					end
				)
			end
		end

		---@class LeaderInfo
		local lastSeenLeader = {
			name = nil,
			realm = nil,
		}

		if PVEFrame then
			local function OnPVEFrameHide()
				lastLFGListResultID = nil
				lastSeenLeader.name = nil
				lastSeenLeader.realm = nil
				lastHoveredLFGListApplicantMember = nil
			end

			PVEFrame:HookScript("OnHide", OnPVEFrameHide)
		end

		local currentTooltipOwner = nil

		if Private.AddOnUtils.RaiderIoLoaded then
			---@param tooltip GameTooltip
			---@param resultID number
			---@param autoAcceptOption boolean
			local function OnLFGListUtilSearchEntry(tooltip, resultID, autoAcceptOption)
				lastLFGListResultID = resultID

				local entry = C_LFGList.GetSearchResultInfo(resultID)

				if not entry or not entry.leaderName then
					return
				end

				local name, realm = strsplit("-", entry.leaderName)
				lastSeenLeader.name = name
				lastSeenLeader.realm = realm or Private.CurrentRealm.name

				local profile = Private.GetProfile(lastSeenLeader.name, lastSeenLeader.realm)

				if profile == nil then
					return
				end

				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				DoGameTooltipUpdate(profile)
			end

			local function OnLFGListSearchEntryLeave(self)
				lastLFGListResultID = nil
			end

			hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", OnLFGListUtilSearchEntry)
			hooksecurefunc("LFGListSearchEntry_OnLeave", OnLFGListSearchEntryLeave)
		else
			local expectedLinesToGetAdded = 0
			local lastUpdatedLFGListResultID = nil

			---@param id number
			local function PerformTooltipUpdateForLFGResult(id)
				if lastUpdatedLFGListResultID == id then
					return
				end

				local entry = C_LFGList.GetSearchResultInfo(id)

				if not entry or not entry.leaderName then
					return
				end

				local name, realm = strsplit("-", entry.leaderName)
				lastSeenLeader.name = name
				lastSeenLeader.realm = realm or Private.CurrentRealm.name

				local profile = Private.GetProfile(lastSeenLeader.name, lastSeenLeader.realm)

				if profile == nil then
					return
				end

				lastUpdatedLFGListResultID = id

				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				DoGameTooltipUpdate(profile)
			end

			hooksecurefunc(GameTooltip, "AddLine", function(self, line)
				if lastLFGListResultID and expectedLinesToGetAdded > 0 then
					expectedLinesToGetAdded = expectedLinesToGetAdded - 1

					if expectedLinesToGetAdded == 0 then
						PerformTooltipUpdateForLFGResult(lastLFGListResultID)
					end
				end
			end)

			local isHoveringLFGListSearchEntry = false

			-- intercept LFGListSearchEntry_OnEnter as soon as possible by catching setting owner to the hovered entry
			-- https://github.com/Gethe/wow-ui-source/blob/428c09816801e8d71cc987924203539f51deaf52/Interface/AddOns/Blizzard_GroupFinder/Mainline/LFGList.lua#L3193-L3194
			hooksecurefunc(GameTooltip, "SetOwner", function(self, owner)
				-- just a bunch of properties guarding against setting owner to a LFGListSearchEntry
				if owner.resultID and owner.expiration and owner.ActivityName then
					lastLFGListResultID = owner.resultID
					isHoveringLFGListSearchEntry = true
				end
			end)

			local originalGetSearchResultEncounterInfo = C_LFGList.GetSearchResultEncounterInfo

			-- follow https://github.com/Gethe/wow-ui-source/blob/428c09816801e8d71cc987924203539f51deaf52/Interface/AddOns/Blizzard_GroupFinder/Mainline/LFGList.lua#L4178-L4197
			-- find out many lines get added based on above code, then await n calls to GameTooltip:AddLine() before adding ours.
			-- this way we can safely append before GameTooltip:Show() gets called and finalizes layouting
			hooksecurefunc(C_LFGList, "GetSearchResultEncounterInfo", function(id)
				if not isHoveringLFGListSearchEntry or lastLFGListResultID == nil then
					return
				end

				expectedLinesToGetAdded = 0

				local completedEncounters = originalGetSearchResultEncounterInfo(id)

				if completedEncounters and #completedEncounters > 0 then
					expectedLinesToGetAdded = #completedEncounters
					expectedLinesToGetAdded = expectedLinesToGetAdded + 2
				end

				local searchResultInfo = C_LFGList.GetSearchResultInfo(id)

				if searchResultInfo.autoAccept then
					expectedLinesToGetAdded = expectedLinesToGetAdded + 2
				end

				if searchResultInfo.isDelisted then
					expectedLinesToGetAdded = expectedLinesToGetAdded + 2
				end

				if expectedLinesToGetAdded == 0 then
					PerformTooltipUpdateForLFGResult(lastLFGListResultID)
				end
			end)

			if LFGListFrame then
				local function OnLFGListSearchPanelButtonEnter(self)
					currentTooltipOwner = self
				end

				local function OnLFGListSearchPanelButtonLeave(self)
					lastLFGListResultID = nil
					currentTooltipOwner = nil
					isHoveringLFGListSearchEntry = false
					lastUpdatedLFGListResultID = nil
				end

				local map = {
					OnEnter = OnLFGListSearchPanelButtonEnter,
					OnLeave = OnLFGListSearchPanelButtonLeave,
				}

				HookAllFrames(LFGListFrame.SearchPanel.ScrollBox:GetFrames(), map)

				LFGListFrame.SearchPanel.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, function()
					HookAllFrames(LFGListFrame.SearchPanel.ScrollBox:GetFrames(), map)
				end)
			end
		end

		if Menu and Menu.ModifyMenu then
			-- technically a violation of separations but since the Quick Join dropdown/menu doesn't propagate
			-- contextual info, we have to do it here based on the last hovered element
			Menu.ModifyMenu("MENU_QUICK_JOIN", function(owner, rootDescription, contextData)
				if not Private.db.Settings.MenuDropdownIntegration or not lastSeenLeader.name then
					return
				end

				rootDescription:CreateDivider()
				rootDescription:CreateTitle("Warcraft Logs")
				rootDescription:CreateButton(Private.L.CopyProfileURL, function()
					Private.ShowCopyProfileUrlPopup(lastSeenLeader)
				end)
			end)

			Menu.ModifyMenu("MENU_LFG_FRAME_MEMBER_APPLY", function(owner, rootDescription, contextData)
				if not Private.db.Settings.MenuDropdownIntegration then
					return
				end

				local memberIdx = owner.memberIdx

				if not memberIdx then
					return
				end

				local parent = owner:GetParent()

				if not parent then
					return
				end

				local applicantID = parent.applicantID

				if not applicantID then
					return
				end

				local fullName = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
				local name, realm = strsplit("-", fullName)

				rootDescription:CreateDivider()
				rootDescription:CreateTitle("Warcraft Logs")
				rootDescription:CreateButton(Private.L.CopyProfileURL, function()
					Private.ShowCopyProfileUrlPopup({
						name = name,
						projectId = WOW_PROJECT_ID,
						realm = realm,
					})
				end)
			end)
		end

		if LFGListFrame and LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer.UnempoweredCover then
			---@type Frame
			local frame = LFGListFrame.ApplicationViewer.UnempoweredCover

			frame:HookScript("OnShow", function(self)
				self:Hide()
			end)
			frame:EnableMouse(false)
			frame:EnableMouseWheel(false)
			frame:SetToplevel(false)
		end

		-- for some reason, the Retail LFG tool doesn't use the "Leader: %s" pattern
		if not Private.IsRetail then
			---@type string
			local localizedGroupLeaderString = strsplit(" ", LFG_LIST_TOOLTIP_LEADER_FACTION or LFG_LIST_TOOLTIP_LEADER or "")

			if LFGListUtil_SetSearchEntryTooltip then
				---@param tooltip GameTooltip
				---@param resultID number
				local function OnLFGListEntrySelection(tooltip, resultID)
					lastLFGListResultID = resultID
				end

				hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", OnLFGListEntrySelection)
			end

			---@param self GameTooltip
			---@param line string
			local function OnGameTooltipLineAdded(self, line)
				if not LFGListFrame or not LFGListFrame:IsVisible() or not line then
					return
				end

				-- parse `Leader: NAME-REALM (FACTION)` info from GameTooltip:AddLine while its being added
				-- and store the current data
				if line:find(localizedGroupLeaderString) ~= nil then
					local withoutLeaderPrefix = line:gsub("^[^:]*:%s*", "")
					local withoutFaction = withoutLeaderPrefix:gsub("%s*%b()", "")
					---@type string
					local trimmed = withoutFaction:match("^%s*(.-)%s*$")
					local sanitized = trimmed:gsub("|cffffffff", ""):gsub("|r", "")

					local name, realm = strsplit("-", sanitized)
					lastSeenLeader.name = name
					lastSeenLeader.realm = realm or Private.CurrentRealm.name
					return
				end

				-- given a leader and seeing the `Members: x (0/1/2)` pattern, append profile data
				-- before `LFGListUtil_SetSearchEntryTooltip` calls :Show on the tooltip which finalizes layouting
				if lastSeenLeader.name ~= nil and line:find("(%d+)%s*%((%d+/%d+/%d+)%)") ~= nil then
					local profile = Private.GetProfile(lastSeenLeader.name, lastSeenLeader.realm)

					if profile == nil then
						return
					end

					GameTooltip_AddBlankLineToTooltip(GameTooltip)

					DoGameTooltipUpdate(profile)
				end
			end

			hooksecurefunc(GameTooltip, "AddLine", OnGameTooltipLineAdded)
		end

		local function MeetingHornOnItemEnter() end
		local meetingHornItem = nil

		EventRegistry:RegisterFrameEventAndCallback(
			"MODIFIER_STATE_CHANGED",
			---@param owner number
			---@param key string
			---@param down number
			function(owner, key, down)
				if
					string.match(key, "SHIFT") == nil
					or not GameTooltip:IsVisible()
					or (InCombatLockdown() and (not Private.db.Settings.ShowTooltipInCombat or not Private.db.Settings.AllowShiftExpansionInCombat))
				then
					return
				end

				local unit = select(2, GameTooltip:GetUnit())

				if unit then
					if GameTooltip.RefreshData then
						GameTooltip:RefreshData()
					else
						GameTooltip:SetUnit(unit)
					end
				elseif FriendsTooltip and FriendsTooltip:IsVisible() then
					-- delay required if RaiderIO is loaded
					C_Timer.After(0, function()
						pcall(FriendsTooltip.Show, FriendsTooltip)
					end)
				elseif lastLFGListResultID then
					local info = C_LFGList.GetSearchResultInfo(lastLFGListResultID)

					if info == nil then
						lastLFGListResultID = nil
						return
					end

					if Private.IsRetail then
						if Private.AddOnUtils.RaiderIoLoaded then
							-- we call the hooked game fn so we don't have to clear up the tooltip ourselves
							LFGListUtil_SetSearchEntryTooltip(GameTooltip, lastLFGListResultID)
						elseif currentTooltipOwner ~= nil then
							GameTooltip:Hide()
							lastLFGListResultID = nil
							LFGListSearchEntry_OnEnter(currentTooltipOwner)
						end
					else
						-- we call the hooked game fn so we don't have to clear up the tooltip ourselves
						-- however this doesn't work on retail
						LFGListUtil_SetSearchEntryTooltip(GameTooltip, lastLFGListResultID)
					end
				elseif lastHoveredLFGListApplicantMember ~= nil then
					LFGListApplicantMember_OnEnter(lastHoveredLFGListApplicantMember)
				elseif CommunitiesFrame ~= nil then
					if CommunitiesFrame.GuildMemberDetailFrame:IsVisible() and GameTooltip:GetOwner() == CommunitiesFrame.GuildMemberDetailFrame and lastExpandedGuildMemberInfo then
						DoGuildFrameTooltipUpdate(lastExpandedGuildMemberInfo)
					elseif hoveredCommunitiesMemberListEntry then
						hoveredCommunitiesMemberListEntry:OnEnter()
					end
				elseif meetingHornItem then
					MeetingHornOnItemEnter(nil, nil, meetingHornItem)
				end
			end
		)

		if Private.IsRetail or Private.CurrentRealm.region ~= "CN" then
			return
		end

		local addonName = "MeetingHorn"

		if not Private.AddOnUtils.IsAddOnLoaded(addonName) or LibStub == nil then
			return
		end

		local MeetingHorn = LibStub("AceAddon-3.0"):GetAddon(addonName)
		local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
		local Browser = MeetingHorn.MainPanel.Browser
		local ActivityList = Browser.ActivityList

		MeetingHornOnItemEnter = function(_, button, item)
			local r, g, b = GetClassColor(item:GetLeaderClass())
			GameTooltip:SetOwner(Browser, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPLEFT", Browser, "TOPRIGHT", 8, 60)
			GameTooltip:SetText(item:GetTitle())
			GameTooltip:AddLine(item:GetLeader(), r, g, b)
			local level = item:GetLeaderLevel()
			if level then
				local color = GetQuestDifficultyColor(level)
				GameTooltip:AddLine(string.format("%s |cff%02x%02x%02x%s|r", LEVEL, color.r * 255, color.g * 255, color.b * 255, item:GetLeaderLevel()), 1, 1, 1)
			end
			GameTooltip:AddLine(item:GetComment(), 0.6, 0.6, 0.6, true)
			GameTooltip_AddBlankLineToTooltip(GameTooltip)

			local profile = Private.GetProfile(item:GetLeader())
			if profile then
				DoGameTooltipUpdate(profile)
			end
			GameTooltip_AddBlankLineToTooltip(GameTooltip)

			if not item:IsActivity() then
				GameTooltip:AddLine(L["<Double-Click> Whisper to player"], 1, 1, 1)
			end
			GameTooltip:AddLine(L["<Right-Click> Open activity menu"], 1, 1, 1)
			GameTooltip:Show()

			meetingHornItem = item
		end

		ActivityList:SetCallback("OnItemEnter", MeetingHornOnItemEnter)
		ActivityList:SetCallback("OnItemLeave", function()
			meetingHornItem = nil
		end)
	end
end)
