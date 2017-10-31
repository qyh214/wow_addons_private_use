-------------------------------------------------------
-- fyhcslb, 2016/10/27
-- Special Thanks: q3fuba
-- Translators: Sexnonstop(ruRU), Durcc(esES), pas06(deDE)
-------------------------------------------------------
local _, addonTable = ...
local L = addonTable.L
local CURRENT_NAME, CURRENT_SERVER
local LCR = LibStub:GetLibrary("LibCurrentRegion")

-------------------------------------------------------
-- menuitems
-------------------------------------------------------
UnitPopupButtons["ENHANCED_MENU"] = { -- Subsection by q3fuba!
  text = L.ENHANCED_MENU,  
  dist = 0,
  isTitle = true,
  isUninteractable = true,
  isSubsectionTitle = true
}

UnitPopupButtons["SUBSECTION_SEPARATOR"] = { -- removed in 7.1 ---> UIDropDownMenu_AddSeparator
	dist = 0,
	isTitle = true,
	isUninteractable = true,
	iconOnly = true,
	icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
	tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1,
	tSizeX = 0, tFitDropDownSizeX = true, tSizeY = 8, 
}

UnitPopupButtons["GUILD_INVITE"] = {
	text = L.GUILD_INVITE,
	value = "GUILD_INVITE",
	dist = 0
}

UnitPopupButtons["COPY_NAME"] = {
	text = L.COPY_NAME,
	value = "COPY_NAME",
	dist = 0
}

UnitPopupButtons["SEND_WHO"] = {
	text = L.SEND_WHO,
	value = "SEND_WHO",
	dist = 0
}

UnitPopupButtons["ARMORY_URL"] = {
	text = L.ARMORY_URL,
	value = "ARMORY_URL",
	dist = 0
}

UnitPopupButtons["WOW_P"] = {
	text = L.WOW_P,
	value = "WOW_P",
	dist = 0
}
-------------------------------------------------------
-- "which" for specific button
-------------------------------------------------------
local EnhancedMenu_ButtonSet = {}

