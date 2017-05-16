-- Author      : RisM
-- Modified by : TehAkarf
-- Create Date : 6/28/2009 3:54:18 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("utils.lua")

-------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
-------------------------------------------------------------------------------


function SpeakinSpell:Keyify( s )
	return string.upper( string.gsub( tostring(s), " ", "_" ) )
end

--TODOFUTURE: consider using this function to make code more readable, but slower
function SpeakinSpell:RemoveEmptyTables( t )
	for key,value in pairs( t ) do
		if type(value) == "table" then
			self:RemoveEmptyTables( value )
			if self:IsTableEmpty( value ) then
				t[key] = nil
			end
		end
	end
end


-- Import new contents from Source into existing table Dest
function SpeakinSpell:AddTable(Dest, Source)
	-- create the destination if it doesn't exist
	if Dest == nil then
		Dest = {}
	end
	assert( type(Dest) == "table" )
	
	-- if there's no source, then there's nothing to add
	if Source == nil then
		-- nothing to add
		return Dest
	end
	
	-- add the contents of Source, one item at a time
	for k,v in pairs(Source) do
		-- dig into embedded tables to add those too, not just create references
		if type(v) == "table" then
			-- NOTE: safety checks above will ensure we create Dest[k] if necessary
			Dest[k] = self:AddTable(Dest[k], v)
		else
			Dest[k] = v
		end
	end
	
	return Dest
end


-- create a deep copy of the table and return it
function SpeakinSpell:CopyTable(SourceTable)
	-- adding SourceTable to a new empty table will create a copy
	return self:AddTable(nil, SourceTable)
end

-- add an array of strings
function SpeakinSpell:AddStringArray(Dest, Source)
	for _,s in ipairs(Source) do
		tinsert( Dest, s )
	end
end



-- make sure there are no empty strings or empty array indices in the string list
-- also remove duplicates
function SpeakinSpell:StringArray_Compress( List )
	-- the easiest thing to do is make a new list
	-- build a reverse lookup table of the target array first, to search for duplicates
	-- TODOFUTURE: could do this a faster way i'm sure
	local NewList = {}
	local UniqueCheck = {}
	for i,s in pairs( List ) do
		if (s ~= "") and (not UniqueCheck[s]) then
			local ret = tinsert( NewList, s )
			UniqueCheck[ s ] = true
		end
	end
	return NewList
end


function SpeakinSpell:IsTableEmpty( t )
	if not t then
		return true
	end
	for _,_ in pairs(t) do
		return false
	end
	return true
end


function SpeakinSpell:SizeTable( t )
	if not t then
		return 0
	end
	
	local size = 0
	for _,_ in pairs(t) do
		size = size + 1
	end
	return size
end


function SpeakinSpell:GetGuildName()
	local guildName = GetGuildInfo("player")
	if guildName then
		return guildName
	else
		return L["Your friends"]
	end
end


function SpeakinSpell:GetPlayerFullTitleName()
	local title = GetTitleName( GetCurrentTitle() )
	-- if we don't have a title, then self:StartsWith will error on the nil value
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	if not title then
		return myname
	end
	-- we have a title, so decide if it comes first or last
	-- blizzard does this by setting a space at the beginning or end for easier string concatenation
	if self:StartsWith(title, " ") then
		return myname..tostring(title)
	else
		return title..myname
	end
end


-- NameWithRealm is either "Name" or "Name-Realm"
-- return "Name" for use in natural speech
function SpeakinSpell:PlayerNameNoRealm( NameWithRealm )
--TODONOW: PlayerNameNoRealm causes a bug on NPC names with hyphens in them
    -- ignore empty input
    if NameWithRealm == nil or NameWithRealm == "" then
        return NameWithRealm
    end
    
	local index = string.find( NameWithRealm, "-" )
	if (index and (index >= 0)) then
		-- found the delimiter between player name and realm name
		return string.sub( NameWithRealm, 1, index-1 )
	else
		-- looks like the realm name was not included
		return NameWithRealm
	end
end


-- InputName is either "Name" or "Name-Realm"
-- Return true if this is referring to the player
-- Return false if this is someone else
-- for determining if an event applies to myself or not
function SpeakinSpell:NameIsMe( InputName )
	--NOTE: myrealm result from UnitName("player") is always nil
	local player, myrealm = UnitName("player")
	local realm = GetRealmName()
		
	if InputName == player then
		return true
	end
	if InputName == player.."-"..realm then
		return true
	end
	
	return false
end

function SpeakinSpell:GetDefaultTarget(ShowDebugMsg)
	-- try the currently selected target
	local target, targetrealm = UnitName("target")
	if target then
		if ShowDebugMsg then self:DebugMsg(nil,"<target> is unknown, using <selected>:"..tostring(target)) end
		return target
	end
	
	-- nobody is selected, try focus
	target, targetrealm = UnitName("focus")
	if target then
		if ShowDebugMsg then self:DebugMsg(nil,"<target> is unknown, using <focus>:"..tostring(target)) end
		return target
	end
	
	-- nobody on focus, try mouseover
	target, targetrealm = UnitName("mouseover")
	if target then
		if ShowDebugMsg then self:DebugMsg(nil,"<target> is unknown, using <mouseover>:"..tostring(target)) end
		return target
	end
	
	-- assume self-cast ability
	-- NO this doesn't work out very well in practice (especially battle cries / entering combat)
	--NOTE: myrealm result from UnitName("player") is always nil
--	target, myrealm = UnitName("player")
--	if ShowDebugMsg then self:DebugMsg(nil,"<target> is unknown, using <player>:"..tostring(target)) end
	
	return target
end


