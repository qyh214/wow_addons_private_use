--[[
	Description: Titan Panel plugin that shows your Reputations
	Author: Eliote
--]]

local ADDON_NAME, L = ...;
local VERSION = GetAddOnMetadata(ADDON_NAME, "Version")


local Color = {}
Color.WHITE = "|cFFFFFFFF"
Color.RED = "|cFFDC2924"
Color.YELLOW = "|cFFFFF244"
Color.GREEN = "|cFF3DDC53"
Color.ORANGE = "|cFFE77324"

local SEX = UnitSex("player")


-- @return current, maximun, color, standingText
local function GetValueAndMaximum(standingId, barValue, bottomValue, topValue, factionId)
	if (standingId == nil) then return "0", "0", "|cFFFF0000", "??? - " .. (factionId .. "?") end

	local current = barValue - bottomValue
	local maximun = topValue - bottomValue
	local color = "|cFF00FF00"
	local standingText = " (" .. ((SEX == 2 and _G["FACTION_STANDING_LABEL" .. standingId]) or _G["FACTION_STANDING_LABEL" .. standingId .. "_FEMALE"] or "?") .. ")"

	if (C_Reputation.IsFactionParagon(factionId)) then
		color = "|cFF00FFFF"

		local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionId);

		if hasRewardPending then standingText = standingText .. "*" end

		return mod(currentValue, threshold), threshold, color, standingText, hasRewardPending
	end

	local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionId)
	if (friendID) then
		standingText = " (" .. friendTextLevel .. ")"

		if (nextFriendThreshold) then
			maximun, current = nextFriendThreshold - friendThreshold, friendRep - friendThreshold
		else
			maximun, current = 1, 1
		end
	else
		if standingId == 1 then
			color = "|cFFCC2222"
		elseif standingId == 2 then
			color = "|cFFFF0000"
		elseif standingId == 3 then
			color = "|cFFEE6622"
		elseif standingId == 4 then
			color = "|cFFFFFF00"
		elseif standingId == 5 then
			color = "|cFF00FF00"
		elseif standingId == 6 then
			color = "|cFF00FF88"
		elseif standingId == 7 then
			color = "|cFF00FFCC"
		elseif standingId == 8 then
			color = "|cFF00FFFF"
		end
	end

	return current, maximun, color, standingText
end

local function GetButtonText(self, id)
	local name, standingID, bottomValue, topValue, barValue, factionId = GetWatchedFactionInfo()

	if not name then
		return "", ""
	end
	local value, max, color, _, hasRewardPending = GetValueAndMaximum(standingID, barValue, bottomValue, topValue, factionId)

	local text = "" .. color

	local showvalue = TitanGetVar(id, "ShowValue")
	local hideMax = TitanGetVar(id, "HideMax")
	if showvalue then
		text = text .. value

		if not hideMax then
			text = text .. "/" .. max
		end
	end
	if TitanGetVar(id, "ShowPercent") then
		local percent = math.floor((value) * 100 / (max))
		if (max == 0) then
			percent = 100
		end

		if showvalue then
			text = text .. " (" .. percent .. "%)"
		else
			text = text .. percent .. "%"
		end

		if hasRewardPending then
			text = "*" + text
		end
	end

	return name .. ":", text
end

local function IsNeutral(factionId, standingId)
	local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionId)

	if friendID then
		return false
	end

	return standingId <= 4
end

local function IsMaxed(factionId, standingId)
	local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionId)

	if friendID then
		return not nextFriendThreshold
	end

	return standingId == 8
end

