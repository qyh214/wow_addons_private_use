local addonName, addon = ...
local Options, L, LSM, WidgetLists
------------------------------------------------------------------------------
local GetNumFriends, GetFriendInfo, GetNumIgnores, GetIgnoreName

local ignorelist_before_hook = {}

local OP_SYNC = 0
local OP_ADD = 1
local OP_DEL = 2
local OP_ADD_DEL = 3
local OP_ADDDEL_IDX = 4

if(addonName ~= nil) then
	Options = addon:NewModule("Options", "AceConsole-3.0")
	L = LibStub("AceLocale-3.0"):GetLocale(addonName)
	LSM = LibStub("LibSharedMedia-3.0")
	WidgetLists = AceGUIWidgetLSMlists

    GetNumFriends = C_FriendList.GetNumFriends
    GetFriendInfo = C_FriendList.GetFriendInfo
    GetNumIgnores = C_FriendList.GetNumIgnores
    GetIgnoreName = C_FriendList.GetIgnoreName
else
	addon = {}
	Options = {}
	L = {}
end

addon.MSG_FILTER_CHANNEL_SET_NORMAL = "1:NORMAL"
addon.MSG_FILTER_CHANNEL_SET_PLUS_PARTY_RAID = "2:PLUS_TEAM"
addon.MSG_FILTER_CHANNEL_SET_PLUS_GUILD = "3:PLUS_GUILD"
addon.MSG_FILTER_CHANNEL_SET_PLUS_BOTH = "4:PLUS_BOTH"

local channel_sets_desc = {
	[addon.MSG_FILTER_CHANNEL_SET_NORMAL] = L["Regular(LFG, World, Trade, etc.)"],
	[addon.MSG_FILTER_CHANNEL_SET_PLUS_PARTY_RAID] = L["Regular and party/raid"],
	[addon.MSG_FILTER_CHANNEL_SET_PLUS_GUILD] = L["Regular and guild"],
	[addon.MSG_FILTER_CHANNEL_SET_PLUS_BOTH] = L["Regular, guild and party/raid"],
}

-------- 

local SPAM_LEVEL_1 = 0.02
local SPAM_LEVEL_2 = 0.3
local SPAM_LEVEL_3 = 1
local SPAM_LEVEL_4 = 2
local SPAM_LEVEL_5 = 3.3

addon.spammercolor = {
	{SPAM_LEVEL_5, "|cfff51000"},
	{SPAM_LEVEL_4, "|cffff9900"},
	{SPAM_LEVEL_3, "|cffffea00"},
	{SPAM_LEVEL_2, "|cff00aaff"},
	{SPAM_LEVEL_1, "|cff00ff00"},
	{0, "|cffffffff"},
}

--  Options
Options.defaults = {
	global = {
		-- UI window
		ui_switch_on = false,
		-- message filtering on or off
		message_filter_switch = true,
		-- hook engine on/off
		message_hook_switch = true,
		-- filter channels settings
		filter_channel_set = addon.MSG_FILTER_CHANNEL_SET_NORMAL,
		-- message rewrite
		message_rewrite = true,
		-- bypass friends
		bypass_friends = true,
		-- same player messages min interval, 0-unlimited
		min_interval_same_player = 0,
		-- same player same message min interval, 0-unlimited
		min_interval_same_message = 0,
		-- minimap icon switch
		minimap_icon_switch = true,
		-- analysis run params
		analysis = {
			interval = 300,
		},
		-- compact db, not use anymore
		compactdb = {
			interval = 500,
		},
		-- current set threshold of spam filtering
		-- 0: off, 1: miniman
		filtering_level = "4",
		-- level to score mapping: level, 
		level_score_map = {
			--["0"] = 0,				-- off
			["1"] = SPAM_LEVEL_1,		-- Minimum
			["2"] = SPAM_LEVEL_2,		-- Talkative
			["3"] = SPAM_LEVEL_3,		-- Annoying
			["4"] = SPAM_LEVEL_4,		-- Spammer
			["5"] = SPAM_LEVEL_5,		-- Bot
		},
		-- beyond this trigger learning (1 hour)
		hourly_learning_threshold = 10,
		-- beyond this trigger learning after hourly check false
		daily_learning_threshold = 30,
		-- low than this trigger remove from leanring (in 5 days)
		penalty_threshold = 20,
		-- messages received time diff lower than this consider as periodcally (mostly spams)
		deviation_threshold = 0.25,
		-- whitelist
		wl = {},
		-- bl
		bl = {},
		-- learning list
		plist = {},
		-- pre-learning list
		prelearning = {},
		-- player features
		pfeatures = {},
		-- font size
		fontsize = 12.8,
		-- output log messages when begin learning on player and found new player with spam score
		do_not_disturb = false,
		-- ui window save status
		ui = {
			height = 50,
			top = 417,
			left = 7,
			width = 80,
		},
	},
}

