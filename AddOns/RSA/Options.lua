local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local LDS = LibStub('LibDualSpec-1.0')
local localisedClass, uClass = UnitClass('player')
uClass = string.lower(uClass)
RSA.Options = RSA:NewModule('Options')

local tags = {
	'TARGET',
	'SOURCE',
	'MISSTYPE',
	'AMOUNT',
	'EXTRA',
	'EXTRALINK',
}

local colors = {
	['titles'] = 'FF00DBBD',
	['descriptions'] = 'FFD1D1D1',
	['deepRed'] = 'FFCF374D',
	['orange'] = 'FFFF8019',
	['green'] = 'FF91BE0F',
	['gold'] = 'FFFFCC00',
	['blue'] = 'FF00B2FA',
	['deepRedDisabled'] = 'FF85474F',
	['orangeDisabled'] = 'FFC3724D',
	['greenDisabled'] = 'FF5C702D',
	['goldDisabled'] = 'FFBF9040',
	['blueDisabled'] = 'FF3B7EB1',
	['white'] = 'FFFFFFFF',
}

-- TODO fill in the rest of the event types.
local configEventInfo = {
	['SPELL_CAST_START'] = {
		localisedName = L["Start"],
		desc = L["When the casting of this spell begins."],
		order = 0,
	},
	['SPELL_AURA_APPLIED'] = {
		localisedName = L["Aura Applied"],
		desc = L["When this buff or debuff is applied to a target."],
		order = 2,
	},
	['SPELL_SUMMON'] = {
		localisedName = L["Summon"],
		desc = L["When this spell spawns another creature or object in the world."],
		order = 3,
	},
	['SPELL_CAST_SUCCESS'] = {
		localisedName = L["Cast"],
		desc = L["When this spell is cast. If the spell has a cast-time, this is when you finish the cast. If the spell is instant, this is when the spell begins its effect."],
		order = 4,
	},
	['SPELL_RESURRECT'] = {
		localisedName = L["Resurrect"],
		desc = L["When this resurrection spell finishes, giving the target the option to return to life."],
		order = 5.0,
	},
	['RSA_UNIT_ACCEPTED_RESS'] = {
		localisedName = L["Accepted Resurrect"],
		desc = L["When the target of this spell accepts the resurrection."],
		advDesc = L["A Fake event supplied by RSA to that occurs when a player accepts a ressurect."],
		order = 5.1,
	},
	['SPELL_DISPEL'] = {
		localisedName = L["Dispel"],
		desc = L["When this spell removes a buff or debuff."],
		order = 6,
	},
	['SPELL_DISPEL_FAILED'] = {
		localisedName = L["Dispel Resist"],
		desc = L["When this spell is resisted by the target."],
		order = 7,
	},
	['SPELL_DAMAGE'] = {
		localisedName = L["Damage"],
		desc = L["When this spell causes damage."],
		order = 8,
	},
	['SPELL_HEAL'] = {
		localisedName = L["Heal"],
		desc = L["When this spell causes healing."],
		order = 9,
	},
	['SPELL_ABSORBED'] = {
		localisedName = L["Damage Absorb"],
		desc = L["When this spell absorbs damage or effects."],
		order = 10,
	},
	['SPELL_INTERRUPT'] = {
		localisedName = L["Interrupt"],
		desc = L["When this spell interrupts another spell cast."],
		order = 11,
	},
	['SPELL_MISSED'] = {
		localisedName = RESIST,
		desc = L["When this spell fails to connect with the target. See the Tag Options to configure what the [MISSTYPE] tag will turn into when used."],
		order = 12,
	},
	['RSA_SPELL_IMMUNE'] = {
		localisedName = IMMUNE,
		desc = L["When the target is immune to your spell."],
		advDesc = L["A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Immune."],
		order = 13.0,
	},
	['RSA_SPELL_REFLECT'] = {
		localisedName = REFLECT,
		desc = L["When this spell reflects another spell."],
		advDesc = L["A Fake event supplied by RSA to allow only announcing when a SPELL_MISSED event is Reflect."],
		order = 13.1,
	},
	['SPELL_AURA_REMOVED'] = {
		localisedName = L["Aura Removed"],
		desc = L["When this buff or debuff is expires."],
		order = 15,
	},
	['SPELL_AURA_BROKEN_SPELL'] = {
		localisedName = L["CC Broken"],
		desc = L["When this CC ability is broken prematurely by another spell."],
		order = 16,
	},
	['RSA_END_TIMER'] = {
		localisedName = L["End"],
		desc = L["When the spell's usual duration ends."],
		advDesc = L["A Fake event supplied by RSA to trigger an announcement after a set number of seconds. Useful when a spell doesn't have an appropriate combat log event to track when it expires. You can modify the duration in the Spell Setup tab."],
		order = 17,
	},
	['SPELL_INSTAKILL'] = {
		localisedName = L["Killed"],
		desc = L["When this spell instantly kills the target."],
		order = 18,
	},
	['UNIT_DIED'] = {
		localisedName = "UNIT_DIED: NYI",
		desc = "This is not yet implemented.",
		--localisedName = L["Unit Died"],
		--desc = L["When a unit summoned by this spell has died. For example when a totem despawns at the end of its duration."],
		order = 18,
	},
	['SPELL_STOLEN'] = {
		localisedName = L["Spell Stolen"],
		desc = L["When this spell captures a buff from the target."],
		order = 19,
	},

}

local channels = {
	'say',
	'yell',
	'emote',
	'party',
	'raid',
	'instance',
	'personal',
	'smartGroup',
	'whisper',
}

local channelStrings = {
	['smartGroup'] = L["Smart Group"],
	['personal'] = L["Local Output"],
}

local channelOrder = {
	['say'] = 1,
	['yell'] = 2,
	['emote'] = 3,
	['party'] = 4,
	['raid'] = 5,
	['instance'] = 6,
	['personal'] = 7,
	['smartGroup'] = 8,
	['whisper'] = 9,
}

local channelColor = {
	['say'] = colors['deepRed'],
	['yell'] = colors['deepRed'],
	['emote'] = colors['deepRed'],
	['party'] = colors['green'],
	['raid'] = colors['green'],
	['instance'] = colors['green'],
	['personal'] = colors['blue'],
	['smartGroup'] = colors['gold'],
	['whisper'] = colors['gold'],
}

local channelDescriptions = {
	['say'] = L["%s can only function inside instances since 8.2.5."]:format(L["Say"]),
	['yell'] = L["%s can only function inside instances since 8.2.5."]:format(L["Yell"]),
	['emote'] = '',
	['party'] = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/party|r if you're in a manually formed group."] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
	['raid'] = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/raid|r if you're in a manually formed raid."] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
	['instance'] = L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
	['personal'] = L["Sends a message locally only visible to you. To choose which part of the UI this is displayed in go to the |cff00B2FALocal Message Output Area|r in the General options."],
	['smartGroup'] = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."] .. '\n' .. L["|cff91BE0F/raid|r if you're in a manually formed raid."] .. '\n' .. L["|cff91BE0F/party|r if you're in a manually formed group."],
	['whisper'] = L["|cffFFCC00Whispers|r the target of the spell."],
}

local function GetChannelColor(channel)
	if channelColor[channel] then
		return channelColor[channel]
	else
		return 'FF00FFFF'
	end
end

local function GetDisabledColor(startColor, profile)
	local curCol = colors[startColor]
	if not profile then
		curCol = colors[startColor .. 'Disabled']
	end
	return curCol
end

local function GetChannelName(channel)
	local globalString = _G[string.upper(channel)] or nil
	if channelStrings[channel] then
		return channelStrings[channel]
	elseif globalString then
		return globalString
	end
