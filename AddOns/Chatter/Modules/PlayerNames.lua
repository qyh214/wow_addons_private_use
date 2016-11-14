local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Player Name Polish", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
local AceTab = LibStub("AceTab-3.0")

mod.modName = L["Player Names"]

local format = _G.string.format
local gsub = _G.string.gsub
local strlower = _G.string.lower
local strmatch = _G.string.match
local strsub = _G.string.sub

local pairs = _G.pairs
local tinsert = _G.tinsert
local wipe = _G.wipe

local select = _G.select
local type = _G.type

local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetChannelName = _G.GetChannelName
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetGuildRosterSelection = _G.GetGuildRosterSelection
local GetGuildRosterShowOffline = _G.GetGuildRosterShowOffline
local GetNumFriends = _G.GetNumFriends
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumWhoResults = _G.GetNumWhoResults
local GetWhoInfo = _G.GetWhoInfo
local GuildRoster = _G.GuildRoster
local SetGuildRosterSelection = _G.SetGuildRosterSelection
local SetGuildRosterShowOffline = _G.SetGuildRosterShowOffline
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName

local local_names = {}
local leftBracket, rightBracket, separator
local colorSelfInText, emphasizeSelfInText

local player

local channels = {
	GUILD = {},
	PARTY = {},
	RAID = {}
}
local colorMethods = {
	CLASS = L["Class"],
	NAME = L["Name"],
	NONE = L["None"],
}

local defaults = {
	realm = {
		names = {},
		levels = {},
	},
	profile = {
		saveData = false,
		blizzardNameColoring = true,
		leftBracket = "[",
		rightBracket = "]",
		bnetBrackets = true,
		separator = ":",
		useTabComplete = true,
		colorSelfInText = true,
		emphasizeSelfInText = true,
		noRealNames = false,
	},
}
local default_nick_color = { ["r"] = 0.627, ["g"] = 0.627, ["b"] = 0.627 }

local localizedToSystemClass = {}
for sys, loc in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	localizedToSystemClass[loc] = sys
end
for sys, loc in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	localizedToSystemClass[loc] = sys
end

local tabComplete
do
	function tabComplete(t, text, pos)
		local word = strsub(text, pos)
		if #word == 0 then return end
		local cf = ChatEdit_GetActiveWindow()
		local channel = cf:GetAttribute("chatType")
		if channel == "CHANNEL" then
			channel = strlower(select(2, GetChannelName(cf:GetAttribute("channelTarget"))))
		elseif channel == "OFFICER" then
			channel = "GUILD"
		elseif channel == "RAID_WARNING" or channel == "RAID_LEADER" or channel == "INSTANCE_CHAT" or channel == "INSTANCE_CHAT_LEADER" then
			channel = "RAID"
		end
		if channels[channel] then
			local searchword = "^"..strlower(word)
			for k, v in pairs(channels[channel]) do
				if strmatch(strlower(k), searchword) then
					tinsert(t, k)
				end
			end
		end
		return t
	end
end

local cache = {};

local function wipeCache()
	wipe(cache)
end

local function updateSaveData(v)
	if v then
		for k, v in pairs(local_names) do
			mod.db.realm.names[k] = v
		end
	end
end

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("PlayerNames", defaults)

	for k, v in pairs(self.db.realm.names) do
		if type(v) == "string" then
			self.db.realm.names[k] = {class = v}
		end
	end

	if self.db.global and self.db.global.names then
		self.db.global.names = {}	-- get rid of old data
	end
end

function mod:Decorate(frame)
	self:RawHook(frame, "AddMessage", true)
end

local storedName = nil

