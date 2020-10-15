------------------------------------------------
---- Raeli's Spell Announcer Warlock Module ----
------------------------------------------------
local RSA =  RSA or LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Warlock = RSA:NewModule('Warlock')

local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo

function RSA_Warlock:OnInitialize()
	if RSA.db.profile.General.Class == 'WARLOCK' then
		RSA_Warlock:SetEnabledState(true)
	else
		RSA_Warlock:SetEnabledState(false)
	end
end

function RSA_Warlock:OnEnable()
	RSA.db.profile.Modules.Warlock = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local Config_SpellLock = { -- Spell Lock
		profile = 'SpellLock',
		section = 'Interrupt',
		replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
	}
	local Config_SpellLock_Missed = { -- Spell Lock
		profile = 'SpellLock',
		section = 'Resist',
		immuneSection = 'Immune',
		replacements = { TARGET = 1, MISSTYPE = 1 },
	}
	local Config_Fear = { -- Fear
		profile = 'Fear',
		section = 'Cast',
		replacements = { TARGET = 1 }
	}
	local Config_Fear_End = { -- Fear
		profile = 'Fear',
		section = 'End',
		replacements = { TARGET = 1 }
	}
	local Config_Seduce = { -- Seduce
		profile = 'Seduce',
		section = 'Cast',
		replacements = { TARGET = 1 }
	}
	local Config_Seduce_End = { -- Seduce
		profile = 'Seduce',
		section = 'End',
		replacements = { TARGET = 1 }
	}
	local Config_SingeMagic = { -- Singe Magic
		profile = 'SingeMagic',
		section = 'Dispel',
		replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
	}
	local MonitorConfig_Warlock = {
		player_profile = RSA.db.profile.Warlock,
		SPELL_CAST_SUCCESS = {
			[698] = { -- SUMMONING STONE
				profile = 'SummonStone'
			},
			[111771] = { -- DEMONIC GATEWAY
				profile = 'Gateway',
				section = 'Cast',
			},
		},
		SPELL_AURA_APPLIED = {
			[118699] = Config_Fear, -- FEAR
			[6358] = Config_Seduce, -- SEDUCE
			[115268] = Config_Seduce, -- MESMERISE - Shivarra Glyph
			[110913] = { -- DARK BARGAIN
				profile = 'DarkBargain'
			},
			[104773] = { -- UNENDING RESOLVE
				profile = 'UnendingResolve'
			},
			[108416] = { -- Dark Pact
				profile = 'DarkPact',
			},
			[17735] = { -- SUFFERING
				profile = 'Suffering',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
			[710] = { -- BANISH
				profile = 'Banish',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
			[6789] = { -- MORTAL COIL
				profile = 'DeathCoil',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
			[30283] = { -- SHADOWFURY
				profile = 'Shadowfury',
				tracker = 2,
				section = 'Cast',
			},
			[20707] = { -- SOULSTONE
				profile = 'Soulstone',
				replacements = { TARGET = 1 },
				section = 'Cast',
			},
			[89766] = { -- Axe Toss
				profile = 'AxeToss',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_AURA_REMOVED = {
			[118699] = Config_Fear_End, -- FEAR
			[6358] = Config_Seduce_End, -- SEDUCE
			[115268] = Config_Seduce_End, -- MESMERISE - Shivarra Glyph
			[710] = { -- BANISH
				profile = 'Banish',
				replacements = { TARGET = 1 },
				section = 'End',
			},
			[110913] = { -- DARK BARGAIN
				profile = 'DarkBargain',
				section = 'End',
			},
			[104773] = { -- UNENDING RESOLVE
				profile = 'UnendingResolve',
				section = 'End',
			},
			[108416] = { -- Dark Pact
				profile = 'DarkPact',
				section = 'End',
			},
			[30283] = { -- SHADOWFURY
				profile = 'Shadowfury',
				tracker = 1,
				section = 'End',
			},
			[89766] = { -- Axe Toss
				profile = 'AxeToss',
				replacements = { TARGET = 1 },
				section = 'End',
			},
		},
		SPELL_CAST_START = {
			[29893] = { -- SOULWELL
				profile = 'SoulWell',
			},
			[30283] = { -- SHADOWFURY
				profile = 'Shadowfury',
				section = 'Start',
			},
		},
		SPELL_DISPEL = {
			[89808] = Config_SingeMagic, -- SINGE MAGIC - Normal Imp
			[115276] = Config_SingeMagic, -- SEAR MAGIC - Fel Imp Glyph
			[132411] = Config_SingeMagic, -- Singe Magic - Grimoire of Sacrifice
			[19505] = { -- DEVOUR MAGIC
				profile = 'DevourMagic',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' },
			}
		},
		SPELL_INTERRUPT = {
			[19647] = Config_SpellLock, -- Felhunter Spell Lock
			[115781] = Config_SpellLock, -- Observer Optical Blast
			[171138] = Config_SpellLock, -- Terrorguard Shadow Lock
			[132409] = Config_SpellLock, -- Grimoire of Sacrifice Command Demon Spell Lock

		},
		SPELL_MISSED = {
			[19647] = Config_SpellLock_Missed, -- Felhunter Spell Lock
			[115781] = Config_SpellLock_Missed, -- Observer Optical Blast
			[171138] = Config_SpellLock_Missed, -- Terrorguard Shadow Lock
			[132409] = Config_SpellLock_Missed, -- Grimoire of Sacrifice Command Demon Spell Lock
			[17735] = {-- SUFFERING
				profile = 'Suffering',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[710] = {-- BANISH
				profile = 'Banish',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[5782] = {-- FEAR
				profile = 'Fear',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Warlock, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local function Warlock_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Warlock.Reminders.SpellName
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
	RSA.CombatLogMonitor:SetScript('OnEvent', Warlock_Spells)
	------------------------------
	---- Resurrection Monitor ----
	------------------------------
	local function Resurrection(_, event, source, dest, _, spell, _)
		if UnitName(source) == pName then
			if spell == 20707 and RSA.db.profile.Warlock.Spells.Soulstone.Messages.Start ~= '' then
				if event == 'UNIT_SPELLCAST_SENT' then
					local messagemax = #RSA.db.profile.Warlock.Spells.Soulstone.Messages.Start
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Warlock.Spells.Soulstone.Messages.Start[messagerandom]
					if dest == L["Unknown"] then -- Invalid Target?
						RSA.Print_Self(L["Couldn't find target for Soulstone."])
					return end
					if dest == nil then -- No target found.
						if UnitExists('target') ~= 1 then
							-- No target found, player not targetting anything, assume self-cast.
							dest = UnitName('player')
						elseif UnitHealth('target') > 1 and UnitIsDeadOrGhost('target') ~= 1 then
							 -- Player has a Target, assume we're casting on target, should be correct most of the time.
							dest = UnitName('target')
						end
					end
					local full_destName,dest = RSA.RemoveServerNames(dest)
					spellinfo = GetSpellInfo(spell) spelllinkinfo = GetSpellLink(spell)
					RSA.Replacements = {['[SPELL]'] = spellinfo, ['[LINK]'] = spelllinkinfo, ['[TARGET]'] = dest,}
					if message ~= '' then
						if RSA.db.profile.Warlock.Spells.Soulstone.Local == true then
							RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.Yell == true then
							RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.Whisper == true and dest ~= pName then
							RSA.Replacements = {['[SPELL]'] = spellinfo, ['[LINK]'] = spelllinkinfo, ['[TARGET]'] = L["You"],}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							RSA.Replacements = {['[SPELL]'] = spellinfo, ['[LINK]'] = spelllinkinfo, ['[TARGET]'] = dest,}
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Warlock.Spells.Soulstone.CustomChannel.Channel)
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.Say == true then
							RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.Party == true then
							if RSA.db.profile.Warlock.Spells.Soulstone.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Warlock.Spells.Soulstone.Raid == true then
							if RSA.db.profile.Warlock.Spells.Soulstone.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
					end
				end
			end
		end
	end
	RSA.ResMon = RSA.ResMon or CreateFrame('Frame', 'RSA:RM')
	RSA.ResMon:RegisterEvent('UNIT_SPELLCAST_SENT')
	RSA.ResMon:SetScript('OnEvent', Resurrection)
end

function RSA_Warlock:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
	RSA.ResMon:SetScript('OnEvent', nil)
end