end

local function GetEventName(event)
	if configEventInfo[event] then
		return configEventInfo[event].localisedName
	else
		return event
	end
end

local function GetValidTags(event)
	local validTags = {}
	if event.tags then
		for k,v in pairs(event.tags) do
			table.insert(validTags,'[' .. k .. ']')
			if k == 'EXTRA' then
				table.insert(validTags, '[EXTRALINK]')
			end
		end
	end
	if validTags[1] then
		return '[SPELL], [LINK], '.. table.concat(validTags, ', ')
	else
		return '[SPELL], [LINK]'
	end
end

local function GetEventDescription(event)
	if configEventInfo[event] then
		return configEventInfo[event].desc
	else
		return event
	end
end

local function GetEventOrder(event)
	if configEventInfo[event] then
		return configEventInfo[event].order
	else
		return 50
	end
end

local function BaseOptions()
	local optionsTable = {
		type = 'group',
		--name = "RSA [|c5500DBBDRaeli's Spell Announcer|r] r|c5500DBBD" .. RSA.db.global.revision .. '|r',
		name = "RSA [|c5500DBBDRaeli's Spell Announcer|r] |c5500DBBD" .. GetAddOnMetadata("RSA","Version") .. "|r",
		order = 0,
		childGroups = 'tab',
		args = {
			general = {
				name = L["Environments"],
				desc = L["Control the areas of the game that RSA is allowed announce in."],
				type = 'group',
				order = 0,
				args = {
					moduleSettings = {
						name = L["Module Settings"],
						type = 'header',
						order = 0,
						hidden = true,
					},
					groupToggles = {
						name = '|c' .. colors['deepRed'] .. L["Channel Options"] .. '|r',
						type = 'group',
						inline = true,
						order = 100.2,
						args = {
							emote = {
								name = '|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['EMOTE']) .. '|r',
								type = 'toggle',
								desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['EMOTE']),
								width = 1.15,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.groupToggles.emote
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.groupToggles.emote = value
								end,
							},
							say = {
								name = '|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['SAY']) .. '|r',
								type = 'toggle',
								desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['SAY']),
								width = 1.15,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.groupToggles.say
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.groupToggles.say = value
								end,
							},
							yell = {
								name = '|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['YELL']) .. '|r',
								type = 'toggle',
								desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['YELL']),
								width = 1.15,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.groupToggles.yell
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.groupToggles.yell = value
								end,
							},
							whisper = {
								name = '|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['WHISPER']) .. '|r',
								type = 'toggle',
								desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['WHISPER']),
								width = 1.15,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.groupToggles.whisper
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.groupToggles.whisper = value
								end,
							},
						},
					},
					enableInPVPAreas = {
						name = '|c' .. colors['orange'] .. L["PvP Options"] .. '|r',
						type = 'group',
						inline = true,
						order = 100.3,
						args = {
							arenas = {
								name = '|c' .. colors['orange'] .. L["Enable in Arenas"] .. '|r',
								type = 'toggle',
								order = 0,
								width = 1,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.arenas
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.arenas = value
								end,
							},
							bgs = {
								name = '|c' .. colors['orange'] .. L["Enable in Battlegrounds"] .. '|r',
								type = 'toggle',
								order = 0,
								width = 1.1,
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.bgs
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.bgs = value
								end,
							},
							warModeWorld = {
								name = function()
									if RSA.IsRetail() then
										return '|c' .. colors['orange'] .. L["Enable in War Mode"] .. '|r'
									else
										return '|c' .. colors['orange'] .. L["Enable in the World"] .. '|r'
									end
								end,
								type = 'toggle',
								order = 1,
								desc = function()
									if RSA.IsRetail() then
										return L["Enable in the non-instanced world area when playing with War Mode %s."]:format(L["turned on"])
									else
										return L["Enable in the non-instanced world area when playing with PvP %s."]:format(L["turned on"])
									end
								end,
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.warModeWorld
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.warModeWorld = value
								end,
							},
						},
					},
					enableInPvEAreas = {
						name = '|c' .. colors['green'] .. L["PvE Options"] .. '|r',
						type = 'group',
						inline = true,
						order = 100.4,
						args = {
							dungeons = {
								name = '|c' .. colors['green'] .. L["Enable in Dungeons"] .. '|r',
								type = 'toggle',
								order = 0,
								desc = L["Enable in manually formed dungeon groups."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.dungeons
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.dungeons = value
								end,
							},
							raids = {
								name = '|c' .. colors['green'] .. L["Enable in Raid Instances"] .. '|r',
								type = 'toggle',
								order = 0,
								desc = L["Enable in manually formed raid groups."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.raids
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.raids = value
								end,
							},
							lfg = {
								name = '|c' .. colors['green'] .. L["Enable in Group Finder Dungeons"] .. '|r',
								type = 'toggle',
								order = 1,
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.lfg
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.lfg = value
								end,
							},
							lfr = {
								name = '|c' .. colors['green'] .. L["Enable in Group Finder Raids"] .. '|r',
								type = 'toggle',
								order = 1,
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.lfr
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.lfr = value
								end,
							},
							scenarios = {
								name = '|c' .. colors['green'] .. L["Enable in Scenarios"] .. '|r',
								type = 'toggle',
								order = 2,
								desc = L["Enable in scenario instances."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.scenarios
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.scenarios = value
								end,
							},
							nonWarWorld = {
								name = '|c' .. colors['green'] .. L["Enable in the World"] .. '|r',
								type = 'toggle',
								order = 2,
								desc = function()
									if RSA.IsRetail() then
										return L["Enable in the non-instanced world area when playing with War Mode %s."]:format(L["turned off"])
									else
										return L["Enable in the non-instanced world area when playing with PvP %s."]:format(L["turned off"])
									end
								end,
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.nonWarWorld
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.nonWarWorld = value
								end,
							},
						},
					},
					combatState = {
						name = '|c' .. colors['gold'] .. L["Other Options"] .. '|r',
						type = 'group',
						inline = true,
						order = 100.5,
						args = {
							inCombat = {
								name = '|c' .. colors['gold'] .. L["Enable in Combat"] .. '|r',
								type = 'toggle',
								order = 110,
								desc = L["Allow announcements if you are in combat."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.combatState.inCombat
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.combatState.inCombat = value
								end,
							},
							noCombat = {
								name = '|c' .. colors['gold'] .. L["Enable out of Combat"] .. '|r',
								type = 'toggle',
								order = 110,
								desc = L["Allow announcements if you are not in combat."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.combatState.noCombat
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.combatState.noCombat = value
								end,
							},
							alwaysWhisper = {
								name = '|c' .. colors['gold'] .. L["Always allow Whispers"] .. '|r',
								type = 'toggle',
								order = 110,
								desc = L["Allows whispers to ignore the %s and %s location options on this page. Does not ignore %s."]:format(
									'|c' .. colors['orange'] .. L['PvP'] .. '|r',
									'|c' .. colors['green'] .. L['PvE'] .. '|r',
									'|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['WHISPER']) .. '|r'),
								descStyle = 'inline',
								width = 'full',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.alwaysWhisper
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.alwaysWhisper = value
								end,
							},
						},
					},
				},
			},
			spells = {
				name = L["Announcements"],
				desc = L["Configure each spell's announcement settings, such as what channels to announce in and what messages to send."],
				type = 'group',
				childGroups = 'tab',
				order = 1,
				args = {
					racials = {
						name = L["Racials"],
						type = 'group',
						childGroups = 'select',
						args = {
							missing = {
								name = L["Missing options. Please report this!"],
								type = 'description',
								order = 0.02,
								fontSize = 'large',
							},
						},
					},
					utilities = {
						name = L["Utilities"],
						type = 'group',
						childGroups = 'select',
						args = {
							missing = {
								name = L["Missing options. Please report this!"],
								type = 'description',
								order = 0.02,
								fontSize = 'large',
							},
						},
					},
				},
			},
			tags = {
				name = L["Tag Options"],
				type = 'group',
				order = 10,
				args = {
					Target = {
						name = '|c5500DBBD[TARGET]|r ' .. L["Tag Options"],
						type = 'group',
						order = 10,
						inline = true,
						args = {
							removeServerNames = {
								name = '|c' .. colors['gold'] .. L["Remove Server Names"] .. '|r',
								type = 'toggle',
								order = 0,
								desc = L["Removes server name from |c5500DBBD[TARGET]|r tags."],
								descStyle = 'inline',
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.globalAnnouncements.removeServerNames
								end,
								set = function(info, value)
									RSA.db.profile.general.globalAnnouncements.removeServerNames = value
								end,
							},
							AlwaysUseName = {
								name = '|c' .. colors['gold'] .. L["Always uses spell target's name"] .. '|r',
								type = 'toggle',
								order = 10,
								desc = L["If selected, |c5500DBBD[TARGET]|r will always use the spell target's name, rather than using the input below for whispers."],
								descStyle = 'inline',
								width = 'full',
								get = function(info)
									return RSA.db.profile.general.replacements.target.alwaysUseName
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.target.alwaysUseName = value
								end,
							},
							Replacement = {
								name = L["Replacement"],
								desc = L["|c5500DBBD[TARGET]|r will be replaced with this when whispering someone."],
								type = 'input',
								order = 10.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.target.alwaysUseName == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.target.replacement
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.target.replacement = value
								end,
							},
						},
					},
					missType = {
						name = '|c5500DBBD[MISSTYPE]|r ' .. L["Tag Options"],
						type = 'group',
						order = 20,
						inline = true,
						args = {
							useGeneralReplacement = {
								name = '|c' .. colors['gold'] .. L["Use Single Replacement"] .. '|r',
								type = 'toggle',
								order = 10,
								desc = L["If selected, |c5500DBBD[MISSTYPE]|r will always use the General Replacement set below."] .. '\n' .. L["Does not affect Immune, Immune will always use its own replacement."],
								descStyle = 'inline',
								width = 'full',
								get = function(info)
									return RSA.db.profile.general.replacements.missType.useGeneralReplacement
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.useGeneralReplacement = value
								end,
							},
							generalReplacement = {
								name = L["General Replacement"],
								desc = L["Whether the target blocks, dodges, absorbs etc. your attack, |c5500DBBD[MISSTYPE]|r will be replaced to this."],
								type = 'input',
								order = 10.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == false then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.generalReplacement
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.generalReplacement = value
								end,
							},
							generalReplacementSpacer = {
								name = ' ',
								type = 'description',
								order = 10.2,
							},
							miss = {
								name = MISS,
								desc = L["When your spell misses the target |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.miss
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.miss = value
								end,
							},
							resist = {
								name = RESIST,
								desc = L["When the target resists your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.resist
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.resist = value
								end,
							},
							absorb = {
								name = ABSORB,
								desc = L["When the target absorbs your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.absorb
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.absorb = value
								end,
							},
							block = {
								name = BLOCK,
								desc = L["When the target blocks your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.block
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.block = value
								end,
							},
							deflect = {
								name = DEFLECT,
								desc = L["When the target deflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.deflect
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.deflect = value
								end,
							},
							dodge = {
								name = DODGE,
								desc = L["When the target dodges your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.dodge
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.dodge = value
								end,
							},
							evade = {
								name = EVADE,
								desc = L["When the target evades your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.evade
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.evade = value
								end,
							},
							parry = {
								name = PARRY,
								desc = L["When the target parries your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.parry
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.parry = value
								end,
							},
							immune = {
								name = IMMUNE,
								desc = L["When the target is immune to your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								get = function(info)
									return RSA.db.profile.general.replacements.missType.immune
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.immune = value
								end,
							},
							reflect = {
								name = REFLECT,
								desc = L["When the target reflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
								type = 'input',
								order = 20.1,
								width = 'double',
								disabled = function()
									if RSA.db.profile.general.replacements.missType.useGeneralReplacement == true then
										return true
									else
										return false
									end
								end,
								get = function(info)
									return RSA.db.profile.general.replacements.missType.reflect
								end,
								set = function(info, value)
									RSA.db.profile.general.replacements.missType.reflect = value
								end,
							},
						},
					},
				},
			},
			Feedback = {
				name = L["Feedback"],
				type = 'group',
				order = 1000,
				args = {
					Head = {
						name = L["Feedback"],
						type = 'header',
						order = 0,
					},
					Revision = {
						--name = "|cffFFCC00" .. L["Current Version: %s"]:format("r|r|c5500DBBD" .. RSA.db.global.revision) .. "|r",
						name = "|cffFFCC00" .. L["Current Version: %s"]:format("|r|c5500DBBD" .. GetAddOnMetadata("RSA","Version")) .. "|r",
						type = 'description',
						order = 0.5,
						fontSize = 'large',
					},
					RevisionDescription = {
						name = L["When reporting an issue, please also post the version number above. Thanks!"],
						type = 'description',
						order = 0.6,
					},
					Spacer_FeedbackOnline = {
						name = '\n',
						type = 'description',
						order = 1,
					},
					Curseforge_Header = {
						name = '|c' .. colors['green'] .. L["Curseforge"] .. '|r',
						type = 'description',
						order = 50,
						fontSize = 'large',
					},
					Curseforge_URL = {
						name = L["URL"],
						type = 'input',
						order = 50.2,
						width = 'full',
						get = function() return 'https://wow.curseforge.com/projects/rsa/issues' end,
						set = function() return 'https://wow.curseforge.com/projects/rsa/issues' end,
					},
					Spacer_OnlineCommunity = {
						name = '\n\n',
						type = 'description',
						order = 75,
					},
					Community_Header = {
						name = '|cff00B2FA' .. L["Discord"] .. '|r',
						type = 'description',
						order = 100,
						fontSize = 'large',
					},
					Community_URL = {
						name = L["Invite Link"],
						type = 'input',
						order = 100.2,
						width = 'full',
						get = function() return 'https://discord.gg/99QZ6sd' end,
						set = function() return 'https://discord.gg/99QZ6sd' end,
					},
				},
			},
			--[[CommunityTest = {
				name = 'TEST',
				type = 'group',
				args = {
					List = {
						name = 'List of Communities',
						type = 'select',
						values = ListNames,
					},
					Channels ={
						name = 'Channels',
						type = 'select',
						values = ListChannels,
					},
				},
			},]]--
		},
	}

	return optionsTable
end

local function GetSpellConfigInfo(selected)
	local configDisplay = selected.configDisplay
	local name,description,icon

	if selected.additionalSpellIDs then
		local spellTable = {}
		table.insert(spellTable, selected.spellID)
		for k in pairs(selected.additionalSpellIDs) do
			if selected.additionalSpellIDs == true then
				table.insert(spellTable, k)
			end
		end
		for i = 1,#spellTable do
			if IsPlayerSpell(spellTable[i]) then
				name = RSA.GetSpellInfo(spellTable[i])
				description = '|c' .. colors['descriptions'] .. RSA.GetSpellDescription(spellTable[i]) .. '|r'
				icon = select(select('#',GetSpellTexture(spellTable[i])),GetSpellTexture(spellTable[i]))
			end
		end
	end

	if configDisplay.defaultName and configDisplay.defaultName ~= '' then
		if type(configDisplay.defaultName) == 'function' then
			name = configDisplay.defaultName()
		else
			name = configDisplay.defaultName
		end
	end

	if configDisplay.defaultDesc and configDisplay.defaultDesc ~= '' then
		if type(configDisplay.defaultDesc) == 'function' then
			description = configDisplay.defaultDesc()
		else
			description = configDisplay.defaultDesc
		end
	end

	if configDisplay.customName and configDisplay.customName ~= '' then
		name = configDisplay.customName
	end

	if configDisplay.customDesc and configDisplay.customDesc ~= '' then
		description = configDisplay.customDesc
	end

	if not name then
		name = RSA.GetSpellInfo(selected.spellID)
	end
	if not description then
		description = '|c' .. colors['descriptions'] .. RSA.GetSpellDescription(selected.spellID) .. '|r'
	end
	if not icon then
		icon = GetSpellTexture(selected.spellID)
	end

	return name,description,icon
end

local function ConfigSpellEnvironments(section, k)
	local environments = {
		name = '|c' .. colors['titles'] .. L["Environments"] .. '|r',
		desc = L["Control the areas of the game this spell is allowed to be announced."],
		order = 90,
		type = 'group',
		args = {
			TEMPDISABLED = {
				name = '|cFF00CCFF Not Yet Implemented - Please use Environments settings in the top left tab.|r',
				width = 'full',
				fontSize = 'large',
				order = 0,
				type = 'description',
			},
			groupToggles = {
				name = function()
					local curCol = GetDisabledColor('deepRed', not RSA.db.profile[section][k].environments.useGlobal)
					return '|c' .. curCol .. L["Channel Options"] .. '|r'
				end,
				type = 'group',
				inline = true,
				disabled = RSA.db.profile[section][k].environments.useGlobal,
				order = 1000.2,
				args = {
					emote = {
						name = function()
							local curCol = GetDisabledColor('deepRed', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["%s only while grouped"]:format(_G['EMOTE']) .. '|r'
						end,
						type = 'toggle',
						desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['EMOTE']),
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.groupToggles.emote
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.groupToggles.emote = value
						end,
					},
					say = {
						name = function()
							local curCol = GetDisabledColor('deepRed', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["%s only while grouped"]:format(_G['SAY']) .. '|r'
						end,
						type = 'toggle',
						desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['SAY']),
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.groupToggles.say
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.groupToggles.say = value
						end,
					},
					yell = {
						name = function()
							local curCol = GetDisabledColor('deepRed', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["%s only while grouped"]:format(_G['YELL']) .. '|r'
						end,
						type = 'toggle',
						desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['YELL']),
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.groupToggles.yell
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.groupToggles.yell = value
						end,
					},
					whisper = {
						name = function()
							local curCol = GetDisabledColor('deepRed', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["%s only while grouped"]:format(_G['WHISPER']) .. '|r'
						end,
						type = 'toggle',
						desc = L["Allow announcements in /%s only when you are in a group."]:format(_G['WHISPER']),
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.groupToggles.whisper
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.groupToggles.whisper = value
						end,
					},
				},
			},
			enableInPVPAreas = {
				name = function()
					local curCol = GetDisabledColor('orange', not RSA.db.profile[section][k].environments.useGlobal)
					return '|c' .. curCol .. L["PvP Options"] .. '|r'
				end,
				type = 'group',
				inline = true,
				disabled = RSA.db.profile[section][k].environments.useGlobal,
				order = 1000.3,
				args = {
					arenas = {
						name = function()
							local curCol = GetDisabledColor('orange', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Arenas"] .. '|r'
						end,
						type = 'toggle',
						order = 0,
						width = 1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.arenas
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.arenas = value
						end,
					},
					bgs = {
						name = function()
							local curCol = GetDisabledColor('orange', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Battlegrounds"] .. '|r'
						end,
						type = 'toggle',
						order = 0,
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.bgs
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.bgs = value
						end,
					},
					warModeWorld = {
						name = function()
							local curCol = GetDisabledColor('orange', not RSA.db.profile[section][k].environments.useGlobal)
							if RSA.IsRetail() then
								return '|c' .. curCol .. L["Enable in War Mode"] .. '|r'
							else
								return '|c' .. curCol .. L["Enable in the World"] .. '|r'
							end
						end,
						type = 'toggle',
						order = 1,
						desc = function()
							if RSA.IsRetail() then
								return L["Enable in the non-instanced world area when playing with War Mode %s."]:format(L["turned on"])
							else
								return L["Enable in the non-instanced world area when playing with PvP %s."]:format(L["turned on"])
							end
						end,
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.warModeWorld
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.warModeWorld = value
						end,
					},
				},
			},
			enableInPvEAreas = {
				name = function()
					local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
					return '|c' .. curCol .. L["PvE Options"] .. '|r'
				end,
				type = 'group',
				inline = true,
				disabled = RSA.db.profile[section][k].environments.useGlobal,
				order = 1000.4,
				args = {
					dungeons = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Dungeons"] .. '|r'
						end,
						type = 'toggle',
						order = 0,
						desc = L["Enable in manually formed dungeon groups."],
						width = 0.9,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.dungeons
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.dungeons = value
						end,
					},
					raids = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Raid Instances"] .. '|r'
						end,
						type = 'toggle',
						order = 1,
						desc = L["Enable in manually formed raid groups."],
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.raids
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.raids = value
						end,
					},
					lfg = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Group Finder Dungeons"] .. '|r'
						end,
						type = 'toggle',
						order = 2,
						width = 1.3,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.lfg
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.lfg = value
						end,
					},
					lfr = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Group Finder Raids"] .. '|r'
						end,
						type = 'toggle',
						order = 3,
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.lfr
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.lfr = value
						end,
					},
					scenarios = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Scenarios"] .. '|r'
						end,
						type = 'toggle',
						order = 4,
						desc = L["Enable in scenario instances."],
						width = 0.9,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.scenarios
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.scenarios = value
						end,
					},
					nonWarWorld = {
						name = function()
							local curCol = GetDisabledColor('green', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in the World"] .. '|r'
						end,
						type = 'toggle',
						order = 5,
						desc = function()
							if RSA.IsRetail() then
								return L["Enable in the non-instanced world area when playing with War Mode %s."]:format(L["turned off"])
							else
								return L["Enable in the non-instanced world area when playing with PvP %s."]:format(L["turned off"])
							end
						end,
						width = 1,
						get = function(info)
							return RSA.db.profile[section][k].environments.enableIn.nonWarWorld
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.enableIn.nonWarWorld = value
						end,
					},
				},
			},
			combatState = {
				name = function()
					local curCol = GetDisabledColor('gold', not RSA.db.profile[section][k].environments.useGlobal)
					return '|c' .. curCol .. L["Other Options"] .. '|r'
				end,
				type = 'group',
				inline = true,
				disabled = RSA.db.profile[section][k].environments.useGlobal,
				order = 1000.5,
				args = {
					inCombat = {
						name = function()
							local curCol = GetDisabledColor('gold', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable in Combat"] .. '|r'
						end,
						type = 'toggle',
						order = 110,
						desc = L["Allow announcements if you are in combat."],
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.combatState.inCombat
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.combatState.inCombat = value
						end,
					},
					noCombat = {
						name = function()
							local curCol = GetDisabledColor('gold', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Enable out of Combat"] .. '|r'
						end,
						type = 'toggle',
						order = 110,
						desc = L["Allow announcements if you are not in combat."],
						width = 1,
						get = function(info)
							return RSA.db.profile[section][k].environments.combatState.noCombat
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.combatState.noCombat = value
						end,
					},
					alwaysWhisper = {
						name = function()
							local curCol = GetDisabledColor('gold', not RSA.db.profile[section][k].environments.useGlobal)
							return '|c' .. curCol .. L["Always allow Whispers"] .. '|r'
						end,
						type = 'toggle',
						order = 110,
						desc = L["Allows whispers to ignore the %s and %s location options on this page. Does not ignore %s."]:format(
							'|c' .. colors['orange'] .. L['PvP'] .. '|r',
							'|c' .. colors['green'] .. L['PvE'] .. '|r',
							'|c' .. colors['deepRed'] .. L["%s only while grouped"]:format(_G['WHISPER']) .. '|r'),
						width = 1.1,
						get = function(info)
							return RSA.db.profile[section][k].environments.alwaysWhisper
						end,
						set = function(info, value)
							RSA.db.profile[section][k].environments.alwaysWhisper = value
						end,
					},
				},
			},
		},
	}
	return environments
end

local function ConfigSpellEnvironmentGlobalToggle(optionsTable, section, selected, k)
	local useGlobal = {
	name = '|c' .. colors['gold'] .. L["Use Global Environment Settings"] .. '|r',
	order = 0,
	type = 'toggle',
	desc = L["Use the global settings to determine where it can be announced."] .. '\n' .. L["When disabled, use the Environments tab below to configure where this spell is allowed to announce. Affects all events this spell can announce."],
	width = 'full',
	get = function(info)
		return RSA.db.profile[section][k].environments.useGlobal
	end,
	set = function(info, value)
		RSA.db.profile[section][k].environments.useGlobal = value
		optionsTable.args[k].args.environments = ConfigSpellEnvironments(section,k)
		optionsTable.args[k].args.environments.args.useGlobal = ConfigSpellEnvironmentGlobalToggle(optionsTable, section, selected, k)
	end,
	}
	return useGlobal
end

local function ConfigSpellEventChannels(section, configDisplay, c, event, k)
	local channel = {
		name = '|c' .. GetChannelColor(channels[c]) .. GetChannelName(channels[c]) .. '|r',
		type = 'toggle',
		width = 0.8,
		order = 0.11 + channelOrder[channels[c]],
		desc = channelDescriptions[channels[c]] or nil,
		hidden = function()
			if configDisplay.disabledChannels then
				if configDisplay.disabledChannels[channels[c]] then
					return true
				end
			end
		end,
		get = function(info)
			return RSA.db.profile[section][k].events[event].channels[channels[c]]
		end,
		set = function(info, value)
			RSA.db.profile[section][k].events[event].channels[channels[c]] = value
		end,
	}
	return channel
end

local function ConfigSpellSetupEvents(section, event, k)
	local events = {
		name = event,
		order = 100,
		type = 'group',
		args = {
			remove = {
				name = 'remove',
				type = 'execute',
				func = function(info, value)
					RSA.db.profile[section][k].configDisplay.messageAreas[event] = nil
					RSA.db.profile[section][k].events[event] = nil
					RSA.RefreshMonitorData(section)
					-- TODO update ConfigSpellSetupEvents to remove this from the list
				end,

			},
			spellID = {
				name = L["Event unique spell ID"],
				desc = L["If this event uses a different spell ID to the primary one, enter it here."],
				order = 0,
				width = 0.8,
				type = 'input',
				validate = function(info, value)
					if value == '' then return true end
					if not string.match(value, '%d') then
						return L["You must enter a valid Spell ID."]
					end
					if not RSA.GetSpellInfo(value) then
						return L["You must enter a valid Spell ID."]
					end
					return true
				end,
				get = function(info)
					if not RSA.db.profile[section][k].events[event].uniqueSpellID then
						return ''
					end
					return tostring(RSA.db.profile[section][k].events[event].uniqueSpellID)
				end,
				set = function(info, value)
					RSA.db.profile[section][k].events[event].uniqueSpellID = tonumber(value)
					RSA.RefreshMonitorData(section)
				end,
			},
			duration = {
				name = L["Duration"],
				desc = L["How long before this fake event triggers after any other event for this spell has been processed."],
				order = 0,
				width = 0.8,
				type = 'input',
				hidden = function()
					if RSA.db.profile[section][k].events[event] == RSA.db.profile[section][k].events['RSA_END_TIMER'] then
						return false
					end
					return true
				end,
				validate = function(info, value)
					if value == '' then return true end
					if not string.match(value, '%d') then
						return L["You must enter a number."]
					end
					return true
				end,
				get = function(info)
					if not RSA.db.profile[section][k].events[event].duration then
						return ''
					end
					return tostring(RSA.db.profile[section][k].events[event].duration)
				end,
				set = function(info, value)
					RSA.db.profile[section][k].events[event].duration = tonumber(value)
					RSA.RefreshMonitorData(section)
				end,
			},
			tracker = {
				hidden = true,
				name = L["Prevent duplicate announcements"],
				desc = L["If this spell can trigger multiple events at the same time, such as if it is an AoE spell, you can start the event tracker when you trigger the spell, and set it to end on all events where you want to prevent subsequent announcements. Where multiple events can trigger the final message, you should select Spell Ends on both events."],
				order = 1,
				type = 'select',
				values = {
					[-1] = L["No tracking required"],
					[2] = L["Spell Starts"],
					[1] = L["Spell Ends"],
				},
				get = function(info)
					if not RSA.db.profile[section][k].events[event].tracker then
						return -1
					end
					return RSA.db.profile[section][k].events[event].tracker
				end,
				set = function(info, value)
					if value ~= -1 then
						RSA.db.profile[section][k].events[event].tracker = value
					else
						RSA.db.profile[section][k].events[event].tracker = nil
					end
				end,
			},
			customSource = {
				name = L["Caster & Target Settings"],
				order = 50,
				type = 'group',
				inline = true,
				args = {

					-- TODO: Make these arrays and list the entries like we do for additionalSpellIDs.
					useCustomSource = {
						name = L["Custom Caster"],
						order = 0,
						type = 'input',
						get = function(info)
							return RSA.db.profile[section][k].events[event].customSourceUnit
						end,
						set = function(info, value)
							RSA.db.profile[section][k].events[event].customSourceUnit = value
						end,
					},
					useCustomTarget = {
						name = L["Custom Target"],
						order = 0,
						type = 'input',
						get = function(info)
							return RSA.db.profile[section][k].events[event].customDestUnit
						end,
						set = function(info, value)
							RSA.db.profile[section][k].events[event].customDestUnit = value
						end,
					},
				},
			},
			tags = {
				name = L["Tags"],
				order = 100,
				type = 'group',
				inline = true,
				args = {
				},
			},
		},
	}
	for t = 1, #tags do
		events.args.tags.args[tags[t]] = {
			name = '|c' .. colors['titles'] .. "[" .. tags[t] .."]|r",
			order = 0,
			type = 'toggle',
			get = function(info)
				return RSA.db.profile[section][k].events[event].tags[tags[t]]
			end,
			set = function(info, value)
				RSA.db.profile[section][k].events[event].tags[tags[t]] = value
			end,
		}
	end

	return events
end

local function Abbreviate(inputString, ...)
	local locale = GetLocale()
	if locale == "koKR" or locale == "zhCN" or locale == "zhTW" then
		return inputString
	else
		local newString = inputString
		for i = 2, select('#', ...) do
			if i % 2 == 0 and (select(i-1,...)) then
				newString = newString:gsub((select(i-1,...)),(select(i,...)))
			end
		end

		return newString
	end
end

local function GenerateSpellOptions(section)
	local optionsData = RSA.db.profile[section]
	local sectionName = section
	local order = 99
	if uClass == section then
		sectionName = localisedClass
		RSA.monitorData[uClass] = RSA.PrepareDataTables(RSA.db.profile[uClass], uClass) -- Refresh Monitor Data so that options displays correctly (i.e if we added or changed an event for a spell profile)
		order = 0
	else
		RSA.monitorData[section] = RSA.PrepareDataTables(RSA.db.profile[section], section)
		sectionName = L[string.gsub(section, '%l', string.upper, 1)]
	end
	if not optionsData then return
		{
			name = sectionName,
			type = 'group',
			args = {
				missing = {
					name = L["Missing options. Please report this!"],
					type = 'description',
					order = 0.02,
					fontSize = 'large',
				},
			},
		}
	end

	local optionsTable = {
		name = sectionName,
		type = 'group',
		order = order,
		args = {
		},
	}

	for k in pairs(optionsData) do
		local selected = optionsData[k]
		local configDisplay = selected.configDisplay
		local spellName,spellDesc,spellIcon = GetSpellConfigInfo(selected)
		optionsTable.args[k] = {
			name = function()
				if string.len(spellName) >= 25 then
					return Abbreviate(spellName,'([%z\1-\127\194-\244][\128-\191])%S+','%1','(%w)%S+','%1',' ','','(\124)(\124)','%1','%p',' %1 ')
					--return spellName:gsub('([%z\1-\127\194-\244][\128-\191])%S+','%1'):gsub('(%w)%S+','%1'):gsub(' ',''):gsub('(\124)(\124)','%1'):gsub('%p',' %1 ')
				else
					return spellName
				end
			end,
			icon = spellIcon,
			desc = spellDesc,
			hidden = configDisplay.hidden or false,
			disabled = configDisplay.disabled or false,
			order = configDisplay.order or 50,
			type = 'group',
			childGroups = 'tab',
			args = {
				title = {
					name = '|c' .. colors['titles'] .. L["Configuring:|r %s"]:format(spellName),
					type = 'description',
					order = 1,
					fontSize = 'large',
				},
				description = {
					--name = '|cffd1d1d1' .. Spells[i].Desc .. '|r',
					name = '|c' .. colors['descriptions'] .. spellDesc .. '|r',
					type = 'description',
					order = 1.01,
					fontSize = 'small',
				},
				spellConfig = {
					-- TODO monitorData and spellData need to be rebuilt when we adjust spell config values. Function also needs to build from profile data.
					name = '|c' .. colors['titles'] .. L["Spell Setup"] .. '|r',
					desc = L["Configure how this spell functions."],
					order = 1000,
					type = 'group',
					childGroups = 'tab',
					hidden = true,
					--hidden = not RSA.db.profile.general.advancedConfig,
					args = {
						configLocked = {
							name = L["Spell Setup for this spell is locked."],
							type = 'description',
							hidden = function()
								if not configDisplay.isDefault then return true end
								if configDisplay.configLocked == false then return true end
								return false
							end,
							order = 0,
						},
						unlockSetup = {
							name = L["Unlock setup"],
							desc = L["WARNING: This spell is included with RSA by default and my cease to function correctly if you unlock and alter these settings."],
							order = 0.2,
							type = 'execute',
							hidden = function()
								if not configDisplay.isDefault then return true end
								if configDisplay.configLocked == false then return true end
								return false
							end,
							func = function()
								RSA.db.profile[section][k].configDisplay.configLocked = false
								RSA.Options:UpdateOptions()
							end,
						},
						remove = {
							name = L["Remove Spell"],
							type = 'execute',
							order = 0,
							hidden = function()
								if configDisplay.isDefault then return true end
								return false
							end,
							func = function()
								RSA.db.profile[section][k] = nil
								RSA.Options:UpdateOptions()
							end,
						},
						spellIDs = {
							name = L["Basic Spell Settings"],
							order = 0,
							type = 'group',
							disabled = function()
								if configDisplay.isDefault then
									if configDisplay.configLocked == false then
										return false
									else
										return true
									end
								else
									return false
								end
							end,
							args = {
								spellID = {
									name = L["Spell ID"],
									order = 0.1,
									type = 'input',
									validate = function(info, value)
										if not string.match(value, '%d') then
											return L["You must enter a valid Spell ID."]
										end
										if not RSA.GetSpellInfo(value) then
											return L["You must enter a valid Spell ID."]
										end
										return true
									end,
									get = function(info)
										return tostring(RSA.db.profile[section][k].spellID)
									end,
									set = function(info, value)
										RSA.db.profile[section][k].spellID = tonumber(value)
										RSA.Options:UpdateOptions()
									end,
								},
								comm = {
									name = L["Group Announcement"],
									desc = L["Prevents multiple RSA users from announcing this spell."],
									order = 0.2,
									type = 'toggle',
									get = function(info)
										return RSA.db.profile[section][k].comm
									end,
									set = function(info, value)
										RSA.db.profile[section][k].comm = value
									end,
								},
								throttle = {
									name = L["Throttle Duration"],
									desc = L["Prevents multiple announcements from occuring within this duration. Useful for abilities that can affect multiple targets at the same time. Select 0 to disable."],
									order = 1.1,
									type = 'range',
									min = 0,
									max = 300,
									softMin = 0,
									softMax = 30,
									step = 0.001,
									bigStep = 0.1,
									get = function(info)
										if not RSA.db.profile[section][k].throttle then
											return 0
										end
										return RSA.db.profile[section][k].throttle
									end,
									set = function(info, value)
										if value ~= 0 then
											RSA.db.profile[section][k].throttle = value
										else
											RSA.db.profile[section][k].throttle = nil
										end
									end,
								},
								throttleSpacer = {
									name = "",
									type = 'description',
									order = 1.2,
									width = 'full',
								},
								addAdditionalSpellID = {
									name = L["Additional Spell IDs"],
									desc = L["If this spell has multiple spell IDs, such as if you are trying to announce different Portals, or if it is modified by a talent which changes its Spell ID, you can enter those additional IDs here. Entering an ID already in the list will prompt you to remove it."],
									width = 0.8,
									order = 2.1,
									type = 'input',
									validate = function(info, value)
										if value == '' then return true end
										if not string.match(value, '%d') then
											return L["You must enter a valid Spell ID."]
										end
										if not RSA.GetSpellInfo(value) then
											return L["You must enter a valid Spell ID."]
										end
										return true
									end,
									confirm = function(info, value)
										if RSA.db.profile[section][k].additionalSpellIDs[tonumber(value)] then
											return L["Are you sure you want to remove this spell ID?"]
										else
											return false
										end
									end,
									set = function(info, value)
										local numVal = tonumber(value)
										if RSA.db.profile[section][k].additionalSpellIDs[numVal] then
											RSA.db.profile[section][k].additionalSpellIDs[numVal] = false
										else
											RSA.db.profile[section][k].additionalSpellIDs[numVal] = true
										end
										RSA.RefreshMonitorData(section)
									end,
								},
								additionalSpellIDs = {
									name = L["List of Additional Spell IDs"],
									desc = L["You can click a spell in this list to remove it."],
									order = 2.2,
									type = 'select',
									width = 1.5,
									confirm = function(info, value)
										if RSA.db.profile[section][k].additionalSpellIDs[tonumber(value)] then
											return L["Are you sure you want to remove this spell ID?"]
										else
											return false
										end
									end,
									hidden = function()
										if not RSA.db.profile[section][k].additionalSpellIDs then return true end
										for k2 in pairs(RSA.db.profile[section][k].additionalSpellIDs) do
											if RSA.db.profile[section][k].additionalSpellIDs[k2] == true then
												return false
											end
										end
										return true
									end,
									values = function()
										local val = {}
										for k2 in pairs(RSA.db.profile[section][k].additionalSpellIDs) do
											if RSA.db.profile[section][k].additionalSpellIDs[k2] then
												val[k2] = "(" .. k2 .. ") " .. RSA.GetSpellInfo(k2)
											end
										end
										return val
									end,
									set = function(info, value)
										if RSA.db.profile[section][k].additionalSpellIDs[tonumber(value)] then
											RSA.db.profile[section][k].additionalSpellIDs[tonumber(value)] = false
											RSA.RefreshMonitorData(section)
										end
									end,
								},
								additionalSpellIDsSpacer = {
									name = "",
									type = 'description',
									order = 2.3,
									width = 'full',
								},
								customName = {
									name = L["Custom Name"],
									desc = L["A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."],
									order = 3.1,
									type = 'input',
									get = function(info)
										return RSA.db.profile[section][k].configDisplay.customName
									end,
									set = function(info, value)
										RSA.db.profile[section][k].configDisplay.customName = value
										RSA.Options:UpdateOptions()
									end,
								},
								customDesc = {
									name = L["Custom Description"],
									desc = L["A custom description for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."],
									order = 3.2,
									width = 1.5,
									type = 'input',
									get = function(info)
										return RSA.db.profile[section][k].configDisplay.customDesc
									end,
									set = function(info, value)
										RSA.db.profile[section][k].configDisplay.customDesc = value
										RSA.Options:UpdateOptions()
									end,
								},
								disabledChannels = {
									name = L["Disabled Channels"],
									order = 100,
									type = 'group',
									inline = true,
									args = {},
								},
							},
						},

						events = {
							name = L["Combat Log Events"],
							order = 2,
							type = 'group',
							childGroups = 'tab',
							disabled = function()
								if configDisplay.isDefault then
									if configDisplay.configLocked == false then
										return false
									else
										return true
									end
								else
									return false
								end
							end,
							args = {},
						},
					},
				},
			},
		}
		optionsTable.args[k].args.environments = ConfigSpellEnvironments(section,k)
		optionsTable.args[k].args.environments.args.useGlobal = ConfigSpellEnvironmentGlobalToggle(optionsTable, section, selected, k)

		for c = 1, #channels do -- Spell Setup -> Disabled Channels
			optionsTable.args[k].args.spellConfig.args.spellIDs.args.disabledChannels.args[channels[c]] = {
				name = '|c' .. GetChannelColor(channels[c]) .. GetChannelName(channels[c]) .. '|r',
				type = 'toggle',
				width = 0.8,
				order = 0.11 + channelOrder[channels[c]],
				desc = function()
					if channels[c] == 'whisper' then
						return L["Prevents you from trying to send announcements to this channel."] .. '\n' .. L["This will not work without a valid target so should be disabled for all self-cast or non-targetted abilities."]
					else
					return L["Prevents you from trying to send announcements to this channel."]
					end
				end,
				get = function(info)
					return RSA.db.profile[section][k].configDisplay.disabledChannels[channels[c]]
				end,
				set = function(info, value)
					-- TODO iterate through events to see if TARGET is checked in any of them. If it isn't, then automatically set this true so that it is disabled.
					RSA.db.profile[section][k].configDisplay.disabledChannels[channels[c]] = value
					for i in pairs(configDisplay.messageAreas) do
						local event = configDisplay.messageAreas[i]
						optionsTable.args[k].args[event].args[channels[c]] = ConfigSpellEventChannels(section, configDisplay, c, event, k)
					end
				end,
			}
		end

		for e in pairs(configDisplay.messageAreas) do -- Spell Setup -> Combat Log Events
			local event = configDisplay.messageAreas[e]
			optionsTable.args[k].args.spellConfig.args.events.args[event] = ConfigSpellSetupEvents(section, event, k)
		end

		for i in pairs(configDisplay.messageAreas) do -- Event config
			local event = configDisplay.messageAreas[i]
			optionsTable.args[k].args[event] = {
				name = GetEventName(event),
				type = 'group',
				desc = GetEventDescription(event),
				order = 0 + GetEventOrder(event),
				args = {
					eventDescription = {
						name = '|c' .. colors['titles'] .. GetEventName(event) .. ':|r ' .. '|c' .. colors['descriptions'] .. GetEventDescription(event) .. '|r\n',
						type = 'description',
						order = 0,
						fontSize = 'medium',
					},
					addNewMessage = {
						name = L["Add New Message"],
						type = 'input',
						order = 10,
						width = 'full',
						 -- TODO Move out and reuse same func in messages.
						validate = function(info, value)
							if value == '' then return true end -- Pressed enter without entering anything, we don't need to warn about this.
							if not string.match(value,'%w') then
								RSA.SendMessage.ChatFrame(L["Your message must contain at least one number or letter!"])
								return L["Your message must contain at least one number or letter!"]
							else
								return true
							end
						end,
						set = function(info, value)
							table.insert(RSA.db.profile[section][k].events[event].messages, value)
							RSA.Options:UpdateOptions()
							RSA:WipeMessageCache()
						end,
					},
					numMessagesDescription = {
						name = 'temp',
						type = 'description',
						order = 11,
						fontSize = 'medium',
					},
					validTagsTitle = {
						name = '|c' .. colors['titles'] .. L['Valid Tags:'] .. '|r ' .. GetValidTags(selected.events[event]),
						type = 'description',
						order = 11.5,
						fontSize = 'medium',
					},
					currentMessages = {
						name = '|c' .. colors['titles'] .. L["Current Messages:"] .. '|r',
						type = 'description',
						order = 12,
						fontSize = 'medium',
						hidden = #selected.events[event].messages <1,
					}
				},
			}
			local numMessages = #selected.events[event].messages

			if numMessages == 0 then
				optionsTable.args[k].args[event].args.numMessagesDescription.name = '\n'.. L["You have no messages for this section."]..L[" If you wish to add a message for this section, enter it above in the |cffFFD100Add New Message|r box. As no messages exist, nothing will be announced for this section."]
			elseif numMessages == 1 then
				optionsTable.args[k].args[event].args.numMessagesDescription.name = '\n'.. L["You have %d message for this section."]:format(numMessages)..L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."]
			else
				optionsTable.args[k].args[event].args.numMessagesDescription.name = '\n'.. L["You have %d messages for this section."]:format(numMessages)..L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."]
			end

			for m = 1, numMessages do
				local curMessage = selected.events[event].messages[m]
				local curNumAsString = tostring(m)

				optionsTable.args[k].args[event].args[curNumAsString] = {
					name = '',
					type = 'input',
					order = 20,
					width = 'full',
					validate = function(info, value)
						if value == '' then return true end
						if not string.match(value,'%w') then
							RSA.SendMessage.ChatFrame(L["Your message must contain at least one number or letter!"])
							return L["Your message must contain at least one number or letter!"]
						else
							return true
						end
					end,
					get = function(info)
						if curMessage == '' then
							table.remove(RSA.db.profile[section][k].events[event].messages,m)
						end
						RSA.Options:UpdateOptions()
						return curMessage
					end,
					set = function(info, value)
						if value == '' then
							RSA.db.profile[section][k].events[event].messages[m] = ''
						else
							RSA.db.profile[section][k].events[event].messages[m] = value
						end
						RSA.Options:UpdateOptions()
						RSA:WipeMessageCache()
					end,
				}

			end
			for c = 1, #channels do
				optionsTable.args[k].args[event].args[channels[c]] = ConfigSpellEventChannels(section, configDisplay, c, event, k)
			end

		end
	end

	return optionsTable
end

local customSpellSetupData = {}

local function ResetCustomSpellSetupData()
	customSpellSetupData = {
		profile = nil,
		spellID = nil,
		comm = nil,
		additionalSpellIDs = {},
		configDisplay = {
			messageAreas = {},
			disabledChannels = {},
			customName = nil,
			customDesc = nil,
			configLocked = false,
		},
		events = {},
		environments = {
			useGlobal = true,
			alwaysWhisper = false,
			enableIn = {
				arenas = false,
				bgs = false,
				warModeWorld = false,
				nonWarWorld = false,
				dungeons = false,
				raids = false,
				lfg = false,
				lfr = false,
				scenarios = false,
			},
			groupToggles = {
				emote = true,
				say = true,
				yell = true,
				whisper = true,
			},
			combatState = {
				inCombat = true,
				noCombat = false,
			},
		}
	}
end

local function GenerateCustomSpellSetupOptions()
	local optionsTable = {
		name = L["Manage Announcements"],
		type = 'group',
		childGroups = 'tab',
		order = 100,
		hidden = true,
		args = {
			advancedConfig = {
				name = L["Advanced Mode"],
				desc = L["Exposes more options to allow custom setup of spells."],
				order = 0.2,
				type = 'toggle',
				get = function(info)
					return RSA.db.profile.general.advancedConfig
				end,
				set = function(info, value)
					RSA.db.profile.general.advancedConfig = value
					RSA.Options:UpdateOptions()
				end,
			},
			add = {
				name = L["Add a Spell"],
				order = 0,
				type = 'group',
				disabled = not RSA.db.profile.general.advancedConfig,
				args = {
					spellIDs = {
						name = L["Basic Spell Settings"],
						order = 0,
						type = 'group',
						inline = true,
						args = {
							spellID = {
								name = L["Primary spell ID"],
								desc = L["RSA takes the name and description for this to show in the configuration panel if a custom name & description are not set."],
								order = 0.1,
								type = 'input',
								validate = function(info, value)
									if not string.match(value, '%d') then
										return L["You must enter a valid Spell ID."]
									end
									if not RSA.GetSpellInfo(value) then
										return L["You must enter a valid Spell ID."]
									end
									return true
								end,
								get = function(info)
									if customSpellSetupData.spellID == nil then
										return ''
									else
										return tostring(customSpellSetupData.spellID)
									end
								end,
								set = function(info, value)
									customSpellSetupData.spellID = tonumber(value)
									RSA.Options:UpdateOptions()
								end,
							},
							SpellIDsSpacer = {
								name = "",
								type = 'description',
								order = 1.3,
								width = 'full',
							},
							customName = {
								name = L["Custom Name"],
								desc = L["A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."],
								order = 2.1,
								type = 'input',
								get = function(info)
									return customSpellSetupData.configDisplay.customName
								end,
								set = function(info, value)
									customSpellSetupData.configDisplay.customName = value
									RSA.Options:UpdateOptions()
								end,
							},
							customDesc = {
								name = L["Custom Description"],
								desc = L["A custom name for this announcement in the options menu. Leave blank to use the spell name for the spell in the Spell ID field."],
								order = 2.2,
								width = 1.5,
								type = 'input',
								get = function(info)
									return customSpellSetupData.configDisplay.customDesc
								end,
								set = function(info, value)
									customSpellSetupData.configDisplay.customDesc = value
									RSA.Options:UpdateOptions()
								end,
							},
							eventData = {
								name = L["Combat Log Events"],
								order = 200,
								type = 'group',
								args = {
									eventName = {
										name = L["Add Event"],
										order = 0,
										type = 'input',
										validate = function(info, value)
											if value == '' then return true end
											local hasLocalisation
											for k,v in pairs(configEventInfo) do
												if k == value then
													hasLocalisation = true
												end
											end
											if not hasLocalisation == true then
												return L["This event is not currently supported by RSA or is not a valid event."]
											end
											return true
										end,
										set = function(info, value)
											if not customSpellSetupData.events[value] then
												customSpellSetupData.events[value] = {
													event = value,
													uniqueSpellID = nil,
													tracker = nil,
													duration = nil,
													tags = {},
													messages = {},
													immuneMessages = {},
													channels = {},
												}
											end
											RSA.Options:UpdateOptions()
										end,
									},
								},
							},
							finaliseSpell = {
								name = L["Add Announcement"],
								type = 'execute',
								order = 1000,
								func = function()
									local profile = tostring(customSpellSetupData.spellID) .. tostring(time())
									RSA.db.profile[uClass][profile] = {}
									RSA.db.profile[uClass][profile] = RSA.CopyTable(customSpellSetupData)
									RSA.db.profile[uClass][profile].profile = profile
									ResetCustomSpellSetupData()
									RSA.Options:UpdateOptions()
								end,
							}
						},
					},
				},
			},
			remove = {
				name = L["Remove a Spell"],
				order = 1,
				type = 'group',
				hidden = true,
				disabled = not RSA.db.profile.general.advancedConfig,
				args = {

				},
			}
		},
	}

		for e in pairs(customSpellSetupData.events) do
			local event = customSpellSetupData.events[e]
			optionsTable.args.add.args.spellIDs.args.eventData.args[event] = {
				name = event.event,
				order = 10,
				type = 'description',
				inline = true,
			}
		end

	return optionsTable
end

function RSA:RegisterOptions()
	local optionsTable = BaseOptions()
	LibStub('AceConfig-3.0'):RegisterOptionsTable('RSA', optionsTable)

	local profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	optionsTable.args.profiles = profiles
	optionsTable.args.profiles.order = 100

	optionsTable.args.general.args.output = RSA:GetSinkAce3OptionsDataTable() -- Add LibSink Options.
	optionsTable.args.general.args.output.args.Channel = nil -- We don't want to display this, and it's broken since 8.2.5 anyway.
	optionsTable.args.general.args.output.name = '|c' .. colors['blue'] .. L["Local Message Output Area"] .. '|r'
	optionsTable.args.general.args.output.order = 100.6
	optionsTable.args.general.args.output.inline = true

	for k in pairs(optionsTable.args.general.args.output.args) do
		optionsTable.args.general.args.output.args[k].name = '|c' .. colors['blue'] .. optionsTable.args.general.args.output.args[k].name .. '|r'
	end

	optionsTable.args.spells.args[uClass] = GenerateSpellOptions(uClass)
	optionsTable.args.spells.args.racials = GenerateSpellOptions('racials')
	optionsTable.args.spells.args.utilities = GenerateSpellOptions('utilities')
	optionsTable.args.spells.args.customSpells = GenerateCustomSpellSetupOptions()

	-- TODO Iterate custom categories.

	LDS:EnhanceDatabase(self.db, 'RSA')
	LDS:EnhanceOptions(profiles, self.db)
end

function RSA.Options:UpdateOptions()
	RSA:RegisterOptions()
	LibStub('AceConfigRegistry-3.0'):NotifyChange('RSA')
end

function RSA.Options:OnInitialize()
	ResetCustomSpellSetupData()

	self.db = RSA.db
	RSA:SetSinkStorage(self.db.profile) -- Setup Saved Variables for LibSink

	RSA:RegisterOptions()
	LibStub('AceConfigDialog-3.0'):SetDefaultSize('RSA',900,770)

	self.db.RegisterCallback(RSA, 'OnProfileChanged', 'RefreshConfig')
	self.db.RegisterCallback(RSA, 'OnProfileCopied', 'RefreshConfig')
	self.db.RegisterCallback(RSA, 'OnProfileReset', 'RefreshConfig')
end

function RSA:RefreshConfig()
	RSA.db.profile = self.db.profile
	RSA.Options:UpdateOptions()
end