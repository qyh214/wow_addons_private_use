-----------------------------------------------
---- Raeli's Spell Announcer Hunter Module ----
-----------------------------------------------
local RSA = LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local RSA_Hunter = RSA:NewModule("Hunter")
function RSA_Hunter:OnInitialize()
	if RSA.db.profile.General.Class == "HUNTER" then
		RSA_Hunter:SetEnabledState(true)
	else
		RSA_Hunter:SetEnabledState(false)
	end
end -- End OnInitialize
function RSA_Hunter:OnEnable()
	RSA.db.profile.Modules.Hunter = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName("player")
	local Config_FreezingTrap = {
		profile = 'FreezingTrap',
		replacements = { TARGET = 1 },
		section = 'Placed'
	}
	local Config_Tranq = { -- Enrage Dispels
		profile = 'Tranq',
		section = "Cast",
		replacements = { TARGET = 1, extraSpellName = "[AURA]", extraSpellLink = "[AURALINK]" }
	}
	local Config_Lust = { -- Heroism spells
		profile = 'AncientHysteria',
		targetIsMe = 1
	}
	local Config_Lust_End = {
		profile = 'AncientHysteria',
		section = 'End',
		targetIsMe = 1
	}
	local Config_Ress = { -- Battle Resses
		profile = 'BattleRess',
		section = 'Cast',
		replacements = { TARGET = 1 },
	}
	local MonitorConfig_Hunter = {
		player_profile = RSA.db.profile.Hunter,
		SPELL_RESURRECT = {
			[159956] = Config_Ress, -- Moth Dust of Life
			[159931] = Config_Ress, -- Crane Gift of Chi-Ji
		},
		SPELL_DISPEL = {
			[19801] = Config_Tranq, -- Tranquilizing Shot
			[264263] = Config_Tranq, -- Bat Sonic Blast
			[264264] = Config_Tranq, -- Nether Ray Nether Shock
			[264028] = Config_Tranq, -- Crane Chi-Ji's Tranquility
			[264266] = Config_Tranq, -- Stag Nature's Grace
			[264265] = Config_Tranq, -- Spirit Beast Spirit Shock
			[264055] = Config_Tranq, -- Moth Serenity Dust
			[264056] = Config_Tranq, -- Sporebat Spore Cloud
			[264262] = Config_Tranq, -- Water Strider Soothing Water
		},
		SPELL_AURA_APPLIED = {
			[90355] = Config_Lust, -- Core Hound Ancient Hysteria
			[160452] = Config_Lust, -- Nether Ray Netherwinds
			[264667] = Config_Lust, -- Primal Rage Pet Specialization
			[3355] = { -- FREEZING TRAP
				profile = 'FreezingTrap',
				replacements = { TARGET = 1 }
			},
			[34477] = { -- MISDIRECTION
				profile = 'Misdirection',
				replacements = { TARGET = 1 }
			},
			[24394] = { -- INTIMIDATION
				profile = 'Intimidation',
				replacements = { TARGET = 1 }
			},
			[199483] = { -- CAMOUFLAGE
				profile = 'Camoflage',
				targetIsMe = 1
			},
			[117526] = { -- Binding Shot
				profile = 'BindingShot',
				linkID = 109248,
				tracker = 2
			},
		},
		SPELL_AURA_REMOVED = {
			[90355] = Config_Lust_End, -- Core Hound Ancient Hysteria
			[160452] = Config_Lust_End, -- Nether Ray Netherwinds
			[264667] = Config_Lust_End, -- Primal Rage Pet Specialization
			[5116] = { -- CONCUSSIVE SHOT
				profile = 'ConcussiveShot',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[3355] = { -- FREEZING TRAP
				profile = 'FreezingTrap',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[186265] = { -- Aspect of the Turtle
				profile = 'Deterrence',
				section = 'End'
			},
			[199483] = { -- CAMOUFLAGE
				profile = 'Camoflage',
				section = 'End',
				targetIsMe = 1
			},
			[53480] = { -- ROAR OF SACRIFICE
				profile = 'RoarOfSacrifice',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[24394] = { -- INTIMIDATION
				profile = 'Intimidation',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[117526] = { -- Binding Shot
				profile = 'BindingShot',
				section = 'End',
				linkID = 109248,
				tracker = 1
			},
		},
		SPELL_CAST_SUCCESS = {
			[187650] = Config_FreezingTrap,
			[5116] = { -- CONCUSSIVE SHOT
				profile = 'ConcussiveShot',
				replacements = { TARGET = 1 }
			},
			[186265] = { -- Aspect of the Turtle
				profile = 'Deterrence'
			},
			[109248] = { -- Binding Shot
				profile = 'BindingShot',
				section = 'Placed'
			},
			[19577] = { -- INTIMIDATION
				profile = 'Intimidation',
				section = 'Cast'
			},
			[53480] = { -- ROAR OF SACRIFICE
				profile = 'RoarOfSacrifice',
				replacements = { TARGET = 1 }
			},
			[90361] = {
				profile = 'SpiritMend',
				section = 'Cast',
				replacements = { TARGET = 1 }
			},
		},
		SPELL_INTERRUPT = {
			[147362] = { -- COUNTER SHOT
				profile = 'SilencingShot',
				section = "Interrupt",
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			},
			[187707] = { -- MUZZLE
				profile = 'Muzzle',
				section = "Interrupt",
				replacements = { TARGET = 1, extraSpellName = "[TARSPELL]", extraSpellLink = "[TARLINK]" }
			},
		},
		SPELL_MISSED = {
			[147362] = {-- COUNTER SHOT
				profile = 'SilencingShot',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[187707] = {-- MUZZLE
				profile = 'Muzzle',
				section = 'Resist',
				immuneSection = "Immune",
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Hunter, UnitGUID("player"))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local spellinfo,spelllinkinfo,extraspellinfo,extraspellinfolink,missinfo
	local RSA_Misdirection_Damage = 0.0
	local RSA_MDPTimer = CreateFrame("Frame", "RSA:MDPTimer")
	local MDPTimeElapsed = 0.0
	local RSA_MisdirectionTracker = CreateFrame("Frame", "RSA:MDT")
	local function Hunter_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == "SPELL_CAST_SUCCESS" and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Hunter.Reminders.SpellName
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
			if event == "SPELL_AURA_APPLIED" then
				if spellID == 34477 and not RSA.IsMe(destFlags) then -- MISDIRECTION
					---- START MISDIRECTION TRACKING ----
					RSA_MisdirectionTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					local function MisdirectionTracker()
						local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
						local amount, overkill = spellID, spellName
						if source == pName then
							if event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
								if overkill ~= -1 then
									overkill = 0
								end
								RSA_Misdirection_Damage = RSA_Misdirection_Damage + (amount - overkill)
							elseif event == "SWING_DAMAGE" then
								if overkill ~= -1 then
									overkill = 0
								end
								RSA_Misdirection_Damage = RSA_Misdirection_Damage + (spellID - spellName)
							end
						end
					end
					RSA_MisdirectionTracker:SetScript("OnEvent", MisdirectionTracker)
					MDPTimeElapsed = 0.0
					local function SBMDPTimer(self, elapsed)
						MDPTimeElapsed = MDPTimeElapsed + elapsed
						if MDPTimeElapsed < 20 then return end
						MDPTimeElapsed = MDPTimeElapsed - floor(MDPTimeElapsed)
						if RSA_Misdirection_Damage == 0.0 then
							RSA_MisdirectionTracker:SetScript("OnEvent", nil)
						end
						RSA_MDPTimer:SetScript("OnUpdate", nil)
					end
					RSA_MDPTimer:SetScript("OnUpdate", SBMDPTimer)
					---- END OF MISDIRECTION TRACKING ----
				end -- MISDIRECTION
			end -- IF EVENT IS SPELL_AURA_APPLIED
			if event == "SPELL_AURA_REMOVED" then
				if spellID == 34477 then -- MISDIRECTION
					spellinfo = GetSpellInfo(spellID)
					spelllinkinfo = GetSpellLink(spellID)
					RSA_MisdirectionTracker:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					local full_destName,dest = RSA.RemoveServerNames(dest)
					RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest, ["[AMOUNT]"] = RSA_Misdirection_Damage,}
					local messagemax = #RSA.db.profile.Hunter.Spells.Misdirection.Messages.End
					if messagemax == 0 then return end
					local messagerandom = math.random(messagemax)
					local message = RSA.db.profile.Hunter.Spells.Misdirection.Messages.End[messagerandom]
					if message ~= "" then
						if RSA.db.profile.Hunter.Spells.Misdirection.Local == true then
							RSA.Print_LibSink(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.Yell == true then
							RSA.Print_Yell(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.Whisper == true and dest ~= pName then
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"], ["[AMOUNT]"] = RSA_Misdirection_Damage or 0,}
							RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
							--RSA.Print_Whisper(string.gsub(message, ".%a+.", RSA.String_Replace), full_destName)
							RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest, ["[AMOUNT]"] = RSA_Misdirection_Damage or 0,}
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.CustomChannel.Enabled == true then
							RSA.Print_Channel(string.gsub(message, ".%a+.", RSA.String_Replace), RSA.db.profile.Hunter.Spells.Misdirection.CustomChannel.Channel)
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.Say == true then
							RSA.Print_Say(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.SmartGroup == true then
							RSA.Print_SmartGroup(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.Party == true then
							if RSA.db.profile.Hunter.Spells.Misdirection.SmartGroup == true and GetNumGroupMembers() == 0 then return end
								RSA.Print_Party(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
						if RSA.db.profile.Hunter.Spells.Misdirection.Raid == true then
							if RSA.db.profile.Hunter.Spells.Misdirection.SmartGroup == true and GetNumGroupMembers() > 0 then return end
							RSA.Print_Raid(string.gsub(message, ".%a+.", RSA.String_Replace))
						end
					end
					RSA_MisdirectionTracker:SetScript("OnEvent", nil)
					RSA_Misdirection_Damage = 0.0
				end -- MISDIRECTION
			end -- IF EVENT IS SPELL_AURA_REMOVED
			MonitorAndAnnounce(self, "player", timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript("OnEvent", Hunter_Spells)
end -- END ON ENABLED
function RSA_Hunter:OnDisable()
	RSA.CombatLogMonitor:SetScript("OnEvent", nil)
end
