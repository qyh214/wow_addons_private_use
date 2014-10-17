--------------------------------------------------------------------------
-- ChatBar.lua 
--------------------------------------------------------------------------
--[[
ChatBar

Author: AnduinLothar - karlkfi@yahoo.com
Graphics: Vynn, Zseton

-Button Bar for openning chat messages of each type.

Change Log:
v 3.6 (yarko)
- Chatbar now clears text the user might have typed before clicking on whisper buttons and puts it back when clicking elsewhere
v 3.5 (yarko)
- Whisper now defaults to the name last whispered if no whisper has been received
- Adjusted for new raid and group API functions
- Adjusted for new instance chat features
- toc to 50100
v3.4
-Fixed 'show text' and 'large buttons' settings to correctly save between sessions
v3.3
-Fixed nil error
-Sped up the bar animation a bit
v3.2
-Removed 'this' usage
-Buttons are now created on demand for less memory usage
-Fixed to work with latest chat changes
-Added BNet Whisper Button
-Added BNet Conversation Button
-toc to 40000
v3.1 (yarko)
-Added larger buttons option to options menu
-Added channel blocking capability to channel buttons right-click menu
-"/w" is now removed if the user first clicks the whisper button then another button without entering a whisper
-toc to 30300
v3.0
-Added a fix for parsing the first character of a chinese channel (3 chars)
-Fixed battleground chat button not showing up (thanks 狂飙)
-Fixed Show Channel ID on Buttons not working
v2.9
-Fixed a channel bug
v2.8
-Added Chat Type Bindings
-Added Channel Bindings by Number
-Channel Bindings can be overridden to save by name
-Updated a lot of old code
-toc to 30200
v2.7
-Added Simplified Chinese Localization (thanks IceChen)
-Added new Squares skin (thanks Chianti/Кьянти)
-Added new skin dropdown (Solid, Glass, Squares)
v2.6
-Added Traditional Chinese Localization
-Fixed a bug with Russian Localization
v2.5
-toc to 30000
-Fixed Sea dep
v2.4
-Removed SeaPrint usage
-Made Chronos optional: Reorder Channels is disabled w/o Chronos installed.
-Added english TBC/WotLK capitol cities to the reorder management
(Best results if in a capitol city and in the LFG queue)
v2.3
-Added Russian Localization (thanks Старостин Алексей)
v2.2
-Added Alternate Artwork (thanks Zseton)
v2.1
-Added Spanish Localization (thanks NeKRoMaNT)
v2.0
-Added an option to Hide All Buttons
-Fixed menu not showing a list of hidden buttons
v1.9
-Fixed chat type openning for new editbox:SetAttribute syntax
v1.8
-Prepared for Lua 5.1
-Added embedded SeaPrint for printing (was already used, just not included)
v1.7
-Added Raid Warning (A) and Battleground (B) chat
v1.6
-Channel Reorder no longer requires Sky
-toc to 11200
v1.5
-Fixed saved variables issue with 1.11 not saving nils
-Fixed a nill bug with the right-click menu
v1.4
-Fixed a nil loading error
v1.3
-Fixed nil SetText errors
-Fixed channel 10 nil errors
-Added Channel Reorder (from ChannelManager) if you have Sky installed (uses many library functions)
v1.2
-VisibilityOptions AutoHide is now smarter and shows whenever ChatBar is sliding or being dragged or the cursor is over its menu
-Fixed Eclipse onload error
-Fixed Whisper abreviation
v1.1
-Addon Channels Hidden added GuildMap
-Text has been made Localizable
-Officer chat shows up if you CanEditOfficerNote()
-Buttons now correctly update when raid, party, and guild changes
-Hide Text now correctly says Show Text
-Fixed button for channel 8 to diplay and tooltip correctly
-Added Reset Position Option
-Added Options to hide the each button by chat type or channel name (hide from button menu, show from main sub menu)
-Added option to use Channel Numbers as text overlay
-Added VisibilityOptions, however autohide is a bit finicky atm.
v1.0
-Initial Release

]]--

--------------------------------------------------
-- Globals
--------------------------------------------------

local addonName, addonTable = ...;

CHAT_BAR_BUTTON_SIZE = 16; -- height/width of each button
CHAT_BAR_EDGE_SIZE = 10; -- amount of space that the bar extends past the first/last button
CHAT_BAR_UPDATE_DELAY = 30;
CHAT_BAR_LARGEBUTTONSCALE = 1.3;
ChatBar_VerticalDisplay = false;
ChatBar_AlternateOrientation = false;
ChatBar_TextOnButtonDisplay = false;
ChatBar_ButtonFlashing = true;
ChatBar_BarBorder = true;
ChatBar_ButtonText = true;
ChatBar_TextChannelNumbers = false;
ChatBar_VerticalDisplay_Sliding = false;
ChatBar_AlternateDisplay_Sliding = false;
ChatBar_LargeButtons_Sliding = false;
ChatBar_HideSpecialChannels = true;
ChatBar_StoredStickies = { };
ChatBar_HiddenButtons = { };
ChatBar_AltArtDirs = { "SkinSolid", "SkinGlass", "SkinSquares" };
ChatBar_ChannelBindings = {};
ChatBar_ButtonScale = 1;

local lastText = nil;

--------------------------------------------------
-- Button Functions
--------------------------------------------------

function ChatBar_UseChatType(chatType, target)
	--local chatFrame = SELECTED_DOCK_FRAME or DEFAULT_CHAT_FRAME;
	--local editBox = chatFrame.editBox;
	local editBox = ChatEdit_ChooseBoxForSend();
	local chatFrame = editBox.chatFrame;
	
	if (lastText) then
		editBox:SetText(lastText);
		lastText = nil;
	end
	
	local chatType, channelIndex = string.gmatch(chatType, "([^%d]*)([%d]*)$")();
	
	if chatType == "WHISPER" or chatType == "BN_WHISPER" then
		--target = ChatEdit_GetLastToldTarget();
		target = ChatEdit_GetLastTellTarget();
		if not target or target == "" then
			--target = ChatEdit_GetLastTellTarget();
			target = ChatEdit_GetLastToldTarget();
		end
		if not target or target == "" then
			--start new (bn) whisper
			lastText = editBox:GetText();
			ChatFrame_OpenChat("/w ", chatFrame);
			ChatEdit_UpdateHeader(editBox);
		else
			ChatEdit_ActivateChat(editBox);
			editBox:SetAttribute("chatType", chatType);
			editBox:SetAttribute("tellTarget", target);
			ChatEdit_UpdateHeader(editBox);
		end
		
	elseif chatType == "BN_CONVERSATION" then
		target = ChatBar_GetLastBNConversationInTarget();
		if target == "" then
			target = ChatBar_GetLastBNConversationOutTarget();
		end
		if target == "" then
			target = GetFristBNConversation() or "";
		end
		if target == "" then
			--start new bn conversation
			BNConversationInvite_NewConversation();
		else
			--target = target + MAX_WOW_CHAT_CHANNELS;
			ChatEdit_ActivateChat(editBox);
			editBox:SetAttribute("channelTarget", target);
			editBox:SetAttribute("chatType", chatType);
			ChatEdit_UpdateHeader(editBox);
		end
		
	elseif chatType == "CHANNEL" then
		if target then
			if type(target) == "string" then
				target = GetChannelName(target);
			end
		elseif channelIndex then
			target = tonumber(channelIndex);
		else
			return
		end
		ChatEdit_ActivateChat(editBox);
		editBox:SetAttribute("channelTarget", target);
		editBox:SetAttribute("chatType", "CHANNEL");
		ChatEdit_UpdateHeader(editBox);
		
	elseif chatType then
		ChatEdit_ActivateChat(editBox);
		editBox:SetAttribute("chatType", chatType);
		ChatEdit_UpdateHeader(editBox);
	end
	
	local text = (editBox:GetText() or "");
	
	if ChatEdit_GetLastTellTarget() == "" and chatType ~= "WHISPER" and chatType ~= "BN_WHISPER"
			and strsub(text, 1, 3) == "/w " then
		ChatFrame_OpenChat("", chatFrame);
	end
end