--FormatDisplayName
-- create a display name for an event, using options
-- typonly = a type filter in effect, or nil
--		if a type filter is in effect, don't include the type in the display name
--		if a type filter is NOT in effect, include the event type in the display name
--
local g_DefaultFormat = {
	typefilter = "*ALL", 
	HighlightFilterText = false, 
	BaseColor = "|r",
}
function SpeakinSpell:FormatDisplayName( de, DisplayNameFormat )
	local funcname = "FormatDisplayName"
	
	local Format = self:CopyTable( DisplayNameFormat )
	self:ValidateObject( Format, g_DefaultFormat )

	local subs = self:CopyTable(de)
	subs.basecolor = Format.BaseColor

	if Format.HighlightFilterText then
		subs.colormatchedname = self:ColorFilterText( de.name, Format.BaseColor )
	else
		subs.colormatchedname = (Format.BaseColor)..tostring(de.name)
	end

	if Format.typefilter == "*ALL" then -- show the type in the display name
		return self:FormatSubs(L["<basecolor><eventtypeprefix><colormatchedname>"],subs)
	end

	-- when showing macros only, format so we show...
	-- when I type: /ss macro
	-- foo, bar, battlecry, whatever
	if (Format.typefilter == "MACRO") and (de.type == "MACRO") then
		if self:StartsWith( string.lower( de.name ), strlower(MACRO) ) then
			subs.colormatchedname = string.sub( de.name, string.len( strlower(MACRO) )+1 )
			if Format.HighlightFilterText then
				subs.colormatchedname = self:ColorFilterText( subs.colormatchedname, Format.BaseColor )
			end
			return self:FormatSubs(L["<basecolor><colormatchedname>"],subs)
		end
	end
	
	return subs.colormatchedname
end


-- from UnitID info on wowwiki:
-- player name 
--    As returned by UnitName, GetGuildRosterInfo, GetFriendInfo, COMBAT LOG EVENT, etc. 
--	This must be spelled exactly AND WILL BE INVALID IF THE NAMED PLAYER IS NOT A PART OF YOUR PARTY OR RAID. 
--	As with all other UnitIDs, it is not case sensitive. 
--	This creates a problem for getting race/class info of players outside the party
--	so we try to get a universally-allowed unitid like target if we have them selected
--	Try all of these UnitNames until we get a match, then return it
--	this will be a usable global name for UnitRace or UnitClass (or similar APIs?)

local NameToUnitIDSearchList = {
"target",    --verified works for UnitRace/UnitClass in 3.3.5
"focus",     --verified works for UnitRace/UnitClass in 3.3.5
"mouseover", --verified works for UnitRace/UnitClass in 3.3.5
-- TEST: the rest are untested for UnitRace/UnitClass
-- "arenaN" Opposing arena member with index N (1,2,3,4 or 5). 
"arena1",
"arena2",
"arena3",
"arena4",
"arena5",
-- "bossN" The active bosses of the current encounter if available N (1,2,3 or 4). (Added in 3.3.0) 
"boss1",
"boss2",
"boss3",
"boss4",
}
--TODOLATER: NameToUnitID is called on-demand... set de.unitid at a better time so we don't repeat this search
function SpeakinSpell:NameToUnitID( name )
	-- similar to GetDefaultTarget but to get a valid unitId to query race/class for people outside our party or raid
	-- which is not allowed by name, but is allowed if they're your target, focus, or mouseover
	for i,unitId in ipairs(NameToUnitIDSearchList) do
		if unitid == name or UnitName(unitId) == name then
			self:DebugMsg("NameToUnitID", "NameToUnitID:"..tostring(unitId))
			return unitId
		end
	end
	
	return nil
end


function SpeakinSpell:TitleCase(s)
	local first = string.sub(s,1,1)
	local rest = string.sub(s,2,-1)

	first = string.upper(first)
	
	rest = string.gsub(rest, " %a",
		function(match) 
			return string.upper(match)
		end
	)
	
	local result = tostring(first)..tostring(rest)
	return result
end


function SpeakinSpell:StartsWith(s, prefix)
	start = string.sub(s, 1, string.len(prefix))
	return (start == prefix)
end


function SpeakinSpell:EndsWith(s, suffix)
	strend = string.sub(s, -1 * string.len(suffix))
	return (strend == suffix)
end


function SpeakinSpell:ContainsWholeWord(s, word)
	-- force lowercase for case-insensitive matching
	-- and tostring() for safety against lua errors
	local search = strlower( tostring(s) )
	local wordlower = strlower( tostring(word) )
	
	-- use gsub to remove all whole words which are not 'word'
	-- "(%a+)" matches all whole words
	-- TODOFUTURE: this whole function can probably be achieved with a more powerful regular expression 
	--		passed to string.match, containing the word we're looking for, and some regular expression syntax
	--		it would probably run faster
	local found = string.gsub( search, "(%a+)", function(match)
		if match == wordlower then
			return wordlower
		end
		return ""
	end)
	
	-- 'found' now contains only whole words which match 'word'
	-- and white space
	local ndx = string.find(found, wordlower)
	if (ndx ~= nil) and (ndx >= 0) then
		return true
	else
		return false
	end
end


function SpeakinSpell:IsInWorldPVPBattle()
	--only applies to active battles
	
	-- we only care if a battle is in progress
	-- if we're in WG for VOA PVE and the battle is over, switch to raid settings
	-- same for Tol Barad, and as of WoW 4.0.6, they share the same API: GetWorldPVPAreaInfo
	local zoneID = 1
	for zoneID = 1, GetNumWorldPVPAreas() do
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(zoneID)
		if isActive and GetZoneText() == localizedName then
			return true
		end
	end
	-- either none of the battles are in progress, or you aren't there
	return false
end


function SpeakinSpell:GetRandomTableEntry( t, last )
	if not t then return nil end
	
	local max = #(t)
	if not (max >= 1) then return nil end
	
	local n = math.random(1, max);
	local sel = t[n]
	
	-- avoid repeating the same message we used last time
	-- unless there's only one in the list
	-- or we don't have a 'last'
	if last and (max > 1) then
		while sel == last do
			n = math.random(1, max);
			sel = t[n]
		end
	end
	
	return sel
end

 -- Note Added this fuction to just do a boolen check for if we are in an 
 -- instance, usefull for when we want to sup one group type for another because 
 -- while your in a party, raid, or BG  you can also be in an instance 

function SpeakinSpell:CheckForInstance()
	local isInstance, instanceType = IsInInstance()
	return isInstance
end 

