---@class Private
local Private = select(2, ...)

local validTypes = {
	ARENAENEMY = true,
	BN_FRIEND = true,
	CHAT_ROSTER = true,
	COMMUNITIES_GUILD_MEMBER = true,
	COMMUNITIES_WOW_MEMBER = true,
	ENEMY_PLAYER = true,
	FOCUS = true,
	FRIEND = true,
	GUILD = true,
	GUILD_OFFLINE = true,
	PARTY = true,
	PLAYER = true,
	RAID = true,
	RAID_PLAYER = true,
	SELF = true,
	TARGET = true,
	WORLD_STATE_SCORE = true,
}

---@class LeaderInfo
---@field name string|nil
---@field realm string|number|nil
---@field projectId number
local currentDropDownSelection = {
	name = nil,
	realm = nil,
	projectId = WOW_PROJECT_ID,
}

local function ExtractCharacterInformation(context)
	-- always reset to current to avoid stale state
	currentDropDownSelection.projectId = WOW_PROJECT_ID

	local unit = context.unit

	-- via party or target frames
	if UnitExists(unit) then
		if not UnitIsPlayer(unit) then
			return
		end

		local name, realm = UnitName(unit)
		currentDropDownSelection.name = name
		currentDropDownSelection.realm = realm
	end

	-- via friendlist
	if not currentDropDownSelection.name and context.bnetIDAccount then
		local index = BNGetFriendIndex(context.bnetIDAccount)

		if not index then
			return
		end

		for i = 1, C_BattleNet.GetFriendNumGameAccounts(index), 1 do
			local accountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i)

			if accountInfo and accountInfo.clientProgram == BNET_CLIENT_WOW then
				currentDropDownSelection.name = accountInfo.characterName

				if accountInfo.realmDisplayName then
					currentDropDownSelection.realm = accountInfo.realmDisplayName
				elseif accountInfo.richPresence then
					-- when checking a character from a different project id (classic <-> retail),
					-- realm name is always missing. accountInfo.realmID is misleading,
					-- it's the underlying connected realm id which cannot be resolved to a specific realm.
					-- however, the rich presence will always indicate "Zone - Realm".
					-- important to pick the last part of the string as zones may include dashes themselves, e.g. Nerub-ar Palace or Ara-Kara
					local parts = strsplittable("-", accountInfo.richPresence)
					local realm = parts[#parts]

					currentDropDownSelection.realm = realm
					currentDropDownSelection.projectId = accountInfo.wowProjectID
				else
					currentDropDownSelection.realm = Private.CurrentRealm.name
				end
				break
			end
		end
	end

	-- /who window
	-- Guild & Community window (Retail)
	if not currentDropDownSelection.name and context.name then
		if context.whoIndex then
			local info = C_FriendList.GetWhoInfo(context.whoIndex)

			if info then
				local name, realm = strsplit("-", info.fullName)

				currentDropDownSelection.name = name
				currentDropDownSelection.realm = realm
			end
		elseif context.clubInfo and context.clubInfo.clubType == Enum.ClubType.Guild then -- Guild
			local info = context.clubMemberInfo

			if info then
				if Private.IsRetail then
					currentDropDownSelection.name = context.name
					currentDropDownSelection.realm = context.server
				else
					local name, realm = strsplit("-", context.name)

					currentDropDownSelection.name = name
					currentDropDownSelection.realm = realm or context.server
				end
			end
		elseif context.clubInfo and context.clubInfo.clubType == Enum.ClubType.Character then -- Community
			local info = context.clubMemberInfo

			if info then
				local name, realm = strsplit("-", info.name)

				currentDropDownSelection.name = name
				currentDropDownSelection.realm = realm
			end
		elseif context.which == "FRIEND" and context.chatTarget then
			if Private.IsClassicEra then
				if GuildFrame:IsVisible() then
					local matchFound = false

					for i = 1, GUILDMEMBERS_TO_DISPLAY do
						local fullName = GetGuildRosterInfo(i)

						if fullName == context.chatTarget then
							matchFound = true
							currentDropDownSelection.name = context.name
							currentDropDownSelection.realm = context.server
							break
						end
					end

					-- could not find a match from guild view, fallback to showing it regardless
					if not matchFound then
						currentDropDownSelection.name = context.name
						currentDropDownSelection.realm = context.server
					end
				end
			elseif Private.IsRetail or Private.IsMists then
				local name, realm = strsplit("-", context.chatTarget)

				currentDropDownSelection.name = name
				currentDropDownSelection.realm = realm
			end
		elseif context.which ~= "BN_FRIEND" then
			-- ignore:
			-- BN_FRIEND because offline bn friends have the `name` set but that's their bnet name

			-- right-clicking a guild member in classic doesn't contain level info and is considered the same
			-- frame origin as the friend list

			currentDropDownSelection.name = context.name
			currentDropDownSelection.realm = context.realm
		end
	end

	-- Quick Join
	if not currentDropDownSelection.name and context.quickJoinButton then
		local memberInfo = context.quickJoinButton.Members[1]

		local linkString = LinkUtil.SplitLink(memberInfo.playerLink)
		local linkType, linkDisplayText, bnetIDAccount = strsplit(":", linkString)

		if linkType == "BNplayer" then -- quick join entry is from a player in your friend list
			local index = BNGetFriendIndex(bnetIDAccount)

			for i = 1, C_BattleNet.GetFriendNumGameAccounts(index), 1 do
				local accountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i)

				if accountInfo and accountInfo.clientProgram == BNET_CLIENT_WOW then
					currentDropDownSelection.name = accountInfo.characterName
					-- in contrast to the above branch where `realmDisplayName` can be missing for x-project bnet friend list entries,
					-- it must be always present for this scenario as LFG entries from a different project don't show up
					currentDropDownSelection.realm = accountInfo.realmDisplayName
					break
				end
			end
		elseif linkType == "player" then -- quick join entry is from a player on your realm
			currentDropDownSelection.name = linkDisplayText
			currentDropDownSelection.realm = Private.CurrentRealm.name
		end
	end

	-- Group Finder
	if not currentDropDownSelection.name and context.menuList then
		for i = 1, #context.menuList do
			local item = context.menuList[i]

			if item and (item.text == WHISPER_LEADER or item.text == WHISPER) then
				local name, realm = strsplit("-", item.arg1)

				currentDropDownSelection.name = name
				currentDropDownSelection.realm = realm
			end
		end
	end
