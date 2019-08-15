------------------------------------------------
---- Raeli's Spell Announcer Utility Spells ----
------------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Utilities = RSA:NewModule('Utilities')

local MonitorConfig_Utilities

local EngineerRessBFA_Target = nil

function RSA_Utilities:OnInitialize()
	RSA_Utilities.CombatLogMonitor = CreateFrame('Frame', 'RSA_Utilities:CLM')
	RSA_Utilities.CombatLogMonitor:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

function RSA_Utilities:OnEnable()
	RSA.db.profile.Modules.Utilities = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	--[[
	-- Template
	local configRepairBots = { -- Repair Bots
		profile = 'Jeeves',
		comm = true, -- If we only want one person in the group to announce this.
		sourceIsMe = true, -- For personal utility spells like Rocket Boots, Trinkets etc.
		replacements = { SOURCE = 1 }
	}
	]]--
	local configRepairBots = {
		profile = 'Jeeves',
		section = 'Placed',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local configFeasts = {
		profile = 'Feasts',
		section = 'Placed',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local configDrums = {
		profile = 'Drums',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local configCauldrons = {
		profile = 'Cauldrons',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local configSleepPotionsStart = {
		profile = 'SleepPotions',
		comm = false,
		sourceIsMe = true,
	}
	local configSleepPotionsEnd = {
		profile = 'SleepPotions',
		section = 'End',
		comm = false,
		sourceIsMe = true,
	}
	local configCodex = {
		profile = 'Codex',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	MonitorConfig_Utilities = {
		player_profile = RSA.db.profile.Utilities,
		SPELL_AURA_APPLIED = {
			[252753] = configSleepPotionsStart, -- Potion of Replenishment (8.0)
			[298157] = configSleepPotionsStart, -- Potion of Reconstitution (8.2)
		},
		SPELL_AURA_REMOVED = {
			[252753] = configSleepPotionsEnd, -- Potion of Replenishment (8.0)
			[298157] = configSleepPotionsEnd, -- Potion of Reconstitution (8.2)
		},
		SPELL_RESURRECT = {
			[265116] = {
				profile = 'EngineerRessBFA',
				section = 'Cast',
				sourceIsMe = true,
				replacements = { TARGET = 1 }
			},
		},
		SPELL_SUMMON = {
			[22700] = configRepairBots, -- Field Repair Bot 74A
			[44389] = configRepairBots, -- Field Repair Bot 110G
			[54711] = configRepairBots, -- Scrapbot (Northrend Engineering)
			[67826] = configRepairBots, -- Jeeves
			[157066] = configRepairBots, -- Walter (WoD Engineer Workshop)
			[199109] = configRepairBots, -- Auto-Hammer
		},
		SPELL_CAST_START = {
			[92649] = configCauldrons, -- Cauldron of Battle (Cata)
			[92712] = configCauldrons, -- Big Cauldron of Battle (Cata)
			[188036] = configCauldrons, -- Spirit Cauldron (Legion)
			[276972] = configCauldrons, -- Mystical Cauldron (BfA)
			[298861] = configCauldrons, -- Greater Mystical Cauldron (8.2)
		},
		SPELL_CAST_SUCCESS = {
			[200205] = configRepairBots, -- Reaves Auto-Hammer mode
			[57301] = configFeasts, -- Great Feast (WotLK)
			[57426] = configFeasts, -- Fish Feast (WotLK)
			[58465] = configFeasts, -- Gigantic Feast (WotLK)
			[58474] = configFeasts, -- Small Feast (WotLK)
			[87643] = configFeasts, -- Broiled Dragon Feast (Cata)
			[87915] = configFeasts, -- Goblin Barbecue Feast (Cata)
			[87644] = configFeasts, -- Seafood Magnifique Feast (Cata)
			[104958] = configFeasts, -- Pandaren Banquet
			[105193] = configFeasts, -- Great Pandaren Banquet Feast
			[126492] = configFeasts, -- Banquet of the Grill
			[126494] = configFeasts, -- Great Banquet of the Grill
			[126495] = configFeasts, -- Banquet of the Wok
			[126496] = configFeasts, -- Great Banquet of the Wok
			[126497] = configFeasts, -- Banquet of the Pot
			[126498] = configFeasts, -- Great Banquet of the Pot
			[126499] = configFeasts, -- Banquet of the Steamer
			[126500] = configFeasts, -- Great Banquet of the Steamer
			[126501] = configFeasts, -- Banquet of the Oven
			[126502] = configFeasts, -- Great Banquet of the Oven
			[126503] = configFeasts, -- Banquet of the Brew
			[126504] = configFeasts, -- Great Banquet of the Brew
			[145166] = configFeasts, -- Noodle Cart
			[145169] = configFeasts, -- Deluxe Noodle Cart
			[145196] = configFeasts, -- Pandaren Treasure Noodle Cart
			[160914] = configFeasts, -- Feast of the Waters (WoD)
			[160740] = configFeasts, -- Feast of Blood (WoD)
			[175215] = configFeasts, -- Savage Feast (WoD)
			[185706] = configFeasts, -- Fancy Darkmoon Feast (Darkmoon Faire)
			[185709] = configFeasts, -- Sugar-Crusted Fish Feast (Darkmoon Faire)
			[201351] = configFeasts, -- Hearty Feast (Legion)
			[201352] = configFeasts, -- Lavish Suramar Feast (Legion)
			[251254] = configFeasts, -- Feast of the Fishes (Legion)
			[259409] = configFeasts, -- Gallery Banquet (BfA)
			[259410] = configFeasts, -- Bountiful Captain's Feast (BfA)
			[286050] = configFeasts, -- Sanguinated Feast (BfA)
			[297048] = configFeasts, -- Famine Evaluator And Snack Table (8.2)
			[178207] = configDrums, -- Drums of Fury (WoD)
			[230935] = configDrums, -- Drums of the Mountain (Legion)
			[256740] = configDrums, -- Drums of the Maelstrom (BfA)
		},
		UNIT_ACCEPTED_RESURRECT = { -- Fake event for resurrect tracking.
			[265116] = {
				profile = 'EngineerRessBFA',
				section = 'AcceptedRess',
				sourceIsMe = true,
				replacements = { TARGET = 1 }
			},
		},
		UNIT_SPELLCAST_SUCCEEDED = {
			[256230] = configCodex,
			[226241] = configCodex,
			[227564] = configCodex,
		},
	}

	RSA.UtilityMonitorConfig(MonitorConfig_Utilities, UnitGUID('player'))

	local function Spells(_,event,arg1,arg2,arg3)
		if RSA.db.profile.Modules.Utilities == false then return end
		if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
			local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
			if RSA.AffiliationGroup(sourceFlags) then
				if event == 'SPELL_RESURRECT' then
					if spellID == 265116 and RSA.AffiliationMine(sourceFlags) then
						EngineerRessBFA_Target = dest
						RSA_Utilities.CombatLogMonitor:RegisterEvent('UNIT_HEALTH')


						C_Timer.After(60, function() -- Resurrects run out after 60 seconds
							EngineerRessBFA_Target = nil
							RSA_Utilities.CombatLogMonitor:UnregisterEvent('UNIT_HEALTH')
						end)

					elseif EngineerRessBFA_Target then -- User cancelled my ress and someone else also sent a ress.
						if dest == EngineerRessBFA_Target then
							EngineerRessBFA_Target = nil
							RSA_Utilities.CombatLogMonitor:UnregisterEvent('UNIT_HEALTH')
						end
					end
				end
				RSA.MonitorAndAnnounce(self, 'utilities', timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
			end
		elseif event == 'UNIT_HEALTH' then
			-- We can't track when another unit comes back to life, other than watching their health.
			-- When their health changes, we stop tracking, reset everything and send a fake event to the Announcement Monitor for processing.
			if not EngineerRessBFA_Target then return end
			if UnitName(arg1) == EngineerRessBFA_Target then
				if UnitHealth(arg1) > 0 then
					EngineerRessBFA_Target = nil
					RSA_Utilities.CombatLogMonitor:UnregisterEvent('UNIT_HEALTH')

					-- Send fake event to AnnouncementMonitor
					RSA.MonitorAndAnnounce(self, 'utilities', nil, 'UNIT_ACCEPTED_RESURRECT', false, UnitGUID('player'), UnitName('player'), 'Me', nil, UnitGUID(arg1), UnitName(arg1), false, nil, 265116, GetSpellInfo(265116))
				end
			end
		elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
			-- Used for Codex since they don't give any combat log events.
			RSA.MonitorAndAnnounce(self, 'utilities', nil, 'UNIT_SPELLCAST_SUCCEEDED', false, UnitGUID(arg1), UnitName(arg1), false, nil, UnitGUID(arg1), UnitName(arg1), false, nil, arg3, GetSpellInfo(arg3))
		end
	end

	RSA_Utilities.CombatLogMonitor:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	RSA_Utilities.CombatLogMonitor:SetScript('OnEvent', Spells)
end

function RSA_Utilities:OnDisable()
	RSA.db.profile.Modules.Utilities = false
	RSA_Utilities.CombatLogMonitor:SetScript('OnEvent', nil)
end
