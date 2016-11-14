local ADDON, Addon = ...
local Mod = Addon:NewModule('Keystone')

local poorColor = select(4, GetItemQualityColor(LE_ITEM_QUALITY_POOR))
local epicColor = select(4, GetItemQualityColor(LE_ITEM_QUALITY_EPIC))

local events = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local function filter(self, event, msg, ...)
	local msg2 = msg:gsub("(|c"..epicColor.."|Hitem:138019:([0-9:]+)|h(%b[])|h|r)", function(msg, itemString, itemName)
		local info = { strsplit(":", itemString) }
		local mapID = tonumber(info[13])
		local mapLevel = tonumber(info[14])
		if not mapID or not mapLevel then return msg end

		local offset = 15
		if mapLevel >= 4 then offset = offset + 1 end
		if mapLevel >= 7 then offset = offset + 1 end
		if mapLevel >= 10 then offset = offset + 1 end
		local depleted = info[offset] ~= "1"

		if depleted then
			return msg:gsub("|c"..epicColor, "|c"..poorColor)
		else
			return msg
		end
	end)
	msg2 = msg2:gsub("(|Hitem:138019:([0-9:]+)|h(%b[])|h)", function(msg, itemString, itemName)
		local info = { strsplit(":", itemString) }
		local mapID = tonumber(info[13])
		local mapLevel = tonumber(info[14])

		if mapID and mapLevel then
			local mapName = C_ChallengeMode.GetMapInfo(mapID)
			return msg:gsub(itemName:gsub("(%W)","%%%1"), format(Addon.Locale.keystoneFormat, mapName, mapLevel))
		else
			return msg
		end
	end)
	if msg2 ~= msg then
		return false, msg2, ...
	end
end

for _, v in pairs(events) do
	ChatFrame_AddMessageEventFilter(v, filter)
end
