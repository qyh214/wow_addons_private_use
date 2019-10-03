----------------------------------------------
---- Raeli's Spell Announcer Druid Module ----
----------------------------------------------
local RSA = LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local LRI = LibStub("LibResInfo-1.0",true)
local RSA_Druid = RSA:NewModule("Druid")

function RSA_Druid:OnInitialize()
	if RSA.db.profile.General.Class == "DRUID" then
		RSA_Druid:SetEnabledState(true)
	else
		RSA_Druid:SetEnabledState(false)
	end
end

local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo

function RSA_Druid:OnEnable()
	--if LRI then LRI.RegisterCallback(RSA, "LibResInfo_ResCastStarted", "Resurrect") end
	RSA.db.profile.Modules.Druid = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName("player")
	local Config_StampedingRoar = { -- STAMPEDING ROAR
		profile = 'StampedingRoar',
		targetIsMe = 1
	}
	local Config_StampedingRoar_End = { -- STAMPEDING ROAR
		profile = 'StampedingRoar',
		section = 'End',
		targetIsMe = 1
	}
	local Config_RemoveCorruption = { -- REMOVE CORRUPTION
		profile = 'RemoveCorruption',
		section = "Cast",
		replacements = { TARGET = 1, extraSpellName = "[AURA]", extraSpellLink = "[AURALINK]" }
	}
	local MonitorConfig_Druid = {
		player_profile = RSA.db.profile.Druid,
		SPELL_RESURRECT = {
			[50769] = { -- Revive
				profile = 'Revive',
				section = 'End',
				replacements = { TARGET = 1 },
			},
			[20484] = { -- Rebirth
				profile = 'Rebirth',
				section = 'End',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_DISPEL = {
			[2782] = Config_RemoveCorruption, -- REMOVE CORRUPTION
			[88423] = Config_RemoveCorruption, -- NATURE'S CURE
			[2908] = { -- SOOTHE
				profile = 'Soothe',
				section = "Cast",
				replacements = { TARGET = 1, extraSpellName = "[AURA]", extraSpellLink = "[AURALINK]" }
			},
		},
		SPELL_AURA_APPLIED = {
			[106898] = Config_StampedingRoar,
			[77764] = Config_StampedingRoar,
			[77761] = Config_StampedingRoar,
			[6795] = { -- GROWL
				profile = 'Growl',
				section = "Cast",
				replacements = { TARGET = 1 }
			},
			[33786] = { -- CYCLONE
				profile = 'Cyclone',
				replacements = { TARGET = 1 }
			},
			[99] = { -- INCAPACITATING ROAR
				profile = 'IncapacitatingRoar',
				tracker = 2
			},
			[339] = { -- ENTANGLING ROOTS
				profile = 'Roots',
				replacements = { TARGET = 1 }
			},
			[102342] = { -- IRONBARK
				profile = 'Ironbark',
				replacements = { TARGET = 1 }
			},
			[33891] = { -- TREE OF LIFE
				profile = 'TreeOfLife'
			},
			[22812] = { -- BARKSKIN
				profile = 'Barkskin'
			},
			[124974] = { -- NATURE'S VIGIL
				profile = 'NaturesVigil'
			},
			[5211] = { -- MIGHTY BASH
				profile = 'MightyBash',
				replacements = { TARGET = 1 }
			},
			[29166] = { -- INNERVATE
				profile = 'Innervate',
				replacements = { TARGET = 1 }
			},
			[192081] = { -- IRONFUR
				profile = 'Ironfur'
			},
			[200851] = { -- Rage Of The Sleeper
				profile = 'RageOfTheSleeper'
			},
			[201664] = { -- Demoralizing Roar
				profile = 'DemoralizingRoar',
				tracker = 2
			},
			[102359] = { -- Mass Entanglement
				profile = 'MassEntanglement',
				tracker = 2
			},
			[2637] = { -- Hibernate
				profile = 'Hibernate',
				replacements = { TARGET = 1 },
				section = "Cast",
			},
		},
		SPELL_CAST_START = {
			[212040] = { -- REVITALIZE
				profile = 'Revitalize'
			},
		},
		SPELL_CAST_SUCCESS = {
			[212040] = { -- REVITALIZE
				profile = 'Revitalize',
				section = 'End'
			},
			[22842] = { -- FRENZIED REGENERATION
				profile = 'FrenziedRegeneration',
				section = "Cast"
			},
			[102793] = { -- URSOL'S VORTEX
				profile = 'UrsolsVortex',
				section = "Cast"
			},
			[205636] = { -- Force of Nature
				profile = 'Treants',
				section = "Cast"
			},
			[740] = { -- TRANQUILITY
				profile = 'Tranquility'
			},
			[61336] = { -- SURVIVAL INSTINCTS
				profile = 'SurvivalInstincts'
			},
			[106951] = { -- Berserk
				profile = 'Berserk',
			},
		},
		SPELL_AURA_REMOVED = {
			[106898] = Config_StampedingRoar_End,
			[77764] = Config_StampedingRoar_End,
			[77761] = Config_StampedingRoar_End,
			[61336] = { -- SURVIVAL INSTINCTS
				profile = 'SurvivalInstincts',
				section = 'End'
			},
			[33891] = { -- TREE OF LIFE
				profile = 'TreeOfLife',
				section = 'End'
			},
			[22812] = { -- BARKSKIN
				profile = 'Barkskin',
				section = 'End'
			},
			[124974] = { -- NATURE'S VIGIL
				profile = 'NaturesVigil',
				section = 'End'
			},
			[740] = { -- TRANQUILITY
				profile = 'Tranquility',
				section = 'End'
			},
			[106951] = { -- Berserk
				profile = 'Berserk',
				section = 'End'
			},
			[33786] = { -- CYCLONE
				profile = 'Cyclone',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[99] = { -- INCAPACITATING ROAR
				profile = 'IncapacitatingRoar',
				section = 'End',
				tracker = 1
			},
			[339] = { -- ENTANGLING ROOTS
				profile = 'Roots',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[102342] = { -- IRONBARK
				profile = 'Ironbark',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[5211] = { -- MIGHTY BASH
				profile = 'MightyBash',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[29166] = { -- INNERVATE
				profile = 'Innervate',
				replacements = { TARGET = 1 },
				section = 'End'
			},
			[192081] = { -- IRONFUR
				profile = 'Ironfur',
				section = 'End'
			},
			[200851] = { -- Rage Of The Sleeper
				profile = 'RageOfTheSleeper',
				section = 'End'
			},
			[201664] = { -- Demoralizing Roar
				profile = 'DemoralizingRoar',
				section = "End",
				tracker = 1
			},
			[102359] = { -- Mass Entanglement
				profile = 'MassEntanglement',
				section = "End",
				tracker = 1
			},
			[2637] = { -- Hibernate
				profile = 'Hibernate',
				replacements = { TARGET = 1 },
				section = "End",
			},
		},
		SPELL_INTERRUPT = {
			--[[[32747] = { -- FAE SILENCE (spell id is general interrupt)
				profile = 'FaeSilence',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			},]]--
			[93985] = { -- SKULL BASH
				profile = 'SkullBash',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			},
			[97547] = { -- SOLAR BEAM
				profile = 'SolarBeam',
				section = "Interrupt",
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			},
		},
		SPELL_MISSED = {
			[6795] = {-- GROWL
				profile = 'Growl',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[93985] = {-- SKULL BASH
				profile = 'SkullBash',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[2637] = { -- Hibernate
				profile = 'Hibernate',
				replacements = { TARGET = 1 },
				section = 'Resist',
				immuneSection = "Immune",
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Druid, UnitGUID("player"))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local function Druid_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == "SPELL_CAST_SUCCESS" and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Druid.Reminders.SpellName
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
			MonitorAndAnnounce(self, "player", timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript("OnEvent", Druid_Spells)
	------------------------------
	---- Resurrection Monitor ----
	------------------------------
	local ResTarget = L["Unknown"]
	local Ressed
	local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
	local function Druid_Resurrections(self, event, source, dest, _, spellid)
		if UnitName(source) == pName then
			if spellid == 50769 and RSA.db.profile.Druid.Spells.Revive.Messages.Start ~= "" then -- REVIVE
				if event == "UNIT_SPELLCAST_SENT" then
					local messagemax = #RSA.db.profile.Druid.Spells.Revive.Messages.Start
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Druid.Spells.Revive.Messages.Start[messagerandom]
					Ressed = false
					if (dest == L["Unknown"] or dest == nil) then
						if UnitExists("target") ~= 1 or (UnitHealth("target") > 1 and UnitIsDeadOrGhost("target") ~= 1) then
							if GameTooltipTextLeft1:GetText() == nil then
								dest = L["Unknown"]
								ResTarget = L["Unknown"]
							else
								dest = string.gsub(GameTooltipTextLeft1:GetText(), L["Corpse of "], "")
								ResTarget = string.gsub(GameTooltipTextLeft1:GetText(), L["Corpse of "], "")
							end
						else
							dest = UnitName("target")
							ResTarget = UnitName("target")
						end
					else
						ResTarget = dest
					end
					local full_destName,dest = RSA.RemoveServerNames(dest)
					spellinfo = GetSpellInfo(spellid) spelllinkinfo = GetSpellLink(spellid)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					if message ~= "" then
						if RSA.db.profile.Druid.Spells.Revive.Local == true then
							RSA.Print_LibSink(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Revive.Yell == true then
							RSA.Print_Yell(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Revive.Whisper == true and dest ~= pName then
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							--RSA.Print_Whisper(string.gsub(message, ".%a+.", RSA.String_Replace), full_destName)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
						end
						if RSA.db.profile.Druid.Spells.Revive.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, ".%a+.", RSA.String_Replace), RSA.db.profile.Druid.Spells.Revive.CustomChannel.Channel)
						end
						if RSA.db.profile.Druid.Spells.Revive.Say == true then
							RSA.Print_Say(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Revive.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Revive.Party == true then
							if RSA.db.profile.Druid.Spells.Revive.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Revive.Raid == true then
							if RSA.db.profile.Druid.Spells.Revive.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
					end
				end
			end
			if spellid == 20484 and RSA.db.profile.Druid.Spells.Rebirth.Messages.Start ~= "" then -- REBIRTH
				if event == "UNIT_SPELLCAST_SENT" then
					local messagemax = #RSA.db.profile.Druid.Spells.Rebirth.Messages.Start
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Druid.Spells.Rebirth.Messages.Start[messagerandom]
					Ressed = false
					if (dest == L["Unknown"] or dest == nil) then
						if UnitExists("target") ~= 1 or (UnitHealth("target") > 1 and UnitIsDeadOrGhost("target") ~= 1) then
							if GameTooltipTextLeft1:GetText() == nil then
								dest = L["Unknown"]
								ResTarget = L["Unknown"]
							else
								dest = string.gsub(GameTooltipTextLeft1:GetText(), L["Corpse of "], "")
								ResTarget = string.gsub(GameTooltipTextLeft1:GetText(), L["Corpse of "], "")
							end
						else
							dest = UnitName("target")
							ResTarget = UnitName("target")
						end
					else
						ResTarget = dest
					end
					local full_destName,dest = RSA.RemoveServerNames(dest)
					spellinfo = GetSpellInfo(spellid) spelllinkinfo = GetSpellLink(spellid)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					if message ~= "" then
						if RSA.db.profile.Druid.Spells.Rebirth.Local == true then
							RSA.Print_LibSink(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Rebirth.Yell == true then
							RSA.Print_Yell(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Rebirth.Whisper == true and dest ~= pName then
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
						end
						if RSA.db.profile.Druid.Spells.Rebirth.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, ".%a+.", RSA.String_Replace), RSA.db.profile.Druid.Spells.Rebirth.CustomChannel.Channel)
						end
						if RSA.db.profile.Druid.Spells.Rebirth.Say == true then
							RSA.Print_Say(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Rebirth.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Rebirth.Party == true then
							if RSA.db.profile.Druid.Spells.Rebirth.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Druid.Spells.Rebirth.Raid == true then
							if RSA.db.profile.Druid.Spells.Rebirth.SmartGroup == true and GetNumGroupMembers() > 0 then return end
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
	RSA.ResMon:SetScript("OnEvent", Druid_Resurrections)
end

function RSA_Druid:OnDisable()
	RSA.CombatLogMonitor:SetScript("OnEvent", nil)
	RSA.ResMon:SetScript("OnEvent", nil)
	if LRI then LRI.UnregisterAllCallbacks(RSA) end
end
