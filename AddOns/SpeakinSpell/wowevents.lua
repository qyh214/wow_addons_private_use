-- Author      : RisM
-- Create Date : 6/28/2009 4:02:20 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("wowevents.lua")

-------------------------------------------------------------------------------
-- WOW GAME EVENT HANDLERS
-------------------------------------------------------------------------------


function SpeakinSpell:RegisterAllEvents()
	local funcname = "RegisterAllEvents"
	self:DebugMsg(funcname, "entry")
	
	-- register for spellcasting events
	-- which is our hook too know when to speak for a spell
	-- among other things
	
	-- startup and loading events
	--self:RegisterEvent("VARIABLES_LOADED") -- wowwiki recommends using ADDON_LOADED instead after WoW 3.0
	-- see additional comments around these two event handler functions
	self:RegisterEvent("ADDON_LOADED")
	
	-- combat events
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_SENT") --just to get the target (but not the spellid)
	self:RegisterEvent("UNIT_SPELLCAST_START") --actually fires the speech event because it includes the spellid (but not the target)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_UNGHOST")
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self:RegisterEvent("COMPANION_UPDATE")

	-- enter and exit combat
	-- NOTE: PLAYER_ENTER_COMBAT and PLAYER_LEAVE_COMBAT are not what they sound like
	--		Those 2 events are auto-attack on/off notifications
	--		To detect when the combat flag goes on and off from getting/losing aggro
	--		which is what we generally mean by "entering combat" and "exiting combat"
	--		we must check for Regen enabled/disabled, which is our only valid notification
	--		see also: http://www.wowwiki.com/Events/Combat
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	-- change zones --
	--self:RegisterEvent("MINIMAP_ZONE_CHANGED") --for subzone changes - does not appear to be needed
	self:RegisterEvent("ZONE_CHANGED_INDOORS") --for subzone changes inside an instance
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --for large scale zone changes
	self:RegisterEvent("ZONE_CHANGED") --covers both small and large scale zone changes?
	
	-- chat events, such as receiving a whisper
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	self:RegisterEvent("CHAT_MSG_GUILD")
	self:RegisterEvent("CHAT_MSG_PARTY")

	-- detecting /follow
	self:RegisterEvent("AUTOFOLLOW_BEGIN")
	self:RegisterEvent("AUTOFOLLOW_END")
	
	-- Achievements
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

	-- NPC interaction
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("BARBER_SHOP_OPEN")
	self:RegisterEvent("BARBER_SHOP_CLOSE")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("TAXIMAP_OPENED")
	self:RegisterEvent("TRAINER_SHOW")
	
	-- TODO: experimental new summoning support - but how can I tell if I'm casting a summoning effect?
	self:RegisterEvent("CONFIRM_SUMMON") -- I received a summon?
	self:RegisterEvent("CANCEL_SUMMON") -- the summon I received has canceled or timed out?
	
	-- more miscellaneous events
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("RESURRECT_REQUEST")
	self:RegisterEvent("TRADE_SHOW")
   --self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
end


---------------------------------------------------------------------------
-- STARTUP AND LOADING EVENTS
---------------------------------------------------------------------------

-- 2010/04/17
-- wowwiki recommends using ADDON_LOADED instead of VARIABLES_LOADED
-- it has never been a problem for me to use VARIABLES_LOADED
-- but every so often someone has complained that installing a new version of SS
-- erased their old saved data, which should not occur (See oldversions.lua)
-- however the load order changes from WoW 3.0 described here:
-- http://www.wowwiki.com/AddOn_loading_process
-- http://www.wowwiki.com/Events/V
-- http://www.wowwiki.com/Events_A-B_%28ActionBar,_Auction,_AutoEquip,_AutoFollow,_Bag,_BankFrame,_BattleFields,_Billing%29#ADDON_LOADED
-- suggest that perhaps switching to ADDON_LOADED will fix this problem (/shrug?)
-- It still seems more likely to me that those other users suffered some other problem
-- and blamed SS incorrectly, but it doesn't hurt to update to the new best practice here

--[[ mothballed

function SpeakinSpell:VARIABLES_LOADED()
	local funcname = "VARIABLES_LOADED"
	self:DebugMsg(funcname, "entry")
	
	--self:OnVariablesLoaded() -- redirected to SpeakinSpell.lua near OnLoad and OnInitialize
end

--]]


function SpeakinSpell:ADDON_LOADED(_,name)
	local funcname = "ADDON_LOADED"
	self:DebugMsg(funcname, "entry, name:"..tostring(name))
	
	if name == "SpeakinSpell" then
		self:OnVariablesLoaded() -- redirected to SpeakinSpell.lua near OnLoad and OnInitialize
	end
end


---------------------------------------------------------------------------
-- COMBAT EVENTS
---------------------------------------------------------------------------


function SpeakinSpell:SPELL_AURA_APPLIED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	local funcname = "SPELL_AURA_APPLIED"
	-- we're only concerned with buffs we receive
	if not SpeakinSpell:NameIsMe(dstName) then
		--self:DebugMsg(funcname, "not cast on you")
		return
	end
	
	-- extra parameters provided with "SPELL_" prefix
	local spellId, spellName, spellSchool = select(1, ...)
	-- extra parameters provided with "_AURA_APPLIED" suffix (same for _AURA_REFRESH)
	local auraType = select(4, ...)

--	self:DebugMsg(funcname, "( srcName, dstName, auraType, spellName )")
--	self:DebugMsgDumpString("srcName",srcName)
--	self:DebugMsgDumpString("dstName",dstName)
--	self:DebugMsgDumpString("auraType",auraType)
--	self:DebugMsgDumpString("spellName",spellName)
	
	local DetectedEventStub = {
		-- event descriptors
		name = spellName,
		type = "SPELL_AURA_APPLIED_"..tostring(auraType),
		-- event-specific data for substitutions
		caster = self:PlayerNameNoRealm(srcName),
		target = self:PlayerNameNoRealm(dstName),
		spellid = spellId,
	}
	
	-- buffs cast on me by someone other than me are treated differently than buffs I cast on myself
	if not SpeakinSpell:NameIsMe(srcName) then
		self:DebugMsg(funcname, "not cast by you")
		DetectedEventStub.type = tostring(DetectedEventStub.type).."_FOREIGN"
	end
	
	-- process the spell
	-- this function is shared with the UNIT_SPELLCAST_SENT event handler
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:SPELL_AURA_REMOVED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	local funcname = "SPELL_AURA_REMOVED"
	-- we're only concerned with buffs on ourselves
	if not SpeakinSpell:NameIsMe(dstName) then
		--self:DebugMsg(funcname, "not fading from you")
		return
	end
	
	-- extra parameters provided with "SPELL_" prefix
	local spellId, spellName, spellSchool = select(1, ...)
	-- extra parameters provided with "_AURA_REMOVED" suffix (same for _AURA_APPLIED)
	local auraType = select(4, ...) --BUFF or DEBUFF

--	self:DebugMsg(funcname, "( srcName, dstName, auraType, spellName )")
--	self:DebugMsgDumpString("srcName",srcName)
--	self:DebugMsgDumpString("dstName",dstName)
--	self:DebugMsgDumpString("auraType",auraType)
--	self:DebugMsgDumpString("spellName",spellName)
	
	local DetectedEventStub = {
		-- event descriptors
		name = spellName,
		type = "SPELL_AURA_REMOVED_"..tostring(auraType),
		-- event-specific data for substitutions
		caster = self:PlayerNameNoRealm(srcName),
		target = self:PlayerNameNoRealm(dstName),
		spellid = spellId,
	}
	
	-- buffs cast on me by someone other than me are treated differently than buffs I cast on myself
	-- but I don't care about the caster for fading debuffs