function ChatBar_StandardButtonClick(self, button, target)
	if button == "RightButton" then
		ToggleDropDownMenu(1, self.ChatID, ChatBar_DropDown, self:GetName(), 10, 0, "TOPRIGHT");
	else
		local chatType = ChatBar_ChatTypes[self.ChatID].type;
		ChatBar_UseChatType(chatType, target);
	end
end

function ChatBar_ChannelShortText(index)
	local channelNum, channelName = GetChannelName(index);
	if channelNum ~= 0 then
		if ChatBar_TextChannelNumbers then
			return channelNum;
		else
			return strsub(channelName,1,CHATBAR_CHAR_LENGTH);
		end
	end
end

function ChatBar_ChannelText(index)
	local channelNum, channelName = GetChannelName(index);
	if channelNum ~= 0 then
		return channelNum..") "..channelName;
	end
	return "";
end

function ChatBar_ChannelShow(index)
	local channelNum, channelName = GetChannelName(index);
	if channelNum ~= 0 then
		if ChatBar_HideSpecialChannels then
			--Special Hidden Whisper Ignores
			if IsAddOnLoaded("Sky") then
				if string.len(channelName) >= 3 and string.sub(channelName,1,3) == "Sky" then
					--Hide Sky channels
					return;
				end
				for i, bogusName in ipairs(BOGUS_CHANNELS) do
					if channelName == bogusName then
						--Hide reorder channels
						return;
					end
				end
			elseif IsAddOnLoaded("CallToArms") and channelName == CTA_DEFAULT_RAID_CHANNEL then
				--Hide CallToArms channel
				return;
			elseif IsAddOnLoaded("CT_RaidAssist") and channelName == CT_RA_Channel then
				--Hide CT_RaidAssist channel
				return;
			elseif IsAddOnLoaded("GuildMap") and GuildMapConfig and channelName == GuildMapConfig.channel then
				--Hide GuildMap channel
				return;
			elseif channelName == "GlobalComm" then
				--Hide standard GlobalComm channel (Telepathy, AceComm)
				return;
			end
		end
		return not ChatBar_HiddenButtons[ChatBar_GetFirstWord(channelName)];
	end
end

function ChatBar_BNConversationShow(chanNum)
	local conversationID = chanNum - MAX_WOW_CHAT_CHANNELS;
	if ( BNGetConversationInfo(conversationID) ) then
		return not ChatBar_HiddenButtons["BN_CONVERSATION"..chanNum];
	end
end

function ChatBar_BNConversation_DisplayConversationTooltip(tooltip, chanNum)
	local info = ChatTypeInfo["BN_CONVERSATION"];
	tooltip:SetText(format(CONVERSATION_NAME, chanNum), info.r, info.g, info.b);

	local conversationID = chanNum - MAX_WOW_CHAT_CHANNELS;
	
	for i=1, BNGetNumConversationMembers(conversationID) do
		local accountID, toonID, name = BNGetConversationMemberInfo(conversationID, i);
		tooltip:AddLine(name, FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
	end
	
	tooltip:Show();
end


--------------------------------------------------
-- BNet Conversations
--------------------------------------------------

local ChatBar_LastBNConversationOutTarget = {};
for i = 1, BNGetMaxNumConversations() do
	ChatBar_LastBNConversationOutTarget[i] = "";
end
local ChatBar_LastBNConversationInTarget = "";

function ChatBar_GetLastBNConversationOutTarget()
	for index, value in ipairs(ChatBar_LastBNConversationOutTarget) do
		if ( value ~= "" ) then
			return value;
		end
	end
	return "";
end

function ChatBar_SetLastBNConversationOutTarget(target)
	local found = #ChatBar_LastBNConversationOutTarget;
	for index, value in ipairs(ChatBar_LastBNConversationOutTarget) do
		if ( strupper(target) == strupper(value) ) then
			found = index;
			break;
		end
	end

	for i = found, 2, -1 do
		ChatBar_LastBNConversationOutTarget[i] = ChatBar_LastBNConversationOutTarget[i-1];
	end
	ChatBar_LastBNConversationOutTarget[1] = target;
end

function ChatBar_GetNextBNConversationOutTarget(target)
	if ( not target or target == "" ) then
		return ChatBar_LastBNConversationOutTarget[1];
	end

	for i = 1, #ChatBar_LastBNConversationOutTarget - 1, 1 do
		if ( ChatBar_LastBNConversationOutTarget[i] == "" ) then
			break;
		elseif ( strupper(target) == strupper(ChatBar_LastBNConversationOutTarget[i]) ) then
			if ( ChatBar_LastBNConversationOutTarget[i+1] ~= "" ) then
				return ChatBar_LastBNConversationOutTarget[i+1];
			else
				break;
			end
		end
	end

	return ChatBar_LastBNConversationOutTarget[1];
end

function ChatBar_GetLastBNConversationInTarget()
	return ChatBar_LastBNConversationInTarget;
end

function ChatBar_SetLastBNConversationInTarget(conversationID)
	ChatBar_LastBNConversationInTarget = conversationID or "";
end

hooksecurefunc("BNSendConversationMessage", function(target, text)
	ChatBar_SetLastBNConversationOutTarget(target);
end);

hooksecurefunc("ChatEdit_OnEscapePressed", function()
	lastText = nil;
end);

--Check to see if there's an existing conversation (only persists on reloads)
function GetFristBNConversation()
	local conversationID = nil;
	for i=1, BNGetMaxNumConversations() do
		if BNGetConversationInfo(i) then
			conversationID = i;
			break;
		end
	end
	return conversationID;
end


--------------------------------------------------
-- Button Info
--------------------------------------------------

ChatBar_ChatTypes = {
	{
		type = "SAY",
		shortText = function() return CHATBAR_SAY_ABRV; end,
		text = function() return CHAT_MSG_SAY; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		show = function()
			return (not ChatBar_HiddenButtons[CHAT_MSG_SAY]);
		end
	},
	{
		type = "YELL",
		shortText = function() return CHATBAR_YELL_ABRV; end,
		text = function() return CHAT_MSG_YELL; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		show = function()
			return (not ChatBar_HiddenButtons[CHAT_MSG_YELL]);
		end
	},
	{
		type = "PARTY",
		shortText = function() return CHATBAR_PARTY_ABRV; end,
		text = function() return CHAT_MSG_PARTY; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		blockExtra = {"PARTY_LEADER"};
		show = function()
			return UnitExists("party1") and (not ChatBar_HiddenButtons[CHAT_MSG_PARTY]);
		end
	},
	{
		type = "RAID",
		shortText = function() return CHATBAR_RAID_ABRV; end,
		text = function() return CHAT_MSG_RAID; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		blockExtra = {"RAID_LEADER"};
		show = function()
			return IsInRaid() and (not ChatBar_HiddenButtons[CHAT_MSG_RAID]);
		end
	},
	{
		type = "RAID_WARNING",
		shortText = function() return CHATBAR_RAID_WARNING_ABRV; end,
		text = function() return CHAT_MSG_RAID_WARNING; end,
		click = ChatBar_StandardButtonClick,
		show = function()
			return IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and (not ChatBar_HiddenButtons[CHAT_MSG_RAID_WARNING]);
		end
	},
	{
		type = "INSTANCE_CHAT",
		shortText = function() return CHATBAR_INSTANCE_CHAT_ABRV; end,
		text = function() return INSTANCE_CHAT; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		blockExtra = {"INSTANCE_CHAT_LEADER"};
		show = function()
			return IsInInstance() and (not ChatBar_HiddenButtons[CHAT_MSG_INSTANCE_CHAT]);
		end
	},
	{
		type = "GUILD",
		shortText = function() return CHATBAR_GUILD_ABRV; end,
		text = function() return CHAT_MSG_GUILD; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		blockExtra = {"GUILD_ACHIEVEMENT"};
		show = function()
			return IsInGuild() and (not ChatBar_HiddenButtons[CHAT_MSG_GUILD]);
		end
	},
	{
		type = "OFFICER",
		shortText = function() return CHATBAR_OFFICER_ABRV; end,
		text = function() return CHAT_MSG_OFFICER; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		chatGroup = "GUILD_OFFICER",
		show = function()
			return CanEditOfficerNote() and (not ChatBar_HiddenButtons[CHAT_MSG_OFFICER]);
		end
	},
	{
		type = "WHISPER",
		shortText = function() return CHATBAR_WHISPER_ABRV; end,
		text = function() return CHAT_MSG_WHISPER_INFORM; end,
		click = ChatBar_StandardButtonClick,
		show = function()
			return (not ChatBar_HiddenButtons[CHAT_MSG_WHISPER_INFORM]);
		end
	},
	{
		type = "BN_WHISPER",
		shortText = function() return CHATBAR_BN_WHISPER_ABRV; end,
		text = function() return BN_WHISPER; end,
		click = ChatBar_StandardButtonClick,
		show = function()
			return (not ChatBar_HiddenButtons[BN_WHISPER]);
		end
	},
	{
		type = "EMOTE",
		shortText = function() return CHATBAR_EMOTE_ABRV; end,
		text = function() return CHAT_MSG_EMOTE; end,
		click = ChatBar_StandardButtonClick,
		blockable = true,
		show = function()
			return (not ChatBar_HiddenButtons[CHAT_MSG_EMOTE]);
		end
	},
	{
		type = "CHANNEL1",
		shortText = function() return ChatBar_ChannelShortText(1); end,
		text = function() return ChatBar_ChannelText(1); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 1); end,
		show = function() return ChatBar_ChannelShow(1); end
	},
	{
		type = "CHANNEL2",
		shortText = function() return ChatBar_ChannelShortText(2); end,
		text = function() return ChatBar_ChannelText(2); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 2); end,
		show = function() return ChatBar_ChannelShow(2); end
	},
	{
		type = "CHANNEL3",
		shortText = function() return ChatBar_ChannelShortText(3); end,
		text = function() return ChatBar_ChannelText(3); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 3); end,
		show = function() return ChatBar_ChannelShow(3); end
	},
	{
		type = "CHANNEL4",
		shortText = function() return ChatBar_ChannelShortText(4); end,
		text = function() return ChatBar_ChannelText(4); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 4); end,
		show = function() return ChatBar_ChannelShow(4); end
	},
	{
		type = "CHANNEL5",
		shortText = function() return ChatBar_ChannelShortText(5); end,
		text = function() return ChatBar_ChannelText(5); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 5); end,
		show = function() return ChatBar_ChannelShow(5); end
	},
	{
		type = "CHANNEL6",
		shortText = function() return ChatBar_ChannelShortText(6); end,
		text = function() return ChatBar_ChannelText(6); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 6); end,
		show = function() return ChatBar_ChannelShow(6); end
	},
	{
		type = "CHANNEL7",
		shortText = function() return ChatBar_ChannelShortText(7); end,
		text = function() return ChatBar_ChannelText(7); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 7); end,
		show = function() return ChatBar_ChannelShow(7); end
	},
	{
		type = "CHANNEL8",
		shortText = function() return ChatBar_ChannelShortText(8); end,
		text = function() return ChatBar_ChannelText(8); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 8); end,
		show = function() return ChatBar_ChannelShow(8); end
	},
	{
		type = "CHANNEL9",
		shortText = function() return ChatBar_ChannelShortText(9); end,
		text = function() return ChatBar_ChannelText(9); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 9); end,
		show = function() return ChatBar_ChannelShow(9); end
	},
	{
		type = "CHANNEL10",
		shortText = function() return ChatBar_ChannelShortText(10); end,
		text = function() return ChatBar_ChannelText(10); end,
		click = function(self, button) ChatBar_StandardButtonClick(self, button, 10); end,
		show = function() return ChatBar_ChannelShow(10); end
	},
	-- These bnet conversations are actually chat channels that start at 11 (tho the index resets to 1)
	{
		type = "BN_CONVERSATION",
		shortText = function() return CHATBAR_BN_CONVERSATION_ABRV; end,
		text = function() return CHAT_MSG_BN_CONVERSATION; end,
		click = ChatBar_StandardButtonClick,
		show = function()
			return (not ChatBar_HiddenButtons[BN_CONVERSATION]);
		end
	}
};

