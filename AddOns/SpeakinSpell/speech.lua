-- Author      : RisM
-- Modified by : TehAkarf
-- Create Date : 6/28/2009 4:04:27 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("speech.lua")

-------------------------------------------------------------------------------
-- RANDOM SPEECHES - OnSpeechEvent, Speak or execute a command
-------------------------------------------------------------------------------


function SpeakinSpell:DoReportDetectedSpeechEvent( de, force, record )
	if force or SpeakinSpellSavedData.ShowSetupGuides or SpeakinSpell.DEBUG_MODE then
		-- displaylink is typically implemented in substitutions.lua
		-- but it may also be overriden in the event stub definition (see "yellow damage" events)
		local subs = self:CopyTable(de)
		--local displaylink = self:FormatSubs( "<displaylink>", de )
		local LuaCode = string.format("SpeakinSpell:OnClickEditEvent(\"%s\")", de.key)
		local ClickHereText = ""
		if de.EventTableEntry then
			ClickHereText = L["[Edit Speeches]"]
		else
			ClickHereText = L["[Setup New Event]"]
		end
		subs.clicktoedit = self:MakeClickHereLink(ClickHereText, LuaCode)
		subs.toggleguides = self:MakeClickHereLink(L["[/ss guides]"], "SpeakinSpell:ToggleSetupGuides()", SpeakinSpell.Colors.SPEAKINSPELL)
		-- {color}[/ss guides] [Edit Speeches] Event Name
		local msgformat = L["<toggleguides> <clicktoedit> <displaylink>"]
		--self:Print( msg ) --would include the [SpeakinSpell] prefix instead of [/ss guides]
		DEFAULT_CHAT_FRAME:AddMessage( self:FormatSubs( msgformat, subs ) )
	end

	if record then
		self:SaveInRecentList(de)
	end
end

function SpeakinSpell:OnSpeechEvent( DetectedEventStub )
	local funcname = "OnSpeechEvent"

	-- fill in the stub
	local DetectedEvent = self:CreateDetectedEvent( DetectedEventStub )
	local EventTable = self:GetActiveEventTable()
	
	--NOTE: it looks like I want to make a subroutine here and call it twice
	--		but the logic is actually slightly different between the ranked and rankless cases
	
	-- look for an event table entry for the ranked version
	local de = self:CopyTable( DetectedEvent )
	de.EventTableEntry = EventTable[ de.key ]
	
	self:DoReportDetectedSpeechEvent( de, false, true )

	if de.EventTableEntry then
		if self:AllowSpeakForSpell( de ) then
			self:SpeakForSpell( de )
		end
	else
		-- record a new event for this ranked key
		--self:DebugMsg(funcname, "no EventTableEntry for key:"..tostring(de.key))
		self:RecordNewEvent( de ) -- this updates the Create New window as necessary			
	end
end



function SpeakinSpell:OnRecursiveEventDetected( text, DetectedEventStub, ParentDetectedEvent )
	local funcname = "OnRecursiveEventDetected"

	-- fill in the stub
	local de = self:CreateDetectedEvent( DetectedEventStub )
	
	-- set a parent link
	de.EventTableEntry = self:GetActiveEventTable()[ de.key ]
	
	self:DoReportDetectedSpeechEvent( de, false, true )

	if not de.EventTableEntry then
		self:ErrorMsg(funcname, "no event settings for "..tostring(text))
		return
	end

	if not self:AllowSpeakForSpell( de ) then
		return
	end
	
	local pop = true
	if not self.RuntimeData.ParentDetectedEvent then
		self.RuntimeData.ParentDetectedEvent = ParentDetectedEvent
	else
		-- add the new cascading event info the old one, in case it defines anything new
		self:ValidateObject( self.RuntimeData.ParentDetectedEvent, ParentDetectedEvent )
		pop = false
	end

	self:SpeakForSpell( de )

	if pop then
		self.RuntimeData.ParentDetectedEvent = nil	
	end
end


