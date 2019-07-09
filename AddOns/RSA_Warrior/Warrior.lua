------------------------------------------------
---- Raeli's Spell Announcer Warrior Module ----
------------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_Warrior = RSA:NewModule('Warrior')
function RSA_Warrior:OnInitialize()
	if RSA.db.profile.General.Class == 'WARRIOR' then
		RSA_Warrior:SetEnabledState(true)
	else
		RSA_Warrior:SetEnabledState(false)
	end
end -- End OnInitialize
function RSA_Warrior:OnEnable()
	local MonitorConfig_Warrior = {
		player_profile = RSA.db.profile.Warrior,
		SPELL_CAST_SUCCESS = {
			[871] = { -- SHIELD WALL
				profile = 'ShieldWall'
			},
			[12975] = { -- LAST STAND
				profile = 'LastStand'
			},
			[184364] = { -- ENRAGED REGENERATION
				profile = 'EnragedRegeneration'
			},
			--[[[97462] = { -- RALLYING CRY
				profile = 'RallyingCry'
			},]]--
		},
		SPELL_AURA_APPLIED = {		
			[355] = { -- TAUNT
				profile = 'Taunt',
				section = 'Cast',
				replacements = { TARGET = 1 },
			},
			[1719] = { -- RECKLESSNESS
				profile = 'Recklessness',
			},
			[118038] = { -- DIE BY THE SWORD
				profile = 'DieByTheSword',
			},
			[132169] = { -- STORM BOLT
				profile = 'StormBolt',
				replacements = { TARGET = 1 },
				linkID = 107570
			},
			--[[[132168] = { -- SHOCKWAVE
				profile = 'Shockwave',
				replacements = { TARGET = 1 },
				tracker = 2,
				linkID = 46968
			},]]--
			[147833] = { -- INTERCEPT
				profile = 'Intercept',
				replacements = { TARGET = 1 },
				linkID = 198758
			},
			[203524] = { -- Neltharion's Fury, Protection Artifact
				profile = 'NeltharionsFury',
			},
			[213915] = { -- Mass Spell Reflection
				profile = 'MassSpellReflection',
				targetIsMe = 1
			},
			[1160] = { -- DEMORALIZING SHOUT
				profile = 'DemoralizingShout',
				tracker = 2
			},
			[97463] = { -- COMMANDING SHOUT
				profile = 'RallyingCry',
				linkID = 97462,
				tracker = 2
			},
			[5246] = { -- Intimidating Shout
				profile = 'IntimidatingShout',
				tracker = 2
			},
		},
		SPELL_AURA_REMOVED = {
			[871] = { -- SHIELD WALL
				profile = 'ShieldWall',
				section = 'End',
			},
			[12975] = { -- LAST STAND
				profile = 'LastStand',
				section = 'End',
			},
			[184364] = { -- ENRAGED REGENERATION
				profile = 'EnragedRegeneration',
				section = 'End',
			},
			[1719] = { -- RECKLESSNESS
				profile = 'Recklessness',
				section = 'End',
			},
			[118038] = { -- DIE BY THE SWORD
				profile = 'DieByTheSword',
				section = 'End',
			},
			[132169] = { -- STORM BOLT
				profile = 'StormBolt',
				replacements = { TARGET = 1 },
				section = 'End',
				linkID = 107570
			},
			--[[[132168] = { -- SHOCKWAVE
				profile = 'Shockwave',
				replacements = { TARGET = 1 },
				section = 'End',
				tracker = 1,
				linkID = 46968
			},]]--
			[147833] = { -- INTERCEPT
				profile = 'Intercept',
				replacements = { TARGET = 1 },
				section = 'End',
				linkID = 198758
			},
			[203524] = { -- Neltharion's Fury, Protection Artifact
				profile = 'NeltharionsFury',
				section = 'End'
			},
			[213915] = { -- Mass Spell Reflection
				profile = 'MassSpellReflection',
				section = 'End',
				targetIsMe = 1
			},
			[1160] = { -- DEMORALIZING SHOUT
				profile = 'DemoralizingShout',
				section = 'End',
				tracker = 1
			},
			[97463] = { -- COMMANDING SHOUT
				profile = 'RallyingCry',
				section = 'End',
				linkID = 97462,
				tracker = 1
			},
			[5246] = { -- Intimidating Shout
				profile = 'IntimidatingShout',
				section = 'End',
				tracker = 1
			},
		},
		SPELL_MISSED = {
			[355] = {-- TAUNT
				profile = 'Taunt',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[6552] = {-- PUMMEL
				profile = 'Pummel',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
		SPELL_INTERRUPT = {
			[6552] = { -- PUMMEL
				profile = 'Pummel',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Warrior, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	RSA.db.profile.Modules.Warrior = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
	local pName = UnitName('player')
	local RSA_ReflectSource = 'RSADummy'
	local RSA_ReflectAmount = 0
	local function Warrior_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if source == RSA_ReflectSource and dest == RSA_ReflectSource then -- It damaged itself.
			RSA_ReflectAmount = missType
			spellinfo = GetSpellInfo(spellID)
			spelllinkinfo = GetSpellLink(spellID)
			local full_destName,dest = RSA.RemoveServerNames(dest)
			local message, messagemax, messagerandom
			if event == 'SPELL_MISSED' then
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = source}
				messagemax = #RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Resist
				if messagemax == 0 then return end
				messagerandom  = math.random(messagemax)
				message = RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Resist[messagerandom]
			elseif missType == 'DEBUFF' then 
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = source}
				messagemax = #RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Debuff
				if messagemax == 0 then return end
				messagerandom  = math.random(messagemax)
				message = RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Debuff[messagerandom]
			else
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = source, ["[AMOUNT]"] = RSA_ReflectAmount}
				messagemax = #RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Damage
				if messagemax == 0 then return end
				messagerandom  = math.random(messagemax)
				message = RSA.db.profile.Warrior.Spells.SpellReflect.Messages.Damage[messagerandom]
			end
			if messagemax == 0 then return end
			if message ~= '' then
				if RSA.db.profile.Warrior.Spells.SpellReflect.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Warrior.Spells.SpellReflect.CustomChannel.Channel)
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.Party == true then
					if RSA.db.profile.Warrior.Spells.SpellReflect.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Warrior.Spells.SpellReflect.Raid == true then
					if RSA.db.profile.Warrior.Spells.SpellReflect.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
		end	
		if dest == pName then
			if missType == 'REFLECT' then -- SPELL REFLECT
				RSA_ReflectSource = source -- Track which unit we reflected.
			end -- SPELL REFLECT
		end
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Warrior.Reminders.SpellName
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
	RSA.CombatLogMonitor:SetScript('OnEvent', Warrior_Spells)
end -- END ON ENABLED
function RSA_Warrior:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
end