ChatBar_BarTypes = {};

--------------------------------------------------
-- Frame Scripts
--------------------------------------------------

function ChatBar_OnLoad(self)
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterForDrag("LeftButton");
	self.velocity = 0;
	if (Eclipse) then
		--Register with VisibilityOptions
		Eclipse.registerForVisibility( {
			name = "ChatBarFrame";	--The name of the config, in this case also the name of the frame
			uiname = "ChatBar";	--This is the base name of this reg to display in the description and ui
			slashcom = { "chatbar", "cb" };	--These are the slash commands
			reqs = { var=ChatBar_ShowIf, val=true, show=true };
		}	);
	end
end

function ChatBar_ShowIf()
	return ChatBarFrame.isSliding or ChatBarFrame.isMoving or (type(ChatBarFrame.count)=="number") or ((UIDROPDOWNMENU_OPEN_MENU=="ChatBar_DropDown" and (MouseIsOver(DropDownList1) or (UIDROPDOWNMENU_MENU_LEVEL==2 and MouseIsOver(DropDownList2))))==1);
end

function ChatBar_OnEvent(self, event, ...)
	local chanNum = select(8, ...)
	if event == "UPDATE_CHAT_COLOR" then
		self.count = 0;
	elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
		self.count = 0;
	elseif event == "PARTY_MEMBERS_CHANGED" then
		self.count = 0;
	elseif event == "RAID_ROSTER_UPDATE" then
		self.count = 0;
	elseif event == "PLAYER_GUILD_UPDATE" then
		self.count = 0;
	elseif event == "CHAT_MSG_CHANNEL" and type(chanNum) == "number" then
		if ChatBar_BarTypes["CHANNEL"..chanNum] then
			--UIFrameFlash(_G["ChatBarFrameButton"..ChatBar_BarTypes["CHANNEL"..chanNum].."Flash"], .5, .5, 1.1);--13
		end
	elseif event == "CHAT_MSG_BN_CONVERSATION" then
		ChatBar_SetLastBNConversationInTarget(chanNum);
	elseif event == "VARIABLES_LOADED" then
		
		ChatBar_UpdateArt();
		ChatBar_UpdateAllButtonOrientation();
		ChatBar_UpdateButtonFlashing();
		ChatBar_UpdateBarBorder();
		ChatBar_UpdateChannelBindings();
		
		ChatBar_ForAllButtons(function(button) 
			ChatBar_UpdateButtonText(button);
			ChatBar_UpdateButtonSize(button);
		end);
		
		--Update live Stickies
		for chatType, enabled in pairs(ChatBar_StoredStickies) do
			if enabled then
				ChatTypeInfo[chatType].sticky = enabled;
			end
		end
	else
		if ChatBar_BarTypes[strsub(event,10)] then
			--UIFrameFlash(_G["ChatBarFrameButton"..ChatBar_BarTypes[strsub(event,10)].."Flash"], .5, .5, 1.1);
		end
	end
end

--ConstantInitialVelocity = 10;
ConstantVelocityModifier = 1.5;
ConstantJerk = 3.5;
ConstantSnapLimit = 2;

