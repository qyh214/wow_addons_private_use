---@class Private
local Private = select(2, ...)

---@param text string
---@return string
local function FormatToPattern(text)
	text = text:gsub("%%", "%%%%")
	text = text:gsub("%.", "%%%.")
	text = text:gsub("%?", "%%%?")
	text = text:gsub("%+", "%%%+")
	text = text:gsub("%-", "%%%-")
	text = text:gsub("%(", "%%%(")
	text = text:gsub("%)", "%%%)")
	text = text:gsub("%[", "%%%[")
	text = text:gsub("%]", "%%%]")
	text = text:gsub("%%%%s", "(.-)")
	text = text:gsub("%%%%d", "(%%d+)")
	text = text:gsub("%%%%%%[%d%.%,]+f", "([%%d%%.%%,]+)")
	return text
end

local whoGuildMember = "^" .. FormatToPattern(WHO_LIST_GUILD_FORMAT) .. "$"
local whoGuildless = "^" .. FormatToPattern(WHO_LIST_FORMAT) .. "$"

---@param self Frame
---@param event string
---@param text string
---@return false, string|nil, ...
local function OnChatMessage(self, event, text, ...)
	if event ~= "CHAT_MSG_SYSTEM" or not Private.IsInitialized then
		return false
	end

	local nameLink, name, _, _, _, _, zone = text:match(whoGuildMember)

	if not nameLink or not zone then
		nameLink, name = text:match(whoGuildless)
	end

	if not nameLink then
		return false
	end

	local profile = Private.GetProfile(name, Private.CurrentRealm.name)

	if profile == nil then
		return false
	end

	local progress = {}
	local specs = {}
	local bestSection = profile.sections[1]

	if bestSection ~= nil then
		progress.zoneId = bestSection.zoneId
		progress.difficultyId = bestSection.difficultyId
		progress.sizeId = bestSection.sizeId
		progress.killed = bestSection.anySpecRankings.progressKilled
		progress.possible = bestSection.anySpecRankings.progressPossible

		for _, rankings in ipairs(bestSection.perSpecRankings) do
			local percentile = Private.EncodeWithPercentileColor(rankings.bestAverage, Private.FormatAveragePercentile(rankings.bestAverage))
			table.insert(specs, string.format("%s %s", Private.EncodeWithTexture(Private.GetSpecIcon(rankings.spec)), percentile))
		end
	else
		progress.zoneId = profile.summary.zoneId
		progress.difficultyId = profile.summary.difficultyId
		progress.sizeId = profile.summary.sizeId
		progress.killed = profile.summary.progressKilled
		progress.possible = profile.summary.progressPossible
	end

	local profileString =
		string.format("%s %s", Private.GetProgressString(progress.zoneId, progress.difficultyId, progress.sizeId, progress.killed, progress.possible, false), table.concat(specs, " "))

	return false, text .. " - " .. profileString, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OnChatMessage)