function SpeakinSpell:GetScenarioKey()
	local funcname = "GetScenarioKey"
	-- NOTE: the EventTableEntry.Channels table stores channel names that are compatible with SendChatMessage
	--	see also CurrentMessagesGUI_OnChannelSelect
	--TODONOW: Ashran new BG in WoW 6.x is reportedly not detected as a BG
	local isInstance, zoneType = IsInInstance()
	if zoneType == "arena" then --(IsActiveBattlefieldArena()) is unreliable during prep time
		return "Arena"
	elseif zoneType == "pvp" then --(GetNumBattlefieldScores() > 0) is unreliable during prep time
		return "BG"
	elseif (self:IsInWorldPVPBattle()) then --only applies to active battles
		-- NOTE: raid warnings not enabled for WG battles
		-- Cata: this same scenario key code is now used for Tol Barad
		return "WG"
	elseif IsInRaid() then
		-- override Raid with Leader if applicable
		if UnitIsGroupLeader("player") then
			return "RaidLeader"
		elseif UnitIsGroupAssistant("player") then
			return "RaidOfficer"
		else
			return "Raid"
		end
	elseif IsInGroup() then
		-- override Party with Leader if applicable
		if UnitIsGroupLeader("player") then
			return "PartyLeader"
		else
			return "Party"
		end
	else -- solo
		return "Solo"
	end
end


-- languageName, languageIndex = GetLanguageByIndex(index)
-- GetRacialLanguage also returns languageName, languageIndex
-- With SendChatMessage, use the locale-independant languageIndex
function SpeakinSpell:GetRacialLanguage()
	-- the languages are ordered differently for every race
	-- return GetLanguageByIndex( 2 ) -- doesn't work as simply as that
	local funcname = "GetRacialLanguage"
	
	-- following is Harmoniii's logic table for finding the racial language
	-- adapted to remove redundant code
	local NumLanguages = GetNumLanguages()
	local Common = GetDefaultLanguage("player")
	local Race = select(2, UnitRace ("player"))
	local Faction = UnitFactionGroup("player")
	local i = 0 -- find this index passed to GetLanguageByIndex at the end
	if (NumLanguages == 2) then   
		if Faction == "Horde" then
			i = 2
		else -- Alliance
			if (GetLanguageByIndex(2) == Common) then  
				-- alliance elves and dwarves.
				i = 1
			else
				-- Gnomish, draenei and pandaren work like horde
				i = 2
			end
		end
	elseif (NumLanguages == 3) then -- Demon Hunter
		if Faction == "Horde" then -- Horde
			i = 3
		else 
			i = 1
		end
	elseif (NumLanguages == 5) then -- alliance non-pandaren mage
		if Race == "NightElf" then
			i = 1
		elseif Race == "Dwarf" then
			i = 2
		elseif Race == "Gnome" then
			i = 4
		elseif Race == "Draenei" then
			i = 5
		else -- impossible, only if forgot something
			self:DebugMsg(funcname, string.format("Unexpected combination of NumLanguages=%d and Race=%s", NumLanguages, Race))
			i = 3 
		end
	elseif (NumLanguages == 6) then   
		if Faction == "Horde" then -- Horde non-pandaren mages
			if Race == "Tauren" then
				i = 2
			elseif Race == "BloodElf" then
				i = 3
			elseif Race == "Troll" then
				i = 4
			elseif Race == "Scourge" then
				i = 5
			elseif Race == "Goblin" then
				i = 6
			else -- impossible, only if forgot something
				self:DebugMsg(funcname, string.format("Unexpected combination of NumLanguages=%d and Race=%s", NumLanguages, Race))
				i = 3
			end
		else -- Alliance pandaren mage
			if Race == "NightElf" then
				i = 1
			elseif Race == "Dwarf" then
				i = 2
			elseif Race == "Gnome" then
				i = 4
			elseif Race == "Draenei" then
				i = 5
			elseif Race == "Pandaren" then
				i = 6
			else -- impossible, only if forgot something
				self:DebugMsg(funcname, string.format("Unexpected combination of NumLanguages=%d and Race=%s", NumLanguages, Race))
				i = 3
			end
		end
	elseif (NumLanguages == 7) then  -- horde pandaren mage
		i = 7
	else
		-- unexpected scenario should not occur until Blizzard changes something
		self:DebugMsg(funcname, string.format("Unexpected combination of NumLanguages=%d and Race=%s", NumLanguages, Race))
		i = 1
	end

	-- i and languageIndex are different
	-- i is an index to this toon's known languages: 1 to GetNumLanguages()
	-- languageIndex is a global index: 1 to the total available languages in the game right now
	-- for example a night elf will have i=1, languageIndex=7, languageName=Darnassian
	local languageName, languageIndex = GetLanguageByIndex(i)
	self:DebugMsg(funcname, string.format("i=%d, languageIndex=%d, languageName=%s", i, languageIndex, languageName))
	return languageName, languageIndex 
end

-- TehAkarf
-- Gets the language of the class, if it has one. Based on the GetRacialLanguage function.
-- Returns languageName, languageIndex
function SpeakinSpell:GetClassLanguage()
	-- return GetLanguageByIndex( 2 )
	-- When the index is equal to 2, it returns the class language for the Demon Hunter. 
	-- Other class's that use a speical language may change this in the future.
	
	-- check the player's class in order to get the correct class language.
	local i = 0
	if UnitClass("player") == "Demon Hunter" then
		i = 2
	else
		-- if the player doesn't have a class language, fall back to common
		i = 1
	end
	
	-- i and languageIndex are different
	-- i is an index to this toon's known languages: 1 to GetNumLanguages()
	-- languageIndex is a global index: 1 to the total available languages in the game right now
	local languageName, languageIndex = GetLanguageByIndex(i)
	self:DebugMsg("GetClassLanguage", string.format("i=%d, languageIndex=%d, languageName=%s", i, languageIndex, languageName))
	return languageName, languageIndex
end