function ChatBar_OnUpdate(self, elapsed)
	
	if (self.slidingEnabled) and (self.isSliding) and (self.velocity) and (self.endsize) then
		local currSize = ChatBar_GetSize();
		if (math.abs(currSize - self.endsize) < ConstantSnapLimit) then
			ChatBar_SetSize(self.endsize);
			ChatBarFrame.isSliding = nil;
			self.velocity = 0;
			if (ChatBar_VerticalDisplay_Sliding or ChatBar_AlternateDisplay_Sliding 
					or ChatBar_LargeButtons_Sliding) and (self:GetWidth() <= 17) and (self:GetHeight() <= 17) then
				if (ChatBar_VerticalDisplay_Sliding) then
					ChatBar_VerticalDisplay_Sliding = nil;
					ChatBar_Toggle_VerticalButtonOrientation();
				elseif (ChatBar_AlternateDisplay_Sliding) then
					ChatBar_AlternateDisplay_Sliding = nil;
					ChatBar_Toggle_AlternateButtonOrientation();
				elseif (ChatBar_LargeButtons_Sliding) then
					ChatBar_LargeButtons_Sliding = nil;
					ChatBar_Toggle_LargeButtons();
				end
				ChatBar_UpdateOrientationPoint();
			else
				ChatBar_UpdateOrientationPoint(true);
			end
		else
			--[[
			local desiredVelocity = ConstantVelocityModifier * (self.endsize - currSize);
			self.velocity = (1 - ConstantJerk) * self.velocity + ConstantJerk * desiredVelocity;
			ChatBar_SetSize(currSize + self.velocity * elapsed);
			]]--
			--[[
			local w = 1 - math.exp(-ConstantJerk* elapsed);
			self.velocity = (1-w)* self.velocity + w*ConstantVelocityModifier*(self.endsize - currSize);
			ChatBar_SetSize(currSize + self.velocity * elapsed);
			]]--
			--[[ incomplete
			local totalDistance = self.endsize - self.startsize; 
			local distanceFromStart = self.startsize - currSize;
			local accel = math.cos(distanceFromStart/totalDistance*math.pi) * ConstantJerk;
			ChatBar_SetSize(currSize + accel * elapsed * elapsed);
			]]--
			local desiredVelocity = ConstantVelocityModifier * (self.endsize - currSize);
			local acceleration = ConstantJerk * (desiredVelocity - self.velocity);
			self.velocity = self.velocity + acceleration * elapsed;
			ChatBar_SetSize(currSize + self.velocity * elapsed);
		end

		-- Show the buttons if there is room on the bar
		ChatBar_ForAllButtons(function(button, buttonIndex) 
			if (currSize >= buttonIndex*(CHAT_BAR_BUTTON_SIZE*ChatBar_ButtonScale)+18) then
				button:Show();
			else
				button:Hide();
			end
		end);
		
	elseif (self.count) then
		if (self.count > CHAT_BAR_UPDATE_DELAY) then
			self.count = nil;
			ChatBarFrame.slidingEnabled = true;
			ChatBar_UpdateButtons();
		else
			self.count = self.count+1;
		end
	end
	
end

function ChatBar_GetSize()
	if (ChatBar_VerticalDisplay) then
		return ChatBarFrame:GetHeight();
	else
		return ChatBarFrame:GetWidth();
	end
end

function ChatBar_SetSize(size)
	if (ChatBar_VerticalDisplay) then
		ChatBarFrame:SetHeight(size);
	else
		ChatBarFrame:SetWidth(size);
	end
end

function ChatBar_Button_OnLoad(self)
	self.Text = _G["ChatBarFrameButton".. self:GetID().."Text"];
	self.ChatID = self:GetID();
	local frameName = self:GetName();

	_G[frameName.."Highlight"]:SetAlpha(.75);
	_G[frameName.."UpTex_Spec"]:SetAlpha(.75);
	_G[frameName.."UpTex_Shad"]:SetAlpha(.75);
	--_G[frameName.."DownTex_Spec"]:SetAlpha(1);
	_G[frameName.."DownTex_Shad"]:SetAlpha(1);
	
	self:SetFrameLevel(self:GetFrameLevel()+1);
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
end

function ChatBar_Button_OnClick(self, button)
	ChatBar_ChatTypes[self.ChatID].click(self, button);
end

function ChatBar_Button_OnEnter(self)
	--local id = self:GetID();
	if (self.ChatID) then
		if ( self.chatType == "BN_CONVERSATION" ) then
			ChatBarFrameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
			ChatBar_BNConversation_DisplayConversationTooltip(ChatBarFrameTooltip, self.ChatID);
		else
			ChatBarFrameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
			ChatBarFrameTooltip:SetText(ChatBar_ChatTypes[self.ChatID].text());
		end
	end
end

function ChatBar_Button_OnLeave(self)
	if (ChatBarFrameTooltip:IsOwned(self)) then
		ChatBarFrameTooltip:Hide();
	end
	if (GameTooltip:IsOwned(self)) then
		GameTooltip:Hide();
	end
end

function ChatBar_Button_OnMouseDown(self, button)
	_G[self:GetName().."UpTex_Spec"]:Hide();
	_G[self:GetName().."DownTex_Spec"]:Show();
end

function ChatBar_Button_OnMouseUp(self, button)
	_G[self:GetName().."UpTex_Spec"]:Show();
	_G[self:GetName().."DownTex_Spec"]:Hide();
end

function ChatBar_OnMouseDown(self, button)
	if (button == "RightButton") then
		ToggleDropDownMenu(1, "ChatBarMenu", ChatBar_DropDown, "cursor");
	else
		local x, y = GetCursorPosition();
		self.xOffset = x - self:GetLeft();
		self.yOffset = y - self:GetBottom();
	end
end

function ChatBar_OnDragStart(self)
	if (not self.isSliding) then
		local x, y = GetCursorPosition();
		self:ClearAllPoints();
		self:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x-self.xOffset, y-self.yOffset);
		self:StartMoving();
		self.isMoving = true;
	end
end

function ChatBar_OnDragStop(self)
	self:StopMovingOrSizing();
	self.isMoving = false;
	ChatBar_UpdateOrientationPoint(true);
end

--------------------------------------------------
-- DropDown Menu
--------------------------------------------------

function ChatBar_DropDownOnLoad(self)
	UIDropDownMenu_Initialize(self, ChatBar_LoadDropDownMenu, "MENU");
end

function ChatBar_LoadDropDownMenu()
	if (not UIDROPDOWNMENU_MENU_VALUE) then
		return;
	end
	
	if (UIDROPDOWNMENU_MENU_VALUE == "ChatBarMenu") then
		ChatBar_CreateFrameMenu();
	elseif (UIDROPDOWNMENU_MENU_VALUE == "HiddenButtonsMenu") then
		ChatBar_CreateHiddenButtonsMenu();
	elseif (UIDROPDOWNMENU_MENU_VALUE == "AltArtMenu") then
		ChatBar_CreateAltArtMenu();
	elseif (strsub(UIDROPDOWNMENU_MENU_VALUE, 1, 7) == "CHANNEL") then
		ChatBar_CreateChannelBindingMenu();
	else
		ChatBar_CreateButtonMenu();
	end
	
end