function mod:OnEnable()
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("WHO_LIST_UPDATE")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("CHAT_MSG_SYSTEM", "WHO_LIST_UPDATE")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
	self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
	self:RegisterEvent("CHAT_MSG_CHANNEL", "CHAT_MSG_CHANNEL_JOIN")

	leftBracket, rightBracket, separator = self.db.profile.leftBracket, self.db.profile.rightBracket, self.db.profile.separator
	colorSelfInText, emphasizeSelfInText = self.db.profile.colorSelfInText, self.db.profile.emphasizeSelfInText
	if IsInGuild() then
		GuildRoster()
	end

	player = UnitName("player") -- can be UNKNOWN when main chunk loads, so do it here.
	self:AddPlayer(player, (select(2, UnitClass("player"))), UnitLevel("player"))

	self:GROUP_ROSTER_UPDATE()

	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local cf = _G[frame]
		self:RawHook(cf, "AddMessage", true)
	end
	if self.db.profile.useTabComplete then
		AceTab:RegisterTabCompletion(addon, nil, tabComplete)
	end

	if CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS.RegisterCallback then
		CUSTOM_CLASS_COLORS:RegisterCallback(wipeCache)
	end

	if self.db.profile.noRealNames then
		storedName = {}
		local _, n = BNGetNumFriends()
		for i=1, n do
			local _, _, _, _, toon, id = BNGetFriendInfo(i)
			storedName[id] = toon
		end
	end

	self:TogglePlayerColors(self.db.profile.blizzardNameColoring)
end

function mod:OnDisable()
	if AceTab:IsTabCompletionRegistered(addon) then
		AceTab:UnregisterTabCompletion(addon)
	end

	if CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS.UnregisterCallback then
		CUSTOM_CLASS_COLORS:UnregisterCallback(wipeCache)
	end
end

function mod:AddPlayer(name, class, level, save)
	if not self.db.realm.names then self.db.realm.names = {} end
	if name and class and class ~= UNKNOWN then
		if save or self.db.realm.names[name] then	-- if we already have an entry saved from elsewhere, we update it regardless of the requested "save" type - nothing else makes sense
			self.db.realm.names[name] = self.db.realm.names[name] or {}
			if level and level ~= 0 then
				self.db.realm.names[name].level = level
			end
		else
			local_names[name] = local_names[name] or {}
			local_names[name].class = class
			if level and level ~= 0 then
				local_names[name].level = level
			end
		end
		cache[name] = nil
	end
end

function mod:FRIENDLIST_UPDATE(evt)
	for i = 1, GetNumFriends() do
		local name, level, class = GetFriendInfo(i)
		if class then
			self:AddPlayer(name, localizedToSystemClass[class], level, self.db.profile.saveFriends)
		end
	end
end

function mod:GUILD_ROSTER_UPDATE(evt)
	if not IsInGuild() then return end
	wipe(channels.GUILD)
	for i = 1, GetNumGuildMembers() do
		local name, _, _, level, _, _, _, _, online, _, class = GetGuildRosterInfo(i)
		if online then
			channels.GUILD[name] = name
		end
		self:AddPlayer(name, class, level, self.db.profile.saveGuild)
	end
end

function mod:GROUP_ROSTER_UPDATE(evt) -- WoW5 only
	wipe(channels.PARTY)
	wipe(channels.RAID)

	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local n, _, _, l, _, c = GetRaidRosterInfo(i)
			if n and c and l then
				channels.RAID[n] = true
				self:AddPlayer(n, c, l, self.db.profile.saveParty)
			end
		end
	elseif IsInGroup() then
		-- Bug fix for MoP, GetNumGroupMembers includes yourself
		local max = GetNumGroupMembers() - 1
		for i = 1, max do
			local u = "party" .. i
			local n = UnitName(u)
			local _, c = UnitClass(u)
			local l = UnitLevel(u)
			channels.PARTY[n] = true
			self:AddPlayer(n, c, l, self.db.profile.saveParty)
		end
	end
end

function mod:PLAYER_TARGET_CHANGED(evt)
	if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end
	local _, c = UnitClass("target")
	local l = UnitLevel("target")
	self:AddPlayer(UnitName("target"), c, l, self.db.profile.saveTarget)
end

function mod:UPDATE_MOUSEOVER_UNIT(evt)
	if not UnitExists("mouseover") or not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end
	local _, c = UnitClass("mouseover")
	local l = UnitLevel("mouseover")
	self:AddPlayer(UnitName("mouseover"), c, l, self.db.profile.saveTarget)
end

function mod:WHO_LIST_UPDATE(evt)
	if GetNumWhoResults() <= 3 or self.db.profile.saveAllWho then
		for i = 1, GetNumWhoResults() do
			local name, _, level, _, _, _, class = GetWhoInfo(i)
			if class then
				self:AddPlayer(name, class, level, self.db.profile.saveWho)
			end
		end
	end
end

function mod:CHAT_MSG_CHANNEL_JOIN(evt, _, name, _, _, _, _, _, _, chan)
	local chanlower = strlower(chan)
	channels[chanlower] = channels[chanlower] or {}
	channels[chanlower][name] = true
