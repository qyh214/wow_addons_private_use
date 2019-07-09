local RSA =  RSA or LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")

local gsub = string.gsub
local racialConfig, utilityConfig, config, playerGUID
local cache_SpellInfo = {}
local cache_SpellLink = {}
local message_cache = {}
local missTypes = {
	"ABSORB",
	"BLOCK",
	"DEFLECT",
	"DODGE",
	"EVADE",
	"IMMUNE",
	"MISS",
	"PARRY",
	"REFLECT",
	"RESIST",
}

local function MonitorConfig(new_config, new_playerGUID)
	config = new_config
	playerGUID = new_playerGUID
end

local function UtilityMonitorConfig(new_config, new_playerGUID)
	utilityConfig = new_config
	playerGUID = new_playerGUID
end

local function RacialMonitorConfig(new_config, new_playerGUID)
	racialConfig = new_config
	playerGUID = new_playerGUID
end

local empty = {}
local replacements = {}
local running = {}

local function WipeCache()
	wipe(cache_SpellInfo)
	wipe(cache_SpellLink)
end

local function WipeMessageCache()
	wipe(message_cache)
end

local function MonitorAndAnnounce(self, configType, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
	local extraSpellID, extraSpellName, extraSchool = ex1, ex2, ex3
	local missType = ex1

	local event_data = nil
	if configType then
		if configType == "player" then
			event_data = config[event]
		elseif configType == "utilities" then
			event_data = utilityConfig[event]
		elseif configType == "racials" then
			event_data = racialConfig[event]
		else return
		end
	end
	if event_data == nil then return end

	local spell_data = event_data[spellID]
	if event == 'SPELL_DISPEL' or event == 'SPELL_STOLEN' then
		if not spell_data then
			spellID, extraSpellID = extraSpellID, spellID
			spellName, extraSpellName = extraSpellName, spellName
			spellSchool, extraSchool = extraSchool, spellSchool
			spell_data = event_data[spellID]
		end
	end
	if not spell_data then return end

	if spell_data.targetIsMe and not RSA.IsMe(destFlags) then return end
	if spell_data.targetNotMe and RSA.IsMe(destFlags) then return end
	if spell_data.sourceIsMe and not RSA.IsMe(sourceFlags) then return end
	if false --[[detect player/pet]] then return end

	local spell_profile = nil
	if (not configType) or (configType == "player") then
		spell_profile = config.player_profile.Spells[spell_data.profile]
	elseif configType == "utilities" then
		spell_profile = utilityConfig.player_profile.Spells[spell_data.profile]
	elseif configType == "racials" then
		spell_profile = racialConfig.player_profile.Spells[spell_data.profile]
	end
	if spell_profile == nil then return end

	-- Track group announced spells using RSA.Comm (AddonMessages)
	local CommCanAnnounce = true
	if spell_data.comm then
		if RSA.Comm.GroupAnnouncer then
			CommCanAnnounce = true
			if RSA.Comm.GroupAnnouncer == tonumber(RSA.db.global.ID) then -- This is us, continue as normal.
				CommCanAnnounce = true
			else -- Someone else is announcing.
				CommCanAnnounce = false
			end
		else -- No Group, continue as normal.
			CommCanAnnounce = true
		end
	end

	-- Track multiple occurences of the same spell to more accurately detect it's real end point.
	local spell_tracker = spell_data.profile
	local tracker = spell_data.tracker or -1	-- Tracks spells like AoE Taunts to prevent multiple messages playing.
	if tracker == 1 and running[spell_tracker] == nil then return end -- Prevent announcement if we didn't start the tracker (i.e Tank Metamorphosis random procs from Artifact)
	if tracker == 1 and running[spell_tracker] >= 500 then return end -- Prevent multiple announcements of buff/debuff removal.
	if tracker == 2 then
		if running[spell_tracker] ~= nil then
			if running[spell_tracker] >= 0 and running[spell_tracker] < 500 then -- Prevent multiple announcements of buff/debuff application.				
				running[spell_tracker] = running[spell_tracker] + 1
				return 
			end
		end		
		running[spell_tracker] = 0
	end	
	if tracker == 1 and running[spell_tracker] == 0 then
		running[spell_tracker] = running[spell_tracker] + 500
	end
	if tracker == 1 and running[spell_tracker] > 0 and running[spell_tracker] < 500 then
		running[spell_tracker] = running[spell_tracker] - 1
		return 
	end

	-- Build Cache of valid messages
	-- We store empty strings when users blank a default message so we know not to use the default. An empty string can also be stored when a user deletes extra messages.
	-- We need to validate the list of messages so when we pick a message at random, we don't accidentally pick the blanked message.
	local message_cache_profile = message_cache[spell_data.profile]
	if not message_cache_profile then
		message_cache_profile = {}
		message_cache[spell_data.profile] = {}
	end
	local ValidMessages = message_cache_profile[spell_data.section or 'Start']
	if not ValidMessages then
		ValidMessages = {}
		for i = 1,#spell_profile.Messages[spell_data.section or 'Start'] do
			if spell_profile.Messages[spell_data.section or 'Start'][i] ~= "" then
				ValidMessages[i] = spell_profile.Messages[spell_data.section or 'Start'][i]
			end
		end
		message_cache[spell_data.profile][spell_data.section or 'Start'] = ValidMessages
	end
	if #ValidMessages == 0 then return end
	local message = ValidMessages[math.random(#ValidMessages)]
	if not message then return end
	message = gsub(message,"%%","%%%%")

	-- Build Spell Name and Link Cache
	if spell_data.linkID ~= nil then
		local spellinfo = GetSpellInfo(spell_data.linkID)
		cache_SpellInfo[spellID] = spellinfo 
		
		local spelllink = GetSpellLink(spell_data.linkID)
		cache_SpellLink[spellID] = spelllink 	
	end	
	local spellinfo = cache_SpellInfo[spellID]	
	if not spellinfo then 
		if not spell_data.linkID then
			spellinfo = GetSpellInfo(spellID)
			cache_SpellInfo[spellID] = spellinfo
		else
			spellinfo = GetSpellInfo(spell_data.linkID)
			cache_SpellInfo[spellID] = spellinfo 
		end	
	end	
	local spelllink = cache_SpellLink[spellID]
	if not spelllink then
		if not spell_data.linkID then
			spelllink = GetSpellLink(spellID)
			cache_SpellLink[spellID] = spelllink
		else
			spelllink = GetSpellLink(spell_data.linkID)
			cache_SpellLink[spellID] = spelllink 
		end
	end

	-- Trim Server Names
	local full_destName = destName
	if RSA.db.profile.General.GlobalAnnouncements.RemoveServerNames == true then
		if destName and destGUID then
			local realmName = select(7,GetPlayerInfoByGUID(destGUID))
			if realmName then
					destName = gsub(destName, "-"..realmName, "")
			end
		end
	end

	-- Build Tag replacements
	wipe(replacements)
	replacements["[SPELL]"] = spellinfo
	replacements["[LINK]"] = spelllink
	local spell_replacements = spell_data.replacements or empty
	if spell_replacements.TARGET then replacements["[TARGET]"] = destName end
	if spell_replacements.SOURCE then replacements["[TARGET]"] = sourceName end
	if spell_replacements.AMOUNT then replacements["[AMOUNT]"] = ex1 end
	local extraSpellNameTarget = spell_replacements.extraSpellName
	if extraSpellNameTarget then
		local spellinfo = cache_SpellInfo[extraSpellID] if not spellinfo then spellinfo = GetSpellInfo(extraSpellID) cache_SpellInfo[extraSpellID] = spellinfo end
		replacements[extraSpellNameTarget] = spellinfo
	end
	local extraSpellLinkTarget = spell_replacements.extraSpellLink
	if extraSpellLinkTarget then
		local spelllink = cache_SpellLink[extraSpellID] if not spelllink then spelllink = GetSpellLink(extraSpellID) cache_SpellLink[extraSpellID] = spelllink end
		replacements[extraSpellLinkTarget] = spelllink
	end
	if spell_replacements.MISSTYPE then
		if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
			for i = 1,#missTypes do
				if missType == missTypes[i] then
					replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.GeneralReplacement
				end
			end
		else
			if missType == "IMMUNE" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Immune
				if spell_profile.Messages[spell_data.immuneSection] then
					local ValidMessages = message_cache_profile[spell_data.immuneSection]
					if not ValidMessages then
						ValidMessages = {}
						for i = 1,#spell_profile.Messages[spell_data.immuneSection] do
							if spell_profile.Messages[spell_data.immuneSection][i] ~= "" then
								ValidMessages[i] = spell_profile.Messages[spell_data.immuneSection][i]
							end
						end
						message_cache[spell_data.profile][spell_data.immuneSection] = ValidMessages
					end
					if #ValidMessages == 0 then return end
					message = ValidMessages[math.random(#ValidMessages)]
					if not message then return end
				end
			elseif missType == "MISS" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Miss
			elseif missType == "RESIST" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Resist
			elseif missType == "ABSORB" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Absorb
			elseif missType == "BLOCK" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Block
			elseif missType == "DEFLECT" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Deflect
			elseif missType == "DODGE" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Dodge
			elseif missType == "EVADE" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Evade
			elseif missType == "PARRY" then
				replacements["[MISSTYPE]"] = RSA.db.profile.General.Replacements.MissType.Parry
			end
		end
	end

	if spell_profile.Local == true then
		if spell_data.groupRequired == true then
			if not (GetNumSubgroupMembers() > 0 or GetNumGroupMembers() > 0) then return end				
		end
		RSA.Print_LibSink(gsub(message, ".%a+.", replacements))
	end
	if CommCanAnnounce == false then return end
	if spell_profile.Yell == true then
		RSA.Print_Yell(gsub(message, ".%a+.", replacements))
	end
	if spell_profile.Whisper == true and UnitExists(full_destName) and RSA.Whisperable(destFlags) then
		RSA.Print_Whisper(message, full_destName, replacements, destName)
	end
	if spell_profile.CustomChannel and spell_profile.CustomChannel.Enabled == true then
		RSA.Print_Channel(gsub(message, ".%a+.", replacements), spell_profile.CustomChannel.Channel)
	end
	if spell_profile.Say == true then
		RSA.Print_Say(gsub(message, ".%a+.", replacements))			
	end
	if spell_profile.Emote == true then
		RSA.Print_Emote(gsub(message, ".%a+.", replacements))			
	end
	local Announced = false
	if spell_profile.Party == true then
		if RSA.Print_Party(gsub(message, ".%a+.", replacements)) == true then Announced = true end
	end
	if spell_profile.Raid == true then
		if RSA.Print_Raid(gsub(message, ".%a+.", replacements)) == true then Announced = true end
	end
	if spell_profile.Instance == true then
		if RSA.Print_Instance(gsub(message, ".%a+.", replacements)) == true then Announced = true end
	end
	if spell_profile.SmartGroup == true then
		if Announced == false then
			RSA.Print_SmartGroup(gsub(message, ".%a+.", replacements))
		end
	end
	if spell_profile.BossBars == true then
		RSA.BossBars(gsub(message, ".%a+.", replacements))
	end

end

RSA.MonitorConfig = MonitorConfig
RSA.UtilityMonitorConfig = UtilityMonitorConfig
RSA.RacialMonitorConfig = RacialMonitorConfig
RSA.MonitorAndAnnounce = MonitorAndAnnounce
RSA.WipeCache = WipeCache
RSA.WipeMessageCache = WipeMessageCache
