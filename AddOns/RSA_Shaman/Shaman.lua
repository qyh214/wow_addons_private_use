-----------------------------------------------
---- Raeli's Spell Announcer Shaman Module ----
-----------------------------------------------
local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local LRI = LibStub('LibResInfo-1.0',true)
local RSA_Shaman = RSA:NewModule('Shaman')

local SpiritLink_GUID,TremorTotem_GUID,WindRush_GUID,Protection_GUID,LightningSurge_GUID,Cloudburst_GUID,EarthenShield_GUID,Grounding_GUID,EarthGrab_GUID
local Protection_Cast,LightningCounter,Cloudburst_Announced,GroundingCounter

function RSA_Shaman:OnInitialize()
	if RSA.db.profile.General.Class == 'SHAMAN' then
		RSA_Shaman:SetEnabledState(true)
	else
		RSA_Shaman:SetEnabledState(false)
	end
end

function RSA.Resurrect(_, _, target, _, caster)
	if caster ~= 'player' then return end
	local dest = UnitName(target)
	local pName = UnitName('player')
	local spell = 2008
	local messagemax = #RSA.db.profile.Shaman.Spells.AncestralSpirit.Messages.Start
	if messagemax == 0 then return end
	local messagerandom = math.random(messagemax)
	local message = RSA.db.profile.Shaman.Spells.AncestralSpirit.Messages.Start[messagerandom]
	local full_destName
	full_destName,dest = RSA.RemoveServerNames(dest)
	local spellinfo = GetSpellInfo(spell)
	local spelllinkinfo = GetSpellLink(spell)
	RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
	if message ~= '' then
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Local == true then
			RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Yell == true then
			RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Whisper == true and dest ~= pName then
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
			RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
			--RSA.Print_Whisper(string.gsub(message, '.%a+.', RSA.String_Replace), full_destName)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.CustomChannel.Enabled == true then
			RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.AncestralSpirit.CustomChannel.Channel)
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Say == true then
			RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.SmartGroup == true then
			RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Party == true then
			if RSA.db.profile.Shaman.Spells.AncestralSpirit.SmartGroup == true and GetNumGroupMembers() == 0 then return end
			RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
		if RSA.db.profile.Shaman.Spells.AncestralSpirit.Raid == true then
			if RSA.db.profile.Shaman.Spells.AncestralSpirit.SmartGroup == true and GetNumGroupMembers() > 0 then return end
			RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
		end
	end
end