EnhancedMenu_ButtonSet["GUILD_INVITE"] = {
	["PARTY"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["RAID_PLAYER"] = true,
	["FRIEND"] = true,
	["FRIEND_OFFLINE"] = true,
	["CHAT_ROSTER"] = true,
}

EnhancedMenu_ButtonSet["COPY_NAME"] = {
	["SELF"] = true,
	["PARTY"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["RAID_PLAYER"] = true,
	["FRIEND"] = true,
	["FRIEND_OFFLINE"] = true,
	["CHAT_ROSTER"] = true,
	["GUILD"] = true,
	["GUILD_OFFLINE"] = true,
}

EnhancedMenu_ButtonSet["SEND_WHO"] = {
	["FRIEND"] = true,
	["CHAT_ROSTER"] = true,
}

EnhancedMenu_ButtonSet["ARMORY_URL"] = {
	["SELF"] = true,
	["PARTY"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["RAID_PLAYER"] = true,
	["FRIEND"] = true,
	["FRIEND_OFFLINE"] = true,
	["CHAT_ROSTER"] = true,
	["GUILD"] = true,
	["GUILD_OFFLINE"] = true,
}

EnhancedMenu_ButtonSet["WOW_P"] = {
	["SELF"] = true,
	["PARTY"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["RAID_PLAYER"] = true,
	["FRIEND"] = true,
	["FRIEND_OFFLINE"] = true,
	["CHAT_ROSTER"] = true,
	["GUILD"] = true,
	["GUILD_OFFLINE"] = true,
}

local SubTable = {
	["SELF"] = true,
	["PARTY"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["RAID_PLAYER"] = true,
	["FRIEND"] = true,
	["FRIEND_OFFLINE"] = true,
	["CHAT_ROSTER"] = true,
	["GUILD"] = true,
	["GUILD_OFFLINE"] = true,
}

-- add Subsection Title
for which, enabled in pairs(SubTable) do
	if enabled then    
		table.insert(UnitPopupMenus[which], #UnitPopupMenus[which], "ENHANCED_MENU")
	end
end

-- add button(s) to subsection
for buttonName, buttonTable in pairs(EnhancedMenu_ButtonSet) do
	for which, enabled in pairs(buttonTable) do
		if enabled then
			table.insert(UnitPopupMenus[which], #UnitPopupMenus[which], buttonName)
		end
	end
end

-- add Subsection Separator
for which, enabled in pairs(SubTable) do
	if enabled then    
		table.insert(UnitPopupMenus[which], #UnitPopupMenus[which], "SUBSECTION_SEPARATOR")
	end
end

-------------------------------------------------------
-- util (FriendsMenuXP & enhanced)
-------------------------------------------------------
local function urlencode(obj)
    local currentIndex = 1;
    local charArray = {}
    while currentIndex <= #obj do
        local char = string.byte(obj, currentIndex);
        charArray[currentIndex] = char
        currentIndex = currentIndex + 1
    end
    local converchar = "";
    for _, char in ipairs(charArray) do
        converchar = converchar..string.format("%%%X", char)
    end
    return converchar;
end

local function showArmoryURL(fullName)
	local name, server = string.split("-", fullName)
	if not name or name == "" then return end
	if not server or server == "" then -- offline, set to current server
		server = GetRealmName()
	end
	
	local portal = string.lower(LCR:GetCurrentRegion())
	local host = ("http://%s.battle.net/"):format(portal)
	local armory = host.."wow/character/"..urlencode(server).."/"..urlencode(name).."/advanced"
	-- local armoryNoEncode = host.."wow/character/"..server.."/"..name.."/advanced"
	
	local editBox = ChatEdit_ChooseBoxForSend()
	--ChatEdit_ActivateChat(editBox)
	editBox:SetText(armory)
	editBox:SetCursorPosition(0)
	editBox:HighlightText()
	
	StaticPopupDialogs["PHRENPOPUP"] = {
	text = "CTRL+C to copy your link",
	hasEditBox = 1,
	editBoxWidth = 500,
	OnShow = function(self)
		local editBox = self.editBox
		editBox:SetText(armory);
		editBox:HighlightText();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopup_Show("PHRENPOPUP","")
end

local function showWoWPURL(fullName)
	local name, server = string.split("-", fullName)
	if not name or name == "" then return end
	if not server or server == "" then -- offline, set to current server
		server = GetRealmName()
	end
	
	local portal = string.lower(LCR:GetCurrentRegion())
	local host = ("https://www.wowprogress.com/character/%s/"):format(portal)
		local wowp = host..urlencode(server).."/"..urlencode(name)
	-- local armoryNoEncode = host.."wow/character/"..server.."/"..name.."/advanced"
	
	local editBox = ChatEdit_ChooseBoxForSend()
	--ChatEdit_ActivateChat(editBox)
	editBox:SetText(wowp)
	editBox:SetCursorPosition(0)
	editBox:HighlightText()
	
	StaticPopupDialogs["PHRENPOPUPA"] = {
	text = "CTRL+C to copy your link",
	hasEditBox = 1,
	editBoxWidth = 500,
	OnShow = function(self)
		local editBox = self.editBox
		editBox:SetText(wowp);
		editBox:HighlightText();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopup_Show("PHRENPOPUPA","")
end

local function showName(fullName)	  -- FriendsMenuXP
	if ( SendMailNameEditBox and SendMailNameEditBox:IsVisible() ) then
		SendMailNameEditBox:SetText(fullName)
		SendMailNameEditBox:HighlightText()
	else
		local editBox = ChatEdit_ChooseBoxForSend()
		if editBox:HasFocus() then
			editBox:Insert(fullName)
		else
			ChatEdit_ActivateChat(editBox)
			editBox:SetText(fullName)
			editBox:HighlightText()
		end
	end
end

-------------------------------------------------------
-- ConfirmGuildInvitePopupDialog -- by q3fuba
-------------------------------------------------------
StaticPopupDialogs["ENHANCED_MENU_CONFIRM_GUILD_INVITE"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

local function ConfirmGuildInvite(fullName)
	StaticPopupDialogs["ENHANCED_MENU_CONFIRM_GUILD_INVITE"].text = CHAT_GUILD_INVITE_SEND .. "\n" .. fullName
	StaticPopupDialogs["ENHANCED_MENU_CONFIRM_GUILD_INVITE"].OnAccept = function() GuildInvite(fullName) end
	StaticPopup_Show("ENHANCED_MENU_CONFIRM_GUILD_INVITE")
end

-------------------------------------------------------
-- EnhancedDropDownMenu
-------------------------------------------------------
local numValidGameAccounts, index, numGameAccounts
local EnhancedDropDownMenu = CreateFrame("Frame", "EnhancedDropDownMenu")

local function ToggleEnhancedDropDownMenu(funcName, btnName)
	UIDropDownMenu_Initialize(EnhancedDropDownMenu, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		info.isTitle = 1
		info.notCheckable = 1
		info.text = btnName
		UIDropDownMenu_AddButton(info, level)
				
		for i = 1, numGameAccounts do
			if select(3, BNGetFriendGameAccountInfo(index, i)) == BNET_CLIENT_WOW then
				local info = UIDropDownMenu_CreateInfo()
				info.text = select(2, BNGetFriendGameAccountInfo(index, i)) .. "-" .. select(4, BNGetFriendGameAccountInfo(index, i))  
				info.notCheckable = 1
				
				if funcName == "GUILD_INVITE" then
					info.func = function(self) ConfirmGuildInvite(self.value) end
				elseif funcName == "COPY_NAME" then
					info.func = function(self) showName(self.value) end
				elseif funcName == "ARMORY_URL" then
					info.func = function(self) showArmoryURL(self.value) end
					elseif funcName == "WOW_P" then
					info.func = function(self) showWoWPURL(self.value) end
				end
				
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end)
	
	ToggleDropDownMenu(1, nil, EnhancedDropDownMenu, "cursor", 0, 60)
end

-------------------------------------------------------
-- UnitPopup hook
-------------------------------------------------------
hooksecurefunc("UnitPopup_ShowMenu", function(self, which)
	-- print(which)
	-- texplore("UnitPopupMenu", self)
	
    if which ~= "BN_FRIEND" and UIDROPDOWNMENU_MENU_LEVEL == 1 then -- BN_FRIEND uses BNGetGameAccountInfo
        -- CURRENT_NAME, CURRENT_SERVER = self.name, self.server or GetRealmName()
		CURRENT_NAME = self.name
		
		if self.server and self.server ~= "" then
			CURRENT_SERVER = self.server
		else
			CURRENT_SERVER = GetRealmName()
		end
		
		numValidGameAccounts = 1
    end
end)

Original_UnitPopup_OnClick = _G["UnitPopup_OnClick"]

function UnitPopup_OnClick(self)
	-- texplore("UnitPopupButton", self)
	local pName, pServer = CURRENT_NAME, CURRENT_SERVER
	if pServer and pServer ~= "" then pName = pName .. "-" .. pServer end	-- no server, no concat
	
	if self.value == "INVITE" then
		InviteUnit(pName)
		return
	elseif self.value == "GUILD_INVITE" then
		if numValidGameAccounts > 1 then
			ToggleEnhancedDropDownMenu("GUILD_INVITE", L.GUILD_INVITE)
		else
			ConfirmGuildInvite(pName)	-- only 1 WoW account available
		end
		return
	elseif self.value == "COPY_NAME" then
		if numValidGameAccounts > 1 then
			ToggleEnhancedDropDownMenu("COPY_NAME", L.COPY_NAME)
		else
			showName(pName)	-- only 1 WoW account available
		end
		return
	elseif self.value == "SEND_WHO" then
		SendWho("n-" .. pName)
		return
	elseif self.value == "ARMORY_URL" then
		if numValidGameAccounts > 1 then
			ToggleEnhancedDropDownMenu("ARMORY_URL", L.ARMORY_URL)
		else
			showArmoryURL(pName)	-- only 1 WoW account available
		end
	elseif self.value == "WOW_P" then
		if numValidGameAccounts > 1 then
			ToggleEnhancedDropDownMenu("WOW_P", L.WOW_P)
		else
			showWoWPURL(pName)	-- only 1 WoW account available
		end
		return
	end
	
	Original_UnitPopup_OnClick(self)
end

-------------------------------------------------------
-- FriendsFrame_ShowBNDropdown
-------------------------------------------------------
Original_FriendsFrame_ShowBNDropdown = _G["FriendsFrame_ShowBNDropdown"]

function FriendsFrame_ShowBNDropdown(name, connected, lineID, chatType, chatFrame, friendsList, bnetIDAccount)
	if connected then
		index = BNGetFriendIndex(bnetIDAccount)
		-- print("index: " .. index)
		numGameAccounts = BNGetNumFriendGameAccounts(index)
		-- print("numGameAccounts: " .. numGameAccounts)
		-- print(BNGetFriendGameAccountInfo(index, 1))	-- include Battlenet app	
		-- hasFocus, characterName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime, canSoR, bnetIDGameAccount = BNGetFriendGameAccountInfo(friendIndex, toonIndex)
		local _, _, _, _, toonName, toonID, client = BNGetFriendInfoByID(bnetIDAccount)
		local _, characterName, _, realmName, realmID = BNGetGameAccountInfo(toonID)
		
		local buttonIndex = nil	-- first index of EnhancedMenu
		
		numValidGameAccounts = 0
		
		for i = 1, numGameAccounts do
			if select(3, BNGetFriendGameAccountInfo(index, i)) == BNET_CLIENT_WOW then
				numValidGameAccounts = numValidGameAccounts + 1
			end
		end
		-- print("numValidGameAccounts: " .. numValidGameAccounts)
		
		for k, v in pairs(UnitPopupMenus["BN_FRIEND"]) do
			if v == "ENHANCED_MENU" then buttonIndex = k end
		end
		
		if numValidGameAccounts > 0 then	-- WoW accounts
				CURRENT_NAME = characterName
				CURRENT_SERVER = realmName
				if not buttonIndex then	-- no button exists
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "ENHANCED_MENU")
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "GUILD_INVITE")
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "COPY_NAME")
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "ARMORY_URL")
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "WOW_P")
					table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "SUBSECTION_SEPARATOR")
				end
		elseif buttonIndex then	-- no available WoW account
			for i = 1, 5 do
				table.remove(UnitPopupMenus["BN_FRIEND"], buttonIndex)
			end
		end
	end
	
	Original_FriendsFrame_ShowBNDropdown(name, connected, lineID, chatType, chatFrame, friendsList, bnetIDAccount)
end

-------------------------------------------------------
-- Alt + LeftButton = Invite
-- also from FriendsMenuXP
-------------------------------------------------------
function GetNameFromLink(link)
    local _, name, _ = strsplit(":", link)
    if ( name and (strlen(name) > 0) ) then	-- necessary?
        name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
        name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
    end
    return name
end

function EnhancedMenu_ChatFrame_OnHyperlinkShow(self, playerString, text, button)
    if(playerString and strsub(playerString, 1, 6) == "player") then
        if IsAltKeyDown() and button == "LeftButton" then
			DEFAULT_CHAT_FRAME.editBox:Hide()
            InviteUnit(GetNameFromLink(playerString))
            return
        end
    end
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", EnhancedMenu_ChatFrame_OnHyperlinkShow)

-------------------------------------------------------
--- Premade ARMORY_URL & COPY_NAME
-------------------------------------------------------
EnhancedMenu_Premade = {}
EnhancedMenu_Premade["ARMORY_URL"] = {
	text = L.ARMORY_URL,
	func = function(_, name) showArmoryURL(name) end,
	notCheckable = true,
	arg1 = nil, --Leader name goes here
	disabled = nil, --Disabled if we don't have a leader name yet
}

EnhancedMenu_Premade["WOW_P"] = {
	text = L.WOW_P,
	func = function(_, name) showWoWPURL(name) end,
	notCheckable = true,
	arg1 = nil, --Leader name goes here
	disabled = nil, --Disabled if we don't have a leader name yet
}

--if necessary, add it later
EnhancedMenu_Premade["COPY_NAME"] = {
	text = L.COPY_NAME,
	func = function(_, name) 
		local editBox = ChatEdit_ChooseBoxForSend()
		if editBox:HasFocus() then
			editBox:Insert(name)
		else
			ChatEdit_ActivateChat(editBox)
			editBox:SetText(name)
			editBox:HighlightText()
		end
	end,
	notCheckable = true,
	arg1 = nil, --Leader name goes here
	disabled = nil, --Disabled if we don't have a leader name yet
}

-- Interface\FrameXML\LFGList.lua line 2687
local LFG_LIST_SEARCH_ENTRY_MENU = {
    {
        text = nil, --Group name goes here
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER_LEADER,
        func = function(_, name) ChatFrame_SendTell(name); end,
        notCheckable = true,
        arg1 = nil, --Leader name goes here
        disabled = nil, --Disabled if we don't have a leader name yet or you haven't applied
        tooltipWhileDisabled = 1,
        tooltipOnButton = 1,
        tooltipTitle = nil, --The title to display on mouseover
        tooltipText = nil, --The text to display on mouseover
    },
	{	-- ARMORY_URL
        text = EnhancedMenu_Premade["ARMORY_URL"].text,
		func = EnhancedMenu_Premade["ARMORY_URL"].func,
		notCheckable = EnhancedMenu_Premade["ARMORY_URL"].notCheckable,
		arg1 = EnhancedMenu_Premade["ARMORY_URL"].arg1,
        disabled = EnhancedMenu_Premade["ARMORY_URL"].disabled,
    },
    {
        text = LFG_LIST_REPORT_GROUP_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_BAD_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistname"); end,
				arg1 = nil, --Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistcomment"); end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_VOICE_CHAT_COMMENT,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistvoicechat"); end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_LEADER_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "badplayername"); end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if we don't have a name for the leader
			},
		},
    },
    {
        text = CANCEL,
        notCheckable = true,
    },
};

-- Interface\FrameXML\LFGList.lua line 2744
function LFGListUtil_GetSearchEntryMenu(resultID)
    local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers = C_LFGList.GetSearchResultInfo(resultID);
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
    LFG_LIST_SEARCH_ENTRY_MENU[1].text = name;
    LFG_LIST_SEARCH_ENTRY_MENU[2].arg1 = leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName;
	
	-- remove requirement "applied"
	-- local applied = (appStatus == "applied" or appStatus == "invited");
	-- LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName or not applied;
	-- LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipTitle = (not applied) and WHISPER
	-- LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipText = (not applied) and LFG_LIST_MUST_SIGN_UP_TO_WHISPER;
	
	-------------------------------------------------------
	-- add our menu(s)
    LFG_LIST_SEARCH_ENTRY_MENU[3].arg1 = leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[3].disabled = not leaderName;
	-------------------------------------------------------
	
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (comment == "");
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].disabled = (voiceChat == "");
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].disabled = not leaderName;
    return LFG_LIST_SEARCH_ENTRY_MENU;
