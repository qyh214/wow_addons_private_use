local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

if RSA.IsRetail() then
	local defaults = {
		['absolution'] = {
			spellID = 212056,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK] finished, get up!',},
				},
			},
		},
		['ardentDefender'] = {
			spellID = 31850,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					uniqueSpellID = 66235, -- Ardent Defender uses a different spell ID when the heal effect triggers.
					tracker = 1, -- Tells the monitor to not announce any further messages for this spell, so that we don't also announce the finishing message.
					messages = {"[LINK] saved my life and healed me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_CAST_SUCCESS'] = {
					tracker = 2, -- Tells the monitor to start tracking this spell so that we can prevent both the Heal and Finish message from playing if the heal triggers.
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['auraMastery'] = {
			spellID = 31821,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				--TODO: Implement source/dest options and code support for event based targets and sources.
				['SPELL_AURA_REMOVED'] = {
					dest = {'player'},
					messages = {"[LINK] finished!",},
				},
			},
		},
		['avengersShield'] = {
			spellID = 31935,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true, -- Replaces AURA and TARSPELL.
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = { -- Fake event to easily generate options for immune specific messages.
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['avengingWrath'] = {
			spellID = 31884,
			additionalSpellIDs = {
				[231895] = true, -- Crusade
				[216331] = true, -- Avenging Crusader
				[389539] = true, -- Sentinel

			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
				defaultName = RSA.Helpers.GetSpellInfo(31884).name .. ' | ' .. RSA.Helpers.GetSpellInfo(216331).name .. ' | ' .. RSA.Helpers.GetSpellInfo(231895).name .. ' | ' .. RSA.Helpers.GetSpellInfo(389539).name,
				defaultDesc = RSA.DescTableBuilder(31884),
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['beaconOfLight'] = {
			spellID = 53563,
			additionalSpellIDs = {
				[156910] = true, -- Beacon of Faith
			},
			configDisplay = {
				isDefault = true,
				defaultName = RSA.Helpers.GetSpellInfo(53563).name .. ' | ' .. RSA.Helpers.GetSpellInfo(156910).name,
				defaultDesc = '|cffFFCC00'..RSA.Helpers.GetSpellInfo(53563).name .. ':|r |cffd1d1d1' .. RSA.Helpers.GetSpellDescription(53563) .. '|r\n\n|cffFFCC00' .. RSA.Helpers.GetSpellInfo(156910).name .. ':|r |cffd1d1d1' .. RSA.Helpers.GetSpellDescription(156910) .. '|r',
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfAutumn'] = {
			spellID = 388010,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfFreedom'] = {
			spellID = 1044,
			additionalSpellIDs = {
				[305395] = true, -- Unbound Freedom
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfProtection'] = {
			spellID = 1022,
			additionalSpellIDs = {
				[204018] = true, -- Blessing of Spellwarding
			},
			configDisplay = {
				isDefault = true,
				defaultName = RSA.Helpers.GetSpellInfo(1022).name .. ' | ' .. RSA.Helpers.GetSpellInfo(204018).name,
				defaultDesc = '|cffFFCC00'..RSA.Helpers.GetSpellInfo(1022).name .. ':|r |cffd1d1d1' .. RSA.Helpers.GetSpellDescription(1022) .. '|r\n\n|cffFFCC00' .. RSA.Helpers.GetSpellInfo(204018).name .. ':|r |cffd1d1d1' .. RSA.Helpers.GetSpellDescription(204018) .. '|r',
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSacrifice'] = {
			spellID = 6940,
			additionalSpellIDs = {
				[199448] = true, -- Ultimate Sacrifice
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSanctuary'] = {
			spellID = 210256,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSpring'] = {
			spellID = 388013,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSummer_2'] = {
			spellID = 388007,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfWinter'] = {
			spellID = 388011,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['cleanse'] = {
			spellID = 4987,
			throttle = 0.25,
			additionalSpellIDs = {
				[213644] = true, -- Cleanse Toxins
			},
			configDisplay = {
				isDefault = true,
				defaultName = RSA.Helpers.GetSpellInfo(4987).name .. ' | ' .. RSA.Helpers.GetSpellInfo(213644).name,
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Cleansed [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['divineProtection'] = {
			spellID = 498,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineShield'] = {
			spellID = 642,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['eyeOfTyr'] = {
			spellID = 387174,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['RSA_END_TIMER'] = {
					duration = 9,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['eyeForAnEye'] = {
			spellID = 205191,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['finalStand'] = {
			spellID = 204079,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['forbearance'] = {
			spellID = 25771,
			configDisplay = {
				isDefault = true,
				disabledChannels = {
					say = true,
					yell = true,
					emote = true,
					party = true,
					raid = true,
					instance = true,
					smartGroup = true,
					whisper = true,
				},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[TARGET] afflicted with [LINK]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] ended!",},
					tags = {TARGET = true,},
				},
			},
		},
		['guardianOfAncientKings'] = {
			spellID = 86659,
			additionalSpellIDs = {
				[212641] = true, -- Glyph of the Queen
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['guardianOfTheForgottenQueen'] = {
			spellID = 228049,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['hammerOfJustice'] = {
			spellID = 853,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['handOfReckoning'] = {
			spellID = 62124,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"Taunted [TARGET]!",},
					tags = {
						TARGET = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['holyAvenger'] = {
			spellID = 105809,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['intercession'] = {
			spellID = 391054,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_RESURRECT'] = {
					messages = {"Resurrected [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {"Casting [LINK] on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['layOnHands'] = {
			spellID = 633,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
			},
		},
		['rebuke'] = {
			spellID = 96231,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true, -- Replaces AURA and TARSPELL.
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = { -- Fake event to easily generate options for immune specific messages.
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['redemption'] = {
			spellID = 7328,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_RESURRECT'] = {
					messages = {"Resurrected [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK] on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['repentance'] = {
			spellID = 20066,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['shieldOfVengeance'] = {
			spellID = 184662,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['turnEvil'] = {
			spellID = 10326,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
	}

	RSA.monitorData.paladin, RSA.configData.paladin = RSA.PrepareDataTables(defaults)
end

if RSA.IsWrath() then
	local wrath = {
		['ardentDefender'] = {
			spellID = 31850,
			throttle = 0.25,
			additionalSpellIDs = {
				[31851] = true, -- Rank 2
				[31852] = true, -- Rank 3
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					uniqueSpellID = 66235, -- Ardent Defender uses a different spell ID when the heal effect triggers.
					tracker = 1, -- Tells the monitor to not announce any further messages for this spell, so that we don't also announce the finishing message.
					messages = {"[LINK] saved my life and healed me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_CAST_SUCCESS'] = {
					tracker = 2, -- Tells the monitor to start tracking this spell so that we can prevent both the Heal and Finish message from playing if the heal triggers.
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['auraMastery'] = {
			spellID = 31821,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				--TODO: Implement source/dest options and code support for event based targets and sources.
				['SPELL_AURA_REMOVED'] = {
					dest = {'player'},
					messages = {"[LINK] finished!",},
				},
			},
		},
		['avengersShield'] = {
			spellID = 31935,
			throttle = 0.25,
			additionalSpellIDs = {
				[32699] = true, -- Rank 2
				[32700] = true, -- Rank 3
				[48826] = true, -- Rank 4
				[48827] = true, -- Rank 5
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true, -- Replaces AURA and TARSPELL.
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = { -- Fake event to easily generate options for immune specific messages.
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['avengingWrath'] = {
			spellID = 31884,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['beaconOfLight'] = {
			spellID = 53563,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfFreedom'] = {
			spellID = 1044,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSacrifice'] = {
			spellID = 6940,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSanctuary'] = {
			spellID = 20911,
			additionalSpellIDs = {
				[25899] = true, -- Greater Blessing of Sanctuary
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfProtection'] = {
			spellID = 1022,
			additionalSpellIDs = {
				[5599] = true, -- Rank 2
				[10278] = true, -- Rank 3
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['cleanse'] = {
			spellID = 4987,
			throttle = 0.25,
			additionalSpellIDs = {
				[1152] = true, -- Purify
			},
			configDisplay = {
				isDefault = true,
				defaultName = RSA.Helpers.GetSpellInfo(4987).name .. ' | ' .. RSA.Helpers.GetSpellInfo(1152).name,
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Cleansed [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['divinePlea'] = {
			spellID = 54428,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineProtection'] = {
			spellID = 498,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineSacrifice'] = {
			spellID = 64205,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					dest = {'player'},
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineShield'] = {
			spellID = 642,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['forbearance'] = {
			spellID = 25771,
			configDisplay = {
				isDefault = true,
				disabledChannels = {
					say = true,
					yell = true,
					emote = true,
					party = true,
					raid = true,
					instance = true,
					smartGroup = true,
					whisper = true,
				},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[TARGET] afflicted with [LINK]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] ended!",},
					tags = {TARGET = true,},
				},
			},
		},
		['hammerOfJustice'] = {
			spellID = 853,
			additionalSpellIDs = {
				[5588] = true, -- Rank 2
				[5589] = true, -- Rank 3
				[10308] = true, -- Rank 4
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['handOfReckoning'] = {
			spellID = 62124,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"Taunted [TARGET]!",},
					tags = {
						TARGET = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['handOfSalvation'] = {
			spellID = 1038,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['layOnHands'] = {
			spellID = 633,
			additionalSpellIDs = {
				[2800] = true, -- Rank 2
				[10310] = true, -- Rank 3
				[27154] = true, -- Rank 4
				[48788] = true, -- Rank 5
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
			},
		},
		['redemption'] = {
			spellID = 7328,
			additionalSpellIDs = {
				[10322] = true, -- Rank 2
				[10324] = true, -- Rank 3
				[20772] = true, -- Rank 4
				[20773] = true, -- Rank 5
				[48949] = true, -- Rank 6
				[48950] = true, -- Rank 7
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_RESURRECT'] = {
					messages = {"Resurrected [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK] on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['repentance'] = {
			spellID = 20066,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['sacredShield'] = {
			spellID = 53601,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['turnEvil'] = {
			spellID = 10326,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
	}

	RSA.monitorData.paladin, RSA.configData.paladin = RSA.PrepareDataTables(wrath)
end

if RSA.IsCata() then
	local cata = {
		['ardentDefender'] = {
			spellID = 31850,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					uniqueSpellID = 66235, -- Ardent Defender uses a different spell ID when the heal effect triggers.
					tracker = 1, -- Tells the monitor to not announce any further messages for this spell, so that we don't also announce the finishing message.
					messages = {"[LINK] saved my life and healed me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_CAST_SUCCESS'] = {
					tracker = 2, -- Tells the monitor to start tracking this spell so that we can prevent both the Heal and Finish message from playing if the heal triggers.
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['auraMastery'] = {
			spellID = 31821,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				--TODO: Implement source/dest options and code support for event based targets and sources.
				['SPELL_AURA_REMOVED'] = {
					dest = {'player'},
					messages = {"[LINK] finished!",},
				},
			},
		},
		['avengersShield'] = {
			spellID = 31935,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true, -- Replaces AURA and TARSPELL.
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = { -- Fake event to easily generate options for immune specific messages.
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['avengingWrath'] = {
			spellID = 31884,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['beaconOfLight'] = {
			spellID = 53563,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfFreedom'] = {
			spellID = 1044,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfSacrifice'] = {
			spellID = 6940,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['blessingOfProtection'] = {
			spellID = 1022,
			additionalSpellIDs = {
				[5599] = true, -- Rank 2
				[10278] = true, -- Rank 3
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['cleanse'] = {
			spellID = 4987,
			throttle = 0.25,
			additionalSpellIDs = {
				[1152] = true, -- Purify
			},
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Cleansed [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['divinePlea'] = {
			spellID = 54428,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineProtection'] = {
			spellID = 498,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineSacrifice'] = {
			spellID = 64205,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					dest = {'player'},
					messages = {"[LINK] finished!",},
				},
			},
		},
		['divineShield'] = {
			spellID = 642,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['forbearance'] = {
			spellID = 25771,
			configDisplay = {
				isDefault = true,
				disabledChannels = {
					say = true,
					yell = true,
					emote = true,
					party = true,
					raid = true,
					instance = true,
					smartGroup = true,
					whisper = true,
				},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[TARGET] afflicted with [LINK]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] ended!",},
					tags = {TARGET = true,},
				},
			},
		},
		['hammerOfJustice'] = {
			spellID = 853,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['handOfReckoning'] = {
			spellID = 62124,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"Taunted [TARGET]!",},
					tags = {
						TARGET = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['handOfSalvation'] = {
			spellID = 1038,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['layOnHands'] = {
			spellID = 633,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
			},
		},
		['redemption'] = {
			spellID = 7328,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_RESURRECT'] = {
					messages = {"Resurrected [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK] on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['repentance'] = {
			spellID = 20066,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['turnEvil'] = {
			spellID = 10326,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_BROKEN_SPELL'] = {
					messages = {"[SOURCE] removed [LINK] on [TARGET] with [EXTRALINK]!",},
					tags = {
						TARGET = true,
						SOURCE = true,
						EXTRA = true,
					},
				},
				['SPELL_MISSED'] = {
					messages = {"[LINK] [MISSTYPE] [TARGET]!",},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
	}

	RSA.monitorData.paladin, RSA.configData.paladin = RSA.PrepareDataTables(cata)
end