local top500list = ""

local function HookIgnoreAPIs()
	-- hook add ignore events
	addon.oriAddIgnore = C_FriendList.AddIgnore
	C_FriendList.AddIgnore = function(...)
		local arg={...}
		Options:FetchBL()
		addon.oriAddIgnore(arg[1])
		Options:SyncBL(OP_ADD, arg[1])
	end

	-- hook del ignore events
	addon.oriDelIgnore = C_FriendList.DelIgnore 
	C_FriendList.DelIgnore = function(...)
		local arg={...}
		Options:FetchBL()
		addon.oriDelIgnore(arg[1])
		Options:SyncBL(OP_DEL, arg[1])
	end

	-- book add or del ignore
	addon.oriAddOrDelIgnore = C_FriendList.AddOrDelIgnore 
	C_FriendList.AddOrDelIgnore = function(...)
		local arg={...}
		Options:FetchBL()
		addon.oriAddOrDelIgnore(arg[1])
		Options:SyncBL(OP_ADD_DEL, arg[1])
	end

	-- hook del by index
	addon.oriDelIgnoreByIndex = C_FriendList.DelIgnoreByIndex
	C_FriendList.DelIgnoreByIndex = function(...)
		local arg={...}
		Options:FetchBL()
		addon.oriDelIgnoreByIndex(arg[1])
		Options:SyncBL(OP_ADDDEL_IDX, arg[1])
	end

end

-----------------------------------------
-- Load after addon enabled
function Options:Load()
	addon.db.global.creator_addon_version = addon.db.global.creator_addon_version or addon.METADATA.VERSION

 	HookIgnoreAPIs()

	self:SyncBL(OP_SYNC)
end

function Options:SyncBL(...)
	local syncargs = {...}

	--local apistack = debugstack(2,5)
	--addon:log(apistack)

	C_Timer.After(0.1, function() sync_bl_func(syncargs) end)
end

function Options:SaveSession()
	if addon.AcamarGUI.display ~= nil and addon.AcamarGUI.display:IsShown() then
		addon.db.global.ui_switch_on = true
	else
		addon.db.global.ui_switch_on = false
	end
end

-- Set filtering flag on/off
function addon:ToggleFiltering()
    addon.db.global.message_filter_switch = not addon.db.global.message_filter_switch
	--addon:log("Filtering is " .. tostring(addon.db.global.message_filter_switch))

	if addon.db.global.message_filter_switch then
		addon:log(L["Chat messages filtering started."])
	else
		addon:log(L["Chat messages filtering stopped, but learning engine still running."])
	end

    -- update UI to reflect current filter status
    addon.AcamarGUI:UpdateAddonUIStatus(addon.db.global.message_filter_switch)
end