function SpeakinSpell:GetChatChannelForSpell(EventTableEntry)
	local funcname = "GetChatChannelForSpell"
	
	local key = self:GetScenarioKey()
	local channel = EventTableEntry.Channels[key]
	
	-- if the player wants to speak in the RAID_WARNING channel, 
	-- but doesn't have permission (not the leader or assist)
	-- then fall back to the RAID channel instead, so we say something at all
	-- instead of triggering an error message in the chat
	-- NOTE: as of WoW patch 3.3.0 you must be in a raid to use raid warnings
	--		IsPartyLeader doesn't count, and RAID may not be the correct fallback if you're not in a raid
	-- WoW 5.0.4: IsPartyLeader() has been replaced by UnitIsGroupLeader("player")
	-- TODO: have /rw restrictions changed in 5.0.4?
	if (channel == "RAID_WARNING") then
		-- raid warning isn't going to work, so pick raid or party
		if IsInRaid() then
			if ( UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") ) then
				-- raid warnings should work
				return channel
			else
				self:DebugMsg(funcname, "You don't have permission to say Raid Warnings right now - using RAID chat instead")
				return "RAID"
			end
		else
			self:DebugMsg(funcname, "You are not in a raid - using PARTY chat instead of RAID_WARNING")
			return "PARTY"
		end
	end
	
	return channel
end


-- returns a language that is usable in SendChatMessage
function SpeakinSpell:GetChatLanguageForSpell(EventTableEntry)
	local funcname = "GetChatLanguageForSpell"
	
	-- [X] Always Use Common
	-- or Common is the only known language
	local NumLanguages = GetNumLanguages() -- doesn't work during first-time load, so we need to be safe about it
	if not NumLanguages then
		NumLanguages = 1
	end
	if SpeakinSpellSavedData.AlwaysUseCommon or (NumLanguages < 2) then
		--self:DebugMsg(funcname, "always use common")
		return nil --more reliable than GetDefaultLanguage("player") for our purposes here
	end
	
	--NOTE: a possible data issue here when sharing between toons of different races
	--		imagine you setup an event while playing your Dwarf, and selected language=Dwarvish
	--		but now you're playing on your Undead where "you don't know that language" errors would happen
	--		that is why the RPLanguage stores a custom value ("RANDOM", "COMMON", or "RACIAL")
	--		instead of the actual language name ("Common", "Orcish", "Foresaken", etc)

	--NOTE: SendChatMessage needs the locale-independant languageIndex from these APIs:
	--		languageName, languageIndex = GetLanguageByIndex(index)
	--      languageName, languageIndex = SpeakinSpell:GetRacialLanguage() too
	
	-- NOTE: GetLanguageByIndex returns the name of the language in String format - TehAkarf
	if "RANDOM" == EventTableEntry.RPLanguage then
		-- Player Selected "Random"
		local list = {}
		for	i=1,NumLanguages do
			-- i and languageIndex are different
			-- i is an index to this toon's known languages: 1 to GetNumLanguages()
			-- languageIndex is a global index: 1 to the total available languages in the game right now
			-- for example a night elf will see i=1, languageIndex=7, languageName=Darnassian
			local languageName, languageIndex = GetLanguageByIndex(i)
			self:DebugMsg(funcname, string.format(L["i=%d, languageName=%s, languageIndex=%d"], i, languageName, languageIndex) )
			list[i] = languageIndex
		end
		local Random = math.random(1,NumLanguages)
		self:DebugMsg(funcname, string.format(L["NumLanguages=%d, selected Random=%d, return languageIndex=%d"], NumLanguages, Random, list[Random]) )
		return list[Random]
	elseif "COMMON" == EventTableEntry.RPLanguage then
		-- Common
		return nil
	elseif "RACIAL" == EventTableEntry.RPLanguage then
		-- use the racial language
		local languageName, languageIndex = SpeakinSpell:GetRacialLanguage()
		return languageIndex
	elseif "CLASS" == EventTableEntry.RPLanguage then
		-- Use the class's language (i.e. Demon Hunter)
		local languageName, languageIndex = SpeakinSpell:GetClassLanguage()
		return languageIndex
	else
		-- invalid option, assume common
		-- TODOFUTURE: add SpeakinSpell language filters like "Pirate" and "Drunk" (and treat Random as one of those?)
		--		if we're speakin in pirate, then this function should return GetDefaultLanguage("player")
		return nil
	end
end


-- return true if this is a slash command
-- return false if this is other default text
function SpeakinSpell:ProcessChatSlashCommand(text, DetectedEvent)
	local funcname = "ProcessChatSlashCommand"

	if ( strsub(text, 1, 1) ~= "/" ) then
		--self:DebugMsg(funcname, "not a slash command:"..tostring(text))
		return false
	end
	
	-- issue a warning if this a secure command like /cast
	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";
	if IsSecureCmd(command) then
		local subs = {
			text = text
		}
		self:Print( self:FormatSubs(L["WARNING: can't execute protected command: <text>"],subs) )
		return true
	end
	
	-- if this is a recursive call into a slash command, it needs some special handling
	-- do it with internal calls instead of passing through the global chat parser and back again
	if self:ProcessRecursiveUserMacro(text, DetectedEvent) then
		self:DebugMsg(funcname, "processed as macro:"..tostring(text) )
		return true
	end
	
	-- OK, run the command (see utils)
	SpeakinSpell:RunSlashCommand(text)
	return true
end



function SpeakinSpell:SelfRaidWarn( text )
	-- show the line as a raid warning style popup that only I can see
	-- using the RaidWarningFrame makes this use the same font size and position
	-- the same as a real raid warning, except for the color, which is user-defined saved data
	local Color = SpeakinSpellSavedData.Colors.Channels["SELF RAID WARNING CHANNEL"]
	PlaySound("RaidWarning") --RaidNotice_AddMessage doesn't play sound
	RaidNotice_AddMessage(RaidWarningFrame, text, Color)
end


function SpeakinSpell:SelfChat_SpeakinSpellChannel( text )
	if not SpeakinSpell.Colors.Channels then
		-- LoadChatColorCodes has to be done some time after OnVariablesLoaded for all addons
		-- and this could be the first time we needed it
		self:LoadChatColorCodes()
	end
	local msg = tostring(SpeakinSpell.Colors.Channels["SPEAKINSPELL CHANNEL"]).."SpeakinSpell|r: " .. tostring(text)
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end


-- SelfChat_BossWhisper
-- mimic boss whispers
-- text = "[voice] whispers: something"
-- this function does not prefix anything
-- TODOFUTURE: distribute to all appropriate chat frames per player's filter settings and custom chat frames
function SpeakinSpell:SelfChat_BossWhisper( text )
	local Color = ChatTypeInfo["RAID_BOSS_WHISPER"]
	DEFAULT_CHAT_FRAME:AddMessage( text, Color.r, Color.g, Color.b, Color.id )
end


-- "[Mysterious Voice] whispers: " .. text
-- TODOFUTURE: distribute to all MONSTER_WHISPER chat frames per player's filter settings and custom chat frames
function SpeakinSpell:SelfChat_MysteriousVoice( text )
	--local MONSTER_WHISPER = ChatTypeInfo["MONSTER_WHISPER"]
	if not SpeakinSpell.Colors.Channels then
		-- LoadChatColorCodes has to be done some time after OnVariablesLoaded for all addons
		-- and this could be the first time we needed it
		self:LoadChatColorCodes()
	end
	local Color = SpeakinSpellSavedData.Colors.Channels["MYSTERIOUS VOICE"]
	local msg = L["[Mysterious Voice] whispers: "] .. tostring(text)
	DEFAULT_CHAT_FRAME:AddMessage( msg, Color.r, Color.g, Color.b --[[, MONSTER_WHISPER.id--]] )
end


-- Comm Traffic channel
function SpeakinSpell:SelfChat_CommTraffic( COMM_TRAFFIC_rxtx, text )
	if not SpeakinSpell.Colors.Channels then
		-- LoadChatColorCodes has to be done some time after OnVariablesLoaded for all addons
		-- and this could be the first time we needed it
		self:LoadChatColorCodes()
	end
	local Color = SpeakinSpellSavedData.Colors.Channels[COMM_TRAFFIC_rxtx]
	local rxtx = "->> " -- outbound
	if COMM_TRAFFIC_rxtx == "COMM TRAFFIC RX" then
		rxtx = "<<- " -- inbound
	end
	local msg = L["SS Network "] .. rxtx .. tostring(text)
	DEFAULT_CHAT_FRAME:AddMessage( msg, Color.r, Color.g, Color.b --[[, id --]] )
end



-- line is "makes strange gestures"
-- return value wants to be /s "* <player> makes strange gestures *"
-- instead of /e "makes strange gestures"
-- used for whispering emotes
function SpeakinSpell:EmoteToSay( line )
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local subs = {
		emotes = line,
		player = myname,
	}
	return self:FormatSubs( L["* <player> <emotes> *"], subs ) --TODOFUTURE: make this string format user-configurable
end


-- does not format subs
-- SendChatMessage("msg" 
--		[,"chatType=say,party,whisper,etc" 
--		[,"language=nil,common,dwarvish,etc" 
--		[,"channel means whisper target name or channel number 1,2,3"]]]);
function SpeakinSpell:SayOneLine(line, channel, Language, EnableWhisperTarget, DetectedEvent)
	-- never print empty lines
	if (not line) or (line == "") then
		return
	end
	
	-- if this message is a slash command, send it through an editBox function to parse and execute the command
	--NOTE: a specified slash command overrides the default channel and whisper features below
	--		it doesn't make sense to combine them
	if self:ProcessChatSlashCommand(line, DetectedEvent) then
		return
	end
	
	-- define custom channel functions
	local ChannelFuncs = {
		["SPEAKINSPELL CHANNEL"]	= function(line)	self:SelfChat_SpeakinSpellChannel(line)	end,
		["RAID_BOSS_WHISPER"]		= function(line)	self:SelfChat_BossWhisper(line)			end,
		["MYSTERIOUS VOICE"]		= function(line)	self:SelfChat_MysteriousVoice(line)		end,
		["COMM TRAFFIC RX"]			= function(line)	self:SelfChat_CommTraffic(channel, line)end,
		["COMM TRAFFIC TX"]			= function(line)	self:SelfChat_CommTraffic(channel, line)end,
		["SELF RAID WARNING CHANNEL"]= function(line)	self:SelfRaidWarn(line)					end,
	}
		
	-- say the message to the chat, if applicable
	if channel then
		-- check for proprietary SS-created channels
		local Func = ChannelFuncs[ channel ]
		if Func then
			Func( line )
		else
			-- all others go directly through Blizzard's SendChatMessage
			--TODOFUTURE: should this check for "|" for invalid escape sequences to prevent LUA errors? or allow color changes and stuff?
			SendChatMessage(line, channel, Language);
		end
	end
	
	-- send the message to a whisper to the target, if applicable
	if EnableWhisperTarget then
		-- NOTE: always use Common(nil) for the language just to ensure the person you whisper can read what you say
		-- NOTE: for whispered emotes, reformat the whisper to sound like the way /e works
		if channel == "EMOTE" then
			line = self:EmoteToSay(line)
		end
		SendChatMessage(line, "WHISPER", nil, DetectedEvent.target);
	end
end


-- expand recursive /ss macro calls
-- so that we have an even random distribution across all shared sub-lists
--
-- for multi-line "/ss macro A<newline>/ss macro B" GetETEForSSMacro will return (nil, false)
--		so it won't be treated as a macro, and will be preserved as-is
--
-- for single-line undefined macros like "/ss macro <targetrace>" that expands to an undefined "/ss macro dwarf"
--		we'll remove it from the list so you don't get a prompt to create it, and instead pick another speech
--
function SpeakinSpell:ExpandSSMacros( ExpandedMessages, EventTableEntry, de )
	if not EventTableEntry.ExpandMacros then
		return
	end
	for _,msg in pairs( EventTableEntry.Messages ) do
		-- NOTE: EventTableEntry.DetectedEvent is just the stub - de has the current target info in it
		local ete, ismacro = self:GetETEForSSMacro(msg, de)
		if ismacro then
			if ete then
				-- we found it
				if ete.ExpandMacros then
					-- EventTableEntry calls "/ss macro foo" (ete) which calls "/ss macro bar" (ete.Messages)
					-- and "/ss macro foo" wants "/ss macro bar" to be expanded
					self:ExpandSSMacros( ExpandedMessages, ete, de )
				else
					-- EventTableEntry calls "/ss macro foo" (ete)
					-- and we stop our recursion here, so just copy ete.Messages
					self:AddStringArray(ExpandedMessages, ete.Messages)
				end
			else
				-- exclude undefined macros from the ExpandedMessages - do nothing here
			end
		else
			-- not a macro, so keep it as-is
			tinsert( ExpandedMessages, msg )
		end
	end
end


-- replace a macro call with the macro's speech list
-- NOTE: expand it out in-place instead of appending to the end
--		the recursive ExpandSSMacros function above is complete/automatic
--		this function is meant for manual editing in the GUI
function SpeakinSpell:ExpandOneSSMacro( Messages, index, de )
	-- find the event table entry for this message
	local msg = Messages[ index ]
	if not msg then
		self:ErrorMsg(funcname, "msg is nil")
		return
	end
	local ete = SpeakinSpell:GetETEForSSMacro(msg, de)
	if not ete then
		self:ErrorMsg(funcname, "ete is nil")
		return
	end

	-- capture everything up to the index, but not the index
	NewMessages = {}
	for i = 1, index-1 do
		tinsert( NewMessages, Messages[i] ) --adds to the end of NewMessages at highest unused index
	end
	-- NewMessages[ index ] = nil
	
	-- add the /ss macro command speeches
	for _,msg in pairs( ete.Messages ) do
		tinsert( NewMessages, msg )
	end
	
	-- add the rest of the original array
	for i = index+1, #Messages do
		tinsert( NewMessages, Messages[i] ) --adds to the end of NewMessages at highest unused index
	end
	
	-- remove duplicates while we go out
	return self:StringArray_Compress( NewMessages )
end


function SpeakinSpell:GetRandomMessage( DetectedEvent )
	-- expand /ss macro calls, if enabled
	-- so that we have an even random distribution across all shared sub-lists
	-- ignoring sub-options except for the option whether to expand - not automatically recursive
	local ExpandedList = DetectedEvent.EventTableEntry.Messages
	if DetectedEvent.EventTableEntry.ExpandMacros then
		ExpandedList = {} --we don't want to corrupt the ete.Messages, and ExpandSSMacros will re-add everything applicable from DetectedEvent.EventTableEntry.Messages
		self:ExpandSSMacros( ExpandedList, DetectedEvent.EventTableEntry, DetectedEvent )
		ExpandedList = self:StringArray_Compress( ExpandedList )
	end
	return self:GetRandomTableEntry( ExpandedList, self:GetLastMessage( DetectedEvent ) )
end


function SpeakinSpell:SayMultiLineWithSubs( msg, channel, Language, EnableWhisperTarget, DetectedEvent )
	-- format substitutions (including <newline>)
	msg = self:FormatSubs( msg, DetectedEvent )
	
	-- break up the message into separate lines, if applicable
	local lines = { strsplit("\n",msg) }

	for _,line in ipairs(lines) do
		-- process substitution variables
		self:SayOneLine(line, channel, Language, EnableWhisperTarget, DetectedEvent)
	end
end


function SpeakinSpell:SpeakForSpell(DetectedEvent)
	local funcname = "SpeakForSpell"
	
	-- determine which channel we will speak in
	local channel = self:GetChatChannelForSpell(DetectedEvent.EventTableEntry)
   
	--TODOFUTURE: make it an option to whisper yourself - but be wary of the auto self-cast logic
	local EnableWhisperTarget = DetectedEvent.EventTableEntry.WhisperTarget and DetectedEvent.target and (DetectedEvent.target ~= "") and (DetectedEvent.target ~= "Unknown") and (not SpeakinSpell:NameIsMe(DetectedEvent.target)) and UnitIsFriend("player",DetectedEvent.target)

	if not channel and not EnableWhisperTarget then
		-- this spell's speeches have no target for the current situation
		-- NOTE: this rule applies even if a slash command override is present in the randomly selected message text
		self:ShowWhyNot( DetectedEvent, L["the selected chat channel is \"Silent\" while in <Scenario>"] )
		return
	end

	-- check for instance channel override
	--self:DebugMsg( funcname, "CheckForInstance="..tostring(self:CheckForInstance()) )
	--self:DebugMsg( funcname, "IsInGroup(LE_PARTY_CATEGORY_INSTANCE)="..tostring(IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) )
	if DetectedEvent.EventTableEntry.InstanceChannel and -- user option is enabled
		self:CheckForInstance() and -- currently in an instance
		IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and -- "INSTANCE_CHAT" only works in dungeon finder groups
		("PARTY" == channel or "RAID" == channel) then -- selected channel is equivalent
		channel = "INSTANCE_CHAT"
	end
   
	-- select a random speech
	local msg = self:GetRandomMessage( DetectedEvent )
	if not msg then
		self:ShowWhyNot( DetectedEvent, L["no speeches are defined"] )
		return
	end
	
	-- determine the language: Common vs. Dwarvish, etc.
	local Language = self:GetChatLanguageForSpell( DetectedEvent.EventTableEntry )

	-- record the time when we spoke for this spell, along with the last target, and last message spoken
	-- to support duplicate prevent, announcement limits, and cooldowns
	-- NOTE: record the unprocessed message text, so that changing the value of substitution variables
	--		does not make us think it's a new random message selection
	self:SaveAnnouncementHistory( DetectedEvent, msg )
	
	self:SayMultiLineWithSubs( msg, channel, Language, EnableWhisperTarget, DetectedEvent )
end

