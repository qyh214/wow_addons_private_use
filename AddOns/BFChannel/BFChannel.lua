------------------------------------------------------------
-- BFChannel.lua
--
-- Abin
-- 2011-11-16
------------------------------------------------------------

local L = {
	["channel"] = "大脚世界频道",
	["desc"] = "自动加入%s并设定频道显示条件。",
	["block options"] = "屏蔽设定",
	["block combat"] = "战斗中屏蔽所有信息",
	["block boss combat"] = "首领战中屏蔽所有信息",
	["block ads"] = "屏蔽代练/售G广告",
	["block bulks"] = "屏蔽快速刷屏信息",
	["other channels"] = "其它频道设定",
	["hide"] = "隐藏：",
}

if GetLocale == "zhTW" then
	L = {
		["channel"] = "大腳世界頻道",
		["desc"] = "自動加入%s并設定頻道顯示條件。",
		["block options"] = "屏蔽設定",
		["block combat"] = "戰鬥中屏蔽所有信息",
		["block boss combat"] = "首領戰中屏蔽所有信息",
		["block ads"] = "屏蔽代練/售G廣告",
		["block bulks"] = "屏蔽快速刷屏信息",
		["other channels"] = "其它頻道設定",
		["hide"] = "隱藏：",
	}
end

local GENERAL = GENERAL
local TRADE = TRADE
local LOOK_FOR_GROUP = LOOK_FOR_GROUP
local GetChatWindowChannels = GetChatWindowChannels
local SetChatColorNameByClass = SetChatColorNameByClass
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local ipairs = ipairs
local select = select
local strlenutf8 = strlenutf8
local GetTime = GetTime
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local JoinChannel = SlashCmdList["JOIN"]
local LeaveChannel = SlashCmdList["LEAVE"]
local _

local FILTER_LEN_LIMIT = 60
local FILTER_FREQ_LIMIT = 1.5

local addonName, addon = ...
addon.version = GetAddOnMetadata(addonName, "Version")
addon.db = { blockboss = 1, blockads = 1, blockbulks = 1, hidegeneral = 1, hidetrade = 1, hidelfg = 1 }

local channelList = {}

local function UpdateChannelList()
	local temp = { GetChannelList() }
	wipe(channelList)
	local index, token
	for index, token in ipairs(temp) do
		if type(token) == "string" then
			channelList[token] = temp[index - 1]
		end
	end
end

local function FindBFChannel()
	local i, id, channel
	for i = 1, NUM_CHAT_WINDOWS do
		local channels = { GetChatWindowChannels(i) }
		for id, channel in ipairs(channels) do
			if channel == L["channel"] then
				return channels[id + 1] -- Channel index, it's zero-based!
			end
		end
	end
end

local function Frame_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 2 then
		self.elapsed = 0
		local id = FindBFChannel()
		if id then
			self:SetScript("OnUpdate", nil) -- Channel joined successfully, remove "OnUpdate" script
			SetChatColorNameByClass("CHANNEL"..(id + 1), true) -- Apply name class color
		else
			JoinChannel(L["channel"]) -- Try to join the channel
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")

local AWAKEN_EVENTS = { "REQUEST_CEMETERY_LIST_RESPONSE", "CURSOR_UPDATE", "CHAT_MSG_CHANNEL" }
do
	local e
	for _, e in ipairs(AWAKEN_EVENTS) do
		frame:RegisterEvent(e)
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGOUT" then
		self:SetScript("OnUpdate", nil)
		LeaveChannel(L["channel"])
	elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
		UpdateChannelList()
	else
		local e
		for _, e in ipairs(AWAKEN_EVENTS) do
			self:UnregisterEvent(e)
		end
		UpdateChannelList()
		self:SetScript("OnUpdate", Frame_OnUpdate)
	end
end)

-----------------------------------------
-- Message filters
-----------------------------------------

