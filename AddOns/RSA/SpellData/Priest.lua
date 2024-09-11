local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

if RSA.IsRetail() then
	local defaults = {
		['apotheosis'] = {
			spellID = 200183,
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
		['archangel'] = {
			spellID = 197862,
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
		['bodyAndSoul'] = {
			spellID = 65081,
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
		['desperatePrayer'] = {
			spellID = 19236,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] activated, healing me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['dispelMagic'] = {
			spellID = 528,
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
		['divineHymn'] = {
			spellID = 64843,
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
		['evangelism'] = {
			spellID = 246287,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['fade'] = {
			spellID = 586,
			additionalSpellIDs = {
				[213602] = true, -- Greater Fade
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
		['guardianSpirit'] = {
			spellID = 47788,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					tracker = 2,
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_HEAL'] = {
					uniqueSpellID = 48153,
					tracker = 1,
					messages = {"[LINK] prevented [TARGET]'s death and healed them for [AMOUNT]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['holyWard'] = {
			spellID = 213610,
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
		['holyWordChastise'] = {
			spellID = 200196,
			additionalSpellIDs = {
				[200200] = true, -- Chastise modified by Censure talent.
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
		['holyWordSalvation'] = {
			spellID = 265202,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['leapOfFaith'] = {
			spellID = 73325,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['levitate'] = {
			spellID = 1706,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['massDispel'] = {
			spellID = 32375,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK]!",},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['massResurrection'] = {
			spellID = 212036,
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
		['mindBomb'] = {
			throttle = 3,
			spellID = 205369,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					uniqueSpellID = 226943,
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['mindControl'] = {
			spellID = 605,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
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
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['painSuppression'] = {
			spellID = 33206,
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
		['powerInfusion_2'] = {
			spellID = 10060,
			throttle = 0.5,
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
		['powerWordBarrier'] = {
			spellID = 62618,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['RSA_END_TIMER'] = {
					duration = 10,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['psychicHorror'] = {
			spellID = 64044,
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
		['psychicScream'] = {
			spellID = 8122,
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
		['purify'] = {
			spellID = 527,
			throttle = 0.25,
			additionalSpellIDs = {
				[213634] = true, -- Purify Disease
			},
			configDisplay = {
				isDefault = true,
				defaultName = RSA.Helpers.GetSpellInfo(527).name .. ' | ' .. RSA.Helpers.GetSpellInfo(213634).name,
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
		['rapture'] = {
			spellID = 47536,
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
		['rayOfHope'] = {
			spellID = 197268,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					tracker = 2,
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_HEAL'] = {
					uniqueSpellID = 197336,
					tracker = 1,
					messages = {"[LINK] prevented [TARGET]'s death and healed them for [AMOUNT]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['resurrection'] = {
			spellID = 2006,
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
		['shackleUndead'] = {
			spellID = 9484,
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
				-- TODO: Check source is source of spell breaking, not source of the CC itself.
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
		['shadowfiend'] = {
			spellID = 34433,
			additionalSpellIDs = {
				[123040] = true, -- Mindbender Discipline
				[200174] = true, -- Mindbender Shadow
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['silence'] = {
			spellID = 15487,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					uniqueSpellID = 220543,
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
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
		['symbolOfHope'] = {
			spellID = 64901,
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
		['vampiricEmbrace'] = {
			spellID = 15286,
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

	RSA.monitorData.priest, RSA.configData.priest = RSA.PrepareDataTables(defaults)
end

if RSA.IsWrath() then
	local wrath = {
		['abolishDisease'] = {
			spellID = 552,
			throttle = 0.5,
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
				['SPELL_DISPEL'] = {
					messages = {"Cleansed [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['bodyAndSoul'] = {
			spellID = 65081,
			additionalSpellIDs = {
				[64128] = true, -- Rank 1
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
		['cureDisease'] = {
			spellID = 528,
			throttle = 0.25,
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
		['desperatePrayer'] = {
			spellID = 19236,
			additionalSpellIDs = {
				[19238] = true, -- Rank 2
				[19240] = true, -- Rank 3
				[19241] = true, -- Rank 4
				[19242] = true, -- Rank 5
				[19243] = true, -- Rank 6
				[25437] = true, -- Rank 7
				[48172] = true, -- Rank 8
				[48173] = true, -- Rank 9
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] activated, healing me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['dispelMagic'] = {
			spellID = 527,
			throttle = 0.25,
			additionalSpellIDs = {
				[988] = true, -- Rank 2
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
		['divineHymn'] = {
			spellID = 64843,
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
		['fade'] = {
			spellID = 586,
			additionalSpellIDs = {
				[213602] = true, -- Greater Fade
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
		['guardianSpirit'] = {
			spellID = 47788,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					tracker = 2,
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_HEAL'] = {
					uniqueSpellID = 48153,
					tracker = 1,
					messages = {"[LINK] prevented [TARGET]'s death and healed them for [AMOUNT]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['levitate'] = {
			spellID = 1706,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['massDispel'] = {
			spellID = 32375,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK]!",},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['mindControl'] = {
			spellID = 605,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
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
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['painSuppression'] = {
			spellID = 33206,
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
		['powerInfusion'] = {
			spellID = 10060,
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
		['psychicHorror'] = {
			spellID = 64044,
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
		['psychicScream'] = {
			spellID = 8122,
			additionalSpellIDs = {
				[8124] = true, -- Rank 2
				[10888] = true, -- Rank 3
				[10890] = true, -- Rank 4
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
		['rapture'] = {
			spellID = 47535,
			additionalSpellIDs = {
				[47536] = true, -- Rank 2
				[47537] = true, -- Rank 3
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
		['resurrection'] = {
			spellID = 2006,
			additionalSpellIDs = {
				[2010] = true, -- Rank 2
				[10880] = true, -- Rank 3
				[10881] = true, -- Rank 4
				[20770] = true, -- Rank 5
				[25435] = true, -- Rank 6
				[48171] = true, -- Rank 7
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
		['shackleUndead'] = {
			spellID = 9484,
			additionalSpellIDs = {
				[9485] = true, -- Rank 2
				[10955] = true, -- Rank 3
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
				-- TODO: Check source is source of spell breaking, not source of the CC itself.
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
		['shadowfiend'] = {
			spellID = 34433,
			additionalSpellIDs = {
				[123040] = true, -- Mindbender Discipline
				[200174] = true, -- Mindbender Shadow
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['silence'] = {
			spellID = 15487,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					uniqueSpellID = 220543,
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
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
		['symbolOfHope'] = {
			spellID = 64901,
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
		['vampiricEmbrace'] = {
			spellID = 15286,
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

	RSA.monitorData.priest, RSA.configData.priest = RSA.PrepareDataTables(wrath)
end

if RSA.IsCata() then
	local cata = {
		['bodyAndSoul'] = {
			spellID = 64127,
			additionalSpellIDs = {
				[64129] = true, -- Rank 2
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
		['cureDisease'] = {
			spellID = 528,
			throttle = 0.25,
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
		['desperatePrayer'] = {
			spellID = 19236,
			additionalSpellIDs = {
				[19238] = true, -- Rank 2
				[19240] = true, -- Rank 3
				[19241] = true, -- Rank 4
				[19242] = true, -- Rank 5
				[19243] = true, -- Rank 6
				[25437] = true, -- Rank 7
				[48172] = true, -- Rank 8
				[48173] = true, -- Rank 9
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] activated, healing me for [AMOUNT]!",},
					tags = {AMOUNT = true,},
				},
				['SPELL_AURA_REMOVED'] = {
					messages = {"[LINK] finished!",},
				},
			},
		},
		['dispelMagic'] = {
			spellID = 527,
			throttle = 0.25,
			additionalSpellIDs = {
				[988] = true, -- Rank 2
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
		['divineHymn'] = {
			spellID = 64843,
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
		['fade'] = {
			spellID = 586,
			additionalSpellIDs = {
				[213602] = true, -- Greater Fade
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
		['guardianSpirit'] = {
			spellID = 47788,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					tracker = 2,
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
				['SPELL_HEAL'] = {
					uniqueSpellID = 48153,
					tracker = 1,
					messages = {"[LINK] prevented [TARGET]'s death and healed them for [AMOUNT]!",},
					tags = {
						TARGET = true,
						AMOUNT = true,
					},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] on [TARGET] finished!",},
					tags = {TARGET = true,},
				},
			},
		},
		['levitate'] = {
			spellID = 1706,
			configDisplay = {
				isDefault = true,
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] cast on [TARGET]!",},
					tags = {TARGET = true,},
				},
			},
		},
		['massDispel'] = {
			spellID = 32375,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {"Casting [LINK]!",},
				},
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['mindControl'] = {
			spellID = 605,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
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
				['RSA_SPELL_IMMUNE'] = {
					messages = {"[TARGET] [MISSTYPE] [LINK]!"},
					tags = {
						TARGET = true,
						MISSTYPE = true,
					},
				},
			},
		},
		['painSuppression'] = {
			spellID = 33206,
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
		['powerInfusion'] = {
			spellID = 10060,
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
		['psychicHorror'] = {
			spellID = 64044,
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
		['psychicScream'] = {
			spellID = 8122,
			additionalSpellIDs = {
				[8124] = true, -- Rank 2
				[10888] = true, -- Rank 3
				[10890] = true, -- Rank 4
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
		['rapture'] = {
			spellID = 47535,
			additionalSpellIDs = {
				[47536] = true, -- Rank 2
				[47537] = true, -- Rank 3
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
		['resurrection'] = {
			spellID = 2006,
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
		['shackleUndead'] = {
			spellID = 9484,
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
				-- TODO: Check source is source of spell breaking, not source of the CC itself.
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
		['shadowfiend'] = {
			spellID = 34433,
			additionalSpellIDs = {
				[123040] = true, -- Mindbender Discipline
				[200174] = true, -- Mindbender Shadow
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['silence'] = {
			spellID = 15487,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_INTERRUPT'] = {
					uniqueSpellID = 220543,
					messages = {"Interrupted [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
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
		['symbolOfHope'] = {
			spellID = 64901,
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
		['vampiricEmbrace'] = {
			spellID = 15286,
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

	RSA.monitorData.priest, RSA.configData.priest = RSA.PrepareDataTables(cata)
end