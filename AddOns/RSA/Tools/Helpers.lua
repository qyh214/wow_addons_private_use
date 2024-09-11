local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local uClass = string.lower(select(2, UnitClass('player')))

local function CombatState()
	local profile = RSA.db.profile.general.globalAnnouncements.combatState
	if InCombatLockdown() then
		if profile.inCombat then
			return true
		end
	else
		if profile.noCombat then
			return true
		end
	end

	return false
end

function RSA.AnnouncementCheck() -- Checks against user settings to see if we are allowed to announce.
	local _, InstanceType = IsInInstance()
	local LFParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) -- party group found through group finder
	local LFRaid = IsInRaid(LE_PARTY_CATEGORY_INSTANCE) -- raid grounp found through group finder

	local profile = RSA.db.profile.general.globalAnnouncements

	if not CombatState() then return false end
	if RSA.IsRetail() then
		if profile.warModeWorld and C_PvP.IsWarModeDesired() and InstanceType == 'none' and not LFParty and not LFRaid then return true end -- Enable in World PvP.
		if profile.nonWarWorld and InstanceType == 'none' and not LFParty and not LFRaid and not C_PvP.IsWarModeDesired() then return true end -- Enable in World PvE.
	else
		if profile.warModeWorld and GetPVPDesired() and InstanceType == 'none' and not LFParty and not LFRaid then return true end
		if profile.nonWarWorld and InstanceType == 'none' and not LFParty and not LFRaid and not GetPVPDesired() then return true end
	end
	if profile.arenas and InstanceType == 'arena' then return true end
	if profile.bgs and LFRaid and (InstanceType == 'pvp' or InstanceType == 'none') then return true end
	if profile.dungeons and InstanceType == 'party' and not LFParty then return true end
	if profile.raids and InstanceType == 'raid' and not LFRaid then return true end
	if profile.scenarios and InstanceType == 'scenario' == true then return true end
	if profile.lfg and (InstanceType == 'party' and LFParty) then return true end
	if profile.lfr and (InstanceType == 'raid' and LFRaid) then return true end

	return false
end

function RSA.GetPersonalID()
	local nameBytes = 0
	for i = 1,string.len(UnitName('player')) do
		nameBytes = nameBytes + string.byte(UnitName('player'),i)
	end
	local random = tostring(random) .. tostring(nameBytes)
	return random
end