-- if any key is missing from obj, it will be imported from DefaultObject
function SpeakinSpell:ValidateObject( obj, DefaultObject )
	if not DefaultObject then -- i'd prefer this didn't happen, but let it pass silently
		return
	end
	for key,val in pairs(DefaultObject) do
		if obj[key] == nil then -- NOTE: don't replace "false" values
			if type( DefaultObject[key] ) == "table" then
				obj[key] = self:CopyTable(DefaultObject[key])
			else
				obj[key] = DefaultObject[key]
			end
		--no, this would bring in whole lists of things like messages
		--elseif type( DefaultObject[key] ) == "table" then
		--	self:ValidateObject( obj[key], DefaultObject[key] )
		end
	end
end


local MODULES = {
"SpeakinSpell",
"SpeakinSpell_GUI",
"SpeakinSpell_Patches",
"SpeakinSpell_Defaults",
}
function SpeakinSpell:GetAddonMemoryUsedString()
	-- start
	local total = 0
	local Report = L["Memory usage report\n"]
   
   -- make sure we are not in combat or this will crash.
   
   if UnitAffectingCombat("player") then
   -- if we are in combat return a blank report and continue on. 
      return Report;
   end
   
	-- list all the modules
	for i,module in ipairs(MODULES) do
      UpdateAddOnMemoryUsage(module)
		local kb = GetAddOnMemoryUsage(module)
		total = total + kb
		local format = L["<module>: <kb> kb"]
		local subs = {
			module = module,
			kb = string.format("%d",kb), -- convert floats to whole number of kb
		}
		Report = Report .. self:FormatSubs( format, subs ) .. "\n"
	end
	-- add the total
	local format = L["Total: <kb> kb"]
	local subs = {
		kb = string.format("%d",total), -- convert floats to whole number of kb
	}
	Report = Report .. self:FormatSubs( format, subs )
	return Report
end


-- Load chat channel colors from the chat frame settings
-- NOTE: it takes a while for ChatTypeInfo to be populated, so this doesn't work too early during loading
--		OnVariablesLoaded, the data is still not available, so we have to call this late as-needed in the GUI
--		which is just as well to force us to get the latest settings if they've changed
function SpeakinSpell:LoadChatColorCodes()
	-- NOTE: new colors can be declared with empty strings
	--		keys must be valid chat type names for ChatTypeInfo[]
	SpeakinSpell.Colors.Channels = {
		RAID				= "|cffff6b00",
		INSTANCE_CHAT		= "|cffff6b00",
		GUILD				= "|c4444ff44",
		PARTY				= "|cffaaeeff",
		EMOTE				= "|cffff7b34",
		YELL				= "|cffff2f32",
		RAID_WARNING		= "|cffffdbad",
		RAID_BOSS_WHISPER	= "",
	}
	
	-- load the game's built-in channel colors from ChatTypeInfo
	for channel,_ in pairs( SpeakinSpell.Colors.Channels ) do
		local info = ChatTypeInfo[channel]
		if info then
			if nil == info.a then
				info.a = 1
			end
			SpeakinSpell.Colors.Channels[channel] = string.format( "|c%02x%02x%02x%02x", 255*info.a, 255*info.r, 255*info.g, 255*info.b )
		end
	end
	
	-- create colors code strings for the SpeakinSpell-created special channels
	if	SpeakinSpellSavedData and 
		SpeakinSpellSavedData.Colors and
		SpeakinSpellSavedData.Colors.Channels then
		for channel,info in pairs( SpeakinSpellSavedData.Colors.Channels ) do
			if nil == info.a then
				info.a = 1
			end
			SpeakinSpell.Colors.Channels[channel] = string.format( "|c%02x%02x%02x%02x", 255*info.a, 255*info.r, 255*info.g, 255*info.b )
		end
	end
end



function SpeakinSpell:StringColorCodeToTable(cc)
	-- cc is a string color code "|caarrggbb" example: "|cff123456"
	-- returns the color code as a table: t.a, t.r, t.g, t.b 
	-- using numbers in the format used by the color picker GUI controls and blizzard APIs
	-- which is a floating point number 0-1 representing the fraction of intensity 0-255
	
	-- extract component colors from the string escape sequence format "|caarrggbb"
	-- the "0x" is needed to make LUA interpret the string to number conversion correctly
	local aa = "0x"..string.sub( cc, 3, 4 )
	local rr = "0x"..string.sub( cc, 5, 6 )
	local gg = "0x"..string.sub( cc, 7, 8 )
	local bb = "0x"..string.sub( cc, 9, 11)
	
	-- convert string hex int "0xff" to floating point fraction or % of 0-255
	-- and store results in a table
	local t = {
		a = aa/255,
		r = rr/255,
		g = gg/255,
		b = bb/255,
	}
	
	return t
end


--Before the transition to using GlobalStrings, we used to define this in the Locale-xxXX.lua file:
--L["Shadowstorm"] = "Shadowstorm" <-- Important to note that GlobalStrings calls Shadowstorm "plague" so this may be reinstated
--GlobalStrings is probably the most accurate/appropriate value we could use
--because that's what it should show in the combat log and elsewhere in the default UI
function SpeakinSpell:DamageSchoolCodeNumberToString(number)
	local Schools = {
		[1] = STRING_SCHOOL_PHYSICAL,
		[2] = STRING_SCHOOL_HOLY,
		[4] = STRING_SCHOOL_FIRE,
		[8] = STRING_SCHOOL_NATURE,
		[12] = STRING_SCHOOL_FIRESTORM,
		[16] = STRING_SCHOOL_FROST,
		[20] = STRING_SCHOOL_FROSTFIRE,
		[24] = STRING_SCHOOL_FROSTSTORM,
		[32] = STRING_SCHOOL_SHADOW,
		[40] = STRING_SCHOOL_SHADOWSTORM,
		[48] = STRING_SCHOOL_SHADOWFROST,
		[64] = STRING_SCHOOL_ARCANE,
		[68] = STRING_SCHOOL_SPELLFIRE,
	}
	if Schools[number] then
		return Schools[number]
	else
		return L["Unknown Damage Type"] --REVIEW: for consistency with the rest of SpeakinSpell, should this return nil? other <substitutions> fail to substitute, rather than say "No Target"
	end
end