-- Turn on/off engine
function addon:HookSwitch()
	if addon.db.global.message_hook_switch then
		if not addon.AcamarMessage.engine_running then
			addon:log(L["Turn on learning engine..."])
			addon.AcamarMessage:HookOn(addon.db.global.filter_channel_set)
		end
	else
		if addon.AcamarMessage.engine_running then
			addon.AcamarMessage:HookOff(addon.db.global.filter_channel_set)
			addon:log(L["Turn off learning engine..."])
		end
	end
end

----------- options functions
function WhisperListToSelf(info) 
	addon:log("Printing banned list: Player Name [spam score]") 

	SendChatMessage(L["Currently banned players:"], "WHISPER", nil, UnitName("player"))
    for k,v in pairs(addon.db.global.pfeatures) do 
		-- exceed blocklist threshold
		if ( v.score >= addon.FilterProcessor.filter_score ) then
			SendChatMessage(v.name .. " [" .. v.score .. "]" , "WHISPER", nil, UnitName("player"))
		end
    end
end

-- get sorted keys
local function keysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    return keys
end

function PrintBannedList(info)
	local bannedlist = {}

	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= addon.FilterProcessor.filter_score ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
		end
    end


	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	addon:log(L["Top 500 spammers with spam score greater than "] .. addon.FilterProcessor.filter_score) 
	local counter=0
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		addon:log(bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]")
		counter = counter + 1
		if counter>=500 then
			break
		end
    end
	addon:log(L["Total players in banned list: "] .. counter) 
end

function GetBannedList(max)
	-- addon:log("GetBannedList")

	local bannedlist = {}
	local list = ""

	local prec = 0
	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= 0 ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
			prec = prec + 1
		end
    end

    if prec == 0 then
    	return L["Learning in progress ..."]
    end

	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	list = L["Top players with spam score. Max "] .. max .. "\n\n"
	list = list .. L["The list changes along with the learning progress."] .. "\n\n"

	local counter=0
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		list = list .. bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]" .. "\n"
		counter = counter + 1
		if counter>=500 then
			break
		end
    end
	list = list .. "\n" .. L["Total players in the list: "] .. counter

	return list
end

function GetBannedTable(max)
	local bannedlist = {}
	local list = {}

	local prec = 0
	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= 0 ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
			prec = prec + 1
		end
    end

    if prec == 0 then
    	return {["0"] = L["Learning in progress ..."]}
    end

	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	local counter=1
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		local idx = string.format("%08d", counter)

		list[idx] = bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]"
		counter = counter + 1
		if counter>=500 then
			break
		end
    end
	list["end"] = "|cff00cccc" .. L["Total players in the list: "] .. counter

	return list
end

function ResetAcamarDB(info)
	addon:log(L["Resetting DB and learning enging..."])

	addon.resetting_flag = true

	-- reset plist
	addon.db.global.plist = {}

	-- reset prelearning
	addon.db.global.prelearning = {}

	-- reset pfeatures
	addon.db.global.pfeatures = {}

	addon.resetting_flag = false
end

function SplitString(s, sep)
    local fields = {}

    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    --string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    string.gsub(s, pattern, function(c) 
    		if(c~=nil and c~= "") then
    			fields[c] = true 
    		end
    	end)

    return fields
end

-- convert table to "\n" seperated string
function addon:LoadWL(a)
	local wlstr = ""

	local klist = {}
	for key, val in pairs(addon.db.global.wl) do
		if key then
			table.insert(klist, key)
		end
	end

	table.sort(klist)

	for key, val in pairs(klist) do
		if val then
			if wlstr ~= "" then
				wlstr = wlstr .. "\n"
			end
			wlstr = wlstr .. val
		end
	end

	return wlstr
end

-- convert string list to indexed table
function addon:SaveWL(str)
	--addon:log("SaveWL" .. str)
	local t = SplitString(str, "\n")
	addon.db.global.wl = t
end

----------- blocklist functions
function Options:FetchBL()
	ignorelist_before_hook = {}
	for i = 1, GetNumIgnores() do
        ignorelist_before_hook[GetIgnoreName(i)] = true
    end	 
