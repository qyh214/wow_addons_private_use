---------------------------------------------
---- Raeli's Spell Announcer Monk Module ----
---------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Monk = RSA:NewModule('Monk')

local spellinfo,spelllinkinfo

function RSA_Monk:OnInitialize()
	if RSA.db.profile.General.Class == 'MONK' then
		RSA_Monk:SetEnabledState(true)
	else
		RSA_Monk:SetEnabledState(false)
	end
end

function RSA_Monk:OnEnable()
	RSA.db.profile.Modules.Monk = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local Config_Detox = {
		profile = 'Detox',
		section = 'Dispel',
		replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
	}
	local MonitorConfig_Monk = {
		player_profile = RSA.db.profile.Monk,
		SPELL_RESURRECT = {
			[115178] = { -- Resuscitate
				profile = 'Resuscitate',
				section = 'End',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_CAST_START = {
			[212051] = { -- REAWAKEN
				profile = 'Reawaken'
			},
			--[[[115178] = { -- Resuscitate
				profile = 'Resuscitate',
				section = 'Start',
				replacements = { TARGET = 1 },
			},]]--
		},
		SPELL_CAST_SUCCESS = {
			[212051] = { -- REAWAKEN
				profile = 'Reawaken',
				section = 'End',
			},
			[119582] = {-- PURIFYING BREW
				profile = 'PurifyingBrew',
				section = 'Cast',
			},
			[115310] = {-- REVIVAL
				profile = 'Revival',
				section = 'Cast',
			},
			[119381] = {-- LEG SWEEP
				profile = 'LegSweep',
				section = 'Cast',
			},
		},
		SPELL_AURA_APPLIED = {
			[115176] = {-- ZEN MEDITATION
				profile = 'ZenMeditation',
				targetIsMe = 1
			},
			[116189] = {-- PROVOKE
				profile = 'Provoke',
				section = 'Cast',
				replacements = { TARGET = 1 },
			},
			[120954] = {-- FORTIFYING BREW
				profile = 'FortifyingBrew',
			},
			[322507] = {
				profile = 'CelestialBrew',
			},
			[115078] = {-- PARALYSIS
				profile = 'Paralysis',
				replacements = { TARGET = 1 },
			},
			[202162] = {-- GUARD
				profile = 'Guard',
				replacements = { TARGET = 1 },
			},
			[115308] = {-- ELUSIVE BREW
				profile = 'ElusiveBrew',
			},
			[122278] = {-- DAMPEN HARM
				profile = 'DampenHarm',
			},
			[116849] = {-- LIFE COCOON
				profile = 'LifeCocoon',
				replacements = { TARGET = 1 },
			},
			[116844] = {-- RING OF PEACE
				profile = 'RingOfPeace',
				replacements = { TARGET = 1 },
			},
			[122783] = {-- DIFFUSE MAGIC
				profile = 'DiffuseMagic',
			},
			[122470] = {-- TOUCH OF KARMA
				profile = 'TouchOfKarma',
				targetIsMe = 1,
			},
			[116841] = {-- TIGER'S LUST
				profile = 'TigersLust',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_AURA_REMOVED = {
			[115176] = {-- ZEN MEDITATION
				profile = 'ZenMeditation',
				section = 'End',
				targetIsMe = 1,
			},
			[120954] = {-- FORTIFYING BREW
				profile = 'FortifyingBrew',
				section = 'End',
			},
			[322507] = {
				profile = 'CelestialBrew',
				section = 'End',
			},
			[115078] = {-- PARALYSIS
				profile = 'Paralysis',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[202162] = {-- GUARD
				profile = 'Guard',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[115308] = {-- IronSkin Brew
				profile = 'ElusiveBrew',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[122278] = {-- DAMPEN HARM
				profile = 'DampenHarm',
				section = 'End',
			},
			[116849] = {-- LIFE COCOON
				profile = 'LifeCocoon',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[116844] = {-- RING OF PEACE
				profile = 'RingOfPeace',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[122783] = {-- DIFFUSE MAGIC
				profile = 'DiffuseMagic',
				section = 'End',
			},
			[122470] = {-- TOUCH OF KARMA
				profile = 'TouchOfKarma',
				section = 'End',
				targetIsMe = 1
			},
			[116841] = {-- TIGER'S LUST
				profile = 'TigersLust',
				section = 'End',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_MISSED = {
			[115078] = {-- PARALYSIS
				profile = 'Paralysis',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[116189] = {-- PROVOKE
				profile = 'Provoke',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[116705] = {-- SPEAR HAND STRIKE
				profile = 'SpearHandStrike',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
		SPELL_DISPEL = {
			[115450] = Config_Detox, -- Misweaver
			[218164] = Config_Detox, -- Brewmaster & Windwalker
		},
		SPELL_INTERRUPT = {
			[116705] = {-- SPEAR HAND STRIKE
				profile = 'SpearHandStrike',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
			},
		}
	}
	RSA.MonitorConfig(MonitorConfig_Monk, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local function Monk_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Monk.Reminders.SpellName
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
			if event == 'SPELL_CAST_SUCCESS' then
				if spellID == 115546 and RSA.GetMobID(destGUID) == 61146 then -- PROVOKE / STATUE OF THE BLACK OX
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					RSA.Replacements = {['[SPELL]'] = spellinfo, ['[LINK]'] = spelllinkinfo, ['[TARGET]'] = dest,}
					if RSA.db.profile.Monk.Spells.Provoke.Messages.StatueOfTheBlackOx ~= '' then
						local messagemax = #RSA.db.profile.Monk.Spells.Provoke.Messages.StatueOfTheBlackOx
						if messagemax == 0 then return end
						local messagerandom = math.random(messagemax)
						local message = RSA.db.profile.Monk.Spells.Provoke.Messages.StatueOfTheBlackOx[messagerandom]
						if message ~= '' then
							if RSA.db.profile.Monk.Spells.Provoke.Local == true then
								RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
							if RSA.db.profile.Monk.Spells.Provoke.Yell == true then
								RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
							if RSA.db.profile.Monk.Spells.Provoke.CustomChannel.Enabled == true then
								RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Monk.Spells.Provoke.CustomChannel.Channel)
							end
							if RSA.db.profile.Monk.Spells.Provoke.Say == true then
								RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
							if RSA.db.profile.Monk.Spells.Provoke.SmartGroup == true then
								RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
							if RSA.db.profile.Monk.Spells.Provoke.Party == true then
								if RSA.db.profile.Monk.Spells.Provoke.SmartGroup == true and GetNumGroupMembers() == 0 then return end
									RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
							if RSA.db.profile.Monk.Spells.Provoke.Raid == true then
								if RSA.db.profile.Monk.Spells.Provoke.SmartGroup == true and GetNumGroupMembers() > 0 then return end
								RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
							end
						end
					end
				end -- PROVOKE
			end -- IF EVENT IS SPELL_CAST_SUCCESS
			MonitorAndAnnounce(self, 'player', timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript('OnEvent', Monk_Spells)

	local function MonkRess(self, event, source, dest, _, spellid)
		if UnitName(source) == pName then
			if spellid == 115178 and RSA.db.profile.Monk.Spells.Resuscitate.Messages.Start ~= "" then
				if event == "UNIT_SPELLCAST_SENT" then
					local messagemax = #RSA.db.profile.Monk.Spells.Resuscitate.Messages.Start
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Monk.Spells.Resuscitate.Messages.Start[messagerandom]
					if (dest == L["Unknown"] or dest == nil) then
						if UnitExists("target") ~= 1 or (UnitHealth("target") > 1 and UnitIsDeadOrGhost("target") ~= 1) then
							if GameTooltipTextLeft1:GetText() == nil then
								dest = L["Unknown"]
							else
								dest = string.gsub(GameTooltipTextLeft1:GetText(), L["Corpse of "], "")
							end
						else
							dest = UnitName("target")
						end
					end
					local full_destName,dest = RSA.RemoveServerNames(dest)
					spellinfo = GetSpellInfo(spellid) spelllinkinfo = GetSpellLink(spellid)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					if message ~= "" then
						if RSA.db.profile.Monk.Spells.Resuscitate.Local == true then
							RSA.Print_LibSink(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.Yell == true then
							RSA.Print_Yell(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.Whisper == true and dest ~= pName then
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							--RSA.Print_Whisper(string.gsub(message, ".%a+.", RSA.String_Replace), full_destName)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, ".%a+.", RSA.String_Replace), RSA.db.profile.Monk.Spells.Resuscitate.CustomChannel.Channel)
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.Say == true then
							RSA.Print_Say(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.Party == true then
							if RSA.db.profile.Monk.Spells.Resuscitate.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Monk.Spells.Resuscitate.Raid == true then
							if RSA.db.profile.Monk.Spells.Resuscitate.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
					end
				end
			end
		end
	end
	RSA.ResMon = RSA.ResMon or CreateFrame("Frame", "RSA:RM")
	RSA.ResMon:RegisterEvent("UNIT_SPELLCAST_SENT")
	RSA.ResMon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	RSA.ResMon:SetScript("OnEvent", MonkRess)
end

function RSA_Monk:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
end