end

function mod:CHAT_MSG_CHANNEL_LEAVE(evt, _, name, _, _, _, _, _, _, chan)
	local chanlower = strlower(chan)
	if not channels[chanlower] then return end
	channels[chanlower][name] = nil
end

function mod:GetColor(className, isLocal)
	if isLocal then
		className = localizedToSystemClass[className]
	end
	local tbl = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[className] or RAID_CLASS_COLORS[className]
	if not tbl then return end
	return format("%02x%02x%02x", tbl.r*255, tbl.g*255, tbl.b*255)
end

local function fixLogin(head,id,misc,who,xtra,colon)
	local bleftBracket, brightBracket = "",""
	if mod.db.profile.bnetBrackets then
		bleftBracket = leftBracket
		brightBracket = rightBracket
	end
	if strmatch(misc,"BN_INLINE_TOAST_ALERT") then
		return head..id..misc..bleftBracket..who..brightBracket..xtra
	else
		return head..id..misc..bleftBracket..who..brightBracket..xtra..colon
	end
end

--[[
	Taken from Basic Chat Mods since funkeh already did the work
--]]
local function changeBNetName(misc, id, moreMisc, fakeName, tag, colon)
	local _, charName, _, _, _, _, _, localizedClass = BNGetGameAccountInfo(id)
	if charName ~= "" then
		if storedName then storedName[id] = charName end --Store name for logoff events, if enabled
		--Replace real name with charname if enabled
		fakeName = mod.db.profile.noRealNames and charName or fakeName
	else
		--Replace real name with stored charname if enabled, for logoff events
		if mod.db.profile.noRealNames and storedName and storedName[id] then
			fakeName = storedName[id]
			storedName[id] = nil
		end
	end

	local bleftBracket = ""
	local brightBracket = ""

	local waslogin = false

	if strmatch(moreMisc,"BN_INLINE_TOAST_ALERT") then
		-- We got an alert strip the colon out of the misc its the last char
		misc = strsub(misc, 1, -2)
		waslogin = true
	end

	if not mod.db.profile.bnetBrackets then
		bleftBracket = leftBracket
		brightBracket = rightBracket
	end

	if localizedClass then --Friend logging off/Starcraft 2
		if not strmatch(fakeName, "|cff") then
			-- Handle coloring here
			if mod.db.profile.nameColoring == "CLASS" then
				local color = mod:GetColor(localizedClass, true)
				if color then fakeName = "|cFF"..color..fakeName.."|r" end
			elseif mod.db.profile.nameColoring == "NAME" then
				fakeName = mod:ColorName(fakeName)
			end
		end
	end

	if waslogin then
		return misc..moreMisc..bleftBracket..fakeName..brightBracket..tag
	else
		return misc..id..moreMisc..bleftBracket..fakeName..brightBracket..tag..":"
	end
end

local function changeName(msgHeader, name, extra, msgCnt, displayName, msgBody)
	if name ~= player then
		if emphasizeSelfInText then
			msgBody = gsub(gsub(msgBody, "("..player..")" , "|cffffff00>|r%1|cffffff00<|r"), "("..player:lower()..")" , "|cffffff00>|r%1|cffffff00<|r")
		end
		if colorSelfInText then
			msgBody = gsub(gsub(msgBody, "("..player..")" , "|cffff0000%1|r"), "("..player:lower()..")" , "|cffff0000%1|r")
		end
	end

	local level
	local tab = mod.db.realm.names[name] or local_names[name]
	if tab then
		level = mod.db.profile.includeLevel and tab.level or nil
	end

	if level and (level ~= MAX_PLAYER_LEVEL or not mod.db.profile.excludeMaxLevel) then
		if mod.db.profile.levelByDiff then
			local c = GetQuestDifficultyColor(level)
			level = format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, level)
			displayName = format("%s%s%s", displayName, separator, level)
		else
			-- If we already have a color -- steal it and use it to color the level
			if strmatch(displayName, "|cff......") then
				-- This will seriously fuck up the string if there is already more than 1 color ... FIXME
				level = gsub(displayName, "((|cff......).-|r)", function (string, color)
					return format("%s%s|r",level,color)
				end)
			end
			displayName = format("%s%s%s", displayName, separator, level)
		end
	end

	return format("|Hplayer:%s%s%s|h%s%s%s|h%s", name, extra, msgCnt, leftBracket, displayName, rightBracket, msgBody)