end

-- blocklist synced from ignore list
function GetBLTable()
	--addon:log(time() .. " GetBLTable")
	local list = {}
	for k, v in pairs(addon.db.global.bl) do
		list[k] = k
	end
	return list
end

function ToggleBLEntry(info, val)
	--addon:log("info=" .. tostring(info) .. " val=" .. tostring(val) .. " dbval=" .. tostring(addon.db.global.bl[val]))
	-- addon.db.global.bl[val] = not addon.db.global.bl[val]

	addon.db.global.bl[val] = nil
	C_FriendList.DelIgnore(val)
	addon:log(val .. L[" had been removed from blocklist."])
end

-- igargs: arguments passed by C_FriendList:xxx functions
function sync_bl_func(syncargs)
	local op = syncargs[1]
	local pname = syncargs[2]
	
	if pname ~= nil then
		pname = string.match(pname, "([^-]+)")
	end
	--addon:log("op=" .. op .. ", arg2=" .. tostring(syncargs[2]) .. ", pname=" .. tostring(pname) )

    -- if in add mode, confirm the player be added to blocklist once system limit of 50 reached
    if op == OP_ADD then
    	addon.db.global.bl[pname] = true
		addon:log(pname .. L[" added to blocklist."])
	-- toggle add/remove
	elseif op == OP_DEL then
		if addon.db.global.bl[pname] then
			--addon:log("OP_DEL unblock " .. pname)
			addon.db.global.bl[pname] = nil
			addon:log(pname .. L[" had been removed from blocklist."])
		end
	elseif op == OP_ADD_DEL then
		if addon.db.global.bl[pname] == nil then
			--addon:log("OP_ADD_DEL block " .. pname)
			addon.db.global.bl[pname] = true
			addon:log(pname .. L[" added to blocklist."])
		else
			--addon:log("OP_ADD_DEL unblock " .. pname)
			addon.db.global.bl[pname] = nil
			addon:log(pname .. L[" had been removed from blocklist."])
		end
	-- remove by index, ignore system removed by index, due to inconsistency of system ignore list with acamar's blocklist
	elseif op == OP_ADDDEL_IDX then
    end
end

function RemovePlayerFromBL()
	--addon:log("RemovePlayerFromBL")
end

function UpdateMinimap()
	--addon:log("addon.db.global.minimap_icon_switch=" .. tostring(addon.db.global.minimap_icon_switch))
	if addon.db.global.minimap_icon_switch then
		addon.AcamarMinimap:ShowIcon()
	else
		addon.AcamarMinimap:HideIcon()
	end
end

-- debug
if(addonName == nil) then

	local function test()
		a = SplitString("测试\n字符串\nabc\nhello\no世界")
		for k,v in pairs(a) do
			print(k)
		end
	end

	test()
end

