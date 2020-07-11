--------------------------------------
---- Raeli's Spell Announcer Core ----
--------------------------------------
local RSA = RSA or LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local pName = UnitName("player")
local spellinfo,spelllinkinfo
local botguids = {}
local blingtronguids = {}
local molleguids = {}

function RSA:OnInitialize() -- Do all this when the addon loads.
	local _, PlayerClass = UnitClass('player')
	self.db = LibStub("AceDB-3.0"):New("RSADB", RSA.DefaultOptions, PlayerClass) -- Setup Saved Variables
	self:SetSinkStorage(self.db.profile) -- Setup Saved Variables for LibSink
	self.db.profile.General.Class = PlayerClass

	-- project-revision
	self.db.global.version = 4.0
	self.db.global.revision = string.match(GetAddOnMetadata("RSA","Version"),"%d+")
	self.db.global.releaseType = string.match(GetAddOnMetadata('RSA','Version'),'%a+',2)

	if not RSA.db.global.ID then
		RSA.db.global.ID = RSA.GetMyRandomNumber()
	end


	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, "RSA")

	self:RegisterChatCommand("RSA", "ChatCommand")
	RSA:TempOptions()

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	-- Load Reminder Module on startup if it's turned on.
	if RSA.db.profile.Modules.Reminders == true then
		--LoadAddOn("RSA_Reminders") -- Disabled for now.
	else
		RSA.db.profile.Modules.Reminders_Loaded = false
	end

	if PlayerClass == "DEATHKNIGHT" then -- Load Class Modules
		local loaded, reason = LoadAddOn("RSA_DeathKnight")
		if not loaded then
			RSA.db.profile.Modules.DeathKnight = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Death Knight " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Death Knight " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "DEMONHUNTER" then
		local loaded, reason = LoadAddOn("RSA_DemonHunter")
		if not loaded then
			RSA.db.profile.Modules.DemonHunter = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Demon Hunter " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Demon Hunter " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "DRUID" then
		local loaded, reason = LoadAddOn("RSA_Druid")
		if not loaded then
			RSA.db.profile.Modules.Druid = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Druid " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Druid " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "HUNTER" then
		local loaded, reason = LoadAddOn("RSA_Hunter")
		if not loaded then
			RSA.db.profile.Modules.Hunter = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Hunter " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Hunter " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "MAGE" then
		local loaded, reason = LoadAddOn("RSA_Mage")
		if not loaded then
			RSA.db.profile.Modules.Mage = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Mage " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Mage " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "MONK" then
		local loaded, reason = LoadAddOn("RSA_Monk")
		if not loaded then
			RSA.db.profile.Modules.Monk = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Monk " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Monk " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "PALADIN" then
		local loaded, reason = LoadAddOn("RSA_Paladin")
		if not loaded then
			RSA.db.profile.Modules.Paladin = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Paladin " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Paladin " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "PRIEST" then
		local loaded, reason = LoadAddOn("RSA_Priest")
		if not loaded then
			RSA.db.profile.Modules.Priest = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Priest " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Priest " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "ROGUE" then
		local loaded, reason = LoadAddOn("RSA_Rogue")
		if not loaded then
			RSA.db.profile.Modules.Rogue = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Rogue " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Rogue " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "SHAMAN" then
		local loaded, reason = LoadAddOn("RSA_Shaman")
		if not loaded then
			RSA.db.profile.Modules.Shaman = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Shaman " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Shaman " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "WARLOCK" then
		local loaded, reason = LoadAddOn("RSA_Warlock")
		if not loaded then
			RSA.db.profile.Modules.Warlock = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Warlock " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Warlock " .. L.OptionsMissing)
			end
		end
	elseif PlayerClass == "WARRIOR" then
		local loaded, reason = LoadAddOn("RSA_Warrior")
		if not loaded then
			RSA.db.profile.Modules.Warrior = false
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Warrior " .. L.OptionsDisabled .. L.OptionsClass)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Warrior " .. L.OptionsMissing)
			end
		end
	end

	if not self.db.profile.Fixed then
		if not IsAddOnLoaded("RSA_Options") then
			local loaded, reason = LoadAddOn("RSA_Options")
			if not loaded then
				ChatFrame1:AddMessage("|cFFFF75B3RSA|r Needs to load RSA Options to initiate a database fix. Please enable it and reload your UI. Once this fix has occured, you can disable the options again if you want. This may need to be done again if you use multiple profiles across multiple characters.")
			end
		end
	end

	RSA.Comm.Registry()
end -- End OnInitialize