-- Search for the summoned companion pet (CritterOrMount="CRITTER") or mount (CritterOrMount="MOUNT")
-- returns (name, spellID)
function SpeakinSpell:GetActiveCompanion(CritterOrMount)
	local funcname = "GetActiveCompanion"
	
	-- I can't find an API that returns the active companion's name directly
	-- looks like the only way is to iterate through all known critters to find the one that's summoned, if any
	self:DebugMsg(funcname, "CritterOrMount="..tostring(CritterOrMount))
	if "CRITTER" == CritterOrMount then
		--self:DebugMsg(funcname, "GetNumCompanions="..tostring(GetNumCompanions(CritterOrMount)))
		local guid = C_PetJournal.GetSummonedPetGUID()
		self:DebugMsg(funcname, "guid="..tostring(guid))
		if guid then
			--local petid = C_PetJournal.GetSummonedPetID()
			--self:DebugMsg(funcname, "petid="..tostring(petid))
			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(guid)
			self:DebugMsg(funcname, "customName="..tostring(customName))
			self:DebugMsg(funcname, "petName="..tostring(petName))
			--for critter spell IDs, use self.RuntimeData.LastKnownSpellId
			if customName then
				return customName, nil
			else
				return petName, nil
			end
		end
	elseif "MOUNT" == CritterOrMount then
		-- search all mounts to find the active one
		for i=1,C_MountJournal.GetNumDisplayedMounts() do
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetDisplayedMountInfo(i)
			if active then
				return creatureName, spellID
			end
		end
	else
		-- during login (but not reloadui) 
		-- we sometimes get a COMPANION_UPDATE with an invalid CritterOrMount value
		self:DebugMsg(funcname, "error invalid CritterOrMount="..tostring(CritterOrMount))
	end

	-- none of the known companion pets are currently summoned
	self:DebugMsg(funcname, "failed")
	return nil, nil
end



-- TODO: DetermineMountClass is not useful in its current form vs. WoW 5.0.4
--       it may be useful to move this to employ this logic as part of COMPANION_UPDATE
--       in order to fire specialized events
-- returns one of the following
--"/ss macro mount"
--"/ss macro mount swim"
--"/ss macro mount qiraj"
--"/ss macro mount flight"
--"/ss macro mount flight fast"
--"/ss macro mount flight 310"
--"/ss macro mount ground"
--"/ss macro mount ground fast"
--[[
function SpeakinSpell:DetermineMountClass( tooltip )

	if not tooltip then
		return "/ss macro mount" -- generic any mount
	end
	
	-- this if-else logic was borrowed from Mountiful
	-- code style and actions taken have been changed for SpeakinSpell purposes
	if ( string.find(tooltip, L["swimmer"]) ) then
		return "/ss macro mount swim"
	elseif ( string.find(tooltip, L["Qiraj"]) ) then
		return "/ss macro mount qiraj"
	elseif string.find(tooltip, L["changes"]) and string.find(tooltip, L["location"]) then -- Catches mounts that change depending on location and skill --headless horseman mount
		return "/ss macro mount ground"
	elseif string.find(tooltip, L["changes"]) and not string.find(tooltip, L["Outland"]) then -- Catches mounts that change depending on skill
		return "/ss macro mount flight"
	elseif string.find(tooltip, L["Outland"]) then -- Catches flying mounts
		if string.find(tooltip, L["extremely"]) then -- Catches 310% mounts
			return "/ss macro mount flight 310"
		elseif(string.find(tooltip, L["changes"])) then -- Catches flying mounts that change depending on skill
			return "/ss macro mount flight"
		elseif (string.find(tooltip, L["very"]))then -- Catches epic flyers
			return "/ss macro mount flight fast"
		else
			return "/ss macro mount flight"
		end
	elseif not string.find(tooltip, L["Outland"]) then
		if string.find(tooltip, L["very"])then
			return "/ss macro mount ground fast"
		else
			return "/ss macro mount ground"
		end
	end
end
--]]


