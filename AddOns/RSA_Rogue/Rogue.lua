----------------------------------------------
---- Raeli's Spell Announcer Rogue Module ----
----------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Rogue = RSA:NewModule('Rogue')
function RSA_Rogue:OnInitialize()
	if RSA.db.profile.General.Class == 'ROGUE' then
		RSA_Rogue:SetEnabledState(true)
	else
		RSA_Rogue:SetEnabledState(false)
	end
end -- End OnInitialize
local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
function RSA_Rogue:OnEnable()
	RSA.db.profile.Modules.Rogue = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local MonitorConfig_Rogue = {
		player_profile = RSA.db.profile.Rogue,
		SPELL_DISPEL = {
			[5938] = { -- Shiv
				profile = 'Shiv',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
		},
		SPELL_CAST_SUCCESS = {
			[76577] = { -- SMOKE BOMB
				profile = 'SmokeBomb'
			},
			[57934] = { -- TRICKS OF THE TRADE
				profile = 'Tricks',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
		},
		SPELL_AURA_APPLIED = {
			[6770] = { -- SAP
				profile = 'Sap',
				replacements = { TARGET = 1 }
			},
			[2094] = { -- BLIND
				profile = 'Blind',
				replacements = { TARGET = 1 }
			},
			[199743] = { -- Parley
				profile = 'Blind',
				replacements = { TARGET = 1 }
			},
			[31224] = { -- CLOAK OF SHADOWS
				profile = 'CloakOfShadows'
			},
			[115834] = { -- Shroud of Concealment
				profile = 'Shroud',
				tracker = 2,
			},
			[199804] = { -- Between The Eyes
				profile = 'BetweenTheEyes',
				replacements = { TARGET = 1 }
			},
			[408] = { -- Kidney Shot
				profile = 'KidneyShot',
				replacements = { TARGET = 1 },
			},
			[1833] = { -- Cheap Shot
				profile = 'CheapShot',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_AURA_REMOVED = {
			[6770] = { -- SAP
				profile = 'Sap',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[2094] = { -- BLIND
				profile = 'Blind',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[199743] = { -- Parley
				profile = 'Blind',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[31224] = { -- CLOAK OF SHADOWS
				profile = 'CloakOfShadows',
				section = 'End'
			},
			[57934] = { -- TRICKS OF THE TRADE
				profile = 'Tricks',
				section = 'End',
			},
			[115834] = { -- Shroud of Concealment
				profile = 'Shroud',
				tracker = 1,
				section = 'End',
			},
			[199804] = { -- Between The Eyes
				profile = 'BetweenTheEyes',
				replacements = { TARGET = 1 },
				section = 'End',
			},
			[408] = { -- Kidney Shot
				profile = 'KidneyShot',
				replacements = { TARGET = 1 },
				section = 'End',
			},
			[1833] = { -- Cheap Shot
				profile = 'CheapShot',
				replacements = { TARGET = 1 },
				section = 'End',
			},
		},
		SPELL_INTERRUPT = {
			[1766] = { -- KICK
				profile = 'Kick',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
			}
		},
		SPELL_MISSED = {
			[1766] = {-- KICK
				profile = 'Kick',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
		[2094] = { -- BLIND
			profile = 'Blind',
			section = 'Resist',
			immuneSection = 'Immune',
			replacements = { TARGET = 1 }
		},
		[199743] = { -- Parley
			profile = 'Blind',
			section = 'Resist',
			immuneSection = 'Immune',
			replacements = { TARGET = 1 }
		},
	}
	RSA.MonitorConfig(MonitorConfig_Rogue, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local function Rogue_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then

			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Rogue.Reminders.SpellName
				if spellName == ReminderSpell and (dest == pName or dest == nil) then
					RSA.Reminder:SetScript('OnUpdate', nil)
					if RSA.db.profile.Reminders.RemindChannels.Chat == true then
						RSA.Print_Self(ReminderSpell .. L[" Refreshed!"])
					end
					if RSA.db.profile.Reminders.RemindChannels.RaidWarn == true then
						RSA.Print_Self_RW(ReminderSpell .. L[" Refreshed!"])
					end
				end
			end -- BUFF REMINDER
			MonitorAndAnnounce(self, 'player', timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript('OnEvent', Rogue_Spells)
end -- END ON ENABLED
function RSA_Rogue:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
end
