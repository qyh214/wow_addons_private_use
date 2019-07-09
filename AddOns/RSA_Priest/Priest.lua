-----------------------------------------------
---- Raeli's Spell Announcer Priest Module ----
-----------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local LRI = LibStub('LibResInfo-1.0',true)
local RSA_Priest = RSA:NewModule('Priest')

local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo,GSTarget

function RSA_Priest:OnInitialize()
	if RSA.db.profile.General.Class == 'PRIEST' then
		RSA_Priest:SetEnabledState(true)
	else
		RSA_Priest:SetEnabledState(false)
	end
end

function RSA.Resurrect(_, _, target, _, caster)
	if caster ~= 'player' then return end
	local dest = UnitName(target)
	local pName = UnitName('player')
	local spell = 2006
	local messagemax = #RSA.db.profile.Priest.Spells.Resurrection.Messages.Start
	if messagemax == 0 then return end
	local messagerandom = math.random(messagemax)
	local message = RSA.db.profile.Priest.Spells.Resurrection.Messages.Start[messagerandom]
	local full_destName,dest = RSA.RemoveServerNames(dest)
	spellinfo = GetSpellInfo(spell) spelllinkinfo = GetSpellLink(spell)
	RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
	if message ~= '' then
		if RSA.db.profile.Priest.Spells.Resurrection.Local == true then
			RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Priest.Spells.Resurrection.Yell == true then
			RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Priest.Spells.Resurrection.Whisper == true and dest ~= pName then
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
			--RSA.Print_Whisper(string.gsub(message, '.%a+.', RSA.String_Replace), full_destName)
			RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
		end
		if RSA.db.profile.Priest.Spells.Resurrection.CustomChannel.Enabled == true then
			RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.Resurrection.CustomChannel.Channel)
		end
		if RSA.db.profile.Priest.Spells.Resurrection.Say == true then
			RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Priest.Spells.Resurrection.SmartGroup == true then
			RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Priest.Spells.Resurrection.Party == true then
			if RSA.db.profile.Priest.Spells.Resurrection.SmartGroup == true and GetNumGroupMembers() == 0 then return end
				RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Priest.Spells.Resurrection.Raid == true then
			if RSA.db.profile.Priest.Spells.Resurrection.SmartGroup == true and GetNumGroupMembers() > 0 then return end
			RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
	end	
end

