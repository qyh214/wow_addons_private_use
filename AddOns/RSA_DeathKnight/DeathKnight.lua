-----------------------------------------------------
---- Raeli's Spell Announcer Death Knight Module ----
-----------------------------------------------------
local RSA = LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local RSA_DeathKnight = RSA:NewModule("DeathKnight")
function RSA_DeathKnight:OnInitialize()
	if RSA.db.profile.General.Class == "DEATHKNIGHT" then
		RSA_DeathKnight:SetEnabledState(true)
	else
		RSA_DeathKnight:SetEnabledState(false)
	end
end -- End OnInitialize

local ConsumptionAmount = 0
local ConsumptionCounter = 0
local DeathKnightSpells = RSA.db.profile.DeathKnight.Spells

function RSA_DeathKnight:OnEnable()
	RSA.db.profile.Modules.DeathKnight = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName("player")
	local Config_DeathGrip_Missed = { -- DEATH GRIP MISSED
		profile = 'DeathGrip',
		section = 'Resist',
		immuneSection = "Immune",
		replacements = { TARGET = 1, MISSTYPE = 1 },
	}
	local MonitorConfig_DeathKnight = {
		player_profile = RSA.db.profile.DeathKnight,
		SPELL_INTERRUPT = {
			[47528] = { -- MIND FREEZE
				profile = 'MindFreeze',
				section = "Interrupt",
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			}
		},
		SPELL_CAST_SUCCESS = {
			[205223] = { -- CONSUMPTION
				profile = 'Consumption'
			},
			[48707] = { -- ANTI MAGIC SHELL
				profile = 'AMS'
			},
			[51052] = { -- ANTI MAGIC ZONE
				profile = 'AMZ',
				section = "Cast"
			},
			[42650] = { -- ARMY OF THE DEAD
				profile = 'Army',
				section = "Cast"
			},
			[49028] = { -- DANCING RUNE WEAPON
				profile = 'DancingRuneWeapon'
			},
			[48792] = { -- ICEBOUND FORTITUDE
				profile = 'IceboundFortitude'
			},
			[51271] = { -- PILLAR OF FROST
				profile = 'PillarOfFrost'
			},
			[55233] = { -- VAMPIRIC BLOOD
				profile = 'VampiricBlood'
			},
			[49576] = { -- DEATH GRIP
				profile = 'DeathGrip',
				section = "Cast",
				replacements = { TARGET = 1 }
			},
		},
		SPELL_RESURRECT = {
			[61999] = { -- RAISE ALLY
				profile = 'RaiseAlly',
				section = "Cast",
				replacements = { TARGET = 1 }
			},
		},
		SPELL_AURA_APPLIED = {
			[108194] = { -- ASPHYXIATE
				profile = 'Asphyxiate',
				replacements = { TARGET = 1 }
			},
			[221562] = { -- ASPHYXIATE
				profile = 'Asphyxiate',
				replacements = { TARGET = 1 }
			},
			[56222] ={ -- DARK COMMAND
				profile = 'DarkCommand',
				section = "Cast",
				replacements = { TARGET = 1 }
			},
			[116888] = { -- PURGATORY
				profile = 'Purgatory'
			},
			[194679] = { -- RUNE TAP
				profile = 'RuneTap'
			},
			[47476] = { -- STRANGULATE
				profile = 'Strangulate',
				replacements = { TARGET = 1 }
			}
		},
		SPELL_AURA_REMOVED = {
			[48707] = { -- ANTI MAGIC SHELL
				profile = 'AMS',
				section = 'End'
			},
			[108194] = { -- ASPHYXIATE
				profile = 'Asphyxiate',
				replacements = { TARGET = 1 },
				section = 'End'
			},
			[221562] = { -- ASPHYXIATE
				profile = 'Asphyxiate',
				replacements = { TARGET = 1 },
				section = 'End'
			},
			[81256] = { -- DANCING RUNE WEAPON
				profile = 'DancingRuneWeapon',
				section = 'End'
			},
			[48792] = { -- ICEBOUND FORTITUDE
				profile = 'IceboundFortitude',
				section = 'End'
			},
			[51271] = { -- PILLAR OF FROST
				profile = 'PillarOfFrost',
				section = 'End'
			},
			[116888] = { -- PURGATORY
				profile = 'Purgatory',
				section = 'End'
			},
			[194679] = { -- RUNE TAP
				profile = 'RuneTap',
				section = 'End'
			},
			[47476] = { -- STRANGULATE
				profile = 'Strangulate',
				replacements = { TARGET = 1 },
				section = 'End'
			},
			[55233] = { -- VAMPIRIC BLOOD
				profile = 'VampiricBlood',
				section = 'End'
			}
		},
		SPELL_MISSED = {
			[49576] = Config_DeathGrip_Missed,
			[108194] = {-- Asphyxiate
				profile = 'Asphyxiate',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[221562] = {-- Asphyxiate
				profile = 'Asphyxiate',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[47476] = {-- Strangulate
				profile = 'Strangulate',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[56222] = {-- DARK COMMAND
				profile = 'DarkCommand',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[47528] = {-- MIND FREEZE
				profile = 'MindFreeze',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_DeathKnight, UnitGUID("player"))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
	local function DeathKnight_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == "SPELL_CAST_SUCCESS" and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.DeathKnight.Reminders.SpellName
				if spellName == ReminderSpell and (dest == pName or dest == nil) then
					RSA.Reminder:SetScript("OnUpdate", nil)
					if RSA.db.profile.Reminders.RemindChannels.Chat == true then
						RSA.Print_Self(ReminderSpell .. L[" Refreshed!"])
					end
					if RSA.db.profile.Reminders.RemindChannels.RaidWarn == true then
						RSA.Print_Self_RW(ReminderSpell .. L[" Refreshed!"])
					end
				end
			end -- BUFF REMINDER
			if spellID == 205223 and event == "SPELL_CAST_SUCCESS" then
				ConsumptionAmount = 0
			end
			if spellID == 205224 then
				ConsumptionAmount = ConsumptionAmount + (missType - overheal)
			end
			if event == "SPELL_DAMAGE" and spellID == 205223 then -- CONSUMPTION
				ConsumptionCounter = ConsumptionCounter +1
			end
			if event == "SPELL_HEAL" and spellID == 205224 then -- CONSUMPTION
				local messagemax = #RSA.db.profile.DeathKnight.Spells.Consumption.Messages.Heal
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.DeathKnight.Spells.Consumption.Messages.Heal[messagerandom]
				spellinfo = GetSpellInfo(spellID) spelllinkinfo = GetSpellLink(spellID)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
				if message ~= "" then
					if RSA.db.profile.DeathKnight.Spells.Consumption.Local == true then
						RSA.Print_LibSink(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.Yell == true then
						RSA.Print_Yell(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, ".%a+.", RSA.String_Replace), RSA.db.profile.DeathKnight.Spells.Consumption.CustomChannel.Channel)
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.Say == true then
						RSA.Print_Say(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.Party == true then
						if RSA.db.profile.DeathKnight.Spells.Consumption.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
					if RSA.db.profile.DeathKnight.Spells.Consumption.Raid == true then
						if RSA.db.profile.DeathKnight.Spells.Consumption.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, ".%a+.", RSA.String_Replace))
					end
				end
			end
			MonitorAndAnnounce(self, "player", timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript("OnEvent", DeathKnight_Spells)
end -- END ON ENABLED
function RSA_DeathKnight:OnDisable()
	RSA.CombatLogMonitor:SetScript("OnEvent", nil)
end
