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
	local Config_RepairBots = { -- Repair Bots
		profile = 'Jeeves',
		comm = true, -- If we only want one person in the group to announce this.
		sourceIsMe = true, -- For personal utility spells like Rocket Boots, Trinkets etc.
		replacements = { SOURCE = 1 }
	}   
	]]--
	local Config_RepairBots = {
		profile = 'Jeeves',
		section = 'Placed',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local Config_Feasts = {
		profile = 'Feasts',
		section = 'Placed',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local Config_Drums = {
		profile = 'Drums',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	local Config_Cauldrons = {
		profile = 'Cauldrons',
		comm = true,
		replacements = { SOURCE = 1 }
	}
	MonitorConfig_Utilities = {
		player_profile = RSA.db.profile.Utilities,
		SPELL_RESURRECT = {
			[265116] = {	
				profile = 'EngineerRessBFA',
				section = 'Cast',
				sourceIsMe = true,
				replacements = { TARGET = 1 }
			},	   
		},
		SPELL_SUMMON = {
			[22700] = Config_RepairBots, -- Field Repair Bot 74A
			[44389] = Config_RepairBots, -- Field Repair Bot 110G			
			[54711] = Config_RepairBots, -- Scrapbot (Northrend Engineering)
			[67826] = Config_RepairBots, -- Jeeves
			[157066] = Config_RepairBots, -- Walter (WoD Engineer Workshop)			
			[199109] = Config_RepairBots, -- Auto-Hammer
		},
		SPELL_CAST_START = {
			[92649] = Config_Cauldrons, -- Cauldron of Battle (Cata)
			[92712] = Config_Cauldrons, -- Big Cauldron of Battle (Cata)
			[188036] = Config_Cauldrons, -- Spirit Cauldron (Legion)
			[276972] = Config_Cauldrons, -- Mystical Cauldron (BfA)	  
		},
		SPELL_CAST_SUCCESS = {
			[200205] = Config_RepairBots, -- Reaves Auto-Hammer mode
			[57301] = Config_Feasts, -- Great Feast (WotLK)
			[57426] = Config_Feasts, -- Fish Feast (WotLK)
			[58465] = Config_Feasts, -- Gigantic Feast (WotLK)
			[58474] = Config_Feasts, -- Small Feast (WotLK)
			[87643] = Config_Feasts, -- Broiled Dragon Feast (Cata)
			[87915] = Config_Feasts, -- Goblin Barbecue Feast (Cata)
			[87644] = Config_Feasts, -- Seafood Magnifique Feast (Cata)
			[104958] = Config_Feasts, -- Pandaren Banquet
			[105193] = Config_Feasts, -- Great Pandaren Banquet Feast
			[126492] = Config_Feasts, -- Banquet of the Grill
			[126494] = Config_Feasts, -- Great Banquet of the Grill
			[126495] = Config_Feasts, -- Banquet of the Wok
			[126496] = Config_Feasts, -- Great Banquet of the Wok
			[126497] = Config_Feasts, -- Banquet of the Pot
			[126498] = Config_Feasts, -- Great Banquet of the Pot
			[126499] = Config_Feasts, -- Banquet of the Steamer
			[126500] = Config_Feasts, -- Great Banquet of the Steamer
			[126501] = Config_Feasts, -- Banquet of the Oven
			[126502] = Config_Feasts, -- Great Banquet of the Oven
			[126503] = Config_Feasts, -- Banquet of the Brew
			[126504] = Config_Feasts, -- Great Banquet of the Brew
			[145166] = Config_Feasts, -- Noodle Cart
			[145169] = Config_Feasts, -- Deluxe Noodle Cart
			[145196] = Config_Feasts, -- Pandaren Treasure Noodle Cart
			[160914] = Config_Feasts, -- Feast of the Waters (WoD)
			[160740] = Config_Feasts, -- Feast of Blood (WoD)
			[175215] = Config_Feasts, -- Savage Feast (WoD)
			[185706] = Config_Feasts, -- Fancy Darkmoon Feast (Darkmoon Faire)
			[185709] = Config_Feasts, -- Sugar-Crusted Fish Feast (Darkmoon Faire)
			[201351] = Config_Feasts, -- Hearty Feast (Legion)
			[201352] = Config_Feasts, -- Lavish Suramar Feast (Legion)
			[251254] = Config_Feasts, -- Feast of the Fishes (Legion)
			[259409] = Config_Feasts, -- Gallery Banquet (BfA)
			[259410] = Config_Feasts, -- Bountiful Captain's Feast (BfA)
			[286050] = Config_Feasts, -- Sanguinated Feast (BfA)			
			[178207] = Config_Drums, -- Drums of Fury (WoD)
			[230935] = Config_Drums, -- Drums of the Mountain (Legion)
			[256740] = Config_Drums, -- Drums of the Maelstrom (BfA)
		},
		UNIT_ACCEPTED_RESURRECT = { -- Fake event for resurrect tracking
			[265116] = {	
				profile = 'EngineerRessBFA',
				section = 'AcceptedRess',
				sourceIsMe = true,
				replacements = { TARGET = 1 }
			},   
		},
	}

	RSA.UtilityMonitorConfig(MonitorConfig_Utilities, UnitGUID('player'))

	local function Spells(_,event,arg1)
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
		end
	end
	RSA_Utilities.CombatLogMonitor:SetScript('OnEvent', Spells)
end

function RSA_Utilities:OnDisable()
	RSA.db.profile.Modules.Utilities = false 
	RSA_Utilities.CombatLogMonitor:SetScript('OnEvent', nil)
end
