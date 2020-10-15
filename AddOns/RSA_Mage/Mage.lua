---------------------------------------------
---- Raeli's Spell Announcer Mage Module ----
---------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Mage = RSA:NewModule('Mage')

function RSA_Mage:OnInitialize()
	if RSA.db.profile.General.Class == 'MAGE' then
		RSA_Mage:SetEnabledState(true)
	else
		RSA_Mage:SetEnabledState(false)
	end
end -- End OnInitialize
function RSA_Mage:OnEnable()
	RSA.db.profile.Modules.Mage = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local Config_Polymorph = { -- POLYMORPH
		profile = 'Polymorph',
		section = 'Cast',
		replacements = { TARGET = 1 }
	}
	local Config_Polymorph_End = { -- POLYMORPH
		profile = 'Polymorph',
		section = 'End',
		replacements = { TARGET = 1 }
	}
	local Config_Polymorph_Missed = { -- POLYMORPH
		profile = 'Polymorph',
		section = 'Resist',
		immuneSection = 'Immune',
		replacements = { TARGET = 1 }
	}
	local Config_Portals = { -- Portals
		profile = 'Portals'
	}
	local Config_Teleport = { -- Teleport
		profile = 'Teleport',
		groupRequired = true,
	}
	local Config_Counterspell = { -- Counterspell
		profile = 'Counterspell',
		section  = 'Interrupt',
		replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
	}
	local Config_Counterspell_Missed = { -- Counterspell
		profile = 'Counterspell',
		section = 'Resist',
		immuneSection = 'Immune',
		replacements = { TARGET = 1, MISSTYPE = 1 },
	}
	local MonitorConfig_Mage = {
		player_profile = RSA.db.profile.Mage,
		SPELL_CAST_START = {
			[10059] = Config_Portals, -- STORMWIND PORTAL
			[11416] = Config_Portals, -- IRONFORGE PORTAL
			[11417] = Config_Portals, -- ORGRIMMAR PORTAL
			[11418] = Config_Portals, -- UNDERCITY PORTAL
			[11419] = Config_Portals, -- DARNASSUS PORTAL
			[11420] = Config_Portals, -- THUNDER BLUFF PORTAL
			[49360] = Config_Portals, -- THERAMORE PORTAL
			[49361] = Config_Portals, -- STONARD PORTAL
			[120146] = Config_Portals, -- ANCIENT DALARAN PORTAL
			[32266] = Config_Portals, -- EXODAR PORTAL
			[32267] = Config_Portals, -- SILVERMOON PORTAL
			[33691] = Config_Portals, -- SHATTRATH PORTAL
			[35717] = Config_Portals, -- SHATTRATH PORTAL
			[53142] = Config_Portals, -- DALARAN NORTHREND PORTAL
			[88345] = Config_Portals, -- TOL BARAD PORTAL
			[88346] = Config_Portals, -- TOL BARAD PORTAL
			[132620] = Config_Portals, -- VALE OF ETERNAL BLOSSOMS PORTAL
			[132626] = Config_Portals, -- VALE OF ETERNAL BLOSSOMS PORTAL
			[176244] = Config_Portals, -- Warspear
			[176246] = Config_Portals, -- Stormshield
			[224871] = Config_Portals, -- DALARAN BROKEN ISLES PORTAL
			[281400] = Config_Portals, -- Boralus
			[281402] = Config_Portals, -- Dazar'alor
			[3563] = Config_Teleport, -- Undercity
			[3566] = Config_Teleport, -- Thunderbluff
			[3561] = Config_Teleport, -- Stormwind
			[3567] = Config_Teleport, -- Orgrimmar
			[3562] = Config_Teleport, -- Ironforge
			[3565] = Config_Teleport, -- Darnassus
			[49359] = Config_Teleport, -- Theramore
			[49358] = Config_Teleport, -- Stonard
			[120145] = Config_Teleport, -- Ancient Teleport: Dalaran (Hillsbrad)
			[35715] = Config_Teleport, -- Shattrath
			[33690] = Config_Teleport, -- Shattrath
			[32271] = Config_Teleport, -- Exodar
			[32272] = Config_Teleport, -- Silvermoon
			[53140] = Config_Teleport, -- Dalaran - Northrend
			[88344] = Config_Teleport, -- Tol Barad
			[88342] = Config_Teleport, -- Tol Barad
			[132627] = Config_Teleport, -- Vale of Eternal Blossoms
			[132621] = Config_Teleport, -- Vale of Eternal Blossoms
			[176242] = Config_Teleport, -- Warspear
			[176248] = Config_Teleport, -- Stormshield
			[224869] = Config_Teleport, -- Dalaran - Broken Isles
			[193759] = Config_Teleport, -- Hall of the Guardian
			[281404] = Config_Teleport, -- Dazar'alor
			[281403] = Config_Teleport, -- Boralus
			[190336] = { -- REFRESHMENT TABLE
				profile = 'RefreshmentTable'
			},
		},
		SPELL_CAST_SUCCESS = {
			[45438] = { -- ICE BLOCK
				profile = 'IceBlock'
			},
		},
		SPELL_AURA_APPLIED = {
			[118] = Config_Polymorph, -- SHEEP
			[28271] = Config_Polymorph, -- TURTLE
			[28272] = Config_Polymorph, -- PIG
			[61305] = Config_Polymorph, -- BLACK CAT
			[61721] = Config_Polymorph, -- RABBIT
			[61780] = Config_Polymorph, -- TURKEY
			[80353] = { -- TIME WARP
				profile = 'TimeWarp',
				targetIsMe = 1
			},
			[130] = { -- SLOW FALL
				profile = 'SlowFall',
				replacements = { TARGET = 1 }
			}
		},
		SPELL_STOLEN = {
			[30449] = { -- SPELL STEAL
				profile = 'Spellsteal',
				section = 'Cast',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			}
		},
		SPELL_DISPEL = {
			[475] = { -- Remove Curse
				profile = 'RemoveCurse',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
		},
		SPELL_HEAL = {
			[87023] = { -- CAUTERIZE
				profile = 'Cauterize',
			}
		},
		SPELL_AURA_REMOVED = {
			[118] = Config_Polymorph_End, -- SHEEP
			[28271] = Config_Polymorph_End, -- TURTLE
			[28272] = Config_Polymorph_End, -- PIG
			[61305] = Config_Polymorph_End, -- BLACK CAT
			[61721] = Config_Polymorph_End, -- RABBIT
			[61780] = Config_Polymorph_End, -- TURKEY
			[87023] = { -- CAUTERIZE
				profile = 'Cauterize',
				section = 'End'
			},
			[80353] = { -- TIME WARP
				profile = 'TimeWarp',
				section = 'End',
				targetIsMe = 1
			},
			[130] = { -- SLOW FALL
				profile = 'SlowFall',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[45438] = { -- ICE BLOCK
				profile = 'IceBlock',
				section = 'End'
			},
		},
		SPELL_SUMMON = {
			[113724] = { -- RING OF FROST
				profile = 'RingOfFrost',
				section = 'Cast',
			}
		},
		SPELL_INTERRUPT = {
			[2139] = Config_Counterspell, -- COUNTERSPELL
		},
		SPELL_MISSED = {
			[2139] = Config_Counterspell_Missed, -- COUNTERSPELL
			[118] = Config_Polymorph_Missed, -- SHEEP
			[28271] = Config_Polymorph_Missed, -- TURTLE
			[28272] = Config_Polymorph_Missed, -- PIG
			[61305] = Config_Polymorph_Missed, -- BLACK CAT
			[61721] = Config_Polymorph_Missed, -- RABBIT
			[61780] = Config_Polymorph_Missed, -- TURKEY
			[30449] = {-- SPELL STEAL
				profile = 'Spellsteal',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Mage, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
	local function Mage_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Mage.Reminders.SpellName
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
	RSA.CombatLogMonitor:SetScript('OnEvent', Mage_Spells)
end -- END ON ENABLED
function RSA_Mage:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
end