end

if Menu and Menu.ModifyMenu then
	local function ModifyMenuCallback(owner, rootDescription, contextData)
		if not Private.db.Settings.MenuDropdownIntegration then
			return
		end

		ExtractCharacterInformation(contextData)

		if currentDropDownSelection.name == nil then
			return
		end

		rootDescription:CreateDivider()
		rootDescription:CreateTitle("Warcraft Logs")
		rootDescription:CreateButton(Private.L.CopyProfileURL, function()
			Private.ShowCopyProfileUrlPopup(currentDropDownSelection)
		end)
	end

	for tagName in pairs(validTypes) do
		local tag = string.format("MENU_UNIT_%s", tagName)

		---@see https://github.com/Gethe/wow-ui-source/blob/5076663b5454de9e7522320994ea7cc15b2a961c/Interface/AddOns/Blizzard_Menu/11_0_0_MenuImplementationGuide.lua#L409-L414
		Menu.ModifyMenu(tag, ModifyMenuCallback)
	end

	Menu.ModifyMenu("MENU_LFG_FRAME_SEARCH_ENTRY", function(owner, rootDescription, contextData)
		if not Private.db.Settings.MenuDropdownIntegration then
			return
		end

		local id = owner.resultID

		local entry = C_LFGList.GetSearchResultInfo(id)

		if entry == nil then
			return
		end

		local name, realm = strsplit("-", entry.leaderName)
		currentDropDownSelection.name = name
		currentDropDownSelection.realm = realm

		if currentDropDownSelection.name == nil then
			return
		end

		rootDescription:CreateDivider()
		rootDescription:CreateTitle("Warcraft Logs")
		rootDescription:CreateButton(Private.L.CopyProfileURL, function()
			Private.ShowCopyProfileUrlPopup(currentDropDownSelection)
		end)
	end)
else
	---@type LibDropDownExtension
	local LibDropDownExtension = LibStub and LibStub:GetLibrary("LibDropDownExtension-1.0", true)

	if not LibDropDownExtension then
		return
	end

	---@type CustomDropDownOption[]
	local customDropDownOptions = {
		---@diagnostic disable-next-line: missing-fields
		{
			text = Private.L.CopyProfileURL,
			func = function()
				Private.ShowCopyProfileUrlPopup(currentDropDownSelection)
			end,
		},
	}

	---@param dropdown CustomDropDown
	---@return boolean
	local function IsValidDropDown(dropdown)
		return dropdown == LFGListFrameDropDown or dropdown == QuickJoinFrameDropDown or (type(dropdown.which) == "string" and validTypes[dropdown.which])
	end

	---@type LibDropDownExtensionCallback
	local function OnShow(dropdown, event, options, level, data)
		if not Private.db.Settings.MenuDropdownIntegration then
			return
		end

		if not IsValidDropDown(dropdown) then
			return
		end

		ExtractCharacterInformation(dropdown)

		if not currentDropDownSelection.name then
			return false
		end

		if options[1] then
			return true
		end

		local index = 0
		for i = 1, #customDropDownOptions do
			local option = customDropDownOptions[i]

			index = index + 1
			options[index] = option
		end

		return true
	end

	local function OnHide(dropdown, event, options, level, data)
		if not Private.db.Settings.MenuDropdownIntegration then
			return
		end

		currentDropDownSelection.name = nil
		currentDropDownSelection.realm = nil
		currentDropDownSelection.projectId = WOW_PROJECT_ID

		if options[1] then
			for i = #options, 1, -1 do
				options[i] = nil
			end

			return true
		end
	end

	LibDropDownExtension:RegisterEvent("OnShow", OnShow, 1)
	LibDropDownExtension:RegisterEvent("OnHide", OnHide, 1)
end