local function FindHyperlink(text, init)
	local pos1, pos2 = strfind(text, "|cff(.-)%[(.-)%]|h|r", init)
	if pos1 then
		--print("link found: ", strsub(text, pos1, pos2))
		return pos2 - pos1 + 1, pos2 + 1
	end
end

local function IsCommonChannelBlocked(id)
	return (addon.db.hidegeneral and id == channelList[GENERAL]) or (addon.db.hidetrade and id == channelList[TRADE]) or (addon.db.hidelfg and id == channelList[LOOK_FOR_GROUP])
end

local messageSenders = {}

local function FilterFunc(self, event, text, sender, _, _, _, _, _, id, channel)
	if channel ~= L["channel"] then
		return IsCommonChannelBlocked(id)
	end

	if not text or not sender then
		return
	end

	-- Block in combat
	if addon.db.blockcombat and InCombatLockdown() then
		return 1
	end

	-- Block in boss combat
	if addon.db.blockboss and UnitExists("boss1") then
		return 1
	end

	-- Block bulk messages
	if addon.db.blockbulks then
		local now = GetTime()
		local lastSent = messageSenders[sender]
		messageSenders[sender] = now
		if lastSent and now - lastSent < FILTER_FREQ_LIMIT then
			return 1
		end
	end

	-- Block ads
	if addon.db.blockads then
		local len = strlenutf8(text)
		if len <= FILTER_LEN_LIMIT then
			return
		end

		-- Hyperlinks are always allowed and length of which should not be taken into account
		local linkLen, position = FindHyperlink(text, 1)
		if linkLen then
			len = len - linkLen

			-- There could be up to 3 hyperlinks in one message but we only need to process 2
			linkLen = FindHyperlink(text, position)
			if linkLen then
				len = len - linkLen
			end
		end

		if len > FILTER_LEN_LIMIT then
			return 1
		end
	end
end

local function FilterNotifyFunc(self, event, text, sender, _, _, _, _, _, id, channel)
	return channel == L["channel"]
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", FilterNotifyFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", FilterNotifyFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE_USER", FilterNotifyFunc)

-----------------------------------------
-- Option frame
-----------------------------------------

local page = UICreateInterfaceOptionPage("BFChannelOptionFrame", L["channel"], format(L["desc"], L["channel"]))

local function Group_OnCheckInit(self, value)
	return addon.db[value]
end

local function Group_OnCheckChanged(self, value, checked)
	addon.db[value] = checked
end

local group1 = page:CreateMultiSelectionGroup(L["block options"])
page:AnchorToTopLeft(group1)
group1:AddButton(L["block combat"], "blockcombat")
group1:AddButton(L["block boss combat"], "blockboss")
group1:AddButton(L["block ads"], "blockads")
group1:AddButton(L["block bulks"], "blockbulks")
group1.OnCheckInit = Group_OnCheckInit
group1.OnCheckChanged = Group_OnCheckChanged

local group2 = page:CreateMultiSelectionGroup(L["other channels"])
group2:SetPoint("TOPLEFT", group1[-1], "BOTTOMLEFT", 0, -12)
group2:AddButton(L["hide"]..GENERAL, "hidegeneral")
group2:AddButton(L["hide"]..TRADE, "hidetrade")
group2:AddButton(L["hide"]..LOOK_FOR_GROUP, "hidelfg")
group2.OnCheckInit = Group_OnCheckInit
group2.OnCheckChanged = Group_OnCheckChanged

page:RegisterEvent("ADDON_LOADED")
page:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		if type(BFChannelDB) ~= "table" then
			BFChannelDB = addon.db
		else
			addon.db = BFChannelDB
		end
		self:UnregisterAllEvents()
	end
end)

SLASH_BFCHANNEL1 = "/bfc"
SLASH_BFCHANNEL2 = "/bfchannel"
SlashCmdList["BFCHANNEL"] = function() page:Open() end