function RSA.GetMobID(mobGUID) -- extracts the mob ID from the GUID
	--[Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[Spawn UID] (Example: 'Creature-0-1461-1158-1458-61146-000136DF91')
	local _, _, _, _, _, _, _, mob_id = string.find(mobGUID, '(%a+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)')
	return tonumber(mob_id)
end

local bor,band = bit.bor, bit.band -- get a local reference to some bitlib functions for faster lookups
local CL_OBJECT_PLAYER_MINE = bor(COMBATLOG_OBJECT_TYPE_PLAYER,COMBATLOG_OBJECT_AFFILIATION_MINE) -- construct a bitmask for a player controlled by me
function RSA.IsMe(unitFlags)
	if unitFlags == 'Me' then return true end
	if unitFlags == true then return true end
	if unitFlags == false then return false end
	if band(CL_OBJECT_PLAYER_MINE,unitFlags) == CL_OBJECT_PLAYER_MINE then
		return true
	end
end

local CL_OBJECT_FRIENDLY_PLAYER = bor(COMBATLOG_OBJECT_TYPE_PLAYER,COMBATLOG_OBJECT_REACTION_FRIENDLY) -- construct a friendly player bitmask
function RSA.Whisperable(destFlags) -- Checks if the unit is a player or not. Since RSA can announce casts for any unit, not just units that fall under UnitID.
	--When we send a fake event through the announcement monitor, ignore flags.
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

function RSA.DescTableBuilder(...)
	local argTable = {}
	local iterator = 0
	for i = 1, select('#',...) do
		local id = select(i,...)
		if RSA.Helpers.GetSpellInfo(id) ~= '' and RSA.Helpers.GetSpellInfo(id) ~= nil then
			iterator = iterator + 1
			argTable[iterator] = '|cffFFCC00' .. RSA.Helpers.GetSpellInfo(id).name .. ':|r '
			iterator = iterator + 1
			argTable[iterator] = '|cffd1d1d1' .. RSA.Helpers.GetSpellDescription(id) .. '|r\n\n'
		end
	end
	--string.gsub(argTable[#argTable], '[\n]', '')
	return table.concat(argTable)
end

function RSA.Helpers.GetSpellInfo(id)
	local spellInfo
	if GetSpellInfo then
		local spell = {GetSpellInfo(id)}
		spellInfo = {
			name = spell[1],
			spellID = id,
		}
	else
		spellInfo = C_Spell and C_Spell.GetSpellInfo(id)
	end
	if spellInfo then
		return spellInfo
	else
		return {name = '',
	spellID = ''}
	end
end

function RSA.Helpers.GetSpellDescription(id)
	local spellDescription
	if GetSpellDescription then
		spellDescription = GetSpellDescription(id)
	else
		spellDescription = C_Spell and C_Spell.GetSpellDescription(id)
	end

	if spellDescription then
		return spellDescription
	else
		return ''
	end
end

local firstRun
function RSA.PrepareDataTables(configData, sectionName)
	-- Ensure barebones config data is properly populated and also reverse link all spellIDs used in a profile to that profile
	-- so that the Monitor can easily check if a spellID is used in a profile, rather than having to iterate through each profile's event data.
	-- Why not store the profile in this manner by default? It's more human readable to have everything needed for a spell to function within
	-- one table, rather than having multiple references to the profile in separate event tables as RSA used to do.
	local monitorData = {}

	--/dump LibStub('AceAddon-3.0'):GetAddon('RSA').monitorData
	for profile in pairs(configData) do
		if not profile then return end

		if sectionName and not configData[profile].spellID then -- When changing a default spell, update profile name, this removes old data.
			RSA.db.profile[sectionName][profile] = nil
			return
		end
		if not monitorData[configData[profile].spellID] then

			monitorData[configData[profile].spellID] = {[profile] = true,}
		else
			monitorData[configData[profile].spellID][profile] = true
		end

		if configData[profile].additionalSpellIDs then -- Add the additional spell variants to the list of spellIDs for the monitor to... monitor.
			for k in pairs(configData[profile].additionalSpellIDs) do
				if configData[profile].additionalSpellIDs[k] then
					if not monitorData[k] then
						monitorData[k] = {[profile] = true,}
					else
						monitorData[k][profile] = true
					end
				end
			end
		else
			configData[profile].additionalSpellIDs = {}
		end

		if not configData[profile].environments then
			configData[profile].environments = {
				useGlobal = true, -- This spell will use the global envrionment settings to determine where it can announce, this overrides the other values in this section.
				alwaysWhisper = false, -- Allows whispers to always be sent.
				enableIn = {
					arenas = false,
					bgs = false,
					warModeWorld = false, -- Enable in War Mode world zones.
					nonWarWorld = false, -- Enable in world zones without war mode enabled.
					dungeons = false,
					raids = false,
					lfg = false,
					lfr = false,
					scenarios = false,
				},
				groupToggles = { -- When true, only announce to these channels if you are in a group
					emote = true,
					say = true,
					yell = true,
					whisper = true,
				},
				combatState = {
					inCombat = true, -- Announce only in Combat
					noCombat = false, -- Announce not in Combat
				},
			}
		else
			local environments = {
				useGlobal = true, -- This spell will use the global envrionment settings to determine where it can announce, this overrides the other values in this section.
				alwaysWhisper = false, -- Allows whispers to always be sent.
				enableIn = {
					arenas = false,
					bgs = false,
					warModeWorld = false, -- Enable in War Mode world zones.
					nonWarWorld = false, -- Enable in world zones without war mode enabled.
					dungeons = false,
					raids = false,
					lfg = false,
					lfr = false,
					scenarios = false,
				},
				groupToggles = { -- When true, only announce to these channels if you are in a group
					emote = true,
					say = true,
					yell = true,
					whisper = true,
				},
				combatState = {
					inCombat = true, -- Announce only in Combat
					noCombat = false, -- Announce not in Combat
				},
			}
			for k in pairs(environments) do
				if not configData[profile].environments[k] then
					configData[profile].environments[k] = environments[k]
				elseif type(environments[k]) == 'table' then
					for i = 1, #configData[profile].environments[k] do
						if not configData[profile].environments[k][i] then
							configData[profile].environments[k][i] = environments[k][i]
						end
					end
				end
			end
		end

		for k in pairs(configData[profile].events) do
			if not configData[profile].configDisplay then
				configData[profile].configDisplay = {}
			end
			if not configData[profile].configDisplay.disabledChannels then
				configData[profile].configDisplay.disabledChannels = {}
			end

			if not configData[profile].configDisplay.messageAreas then
				configData[profile].configDisplay.messageAreas = {}
			end
			configData[profile].configDisplay.messageAreas[k] = k

			if configData[profile].configDisplay.configLocked == false then -- Re-lock any unlocked default spells when we reload.
				if not firstRun then
					firstRun = true
					configData[profile].configDisplay.configLocked = true
				end
			end

			if configData[profile].events[k].uniqueSpellID then -- Add uniqueSpellID for a specific event (i.e where SPELL_CAST_SUCCESS and SPELL_HEAL use different IDs) so that they are both tracked by the monitor.
				if not monitorData[configData[profile].events[k].uniqueSpellID] then
					monitorData[configData[profile].events[k].uniqueSpellID] = {[profile] = true,}
				else
					monitorData[configData[profile].events[k].uniqueSpellID][profile] = true
				end
			end

			if not configData[profile].events[k].channels then
				configData[profile].events[k].channels = {}
			end

			if not configData[profile].events[k].tags then
				configData[profile].events[k].tags = {}
			end

			if not configData[profile].events[k].messages then
				configData[profile].events[k].messages = {}
			end
		end
	end

	-- Reorganise spell profiles in monitorData to indexed tables for easier iteration in the Monitor.
	for k in pairs(monitorData) do
		local spells = {}
		local count = 0
		for c in pairs(monitorData[k]) do
			count = count + 1
			spells[count] = c
		end
			monitorData[k] = spells
	end

	return monitorData, configData
end

function RSA.RefreshMonitorData(section)
	if RSA.monitorData[section] then
		RSA.monitorData[section] = RSA.PrepareDataTables(RSA.db.profile[section], true)
	else
		RSA.SendMessage.ChatFrame(L['Unexpected Data Table'])
	end
end

function RSA.CopyTable(source)
	local sourceType = type(source)
	local copy
	if sourceType == 'table' then
		copy = {}
		for sourceKey, sourceVal in next, source, nil do
			copy[RSA.CopyTable(sourceKey)] = RSA.CopyTable(sourceVal)
		end
		setmetatable(copy, RSA.CopyTable(getmetatable(source)))
	else
		copy = source
	end
	return copy
end