end

function mod:ColorName(name)
	local class
	local tab = mod.db.realm.names[name] or local_names[name]
	if tab then class = tab.class end

	-- already known?
	if cache[name] then
		name = cache[name]
	else
		local coloring = mod.db.profile.nameColoring

		-- not yet colored by blizzy
		if coloring ~= "NONE" then
			local c = default_nick_color
			if coloring == "CLASS" then
				c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or default_nick_color
			elseif coloring == "NAME" then
				c = getNameColor(name)
			end

			name = format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name)
		end
	end

	return name
end

function mod:AddMessage(frame, text, ...)
	if text and type(text) == "string" then
		text = gsub(text, "(|HBNplayer:%S-|k:)(%d-)(:%S-|h)%[(%S-)%](|?h?)(:?)", changeBNetName)
		text = gsub(text, "(|HBNplayer:%S-|k:)(%d-)(:%S-BN_INLINE_TOAST_ALERT%S-|h)%[(%S-)%](|?h?)(:?)",fixLogin)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:Info()
	return L["Provides options to color player names, add player levels, and add tab completion of player names."]
end

function mod:TogglePlayerColors(val)
	ToggleChatColorNamesByClassGroup(val, "SAY")
	ToggleChatColorNamesByClassGroup(val, "EMOTE")
	ToggleChatColorNamesByClassGroup(val, "YELL")
	ToggleChatColorNamesByClassGroup(val, "GUILD")
	ToggleChatColorNamesByClassGroup(val, "OFFICER")
	ToggleChatColorNamesByClassGroup(val, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(val, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(val, "WHISPER")
	ToggleChatColorNamesByClassGroup(val, "PARTY")
	ToggleChatColorNamesByClassGroup(val, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(val, "RAID")
	ToggleChatColorNamesByClassGroup(val, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(val, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(val, "CHANNEL11")
	ToggleChatColorNamesByClassGroup(val, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(val, "INSTANCE_CHAT_LEADER")
end

local options
function mod:GetOptions()
	if not options then	-- save RAM / load time
		options = {
			save = {
				type = "group",
				name = L["Save Data"],
				desc = L["Save data between sessions. Will increase memory usage"],
				args = {
					guild = {
						type = "toggle",
						name = L["Guild"],
						desc = L["Save class data from guild between sessions."],
						get = function()
							return mod.db.profile.saveGuild
						end,
						set = function(info, v)
							mod.db.profile.saveGuild = v
							updateSaveData(v)
						end
					},
					group = {
						type = "toggle",
						name = L["Group"],
						desc = L["Save class data from groups between sessions."],
						get = function()
							return mod.db.profile.saveGroup
						end,
						set = function(info, v)
							mod.db.profile.saveGroup = v
							updateSaveData(v)
						end
					},
					friend = {
						type = "toggle",
						name = L["Friends"],
						desc = L["Save class data from friends between sessions."],
						get = function()
							return mod.db.profile.saveFriends
						end,
						set = function(info, v)
							mod.db.profile.saveFriends = v
							updateSaveData(v)
						end
					},
					target = {
						type = "toggle",
						name = L["Target/Mouseover"],
						desc = L["Save class data from target/mouseover between sessions."],
						get = function()
							return mod.db.profile.saveTarget
						end,
						set = function(info, v)
							mod.db.profile.saveTarget = v
							updateSaveData(v)
						end
					},
					who = {
						type = "toggle",
						name = L["Who"],
						desc = L["Save class data from /who queries between sessions."],
						order = 104,
						get = function()
							return mod.db.profile.saveWho
						end,
						set = function(info, v)
							mod.db.profile.saveWho = v
							updateSaveData(v)
						end
					},
					saveAllWho = {
						type = "toggle",
						name = L["Save all /who data"],
						desc = L["Will save all data for large /who queries"],
						disabled = function() return not mod.db.profile.saveWho end,
						order = 105,
						get = function()
							return mod.db.profile.saveAllWho
						end,
						set = function(info, v)
							mod.db.profile.saveAllWho = v
						end
					},
					resetDB = {
						type = "execute",
						name = L["Reset Data"],
						desc = L["Destroys all your saved class/level data"],
						func = function() wipe(mod.db.realm.names) end,
						order = 101,
						confirm = function() return L["Are you sure you want to delete all your saved class/level data?"] end
					}
				}
			},
			leftbracket = {
				type = "input",
				name = L["Left Bracket"],
				desc = L["Character to use for the left bracket"],
				get = function() return mod.db.profile.leftBracket end,
				set = function(i, v)
					mod.db.profile.leftBracket = v
					leftBracket = v
				end
			},
			rightbracket = {
				type = "input",
				name = L["Right Bracket"],
				desc = L["Character to use for the right bracket"],
				get = function() return mod.db.profile.rightBracket end,
				set = function(i, v)
					mod.db.profile.rightBracket = v
					rightBracket = v
				end
			},
			separator = {
				type = "input",
				name = L["Separator"],
				desc = L["Character to use between the name and level"],
				get = function() return mod.db.profile.separator end,
				set = function(i, v)
					mod.db.profile.separator = v
					separator = v
				end
			},
			bnetBrackets = {
				type = "toggle",
				name = L["RealID Brackets"],
				desc = L["Strip RealID brackets"],
				get = function() return mod.db.profile.bnetBrackets end,
				set = function(info,v)
					mod.db.profile.bnetBrackets = v
				end,
			},
			bnetRealNames = {
				type = "toggle",
				name = L["No RealNames"],
				desc = L["Show toon names instead of real names"],
				get = function() return mod.db.profile.noRealNames end,
				set = function(info,v)
					mod.db.profile.noRealNames = v
				end,
			},
			useTabComplete = {
				type = "toggle",
				name = L["Use Tab Complete"],
				desc = L["Use tab key to automatically complete character names."],
				get = function() return mod.db.profile.useTabComplete end,
				set = function(info, v)
					mod.db.profile.useTabComplete = v
					if v and not AceTab:IsTabCompletionRegistered(addon) then
						AceTab:RegisterTabCompletion(addon, nil, tabComplete)
					elseif not v and AceTab:IsTabCompletionRegistered(addon) then
						AceTab:UnregisterTabCompletion(addon)
					end
				end
			},
			colorSelfInText = {
				type = "toggle",
				name = L["Color self in messages"],
				desc = L["Color own charname in messages."],
				get = function() return mod.db.profile.colorSelfInText end,
				set = function(i, v)
					mod.db.profile.colorSelfInText = v
					colorSelfInText = v
				end
			},
			emphasizeSelfInText = {
				type = "toggle",
				name = L["Emphasize self in messages"],
				desc = L["Add surrounding brackets to own charname in messages."],
				width = "double",
				get = function() return mod.db.profile.emphasizeSelfInText end,
				set = function(i, v)
					mod.db.profile.emphasizeSelfInText = v
					emphasizeSelfInText = v
				end
			},
			levelHeader = {
				type = "header",
				name = L["Level Options"],
				order = 104
			},
			includeLevel = {
				type = "toggle",
				name = L["Include level"],
				desc = L["Include the player's level"],
				order = 105,
				get = function() return mod.db.profile.includeLevel end,
				set = function(info, val)
					mod.db.profile.includeLevel = val
					wipeCache()
				end
			},
			excludeMaxLevel = {
				type = "toggle",
				name = L["Exclude max levels"],
				desc = L["Exclude level display for max level characters"],
				order = 105,
				get = function() return mod.db.profile.excludeMaxLevel end,
				set = function(info, val)
					mod.db.profile.excludeMaxLevel = val
					wipeCache()
				end,
				hidden = function() return not mod.db.profile.includeLevel end
			},
			colorLevelByDifficulty = {
				type = "toggle",
				name = L["Color level by difficulty"],
				desc = L["Color level by difficulty"],
				order = 105,
				get = function()
					return mod.db.profile.levelByDiff
				end,
				set = function(info, v)
					mod.db.profile.levelByDiff = v
					wipeCache()
				end,
				hidden = function() return not mod.db.profile.includeLevel end
			},
			colorBy = {
				type = "toggle",
				name = L["Color Player Names By Class"],
				desc = L["Color Player Names By Class"],
				get = function() return mod.db.profile.blizzardNameColoring end,
				set = function(info, val)
					mod.db.profile.blizzardNameColoring = val
					mod:TogglePlayerColors(val)
				end
			}
		}

	end
	return options
end