function RSA_Shaman:OnEnable()
	if LRI then LRI.RegisterCallback(RSA, 'LibResInfo_ResCastStarted', 'Resurrect') end
	RSA.db.profile.Modules.Shaman = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local pName = UnitName('player')
	local Config_Ascendance = { -- ASCENDANCE
		profile = 'Ascendance'
	}
	local Config_Ascendance_End = { -- ASCENDANCE
		profile = 'Ascendance',
		section = 'End'
	}
	local MonitorConfig_Shaman = {
		player_profile = RSA.db.profile.Shaman,
		SPELL_RESURRECT = {
			[2008] = { -- AncestralSpirit
				profile = 'AncestralSpirit',
				section = 'End',
				replacements = { TARGET = 1 },
			},
		},
		SPELL_CAST_START = {
			[212048] = { -- ANCESTRAL VISION
				profile = 'AncestralVision'
			},
		},
		SPELL_CAST_SUCCESS = {
			[212048] = { -- ANCESTRAL VISION
				profile = 'AncestralVision',
				section = 'End',
			},
			[108280] = { -- HEALING TIDE TOTEM
				profile = 'HealingTide',
				section = 'Placed',
			},
			[198103] = { -- EARTH ELEMENTAL
				profile = 'EarthElemental'
			},
			[198067] = { -- FIRE ELEMENTAL
				profile = 'FireElemental',
			},
			[98008] = { -- SPIRIT LINK TOTEM
				profile = 'SpiritLink',
				section = 'Placed',
			},
			[8143] = { -- Tremor Totem
				profile = 'TremorTotem',
				section = 'Placed',
			},
			[192077] = { -- WINDRUSH TOTEM
				profile = 'WindRushTotem',
				section = 'Placed',
			},
			[51485] = { -- Earth Grab Totem
				profile = 'EarthGrabTotem',
				section = 'Placed',
			},
			[2825] = { -- BLOODLUST
				profile = 'Heroism'
			},
			[32182] = { -- HEROISM
				profile = 'Heroism'
			},
			[51490] = { -- THUNDERSTORM
				profile = 'Thunderstorm',
				section = 'Cast'
			},
			[108281] = { -- ANCESTRAL GUIDANCE
				profile = 'AncestralGuidance'
			},
			[108271] = { -- ASTRAL SHIFT
				profile = 'AstralShift'
			},
			[51533] = { -- FERAL SPIRIT
				profile = 'FeralSpirit',
				section = 'Cast'
			},
			[21169] = { -- REINCARNATION
				profile = 'Reincarnation',
				section = 'Cast'
			},
			[207399] = { -- Ancestral Protection Totem
				profile = 'AncestralProtection',
				section = 'Placed',
			},
			[192058] = { -- Lightning Surge Totem
				profile = 'LightningSurge',
				section = 'Placed',
			},
			[157153] = { -- Cloudburst Totem
				profile = 'Cloudburst',
				section = 'Placed',
			},
			[201764] = { -- Cloudburst Totem
				profile = 'Cloudburst',
				linkID = 157153,
				section = 'End'
			},
			[198838] = { -- Earthen Shield Totem
				profile = 'EarthenShieldTotem',
				section = 'Placed',
			},
			[204336] = { -- Grounding Totem
				profile = 'GroundingTotem',
				section = 'Placed',
			},
		},
		SPELL_AURA_APPLIED = {
			[51514] = { -- HEX
				profile = 'Hex',
				replacements = { TARGET = 1 }
			},
			[114050] = Config_Ascendance, -- ASCENDANCE
			[114051] = Config_Ascendance, -- ASCENDANCE
			[114052] = Config_Ascendance -- ASCENDANCE
		},
		SPELL_AURA_REMOVED = {
			[198103] = { -- EARTH ELEMENTAL
				profile = 'EarthElemental',
				section = 'End',
			},
			[118291] = { -- FIRE ELEMENTAL
				profile = 'FireElemental',
				section = 'End',
				linkID = 198067,
			},
			[188592] = { -- FIRE ELEMENTAL
				profile = 'FireElemental',
				section = 'End',
				linkID = 198067,
			},
			[108280] = { -- HEALING TIDE TOTEM
				profile = 'HealingTide',
				section = 'End'
			},
			[51514] = { -- HEX
				profile = 'Hex',
				section = 'End',
				replacements = { TARGET = 1 }
			},
			[2825] = { -- BLOODLUST
				profile = 'Heroism',
				section = 'End',
				targetIsMe = 1
			},
			[32182] = { -- HEROISM
				profile = 'Heroism',
				section = 'End',
				targetIsMe = 1
			},
			[114050] = Config_Ascendance_End, -- ASCENDANCE
			[114051] = Config_Ascendance_End, -- ASCENDANCE
			[114052] = Config_Ascendance_End, -- ASCENDANCE
			[108281] = { -- ANCESTRAL GUIDANCE
				profile = 'AncestralGuidance',
				section = 'End'
			},
			[108271] = { -- ASTRAL SHIFT
				profile = 'AstralShift',
				section = 'End'
			}
		},
		SPELL_DISPEL = {
			[370] = { -- PURGE
				profile = 'Purge',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
			[51886] = { -- CLEANSE SPIRIT
				profile = 'CleanseSpirit',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
			[77130] = { -- PURIFY SPIRIT
				profile = 'CleanseSpirit',
				section = 'Dispel',
				replacements = { TARGET = 1, extraSpellName = '[AURA]', extraSpellLink = '[AURALINK]' }
			},
		},
		SPELL_DISPEL_FAILED = {
			[370] = { -- PURGE
				profile = 'Purge',
				section = 'Resist',
				replacements = { TARGET = 1}
			},
		},
		SPELL_INTERRUPT = {
			[57994] = { -- WIND SHEAR
				profile = 'WindShear',
				section = 'Interrupt',
				replacements = { TARGET = 1, extraSpellName = '[TARSPELL]', extraSpellLink = '[TARLINK]' }
			},
		},
		SPELL_MISSED = {
			[57994] = {-- WIND SHEAR
				profile = 'WindShear',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
			[51514] = { -- HEX
				profile = 'Hex',
				section = 'Resist',
				immuneSection = 'Immune',
				replacements = { TARGET = 1, MISSTYPE = 1 },
			},
		},
	}
	RSA.MonitorConfig(MonitorConfig_Shaman, UnitGUID('player'))
	local MonitorAndAnnounce = RSA.MonitorAndAnnounce
	local ResTarget = L["Unknown"]
	local Ressed
	local function Shaman_Spells()
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			if (event == 'SPELL_CAST_SUCCESS' and RSA.db.profile.Modules.Reminders_Loaded == true) then -- Reminder Refreshed
				local ReminderSpell = RSA.db.profile.Shaman.Reminders.SpellName
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
			if event == 'SPELL_SUMMON' then
				if spellID == 98008 then -- SPIRIT LINK TOTEM
					SpiritLink_GUID = destGUID return -- Unit source isn't player. GUID tracking used to ensure we only announce our own.
				end
				if spellID == 8143 then -- SPIRIT LINK TOTEM
					TremorTotem_GUID = destGUID return -- Unit source isn't player. GUID tracking used to ensure we only announce our own.
				end
				if spellID == 192077 then -- WINDRUSH TOTEM
					WindRush_GUID = destGUID return
				end
				if spellID == 51485 then -- Earth Grab Totem
					EarthGrab_GUID = destGUID return
				end
				if spellID == 207399 then -- Ancestral Protection Totem
					Protection_Cast = true
					Protection_GUID = destGUID return
				end
				if spellID == 192058 then -- Lightning Surge Totem
					LightningCounter = 0
					LightningSurge_GUID = destGUID return
				end
				if spellID == 157153 then -- Cloudburst Totem
					Cloudburst_Announced = false
				end
				if spellID == 198838 then -- Earthen Shield Totem
					EarthenShield_GUID = destGUID return
				end
				if spellID == 204336 then -- GROUNDING TOTEM
					GroundingCounter = 0
					Grounding_GUID = destGUID return
				end
			end -- IF EVENT IS SPELL_SUMMON
			if event == 'SPELL_CAST_SUCCESS' and spellID == 201764 then -- Recall Cloudburst Totem
				--Cloudburst_Announced = true
			end
			if event == 'SPELL_HEAL' and spellID == 157503 then -- Cloudburst Totem Heal
				if Cloudburst_Announced == true then return end
				Cloudburst_Announced = true
				local spellinfo = GetSpellInfo(157153)
				local spelllinkinfo = GetSpellLink(157153)
				local full_destName,dest = RSA.RemoveServerNames(dest)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest, ["[AMOUNT]"] = missType + overheal}
				local messagemax = #RSA.db.profile.Shaman.Spells.Cloudburst.Messages.Heal
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.Cloudburst.Messages.Heal[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.Cloudburst.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.Whisper == true and dest ~= pName then
						RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
						RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
						RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.Cloudburst.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.Party == true then
						if RSA.db.profile.Shaman.Spells.Cloudburst.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.Cloudburst.Raid == true then
						if RSA.db.profile.Shaman.Spells.Cloudburst.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			MonitorAndAnnounce(self, 'player', timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end -- IF SOURCE IS PLAYER
		if event == 'SPELL_CAST_SUCCESS' and Protection_Cast == true and spellID == 207553 then -- Ancestral Protection Totem
			for i=1,4 do
				local totemname = select(2, GetTotemInfo(i))
				if totemname == GetSpellInfo(207399) then -- If our totem exists then the resurrection cannot be from our totem.
					return
				end
			end
			Protection_Cast = false
			local spellinfo = GetSpellInfo(207399)
			local spelllinkinfo = GetSpellLink(207399)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = source,}
			local messagemax = #RSA.db.profile.Shaman.Spells.AncestralProtection.Messages.Cast
			if messagemax == 0 then return end
			local messagerandom = math.random(messagemax)
			local message = RSA.db.profile.Shaman.Spells.AncestralProtection.Messages.Cast[messagerandom]
			if message ~= '' then
				if RSA.db.profile.Shaman.Spells.AncestralProtection.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.AncestralProtection.CustomChannel.Channel)
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.Party == true then
					if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.AncestralProtection.Raid == true then
					if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
		end
		if event == 'SPELL_CAST_SUCCESS' and sourceGUID == LightningSurge_GUID and spellID == 118905 then -- Lightning Surge Totem
			local spellinfo = GetSpellInfo(118905)
			local spelllinkinfo = GetSpellLink(118905)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
			local messagemax = #RSA.db.profile.Shaman.Spells.LightningSurge.Messages.Cast
			if messagemax == 0 then return end
			local messagerandom = math.random(messagemax)
			local message = RSA.db.profile.Shaman.Spells.LightningSurge.Messages.Cast[messagerandom]
			if message ~= '' and LightningCounter == 0 then
				if RSA.db.profile.Shaman.Spells.LightningSurge.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.LightningSurge.CustomChannel.Channel)
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Party == true then
					if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Raid == true then
					if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
			LightningCounter = LightningCounter +1
		end
		if destGUID == Grounding_GUID and event == 'SPELL_ABSORBED' then -- GROUNDING TOTEM
			-- Event is some sort of incoming damage.
			local spellinfo = GetSpellInfo(204336)
			local spelllinkinfo = GetSpellLink(204336)
			local extraspellinfo = GetSpellInfo(spellID)
			local extraspellinfolink = GetSpellLink(spellID)
			local full_sourceName,sourceName = RSA.RemoveServerNames(source)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = sourceName, ["[AMOUNT]"] = ex8, ["[TARLINK]"] = extraspellinfolink, ["[TARSPELL]"] = extraspellinfo,}
			local messagemax = #RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.DamageAbsorb
			if messagemax == 0 then return end
			local messagerandom = math.random(messagemax)
			local message = RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.DamageAbsorb[messagerandom]
			if message ~= '' then
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Channel)
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Party == true then
					if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Raid == true then
					if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
			GroundingCounter = GroundingCounter + 1
		end
		if destGUID == Grounding_GUID and event == 'SPELL_MISSED' and missType == 'IMMUNE' then -- GROUNDING TOTEM
			-- Incoming spell is some sort of Debuff, which cannot be applied to grounding totem.
			local spellinfo = GetSpellInfo(204336)
			local spelllinkinfo = GetSpellLink(204336)
			local extraspellinfo = GetSpellInfo(spellID)
			local extraspellinfolink = GetSpellLink(spellID)
			local full_sourceName,sourceName = RSA.RemoveServerNames(source)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = sourceName, ["[TARLINK]"] = extraspellinfolink, ["[TARSPELL]"] = extraspellinfo,}
			local messagemax = #RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.EffectAbsorb
			if messagemax == 0 then return end
			local messagerandom = math.random(messagemax)
			local message = RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.EffectAbsorb[messagerandom]
			if message ~= '' then
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Channel)
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Party == true then
					if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.GroundingTotem.Raid == true then
					if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
			GroundingCounter = GroundingCounter + 1
		end
		if event == 'SPELL_AURA_REMOVED' and sourceGUID == LightningSurge_GUID and spellID == 118905 then -- Lightning Surge Totem
			local spellinfo = GetSpellInfo(118905)
			local spelllinkinfo = GetSpellLink(118905)
			RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
			LightningCounter = LightningCounter -1
			local messagemax = #RSA.db.profile.Shaman.Spells.LightningSurge.Messages.End
			if messagemax == 0 then return end
			local messagerandom = math.random(messagemax)
			local message = RSA.db.profile.Shaman.Spells.LightningSurge.Messages.End[messagerandom]
			if message ~= '' and LightningCounter == 0 then
				if RSA.db.profile.Shaman.Spells.LightningSurge.Local == true then
					RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Yell == true then
					RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.CustomChannel.Enabled == true then
					RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.LightningSurge.CustomChannel.Channel)
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Say == true then
					RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true then
					RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Party == true then
					if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true and GetNumGroupMembers() == 0 then return end
						RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
				if RSA.db.profile.Shaman.Spells.LightningSurge.Raid == true then
					if RSA.db.profile.Shaman.Spells.LightningSurge.SmartGroup == true and GetNumGroupMembers() > 0 then return end
					RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
				end
			end
		end
		if event == 'UNIT_DIED' then -- Unit source isn't player. GUID tracking used to ensure we only announce our own.
			if destGUID == SpiritLink_GUID then -- Spirit Link Totem UNIT_DIED
				local spellinfo = GetSpellInfo(98008)
				local spelllinkinfo = GetSpellLink(98008)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
				local messagemax = #RSA.db.profile.Shaman.Spells.SpiritLink.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.SpiritLink.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.SpiritLink.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.SpiritLink.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.Party == true then
						if RSA.db.profile.Shaman.Spells.SpiritLink.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.SpiritLink.Raid == true then
						if RSA.db.profile.Shaman.Spells.SpiritLink.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == TremorTotem_GUID then -- Tremor Totem UNIT_DIED
				local spellinfo = GetSpellInfo(8143)
				local spelllinkinfo = GetSpellLink(8143)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
				local messagemax = #RSA.db.profile.Shaman.Spells.TremorTotem.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.TremorTotem.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.TremorTotem.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.TremorTotem.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.Party == true then
						if RSA.db.profile.Shaman.Spells.TremorTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.TremorTotem.Raid == true then
						if RSA.db.profile.Shaman.Spells.TremorTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == WindRush_GUID then -- WindRushTotem UNIT_DIED
				local spellinfo = GetSpellInfo(192077)
				local spelllinkinfo = GetSpellLink(192077)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
				local messagemax = #RSA.db.profile.Shaman.Spells.WindRushTotem.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.WindRushTotem.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.WindRushTotem.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.WindRushTotem.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.Party == true then
						if RSA.db.profile.Shaman.Spells.WindRushTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.WindRushTotem.Raid == true then
						if RSA.db.profile.Shaman.Spells.WindRushTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == EarthGrab_GUID then -- Earth Grab Totem UNIT_DIED
				local spellinfo = GetSpellInfo(51485)
				local spelllinkinfo = GetSpellLink(51485)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo,}
				local messagemax = #RSA.db.profile.Shaman.Spells.EarthGrabTotem.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.EarthGrabTotem.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.EarthGrabTotem.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.Party == true then
						if RSA.db.profile.Shaman.Spells.EarthGrabTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthGrabTotem.Raid == true then
						if RSA.db.profile.Shaman.Spells.EarthGrabTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == Protection_GUID then -- Ancestral Protection Totem UNIT_DIED
				Protection_Cast = false
				local spellinfo = GetSpellInfo(207495)
				local spelllinkinfo = GetSpellLink(207495)
				local full_destName,dest = RSA.RemoveServerNames(dest)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
				local messagemax = #RSA.db.profile.Shaman.Spells.AncestralProtection.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.AncestralProtection.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Whisper == true and dest ~= pName then
						RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = L["You"],}
						--RSA.Print_Whisper(string.gsub(message, '.%a+.', RSA.String_Replace), full_destName)
						RSA.Print_Whisper(message, full_destName, RSA.Replacements, dest)
						RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[TARGET]"] = dest,}
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.AncestralProtection.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Party == true then
						if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.AncestralProtection.Raid == true then
						if RSA.db.profile.Shaman.Spells.AncestralProtection.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == EarthenShield_GUID then -- Earthen Shield Totem UNIT_DIED
				local spellinfo = GetSpellInfo(198838)
				local spelllinkinfo = GetSpellLink(198838)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo}
				local messagemax = #RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.EarthenShieldTotem.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Party == true then
						if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.Raid == true then
						if RSA.db.profile.Shaman.Spells.EarthenShieldTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end
			if destGUID == Grounding_GUID then -- Grounding Totem UNIT_DIED
				local spellinfo = GetSpellInfo(204336)
				local spelllinkinfo = GetSpellLink(204336)
				RSA.Replacements = {["[SPELL]"] = spellinfo, ["[LINK]"] = spelllinkinfo, ["[AMOUNT]"] = GroundingCounter, }
				local messagemax = #RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.End
				if messagemax == 0 then return end
				local messagerandom = math.random(messagemax)
				local message = RSA.db.profile.Shaman.Spells.GroundingTotem.Messages.End[messagerandom]
				if message ~= '' then
					if RSA.db.profile.Shaman.Spells.GroundingTotem.Local == true then
						RSA.Print_LibSink(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.Yell == true then
						RSA.Print_Yell(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Enabled == true then
						RSA.Print_Channel(string.gsub(message, '.%a+.', RSA.String_Replace), RSA.db.profile.Shaman.Spells.GroundingTotem.CustomChannel.Channel)
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.Say == true then
						RSA.Print_Say(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true then
						RSA.Print_SmartGroup(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.Party == true then
						if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() == 0 then return end
							RSA.Print_Party(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
					if RSA.db.profile.Shaman.Spells.GroundingTotem.Raid == true then
						if RSA.db.profile.Shaman.Spells.GroundingTotem.SmartGroup == true and GetNumGroupMembers() > 0 then return end
						RSA.Print_Raid(string.gsub(message, '.%a+.', RSA.String_Replace))
					end
				end
			end -- Earthen Shield Totem
		end -- IF EVENT IS UNIT_DIED
	end -- END ENTIRELY
	RSA.CombatLogMonitor:SetScript('OnEvent', Shaman_Spells)
end

function RSA_Shaman:OnDisable()
	RSA.CombatLogMonitor:SetScript('OnEvent', nil)
	if LRI then LRI.UnregisterAllCallbacks(RSA) end
end
