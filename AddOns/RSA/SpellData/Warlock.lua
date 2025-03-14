local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

if RSA.IsRetail() then
	local defaults = {
		['axeToss'] = {
			spellID = 89766,
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
		['banish'] = {
			spellID = 710,
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
		['createSoulwell'] = {
			spellID = 29893,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK] placed!',},
				},
			},
		},
		['darkPact'] = {
			spellID = 108416,
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
		['demonicGateway'] = {
			spellID = 111771,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK] placed!',},
				},
			},
		},
		['devourMagic'] = {
			spellID = 19505,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Dispelled [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
				['SPELL_DISPEL_FAILED'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['fear'] = {
			spellID = 5782,
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
		['mortalCoil'] = {
			spellID = 6789,
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
		['ritualOfSummoning'] = {
			spellID = 698,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK], please assist!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK], placed!',},
				},
			},
		},
		['seduce'] = {
			spellID = 6358,
			additionalSpellIDs = {
				[115268] = true, -- Mesmerize (Glyph of the Shivarra)
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
		['shadowfury'] = {
			spellID = 30283,
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['singeMagic'] = {
			spellID = 89808,
			throttle = 0.25,
			additionalSpellIDs = {
				[115276] = true, -- Sear Magic (Glyph of Fel Imp)
				[132411] = true, -- Player variant from Grimoire of Sacrifice
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
		['soulstone'] = {
			spellID = 20707,
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
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['spellLock'] = {
			spellID = 19647,
			additionalSpellIDs = {
				[115781] = true, -- Optical Blast (Glyph of Observer)
				[132409] = true, -- Player variant from Grimoire of Sacrifice
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
		['suffering'] = {
			spellID = 17735,
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
		['unendingResolve'] = {
			spellID = 104773,
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
	}

	RSA.monitorData.warlock, RSA.configData.warlock = RSA.PrepareDataTables(defaults)
end

if RSA.IsWrath() then
	local wrath = {
		['banish'] = {
			spellID = 710,
			additionalSpellIDs = {
				[18647] = true, -- Rank 2
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
		['ritualOfSouls'] = {
			spellID = 29893,
			additionalSpellIDs = {
				[58887] = true, -- Rank 2
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK] placed!',},
				},
			},
		},
		['darkPact'] = {
			spellID = 18220,
			additionalSpellIDs = {
				[18937] = true, -- Rank 2
				[18938] = true, -- Rank 3
				[27265] = true, -- Rank 4
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
		['devourMagic'] = {
			spellID = 19505,
			throttle = 0.25,
			additionalSpellIDs = {
				[19731] = true, -- Rank 2
				[19734] = true, -- Rank 3
				[19736] = true, -- Rank 4
				[27276] = true, -- Rank 5
				[27277] = true, -- Rank 6
				[48011] = true, -- Rank 7
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Dispelled [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
				['SPELL_DISPEL_FAILED'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['fear'] = {
			spellID = 5782,
			additionalSpellIDs = {
				[6213] = true, -- Rank 2
				[6215] = true, -- Rank 3
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
		['deathCoil'] = {
			spellID = 6789,
			additionalSpellIDs = {
				[17925] = true, -- Rank 2
				[17926] = true, -- Rank 3
				[27223] = true, -- Rank 4
				[47859] = true, -- Rank 5
				[47860] = true, -- Rank 6
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
		['ritualOfSummoning'] = {
			spellID = 698,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK], please assist!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK], placed!',},
				},
			},
		},
		['seduce'] = {
			spellID = 6358,
			additionalSpellIDs = {
				[115268] = true, -- Mesmerize (Glyph of the Shivarra)
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
		['shadowfury'] = {
			spellID = 30283,
			additionalSpellIDs = {
				[30413] = true, -- Rank 2
				[30414] = true, -- Rank 3
				[47846] = true, -- Rank 4
				[47847] = true, -- Rank 5
			},
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['soulstone'] = {
			spellID = 20707,
			additionalSpellIDs = {
				[20762] = true, -- Rank 2
				[20763] = true, -- Rank 3
				[20764] = true, -- Rank 4
				[20765] = true, -- Rank 5
				[27239] = true, -- Rank 6
				[47883] = true, -- Rank 7

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
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['spellLock'] = {
			spellID = 19244,
			additionalSpellIDs = {
				[19647] = true,
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
		['suffering'] = {
			spellID = 17735,
			additionalSpellIDs = {
				[17750] = true, -- Rank 2
				[17751] = true, -- Rank 3
				[17752] = true, -- Rank 4
				[27271] = true, -- Rank 5
				[33701] = true, -- Rank 6
				[47989] = true, -- Rank 7
				[47990] = true, -- Rank 8
			},
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
	}

	RSA.monitorData.warlock, RSA.configData.warlock = RSA.PrepareDataTables(wrath)
end

if RSA.IsCata() then
	local cata = {
		['banish'] = {
			spellID = 710,
			additionalSpellIDs = {
				[18647] = true, -- Rank 2
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
		['ritualOfSouls'] = {
			spellID = 29893,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK] placed!',},
				},
			},
		},
		['devourMagic'] = {
			spellID = 19505,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_DISPEL'] = {
					messages = {"Dispelled [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
				['SPELL_DISPEL_FAILED'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['fear'] = {
			spellID = 5782,
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
		['deathCoil'] = {
			spellID = 6789,
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
		['ritualOfSummoning'] = {
			spellID = 698,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK], please assist!',},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {'[LINK], placed!',},
				},
			},
		},
		['seduce'] = {
			spellID = 6358,
			additionalSpellIDs = {
				[115268] = true, -- Mesmerize (Glyph of the Shivarra)
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
		['shadowfury'] = {
			spellID = 30283,
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['soulstone'] = {
			spellID = 20707,
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
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['spellLock'] = {
			spellID = 19647,
			additionalSpellIDs = {
				[19647] = true,
				[24259] = true,
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
		['suffering'] = {
			spellID = 17735,
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
	}

	RSA.monitorData.warlock, RSA.configData.warlock = RSA.PrepareDataTables(cata)
end