-----------------------------------------------------
function Options.GetOptions(uiType, uiName, appName)
	if appName == addonName then
		--top500list = GetBannedList(500)

		local options  = {
			type = "group",
			name = addon.METADATA.NAME .. " (" .. addon.METADATA.VERSION .. ")",
			get = function(info)
					return addon.db.global[info[#info]] or ""
				end,
			set = function(info, value)
					addon.db.global[info[#info]] = value
					--[[
					addon.Data:UpdateSession()
					if addon.AcamarGUI.display then
						addon.GUI.container:Reload()
					end
					]]
				end,
			args = {
				main_settings = {
					type = "group",
					childGroups = "tab",
					name = L["Engine Settings"],
					order = 1.0,
					args = {
						addoninfo = {
							type = "description",
							name = L["ADDON_INFO"],
							descStyle = L["ADDON_INFO"],
							order = 0.1,
						},

						header01 = {
							type = "header",
							name = "",
							order = 1.01,
						},

						filtering_level = {
							type = "select",
							width = "full",
							name = L["Filtering Level"],
							desc = L["Set messages filtering level"],
							values = { 	
										--["0"] = L["Off"],
										["1"] = L["Most strict level with minimum spam"] .. " [" .. SPAM_LEVEL_1 .. "]",
										["2"] = L["Bots, spammers, annoying senders and talkative players away"] .. " [" .. SPAM_LEVEL_2 .. "]",
										["3"] = L["Block bots, spammers and annoying messages"] .. " [" .. SPAM_LEVEL_3 .. "]",
										["4"] = L["Block bots and spammers"] .. " [" .. SPAM_LEVEL_4 .. "]",
										["5"] = L["Block bots only"] .. " [" .. SPAM_LEVEL_5 .. "]",
									},
							get = function(info)
									return addon.db.global[info[#info]] or ""
								end,
							set = function(info, value)
									addon.db.global[info[#info]] = value
									addon.FilterProcessor:UpdateFilterScore(value)
								end,
							order = 1.1,
						},

						header02 = {
							type = "header",
							name = "",
							order = 1.51,
						},

						filter_channel_set = {
							type = "select",
							width = "full",
							name = L["Filtering Channels"],
							desc = L["Select channels to filtered"],
							values = channel_sets_desc,
							get = function(info)
									return addon.db.global[info[#info]] or ""
								end,
							set = function(info, value)
									addon.AcamarMessage:HookOff(addon.db.global.filter_channel_set)
									addon.db.global[info[#info]] = value
									addon.AcamarMessage:HookOn(addon.db.global.filter_channel_set)
								end,
							order = 1.6,
						},

						filter_channel_note = {
							type = "description",
							name = L["FILTER_CHANNEL_NOTE"],
							order = 1.7,
						},

						header_dnd = {
							type = "header",
							name = "",
							order = 2.01,
						},

						do_not_disturb = {
							type = "toggle",
							width = "normal",
							name = L["Do not disturb"],
							desc = L["Enable to bypass printing of progress messages (like talkative player added into learning) in chat window."],
							width = "normal",
							set = function(info,val) 
									addon.db.global.do_not_disturb = val 
								end,
		      				get = function(info) 
		      						return addon.db.global.do_not_disturb 
		      					end,
							order = 2.1,
						},

						message_rewrite = {
							type = "toggle",
							width = "normal",
							name = L["Rewrite messages"],
							desc = L["REWRITE_DESC"] ,
							width = "normal",
							set = function(info,val) 
									addon.db.global.message_rewrite = val 
								end,
		      				get = function(info) 
		      						return addon.db.global.message_rewrite 
		      					end,
							order = 2.2,
						},

						bypass_friends = {
							type = "toggle",
							width = "normal",
							name = L["Bypass friends"],
							desc = L["Do not filter members of guild, party/raid, and myself."],
							width = "normal",
							set = function(info,val) 
									addon.db.global.bypass_friends = val 
								end,
		      				get = function(info) 
		      						return addon.db.global.bypass_friends 
		      					end,
							order = 2.3,
						},

						minimap_icon_switch = {
							type = "toggle",
							width = "normal",
							name = L["Show minimap icon"],
							width = "normal",
							set = function(info,val) 
									addon.db.global.minimap_icon_switch = val 
									UpdateMinimap()
								end,
		      				get = function(info) 
		      						return addon.db.global.minimap_icon_switch 
		      					end,
							order = 2.4,
						},

						header_interval = {
							type = "header",
							name = "",
							order = 3.01,
						},

						min_interval_desc = {
							type = "description",
							name = L["MIN_INTERVAL_DESC"],
							order = 3.1,
						},

						min_interval_same_player = {
							type = "range",
							width = "double",
							min = 0,
							max = 3600,
							step = 1,
							softMin = 0,
							softMax = 3600,
							name = L["Same player"],
							desc = L["Allow only 1 message sent by same player during set interval (seconds)"],
							width = "normal",
							order = 3.2,
						},

						min_interval_same_message = {
							type = "range",
							width = "double",
							min = 0,
							max = 3600,
							step = 1,
							softMin = 0,
							softMax = 3600,
							name = L["Same message"],
							desc = L["Allow only 1 message with same content sent by same player during set interval (seconds)"],
							width = "normal",
							order = 3.3,
						},
					},
				},

				adv_settings = {
					type = "group",
					childGroups = "tab",
					name = L["Advanced Settings"],
					order = 5.0,
					args = {
						message_hook_switch = {
							type = "toggle",
							width = "full",
							name = L["Turn On Engine"],
							desc = L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."],
							width = "normal",
							set = function(info,val) 
									addon.db.global.message_hook_switch = val 
									addon:HookSwitch()
								end,
		      				get = function(info) 
		      						return addon.db.global.message_hook_switch 
		      					end,
							order = 5.1,
						},

						header03 = {
							type = "header",
							name = "",
							order = 6.01,
						},

						command_cleardb = {
							type = "execute",
							width = "normal",
							name = L["Reset and re-learn"],
							confirm = true,
							desc = L["Reset DB to initial status and begin to re-learn players' behavior."],
							func = function(info) ResetAcamarDB(info) end,
							order = 6.1,
						},
					},
				},

				spamscore_panel = {
					type = "group",
					childGroups = "tab",
					name = L["Spam score"],
					order = 7.0,
					args = {
						top500_list_desc = {
							type = "description",
							name = "|cff00cccc" .. L["Top players with spam score. Max "] .. "500" .. "\n" ..
								L["The list changes along with the learning progress."] .. "|r",
							order = 7.01,
						},
						top500_list_select = {
							type = "multiselect",
							width = "full",
							disabled = true,
							name = "",
							descStyle = L["The list changes along with the learning progress."],
							values = function(info) return GetBannedTable(500) end,
							order = 7.1,
						},								
					},
				},

				blocklist_panel = {
					type = "group",
					childGroups = "tab",
					name = L["Block list"],
					order = 8.0,
					args = {
						blocklist_desc = {
							type = "description",
							name = L["BL_DESC"],
							order = 8.01,
						},
						blocklist_select = {
							type = "multiselect",
							width = "full",
							disabled = false,
							name = L["Block list"],
							values = function(info) return GetBLTable() end,
							set = function(info, val)
									ToggleBLEntry(info, val)
								end,
							get = function(info, val)  end,
							order = 8.1,
						},					
						--[[			
						command_removebl = {
							type = "execute",
							width = "normal",
							name = L["Remove selected"],
							confirm = false,
							desc = L["Remove selected players from blocklist and sync with system ignore list"],
							func = function(info) RemovePlayerFromBL() end,
							order = 8.7,
						},
						]]
					},
				},

				whitelist_panel = {
					type = "group",
					childGroups = "tab",
					name = L["White list"],
					order = 8.5,
					args = {
						whitelist_desc = {
							type = "description",
							name = L["Enter player's name list to bypass filtering:"],
							order = 8.51,
						},
						whitelist_select = {
							type = "input",
							width = "full",
							multiline = 16,
							name = L["One player in one single line"],
							usage = L["One player in one single line"],
							set = function(info,val) 
									addon:SaveWL(val)
								end,
		      				get = function(info) 
		      						return addon:LoadWL()
		      					end,
							order = 8.6,
						},								
					},
				},

				about_panel = {
					type = "group",
					childGroups = "tab",
					name = L["About"],
					order = 9.0,
					args = {
						top500_list_desc = {
							type = "description",
							name = L["ABOUT_INFO"],
							order = 8.01,
						},

						header_author = {
							type = "header",
							name = "",
							order = 9.01,
						},

						authorinfo = {
							type = "description",
							name = L["AUTHOR_INFO"],
							descStyle = L["AUTHOR_INFO"],
							order = 9.1,
						},
					},
				},
			},
		}

		return options
	end
end

-- EOF