function RSA_Priest:OnEnable()
	if LRI then LRI.RegisterCallback(RSA, 'LibResInfo_ResCastStarted', 'Resurrect') end
	RSA.db.profile.Modules.Priest = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local Config_MC = { -- Mind Control and Dominant Mind shadow talent
		profile = 'MindControl',
		section = 'Cast',
		targetNotMe = 1,
		replacements = { TARGET = 1 }
	}
	local Config_MC_End = { -- Mind Control and Dominant Mind shadow talent
		profile = 'MindControl',
		section = 'End',
		targetNotMe = 1,
		replacements = { TARGET = 1 }
	}
	local Config_Fade = { -- Fade and Greater Fade
		profile = 'Fade',
	}
	local Config_Fade_End = { -- Fade and Greater Fade
		profile = 'Fade',
		section = 'End'
	}
	local Config_Purify = { -- Purify & Purify Disease
		profile = 'Purify',
		section = 'Dispel',
		replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
	}
	local Config_Chastise = { -- Holy Word: Chastise
		profile = 'Chastise',
		replacements = { TARGET = 1 },
	}
	local Config_Chastise_End = { -- Holy Word: Chastise
		profile = 'Chastise',
		replacements = { TARGET = 1 },
		section = 'End'
	}
	local MonitorConfig_Priest = {
		player_profile = RSA.db.profile.Priest,
		SPELL_RESURRECT = {
			[2006] = { -- Resurrection
				profile = 'Resurrection',
				section = 'End',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_HEAL = {
			[197336] = { -- Ray Of Hope
				profile = 'RayOfHope',
				section = 'Heal',
				linkID = 197268,
				replacements = { TARGET = 1, AMOUNT = 1 }
			},
		},
		SPELL_AURA_APPLIED = {
			[605] = Config_MC, -- Mind Control
			[205364] = Config_MC, -- Mind Control
			[200196] = Config_Chastise, -- Holy Word: Chastise
			[200200] = Config_Chastise, -- Holy Word: Chastise with Censure talent
			[9484] = { -- SHACKLE UNDEAD
				profile = 'ShackleUndead',
				replacements = { TARGET = 1 }
			},
			[15286] = { -- VAMPIRIC EMBRACE
				profile = 'VampiricEmbrace',
				replacements = { TARGET = 1 }
			},
			[65081] = { -- BODY AND SOUL
				profile = 'BodyAndSoul',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
			[197871] = { -- Dark Archangel
				profile = 'DarkAngel',
			},
			[197862] = { -- Archangel
				profile = 'Archangel',
			},	
			[213610] = { -- Holy Ward
				profile = 'HolyWard',
				replacements = { TARGET = 1 },
			},
			[197268] = { -- Ray Of Hope
				profile = 'RayOfHope',
				replacements = { TARGET = 1 },
			},		
		},
		SPELL_CAST_START = {
			[212036] = { -- MASS RESURRECTION
				profile = 'MassRess'
			},
			[32375] = { -- MASS DISPEL
				profile = 'MassDispel',
				section = 'Start',
			},
		},
		SPELL_CAST_SUCCESS = {
			[586] = Config_Fade, -- Fade
			[213602] = Config_Fade, -- Greater Fade
			[212036] = { -- MASS RESURRECTION
				profile = 'MassRess',
				section = 'End'
			},
			[73325] = { -- LEAP OF FAITH
				profile = 'LeapOfFaith',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
			[32375] = { -- MASS DISPEL
				profile = 'MassDispel',
				section = 'Cast',
			},
			[62618] = { -- POWER WORD: BARRIER
				profile = 'PowerWordBarrier'
			},
			[64843] = { -- DIVINE HYMN
				profile = 'DivineHymn'
			},
			[200183] = {
				profile = 'Apotheosis'
			},
			[1706] = { -- LEVITATE
				profile = 'Levitate',
				replacements = { TARGET = 1 }
			},
			[33206] = { -- PAIN SUPPRESSION
				profile = 'PainSuppression',
				replacements = { TARGET = 1 }
			},
			[64044] = { -- PSYCHIC HORROR
				profile = 'PsychicHorror',
				replacements = { TARGET = 1 }
			},
			[34433] = { -- SHADOWFIEND (normal)
				profile = 'Shadowfiend',
				section = 'Cast'
			},
			[123040] = { -- Mindbender Discipline
				profile = 'Shadowfiend',
				section = 'Cast'
			},
			[200174] = { -- Mindbender Shadow
				profile = 'Shadowfiend',
				section = 'Cast'
			},
			[47788] = { -- GUARDIAN SPIRIT
				profile = 'GuardianSpirit',
				replacements = { TARGET = 1 }
			},
			[8122] = { -- PSYCHIC SCREAM
				profile = 'PsychicScream'
			},
			[205369] = { -- Mind Bomb
			profile = 'MindBomb',
			replacements = { TARGET = 1 }
			},
			[64901] = { -- SYMBOL OF HOPE
				profile = 'SymbolOfHope'
			},
			[265202] = { -- Holy Word: Salvation
				profile = 'Salvation',
				section = 'Cast'
			},
		},
		SPELL_AURA_REMOVED = {
			[586] = Config_Fade_End, -- Fade
			[213602] = Config_Fade_End, -- Greater Fade
			[605] = Config_MC_End, -- Mind Control
			[205364] = Config_MC_End, -- Mind Control
			[200196] = Config_Chastise_End, -- Holy Word: Chastise
			[200200] = Config_Chastise_End, -- Holy Word: Chastise with Censure talent
			[15286] = { -- VAMPIRIC EMBRACE
				profile = 'VampiricEmbrace',
				section = 'End'
			},
			[64843] = { -- DIVINE HYMN
				profile = 'DivineHymn',
				section = 'End'
			},
			[200183] = {
				profile = 'Apotheosis',
				section = 'End'
			},
			[111759] = { -- LEVITATE
				profile = 'Levitate',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[9484] = { -- SHACKLE UNDEAD
				profile = 'ShackleUndead',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[33206] = { -- PAIN SUPPRESSION
				profile = 'PainSuppression',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[15487] = { -- SILENCE
				profile = 'Silence',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[64044] = { -- PSYCHIC HORROR
				profile = 'PsychicHorror',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			--[[[47788] = { -- GUARDIAN SPIRIT
				profile = 'GuardianSpirit',
				section = 'End',
				replacements = { TARGET = 1 }
			},]]--
			[64901] = { -- SYMBOL OF HOPE
				profile = 'SymbolOfHope',
				section = 'End',
				targetIsMe = 1
			},
			[197871] = { -- Dark Archangel
				profile = 'DarkAngel',
				section = 'End',
				targetIsMe = 1
			},
			[197862] = { -- Archangel
				profile = 'Archangel',
				section = 'End',
				
			},	
			[213610] = { -- Holy Ward
				profile = 'HolyWard',
				replacements = { TARGET = 1 },
				section = 'End',
			},
			[197268] = { -- Ray Of Hope
				profile = 'RayOfHope',
				section = 'End',
				replacements = { TARGET = 1 },
			},	
		},
		SPELL_DISPEL = {
			[528] = { -- DISPEL MAGIC
				profile = 'DispelMagic',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
			[527] = Config_Purify,
			[213634] = Config_Purify,
		},
		SPELL_DISPEL_FAILED = {
			[528] = { -- DISPEL MAGIC
				profile = 'DispelMagic',
				section = 'Resist',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
		},
		SPELL_INTERRUPT = {
			[220543] = { -- SILENCE
				profile = 'Silence',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Priest, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local RSA_Silenced = false -- If we Interrupt and Silence our target, it will fire two events, both of which have announcements linked, this variable is to stop that.
	local RSA_PWBTimer = CreateFrame('Frame', 'RSA:PWBTimer') -- Because Power Word: Barrier has no event for end message.
	local PWBTimeElapsed = 0.0
	local RSA_PsychicScream = false
	local function Priest_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Priest.Reminders.SpellName
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
			if event == 'SPELL_AURA_APPLIED' then
				if spellID == 15487 and RSA_Silenced == false then -- SILENCE
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					RSA_Silenced = true
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					local messagemax = #RSA.db.profile.Priest.Spells.Silence.Messages.Cast
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Priest.Spells.Silence.Messages.Cast[messagerandom]
					if message ~= '' then
						if RSA.db.profile.Priest.Spells.Silence.Local == true then
							RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.Silence.Yell == true then
							RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.Silence.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.Silence.CustomChannel.Channel)
						end
						if RSA.db.profile.Priest.Spells.Silence.Say == true then
							RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.Silence.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.Silence.Party == true then
							if RSA.db.profile.Priest.Spells.Silence.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.Silence.Raid == true then
							if RSA.db.profile.Priest.Spells.Silence.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
					end
				end -- SILENCE
			end -- IF EVENT IS SPELL_AURA_APPLIED
			if event == 'SPELL_CAST_SUCCESS' then
				if spellID == 47788 then -- Guardian Spirit
					GSTarget = destGUID				
				end
				if spellID == 62618 then -- POWER WORD: BARRIER timed end message
					if RSA.db.profile.Priest.Spells.PowerWordBarrier.Messages.End ~= '' then
						PWBTimeElapsed = 0.0 -- Start a timer for end announcement, because Power Word Barrier has no reliable end event in combat log.
						local duration = 10.5
						local function PWBTimer(self, elapsed)
							PWBTimeElapsed = PWBTimeElapsed + elapsed
							if PWBTimeElapsed < duration then return end
							RSA_PWBTimer:SetScript('OnUpdate', nil)
							PWBTimeElapsed = PWBTimeElapsed - floor(PWBTimeElapsed)
							spellinfo = GetSpellInfo(spellID)
							spelllinkinfo = GetSpellLink(spellID)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
							local messagemax = #RSA.db.profile.Priest.Spells.PowerWordBarrier.Messages.End
							if messagemax == 0 then return end
							local messagerandom = math.random(messagemax)
							local message = RSA.db.profile.Priest.Spells.PowerWordBarrier.Messages.End[messagerandom]
							if message ~= '' then
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.Local == true then
									RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.Yell == true then
									RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.CustomChannel.Enabled == true then
									RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.PowerWordBarrier.CustomChannel.Channel)
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.Say == true then
									RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.SmartGroup == true then
									RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.Party == true then
									if RSA.db.profile.Priest.Spells.PowerWordBarrier.SmartGroup == true and GetNumGroupMembers() == 0 then return end
										RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
								if RSA.db.profile.Priest.Spells.PowerWordBarrier.Raid == true then
									if RSA.db.profile.Priest.Spells.PowerWordBarrier.SmartGroup == true and GetNumGroupMembers() > 0 then return end
									RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
								end
							end
						end
						RSA_PWBTimer:SetScript('OnUpdate', PWBTimer)
					end
				end -- POWER WORD: BARRIER
				if spellID == 8122 or spellID == 205369 then -- PSYCHIC SCREAM and Mind Bomb
					RSA_PsychicScream = false -- announcement done in unified core
				end -- PSYCHIC SCREAM
			end -- IF EVENT IS SPELL_CAST_SUCCESS
			if event == 'SPELL_AURA_REMOVED' then			
				if spellID == 47788 and GSTarget == destGUID then -- Guardian Spirit, temporary until I figure out a better method. Should prevent announcement due to artifact trait on the player, but still announce on the player if they cast it on themselves
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					local full_destName,dest = RSA.RemoveServerNames(dest)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					local messagemax = #RSA.db.profile.Priest.Spells.GuardianSpirit.Messages.End
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Priest.Spells.GuardianSpirit.Messages.End[messagerandom]
					if message ~= '' then
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Local == true then
							RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Yell == true then
							RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Whisper == true and dest ~= pName then
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.GuardianSpirit.CustomChannel.Channel)
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Say == true then
							RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Party == true then
							if RSA.db.profile.Priest.Spells.GuardianSpirit.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.GuardianSpirit.Raid == true then
							if RSA.db.profile.Priest.Spells.GuardianSpirit.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
					end			
				end
				if (spellID == 8122 and RSA_PsychicScream == false) then -- PSYCHIC SCREAM
					RSA_PsychicScream = true
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					local messagemax = #RSA.db.profile.Priest.Spells.PsychicScream.Messages.End
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Priest.Spells.PsychicScream.Messages.End[messagerandom]
					if message ~= '' then
						if RSA.db.profile.Priest.Spells.PsychicScream.Local == true then
							RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.Yell == true then
							RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.PsychicScream.CustomChannel.Channel)
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.Say == true then
							RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.Party == true then
							if RSA.db.profile.Priest.Spells.PsychicScream.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.PsychicScream.Raid == true then
							if RSA.db.profile.Priest.Spells.PsychicScream.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
					end	
				end -- PSYCHIC SCREAM
				if (spellID == 226943 and RSA_PsychicScream == false) then -- Mind Bomb
					RSA_PsychicScream = true
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					local messagemax = #RSA.db.profile.Priest.Spells.MindBomb.Messages.End
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Priest.Spells.MindBomb.Messages.End[messagerandom]
					if message ~= '' then
						if RSA.db.profile.Priest.Spells.MindBomb.Local == true then
							RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.MindBomb.Yell == true then
							RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.MindBomb.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Priest.Spells.MindBomb.CustomChannel.Channel)
						end
						if RSA.db.profile.Priest.Spells.MindBomb.Say == true then
							RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.MindBomb.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.MindBomb.Party == true then
							if RSA.db.profile.Priest.Spells.MindBomb.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
						if RSA.db.profile.Priest.Spells.MindBomb.Raid == true then
							if RSA.db.profile.Priest.Spells.MindBomb.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
						end
					end	
				end -- Mind Bomb
				if spellID == 15487 then -- SILENCE
					RSA_Silenced = false -- announcement done in unified core
				end -- SILENCE
			end -- IF EVENT IS SPELL_AURA_REMOVED
			if event == 'SPELL_INTERRUPT' then
				if spellID == 220543 then -- SILENCE
					RSA_Silenced = true -- announcement done in unified core
				end -- SILENCE
			end -- IF EVENT IS SPELL_INTERRUPT
			MonitorAndAnnounce(self, 'player', timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript('OnEvent', Priest_Spells)
end

function RSA_Priest:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
	if LRI then LRI.UnregisterAllCallbacks(RSA) end
end