function RSA.AnnouncementCheck() -- Checks against user settings to see if we are allowed to announce.
	local InInstance, InstanceType = IsInInstance()
	local LFParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) -- party group found through group finder
	local LFRaid = IsInRaid(LE_PARTY_CATEGORY_INSTANCE) -- raid grounp found through group finder
	if RSA.db.profile.General.GlobalAnnouncements.OnlyInCombat and not InCombatLockdown() then return false end -- If we're not in combat and only announce in combat, stop right here.
	if RSA.db.profile.General.GlobalAnnouncements.InWarMode and C_PvP.IsWarModeActive() and InstanceType == "none" and not LFParty and not LFRaid then return true end -- Enable in World PvP.
	if RSA.db.profile.General.GlobalAnnouncements.Arena and InstanceType == "arena" then return true end
	if RSA.db.profile.General.GlobalAnnouncements.Battlegrounds and LFRaid and (InstanceType == "pvp" or InstanceType == "none") then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InDungeon and InstanceType == "party" and not LFParty then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InRaid and InstanceType == "raid" and not LFRaid then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InScenario and InstanceType == "scenario" == true then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InLFG_Party and (InstanceType == "party" and LFParty) then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InLFG_Raid and (InstanceType == "raid" and LFRaid) then return true end
	if RSA.db.profile.General.GlobalAnnouncements.InWorld and InstanceType == "none" and not LFParty and not LFRaid and not C_PvP.IsWarModeActive() then return true end -- Enable in World PvE.
	return false
end

function RSA.String_Replace(str) -- Used for custom messages to replace text.
	return RSA.Replacements [str] or str
end

function RSA.Print_Self(message) -- Send a message to your default chat window.
	ChatFrame1:AddMessage("|cFFFF75B3RSA:|r " .. format(message))
end

function RSA.Print_LibSink(message)
	RSA:Pour("|cFFFF75B3RSA:|r " .. message, 1, 1, 1)
end

function RSA.Print_Instance(message) -- Send a message to /instance.
	if RSA.AnnouncementCheck() == false then return end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	end
end

function RSA.Print_SmartGroup(message) -- Send a message to /instance, /raid, or /party in that order of priority.
	if RSA.AnnouncementCheck() == false then return end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "RAID", nil)
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "PARTY", nil)
	end
end

function RSA.Print_Raid(message) -- Send a message to /raid or /instance. Prefers /raid if you are in an instance raid group and a home raid group.
	if RSA.AnnouncementCheck() == false then return end
	if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		if IsInRaid(LE_PARTY_CATEGORY_HOME) then
			SendChatMessage(format(message), "RAID", nil)
			return true
		else
			SendChatMessage(format(message), "INSTANCE_CHAT", nil)
			return true
		end
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "RAID", nil)
		return true
	end
end

function RSA.Print_Party(message) -- Send a message to /party or /instance. Prefers /party if you are in an instance raid group and a home raid group.
	if RSA.AnnouncementCheck() == false then return end
	if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and IsInGroup(LE_PARTY_CATEGORY_HOME) then -- In LFR, and Home Party
		SendChatMessage(format(message), "PARTY", nil)
		return true
	elseif IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then -- In LFR
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInGroup(LE_PARTY_CATEGORY_HOME) then -- In LFG, and Home Party
		SendChatMessage(format(message), "PARTY", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then -- In LFG
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "PARTY", nil)
		return true
	end
end

function RSA.Print_Channel(message, channel) -- Send a message to the custom channel that the user defines.
	if 0 == 0 then return end -- 8.2.5 Broke Sending messages to custom channels and I'm too lazy to find every instance that this is called.
	if RSA.AnnouncementCheck() == true then
		if RSA.db.profile.General.GlobalAnnouncements.SmartCustomChannel == true then
			if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
				SendChatMessage(format(message), "CHANNEL", nil, GetChannelName(channel))
			end
		elseif RSA.db.profile.General.GlobalAnnouncements.SmartCustomChannel == false then
			SendChatMessage(format(message), "CHANNEL", nil, GetChannelName(channel))
		end
	end
end

function RSA.Print_Say(message) -- Send a message to Say.
	if IsInInstance() then
		if RSA.AnnouncementCheck() == true then
			if RSA.db.profile.General.GlobalAnnouncements.SmartSay == true then
				if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
					SendChatMessage(format(message), "SAY", nil)
				end
			elseif RSA.db.profile.General.GlobalAnnouncements.SmartSay == false then
				SendChatMessage(format(message), "SAY", nil)
			end
		end
	end
end

function RSA.Print_Emote(message) -- Send a message to Emote.
	if RSA.AnnouncementCheck() == true then
		if RSA.db.profile.General.GlobalAnnouncements.SmartEmote == true then
			if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
				SendChatMessage(format(message), "EMOTE", nil)
			end
		elseif RSA.db.profile.General.GlobalAnnouncements.SmartEmote == false then
			SendChatMessage(format(message), "EMOTE", nil)
		end
	end
end

function RSA.Print_Yell(message) -- Send a message to Yell.
	if IsInInstance() then
		if RSA.AnnouncementCheck() == true then
			if RSA.db.profile.General.GlobalAnnouncements.SmartYell == true then
				if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
					SendChatMessage(format(message), "YELL", nil)
				end
			elseif RSA.db.profile.General.GlobalAnnouncements.SmartYell == false then
				SendChatMessage(format(message), "YELL", nil)
			end
		end
	end
end