end

-- Interface\FrameXML\LFGList.lua line 2763
local LFG_LIST_APPLICANT_MEMBER_MENU = {
    {
        text = nil, --Player name goes here
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER,
        func = function(_, name) ChatFrame_SendTell(name); end,
        notCheckable = true,
        arg1 = nil, --Player name goes here
        disabled = nil, --Disabled if we don't have a name yet
    },
    {	-- ARMORY_URL
        text = EnhancedMenu_Premade["ARMORY_URL"].text,
		func = EnhancedMenu_Premade["ARMORY_URL"].func,
		notCheckable = EnhancedMenu_Premade["ARMORY_URL"].notCheckable,
		arg1 = EnhancedMenu_Premade["ARMORY_URL"].arg1,
        disabled = EnhancedMenu_Premade["ARMORY_URL"].disabled,
    },
	{	-- ARMORY_URL
        text = EnhancedMenu_Premade["WOW_P"].text,
		func = EnhancedMenu_Premade["WOW_P"].func,
		notCheckable = EnhancedMenu_Premade["WOW_P"].notCheckable,
		arg1 = EnhancedMenu_Premade["WOW_P"].arg1,
        disabled = EnhancedMenu_Premade["WOW_P"].disabled,
    },
    {
		text = LFG_LIST_REPORT_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_BAD_PLAYER_NAME,
				notCheckable = true,
				func = function(_, id, memberIdx) C_LFGList.ReportApplicant(id, "badplayername", memberIdx); end,
				arg1 = nil, --Applicant ID goes here
				arg2 = nil, --Applicant Member index goes here
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				notCheckable = true,
				func = function(_, id) C_LFGList.ReportApplicant(id, "lfglistappcomment"); end,
				arg1 = nil, --Applicant ID goes here
			},
		},
	},
	{
		text = IGNORE_PLAYER,
		notCheckable = true,
		func = function(_, name, applicantID) AddIgnore(name); C_LFGList.DeclineApplicant(applicantID); end,
		arg1 = nil, --Player name goes here
		arg2 = nil, --Applicant ID goes here
		disabled = nil, --Disabled if we don't have a name yet
	},
	{
		text = CANCEL,
		notCheckable = true,
	},
};

-- Interface\FrameXML\LFGList.lua line 2763
function LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
    local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
    LFG_LIST_APPLICANT_MEMBER_MENU[1].text = name or " ";
    LFG_LIST_APPLICANT_MEMBER_MENU[2].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[2].disabled = not name or (status ~= "applied" and status ~= "invited");
	
	-------------------------------------------------------
	-- add our menu(s)
    LFG_LIST_APPLICANT_MEMBER_MENU[3].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[3].disabled = not name or (status ~= "applied" and status ~= "invited");
	-------------------------------------------------------
	
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg1 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg2 = memberIdx;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].arg1 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].disabled = (comment == "");
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg2 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[5].disabled = not name;
    return LFG_LIST_APPLICANT_MEMBER_MENU;
end