function ChatBar_CreateFrameMenu()
	--Title
	local info = {};
	info.text = CHATBAR_MENU_MAIN_TITLE;
	info.notClickable = 1;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Large Buttons
	local info = {};
	info.text = CHATBAR_MENU_MAIN_LARGE;
	info.func = ChatBar_Toggle_LargeButtonsSlide;
	if (ChatBar_ButtonScale > 1) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Vertical
	local info = {};
	info.text = CHATBAR_MENU_MAIN_VERTICAL;
	info.func = ChatBar_Toggle_VerticalButtonOrientationSlide;
	if (ChatBar_VerticalDisplay) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Alt Button
	local info = {};
	info.text = CHATBAR_MENU_MAIN_REVERSE;
	info.func = ChatBar_Toggle_AlternateButtonOrientationSlide;
	if (ChatBar_AlternateOrientation) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Alt Art
	local info = {};
	info.text = CHATBAR_MENU_MAIN_ALTART;
	info.hasArrow = 1;
	info.value = "AltArtMenu";
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Text On Buttons
	local info = {};
	info.text = CHATBAR_MENU_MAIN_TEXTONBUTTONS;
	info.func = ChatBar_Toggle_TextOrientation;
	info.keepShownOnClick = 1;
	if (ChatBar_TextOnButtonDisplay) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Show Button Text
	local info = {};
	info.text = CHATBAR_MENU_MAIN_SHOWTEXT;
	info.func = ChatBar_Toggle_ButtonText;
	info.keepShownOnClick = 1;
	if (ChatBar_ButtonText) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Use Channel ID on Buttons
	local info = {};
	info.text = CHATBAR_MENU_MAIN_CHANNELID;
	info.func = ChatBar_Toggle_TextChannelNumbers;
	info.keepShownOnClick = 1;
	if (ChatBar_TextChannelNumbers) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Button Flashing
	local info = {};
	info.text = CHATBAR_MENU_MAIN_BUTTONFLASHING;
	info.func = ChatBar_Toggle_ButtonFlashing;
	info.keepShownOnClick = 1;
	if (ChatBar_ButtonFlashing) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	--Bar Border
	local info = {};
	info.text = CHATBAR_MENU_MAIN_BARBORDER;
	info.func = ChatBar_Toggle_BarBorder;
	info.keepShownOnClick = 1;
	if (ChatBar_BarBorder) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Hide Special
	local info = {};
	info.text = CHATBAR_MENU_MAIN_ADDONCHANNELS;
	info.func = ChatBar_Toggle_HideSpecialChannels;
	if (ChatBar_HideSpecialChannels) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Hide All
	local info = {};
	info.text = CHATBAR_MENU_MAIN_HIDEALL;
	info.func = ChatBar_Toggle_HideAllButtons;
	if (ChatBar_HideAllButtons) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	local size = 0;
	for _, v in pairs(ChatBar_HiddenButtons) do
		if (v) then
			size = size+1
		end
	end
	if (size > 0) then
		--Show Hidden Buttons
		local info = {};
		info.text = CHATBAR_MENU_MAIN_HIDDENBUTTONS;
		info.hasArrow = 1;
		info.func = nil;
		info.value = "HiddenButtonsMenu";
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
	
	--Reset Position
	local info = {};
	info.text = CHATBAR_MENU_MAIN_RESET;
	info.func = ChatBar_Reset;
	if (not ChatBarFrame:IsUserPlaced()) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--Reorder Channels
	local info = {};
	info.text = CHATBAR_MENU_MAIN_REORDER;
	if (not Chronos) then
		info.text = info.text..CHATBAR_MENU_MAIN_REQCHRONOS
		info.disabled = 1;
	end
	info.func = ChatBar_ReorderChannels;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function ChatBar_CreateHiddenButtonsMenu()
	for k,v in pairs(ChatBar_HiddenButtons) do
		--Show Button
		local info = {};
		info.text = format(CHATBAR_MENU_SHOW_BUTTON, k);
		local ctype = k;
		info.func = function() ChatBar_HiddenButtons[ctype]=nil ChatBarFrame.count = 0; end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function ChatBar_CreateAltArtMenu()
	for k,v in pairs(ChatBar_AltArtDirs) do
		--Show Button
		local info = {};
		info.text = _G["CHATBAR_SKIN"..k];
		local skinIndex = k;
		info.func = function() ChatBar_AltArt=skinIndex; ChatBar_UpdateArt(); end;
		if (ChatBar_AltArt == k) then
			info.checked = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function ChatBar_CreateButtonMenu()
	local buttonHeader = ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].type;
	
	--Title
	local info = {};
	info.text = ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].text();
	info.notClickable = 1;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	local chatType, channelIndex = string.gmatch(buttonHeader, "([^%d]*)([%d]+)$")();
	
	if channelIndex then
		local channelNum, channelName = GetChannelName(tonumber(channelIndex));
		local channelShortName = ChatBar_GetFirstWord(channelName);
		
		--Block
		local info = {};
		info.text = format(CHATBAR_MENU_CHANNEL_BLOCK, channelShortName);
		info.arg1 = channelShortName;
		info.func = function(self, channel, arg2, checked) ChatBar_ToggleChatChannel(checked, channel) end;
		info.checked = not ChatBar_IsListeningForChannel(channelShortName);
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		
		--Leave
		local info = {};
		info.text = CHATBAR_MENU_CHANNEL_LEAVE;
		info.func = function() LeaveChannelByName(channelNum) end;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

		--Channel User List
		local info = {};
		info.text = CHATBAR_MENU_CHANNEL_LIST;
		info.func = function() ListChannelByName(channelNum) end;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		
		--Hide Button
		local info = {};
		info.text = format(CHATBAR_MENU_HIDE_BUTTON, channelShortName);
		info.func = function() ChatBar_HiddenButtons[channelShortName]=true; ChatBarFrame.count = 0; end;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	else
		local localizedChatType = ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].text()

		--Block
		if ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].blockable then
			local info = {};
			info.text = format(CHATBAR_MENU_CHANNEL_BLOCK, localizedChatType);
			info.arg1 = UIDROPDOWNMENU_MENU_VALUE;
			info.func = function(self, chatTypeIndex, arg2, checked) ChatBar_ToggleChatMessageGroup(checked, chatTypeIndex) end;
			info.checked = not ChatBar_IsListeningForChatType(ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].chatGroup or buttonHeader);
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		
		--Hide Button
		local info = {};
		info.text = format(CHATBAR_MENU_HIDE_BUTTON, localizedChatType);
		info.func = function() ChatBar_HiddenButtons[localizedChatType]=true; ChatBarFrame.count = 0; end;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
	
	if buttonHeader == "WHISPER" then
		local chatFrame = SELECTED_DOCK_FRAME
		if not chatFrame then
			chatFrame = DEFAULT_CHAT_FRAME;
		end
		
		--Reply
		local info = {};
		info.text = CHATBAR_MENU_WHISPER_REPLY;
		info.func = function()
			ChatFrame_ReplyTell(chatFrame)
		end;
		if ChatEdit_GetLastTellTarget(ChatFrameEditBox) == "" then
			info.disabled = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		
		--Retell
		local lastTellTarget = ChatEdit_GetLastToldTarget();
		local info = {};
		info.text = CHATBAR_MENU_WHISPER_RETELL;
		info.func = function()
			ChatFrame_SendTell(lastTellTarget, chatFrame)
		end;
		if not lastTellTarget or lastTellTarget == "" then
			info.disabled = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
	
	if channelIndex then
		local info = {};
		info.text = CHATBAR_MENU_BINDING;
		info.hasArrow = 1;
		info.value = buttonHeader;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
	
	--Sticky
	local info = {};
	if chatType then
		info.text = CHATBAR_MENU_CHANNEL_STICKY;
	else
		info.text = CHATBAR_MENU_STICKY;
		chatType = buttonHeader;
	end
	info.func = function()
		if ChatTypeInfo[chatType].sticky == 1 then
			ChatTypeInfo[chatType].sticky = 0;
			ChatBar_StoredStickies[chatType] = 0;
		else
			ChatTypeInfo[chatType].sticky = 1;
			ChatBar_StoredStickies[chatType] = 1;
		end
	end;
	if ChatTypeInfo[chatType].sticky == 1 then
		info.checked = 1;
	end
	if not ChatTypeInfo[chatType] then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

end

function ChatBar_ReplaceChannelBinding(index, newTarget)
	if newTarget then
		for i=1, MAX_WOW_CHAT_CHANNELS do
			if ChatBar_ChannelBindings[i] == newTarget then
				ChatBar_ChannelBindings[i] = nil;
				_G["BINDING_NAME_CHATBAR_CHANNEL"..i] = format(BINDING_NAME_CHATBAR_CHANNEL_FORMAT, i)
			end
		end
	end
	if index then
		ChatBar_ChannelBindings[index] = newTarget;
		_G["BINDING_NAME_CHATBAR_CHANNEL"..index] = format(BINDING_NAME_CHATBAR_CHANNEL_FORMAT, newTarget)
	end
end

function ChatBar_CreateChannelBindingMenu()
	local buttonHeader = UIDROPDOWNMENU_MENU_VALUE;
	local chatType, channelIndex = string.gmatch(buttonHeader, "([^%d]*)([%d]+)$")();
	local channelNum, channelName = GetChannelName(tonumber(channelIndex));
	local channelShortName = ChatBar_GetFirstWord(channelName);
	
	--Title
	local info = {};
	info.text = CHATBAR_MENU_BINDING_TITLE;
	info.notClickable = 1;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	--None
	local info = {};
	info.text = CHATBAR_MENU_NONE;
	info.func = function() ChatBar_ReplaceChannelBinding(nil, channelShortName) end;
	info.checked = 1;
	for i=1, MAX_WOW_CHAT_CHANNELS do
		if ChatBar_ChannelBindings[i] == channelShortName then
			info.checked = nil;
			break;
		end
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	for i=1, MAX_WOW_CHAT_CHANNELS do
		local info = {};
		info.text = _G["BINDING_NAME_CHATBAR_CHANNEL"..i];
		local channelIndex = i;
		info.func = function() ChatBar_ReplaceChannelBinding(channelIndex, channelShortName) end;
		if ChatBar_ChannelBindings[i] == channelShortName then
			info.checked = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

--------------------------------------------------
-- Blocking Functions
--------------------------------------------------