--	if not SpeakinSpell:NameIsMe(srcName) then
--		self:DebugMsg(funcname, "not cast by you")
--		DetectedEventStub.type = tostring(DetectedEventStub.type).."_FOREIGN"
--	end
	
	-- process the spell
	-- this function is shared with the UNIT_SPELLCAST_SENT event handler
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:SPELL_DAMAGE(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	-- extra parameters provided with "SPELL_" prefix
	local spellId, spellName, spellSchool = select(1, ...)
	-- extra parameters provided with "_DAMAGE" suffix
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)
	-- transfer to shared function
	self:DamageEvent(eventtype, spellId, spellName, srcName, dstName, amount, overkill, school, critical)
end


function SpeakinSpell:SWING_DAMAGE(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	-- extra parameters provided with "SWING_" prefix
	--none
	-- extra parameters provided with "_DAMAGE" suffix
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...)
	-- transfer to shared function
	-- NOTE: melee swings don't have a spell name or spellId
	self:DamageEvent(eventtype, nil, L["Melee Swing"], srcName, dstName, amount, overkill, school, critical)
end


function SpeakinSpell:RANGE_DAMAGE(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	--RANGE_DAMAGE is triggered for a hunter's bow or a mage's wand, etc.
	-- extra parameters provided with "RANGE_" prefix
	local spellId, spellName, spellSchool = select(1, ...)
	-- extra parameters provided with "_DAMAGE" suffix
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)
	-- transfer to shared function
	self:DamageEvent(eventtype, spellId, spellName, srcName, dstName, amount, overkill, school, critical)
end

--[[ Not ready yet
function SpeakinSpell:SPELL_MISSED(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...) 
	--We only care about blocks/parries/etc. if it happens to the player
	--REVIEW: No, other way around... we only care if this is the player's miss, i.e. the player is the source
	if not SpeakinSpell:NameIsMe(srcName) then
		return
	end
	--extra parameters with "SPELL_" prefix
	local spellId, spellName, spellSchool = select(1, ...)
	-- extra parameters provided with "_MISSED" suffix
	local missType, amountMissed = select(4, ...)
	--This makes the event name "%2$s was ___ed by %4$s"
	local eventname = _G["ACTION_SPELL_MISSED_"..missType.."_FULL_TEXT_NO_SOURCE"]
	--Replace the regexes with the words "player" and "attack". This 
	eventname = gsub(gsub(eventname, "%4$s", PLAYER),"%2$s",ATTACK)
	--REVIEW: that looks more like a display name... what does eventname actually say now? "<spellname> was blocked by <caster>"? that doesn't seem right
	local DetectedEventStub = {
			type = "COMBAT", --REVIEW: this might want to be SPELL_MISS for special handling of display names
			
			--REVIEW: which of these generates the key? which *should* generate it? the one that includes the name of the spell would probably be ideal, because you only want to announce when Taunt misses, not regular damage spells (probably)
			name		= eventname,
			eventname	= _G[missType], -- this formats the miss type to be localized and not all caps
			
			-- I don't think this stuff is necessary, but we'll see
			-- it's needed for "My <spellname> missed!" i.e. for a Taunt
			spellid = spellId,
			spellname = spellName,
			
			-- spell/ability was cast by source on dest
			caster = srcName,
			target = dstName,
			
			-- event-specific substitions
			misstype = missType, --might as well support this in case you use a shared speech list
			damage = amountMissed, --"Dang, that <spellname> would have hit for <damage>... but I missed! ack!"
		}
		self:OnSpeechEvent( DetectedEventStub )
end
]]

function SpeakinSpell:DamageEvent(eventtype, spellId, spellName, srcName, dstName, amount, overkill, school, critical) 
	
	local funcname = "DamageEvent"
	
	-- we only care about damage done by me
	if not SpeakinSpell:NameIsMe(srcName) then
		return
	end

--	self:DebugMsg(funcname, "eventtype:"..tostring(eventtype))
--	self:DebugMsg(funcname, "overkill:"..tostring(overkill))
--	self:DebugMsg(funcname, "critical:"..tostring(critical))
	
	if critical then
		local DetectedEventStub = {
			type = "COMBAT",
			
			name		= L["Critical Strike"],
			eventname	= L["Critical Strike"],
			
			-- replace the default spellname = eventname = name logic, to provide info about the actual spell
			spellid = spellId,
			spellname = spellName,
			
			-- spell/ability was cast by source on dest
			caster = self:PlayerNameNoRealm(srcName),
			target = self:PlayerNameNoRealm(dstName),
			
			-- event-specific substitions
			damage		= amount or 0,
			overkill	= overkill or 0,
			school		= self:DamageSchoolCodeNumberToString(school), --spellSchool is the same code number
		}
		-- override the display link format used by the Report Detected Speech Events diagnostic feature, to achieve this results:
		-- self:Print( "Combat Event: Critical Strike: [Seal of Righteousness]" )
		DetectedEventStub.displaylink = self:FormatSubs( "<eventtypeprefix><eventname>: <spelllink>", DetectedEventStub)
		
		self:OnSpeechEvent( DetectedEventStub )
	end
	
	--TODOFUTURE: this is only going to catch MOST killing blows
	--	if you kill something by exactly the right amount of damage, your overkill can be 0
	--	that's extremely unlikely, but for perfection we could use UNIT_DIED or PARTY_KILL
	--	Unfortunately, both of those provide GUID parameters instead of names
	--	which is just annoying, so I'm leaving it based on overkill damage for now
	if overkill and overkill > 0 then
		local DetectedEventStub = {
			type = "COMBAT",
			
			name		= L["Killing Blow"],
			eventname	= L["Killing Blow"],
			
			-- replace the default spellname = eventname = name logic, to provide info about the actual spell
			spellid = spellId,
			spellname = spellName,
			
			-- spell/ability was cast by source on dest
			caster = self:PlayerNameNoRealm(srcName),
			target = self:PlayerNameNoRealm(dstName),
			
			-- event-specific substitions
			damage		= amount or 0,
			overkill	= overkill or 0,
			school		= self:DamageSchoolCodeNumberToString(school), --spellSchool is the same code number
		}
		-- override the display link format used by the Report Detected Speech Events diagnostic feature, to achieve this results:
		-- self:Print( "Combat Event: Critical Strike: [Seal of Righteousness]" )
		DetectedEventStub.displaylink = self:FormatSubs( "<eventtypeprefix><eventname>: <spelllink>", DetectedEventStub)
		
		self:OnSpeechEvent( DetectedEventStub )
	end
end