--[[
Lots of notes here on the issues surrounding RunSlashCommand below

one possible implementation of RunSlashCmd from wowwiki
http://www.wowwiki.com/RunSlashCmd

-- works for "/help" but not for "/cheer" - it doesn't work on built-in emotes

local _G = _G
local function RunSlashCmd(cmd)
  local slash, rest = cmd:match("^(%S+)%s*(.-)$")
  for name in pairs(SlashCmdList) do
     local i = 1
     local slashCmd
     repeat
        slashCmd = _G["SLASH_"..name..i]
        
        if slashCmd == slash then
           -- Call the handler
           SlashCmdList[name](rest)
           return true
        end
        i = i + 1
     until not slashCmd
  end
end 

The problem is, that method doesn't work with emotes
There's an equivalent algorithm that ONLY works with emotes
I need a function that does both

Technically, there are actually 4 cases:
- /help		- built-in slash commands
- /ss		- addon slash commands
- /cheer	- emotes
- /say		- chat channel selectors

Those are all handled by different Blizzard code
most solutions I find (on wowwiki) only handle 1 of those, but not the others

---

	the following method was perfect in 3.3.3, but is now incomplete after 3.3.5.
	CreateFrame("EditBox") is an incomplete object for use with ChatEdit_SendText()
	It seems to work, but as it pops off the stack and does its cleanup
	it tries to deactivate the EditBox, and fails on a bunch of nil values
	I tried experimentally adding stubs to satisfy the nil objects
	but that's impossible based on guessing, without access to the source
	which is in the private code.
	I found an imperfect work-around below
	
	-- create a hidden edit box to parse and send the slash command
	if not SpeakinSpellTempEditBox then
		self:DebugMsg(funcname, "creating SpeakinSpellTempEditBox")
		SpeakinSpellTempEditBox = CreateFrame("EditBox", "SpeakinSpellTempEditBox")
		--ZOMG HAX
		--WoW 3.3.5 overhauled the chat frame with zero documentation
		--I got an error popup saying
		--	Message: ..\FrameXML\ChatFrame.lua line 3421:
		--   attempt to index field 'header' (a nil value)
		--and took a WILD guess that it was a field of SpeakinSpellTempEditBox
		--one nil field error after the next, I experimentally found I could hack around it by adding these stubs
		SpeakinSpellTempEditBox.header = {}
		SpeakinSpellTempEditBox.header.Hide = function() end
		SpeakinSpellTempEditBox.focusLeft = {}
		SpeakinSpellTempEditBox.focusLeft.Hide = function() end
		SpeakinSpellTempEditBox.focusRight = {}
		SpeakinSpellTempEditBox.focusRight.Hide = function() end
		SpeakinSpellTempEditBox.focusMid = {} --focusMid?! Blizz, you are just mocking me now WTF are these things?!
		SpeakinSpellTempEditBox.focusMid.Hide = function() end
		SpeakinSpellTempEditBox.button = {} --TODOFUTURE: this isn't it, it's a field of some other table
		--Hide was already here before 3.3.5, since the beginning
		SpeakinSpellTempEditBox:Hide()
	end

	self:DebugMsg(funcname,"executing slash command: " .. tostring(text) )
	SpeakinSpellTempEditBox:SetText(text)
	ChatEdit_SendText(SpeakinSpellTempEditBox) -- throws a lua error, as-is, without more attached frame objects in the table

-- this doesn't work either
--	DEFAULT_CHAT_FRAME:SetText(text)
--	ChatEdit_SendText(DEFAULT_CHAT_FRAME)

-- nor this
--	DEFAULT_CHAT_FRAME:AddMessage(text)

-- using ChatFrame 1 has the side-effect of erasing something you're in the middle of typing
-- if an event fires an emote while you're trying to type something manually
	ChatFrame1EditBox:SetText(text)
	ChatEdit_SendText(ChatFrame1EditBox)

-- to work around that problem, I tried to GetText then SetText as follows
-- the text is preserved, however the edit box loses focus
-- you have to click it with the mouse to get focus on it again
-- hitting enter resets it to an empty string
	local oldtext = ChatFrame1EditBox:GetText()
	ChatFrame1EditBox:SetText(text)
	ChatEdit_SendText(ChatFrame1EditBox)
	ChatFrame1EditBox:SetText(oldtext)

-- which led me to using ChatFrame 2
-- this suffers the same problem, but since chat frame 2 is usually the combat log
-- the impact is gone
-- and text you were typing in chat frame 1 is not effected
-- while the emote still comes out in chat frame 1 as expected based on chat types

Update: ChatFrame2EditBox still works in 4.0.6, but still has the undesirable side effect
the user *could* be typing a message into ChatFrame2EditBox (combat log window)
which would get blown away by using it for our RunSlashCommand function
--]]

--[[ 
--in 3.3.5 the following function requires a fragment of XML 
--to fix initialization of the EditBox object
see frames.xml
	<EditBox name="SpeakinSpellEditBoxTemplate" inherits="ChatFrameEditBoxTemplate" virtual="true">
		<Scripts>
			<OnLoad>
				self.chatFrame = self:GetParent();
				ChatEdit_OnLoad(self);
			</OnLoad>
		</Scripts>
	</EditBox>
--]]

--[[ WoW 4.0.6

Found out how to get the latest ChatFrame.lua code

1. Launch WoW with the -console switch; on Windows, you can do this from the properties of the shortcut if you're so inclined, or directly from the command line; on Mac, you can open a terminal and use "open /Applications/World\ of\ Warcraft/World\ of\ Warcraft\ Launcher.app --args -console" (on most systems).
(this works from the launcher.exe)

2. Once you're at the login screen, hit the `/~ key to open a text console a the top of the window.
(character selection screen, tilde key)

3. Type "exportInterfaceFiles code" (or "exportInterfaceFiles art") and hit Enter. The game will likely lag for a moment.
(copy-paste works)

4. Find the current version of the stock UI files in BlizzardInterfaceCode in your WoW directory.
WoW/BlizzardInterfaceCode/Interface/FrameXML/ChatFrame.lua

Sadly, something is breaking here in 4.0.6 where the error says
Message: ..\FrameXML\ChatFrame.lua line 3779:
   attempt to perform arithmetic on a nil value

The related line of code in ChatFrame.lua is:
	local headerWidth = header:GetRight() - header:GetLeft();
	
Apparently "header" is non-nil, but GetRight and/or GetLeft are returning nil instead of 0
Grr @ Blizzard for that...
--]]

--[[

-- Since this method is only working in 4.0.6 based on the ChatFrame2EditBox hack noted below
-- we're going with the wowwiki method described in the first related comment above (way up there)
-- at least for now...

function SpeakinSpell:RunSlashCommand(text)
	local funcname = "RunSlashCommand"

	-- validate input
	if not text then
		return false
	end
	if type(text) ~= "string" then
		return false
	end
	if ( strsub(text, 1, 1) ~= "/" ) then
		return false
	end
	
	-- wait to create the SpeakinSpellChatEditBox until the first time we need it
	if not SpeakinSpell.SpeakinSpellChatEditBox then
		--SpeakinSpell.SpeakinSpellChatEditBox = CreateFrame("EditBox", "SpeakinSpellChatEditBox", UIParent, "SpeakinSpellEditBoxTemplate")
		SpeakinSpell.SpeakinSpellChatEditBox = ChatFrame2EditBox --HACK!
	end
	
	-- OK to send the command	
	self:DebugMsg(funcname,"passing to SpeakinSpellChatEditBox: " .. tostring(text) )
	SpeakinSpell.SpeakinSpellChatEditBox:SetText(text) 
	ChatEdit_SendText(SpeakinSpell.SpeakinSpellChatEditBox)

	self:DebugMsg(funcname,"success" )
	return true
end
--]]