local function GetTooltipText(self, id)
	local text = ""

	local hideNeutral = TitanGetVar(id, "HideNeutral")
	local showHeaders = TitanGetVar(id, "ShowHeaders")
	local alwaysShowParagon = TitanGetVar(id, "AlwaysShowParagon")

	local numFactions = GetNumFactions()

	local topText = ""

	local headerText
	local childText = ""

	for factionIndex = 1, numFactions do
		local name, _, standingId, bottomValue, topValue, earnedValue, atWarWith, _, isHeader, _, hasRep, isWatched, _, factionId, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex)

		if name then
			if isWatched then
				local value, max, color, standing = GetValueAndMaximum(standingId, earnedValue, bottomValue, topValue, factionId)
				local nameColor = (atWarWith and Color.RED) or ""

				topText = nameColor .. name .. "\t" .. color .. value .. "/" .. max .. standing .. "|r\n\n"
			end

			if isHeader then
				-- if the previous header has child
				if (headerText and childText ~= "") then
					text = text .. headerText .. childText
					headerText = nil
					childText = ""
				end

				if showHeaders then
					if hasRep then
						local value, max, color, standing = GetValueAndMaximum(standingId, earnedValue, bottomValue, topValue, factionId)

						headerText = Color.WHITE .. name .. "\t" .. color .. value .. "/" .. max .. standing .. "|r\n"
					else
						headerText = Color.WHITE .. name .. "|r\n"
					end
				end
			else
				local hideExalted = TitanGetVar(id, "HideExalted")
				local show = true

				if IsFactionInactive(factionIndex) then
					show = false
				elseif hideNeutral and IsNeutral(factionId, standingId) then
					show = false
				elseif hideExalted and IsMaxed(factionId, standingId) then
					show = false
				end

				if (alwaysShowParagon and C_Reputation.IsFactionParagon(factionId)) then
					show = true
				end

				if show then
					local value, max, color, standing = GetValueAndMaximum(standingId, earnedValue, bottomValue, topValue, factionId)
					local nameColor = (atWarWith and Color.RED) or ""

					childText = childText .. "-" .. nameColor .. name .. "\t" .. color .. value .. "/" .. max .. standing .. "|r\n"
				end
			end
		end
	end

	if (childText ~= "") then
		if (headerText) then
			text = text .. headerText
		end

		text = text .. childText
	end

	return topText .. text
end

local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		TitanPanelButton_UpdateButton(self.registry.id)
	end,
	UPDATE_FACTION = function(self)
		TitanPanelButton_UpdateButton(self.registry.id)
	end
}

local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("ReputationFrame");
	end
end

local menus = {
	{ type = "space" },
	{ type = "toggle", text = L["HideNeutral"], var = "HideNeutral", def = false, keepShown = true },
	{ type = "toggle", text = L["ShowValue"], var = "ShowValue", def = true, keepShown = true },
	{ type = "toggle", text = L["ShowPercent"], var = "ShowPercent", def = true, keepShown = true },
	{ type = "toggle", text = L["ShowHeaders"], var = "ShowHeaders", def = true, keepShown = true },
	{ type = "toggle", text = L["HideMax"], var = "HideMax", def = false, keepShown = true },
	{ type = "toggle", text = L["HideExalted"], var = "HideExalted", def = false, keepShown = true },
	{ type = "toggle", text = L["AlwaysShowParagon"], var = "AlwaysShowParagon", def = true, keepShown = true },
	{ type = "space" },
	{ type = "rightSideToggle" }
}

L.Elib({
	id = "TITAN_REPUTATION_XP",
	name = L["Reputation"],
	tooltip = L["Reputation"],
	icon = "Interface\\Icons\\INV_MISC_NOTE_02",
	category = "TEST_CATEGORY",
	version = VERSION,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	eventsTable = eventsTable,
	menus = menus,
	onClick = OnClick,
	onLoad = function()
		local categories = LibStub("AceLocale-3.0"):GetLocale(TITAN_ID, true)["TITAN_PANEL_MENU_CATEGORIES"]
		table.insert(categories, "TESTE 1 2 3")
		table.insert(TITAN_PANEL_BUTTONS_PLUGIN_CATEGORY, "TEST_CATEGORY")
	end
})