function ChatBar_IsListeningForChatType(chatType)
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
	local messageTypeList = frame.messageTypeList;
	if ( messageTypeList ) then
		for index, value in pairs(messageTypeList) do
			if ( value == chatType ) then
				return true;
			end
		end
		
		local blockExtra = ChatBar_ChatTypes[UIDROPDOWNMENU_MENU_VALUE].blockExtra;
		if (blockExtra) then
			for i, v in ipairs(blockExtra) do
				for index, value in pairs(messageTypeList) do
					if ( value == v ) then
						return true;
					end
				end
			end
		end
	end
	return false;
end

function ChatBar_IsListeningForChannel(channel)
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
	local channelList = frame.channelList;
	local zoneChannelList = frame.zoneChannelList;
	if ( channelList ) then
		for index, value in pairs(channelList) do
			if ( value == channel ) then
				return true;
			end
		end
	end
	if ( zoneChannelList ) then
		for index, value in pairs(zoneChannelList) do
			if ( value == channel ) then
				return true;
			end
		end
	end
	return false;
end

function ChatBar_ToggleChatMessageGroup(checked, chatTypeIndex)
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
	local chatType = (ChatBar_ChatTypes[chatTypeIndex].chatGroup or ChatBar_ChatTypes[chatTypeIndex].type);
	local channelName = ChatBar_ChatTypes[chatTypeIndex].text();
	if ( checked ) then
		ChatFrame_AddMessageGroup(frame, chatType);
		print(format(CHATBAR_UNBLOCKED, channelName));
	else
		ChatFrame_RemoveMessageGroup(frame, chatType);
		print(format(CHATBAR_BLOCKED, channelName));
	end
		
	local blockExtra = ChatBar_ChatTypes[chatTypeIndex].blockExtra;
	if (blockExtra) then
		for i, v in ipairs(blockExtra) do
			if ( checked ) then
				ChatFrame_AddMessageGroup(frame, v);
			else
				ChatFrame_RemoveMessageGroup(frame, v);
			end
		end
	end
end

function ChatBar_ToggleChatChannel(checked, channel)
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
	if ( checked ) then
		ChatFrame_AddChannel(frame, channel);
		print(format(CHATBAR_UNBLOCKED, channel));
	else
		ChatFrame_RemoveChannel(frame, channel);
		print(format(CHATBAR_BLOCKED, channel));
	end
end

--------------------------------------------------
-- Update Functions
--------------------------------------------------

function ChatBar_CreateButton(buttonIndex)
	local button = CreateFrame("Button", "ChatBarFrameButton"..buttonIndex, ChatBarFrame, "ChatBarButtonTemplate", buttonIndex);
	button:SetPoint("LEFT", "ChatBarFrameButton"..(buttonIndex-1), "RIGHT", 0, 0);
	
	ChatBar_Button_OnLoad(button);
	
	ChatBar_UpdateButtonOrientation(button, buttonIndex);
	
	local artDir = ChatBar_AltArtDirs[ChatBar_AltArt];
	ChatBar_UpdateButtonArt(buttonIndex, artDir);
	
	ChatBar_UpdateButtonText(button);
	ChatBar_UpdateButtonSize(button);
end

-- Calls the func on each button, passing the button and the button index
function ChatBar_ForAllButtons(func, startIndex)
	local buttonIndex = startIndex or 1;
	local button = _G["ChatBarFrameButton".. buttonIndex];
	while button ~= nil do
		func(button, buttonIndex);
		buttonIndex = buttonIndex+1;
		button = _G["ChatBarFrameButton".. buttonIndex];
	end
end

function ChatBar_SetButtonToBeShown(chatTypeIndex, chatType, buttonIndex)
	local info = ChatTypeInfo[chatType.type];
	ChatBar_BarTypes[chatType.type] = buttonIndex;
	if _G["ChatBarFrameButton".. buttonIndex] == nil then
		ChatBar_CreateButton(buttonIndex);
	end
	_G["ChatBarFrameButton".. buttonIndex.."Highlight"]:SetVertexColor(info.r, info.g, info.b);
	_G["ChatBarFrameButton".. buttonIndex.."Flash"]:SetVertexColor(info.r, info.g, info.b);
	_G["ChatBarFrameButton".. buttonIndex.."Center"]:SetVertexColor(info.r, info.g, info.b);
	_G["ChatBarFrameButton".. buttonIndex.."Text"]:SetText(chatType.shortText());
	_G["ChatBarFrameButton".. buttonIndex].ChatID = chatTypeIndex;
	--_G["ChatBarFrameButton".. buttonIndex]:Show();
end

function ChatBar_SetButtonToBeHidden(button)
	button.ChatID = nil;
	--button:Hide();
end

function ChatBar_UpdateButtons()
	
	ChatBar_BarTypes = {};
	local buttonIndex = 1;
	if not ChatBar_HideAllButtons then
		for chatTypeIndex,chatType in ipairs(ChatBar_ChatTypes) do
			if chatType.show() then
				ChatBar_SetButtonToBeShown(chatTypeIndex, chatType, buttonIndex);
				buttonIndex = buttonIndex+1;
			end
		end
	end
	if ChatBar_VerticalDisplay then
		local size = (buttonIndex-1)*(CHAT_BAR_BUTTON_SIZE*ChatBar_ButtonScale)+CHAT_BAR_EDGE_SIZE*2;
		ChatBarFrame:SetWidth(CHAT_BAR_BUTTON_SIZE);
		if ChatBarFrame:GetTop() then
			ChatBar_StartSlidingTo(size);
		else
			ChatBarFrame:SetHeight(size);
		end
	else
		local size = (buttonIndex-1)*(CHAT_BAR_BUTTON_SIZE*ChatBar_ButtonScale)+CHAT_BAR_EDGE_SIZE*2;
		ChatBarFrame:SetHeight(CHAT_BAR_BUTTON_SIZE);
		if ChatBarFrame:GetRight() then
			ChatBar_StartSlidingTo(size);
		else
			ChatBarFrame:SetWidth(size);
		end
		--/z ChatBarFrame.startpoint = ChatBarFrame:GetRight();ChatBarFrame.endsize = ChatBarFrame:GetLeft() + 260;
		--/z ChatBarFrame.centerpoint = ChatBarFrame.startpoint + (ChatBarFrame.endsize - ChatBarFrame.startpoint)/2;ChatBarFrame.velocity = 0;ChatBarFrame.isSliding = true;
		--/z ChatBarFrame.isSliding = nil; ChatBarFrame:SetWidth(180)
		--/z ChatBar_StartSlidingTo(300)
	end
	-- Set the remaining buttons to be hidden
	ChatBar_ForAllButtons(ChatBar_SetButtonToBeHidden, buttonIndex);
end

function ChatBar_StartSlidingTo(size)
	ChatBarFrame.endsize = size;
	ChatBarFrame.isSliding = true;
end

function ChatBar_UpdateButtonSize(button)
	button:SetScale(ChatBar_ButtonScale) 
end

-- do not use on button #1
function ChatBar_UpdateButtonOrientation(button, buttonIndex)
	local prevButtonName = "ChatBarFrameButton"..(buttonIndex-1);
	button:ClearAllPoints();
	button.Text:ClearAllPoints();
	if ChatBar_VerticalDisplay then
		if ChatBar_AlternateOrientation then
			button:SetPoint("TOP", prevButtonName, "BOTTOM");
		else
			button:SetPoint("BOTTOM", prevButtonName, "TOP");
		end
		if ChatBar_TextOnButtonDisplay then
			button.Text:SetPoint("CENTER", button);
		else
			button.Text:SetPoint("RIGHT", button, "LEFT");
		end
	else
		if ChatBar_AlternateOrientation then
			button:SetPoint("RIGHT", prevButtonName, "LEFT");
		else
			button:SetPoint("LEFT", prevButtonName, "RIGHT");
		end
		if ChatBar_TextOnButtonDisplay then
			button.Text:SetPoint("CENTER", button);
		else
			button.Text:SetPoint("BOTTOM", button, "TOP");
		end
	end
end