-- This is like RegisterEvent: set up a table mapping the eventtype to a function
SpeakinSpell.CombatLogEvents = {
	["SPELL_AURA_APPLIED"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- buff gains
		SpeakinSpell:SPELL_AURA_APPLIED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	end,
	["SPELL_AURA_REFRESH"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- buff timer refreshed (Recast on you without wearing off all the way first)
		-- NOTE: the function is called SPELL_AURA_APPLIED because it's shared, but still pass eventtype=SPELL_AURA_REFRESH
		SpeakinSpell:SPELL_AURA_APPLIED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	end,
	["SPELL_AURA_REMOVED"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- buff or debuff is expiring
		SpeakinSpell:SPELL_AURA_REMOVED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	end,
	["SPELL_DAMAGE"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- any spell or other special ability landed a hit (or crit) to deal damage
		SpeakinSpell:SPELL_DAMAGE( timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	end,
	["SWING_DAMAGE"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- melee swings (white hits)
		SpeakinSpell:SWING_DAMAGE( timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	end,
	["RANGE_DAMAGE"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
		-- white hits with a ranged attack, such as a hunter's bow, or a mage's wand, etc.
		SpeakinSpell:RANGE_DAMAGE( timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...) 
	end,
  -- hoping this will pick up channeled summon events. 
   ["SPELL_SUMMON"] = function(  timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
   end,
--	["SPELL_MISSED"] = function(  timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		-- Special ability misses, is blocked, absorbed, parried, etc,
--		SpeakinSpell:SPELL_MISSED( timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...) 
--	end,
}

function SpeakinSpell:COMBAT_LOG_EVENT_UNFILTERED()
	local parameterTable = { CombatLogGetCurrentEventInfo() }
	local timestamp = parameterTable[1]
	local eventtype = parameterTable[2]
	local hideCaster = parameterTable[3]
	local srcGUID = parameterTable[4]
	local srcName = parameterTable[5]
	local srcFlags = parameterTable[6]
	local srcRaidFlags = parameterTable[7]
	local dstGUID = parameterTable[8]
	local dstName = parameterTable[9]
	local dstFlags = parameterTable[10]
	local dstRaidFlags = parameterTable[11]
	local overflowTable = {}
	for i = 1, #parameterTable do
		overflowTable[i] = parameterTable[i+11]
	end

	
	local func = SpeakinSpell.CombatLogEvents[eventtype]
	if func then
		func(unpack(parameterTable))
		--func(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, overflowTable)
		--func(parameterTable)
	end
end


function SpeakinSpell:UNIT_THREAT_LIST_UPDATE(_,mob)
	local funcname = "UNIT_THREAT_LIST_UPDATE"
	self:DebugMsg(funcname, "mob:"..tostring(mob))
	-- Omen comments say the mob will only be "target" or "focus"
	-- that seems to be true
	if not mob then
		-- we get this event at login with mob=nil, which causes UnitDetailedThreatSituation to throw an error
		return
	end
	local hasAggro,_,_,_,_ = UnitDetailedThreatSituation("player", mob);
	local situation = ""
	if self.RuntimeData.hasAggro and (not hasAggro) then
		--If you were tanking before and now you don't, do lost aggro event
		situation = L["I Lost Aggro"]
		self.RuntimeData.hasAggro = false
		self:DebugMsg(funcname, "Signal System Event: Losing Aggro")
	elseif (not self.RuntimeData.hasAggro) and hasAggro then
		--If you weren't tanking before and now you are, do the gain aggro event
		situation = L["I Gained Aggro"]
		self.RuntimeData.hasAggro = true
		self:DebugMsg(funcname, "Signal System Event: Gaining Aggro")
	else
		-- aggro has stayed the same
		return
	end
	local castername, casterrealm = UnitName(mob)
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		-- event descriptors
		type = "COMBAT",
		name = situation,
		-- event-specific data for substitutions
		caster = castername,
		target = myname,
	}
	self:OnSpeechEvent( DetectedEventStub )
end


-------------------------------------------------------------------------------
-- COMPANIONS/MOUNTS
-------------------------------------------------------------------------------


--[[
"COMPANION_UPDATE"
<Added in Patch 3.0 (WotLK)> 
Added to SpeakinSpell in SS v5.0.4.02
Copied from wowwiki/wowpedia (text is identical on both sites)

	If the type is nil, the UI should update if it's visible, regardless of which type it's managing. If the type is non-nil, then it will be either "CRITTER" or "MOUNT" and that signifies that the active companion has changed and the UI should update if it's currently showing that type.

	This event fires when any of the following conditions occur:

		- You, or anyone within range, summons or dismisses a critter
		- You, or anyone within range, mounts or dismounts
		- Someone enters range with a critter summoned
		- Someone enters range while mounted 

	"Range" appears to be at least 40 yards. If you are in a major city, expect this event to fire constantly.

For SpeakinSpell, we really only care about the cases where You, the player, 
summon or dismiss a critter or mount

We do NOT care about other players entering/exiting range with their mounts/critters
We do NOT care about other nearby players summoning/dismissing their mounts/critters

The API only tells us whether this event is for a "CRITTER" (=vanity pet) or "MOUNT"
In order for us to determine whether this event is for ourselves or for some other player
we need to keep track of the old companion in self.RuntimeData.ActiveCompanions
see also: self:LoadActiveCompanions()
--]]
function SpeakinSpell:COMPANION_UPDATE(_, CritterOrMount)
	local funcname = "COMPANION_UPDATE"
	local OldCompanion = self.RuntimeData.ActiveCompanions[CritterOrMount]
	local NewCompanion, NewSpellID = self:GetActiveCompanion(CritterOrMount)
	
	self:DebugMsg(funcname, "CritterOrMount="..tostring(CritterOrMount))
	self:DebugMsg(funcname, "OldCompanion="..tostring(OldCompanion))
	self:DebugMsg(funcname, "NewCompanion="..tostring(NewCompanion))

	if NewCompanion == OldCompanion then
		-- the active companion has not changed
		-- this must be a notification for another player summoning/dismissing their mounts/critters
		-- or another player entering/exiting range (40 yards)
		self:DebugMsg(funcname, "COMPANION_UPDATE ignored because NewCompanion == OldCompanion")
		return
	end
	
	-- remember the new companion for future reference, so we know when it changes
	self.RuntimeData.ActiveCompanions[CritterOrMount] = NewCompanion
	
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		-- event descriptors
		type = "EVENT",
		-- name = L["Summon Mount"], -- determined below

		-- treat these special events as cast by the player on himself
		caster = myname,
		target = (NewCompanion or OldCompanion), -- users may find this value more intuitive than UnitName("player"),

		-- EVENT-SPECIFIC DATA FOR SUBSTITUTIONS
		-- override the spellname with that of the applicable companion 
		-- either the one which was summoned (new) or dismissed (old)
		spellname = (NewCompanion or OldCompanion),
		spellid = (NewSpellID or self.RuntimeData.LastKnownSpellId),
		-- the isCOMPANION_UPDATE is used to override the behavior of <DisplayLink>
		isCOMPANION_UPDATE = true,
	}
	
	-- figure out which event just happened
	-- this 'name' will become the event trigger key
	if "MOUNT" == CritterOrMount then
		if nil == NewCompanion then
			-- the new mount is unknown, must be dismissed
			DetectedEventStub.name = L["Dismiss Mount"]
		else
			-- a mount is known, so we must have summoned it
			DetectedEventStub.name = L["Summon Mount"]
		end
	elseif "CRITTER" == CritterOrMount then
		if nil == NewCompanion then
			-- we had a vanity pet, but now we don't
			DetectedEventStub.name = L["Dismiss Companion Pet"]
		else
			if OldCompanion then
				-- If we're switching from an old mount to a new one
				-- it comes in a single companion update
				-- Fire the dismiss event, the the summon event
				DetectedEventStub.name = L["Dismiss Companion Pet"]
				DetectedEventStub.target = OldCompanion
				DetectedEventStub.spellname = OldCompanion
				self:OnSpeechEvent( DetectedEventStub )
				-- switch info back to the new companion for the summon event
				DetectedEventStub.target = NewCompanion
				DetectedEventStub.spellname = NewCompanion
				--NOTE: mounts don't have this issue because you must dismount before remounting
			end
			-- the new critter is unknown, so it must have been dismissed
			DetectedEventStub.name = L["Summon Companion Pet"]
		end
	else
		self:DebugMsg(funcname, "Unexpected CritterOrMount="..tostring(CritterOrMount))
		return
	end
	
	self:OnSpeechEvent( DetectedEventStub )
end


-------------------------------------------------------------------------------
-- SPELL CASTING EVENTS
-------------------------------------------------------------------------------

-- Analysis of spell event flows in WoW 4.0.3

-- There are 4 kinds of spells with different event flows
-- Castbars, Instants, Channeled, and Rituals.

-- Castbars possible flows:
--	SENT -> START -> SUCCEEDED -> STOP
--	FAILED
--	SENT -> FAILED
--	SENT -> START -> INTERRUPTED -> STOP -> INTERRUPTED -> INTERRUPTED -> INTERRUPTED

-- Instants possible flows:
--	SENT -> SUCCEEDED
--	FAILED
--	SENT -> FAILED

-- Channeled possible flows:
--	CHANNEL_START -> SUCCEEDED -> (channeling progress bar decays here) -> CHANNEL_STOP
--	FAILED

-- Rituals possible flows:
--	SENT -> CHANNEL_START (spellid 1) -> SUCCEEDED (spellid 1) -> SUCCEEDED (spellid 2) -> (channeling progress bar decays here) -> CHANNEL_STOP (spellid 1)
--	TEST: understand this better, something is different than other channeled spells, see examples

-- "When I start casting" speech event
--		needs the true spell target
--		needs the spellid
--		occurs whether followed by SUCCEEDED, FAILED, or INTERRUPTED
--		EventTable keys use de.type==UNIT_SPELLCAST_SENT for this
--		Castbars: announce this unless FAILED
--		Instants: announce this unless FAILED
--		Channeled: don't announce this - use "When I start channeling" instead (TODOFUTURE: change this rule and combine them)

-- UNIT_SPELLCAST_SENT
--		gives us the true spell target
--		does NOT give us the spellid
--		does NOT precede CHANNEL_START
--		typically does not occur if a spell FAILED, but it can occur for FAILED spells
--		from a macro (/m) we will get all UNIT_SPELLCAST_SENT first
--			before any of them go to START, SUCCEEDED, FAILED, or INTERRUPTED
--			also applies if spamming an instant cast quickly
--		Since it lacks the spellid, UNIT_SPELLCAST_SENT is only used for preparation
--			to build the PendingSpellcastSent table
--			mostly to capture the true spell target

-- UNIT_SPELLCAST_START
--		gives us the spellid
--		indicates the CAST BAR is starting (non-channeled)
--		only applies to castbar type spells
--		instant spells: does NOT occur for instant-cast spells
--		channeled spells: does NOT occur for channeled spells
--		does NOT give the true spell target

-- UNIT_SPELLCAST_STOP
--		indicates the CAST BAR has stopped
--		does NOT occur for instant-cast spells
--		does NOT occur for channeled spells
--		always preceded by SUCCEEDED or INTERRUPTED
--		never preceded by FAILED (in that case, we never got UNIT_SPELLCAST_START)
--		gives us the spellid
--		does NOT give the true spell target

-- UNIT_SPELLCAST_SUCCEEDED
--		Only occurs if the spell cast succeeded
--		Occurs for "miss" and similar results - does not imply that damage was done
--		For cast bar spells, this is always preceded by SENT and START
--		For instant casts, this is always preceded by SENT (no START)
--		For channeled spells, this is always preceded by CHANNEL_START (no SENT or START)
--			and indicates that channeling began successfully - NOT that the channeling is complete

-- UNIT_SPELLCAST_INTERRUPTED
--		occurs if you move, or are silenced or stunned during casting
--		only applies to cast bar spells
--		does NOT occur for interrupted channeled spells (they already SUCCEEDED and then merely STOP)
--		does NOT occur for instant casts (impossible to interrupt)
--		can occur redundantly for the same spell interruption 3 times in a row
--			I see one INTERRUPTED, then STOP, then 3x INTERRUPTED again

-- UNIT_SPELLCAST_FAILED
--		indicates that a spell was never attempted (no target, out of range, OOM, cooldown, GCD, etc)
--		NEVER preceded by SENT
--		NEVER occurs in the same event chain as INTERRUPTED
--		should NOT fire "when I start casting" for instant casts that fail
--			this is legacy behavior, and still the desirable result

-- UNIT_SPELLCAST_CHANNEL_START
--		gives us the spellid
--		only occurs for channeled spells and rituals
--		preceded by SENT for rituals (not for other channeled spells)

-- UNIT_SPELLCAST_CHANNEL_STOP
--		gives us the spellid


-------------------------------------------------------------------------------
-- Examples from testing 4.0.3.06


-- cast bar spell succeeds
-- summon a mount, and allow it to finish
-- SENT
-- START
-- SUCCEEDED
-- STOP

-- cast bar spell is interrupted
-- summon a mount, and move before it finishes
-- SENT
-- START
-- INTERRUPTED
-- STOP
-- INTERRUPTED -- suppress redundant interrupts -- I ALWAYS see 3 after the STOP, but is that reliable?
-- INTERRUPTED
-- INTERRUPTED

-- instant cast spell succeeds
-- cast arcane explosion
-- SENT
-- SUCCEEDED -- fake START off this

-- instant cast spell fails (OOM)
-- try to cast arcane explosion while out of mana
-- FAILED

-- instant cast spell fails (no target)
-- try to cast Fire Blast without a target
-- FAILED

-- instant cast spell fails (cooldown)
-- cast mirror images while it is on cooldown
-- FAILED

-- spam instant casts
-- spam arcane explosion, sometimes it fails because of the GCD
-- SENT
-- SENT -- GCD not triggered yet, so we were able to send
-- SUCCEEDED
-- FAILED (GCD) -- GCD in effect now, so we fail
-- SENT
-- SUCCEEDED
-- SENT
-- SENT
-- SENT -- I haven't seen it send more than 3 before the first cast happens and sets the GCD
-- SUCCEEDED
-- FAILED (GCD)
-- FAILED (GCD)
-- SENT
-- SUCCEEDED


-- multiple spell macro (/m) - complete success
-- cast Arcane Power and Mirror Image in the same macro (/m)
-- SENT (Arcane Power)
-- SENT (Mirror Image)
-- SUCCEEDED (Arcane Power) -- fake START from this
-- SUCCEEDED (Mirror Image) -- fake START from this

-- multiple spell macro (/m) - partial failure
-- cast Arcane Power and Mirror Image in the same macro (/m)
-- SENT (Arcane Power)
-- FAILED (Mirror Image)	-- DON'T fake START from this
-- SUCCEEDED (Arcane Power) -- fake START from this


-- channeled spell, non-targetable, full success
-- cast Evocation, and allow it to complete
-- CHANNEL_START
-- SUCCEEDED (immediately)
-- CHANNEL_STOP (when evocation is complete)

-- channeled spell, non-targetable, interrupted
-- cast Evocation, and move before it completes
-- CHANNEL_START
-- SUCCEEDED (immediately)
-- CHANNEL_STOP (when evocation is interrupted)

-- channeled spell, non-targetable, failed (cooldown)
-- cast Evocation, while on cooldown
-- FAILED

-- channeled spell, targetable, multiple success
-- cast Arcane Missiles
-- SENT "Arcane Missiles"
-- START spellid=5134
-- CHANNEL_START spellid=5134
-- SUCCEEDED spellid=5134 - 5134 appears to be the channeling effect
-- SUCCEEDED spellid=7268 - 7268 appears to be each bolt of damage
-- SUCCEEDED spellid=7268
-- SUCCEEDED spellid=7268
-- SUCCEEDED spellid=7268
-- SUCCEEDED spellid=7268
-- FAILED spellid=7268 (target dead)
-- CHANNEL_STOP spellid=5134

-- Ritual channeled spell, requires assistance, canceled by caster
-- cast Ritual of Refreshment without help
-- SENT (Ritual of Refreshment, spellid unknown)
-- CHANNEL_START (spellid 92827) -- 92827 is the channeling that holds the portal open?
-- SUCCEEDED (spellid 92827) -- typical for CHANNEL_START to immediately succeed
-- SUCCEEDED (spellid 43987) -- 43987 is the ritual that creates the table?
-- (I moved)
-- CHANNEL_STOP (spellid 92827) -- stop the channeling bar / stop holding the portal open
-- FAILED (spellid 43987) -- failed to create the table... after it succeeded... nice blizz, grr!

-- Ritual channeled spell, requires assistance, none given before time runs out
-- cast Ritual of Refreshment without help
-- SENT (Ritual of Refreshment, spellid unknown)
-- CHANNEL_START (spellid 92827) -- 92827 is the channeling that holds the portal open?
-- SUCCEEDED (spellid 92827) -- typical for CHANNEL_START to immediately succeed
-- SUCCEEDED (spellid 43987) -- 43987 is the ritual that creates the table?
-- (I moved)
-- CHANNEL_STOP (spellid 92827) -- stop the channeling bar / stop holding the portal open
-- (no failed?! grr!)

-- Ritual channeled spell, requires assistance, assistance given, ritual is completed
-- cast Ritual of Refreshment with help
-- SENT (Ritual of Refreshment, spellid unknown)
-- CHANNEL_START (spellid 92827) -- 92827 is the channeling that holds the portal open?
-- SUCCEEDED (spellid 92827) -- typical for CHANNEL_START to immediately succeed
-- SUCCEEDED (spellid 43987) -- 43987 is the ritual that creates the table?
-- CHANNEL_STOP (spellid 92827) -- stop the channeling bar / stop holding the portal open
-- (no indication of success or failure - this is the same as when I canceled it by moving)

-- Summoning stone - fail
-- Use a summoning stone and move to cancel summoning
-- TEST: do this experiment

-- Summoning stone - success
-- Use a summoning stone and get help to complete the summoning
-- TEST: do this experiment


-------------------------------------------------------------------------------


local PendingSpellcastsSent = {}

function SpeakinSpell:UNIT_SPELLCAST_SENT(event, caster, target, castid, spellid)
	--print(event.." "..caster.." "..target.." "..castid.." "..spellid)
	-- <lasttarget> is the last known <target> reported by a UNIT_SPELLCAST_SENT
	local spellname = GetSpellInfo(spellid)
	self.RuntimeData.LastSpellcastSentTarget = target
	self:DebugMsg("UNIT_SPELLCAST_SENT", tostring(spellname).." target is "..tostring(target))
	
	-- we're not firing the standard handler here because we don't have the spellid yet
	-- we might also skip ahead to other events
	-- because the API notifications are somewhat inconsistent depending on the in-game results
	-- so merely store some information about this pending spellcast that the player tried to send
	
	-- Deleting this object is a little tricky
	-- Based on the notes above, we can safely delete this on all FAILED, STOP, and CHANNEL_STOP events
	-- TODO: That leaves one case for instant casts that fire SENT -> SUCCEEDED
	--		SUCCEEDED can't tell what's an instant cast (castTime=0 for channeled spells)
	PendingSpellcastsSent[spellname] = {
		-- NOTE: don't remove the realm name from the target here - not until we setup the detected event stub
		target = target,		-- the true spell target we don't get from the other events
		interrupted = false,	-- used to suppress redundant interrupts
		AnnouncedStart = false, -- whether we announced "when I start casting" this spell (since START might be skipped)
		}
end


function SpeakinSpell:UNIT_SPELLCAST_START(event, caster, castid, spellid)
	--print(tostring(event).." "..tostring(caster).." "..tostring(spellname).." "..tostring(spellrank).." "..tostring(lineidcounter).." "..tostring(spellid))
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
end


function SpeakinSpell:UNIT_SPELLCAST_INTERRUPTED(event, caster, castid, spellid)
	-- these messages can be redundant for a single interrupt notified 3 times
	-- we may have sent many spells from a macro (/m) and any or all of them could be interrupted
	-- so match this interruption to a pending sent spell (if we can)
	--print(tostring(event).." "..tostring(caster).." "..tostring(spellname).." "..tostring(spellrank).." "..tostring(lineidcounter).." "..tostring(spellid))
	local PendingSent = PendingSpellcastsSent[spellname]
	local target = ""
	local spellname = GetSpellInfo(spellid)
	if PendingSent then
		if PendingSent.interrupted then
			self:DebugMsg(nil,"(already interrupted) suppressed redundant UNIT_SPELLCAST_INTERRUPTED for "..tostring(spellname))
			return
		end
		PendingSent.interrupted = true
		target = PendingSent.target
	else
		-- we interrupted a spell that was never sent
		-- this indicates that the spell already reached STOP so we deleted the PendingSent
		-- so this is a redundant interrupt
		self:DebugMsg(nil,"(no PendingSent info) suppressed redundant UNIT_SPELLCAST_INTERRUPTED for "..tostring(spellname))
		return
	end

	self:OnSpellcastEvent(event, caster, spellname, spellid)
end


function SpeakinSpell:UNIT_SPELLCAST_FAILED(event, caster, castid, spellid)
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
	PendingSpellcastsSent[spellname] = nil
end

function SpeakinSpell:UNIT_SPELLCAST_CHANNEL_START(event, caster, castid, spellid)
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
end

function SpeakinSpell:UNIT_SPELLCAST_CHANNEL_STOP(event, caster, castid, spellid)
	--print(tostring(event).." "..tostring(caster).." "..tostring(castid).." "..tostring(spellid).." "..tostring(arg1).." "..tostring(arg2))
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
	PendingSpellcastsSent[spellname] = nil
end

function SpeakinSpell:UNIT_SPELLCAST_STOP(event, caster, castid, spellid)
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
	PendingSpellcastsSent[spellname] = nil
end

function SpeakinSpell:UNIT_SPELLCAST_SUCCEEDED(event, caster, castid, spellid)
	local spellname = GetSpellInfo(spellid)
	self:OnSpellcastEvent(event, caster, spellname, spellid)
	
	-- if this is an instant cast, we need to clean up our pending sent object, or we'll leak memory
	-- but if it's not an instant cast, then we need to keep this pending sent info
	-- Blizzard Fail: castTime is 0 for channeled spells
	--		and isFunnel doesn't mean channeled spell (it means health funnel)
	-- so this would delete information prematurely
	--TODO: we have a small memory leak here still, and incorrect comments in SENT
	--[[
	local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange 
		= GetSpellInfo(spellid)

	if (castTime == 0) then
		self:DebugMsg("UNIT_SPELLCAST_SUCCEEDED", "cast time is 0 so delete pending sent info for: "..tostring(spellname))
		PendingSpellcastsSent[spellname] = nil
	end
	--]]
end


function SpeakinSpell:OnSpellcastEvent(event, caster, spellname, spellid)
--function SpeakinSpell:OnSpellcastEvent(event, caster, spellname, spellrank, spellid)
	local funcname = "OnSpellcastEvent"
	
	-- ignore events that don't originate with the player or pet
	-- TODOFUTURE: we will allow announcements for other people's spell casting
	if caster ~= "player" and caster ~= "pet" then
		--self:DebugMsg(funcname,"caster is not the player or pet")
		return
	end
	
	local PendingSent = PendingSpellcastsSent[spellname]
	local target = ""
	
	if PendingSent then
		-- the true target was known to the SENT event
		target = PendingSent.target
		
		-- check that we announced "when I start casting"
		if not PendingSent.AnnouncedStart then
			if event == "UNIT_SPELLCAST_START" then
				-- we're announcing the start, so flag it for future reference
				PendingSent.AnnouncedStart = true
			elseif event == "UNIT_SPELLCAST_FAILED" then
				-- SS 4.0.3.05 runtime test result:
				-- I found that instant casts on cooldown were announcing "when I start casting"
				-- even though they failed to cast
				-- so we should skip the START/SENT announcement on such failures
				-- from a user perspective, you never started casting (because it was on cooldown, out of range, etc)
				PendingSent.AnnouncedStart = true
			else
				-- instant casts skip from SENT to SUCCEEDED without hitting START
				-- so we haven't announced "when I start casting" yet
				-- fake it with a recursive call
				self:DebugMsg(funcname,"expected START was skipped (instant cast?) - faking it")
				self:OnSpellcastEvent("UNIT_SPELLCAST_START", caster, spellname, spellrank, spellid)
				-- fall through to proceed to the current event (succeeded, stopped, interrupted)
			end
		end
	end
	--else the target is unknown
	
--	self:DebugMsg(funcname,"(caster, spellname, spellrank, spellid)")
	self:DebugMsgDumpString("event",event)
--	self:DebugMsgDumpString("caster",caster)
	self:DebugMsgDumpString("spellname",spellname)
--	self:DebugMsgDumpString("spellrank",spellrank)
	self:DebugMsgDumpString("spellid",spellid)
	self:DebugMsgDumpString("target",target)
	
	-- setup basic information about the speech event
	local DetectedEventStub = {
		-- event descriptors
		type = event, --unless we change UNIT_SPELLCAST_START to UNIT_SPELLCAST_SENT below or add PET
		name = spellname,
		-- event-specific data for substitutions
		caster = self:PlayerNameNoRealm(caster),
		target = self:PlayerNameNoRealm(target),
		spellid = spellid,
		rank = spellrank, --NOTE: ranks are still available in WoW 4.0.3 for Polymorph, and professions
	}

	-- Don't use UNIT_SPELLCAST_START in event trigger keys
	-- we have always used SENT before for "when I start casting" events
	-- UNIT_SPELLCAST_START is now used to capture the spellid that is not included with SENT
	-- but I want it to continue using the existing event triggers that are keyed on SENT
	-- TODOFUTURE: write a patch function to change the data to use START instead of SENT'
	--		however, in the future, I'd like to stop using this 'type' as part of the key
	--		so writing that patch now would have dubious benefits, and would require updating GUI code as well
	if DetectedEventStub.type == "UNIT_SPELLCAST_START" then
		DetectedEventStub.type = "UNIT_SPELLCAST_SENT"
	end

	-- modify values for pet events	
	-- NOTE: UNIT_SPELLCAST_SUCCEEDED appears to be the only pet event that actually occurs in WoW 3.3.5
	if caster == "player" then
		--NOTE: myrealm result from UnitName("player") is always nil
		local myname, myrealm = UnitName("player")
		DetectedEventStub.caster = myname
	elseif caster == "pet" then --it's not UnitName("pet")
		DetectedEventStub.type = "PET"..event
		local petname, petrealm = UnitName("pet")
		DetectedEventStub.caster = petname
	end
	
	-- Remember the last spell ID that we saw
	-- this assists COMPANION_UPDATE
	self.RuntimeData.LastKnownSpellId = spellid
	
	-- SPEAK!
	self:OnSpeechEvent( DetectedEventStub )
end


-------------------------------------------------------------------------------
-- PLAYER DEATH, ALIVE, GHOST
-------------------------------------------------------------------------------


function SpeakinSpell:PLAYER_DEAD(event)
	local funcname = "PLAYER_DEAD"

	-- Blizzard apparently has a bug that is triggering this event multiple times
	-- so use this flag to suppress redundant PLAYER_DEAD events until PLAYER_ALIVE/PLAYER_UNGHOST
	if self.RuntimeData.dead then
		self:DebugMsg(funcname, "suppressing redundant PLAYER_DEAD event (Blizzard API bug)")
		return
	end
	self.RuntimeData.dead = true
	
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		-- event descriptors
		type = "COMBAT",
		name = L["I Died"],
		-- event-specific data for substitutions
		--caster = caster,
		target = myname,
	}
	self:OnSpeechEvent( DetectedEventStub )
end


-- Blizzard apparently has a bug that is triggering this event multiple times
-- so use this flag to suppress redundant PLAYER_DEAD events until PLAYER_ALIVE/PLAYER_UNGHOST

--[[
PLAYER_ALIVE
Fired when the player:

    * Releases from death to a graveyard.
    * Accepts a resurrect before releasing their spirit. 

Does not fire when the player is alive after being a ghost. PLAYER_UNGHOST is triggered in that case. 

PLAYER_UNGHOST
Fired when the player is alive after being a ghost. Called after one of:

    * Performing a successful corpse run and the player accepts the 'Resurrect Now' box.
    * Accepting a resurrect from another player after releasing from a death.
    * Zoning into an instance where the player is dead.
    * When the player accept a resurrect from a Spirit Healer. 

The player is alive when this event happens. Does not fire when the player is resurrected before releasing. PLAYER_ALIVE is triggered in that case. 
--]]

-- TODOFUTURE: Combat Event: I'm Alive Again
--	it's tricky because of the weird overlap

function SpeakinSpell:PLAYER_ALIVE(event)
	--NOTE: you might actually still be dead, and released to a graveyard as a ghost
	--		but the only use of this flag is to suppress redundant PLAYER_DEAD notifications
	--		which does not seem to occur after releasing to a GY, so this is adequate
	self.RuntimeData.dead = false
end

function SpeakinSpell:PLAYER_UNGHOST(event)
	self.RuntimeData.dead = false
end


---------------------------------------------------------------------------
-- ENTERING AND EXITING COMBAT
---------------------------------------------------------------------------
-- NOTE: PLAYER_ENTER_COMBAT and PLAYER_LEAVE_COMBAT are not what they sound like
--		Those 2 events are auto-attack on/off notifications
--		To detect when the combat flag goes on and off from getting/losing aggro
--		which is what we generally mean by "entering combat" and "exiting combat"
--		we must check for Regen enabled/disabled, which is our only valid notification
--		see also: http://www.wowwiki.com/Events/Combat


function SpeakinSpell:PLAYER_REGEN_DISABLED()
	local funcname = "PLAYER_REGEN_DISABLED"

	-- update combat status flags for "limit once per combat" feature
	self.RuntimeData.InCombat = true
	self:ResetOncePerCombatFlags()

	-- Signal the Entering Combat event
	self:DebugMsg(funcname, "Signal System Event: Entering Combat")
	local DetectedEventStub = {
		-- event descriptors
		name = L["Entering Combat"],
		type = "COMBAT",
		-- event-specific data for substitutions
		-- None
	}
	self:OnSpeechEvent( DetectedEventStub ) 
end


function SpeakinSpell:PLAYER_REGEN_ENABLED()
	local funcname = "PLAYER_REGEN_ENABLED"

	-- update combat status flags for "limit once per combat" feature
	self.RuntimeData.InCombat = false
	self:ResetOncePerCombatFlags()
	
	-- we can't have aggro on the current target now that we're out of combat
	-- if we deselected our target before exiting combat, the UNIT_THREAT_LIST_UPDATE won't tell us that we lost aggro
	self.RuntimeData.hasAggro = false

	-- Signal the Exiting Combat event
	self:DebugMsg(funcname, "Signal System Event: Exiting Combat")
	local DetectedEventStub = {
		-- event descriptors
		name = L["Exiting Combat"],
		type = "COMBAT",
		-- event-specific data for substitutions
		-- None
	}
	self:OnSpeechEvent( DetectedEventStub ) 
end


---------------------------------------------------------------------------
-- MOVING TO A DIFFERENT ZONE OR REGION
---------------------------------------------------------------------------


function SpeakinSpell:OnZoneChange(minoronly)
	local funcname = "OnZoneChange"

	-- Signal the zone change event
	self:DebugMsg(funcname, "Signal System Event: Zone Changed, minoronly="..tostring(minoronly))
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		-- event descriptors
		name = L["Changed Zone"],
		type = "EVENT",
		-- treat these special events as cast by the player on himself
		caster = myname,
		target = myname,
		-- event-specific data for substitutions
		-- None
	}
	
	if minoronly then
		DetectedEventStub.name = L["Changed Sub-Zone"]
	end
	
	self:OnSpeechEvent( DetectedEventStub ) 
end


--for subzone changes -- does not appear to be needed
--[[
function SpeakinSpell:MINIMAP_ZONE_CHANGED()
	local funcname = "MINIMAP_ZONE_CHANGED"
	self:DebugMsg(funcname, "entry")
	
	self:OnZoneChange(true)
end
--]]

--for subzone changes inside an instance
function SpeakinSpell:ZONE_CHANGED_INDOORS()
	local funcname = "ZONE_CHANGED_INDOORS"
	self:DebugMsg(funcname, "entry")
	
	self:OnZoneChange(true)
end

--for large scale zone changes
function SpeakinSpell:ZONE_CHANGED_NEW_AREA()
	local funcname = "ZONE_CHANGED_NEW_AREA"
	self:DebugMsg(funcname, "entry")
	
	self:OnZoneChange(false)
end

--covers both small and large scale zone changes?
function SpeakinSpell:ZONE_CHANGED()
	local funcname = "ZONE_CHANGED"
	self:DebugMsg(funcname, "entry")
	
	self:OnZoneChange(true)
end


---------------------------------------------------------------------------
-- PARSE CHAT MESSAGES
---------------------------------------------------------------------------


--[[
"CHAT_MSG_WHISPER"
	Category: Communication
  	

Fired when a whisper is received from another player.

The rest of the arguments appear to be nil

arg1 
    Message received 
arg2 
    Author 
arg3 
    Language (or nil if universal, like messages from GM) (always seems to be an empty string; argument may have been kicked because whispering in non-standard language doesn't seem to be possible [any more?]) 
arg6 
    status (like "DND" or "GM") 
arg7 
    (number) message id (for reporting spam purposes?) (default: 0) 
arg8 
    (number) unknown (default: 0) 
--]]
function SpeakinSpell:CHAT_MSG_WHISPER(event, msg, author, language, status, id, ...)
	-- Chat Event: Whispered While In-Combat
	if	self.RuntimeData.InCombat			and 
		type(author) == "string"			and
		not SpeakinSpell:NameIsMe(author)	then

		--NOTE: myrealm result from UnitName("player") is always nil
		local myname, myrealm = UnitName("player")
		local DetectedEventStub = {
			type = "CHAT",
			name = L["Whispered While In-Combat"],
			--TODO: remove realm name from author? what if you use <caster> to whisper back, how does that work?
			caster = author, -- the name of the player who whispered to you
			target = myname, -- the target of the whisper is you, the player
			-- event-specific substitution
			text = msg -- the contents of the message that was whispered to you
		}
		self:OnSpeechEvent( DetectedEventStub )
	end
	
	-- TODOFUTURE: more whisper-response based features could go here
	--	allow other people to trigger /ss commands by whispering to you, similar to auctioneer's whisper activated price lookup feature
	--	auto-advertise in response to "what addon is that?"
end


-- Whispered on Real ID should work the same as regular whispers
-- TODO: what happens when we try to auto-reply? needs experimentation/testing
function SpeakinSpell:CHAT_MSG_BN_WHISPER(event, msg, author, language, status, id, ...)
	self:CHAT_MSG_WHISPER(event, msg, author, language, status, id, ...)
end


--[[
"CHAT_MSG_GUILD"
	Category: Communication,Guild
  	
Fired when a message is sent or received in the Guild channel.

arg1 
    Message that was sent 
arg2 
    Author 
arg3 
    Language that the message was sent in 
--]]
function SpeakinSpell:CHAT_MSG_GUILD(event, message, sender, ...)
	-- "Chat Event: A Guild Member said 'ding'"
	-- match whole word, not "raiding" or other substring match
	if self:ContainsWholeWord( message, strsub(EMOTE389_CMD1,2)) then --EMOTE389_CMD1 is "/ding"
		local DetectedEventStub = {
			type = "CHAT",
			name = L[
[[A guild member said ding]]
			],
			caster = self:PlayerNameNoRealm(sender),
			target = SpeakinSpell:GetGuildName(),
		}
		self:OnSpeechEvent( DetectedEventStub )
	end
end


function SpeakinSpell:CHAT_MSG_PARTY(event, message, sender, ...)
	-- "Chat Event: A Party Member said 'ding'"
	-- match whole word, not "raiding" or other substring match
	if self:ContainsWholeWord( message, strsub(EMOTE389_CMD1,2)) then --EMOTE389_CMD1 is "/ding"
		local DetectedEventStub = {
			type = "CHAT",
			name = L[
[[A party member said ding]]
			],
			caster = self:PlayerNameNoRealm(sender),
			--target = SpeakinSpell:GetGuildName(), -- assume default target logic
		}
		self:OnSpeechEvent( DetectedEventStub )
	end
end


---------------------------------------------------------------------------
-- ANNOUNCING /FOLLOW
---------------------------------------------------------------------------

-- AUTOFOLLOW_END doesn't indicate the name of the target
-- so we store that name when we get AUTOFOLLOW_BEGIN
-- we sometimes see AUTOFOLLOW_END 3 times in a row for the same ending of auto-follow
-- so we also use the name as a flag to link one end to one begin


function SpeakinSpell:AUTOFOLLOW_BEGIN(event, unit)
--	local funcname = "AUTOFOLLOW_BEGIN"
--	self:DebugMsg(funcname, "unit:"..tostring(unit))
	
	self.RuntimeData.AutoFollowTarget = unit -- saved for AUTOFOLLOW_END
	local DetectedEventStub = {
		type = "EVENT",
		name = L["Begin /follow"],
		target = self:PlayerNameNoRealm(unit),
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:AUTOFOLLOW_END(event, ...)
--	local funcname = "AUTOFOLLOW_END"
--	self:DebugMsg(funcname, "AutoFollowTarget:"..tostring(self.RuntimeData.AutoFollowTarget))
	
	if self.RuntimeData.AutoFollowTarget then
		local DetectedEventStub = {
			type = "EVENT",
			name = L["End /follow"],
			target = self.RuntimeData.AutoFollowTarget,
		}
		self.RuntimeData.AutoFollowTarget = nil
		self:OnSpeechEvent( DetectedEventStub )
	end
end


---------------------------------------------------------------------------
-- ACHIEVEMENTS
---------------------------------------------------------------------------


function SpeakinSpell:ACHIEVEMENT_EARNED(event, AchievementID)
	local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = GetAchievementInfo( AchievementID )
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		type = "ACHIEVEMENT",
		name = COMBATLOG_FILTER_STRING_ME, -- DisplayName = "Achievement Earned by <name>"
		-- NOTE: we don't want the name of this achievement to be in the type or name of this stub, defined above, 
		--		because we want ALL differently-named achievements to share the same speech event settings
		--		so we'll use an event-specific custom data name to support substitution the name of this achievement in the speech
		achievement = Name,
		-- and the achievement link also relays the achievement name, via the standard <spelllink> substitution
		spelllink = GetAchievementLink( AchievementID ),
		-- and standard meaning for target and caster OF THE EVENT
		target = myname,
		caster = myname,
		-- and let's include (most of) the rest of the achievement info for substitutions, why not?
		points = Points,
		desc = Description,
		reward = RewardText,
	}
	-- Blizzard Bug: GetAchievementLink() returns "[Achievement]!" with an extra exclamation point
	DetectedEventStub.spelllink = string.sub(DetectedEventStub.spelllink, -1)
	self:OnSpeechEvent( DetectedEventStub )
end


--[[
from wowwiki.com, plus added comments to fill in missing details

"CHAT_MSG_ACHIEVEMENT"
	Category: Communication,Guild,Achievements
  	

Fired when a player in your vicinity completes an achievement.

arg1 (ChatMessage)
    The full body of the broadcast message. ("%s has earched the achievement [clickable link]")
arg2, arg5 (EarnedBy)
    The name of player who has just completed the achievement. 
arg7, arg8 
    Some integer. (Ris: the achievement ID???)
--]]
function SpeakinSpell:CHAT_MSG_ACHIEVEMENT(event, ChatMessage, EarnedBy, ...)
	-- don't congratulate myself (we DO get this message for our own achievements)
	if SpeakinSpell:NameIsMe(EarnedBy) then
		return
	end
	local ndx = string.find(ChatMessage, "|") -- find the clickable link in the achievement message
	local achievement = string.sub(ChatMessage, ndx, string.len(ChatMessage))
	local DetectedEventStub = {
		type = "ACHIEVEMENT",
		name = L["Someone Nearby"], -- DisplayName = "Achievement Earned by <name>"
		-- NOTE: we don't want the name of this achievement to be in the type or name of this stub, defined above, 
		--		because we want ALL differently-named achievements to share the same speech event settings
		--		so we'll use an event-specific custom data name to support substitution the name of this achievement in the speech
		--TODOFUTURE: ? parse this for the achievement name or link instead of the full chat message text ?
		--	for now, providing <achievement> and <desc> as both the complete message, for similarity to ACHIEVEMENT_EARNED
		achievement = achievement, 
		desc = achievement,
		spelllink = achievement,
		-- and standard meaning for target and caster OF THE EVENT (the player who earned the achievement)
		target = self:PlayerNameNoRealm(EarnedBy),
		caster = self:PlayerNameNoRealm(EarnedBy),
	}
	self:OnSpeechEvent( DetectedEventStub )
end


--[[
"CHAT_MSG_GUILD_ACHIEVEMENT" (same as CHAT_MSG_ACHIEVEMENT)
	Category: Communication,Guild,Achievements
  	
Fired when a guild member completes an achievement.

arg1 
    The full body of the broadcast message. 
arg2, arg5 
    The name of player who has just completed the achievement. 
arg7, arg8, arg11 
    Some integer that (but not the achievement ID, or the total number of achievement points for the player; this seems to increment if two consecutive achievements are posted (needs to be verified)). 
--]]
function SpeakinSpell:CHAT_MSG_GUILD_ACHIEVEMENT(event, ChatMessage, EarnedBy, ...)
	if SpeakinSpell:NameIsMe(EarnedBy) then -- don't congratulate myself (we DO get this message for our own achievements)
		return
	end
	local ndx = string.find(ChatMessage, "|") -- find the clickable link in the achievement message
	local achievement = string.sub(ChatMessage, ndx, string.len(ChatMessage))
	local DetectedEventStub = {
		type = "ACHIEVEMENT",
		name = L["a Guild Member"], -- DisplayName = "Achievement Earned by <name>"
		-- NOTE: we don't want the name of this achievement to be in the type or name of this stub, defined above, 
		--		because we want ALL differently-named achievements to share the same speech event settings
		--		so we'll use an event-specific custom data name to support substitution the name of this achievement in the speech
		--TODOFUTURE: ? parse this for the achievement name or link instead of the full chat message text ?
		--	for now, providing <achievement> and <desc> as both the complete message, for similarity to ACHIEVEMENT_EARNED
		achievement = achievement, 
		desc = achievement,
		spelllink = achievement,
		-- and standard meaning for target and caster OF THE EVENT (the player who earned the achievement)
		target = self:PlayerNameNoRealm(EarnedBy),
		caster = self:PlayerNameNoRealm(EarnedBy),
	}
	self:OnSpeechEvent( DetectedEventStub )
end


---------------------------------------------------------------------------
-- NPC INTERACTION
---------------------------------------------------------------------------


function SpeakinSpell:GOSSIP_SHOW()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Open Gossip Window"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:BARBER_SHOP_OPEN()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Enter Barber Chair"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:BARBER_SHOP_CLOSE()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Exit Barber Chair"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:MAIL_SHOW()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Open Mailbox"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:MERCHANT_SHOW()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Talk to Vendor"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:QUEST_GREETING()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Talk to Quest-Giver"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:TAXIMAP_OPENED()
	local DetectedEventStub = {
		type = "NPC",
		name = L["Talk to Flight Master"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:TRAINER_SHOW() -- fired for any class and profession trainers
	local DetectedEventStub = {
		type = "NPC",
		name = L["Talk to Trainer"],
	}
	self:OnSpeechEvent( DetectedEventStub )
end


---------------------------------------------------------------------------
-- SUMMONING EFFECTS
---------------------------------------------------------------------------
-- TODO: new/experimental summoning events
-- CONFIRM_SUMMON and CANCEL_SUMMON are not triggered when i attempt to summon myself without assistance

 -- I received a summon?
function SpeakinSpell:CONFIRM_SUMMON(...)
	local funcname = "CONFIRM_SUMMON"
	self:DebugMsg(funcname, "entry")
end


-- the summon I received has canceled or timed out?
function SpeakinSpell:CANCEL_SUMMON(...)
	local funcname = "CANCEL_SUMMON"
	self:DebugMsg(funcname, "entry")
end


---------------------------------------------------------------------------
-- MORE MISC. EVENTS
---------------------------------------------------------------------------

--[[
"PLAYER_LEVEL_UP"
	Category: Player
  	

Fired when a player levels up.

arg1 
    New player level. Note that UnitLevel("player") will most likely return an incorrect value when called in this event handler or shortly after, so use this value. 
arg2 
    Hit points gained from leveling. 
arg3 
    Mana points gained from leveling. 
arg4 
    Talent points gained from leveling. Should always be 1 unless the player is between levels 1 to 9. 
arg5 - arg9 
    Attribute score increases from leveling. Strength (5) / Agility (6) / Stamina (7) / Intellect (8) / Spirit (9). 
--]]
function SpeakinSpell:PLAYER_LEVEL_UP(event, ...)
	local DetectedEventStub = {
		type = "EVENT",
		name = PLAYER_LEVEL_UP,
	}
	self:OnSpeechEvent( DetectedEventStub )
end


--[[
"RESURRECT_REQUEST"
	Category: Death
  	
Fired when another player resurrects you

arg1 
    player name 
--]]
function SpeakinSpell:RESURRECT_REQUEST(event, caster)
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		type = "EVENT",
		name = L["a player sent me a rez"],
		caster = self:PlayerNameNoRealm(caster),
		target = myname,
	}
	self:OnSpeechEvent( DetectedEventStub )
end


function SpeakinSpell:TRADE_SHOW()
	local DetectedEventStub = {
		type = "EVENT",
		name = L["Open Trade Window"],
	}
	self:OnSpeechEvent( DetectedEventStub )
   
end

 function SpeakinSpell:UPDATE_MOUSEOVER_UNIT()
     print (UnitGUID("mouseover"));
 end
