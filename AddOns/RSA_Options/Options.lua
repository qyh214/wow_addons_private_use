local RSA =  RSA or LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')
local RSA_O = RSA:NewModule('RSA_Options', 'LibSink-2.0')
local _, PlayerClass = UnitClass('player')
local _,_,RaceID = UnitRace('player')

local Options = {
	type = 'group',
	name = "RSA [|c5500DBBDRaeli's Spell Announcer|r] r|c5500DBBD" .. RSA.db.global.revision ..'|r',
	order = 0,
	args = {
		General = {
			name = L["General"],
			type = 'group',
			order = 0,
			args = {
				Module_Settings = {
					name = L["Module Settings"],
					type = 'header',
					order = 0,
					hidden = true,
				},
				Buff_Reminders = {
					hidden = true,
					name = '|cff00CCFF' .. L["Enable Buff Reminder Module"] .. '|r',
					type = 'toggle',
					order = 5,
					width = 'full',
					descStyle = 'inline',
					get = function(info)
						return RSA.db.profile.Modules.Reminders
					end,
					set = function(info, value)
						RSA.db.profile.Modules.Reminders = value
						if value == false and (LoadAddOn('RSA_Reminders') == 1) then
							RSA:DisableModule('Reminders')
						elseif value == true then
							local loaded, reason = LoadAddOn('RSA_Reminders')
							if not loaded then
								if reason == 'DISABLED' or reason == 'INTERFACE_VERSION' then
									ChatFrame1:AddMessage('|cFFFF75B3RSA:|r Reminders ' .. L.OptionsDisabled)
								elseif reason == 'MISSING' or reason == 'CORRUPT' then
									ChatFrame1:AddMessage('|cFFFF75B3RSA:|r Reminders ' .. L.OptionsMissing)
								end
							else
								RSA:EnableModule('Reminders')
							end
						end
					end,
				},
				Smart_Channel_Options = {
					name = '|cffCF374D'..L["Smart Channel Options"]..'|r',
					type = 'group',
					inline = true,
					order = 100.2,
					args = {
						Smart_Emote = {
							name = '|cffCF374D'..L["Smart Emote"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Only announce in /emote while you are in a group."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.SmartEmote
							end,
							set = function (info, value)
								RSA.db.profile.General.GlobalAnnouncements.SmartEmote = value
							end,
						},
						Smart_Say = {
							name = '|cffCF374D'..L["Smart Say"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Only announce in /say while you are in a group."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.SmartSay
							end,
							set = function (info, value)
								RSA.db.profile.General.GlobalAnnouncements.SmartSay = value
							end,
						},
						Smart_Yell = {
							name = '|cffCF374D'..L["Smart Yell"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Only announce in /yell while you are in a group."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.SmartYell
							end,
							set = function (info, value)
								RSA.db.profile.General.GlobalAnnouncements.SmartYell = value
							end,
						},
						Smart_Custom_Channel = {
							name = '|cffCF374D'..L["Smart Custom Channel"]..'|r',
							type = 'toggle',
							order = 1,
							desc = L["Announce to custom channels only while you are in a manually formed group."],
							descStyle = 'inline',
							width = 'double',
							hidden = true,
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.SmartCustomChannel
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.SmartCustomChannel = value
							end,
						},
					},
				},
				PvP_Options = {
					name = '|cffFF8019'..L["PvP Options"]..'|r',
					type = 'group',
					inline = true,
					order = 100.3,
					args = {
						Enable_In_Arenas = {
							name = '|cffFF8019'..L["Enable in Arenas"]..'|r',
							type = 'toggle',
							order = 0,
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.Arena
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.Arena = value
							end,
						},
						Enable_In_Battlegrounds = {
							name = '|cffFF8019'..L["Enable in Battlegrounds"]..'|r',
							type = 'toggle',
							order = 0,
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.Battlegrounds
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.Battlegrounds = value
							end,
						},
						Enable_In_War_Mode = {
							name = '|cffFF8019'..L["Enable in War Mode"]..'|r',
							type = 'toggle',
							order = 1,
							desc = L["Enable in the world area if you have War Mode active."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InWarMode
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InWarMode = value
							end,
						},
					},
				},
				PvE_Options = {
					name = '|cff91BE0F'..L["PvE Options"]..'|r',
					type = 'group',
					inline = true,
					order = 100.4,
					args = {
						Enable_In_Dungeons = {
							name = '|cff91BE0F'..L["Enable in Dungeons"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Enable in manually formed dungeon groups."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InDungeon
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InDungeon = value
							end,
						},
						Enable_In_Raids = {
							name = '|cff91BE0F'..L["Enable in Raid Instances"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Enable in manually formed raid groups."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InRaid
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InRaid = value
							end,
						},
						Enable_In_Group_Finder_Dungeons = {
							name = '|cff91BE0F'..L["Enable in Group Finder Dungeons"]..'|r',
							type = 'toggle',
							order = 1,
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InLFG_Party
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InLFG_Party = value
							end,
						},
						Enable_In_Group_Finder_Raids = {
							name = '|cff91BE0F'..L["Enable in Group Finder Raids"]..'|r',
							type = 'toggle',
							order = 1,
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InLFG_Raid
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InLFG_Raid = value
							end,
						},
						Enable_In_Scenarios = {
							name = '|cff91BE0F'..L["Enable in Scenarios"]..'|r',
							type = 'toggle',
							order = 2,
							desc = L["Enable in scenario instances."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InScenario
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InScenario = value
							end,
						},
						Enable_In_World = {
							name = '|cff91BE0F'..L["Enable in the World"]..'|r',
							type = 'toggle',
							order = 2,
							desc = L["Enable in the non-instanced world area when playing with War Mode disabled."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.InWorld
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.InWorld = value
							end,
						},
					},
				},
				Other_Options = {
					name = '|cffFFCC00'..L["Other Options"]..'|r',
					type = 'group',
					inline = true,
					order = 100.5,
					args = {
						Enable_Only_In_Combat = {
							name = '|cffFFCC00'..L["Enable Only in Combat"]..'|r',
							type = 'toggle',
							order = 110,
							desc = L["Only announce if you are in combat."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.OnlyInCombat
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.OnlyInCombat = value
							end,
						},
						AlwaysAllowWhispers = {
							name = '|cffFFCC00'..L["Always allow Whispers"]..'|r',
							type = 'toggle',
							order = 110,
							desc = L["Always allow whispers to be sent, ignoring the PvP and PvE Options on this page."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.AlwaysAllowWhispers
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.AlwaysAllowWhispers = value
							end,
						},
					},
				},
			},
		},
		Spells = {
			name = L["Spells"],
			type = 'group',
			childGroups = 'tab',
			order = 1,
			args = {
				Racials = {
					name = L["Racials"],
					type = 'group',
					args = {
						Disabled_Notification = {
							name = 'Coming Soon',
							type = 'description',
							order = 0.02,
							fontSize = 'large',
						},
					},
				},
				Utilities = {
					name = L["Utilities"],
					type = 'group',
					args = {
						Disabled_Notification = {
							name = 'Coming Soon',
							type = 'description',
							order = 0.03,
							fontSize = 'large',
						},
					},
				},
			},
		},
		Tags = {
			name = L["Tag Options"],
			type = 'group',
			order = 10,
			args = {
				Target = {
					name = '|c5500DBBD[TARGET]|r '..L["Tag Options"],
					type = 'group',
					order = 10,
					inline = true,
					args = {
						Remove_Server_Names = {
							name = '|cffFFCC00'..L["Remove Server Names"]..'|r',
							type = 'toggle',
							order = 0,
							desc = L["Removes server name from |c5500DBBD[TARGET]|r tags."],
							descStyle = 'inline',
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.GlobalAnnouncements.RemoveServerNames
							end,
							set = function(info, value)
								RSA.db.profile.General.GlobalAnnouncements.RemoveServerNames = value
							end,
						},
						AlwaysUseName = {
							name = '|cffFFCC00'..L["Always uses spell target's name"]..'|r',
							type = 'toggle',
							order = 10,
							desc = L["If selected, |c5500DBBD[TARGET]|r will always use the spell target's name, rather than using the input below for whispers."],
							descStyle = 'inline',
							width = 'full',
							get = function(info)
								return RSA.db.profile.General.Replacements.Target.AlwaysUseName
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.Target.AlwaysUseName = value
							end,
						},
						Replacement = {
							name = L["Replacement"],
							desc = L["|c5500DBBD[TARGET]|r will be replaced with this when whispering someone."],
							type = 'input',
							order = 10.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.Target.AlwaysUseName == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.Target.Replacement
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.Target.Replacement = value
							end,
						},
					},
				},
				MissType = {
					name = '|c5500DBBD[MISSTYPE]|r '.. L["Tag Options"],
					type = 'group',
					order = 20,
					inline = true,
					args = {
						UseGeneralReplacement = {
							name = '|cffFFCC00' .. L["Use Single Replacement"] .. '|r',
							type = 'toggle',
							order = 10,
							desc = L["If selected, |c5500DBBD[MISSTYPE]|r will always use the General Replacement set below."]..'\n'..L["Does not affect Immune, Immune will always use its own replacement."],
							descStyle = 'inline',
							width = 'full',
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement = value
							end,
						},
						GeneralReplacement = {
							name = L["General Replacement"],
							desc = L["Whether the target blocks, dodges, absorbs etc. your attack, |c5500DBBD[MISSTYPE]|r will be replaced to this."],
							type = 'input',
							order = 10.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == false then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.GeneralReplacement
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.GeneralReplacement = value
							end,
						},
						GeneralReplacement_Spacer = {
							name = ' ',
							type = 'description',
							order = 10.2,
						},
						Miss = {
							name = MISS,
							desc = L["When your spell misses the target |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Miss
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Miss = value
							end,
						},
						Resist = {
							name = RESIST,
							desc = L["When the target resists your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Resist
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Resist = value
							end,
						},
						Absorb = {
							name = ABSORB,
							desc = L["When the target absorbs your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Absorb
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Absorb = value
							end,
						},
						Block = {
							name = BLOCK,
							desc = L["When the target blocks your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Block
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Block = value
							end,
						},
						Deflect = {
							name = DEFLECT,
							desc = L["When the target deflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Deflect
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Deflect = value
							end,
						},
						Dodge = {
							name = DODGE,
							desc = L["When the target dodges your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Dodge
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Dodge = value
							end,
						},
						Evade = {
							name = EVADE,
							desc = L["When the target evades your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Evade
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Evade = value
							end,
						},
						Parry = {
							name = PARRY,
							desc = L["When the target parries your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Parry
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Parry = value
							end,
						},
						Immune = {
							name = IMMUNE,
							desc = L["When the target is immune to your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Immune
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Immune = value
							end,
						},
						Reflect = {
							name = REFLECT,
							desc = L["When the target reflects your spell |c5500DBBD[MISSTYPE]|r will be replaced with this."],
							type = 'input',
							order = 20.1,
							width = 'double',
							disabled = function()
								if RSA.db.profile.General.Replacements.MissType.UseGeneralReplacement == true then
									return true
								else
									return false
								end
							end,
							get = function(info)
								return RSA.db.profile.General.Replacements.MissType.Reflect
							end,
							set = function(info, value)
								RSA.db.profile.General.Replacements.MissType.Reflect = value
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
					name = "|cffFFCC00" .. L["Current Version: %s"]:format("r|r|c5500DBBD" .. RSA.db.global.revision) .. "|r",
					type = 'description',
					order = 0.5,
					fontSize = 'large',
				},
				RevisionDescription = {
					name = L["When reporting an issue, please also post the revision number above. Thanks!"],
					type = 'description',
					order = 0.6,
				},
				Spacer_FeedbackOnline = {
					name = '\n',
					type = 'description',
					order = 1,
				},
				Curseforge_Header = {
					name = '|cff91BE0F'..L["Curseforge"]..'|r',
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
					name = '|cff00B2FA'..L["Discord"]..'|r',
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

local function DeathKnight_Options()
	local Spells = {
		['Army'] = {
			Profile = 'Army',
			Name = GetSpellInfo(42650),
			Desc = GetSpellDescription(42650),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['AMS'] = {
			Profile = 'AMS',
			Name = GetSpellInfo(48707),
			Desc = GetSpellDescription(48707),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['AMZ'] = {
			Profile = 'AMZ',
			Name = GetSpellInfo(51052),
			Desc = GetSpellDescription(51052),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['DarkCommand'] = {
			Profile = 'DarkCommand',
			Name = GetSpellInfo(56222),
			Desc = GetSpellDescription(56222),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		['IceboundFortitude'] = {
			Profile = 'IceboundFortitude',
			Name = GetSpellInfo(48792),
			Desc = GetSpellDescription(48792),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['Strangulate'] = {
			Profile = 'Strangulate',
			Name = GetSpellInfo(47476),
			Desc = GetSpellDescription(47476),
			Message_Amount = 4,
			Message_Areas = {'Start', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		['Asphyxiate'] = {
			Profile = 'Asphyxiate',
			Name = GetSpellInfo(108194),
			Desc = GetSpellDescription(108194),
			Message_Amount = 4,
			Message_Areas = {'Start', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		['MindFreeze'] = {
			Profile = 'MindFreeze',
			Name = GetSpellInfo(47528),
			Desc = GetSpellDescription(47528),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		['GorefiendsGrasp'] = {
			Profile = 'GorefiendsGrasp',
			Name = GetSpellInfo(108199),
			Desc = GetSpellDescription(108199),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		['DeathGrip'] = {
			Profile = 'DeathGrip',
			Name = GetSpellInfo(49576),
			Desc = GetSpellDescription(49576),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		['VampiricBlood'] = {
			Profile = 'VampiricBlood',
			Name = GetSpellInfo(55233),
			Desc = GetSpellDescription(55233),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['RuneTap'] = {
			Profile = 'RuneTap',
			Name = GetSpellInfo(194679),
			Desc = GetSpellDescription(194679),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['DancingRuneWeapon'] = {
			Profile = 'DancingRuneWeapon',
			Name = GetSpellInfo(81256),
			Desc = GetSpellDescription(81256),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['RaiseAlly'] = {
			Profile = 'RaiseAlly',
			Name = GetSpellInfo(61999),
			Desc = GetSpellDescription(61999),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		['PillarOfFrost'] = {
			Profile = 'PillarOfFrost',
			Name = GetSpellInfo(51271),
			Desc = GetSpellDescription(51271),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['Purgatory'] = {
			Profile = 'Purgatory',
			Name = GetSpellInfo(114556),
			Desc = GetSpellDescription(114556),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function DemonHunter_Options()
	local Spells = {
		[1] = {
			Profile = 'SpectralSight',
			Name = GetSpellInfo(188501),
			Desc = GetSpellDescription(188501),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[2] = {
			Profile = 'Disrupt',
			Name = GetSpellInfo(183752),
			Desc = GetSpellDescription(183752),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[3] = {
			Profile = 'Blur',
			Name = GetSpellInfo(212800),
			Desc = GetSpellDescription(212800),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[4] = {
			Profile = 'Netherwalk',
			Name = GetSpellInfo(196555),
			Desc = GetSpellDescription(196555),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[5] = {
			Profile = 'LastResort',
			Name = GetSpellInfo(209261),
			Desc = GetSpellDescription(209258),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[6] = {
			Profile = 'MetamorphosisTank',
			Name = GetSpellInfo(187827)..': '..TANK,
			Desc = GetSpellDescription(187827),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[7] = {
			Profile = 'MetamorphosisDD',
			Name = GetSpellInfo(191427)..': '..COMBATLOG_HIGHLIGHT_DAMAGE,
			Desc = GetSpellDescription(191427),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[8] = {
			Profile = 'FieryBrand',
			Name = GetSpellInfo(207744),
			Desc = GetSpellDescription(207744),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[9] = {
			Profile = 'SigilOfChains',
			Name = GetSpellInfo(202138),
			Desc = GetSpellDescription(202138),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[10] = {
			Profile = 'SigilOfMisery',
			Name = GetSpellInfo(207684),
			Desc = GetSpellDescription(207684),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[11] = {
			Profile = 'SigilOfSilence',
			Name = GetSpellInfo(202137),
			Desc = GetSpellDescription(202137),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[12] = {
			Profile = 'Torment',
			Name = GetSpellInfo(185245),
			Desc = GetSpellDescription(185245),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[13] = {
			Profile = 'ChaosNova',
			Name = GetSpellInfo(179057),
			Desc = GetSpellDescription(179057),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[14] = {
			Profile = 'Darkness',
			Name = GetSpellInfo(196718),
			Desc = GetSpellDescription(196718),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[15] = {
			Profile = 'Consume', -- Consume Magic
			Name = GetSpellInfo(278326),
			Desc = GetSpellDescription(278326),
			Message_Amount = 2,
			Message_Areas = {'Dispel', 'Resist'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["FelEruption"] = {
			Profile = 'FelEruption',
			Name = GetSpellInfo(211881),
			Desc = GetSpellDescription(211881),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Imprison"] = {
			Profile = 'Imprison',
			Name = GetSpellInfo(217832),
			Desc = GetSpellDescription(217832),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
	}
	return Spells
end

local function Druid_Options()
	local Spells = {
		["SurvivalInstincts"] = {
			Profile = 'SurvivalInstincts',
			Name = GetSpellInfo(61336),
			Desc = GetSpellDescription(61336),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Cyclone"] = {
			Profile = 'Cyclone',
			Name = GetSpellInfo(33786),
			Desc = GetSpellDescription(33786),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["IncapacitatingRoar"] = {
			Profile = 'IncapacitatingRoar',
			Name = GetSpellInfo(99),
			Desc = GetSpellDescription(99),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["FrenziedRegeneration"] = {
			Profile = 'FrenziedRegeneration',
			Name = GetSpellInfo(22842),
			Desc = GetSpellDescription(22842),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["UrsolsVortex"] = {
			Profile = 'UrsolsVortex',
			Name = GetSpellInfo(102793),
			Desc = GetSpellDescription(102793),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Treants"] = {
			Profile = 'Treants',
			Name = GetSpellInfo(205636),
			Desc = GetSpellDescription(205636),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Ironbark"] = {
			Profile = 'Ironbark',
			Name = GetSpellInfo(102342),
			Desc = GetSpellDescription(102342),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["SkullBash"] = {
			Profile = 'SkullBash',
			Name = GetSpellInfo(93985),
			Desc = GetSpellDescription(93985),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		["Growl"] = {
			Profile = 'Growl',
			Name = GetSpellInfo(6795),
			Desc = GetSpellDescription(6795),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["Revive"] = {
			Profile = 'Revive',
			Name = GetSpellInfo(50769),
			Desc = GetSpellDescription(50769),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Rebirth"] = {
			Profile = 'Rebirth',
			Name = GetSpellInfo(20484),
			Desc = GetSpellDescription(20484),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["TreeOfLife"] = {
			Profile = 'TreeOfLife',
			Name = GetSpellInfo(33891),
			Desc = GetSpellDescription(33891),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Barkskin"] = {
			Profile = 'Barkskin',
			Name = GetSpellInfo(22812),
			Desc = GetSpellDescription(22812),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["MightyBash"] = {
			Profile = 'MightyBash',
			Name = GetSpellInfo(5211),
			Desc = GetSpellDescription(5211),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Tranquility"] = {
			Profile = 'Tranquility',
			Name = GetSpellInfo(740),
			Desc = GetSpellDescription(740),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["NaturesVigil"] = {
			Profile = 'NaturesVigil',
			Name = GetSpellInfo(124974),
			Desc = GetSpellDescription(124974),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Berserk"] = {
			Profile = 'Berserk',
			Name = GetSpellInfo(106951),
			Desc = GetSpellDescription(106951),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["RemoveCorruption"] = {
			Profile = 'RemoveCorruption',
			Name = GetSpellInfo(2782) .. ' / ' .. GetSpellInfo(88423),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(2782) .. ':|r |cffd1d1d1' .. GetSpellDescription(2782) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(88423) .. ':|r |cffd1d1d1' .. GetSpellDescription(88423) .. '|r',
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["Roots"] = {
			Profile = 'Roots',
			Name = GetSpellInfo(339),
			Desc = GetSpellDescription(339),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["StampedingRoar"] = {
			Profile = 'StampedingRoar',
			Name = GetSpellInfo(106898),
			Desc = GetSpellDescription(106898),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["SolarBeam"] = {
			Profile = 'SolarBeam',
			Name = GetSpellInfo(97547),
			Desc = GetSpellDescription(97547),
			Message_Amount = 1,
			Message_Areas = {'Interrupt'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]'},
		},
		["Revitalize"] = {
			Profile = 'Revitalize',
			Name = GetSpellInfo(212040),
			Desc = GetSpellDescription(212040),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Innervate"] = {
			Profile = 'Innervate',
			Name = GetSpellInfo(29166),
			Desc = GetSpellDescription(29166),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Ironfur"] = {
			Profile = 'Ironfur',
			Name = GetSpellInfo(192081),
			Desc = GetSpellDescription(192081),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["DemoralizingRoar"] = {
			Profile = 'DemoralizingRoar',
			Name = GetSpellInfo(201664),
			Desc = GetSpellDescription(201664),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Soothe"] = {
			Profile = 'Soothe',
			Name = GetSpellInfo(2908),
			Desc = GetSpellDescription(2908),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["MassEntanglement"] = {
			Profile = 'MassEntanglement',
			Name = GetSpellInfo(102359),
			Desc = GetSpellDescription(102359),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Hibernate"] = {
			Profile = 'Hibernate',
			Name = GetSpellInfo(2637),
			Desc = GetSpellDescription(2637),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
	}
	return Spells
end

local function Hunter_Options()
	local Spells = {
		[1] = {
			Profile = 'Misdirection',
			Name = GetSpellInfo(34477),
			Desc = GetSpellDescription(34477),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]','[AMOUNT]'},
		},
		[2] = {
			Profile = 'ConcussiveShot',
			Name = GetSpellInfo(5116),
			Desc = GetSpellDescription(5116),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[3] = {
			Profile = 'Intimidation',
			Name = GetSpellInfo(24394),
			Desc = GetSpellDescription(24394),
			Message_Amount = 3,
			Message_Areas = {'Start', 'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[4] = {
			Profile = 'FreezingTrap',
			Name = GetSpellInfo(3355),
			Desc = GetSpellDescription(3355),
			Message_Amount = 3,
			Message_Areas = {'Placed', 'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[5] = {
			Profile = 'SilencingShot', -- Counter Shot
			Name = GetSpellInfo(147362),
			Desc = GetSpellDescription(147362),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[6] = {
			Profile = 'Deterrence',
			Name = GetSpellInfo(186265),
			Desc = GetSpellDescription(186265),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[7] = {
			Profile = 'Camoflage',
			Name = GetSpellInfo(199483),
			Desc = GetSpellDescription(199483),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[8] = {
			Profile = 'RoarOfSacrifice',
			Name = GetSpellInfo(53480),
			Desc = GetSpellDescription(53480),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[9] = {
			Profile = 'Muzzle',
			Name = GetSpellInfo(187707),
			Desc = GetSpellDescription(187707),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[10] = {
			Profile = 'BindingShot',
			Name = GetSpellInfo(109248),
			Desc = GetSpellDescription(109248),
			Message_Amount = 3,
			Message_Areas = {'Placed', 'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		--[[[11] = {
			Profile = 'Tranq',
			Name = L["Pet Dispels"],
			Desc = GetSpellDescription(264263),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},]]--
		[11] = {
			Profile = 'Tranq',
			Name = GetSpellInfo(19801),
			Desc = GetSpellDescription(19801),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["AncientHysteria"] = {
			Profile = 'AncientHysteria',
			Name = GetSpellInfo(90355),
			Desc = GetSpellDescription(90355),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["SpiritMend"] = {
			Profile = 'SpiritMend',
			Name = GetSpellInfo(90361),
			Desc = GetSpellDescription(90361),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]',},
		},
		["BattleRess"] = {
			Profile = 'BattleRess',
			Name = GetSpellInfo(159956),
			Desc = GetSpellDescription(159956),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]',},
		},
	}
	return Spells
end

local function Mage_Options()
	local Spells = {
		[1] = {
			Profile = 'TimeWarp',
			Name = GetSpellInfo(80353),
			Desc = GetSpellDescription(80353),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[2] = {
			Profile = 'Spellsteal',
			Name = GetSpellInfo(30449),
			Desc = GetSpellDescription(30449),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]', '[MISSTYPE]'},
		},
		[3] = {
			Profile = 'Polymorph',
			Name = GetSpellInfo(118),
			Desc = GetSpellDescription(118),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[4] = {
			Profile = 'Counterspell',
			Name = GetSpellInfo(2139),
			Desc = GetSpellDescription(2139),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[5] = {
			Profile = 'Portals',
			Name = GetSpellInfo(109400),
			Desc = GetSpellDescription(11419),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[6] = {
			Profile = 'Teleport',
			Name = GetSpellInfo(223199),
			Desc = GetSpellDescription(3563),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true, ["Custom"] = true, ["Raid"] = true, ["Party"] = true, ["SmartGroup"] = true, ["Emote"] = true, ["Say"] = true, ["Yell"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[7] = {
			Profile = 'RefreshmentTable',
			Name = GetSpellInfo(190336),
			Desc = GetSpellDescription(190336),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[8] = {
			Profile = 'RingOfFrost',
			Name = GetSpellInfo(113724),
			Desc = GetSpellDescription(113724),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[9] = {
			Profile = 'Cauterize',
			Name = GetSpellInfo(87023),
			Desc = GetSpellDescription(87023),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["IceBlock"] = {
			Profile = 'IceBlock',
			Name = GetSpellInfo(45438),
			Desc = GetSpellDescription(45438),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["SlowFall"] = {
			Profile = 'SlowFall',
			Name = GetSpellInfo(130),
			Desc = GetSpellDescription(130),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["RemoveCurse"] = {
			Profile = 'RemoveCurse',
			Name = GetSpellInfo(475),
			Desc = GetSpellDescription(475),
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
	}
	return Spells
end

local function Monk_Options()
	local Spells = {
		[1] = {
			Profile = 'ZenMeditation',
			Name = GetSpellInfo(115176),
			Desc = GetSpellDescription(115176),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[2] = {
			Profile = 'Provoke',
			Name = GetSpellInfo(116189),
			Desc = GetSpellDescription(116189),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'Resist', 'Immune', 'StatueOfTheBlackOx'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[3] = {
			Profile = 'FortifyingBrew',
			Name = GetSpellInfo(120954),
			Desc = GetSpellDescription(120954),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[4] = {
			Profile = 'SpearHandStrike',
			Name = GetSpellInfo(116705),
			Desc = GetSpellDescription(116705),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[5] = {
			Profile = 'Paralysis',
			Name = GetSpellInfo(115078),
			Desc = GetSpellDescription(115078),
			Message_Amount = 4,
			Message_Areas = {'Start', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[6] = {
			Profile = 'Guard',
			Name = GetSpellInfo(202162),
			Desc = GetSpellDescription(202162),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[7] = {
			Profile = 'ElusiveBrew',
			Name = GetSpellInfo(115308),
			Desc = GetSpellDescription(115308),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[8] = {
			Profile = 'PurifyingBrew',
			Name = GetSpellInfo(119582),
			Desc = GetSpellDescription(119582),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[9] = {
			Profile = 'DampenHarm',
			Name = GetSpellInfo(122278),
			Desc = GetSpellDescription(122278),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[10] = {
			Profile = 'LifeCocoon',
			Name = GetSpellInfo(116849),
			Desc = GetSpellDescription(116849),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[11] = {
			Profile = 'RingOfPeace',
			Name = GetSpellInfo(116844),
			Desc = GetSpellDescription(116844),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[12] = {
			Profile = 'DiffuseMagic',
			Name = GetSpellInfo(122783),
			Desc = GetSpellDescription(122783),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[13] = {
			Profile = 'TouchOfKarma',
			Name = GetSpellInfo(122470),
			Desc = GetSpellDescription(122470),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[14] = {
			Profile = 'Detox',
			Name = GetSpellInfo(115450),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(115450) .. ':|r |cffd1d1d1' .. GetSpellDescription(115450) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(218164) .. ':|r |cffd1d1d1' .. GetSpellDescription(218164) .. '|r',
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		[15] = {
			Profile = 'Resuscitate',
			Name = GetSpellInfo(115178),
			Desc = GetSpellDescription(115178),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
			Requirements = {'LRI'},
		},
		[16] = {
			Profile = 'Revival',
			Name = GetSpellInfo(115310),
			Desc = GetSpellDescription(115310),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[17] = {
			Profile = 'Reawaken',
			Name = GetSpellInfo(212051),
			Desc = GetSpellDescription(212051),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[18] = {
			Profile = 'LegSweep',
			Name = GetSpellInfo(119381),
			Desc = GetSpellDescription(119381),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		['CelestialBrew'] = {
			Profile = 'CelestialBrew',
			Name = GetSpellInfo(322507),
			Desc = GetSpellDescription(322507),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function Paladin_Options()
	local Spells = {
		[1] = {
			Profile = 'ArdentDefender',
			Name = GetSpellInfo(31850),
			Desc = GetSpellDescription(31850),
			Message_Amount = 3,
			Message_Areas = {'Start', 'End', 'Heal'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[AMOUNT]'},
		},
		[2] = {
			Profile = 'HandOfFreedom',
			Name = GetSpellInfo(1044),
			Desc = GetSpellDescription(1044),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[3] = {
			Profile = 'Forbearance',
			Name = GetSpellInfo(25771),
			Desc = GetSpellDescription(25771),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true, ["Custom"] = true, ["Raid"] = true, ["Party"] = true, ["SmartGroup"] = true, ["Say"] = true, ["Yell"] = true, ["Emote"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[4] = {
			Profile = 'DevotionAura',
			Name = GetSpellInfo(31821),
			Desc = GetSpellDescription(31821),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[5] = {
			Profile = 'DivineProtection',
			Name = GetSpellInfo(498),
			Desc = GetSpellDescription(498),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["BoP&BoS"] = {
			Profile = 'HandOfProtection',
			Name = GetSpellInfo(1022) .. ' / ' .. GetSpellInfo(204018),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(1022) .. ':|r |cffd1d1d1' .. GetSpellDescription(1022) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(204018) .. ':|r |cffd1d1d1' .. GetSpellDescription(204018) .. '|r',
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["BoSac"] = {
			Profile = 'HandOfSacrifice',
			Name = GetSpellInfo(6940),
			Desc = GetSpellDescription(6940),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["BoSanc"] = {
			Profile = 'BlessingOfSanctuary',
			Name = GetSpellInfo(210256),
			Desc = GetSpellDescription(210256),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["ForgottenQueen"] = {
			Profile = 'ForgottenQueen',
			Name = GetSpellInfo(228049),
			Desc = GetSpellDescription(228049),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["LoH"] = {
			Profile = 'LayOnHands',
			Name = GetSpellInfo(633),
			Desc = GetSpellDescription(633),
			Message_Amount = 1,
			Message_Areas = {'Heal'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AMOUNT]'},
		},
		["GoAK"] = {
			Profile = 'GoAK',
			Name = GetSpellInfo(86659),
			Desc = GetSpellDescription(86659),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[12] = {
			Profile = 'HolyAvenger',
			Name = GetSpellInfo(105809),
			Desc = GetSpellDescription(105809),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[13] = {
			Profile = 'Repentance',
			Name = GetSpellInfo(20066),
			Desc = GetSpellDescription(20066),
			Message_Amount = 3,
			Message_Areas = {'Start', 'End', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[14] = {
			Profile = 'Rebuke',
			Name = GetSpellInfo(96231),
			Desc = GetSpellDescription(96231),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[15] = {
			Profile = 'HandOfReckoning',
			Name = GetSpellInfo(62124),
			Desc = GetSpellDescription(62124),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[16] = {
			Profile = 'Beacon',
			Name = GetSpellInfo(53563),
			Desc = GetSpellDescription(53563),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[17] = {
			Profile = 'Redemption',
			Name = GetSpellInfo(7328),
			Desc = GetSpellDescription(7328),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
			Requirements = {'LRI'},
		},
		[18] = {
			Profile = 'AvengersShield',
			Name = GetSpellInfo(31935),
			Desc = GetSpellDescription(31935),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[19] = {
			Profile = 'HammerOfJustice',
			Name = GetSpellInfo(853),
			Desc = GetSpellDescription(853),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[20] = {
			Profile = 'Cleanse',
			Name = GetSpellInfo(4987) .. ' / ' .. GetSpellInfo(213644),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(4987) .. ':|r |cffd1d1d1' .. GetSpellDescription(4987) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(213644) .. ':|r |cffd1d1d1' .. GetSpellDescription(213644) .. '|r',
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		[21] = {
			Profile = 'DivineShield',
			Name = GetSpellInfo(642),
			Desc = GetSpellDescription(642),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[22] = {
			Profile = 'AvengingWrath',
			Name = GetSpellInfo(31884) .. ' / ' .. GetSpellInfo(216331) .. ' / ' .. GetSpellInfo(231895),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(31884) .. ':|r |cffd1d1d1' .. GetSpellDescription(31884) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(216331) .. ':|r |cffd1d1d1' .. GetSpellDescription(216331) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(231895) .. ':|r |cffd1d1d1' .. GetSpellDescription(231895) .. '|r',
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[23] = {
			Profile = 'ShieldOfVengeance',
			Name = GetSpellInfo(184662),
			Desc = GetSpellDescription(184662),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[24] = {
			Profile = 'FinalStand',
			Name = GetSpellInfo(204077),
			Desc = GetSpellDescription(204077),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[25] = {
			Profile = 'Absolution',
			Name = GetSpellInfo(212056),
			Desc = GetSpellDescription(212056),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		--[[[26] = {
			Profile = 'AegisOfLight',
			Name = GetSpellInfo(204150),
			Desc = GetSpellDescription(204150),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},]]--
		[27] = {
			Profile = 'EyeForAnEye',
			Name = GetSpellInfo(205191),
			Desc = GetSpellDescription(205191),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function Priest_Options()
	local Spells = {
		["MassDispel"] = {
			Profile = 'MassDispel',
			Name = GetSpellInfo(32375),
			Desc = GetSpellDescription(32375),
			Message_Amount = 2,
			Message_Areas = {'Start', 'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["VampiricEmbrace"] = {
			Profile = 'VampiricEmbrace',
			Name = GetSpellInfo(15286),
			Desc = GetSpellDescription(15286),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["LeapOfFaith"] = {
			Profile = 'LeapOfFaith',
			Name = GetSpellInfo(73325),
			Desc = GetSpellDescription(73325),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["DivineHymn"] = {
			Profile = 'DivineHymn',
			Name = GetSpellInfo(64843),
			Desc = GetSpellDescription(64843),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Apotheosis"] = {
			Profile = 'Apotheosis',
			Name = GetSpellInfo(200183),
			Desc = GetSpellDescription(200183),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Levitate"] = {
			Profile = 'Levitate',
			Name = GetSpellInfo(1706),
			Desc = GetSpellDescription(1706),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["ShackleUndead"] = {
			Profile = 'ShackleUndead',
			Name = GetSpellInfo(9484),
			Desc = GetSpellDescription(9484),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Chastise"] = {
			Profile = 'Chastise',
			Name = GetSpellInfo(88625),
			Desc = GetSpellDescription(88625),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["DispelMagic"] = {
			Profile = 'DispelMagic',
			Name = GetSpellInfo(528),
			Desc = GetSpellDescription(528),
			Message_Amount = 2,
			Message_Areas = {'Dispel', 'Resist'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["GuardianSpirit"] = {
			Profile = 'GuardianSpirit',
			Name = GetSpellInfo(47788),
			Desc = GetSpellDescription(47788),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["PainSuppression"] = {
			Profile = 'PainSuppression',
			Name = GetSpellInfo(33206),
			Desc = GetSpellDescription(33206),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["PowerWordBarrier"] = {
			Profile = 'PowerWordBarrier',
			Name = GetSpellInfo(62618),
			Desc = GetSpellDescription(62618),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Resurrection"] = {
			Profile = 'Resurrection',
			Name = GetSpellInfo(2006),
			Desc = GetSpellDescription(2006),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
			Requirements = {'LRI'},
		},
		["MassRess"] = {
			Profile = 'MassRess',
			Name = GetSpellInfo(212036),
			Desc = GetSpellDescription(212036),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Fade"] = {
			Profile = 'Fade',
			Name = GetSpellInfo(586) .. ' / ' .. GetSpellInfo(213602),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(586) .. ':|r |cffd1d1d1' .. GetSpellDescription(586) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(213602) .. ':|r |cffd1d1d1' .. GetSpellDescription(213602) .. '|r',
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["PsychicScream"] = {
			Profile = 'PsychicScream',
			Name = GetSpellInfo(8122),
			Desc = GetSpellDescription(8122),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["MindBomb"] = {
			Profile = 'MindBomb',
			Name = GetSpellInfo(205369),
			Desc = GetSpellDescription(205369),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["MindControl"] = {
			Profile = 'MindControl',
			Name = GetSpellInfo(605),
			Desc = GetSpellDescription(605),
			Message_Amount = 2,
			Message_Areas = {'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Silence"] = {
			Profile = 'Silence',
			Name = GetSpellInfo(15487),
			Desc = GetSpellDescription(15487),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]'},
		},
		["BodyAndSoul"] = {
			Profile = 'BodyAndSoul',
			Name = GetSpellInfo(65081),
			Desc = GetSpellDescription(65081),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Shadowfiend"] = {
			Profile = 'Shadowfiend',
			Name = GetSpellInfo(34433),
			Desc = GetSpellDescription(34433),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["SymbolOfHope"] = {
			Profile = 'SymbolOfHope',
			Name = GetSpellInfo(64901),
			Desc = GetSpellDescription(64901),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["PsychicHorror"] = {
			Profile = 'PsychicHorror',
			Name = GetSpellInfo(64044),
			Desc = GetSpellDescription(64044),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["DarkAngel"] = {
			Profile = 'DarkAngel',
			Name = GetSpellInfo(197871),
			Desc = GetSpellDescription(197871),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Archangel"] = {
			Profile = 'Archangel',
			Name = GetSpellInfo(197862),
			Desc = GetSpellDescription(197862),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["HolyWard"] = {
			Profile = 'HolyWard',
			Name = GetSpellInfo(213610),
			Desc = GetSpellDescription(213610),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["RayOfHope"] = {
			Profile = 'RayOfHope',
			Name = GetSpellInfo(197268),
			Desc = GetSpellDescription(197268),
			Message_Amount = 3,
			Message_Areas = {'Start', 'Heal', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AMOUNT]'},
		},
		["Purify"] = {
			Profile = 'Purify',
			Name = GetSpellInfo(527) .. ' / ' .. GetSpellInfo(213634),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(527) .. ':|r |cffd1d1d1' .. GetSpellDescription(527) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(213634) .. ':|r |cffd1d1d1' .. GetSpellDescription(213634) .. '|r',
			Message_Amount = 1,
			--Hidden = GetSpecialization() == 3,
			Message_Areas = {'Dispel'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["Salvation"] = {
			Profile = 'Salvation',
			Name = GetSpellInfo(265202),
			Desc = GetSpellDescription(265202),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Evangelism"] = {
			Profile = 'Evangelism',
			Name = GetSpellInfo(246287),
			Desc = GetSpellDescription(246287),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Rapture"] = {
			Profile = 'Rapture',
			Name = GetSpellInfo(47536),
			Desc = GetSpellDescription(47536),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function Rogue_Options()
	local Spells = {
		["Sap"] = {
			Profile = 'Sap',
			Name = GetSpellInfo(6770),
			Desc = GetSpellDescription(6770),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Blind"] = {
			Profile = 'Blind',
			Name = GetSpellInfo(2094) .. ' / ' .. GetSpellInfo(199743),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(2094) .. ':|r |cffd1d1d1' .. GetSpellDescription(2094) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(199743) .. ':|r |cffd1d1d1' .. GetSpellDescription(199743) .. '|r',
			Message_Amount = 4,
			Message_Areas = {'Start', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["Kick"] = {
			Profile = 'Kick',
			Name = GetSpellInfo(1766),
			Desc = GetSpellDescription(1766),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		["Tricks"] = {
			Profile = 'Tricks',
			Name = GetSpellInfo(57934),
			Desc = GetSpellDescription(57934),
			Message_Amount = 2,
			Message_Areas = {'Cast', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["SmokeBomb"] = {
			Profile = 'SmokeBomb',
			Name = GetSpellInfo(76577),
			Desc = GetSpellDescription(76577),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Shroud"] = {
			Profile = 'Shroud',
			Name = GetSpellInfo(115834),
			Desc = GetSpellDescription(115834),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["CloakOfShadows"] = {
			Profile = 'CloakOfShadows',
			Name = GetSpellInfo(31224),
			Desc = GetSpellDescription(31224),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["BetweenTheEyes"] = {
			Profile = 'BetweenTheEyes',
			Name = GetSpellInfo(199804),
			Desc = GetSpellDescription(199804),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["KidneyShot"] = {
			Profile = 'KidneyShot',
			Name = GetSpellInfo(408),
			Desc = GetSpellDescription(408),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["CheapShot"] = {
			Profile = 'CheapShot',
			Name = GetSpellInfo(1833),
			Desc = GetSpellDescription(1833),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Shiv"] = {
			Profile = 'Shiv',
			Name = GetSpellInfo(5938),
			Desc = GetSpellDescription(5938),
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
	}
	return Spells
end

local function Shaman_Options()
	local Spells = {
		["Hex"] = {
			Profile = 'Hex',
			Name = GetSpellInfo(51514),
			Desc = GetSpellDescription(51514),
			Message_Amount = 4,
			Message_Areas = {'Start', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["Heroism"] = {
			Profile = 'Heroism',
			Name = GetSpellInfo(2825),
			Desc = GetSpellDescription(2825),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["WindShear"] = {
			Profile = 'WindShear',
			Name = GetSpellInfo(57994),
			Desc = GetSpellDescription(57994),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		["Purge"] = {
			Profile = 'Purge',
			Name = GetSpellInfo(370),
			Desc = GetSpellDescription(370),
			Message_Amount = 2,
			Message_Areas = {'Dispel', 'Resist'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["CleanseSpirit"] = {
			Profile = 'CleanseSpirit',
			Name = GetSpellInfo(51886) .. ' / ' .. GetSpellInfo(77130),
			longDesc = true,
			Desc = '|cffFFCC00'..GetSpellInfo(51886) .. ':|r |cffd1d1d1' .. GetSpellDescription(51886) .. '|r\n\n|cffFFCC00' .. GetSpellInfo(77130) .. ':|r |cffd1d1d1' .. GetSpellDescription(77130) .. '|r',
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["HealingTide"] = {
			Profile = 'HealingTide',
			Name = GetSpellInfo(108280),
			Desc = GetSpellDescription(108280),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["EarthElemental"] = {
			Profile = 'EarthElemental',
			Name = GetSpellInfo(198103),
			Desc = GetSpellDescription(198103),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["FireElemental"] = {
			Profile = 'FireElemental',
			Name = GetSpellInfo(198067),
			Desc = GetSpellDescription(198067),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AncestralSpirit"] = {
			Profile = 'AncestralSpirit',
			Name = GetSpellInfo(2008),
			Desc = GetSpellDescription(2008),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
			Requirements = {'LRI'},
		},
		["SpiritLink"] = {
			Profile = 'SpiritLink',
			Name = GetSpellInfo(98008),
			Desc = GetSpellDescription(98008),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["TremorTotem"] = {
			Profile = 'TremorTotem',
			Name = GetSpellInfo(8143),
			Desc = GetSpellDescription(8143),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Thunderstorm"] = {
			Profile = 'Thunderstorm',
			Name = GetSpellInfo(51490),
			Desc = GetSpellDescription(51490),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["FeralSpirit"] = {
			Profile = 'FeralSpirit',
			Name = GetSpellInfo(51533),
			Desc = GetSpellDescription(51533),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Reincarnation"] = {
			Profile = 'Reincarnation',
			Name = GetSpellInfo(21169),
			Desc = GetSpellDescription(21169),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AncestralGuidance"] = {
			Profile = 'AncestralGuidance',
			Name = GetSpellInfo(108281),
			Desc = GetSpellDescription(108281),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AstralShift"] = {
			Profile = 'AstralShift',
			Name = GetSpellInfo(108271),
			Desc = GetSpellDescription(108271),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["WindRushTotem"] = {
			Profile = 'WindRushTotem',
			Name = GetSpellInfo(192077),
			Desc = GetSpellDescription(192077),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Ascendance"] = {
			Profile = 'Ascendance',
			Name = GetSpellInfo(114050),
			Desc = GetSpellDescription(114050),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AncestralVision"] = {
			Profile = 'AncestralVision',
			Name = GetSpellInfo(212048),
			Desc = GetSpellDescription(212048),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AncestralProtection"] = {
			Profile = 'AncestralProtection',
			Name = GetSpellInfo(207399),
			Desc = GetSpellDescription(207399),
			Message_Amount = 3,
			Message_Areas = {'Placed', 'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["LightningSurge"] = {
			Profile = 'LightningSurge', -- Capacitor Totem
			Name = GetSpellInfo(192058),
			Desc = GetSpellDescription(192058),
			Message_Amount = 3,
			Message_Areas = {'Placed', 'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Cloudburst"] = {
			Profile = 'Cloudburst',
			Name = GetSpellInfo(157153),
			Desc = GetSpellDescription(157153),
			Message_Amount = 3,
			Message_Areas = {'Placed', 'End', 'Heal'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[AMOUNT]'},
		},
		["EarthenShieldTotem"] = {
			Profile = 'EarthenShieldTotem',
			Name = GetSpellInfo(198838),
			Desc = GetSpellDescription(198838),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["GroundingTotem"] = {
			Profile = 'GroundingTotem',
			Name = GetSpellInfo(204336),
			Desc = GetSpellDescription(204336),
			Message_Amount = 4,
			Message_Areas = {'Placed', 'DamageAbsorb', 'EffectAbsorb', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AMOUNT]', '[TARLINK]', '[TARSPELL]'},
		},
		["EarthGrabTotem"] = {
			Profile = 'EarthGrabTotem',
			Name = GetSpellInfo(51485),
			Desc = GetSpellDescription(51485),
			Message_Amount = 2,
			Message_Areas = {'Placed', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function Warlock_Options()
	local Spells = {
		["SoulWell"] = {
			Profile = 'SoulWell',
			Name = GetSpellInfo(29893),
			Desc = GetSpellDescription(29893),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["SummonStone"] = {
			Profile = 'SummonStone',
			Name = GetSpellInfo(698),
			Desc = GetSpellDescription(698),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Suffering"] = {
			Profile = 'Suffering',
			Name = GetSpellInfo(17735),
			Desc = GetSpellDescription(17735),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["SingeMagic"] = {
			Profile = 'SingeMagic',
			Name = GetSpellInfo(89808),
			Desc = GetSpellDescription(89808),
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["Banish"] = {
			Profile = 'Banish',
			Name = GetSpellInfo(710),
			Desc = GetSpellDescription(710),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["Fear"] = {
			Profile = 'Fear',
			Name = GetSpellInfo(5782),
			Desc = GetSpellDescription(5782),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["Seduce"] = {
			Profile = 'Seduce',
			Name = GetSpellInfo(6358),
			Desc = GetSpellDescription(6358),
			Message_Amount = 4,
			Message_Areas = {'Cast', 'End', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		["SpellLock"] = {
			Profile = 'SpellLock',
			Name = GetSpellInfo(19647),
			Desc = GetSpellDescription(19647),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		["Soulstone"] = {
			Profile = 'Soulstone',
			Name = GetSpellInfo(20707),
			Desc = GetSpellDescription(20707),
			Message_Amount = 2,
			Message_Areas = {'Start', 'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["DeathCoil"] = {
			Profile = 'DeathCoil',
			Name = GetSpellInfo(6789),
			Desc = GetSpellDescription(6789),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Shadowfury"] = {
			Profile = 'Shadowfury',
			Name = GetSpellInfo(30283),
			Desc = GetSpellDescription(30283),
			Message_Amount = 3,
			Message_Areas = {'Start', 'Cast', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["UnendingResolve"] = {
			Profile = 'UnendingResolve',
			Name = GetSpellInfo(104773),
			Desc = GetSpellDescription(104773),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Gateway"] = {
			Profile = 'Gateway',
			Name = GetSpellInfo(111771),
			Desc = GetSpellDescription(111771),
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["DarkPact"] = {
			Profile = 'DarkPact',
			Name = GetSpellInfo(108416),
			Desc = GetSpellDescription(108416),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["DevourMagic"] = {
			Profile = 'DevourMagic',
			Name = GetSpellInfo(19505),
			Desc = GetSpellDescription(19505),
			Message_Amount = 1,
			Message_Areas = {'Dispel'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[AURA]', '[AURALINK]'},
		},
		["AxeToss"] = {
			Profile = 'AxeToss',
			Name = GetSpellInfo(89766),
			Desc = GetSpellDescription(89766),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
	}
	return Spells
end

local function Warrior_Options()
	local Spells = {
		[1] = {
			Profile = 'ShieldWall',
			Name = GetSpellInfo(871),
			Desc = GetSpellDescription(871),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[2] = {
			Profile = 'Pummel',
			Name = GetSpellInfo(6552),
			Desc = GetSpellDescription(6552),
			Message_Amount = 3,
			Message_Areas = {'Interrupt', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[TARSPELL]', '[TARLINK]', '[MISSTYPE]'},
		},
		[3] = {
			Profile = 'DemoralizingShout',
			Name = GetSpellInfo(1160),
			Desc = GetSpellDescription(1160),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[4] = {
			Profile = 'Taunt',
			Name = GetSpellInfo(355),
			Desc = GetSpellDescription(355),
			Message_Amount = 3,
			Message_Areas = {'Cast', 'Resist', 'Immune'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]', '[MISSTYPE]'},
		},
		[5] = {
			Profile = 'LastStand',
			Name = GetSpellInfo(12975),
			Desc = GetSpellDescription(12975),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[6] = {
			Profile = 'EnragedRegeneration',
			Name = GetSpellInfo(184364),
			Desc = GetSpellDescription(184364),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[7] = {
			Profile = 'SpellReflect',
			Name = GetSpellInfo(23920),
			Desc = GetSpellDescription(23920),
			Message_Amount = 3,
			Message_Areas = {'Damage', 'Debuff', 'Resist'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]','[AMOUNT]'},
		},
		[8] = {
			Profile = 'Recklessness',
			Name = GetSpellInfo(1719),
			Desc = GetSpellDescription(1719),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[9] = {
			Profile = 'RallyingCry',
			Name = GetSpellInfo(97463),
			Desc = GetSpellDescription(97463),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		--[[[10] = {
			Profile = 'Intercept',
			Name = GetSpellInfo(198758),
			Desc = GetSpellDescription(198758),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},]]--
		['Intervene'] = {
			Profile = 'Intervene',
			Name = GetSpellInfo(3411),
			Desc = GetSpellDescription(3411),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		[11] = {
			Profile = 'DieByTheSword',
			Name = GetSpellInfo(118038),
			Desc = GetSpellDescription(118038),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[12] = {
			Profile = 'StormBolt',
			Name = GetSpellInfo(107570),
			Desc = GetSpellDescription(107570),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[13] = {
			Profile = 'MassSpellReflection',
			Name = GetSpellInfo(213915),
			Desc = GetSpellDescription(213915),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		[14] = {
			Profile = 'IntimidatingShout',
			Name = GetSpellInfo(5246),
			Desc = GetSpellDescription(5246),
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

local function Racial_Options()
	local Spells = {
		["EMFH"] = {
			Profile = 'EMFH',
			Name = GetSpellInfo(59752),
			Desc = GetSpellDescription(59752),
			Race = 1,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Stoneform"] = {
			Profile = 'Stoneform',
			Name = GetSpellInfo(20594),
			Desc = GetSpellDescription(20594),
			Race = 3,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Shadowmeld"] = {
			Profile = 'Shadowmeld',
			Name = GetSpellInfo(58984),
			Desc = GetSpellDescription(58984),
			Race = 4,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["EscapeArtist"] = {
			Profile = 'EscapeArtist',
			Name = GetSpellInfo(20589),
			Desc = GetSpellDescription(20589),
			Race = 7,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["GOTN"] = {
			Profile = 'GOTN',
			Name = GetSpellInfo(28880),
			Desc = GetSpellDescription(28880),
			Race = 11,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Darkflight"] = {
			Profile = 'Darkflight',
			Name = GetSpellInfo(68992),
			Desc = GetSpellDescription(68992),
			Race = 22,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]',},
		},
		["BloodFury"] = {
			Profile = 'BloodFury',
			Name = GetSpellInfo(33697),
			Desc = GetSpellDescription(33697),
			Race = 2,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["WOTF"] = {
			Profile = 'WOTF',
			Name = GetSpellInfo(7744),
			Desc = GetSpellDescription(7744),
			Race = 5,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["WarStomp"] = {
			Profile = 'WarStomp',
			Name = GetSpellInfo(20549),
			Desc = GetSpellDescription(20549),
			Race = 6,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Berserking"] = {
			Profile = 'Berserking',
			Name = GetSpellInfo(26297),
			Desc = GetSpellDescription(26297),
			Race = 8,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["ArcaneTorrent"] = {
			Profile = 'ArcaneTorrent',
			Name = GetSpellInfo(28730),
			Desc = GetSpellDescription(28730),
			Race = 10,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["RocketJump"] = {
			Profile = 'RocketJump',
			Name = GetSpellInfo(69070),
			Desc = GetSpellDescription(69070),
			Race = 9,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["SpatialRift"] = {
			Profile = 'SpatialRift',
			Name = GetSpellInfo(256948),
			Desc = GetSpellDescription(256948),
			Race = 29,
			Message_Amount = 2,
			Message_Areas = {'Placed','Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Fireblood"] = {
			Profile = 'Fireblood',
			Name = GetSpellInfo(265221),
			Desc = GetSpellDescription(265221),
			Race = 34,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["ArcanePulse"] = {
			Profile = 'ArcanePulse',
			Name = GetSpellInfo(260364),
			Desc = GetSpellDescription(260364),
			Race = 27,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["BullRush"] = {
			Profile = 'BullRush',
			Name = GetSpellInfo(255654),
			Desc = GetSpellDescription(255654),
			Race = 28,
			Message_Amount = 1,
			Message_Areas = {'Cast'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["AncestralCall"] = {
			Profile = 'AncestralCall',
			Name = GetSpellInfo(274738),
			Desc = GetSpellDescription(274738),
			Race = 36,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Regeneratin"] = {
			Profile = 'Regeneratin',
			Name = GetSpellInfo(291944),
			Desc = GetSpellDescription(291944),
			Race = 31,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Haymaker"] = {
			Profile = 'Haymaker',
			Name = GetSpellInfo(287712),
			Desc = GetSpellDescription(287712),
			Race = 32,
			Message_Amount = 2,
			Message_Areas = {'Start', 'End'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
	}
	return Spells
end

local function Utilities_Options()
	local Spells = {
		["Jeeves"] = {
			Profile = 'Jeeves',
			Name = L['Repair Bots'],
			Desc = GetSpellDescription(44389),
			Message_Amount = 1,
			Message_Areas = {'Placed'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Feasts"] = {
			Profile = 'Feasts',
			Name = L['Feasts'],
			Desc = GetSpellDescription(259410),
			Message_Amount = 1,
			Message_Areas = {'Placed'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Drums"] = {
			Profile = 'Drums',
			Name = L['Drums'],
			Desc = GetSpellDescription(256740),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["Cauldrons"] = {
			Profile = 'Cauldrons',
			Name = L['Cauldrons'],
			Desc = GetSpellDescription(276972),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["EngineerRessBFA"] = {
			Profile = 'EngineerRessBFA',
			Name = GetSpellInfo(265116),
			Desc = GetSpellDescription(265116),
			Message_Amount = 2,
			Message_Areas = {'Cast','AcceptedRess'},
			Valid_Tags = {'[SPELL]', '[LINK]', '[TARGET]'},
		},
		["SleepPotions"] = {
			Profile = 'SleepPotions',
			Name = L['Sleeping Mana Potions'],
			Desc = GetSpellDescription(298157),
			Message_Amount = 2,
			Message_Areas = {'Start','End'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
		["Codex"] = {
			Profile = 'Codex',
			Name = L['Respec Codex'],
			Desc = GetSpellDescription(256230),
			Message_Amount = 1,
			Message_Areas = {'Start'},
			Message_Channels_Disabled = {["Whisper"] = true},
			Valid_Tags = {'[SPELL]', '[LINK]'},
		},
	}
	return Spells
end

function RSA:FixDB()
	local Profiles = {
		[1] = 'DeathKnight',
		[2] = 'DemonHunter',
		[3] = 'Druid',
		[4] = 'Hunter',
		[5] = 'Mage',
		[6] = 'Monk',
		[7] = 'Paladin',
		[8] = 'Priest',
		[9] = 'Rogue',
		[10] = 'Shaman',
		[11] = 'Warlock',
		[12] = 'Warrior',
		[13] = 'Racials',
		[14] = 'Utilities',
	}
	local Functions = {
		[1] = DeathKnight_Options(),
		[2] = DemonHunter_Options(),
		[3] = Druid_Options(),
		[4] = Hunter_Options(),
		[5] = Mage_Options(),
		[6] = Monk_Options(),
		[7] = Paladin_Options(),
		[8] = Priest_Options(),
		[9] = Rogue_Options(),
		[10] = Shaman_Options(),
		[11] = Warlock_Options(),
		[12] = Warrior_Options(),
		[13] = Racial_Options(),
		[14] = Utilities_Options(),
	}
	for c = 1,#Profiles do
		local Spells = Functions[c]
		local ProfileName = Profiles[c]
		for i,v in pairs(Spells) do
			for k=1,Spells[i].Message_Amount do
				if type(RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]]) == 'string' then
					if not RSA.db.profile.Fixed then RSA.Print_Self('Fixing Database') end
					RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]] = {RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]]}
				end
			end
		end
	end
	RSA.db.profile.Fixed = true
end

local function Spell_Options(NonClass)
	local Spells, ProfileName
	local OptionName = L["Class Abilities"]
	if NonClass then
		if NonClass == 'Racials' then
			Spells = Racial_Options()
			ProfileName = 'Racials'
			OptionName = L["Racials"]
		end
		if NonClass == 'Utilities' then
			Spells = Utilities_Options()
			ProfileName = 'Utilities'
			OptionName = L["Utilities"]
		end
	elseif PlayerClass == 'DEATHKNIGHT' then
		Spells = DeathKnight_Options()
		ProfileName = 'DeathKnight'
	elseif PlayerClass == 'DEMONHUNTER' then
		Spells = DemonHunter_Options()
		ProfileName = 'DemonHunter'
	elseif PlayerClass == 'DRUID' then
		Spells = Druid_Options()
		ProfileName = 'Druid'
	elseif PlayerClass == 'HUNTER' then
		Spells = Hunter_Options()
		ProfileName = 'Hunter'
	elseif PlayerClass == 'MAGE' then
		Spells = Mage_Options()
		ProfileName = 'Mage'
	elseif PlayerClass == 'MONK' then
		Spells = Monk_Options()
		ProfileName = 'Monk'
	elseif PlayerClass == 'PALADIN' then
		Spells = Paladin_Options()
		ProfileName = 'Paladin'
	elseif PlayerClass == 'PRIEST' then
		Spells = Priest_Options()
		ProfileName = 'Priest'
	elseif PlayerClass == 'ROGUE' then
		Spells = Rogue_Options()
		ProfileName = 'Rogue'
	elseif PlayerClass == 'SHAMAN' then
		Spells = Shaman_Options()
		ProfileName = 'Shaman'
	elseif PlayerClass == 'WARLOCK' then
		Spells = Warlock_Options()
		ProfileName = 'Warlock'
	elseif PlayerClass == 'WARRIOR' then
		Spells = Warrior_Options()
		ProfileName = 'Warrior'
	end
	local Area_Orders = {
		[1] = 'Start',
		[2] = 'Placed',
		[3] = 'Cast',
		[4] = 'Dispel',
		[5] = 'Damage',
		[6] = 'Heal',
		[7] = 'Debuff',
		[8] = 'DamageAbsorb',
		[9] = 'EffectAbsorb',
		[10] = 'Interrupt',
		[11] = 'Resist',
		[12] = 'Immune',
		[13] = 'Failed',
		[14] = 'End',
		[15] = 'StatueOfTheBlackOx',
		[16] = 'AcceptedRess',
	}
	local Area_Descriptions = {
		[1] = 'When you start casting this spell or when this spell starts.',
		[2] = 'When you have placed this in the world.',
		[3] = 'When you cast this spell.',
		[4] = 'When you dispel a buff or debuff.',
		[5] = 'When you deal damage.',
		[6] = 'When you heal.',
		[7] = 'When you debuff a unit.',
		[8] = 'When you absorb damage.',
		[9] = 'When you absorb a debuff.',
		[10] = 'When you interrupt a spell cast.',
		[11] = 'When your spell is resisted.',
		[12] = 'When the target is immune to your spell.',
		[13] = 'When the spell failed.',
		[14] = 'When the spell ends.',
		[15] = 'When you cast Provoke on your Statue of the Black Ox.',
		[16] = 'When someone accepts the resurrect you cast on them.',
	}
	local Options = {
		name = OptionName,
		type = 'group',
		order = 0.01,
		childGroups ='tree',
		args = {
		},
	}
	for i,v in pairs(Spells) do
		if Spells[i] then
			if not Spells[i].Name then error('The following spell profile is causing an issue in RSA: ' .. Spells[i].Profile) else
				Options.args[Spells[i].Name] = {
					name = function()
						if Spells[i].Race then
							if RaceID ~= Spells[i].Race then
								local name = '|cffFFCC00' .. Spells[i].Name .. '|r'
								return name
							else
								local name = '|c5500DBBD' .. Spells[i].Name .. '|r'
								return name
							end
						end
						if string.len(Spells[i].Name) > 35 then
							local name = Spells[i].Name
							name = name:gsub('(%w)%S+%s*','%1')
							name = name:gsub('/ ',' / ')
							return name
						else
							return Spells[i].Name
						end
					end,
					desc = function() if Spells[i].longDesc then return Spells[i].Desc else return '|cffd1d1d1'..Spells[i].Desc..'|r' end end,
					hidden = Spells[i].Hidden or false,
					disabled = Spells[i].Hidden or false,
					order = Spells[i].Order or 5,
					type = 'group',
					childGroups = 'tab',
					args = {
						Spell_Name = {
							name = '|c5500DBBD'..L["Configuring"]..':|r '..Spells[i].Name,
							type = 'description',
							order = 0.01,
							fontSize = 'large',
						},
						Spell_Desc = {
							name = '|cffd1d1d1'..Spells[i].Desc..'|r',
							type = 'description',
							hidden = Spells[i].longDesc or false,
							order = 0.02,
						},
						Spell_LongDesc = {
							name = Spells[i].Desc,
							type = 'description',
							hidden = function() if Spells[i].longDesc then return false else return true end end,
							order = 0.02,
						},
						Channel_Header = {
							name = L["Message Announce Area"],
							type = 'header',
							order = 0.1,
						},
						Emote = {
							name = '|cffCF374D'..L["Emote"]..'|r',
							type = 'toggle',
							order = 0.11,
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Emote"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Emote
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Emote = value
							end,
						},
						Say = {
							name = '|cffCF374D'..L["Say"]..'|r',
							desc = L["%s can only function inside instances since 8.2.5."] :format(L["Say"]),
							type = 'toggle',
							order = 0.11,
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Say"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Say
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Say = value
							end,
						},
						Yell = {
							name = '|cffCF374D'..L["Yell"]..'|r',
							desc = L["%s can only function inside instances since 8.2.5."] :format(L["Yell"]),
							type = 'toggle',
							order = 0.11,
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Yell"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Yell
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Yell = value
							end,
						},
						Custom_Channel_Toggle = {
							name = '|cffCF374D'..L["Custom Channel"]..'|r',
							type = 'toggle',
							order = 1,
							desc = L["Send to player created channel."],
							--hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Custom"] then return true end end end,
							hidden = true,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Enabled
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Enabled = value
							end,
						},
						Custom_Channel_Name = {
							name = '|cffCF374D'..L["Channel Name"]..'|r',
							type = 'input',
							order = 2,
							desc = L["Only usable for player created channels, do not use for Blizzard channels such as |cff91BE0F/party|r."],
							width = 'full',
							hidden = true,
							--[[hidden = function()
								if Spells[i].Message_Channels_Disabled then
									if Spells[i].Message_Channels_Disabled["Custom"] then
										return true
									else
										return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Enabled ~= true
									end
								else
									return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Enabled ~= true
								end
							end,]]--
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Channel
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].CustomChannel.Channel = value
							end,
						},
						Instance = {
							name = '|cff91BE0F'..L["Instance"]..'|r',
							type = 'toggle',
							order = 4,
							desc = L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Instance"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Instance
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Instance = value
							end,
						},
						Raid = {
							name = '|cff91BE0F'..L["Raid"]..'|r',
							type = 'toggle',
							order = 4,
							desc = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/raid|r if you're in a manually formed raid."] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Raid"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Raid
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Raid = value
							end,
						},
						Party = {
							name = '|cff91BE0F'..L["Party"]..'|r',
							type = 'toggle',
							order = 4,
							desc = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/party|r if you're in a manually formed group."] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."],
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Party"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Party
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Party = value
							end,
						},
						Local = {
							name = '|cff00B2FA'..L["Local"]..'|r',
							type = 'toggle',
							order = 5,
							desc = L["Sends a message locally only visible to you. To choose which part of the UI this is displayed in go to the |cff00B2FALocal Message Output Area|r in the General options."],
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Local"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Local
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Local = value
							end,
						},
						Whisper = {
							name = '|cffFFCC00'..L["Whisper"]..'|r',
							type = 'toggle',
							desc = L["|cffFFCC00Whispers|r the target of the spell."] .. '\n' .. L["This setting also does not follow the global announcement settings, and will, if checked, announce regardless of those settings."],
							order = 6,
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["Whisper"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Whisper
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Whisper = value
							end,
						},
						Smart_Group = {
							name = '|cffFFCC00'..L["Smart Group Channel"]..'|r',
							type = 'toggle',
							order = 7,
							desc = L["Sends a message to one of the following channels in order of priority:"] .. '\n' .. L["|cff91BE0F/instance|r if you're in an instance group such as when in LFR or Battlegrounds."] .. '\n' .. L["|cff91BE0F/raid|r if you're in a manually formed raid."] .. '\n' .. L["|cff91BE0F/party|r if you're in a manually formed group."],
							hidden = function() if Spells[i].Message_Channels_Disabled then if Spells[i].Message_Channels_Disabled["SmartGroup"] then return true end end end,
							get = function(info)
								return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].SmartGroup
							end,
							set = function (info, value)
								RSA.db.profile[ProfileName].Spells[Spells[i].Profile].SmartGroup = value
							end,
						},
						Message_Header = {
							name = L["Message Texts"],
							type = 'header',
							order = 100,
						},
						Message_Description = {
							name = L["The following tags are available for use with this spell:"],
							type = 'description',
							order = 100.1,
							fontSize = 'medium',
						},
					},
				}
			end
		end

		-- Add usable tags to description.
		local TagList = ''
		for j = 1,#Spells[i].Valid_Tags do
			if j == 1 then--(j % 2 == 0) then
				--TagList = TagList ..', '.. '|c5500DBBD' .. Spells[i].Valid_Tags[j] .. '|r'
				TagList = '\n'.. '|c5500DBBD' .. Spells[i].Valid_Tags[j] .. '|r'
			else
				TagList = TagList ..', '.. '|c5500DBBD' .. Spells[i].Valid_Tags[j] .. '|r'
				--TagList = TagList ..'\n'.. '|c5500DBBD' .. Spells[i].Valid_Tags[j] .. '|r'
			end
		end
		Options.args[Spells[i].Name].args.Message_Description.name = L["The following tags are available for use with this spell:"] .. TagList

		-- Iterate Messages
		for k=1,Spells[i].Message_Amount do
			local OrderVal
			for n = 1,#Area_Orders do -- Order message areas logically (i.e Start message is displayed before End message)
				if Spells[i].Message_Areas[k] == Area_Orders[n] then
					OrderVal = n
				end
			end
			local Messages = {}
			for _,v in pairs(RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]]) do -- Add valid messages to list.
				if string.match(v,'%w') then
					if v ~= '' then
						table.insert(Messages,v)
					end
				end
			end
			Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]] = {
				name = L[Spells[i].Message_Areas[k]],
				type = 'group',
				desc = L[Area_Descriptions[OrderVal]],
				order = 110 + OrderVal,
				args = {
					Description = {
						name = L[Spells[i].Message_Areas[k]].. ': |cffFFCC00'.. L[Area_Descriptions[OrderVal]]..'|r\n',
						type = 'description',
						order = 0,
						fontSize = 'medium',
					},
					Add = {
						name = L["Add New Message"],
						type = 'input',
						order = 10,
						width = 'full',
						validate = function(info, value)
							if value == '' then return true end -- Pressed enter without entering anything, we don't need to warn about this.
							if not string.match(value,'%w') then
								RSA.Print_Self(L["Your message must contain at least one number or letter!"])
								return L["Your message must contain at least one number or letter!"]
							else
								return true
							end
						end,
						set = function(info, value)
							table.insert(RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]],value)
							RSA:UpdateOptions()
							RSA.WipeMessageCache()
						end,
					},
					List_Description = {
						name = 'Placeholder',
						type = 'description',
						order = 15,
						fontSize = 'medium',
					},
				},
			}
			if #Messages == 0 then
				Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]].args.List_Description.name = '\n'.. L["You have no messages for this section."]..L[" If you wish to add a message for this section, enter it above in the |cffFFD100Add New Message|r box. As no messages exist, nothing will be announced for this section."]
			elseif #Messages == 1 then
				Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]].args.List_Description.name = '\n'.. L["You have %d message for this section."]:format(#Messages)..L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."]
			else
				Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]].args.List_Description.name = '\n'.. L["You have %d messages for this section."]:format(#Messages)..L[" RSA will choose a message from this section at random, if you wish to remove a message, delete the contents and press enter. If no messages exist, nothing will be announced for this section."]
			end


			if Spells[i].Requirements then
				for r=1,#Spells[i].Requirements do
					if Spells[i].Requirements[r] == 'LRI' and k == 2 then -- k == 2 means it's the second message. The second message for resses in RSA is always the end message.
					local LRI = LibStub('LibResInfo-1.0',true)
					if not LRI then
						Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]].args.List_Description.name = L["This section requires LibResInfo-1.0 to work. As you don't have it, nothing from this section will announce."]
					end
					end
				end
			end



			for l=1,#Messages do
				Options.args[Spells[i].Name].args[Spells[i].Message_Areas[k]].args[tostring(l)] = {
					type = 'input',
					width = 'full',
					name = tostring(l),
					order = 20,
					validate = function(info, value)
						if value == '' then return true end
						if not string.match(value,'%w') then
							RSA.Print_Self(L["Your message must contain at least one number or letter!"])
							return L["Your message must contain at least one number or letter!"]
						else
							return true
						end
					end,
					get = function(info)
						if RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]][l] == '' then
							table.remove(RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]],l)
						end
						RSA:UpdateOptions()
						return RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]][l]
					end,
					set = function(info, value)
						if value == '' then
							RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]][l] = ''
						else
							RSA.db.profile[ProfileName].Spells[Spells[i].Profile].Messages[Spells[i].Message_Areas[k]][l] = value
						end
						RSA:UpdateOptions()
						RSA.WipeMessageCache()
					end,
				}
			end
		end
	end
	return Options
end

local function LibSink_Options()
	Options.args.General.args.Output = RSA_O:GetSinkAce3OptionsDataTable() -- Add LibSink Options.
	Options.args.General.args.Output.args.Channel = nil -- We don't want to display this, and it's broken since 8.2.5 anyway.
	Options.args.General.args.Output.name = '|cff00B2FA'..L["Local Message Output Area"]..'|r'
	Options.args.General.args.Output.order = 100.6
	Options.args.General.args.Output.inline = true
end

local function AddOptions()
	Options.args.General.args.LibSink = LibSink_Options()
	Options.args.Spells.args.Class = Spell_Options()
	--Options.args.Spells.args.Consumables = Spell_Options('Consumables')
	Options.args.Spells.args.Racials = Spell_Options('Racials')
	Options.args.Spells.args.Utilities = Spell_Options('Utilities')
end

function RSA_O:OnInitialize()
	self.db = RSA.db
	self:SetSinkStorage(self.db.profile) -- Setup Saved Variables for LibSink

	-- Profile Management
	self.db.RegisterCallback(RSA, 'OnProfileChanged', 'RefreshConfig')
	self.db.RegisterCallback(RSA, 'OnProfileCopied', 'RefreshConfig')
	self.db.RegisterCallback(RSA, 'OnProfileReset', 'RefreshConfig')

	if not self.db.profile.Fixed then
		RSA:FixDB()
	end

	-- Register Various Options
	LibStub('AceConfig-3.0'):RegisterOptionsTable('RSA', Options) -- Register Options
	local Profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	Options.args.profiles = Profiles
	Options.args.profiles.order = 99
	AddOptions()
	LibStub('AceConfigDialog-3.0'):SetDefaultSize('RSA',975,740)
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, 'RSA')
	LibDualSpec:EnhanceOptions(Profiles, self.db)
	InterfaceAddOnsList_Update()
end

function RSA:UpdateOptions()
	AddOptions()
	LibStub('AceConfigRegistry-3.0'):NotifyChange('RSA')
end

function RSA_O:RefreshConfig()
	RSA.db.profile = self.db.profile
	RSA:UpdateOptions()
end