function ChatBar_UpdateAllButtonOrientation()
	local button = ChatBarFrameButton1;
	button:ClearAllPoints();
	button.Text:ClearAllPoints();
	if ChatBar_VerticalDisplay then
		if ChatBar_AlternateOrientation then
			button:SetPoint("TOP", "ChatBarFrame", "TOP", 0, (-CHAT_BAR_EDGE_SIZE/ChatBar_ButtonScale));
		else
			button:SetPoint("BOTTOM", "ChatBarFrame", "BOTTOM", 0, (CHAT_BAR_EDGE_SIZE/ChatBar_ButtonScale));
		end
		if (ChatBar_TextOnButtonDisplay) then
			button.Text:SetPoint("CENTER", button);
		else
			button.Text:SetPoint("RIGHT", button, "LEFT", 0, 0);
		end
	else
		if ChatBar_AlternateOrientation then
			button:SetPoint("RIGHT", "ChatBarFrame", "RIGHT", (-CHAT_BAR_EDGE_SIZE/ChatBar_ButtonScale), 0);
		else
			button:SetPoint("LEFT", "ChatBarFrame", "LEFT", (CHAT_BAR_EDGE_SIZE/ChatBar_ButtonScale), 0);
		end
		if ChatBar_TextOnButtonDisplay then
			button.Text:SetPoint("CENTER", button);
		else
			button.Text:SetPoint("BOTTOM", button, "TOP");
		end
	end
	-- update the rest of the buttons
	ChatBar_ForAllButtons(ChatBar_UpdateButtonOrientation, 2);
end

function ChatBar_UpdateButtonFlashing()
	local frame = ChatBarFrame;
	if ChatBar_ButtonFlashing then
		frame:RegisterEvent("CHAT_MSG_SAY");
		frame:RegisterEvent("CHAT_MSG_YELL");
		frame:RegisterEvent("CHAT_MSG_PARTY");
		frame:RegisterEvent("CHAT_MSG_RAID");
		frame:RegisterEvent("CHAT_MSG_RAID_WARNING");
		frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT");
		frame:RegisterEvent("CHAT_MSG_GUILD");
		frame:RegisterEvent("CHAT_MSG_OFFICER");
		frame:RegisterEvent("CHAT_MSG_WHISPER");
		frame:RegisterEvent("CHAT_MSG_BN_WHISPER");
		frame:RegisterEvent("CHAT_MSG_BN_CONVERSATION");
		frame:RegisterEvent("CHAT_MSG_EMOTE");
		frame:RegisterEvent("CHAT_MSG_CHANNEL");
	else
		frame:UnregisterEvent("CHAT_MSG_SAY");
		frame:UnregisterEvent("CHAT_MSG_YELL");
		frame:UnregisterEvent("CHAT_MSG_PARTY");
		frame:UnregisterEvent("CHAT_MSG_RAID");
		frame:UnregisterEvent("CHAT_MSG_RAID_WARNING");
		frame:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT");
		frame:UnregisterEvent("CHAT_MSG_GUILD");
		frame:UnregisterEvent("CHAT_MSG_OFFICER");
		frame:UnregisterEvent("CHAT_MSG_WHISPER");
		frame:UnregisterEvent("CHAT_MSG_BN_WHISPER");
		frame:UnregisterEvent("CHAT_MSG_BN_CONVERSATION");
		frame:UnregisterEvent("CHAT_MSG_EMOTE");
		frame:UnregisterEvent("CHAT_MSG_CHANNEL");
	end
end

function ChatBar_UpdateBarBorder()
	if ChatBar_BarBorder then
		ChatBarFrameBackground:Show();
	else
		ChatBarFrameBackground:Hide();
	end
end

function ChatBar_Reset()
	ChatBarFrame:ClearAllPoints();
	ChatBarFrame:SetPoint("BOTTOMLEFT", "ChatFrame1", "TOPLEFT", 0, 30);
	ChatBarFrame:SetUserPlaced(0);
end