--[[
WoW 4.0.6

Blizzard keeps breaking the chat frame on us
Here's hoping this method stays reliable through future patches now
Adapted from http://www.wowwiki.com/RunSlashCmd

Duerma's list of chat commands to look for:
	SLASH_BATTLEGROUND1, SLASH_BATTLEGROUND2, SLASH_BATTLEGROUND3, SLASH_BATTLEGROUND4, SLASH_CHANNEL1, SLASH_CHANNEL2, SLASH_CHANNEL3, SLASH_CHANNEL4, SLASH_EMOTE1, SLASH_EMOTE2, SLASH_EMOTE3, SLASH_EMOTE4, SLASH_EMOTE5, SLASH_EMOTE6, SLASH_EMOTE7, SLASH_EMOTE8, SLASH_FOLLOW1, SLASH_FOLLOW2, SLASH_FOLLOW3, SLASH_FOLLOW4, SLASH_FOLLOW5, SLASH_FOLLOW6, SLASH_FOLLOW7, SLASH_GUILD1, SLASH_GUILD2, SLASH_GUILD3, SLASH_GUILD4, SLASH_GUILD5, SLASH_GUILD6, SLASH_GUILD7, SLASH_GUILD8, SLASH_GUILD9, SLASH_OFFICER1, SLASH_OFFICER2, SLASH_OFFICER3, SLASH_OFFICER4, SLASH_OFFICER5, SLASH_OFFICER6, SLASH_PARTY1, SLASH_PARTY2, SLASH_PARTY3, SLASH_PARTY4, SLASH_PARTY5, SLASH_RAID1, SLASH_RAID2, SLASH_RAID3, SLASH_RAID4, SLASH_RAID5, SLASH_RAID6, SLASH_RAID_WARNING1, SLASH_RAID_WARNING2, SLASH_SAY1, SLASH_SAY2, SLASH_SAY3, SLASH_SAY4, SLASH_YELL1, SLASH_YELL2, SLASH_YELL3, SLASH_YELL4, SLASH_YELL5, SLASH_YELL6, SLASH_YELL7, SLASH_YELL8, "/in"
	In English, there are twice as many commands as needed, but in other languages this is not the case.
	Everything not a slash command and not /ss can be passed through DoEmote. 
	If it's a real emote, it will fire. If not, it will fail silently,
	see CHAT_CHANNEL_SELECTORS table below

NOTE: recursive calls to /ss macros are handled in ProcessChatSlashCommand
	as well as some additional error logic to see if this function should be called

NOTE: as of WoW 5.0.4 I'm now using a technique I got from the SlashIn addon

local _G = _G
local CHAT_CHANNEL_SELECTORS = {
	[SLASH_BATTLEGROUND1] = "BATTLEGROUND",
	[SLASH_BATTLEGROUND2] = "BATTLEGROUND",
	[SLASH_BATTLEGROUND3] = "BATTLEGROUND",
	[SLASH_BATTLEGROUND4] = "BATTLEGROUND",
	--[ [ "/c" requires special handling like "/t"
	[SLASH_CHANNEL1] = "1",
	[SLASH_CHANNEL2] = "2",
	[SLASH_CHANNEL3] = "3",
	[SLASH_CHANNEL4] = "4",
	--] ]
	[SLASH_EMOTE1] = "EMOTE",
	[SLASH_EMOTE2] = "EMOTE",
	[SLASH_EMOTE3] = "EMOTE",
	[SLASH_EMOTE4] = "EMOTE",
	[SLASH_EMOTE5] = "EMOTE",
	[SLASH_EMOTE6] = "EMOTE",
	[SLASH_EMOTE7] = "EMOTE",
	[SLASH_EMOTE8] = "EMOTE",
	--[ [ /follow is not a chat channel selector, it should be detected in the SlashCmdList
	[SLASH_FOLLOW1] = "/follow",
	[SLASH_FOLLOW2, 
	[SLASH_FOLLOW3, 
	[SLASH_FOLLOW4, 
	[SLASH_FOLLOW5, 
	[SLASH_FOLLOW6, 
	[SLASH_FOLLOW7, 
	--] ]
	[SLASH_GUILD1] = "GUILD",
	[SLASH_GUILD2] = "GUILD",
	[SLASH_GUILD3] = "GUILD",
	[SLASH_GUILD4] = "GUILD",
	[SLASH_GUILD5] = "GUILD",
	[SLASH_GUILD6] = "GUILD",
	[SLASH_GUILD7] = "GUILD",
	[SLASH_GUILD8] = "GUILD",
	[SLASH_GUILD9] = "GUILD",
	[SLASH_OFFICER1] = "OFFICER",
	[SLASH_OFFICER2] = "OFFICER",
	[SLASH_OFFICER3] = "OFFICER",
	[SLASH_OFFICER4] = "OFFICER",
	[SLASH_OFFICER5] = "OFFICER",
	[SLASH_OFFICER6] = "OFFICER",
	[SLASH_PARTY1] = "PARTY",
	[SLASH_PARTY2] = "PARTY",
	[SLASH_PARTY3] = "PARTY",
	[SLASH_PARTY4] = "PARTY",
	[SLASH_PARTY5] = "PARTY",
	[SLASH_RAID1] = "RAID",
	[SLASH_RAID2] = "RAID",
	[SLASH_RAID3] = "RAID",
	[SLASH_RAID4] = "RAID",
	[SLASH_RAID5] = "RAID",
	[SLASH_RAID6] = "RAID",
	[SLASH_RAID_WARNING1] = "RAID_WARNING",
	[SLASH_RAID_WARNING2] = "RAID_WARNING",
	[SLASH_SAY1] = "SAY",
	[SLASH_SAY2] = "SAY",
	[SLASH_SAY3] = "SAY",
	[SLASH_SAY4] = "SAY",
	[SLASH_YELL1] = "YELL",
	[SLASH_YELL2] = "YELL",
	[SLASH_YELL3] = "YELL",
	[SLASH_YELL4] = "YELL",
	[SLASH_YELL5] = "YELL",
	[SLASH_YELL6] = "YELL",
	[SLASH_YELL7] = "YELL",
	[SLASH_YELL8] = "YELL",
	--NOTE: SLASH_WHISPER1 through SLASH_WHISPER10 are handled differently
	--		because we have to extract the target player's name
}


--function SpeakinSpell:RunSlashCommand(text)
	local funcname = "RunSlashCommand"

	-- split "/slash rest" into slash="/slash" rest="rest"
	local slash, rest = text:match("^(%S+)%s*(.-)$")
	slash = strlower(slash)
	--self:DebugMsg(funcname, "slash:"..tostring(slash))
	--self:DebugMsg(funcname, "rest:"..tostring(rest))

	-- "/c 2 whatever" or "/csay trade whatever"
	-- named/numbered channels require similar handling to whispers
	-- For some reason, "/c" is coming up in the SlashCmdList
	-- and the related func() is throwing an error in ChatFrame.lua
	-- not sure if this is a Blizzard bug, or a conflicting addon that inappropriately registered "/c"
	-- but it seems reasonable to check for Blizzard's definition of "/c" first
	-- TODO: this isn't working with named channels
	--		/join mychannel = [5. mychannel]
	--		"/c 5 test" works
	--		"/c mychannel test" fails silently within SpeakinSpell
	--		If I type into the chat frame, as I hit the space after "/c mychannel" it changes my chat input box immediately, 
	--		before I finish typing the message, and I think that's why it doesn't work here
	--		when that becomes SendChatMessage(message, "CHANNEL", nil, "mychannel")
	--		which could also explain why "/c" is coming up in the SlashCmdList below
	local i = 1
	while _G["SLASH_CHANNEL"..i] do
		if slash == _G["SLASH_CHANNEL"..i] then
			local target, message = rest:match("^(%S+)%s*(.-)$")
			self:DebugMsg(funcname, "found channel SLASH_CHANNEL"..tostring(i))
			SendChatMessage(message, "CHANNEL", nil, target)
			return true
		end
		i = i + 1
	end

	-- numbered channels using "/2 WTS portals"
	-- we have to check for each possible number since they aren't in CHAT_CHANNEL_SELECTORS
	i = 1
	repeat
		if slash == "/"..i then
			self:DebugMsg(funcname, "found CHANNEL /"..tostring(i))
			SendChatMessage(rest, "CHANNEL", nil, i)
			return true
		end
		i = i + 1
		-- TODO: what's the correct max number here? going with /9 as the max for now
	until i>9

	-- some commands, notable /run and /script are not found by the loop below
	-- try a direct table lookup first (should be faster than the loop below)
	-- from ChatFrame.lua (blizzard code)
	--     SlashCmdList["SCRIPT"] = function(msg)
	--	       RunScript(msg);
	--     end
	local COMMAND = strsub( strupper(slash), 2 )
	--self:DebugMsg(funcname, "uppercase COMMAND="..tostring(COMMAND))
	local func = SlashCmdList[COMMAND]
	if func ~= nil then
		self:DebugMsg(funcname, "found by direct lookup in SlashCmdList")
		func(rest)
		return true;
	end
	
	-- search the registered slash commands list the slow way
	-- this should include "/help" and "/addon" commands
	-- for sample code, see ChatFrame.lua function ChatEdit_ParseText
	-- NOTE: this doesn't seem necessary after performing the direct lookup above
	--[ [
	local name = ""
	local func = nil
	for name, func in pairs(SlashCmdList) do
		local i, slashCmd = 1
		self:DebugMsg(funcname, "SlashCmdList[i] = \""..name.."\"")
		repeat
			slashCmd, i = _G["SLASH_"..name..i], i + 1
			if slashCmd == slash then
				self:DebugMsg(funcname, "found by loop search in SlashCmdList (unexpected after direct lookup)")
				func(rest)
				return true
			end
		until not slashCmd
	end
	--] ]
	
	-- Okay, so it's not a slash command. It may also be an emote.
	i = 1
	while _G["EMOTE" .. i .. "_TOKEN"] do
		local j, cn = 2, _G["EMOTE" .. i .. "_CMD1"]
		while cn do
			if cn == slash then
				self:DebugMsg(funcname, "found DoEmote")
				DoEmote(_G["EMOTE" .. i .. "_TOKEN"], rest);
				return true
			end
			j, cn = j+1, _G["EMOTE" .. i .. "_CMD" .. j]
		end
		i = i + 1
	end
	
	-- Okay, so it's not a slash command, or an emote
	-- it could be a chat channel selector like /say or /party
	-- we define CHAT_CHANNEL_SELECTORS above, using all possible localized prefixes, i.e. /y vs. /yell
	local channel = CHAT_CHANNEL_SELECTORS[slash]
	if channel ~= nil then
		self:DebugMsg(funcname, "found in CHAT_CHANNEL_SELECTORS, channel="..tostring(channel))
		SendChatMessage(rest, channel)
		return true
	end
	
	-- Whispers (/t) are a little more complicated because we have to parse out the target name
	i = 1
	while _G["SLASH_WHISPER"..i] do
		if slash == _G["SLASH_WHISPER"..i] then
			local target, message = rest:match("^(%S+)%s*(.-)$")
			self:DebugMsg(funcname, "found whisper")
			SendChatMessage(message, "WHISPER", nil, target)
			return true
		end
		i = i + 1
	end
	
	-- Okay, it's not a slash command that we could find
	self:DebugMsg(funcname, "failed for text: "..tostring(text))
	return false
end
--]]

--[
--WoW 5.0.4
--Copied from SlashIn.lua
-- We execute lines by faking them as EXECUTE_CHAT_LINE events to the MacroEditBox defined in ChatFrame.lua.
-- The main benefit of this is that MacroEditBox gets special treatment in ChatEdit_OnEscapePressed.
-- It's also elegant, and reuses Blizzard code.
-- The main concern is taint, but I've tested it fairly well, and analyzed the execution path, and I'm
-- reasonably sure taint isn't an issue.
-- If taint does become a problem, there are other implementations that work just as well; they're just
-- less elegant. The dev version in Git has an alternative implementation commented out at the bottom.

--Ris: This is what I've always wanted to do in SpeakinSpell to begin with
--and it appears that this is the correct way (at last!) to write the code
--]

local MacroEditBox = MacroEditBox
local MacroEditBox_OnEvent = MacroEditBox:GetScript("OnEvent")

function SpeakinSpell:RunSlashCommand(text)
	MacroEditBox_OnEvent(MacroEditBox, "EXECUTE_CHAT_LINE", text)
end
