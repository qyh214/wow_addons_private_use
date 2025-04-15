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

	local specs = {}

	for _, spec in ipairs(profile.specs) do
		local percentile = spec.average == nil and "" or Private.EncodeWithPercentileColor(spec.average, Private.FormatAveragePercentile(spec.average))
		table.insert(specs, string.format("%s %s", Private.EncodeWithTexture(Private.GetSpecIcon(spec.type)), percentile))
	end

	local progress = string.format(
		"%d/%d %s %s",
		profile.progress.count,
		profile.progress.total,
		Private.GetDifficultyString(profile.difficulty, profile.size, profile.zoneId),
		table.concat(specs, " ")
	)

	return false, text .. " - " .. progress, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OnChatMessage)