function ChatBar_UpdateButtonArt(buttonIndex, artDir)
	_G["ChatBarFrameButton"..buttonIndex.."UpTex_Spec"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Up_Spec");
	_G["ChatBarFrameButton"..buttonIndex.."DownTex_Spec"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Down_Spec");
	_G["ChatBarFrameButton"..buttonIndex.."Flash"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Glow_Alpha");
	
	_G["ChatBarFrameButton"..buttonIndex.."Center"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Center");
	_G["ChatBarFrameButton"..buttonIndex.."Background"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_BG");
	
	_G["ChatBarFrameButton"..buttonIndex.."UpTex_Shad"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Up_Shad");
	_G["ChatBarFrameButton"..buttonIndex.."DownTex_Shad"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Down_Shad");
	_G["ChatBarFrameButton"..buttonIndex.."Highlight"]:SetTexture("Interface\\AddOns\\ChatBar\\"..artDir.."\\ChanButton_Glow_Alpha");
end

function ChatBar_UpdateArt()
	if type(ChatBar_AltArt) == "boolean" or ChatBar_AltArt == nil or not ChatBar_AltArtDirs[ChatBar_AltArt] then
		ChatBar_AltArt = 1;
	end
	local artDir = ChatBar_AltArtDirs[ChatBar_AltArt];
	
	ChatBar_ForAllButtons(function(button, buttonIndex) 
		ChatBar_UpdateButtonArt(buttonIndex, artDir);
	end);
	
	ChatBarFrameBackground:SetBackdrop({
		edgeFile = "Interface\\AddOns\\ChatBar\\"..artDir.."\\ChatBarBorder";
		bgFile = "Interface\\AddOns\\ChatBar\\"..artDir.."\\BlackBg";
		tile = true, tileSize = 8, edgeSize = 8;
		insets = { left = 8, right = 8, top = 8, bottom = 8 };
	});
end

--------------------------------------------------
-- Configuration Functions
--------------------------------------------------

function ChatBar_Toggle_LargeButtonsSlide()
	if not ChatBarFrame.isMoving then
		ChatBar_LargeButtons_Sliding = true;
		ChatBar_StartSlidingTo(CHAT_BAR_BUTTON_SIZE);
	end
end

function ChatBar_Toggle_VerticalButtonOrientationSlide()
	if not ChatBarFrame.isMoving then
		ChatBar_VerticalDisplay_Sliding = true;
		ChatBar_StartSlidingTo(CHAT_BAR_BUTTON_SIZE);
	end
end

function ChatBar_Toggle_AlternateButtonOrientationSlide()
	if not ChatBarFrame.isMoving then
		ChatBar_AlternateDisplay_Sliding = true;
		ChatBar_StartSlidingTo(CHAT_BAR_BUTTON_SIZE);
	end
end

function ChatBar_Toggle_LargeButtons()
	ChatBar_ButtonScale = (ChatBar_ButtonScale == 1 and CHAT_BAR_LARGEBUTTONSCALE) or 1;
	ChatBar_ForAllButtons(ChatBar_UpdateButtonSize);
	ChatBar_UpdateAllButtonOrientation();
	ChatBar_UpdateButtons();
end

function ChatBar_Toggle_VerticalButtonOrientation()
	ChatBar_VerticalDisplay = not ChatBar_VerticalDisplay;
	--ChatBar_UpdateOrientationPoint();
	ChatBar_UpdateAllButtonOrientation();
	ChatBar_UpdateButtons();
end

function ChatBar_UpdateOrientationPoint(expanded)
	local x, y;
	if ChatBarFrame:IsUserPlaced() then
		if expanded then
			if ChatBar_AlternateOrientation then
				x = ChatBarFrame:GetRight();
				y = ChatBarFrame:GetTop();
				ChatBarFrame:ClearAllPoints();
				ChatBarFrame:SetPoint("TOPRIGHT", "UIParent", "BOTTOMLEFT", x, y);
			else
				x = ChatBarFrame:GetLeft();
				y = ChatBarFrame:GetBottom();
				ChatBarFrame:ClearAllPoints();
				ChatBarFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x, y);
			end
		else
			if ChatBar_AlternateOrientation then
				x = ChatBarFrame:GetLeft()+CHAT_BAR_BUTTON_SIZE;
				y = ChatBarFrame:GetBottom()+CHAT_BAR_BUTTON_SIZE;
				ChatBarFrame:ClearAllPoints();
				ChatBarFrame:SetPoint("TOPRIGHT", "UIParent", "BOTTOMLEFT", x, y);
			else
				x = ChatBarFrame:GetRight()-CHAT_BAR_BUTTON_SIZE;
				y = ChatBarFrame:GetTop()-CHAT_BAR_BUTTON_SIZE;
				ChatBarFrame:ClearAllPoints();
				ChatBarFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x, y);
			end
		end
	else
		if ChatBar_AlternateOrientation then
			ChatBarFrame:ClearAllPoints();
			ChatBarFrame:SetPoint("TOPRIGHT", "ChatFrame1", "TOPLEFT", 16, 46);
		else
			ChatBarFrame:ClearAllPoints();
			ChatBarFrame:SetPoint("BOTTOMLEFT", "ChatFrame1", "TOPLEFT", 0, 30);
		end
	end
end

function ChatBar_Toggle_AlternateButtonOrientation()
	ChatBar_AlternateOrientation = not ChatBar_AlternateOrientation;
	--ChatBar_UpdateOrientationPoint();
	ChatBar_UpdateAllButtonOrientation();
	ChatBar_UpdateButtons();
end

function ChatBar_Toggle_TextOrientation()
	ChatBar_TextOnButtonDisplay = not ChatBar_TextOnButtonDisplay;
	ChatBar_UpdateAllButtonOrientation();
end

function ChatBar_Toggle_ButtonFlashing()
	ChatBar_ButtonFlashing = not ChatBar_ButtonFlashing;
	ChatBar_UpdateButtonFlashing();
end

function ChatBar_Toggle_BarBorder()
	ChatBar_BarBorder = not ChatBar_BarBorder;
	ChatBar_UpdateBarBorder();
end

function ChatBar_Toggle_HideSpecialChannels()
	ChatBar_HideSpecialChannels = not ChatBar_HideSpecialChannels;
	ChatBar_UpdateButtons();
end

function ChatBar_Toggle_HideAllButtons()
	ChatBar_HideAllButtons = not ChatBar_HideAllButtons
	ChatBar_UpdateButtons();
end

function ChatBar_UpdateButtonText(button)
	if ChatBar_ButtonText then
		button.Text:Show();
	else
		button.Text:Hide();
	end
end

function ChatBar_Toggle_ButtonText()
	ChatBar_ButtonText = not ChatBar_ButtonText;
	ChatBar_ForAllButtons(ChatBar_UpdateButtonText);
end

function ChatBar_Toggle_TextChannelNumbers()
	ChatBar_TextChannelNumbers = not ChatBar_TextChannelNumbers;
	ChatBar_UpdateButtons();
end

function ChatBar_UpdateChannelBindings()
	if ChatBar_ChannelBindings then
		for i=1, MAX_WOW_CHAT_CHANNELS do
			_G["BINDING_NAME_CHATBAR_CHANNEL"..i] = format(BINDING_NAME_CHATBAR_CHANNEL_FORMAT, ChatBar_ChannelBindings[i] or i);
		end
	else 
		ChatBar_ChannelBindings = {}
	end
end

--------------------------------------------------
-- Helper Functions
--------------------------------------------------

function ChatBar_GetFirstWord(s)
	local firstWord, count = gsub(s, "%s.*", "")
	return firstWord;
end

local function print(text)
	local color = ChatTypeInfo["SYSTEM"]
	local frame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
	frame:AddMessage(text, color.r, color.g, color.b)
end

--------------------------------------------------
-- Reorder Channels
--------------------------------------------------

-- Standard Channel Order
STANDARD_CHANNEL_ORDER = {
	[CHATBAR_GENERAL] = 1,
	[CHATBAR_TRADE] = 2,
	[CHATBAR_LFG] = 3,
	[CHATBAR_LOCALDEFENSE] = 4,
	[CHATBAR_WORLDDEFENSE] = 5,
	[CHATBAR_GUILDRECRUITMENT] = 6,
};

BOGUS_CHANNELS = {
	"morneusgbyfyh",
	"akufbhfeuinjke",
	"lkushawdewui",
	"auwdbadwwho",
	"uawhbliuernb",
	"nvcuoiisnejfk",
	"cmewhumimr",
	"cliuchbwubine",
	"omepwucbawy",
	"yuiwbefmopou"
};

CHATBAR_CAPITAL_CITIES = {
	[CHATBAR_ORGRIMMAR] = 1,
	[CHATBAR_STORMWIND] = 1,
	[CHATBAR_IRONFORGE] = 1,
	[CHATBAR_DARNASSUS] = 1,
	[CHATBAR_UNDERCITY] = 1,
	[CHATBAR_THUNDERBLUFF] = 1,
	[CHATBAR_SHATRATH] = 1,
	[CHATBAR_EXODAR] = 1,
	[CHATBAR_SILVERMOON] = 1,
	[CHATBAR_DALARAN] = 1,
};

--
--	reorderChannels()
--		Stores current channels, Leaves all channels and then rejoins them in a standard ordering.
--		
--
function ChatBar_ReorderChannels()
	if UnitOnTaxi("player") then
		print(CHATBAR_REORDER_FLIGHT_FAIL);
		-- For some reason channels do not register join/leave in a reasonable amount of time while in transit.
		return;
	end
	
	local newChannelOrder = {};
	local openChannelIndex = 1;
	local currIdentifier, simpleName, inGlobalComm, _;
	
	--Get Channel List
	local list = {GetChannelList()};
	local currChannelList = {};
	for i=1, #list, 2 do
		tinsert(currChannelList, tonumber(list[i]), list[i+1]);
	end
	
	-- Find current standard channels: store and leave
	for index, chanName in pairs(currChannelList) do
		if type(chanName) == "string" then
			_, _, simpleName = strfind(chanName, "(%w+).*");
			if STANDARD_CHANNEL_ORDER[simpleName] then
				if ( simpleName == "GlobalComm" ) then 
					inGlobalComm = true;
				else
					newChannelOrder[STANDARD_CHANNEL_ORDER[simpleName]] = simpleName;
				end
				LeaveChannelByName(chanName);
				currChannelList[index] = nil;
			end
		end
	end
	
	-- Find current non-standard channels: store and leave
	for index, chanName in pairs(currChannelList) do
		if type(chanName) == "string" then
			while newChannelOrder[openChannelIndex] do
				openChannelIndex = openChannelIndex + 1;
			end
			newChannelOrder[openChannelIndex] = chanName;
			LeaveChannelByName(chanName);
			openChannelIndex = openChannelIndex + 1;
		end
	end
	
	if inGlobalComm then
		while newChannelOrder[openChannelIndex] do
			openChannelIndex = openChannelIndex + 1;
		end
		newChannelOrder[openChannelIndex] = "GlobalComm";
	end
	
	print(CHATBAR_REORDER_START);
	Chronos.schedule(.6, ChatBar_joinChannelsInOrder, newChannelOrder);
	Chronos.schedule(1.2, function() print(CHATBAR_REORDER_END); end );
	Chronos.schedule(2, ListChannels );
end

function ChatBar_joinChannelsInOrder(newChannelOrder)
	
	local inACity = CHATBAR_CAPITAL_CITIES[GetRealZoneText()];
	
	-- Join channels in new order
	for i=1, MAX_WOW_CHAT_CHANNELS do
		if newChannelOrder[i] then
			if ChannelManager_CustomChannelPasswords and ChannelManager_CustomChannelPasswords[newChannelOrder[i]] then
				JoinChannelByName(newChannelOrder[i], ChannelManager_CustomChannelPasswords[newChannelOrder[i]]);
			else
				JoinChannelByName(newChannelOrder[i]);
			end
		else
			-- Allow for hidden trade channel (Unfortunetly if you're not in a city and aren't in trade then numbers will be slightly off)
			if inACity or STANDARD_CHANNEL_ORDER[CHATBAR_TRADE] ~= i then
				JoinChannelByName(BOGUS_CHANNELS[i]);
			end
		end
	end
	Chronos.schedule(.6, ChatBar_leaveExtraChannels, newChannelOrder );
end

function ChatBar_leaveExtraChannels(newChannelOrder)
	
	for i, bogusName in ipairs(BOGUS_CHANNELS) do
		local channelNum, channelName = GetChannelName(bogusName);
		if channelName then
			LeaveChannelByName(channelNum);
		end
	end

end