function RSA.Print_Self_RW(message) -- Send a message locally to the raid warning frame. Only visible to the user.
	local RWColor = {r=1, g=1, b=1}
	RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF75B3RSA:|r " .. format(message), RWColor)
end

function RSA.Print_RW(message) -- Send a proper message to the raid warning frame.
	if RSA.AnnouncementCheck() == true then
		SendChatMessage(format(message), "RAID_WARNING", nil)
	end
end

function RSA.Print_Whisper(message, target, replacements, destName)
	if RSA.db.profile.General.GlobalAnnouncements.AlwaysAllowWhispers == false then
		if RSA.AnnouncementCheck() == false then return end
	end
	if replacements and destName then -- Until we replace all instances where this function is used, check if we have all args before trying to create new format message.
		if RSA.db.profile.General.Replacements.Target.AlwaysUseName == true then
			replacements["[TARGET]"] = destName
		else
			replacements["[TARGET]"] = RSA.db.profile.General.Replacements.Target.Replacement
		end
		local tosend = gsub(message, ".%a+.", replacements)
		SendChatMessage(format(tosend), "WHISPER", nil, target)
	else
		SendChatMessage(format(message), "WHISPER", nil, target)
	end

	-- Return to original value after whispering, so any subsequent messages for the same event use the correct value.
	replacements["[TARGET]"] = destName
end

local bor,band = bit.bor, bit.band -- get a local reference to some bitlib functions for faster lookups
local CL_OBJECT_FRIENDLY_PLAYER = bor(COMBATLOG_OBJECT_TYPE_PLAYER,COMBATLOG_OBJECT_REACTION_FRIENDLY) -- construct a friendly player bitmask
function RSA.Whisperable(destFlags) -- Checks if the unit is a player or not. Since RSA can announce casts for any unit, not just units that fall under UnitID.

	--When we send a fake event through the announcement monitor, ingnore flags.
	if destFlags == true then return true end
	if destFlags == false then return false end


	if band(CL_OBJECT_FRIENDLY_PLAYER,destFlags) == CL_OBJECT_FRIENDLY_PLAYER and not RSA.IsMe(destFlags) then -- check if players in vehicle need special handling
		return true
	end
end

function RSA.AffiliationMine(sourceFlags)
if not sourceFlags then return end
	if band(COMBATLOG_OBJECT_AFFILIATION_MINE,sourceFlags) == COMBATLOG_OBJECT_AFFILIATION_MINE then
		return true
	end
end

function RSA.AffiliationGroup(sourceFlags)
	if not sourceFlags then return end
	if band(COMBATLOG_OBJECT_AFFILIATION_MINE,sourceFlags) == COMBATLOG_OBJECT_AFFILIATION_MINE then
		return true
	end
	if band(COMBATLOG_OBJECT_AFFILIATION_PARTY,sourceFlags) == COMBATLOG_OBJECT_AFFILIATION_PARTY then
		return true
	end
	if band(COMBATLOG_OBJECT_AFFILIATION_RAID,sourceFlags) == COMBATLOG_OBJECT_AFFILIATION_RAID then
		return true
	end
end

local CL_OBJECT_PLAYER_MINE = bor(COMBATLOG_OBJECT_TYPE_PLAYER,COMBATLOG_OBJECT_AFFILIATION_MINE) -- construct a bitmask for a player controlled by me
function RSA.IsMe(unitFlags)
	if unitFlags == "Me" then return true end
	if unitFlags == true then return true end
	if unitFlags == false then return false end
	if band(CL_OBJECT_PLAYER_MINE,unitFlags) == CL_OBJECT_PLAYER_MINE then
		return true
	end
end

function RSA.RemoveServerNames(destName)
	local full_destName
	local a,b = UnitName(destName)
	if b == nil or b == "" then
		full_destName = destName
	else
		full_destName = a .. "-" .. b
	end
	if RSA.db.profile.General.GlobalAnnouncements.RemoveServerNames == true then
		if destName then
			destName = gsub(destName, "-.*", "")
		end
	end
	return full_destName,destName
end

function RSA.Talents() -- Detects which talent tree a user has primarily.
	if not GetSpecializationInfo( 1 ) then
		return -- Talents aren't loaded yet!
	end
	local specID = GetSpecialization()
	if specID then
		return specID
	end
end

function RSA.GetMyRandomNumber()
	local random = math.random(1,time())
	local namebytes = 0
	for i = 1,string.len(UnitName("player")) do
		namebytes = namebytes + string.byte(UnitName("player"),i)
	end
	random = tostring(random) .. tostring(namebytes)
	return random
end

function RSA.GetMobID(mobGUID) -- extracts the mob ID from the GUID
	--[Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[Spawn UID] (Example: "Creature-0-1461-1158-1458-61146-000136DF91")
	local _, _, _, _, _, _, _, mob_id = string.find(mobGUID, "(%a+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
	return tonumber(mob_id)
end

-- Global Frames and Event Registers
RSA.CombatLogMonitor = CreateFrame("Frame", "RSA:CLM")
RSA.CombatLogMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
