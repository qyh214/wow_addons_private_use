local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

local defaults = {
	['barkskin'] = {
		spellID = 22812,
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
	['berserk'] = {
		spellID = 106951,
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
	['cyclone'] = {
		spellID = 33786,
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
	['demoralizingRoar'] = {
		spellID = 201664,
		throttle = 2,
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
	['entanglingRoots'] = {
		spellID = 339,
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
			--TODO: Test that this event exists for Roots.
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
	['frenziedRegeneration'] = {
		spellID = 22842,
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
	['growl'] = {
		spellID = 6795,
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
	['hibernate'] = {
		spellID = 2637,
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
	['incapacitatingRoar'] = {
		spellID = 99,
		throttle = 2,
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
	['innervate'] = {
		spellID = 29166,
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
	['ironbark'] = {
		spellID = 102342,
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
	['ironfur'] = {
		spellID = 192081,
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
	['massEntanglingRoots'] = {
		spellID = 102359,
		throttle = 2,
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
	['mightyBash'] = {
		spellID = 5211,
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
	['rebirth'] = {
		spellID = 20484,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_CAST_START'] = {
				messages = {"Casting [LINK] on [TARGET]!",},
				tags = {TARGET = true,},
			},
			['SPELL_RESURRECT'] = {
				messages = {"Resurrected [TARGET]!",},
				tags = {TARGET = true,},
			},
		},
	},
	['removeCorruption'] = {
		spellID = 2782,
		throttle = 0.25,
		additionalSpellIDs = {
			[88423] = true, -- Nature's Cure
		},
		configDisplay = {
			isDefault = true,
			defaultName = RSA.GetSpellInfo(2782) .. ' | ' .. RSA.GetSpellInfo(88423),
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
	['revitalize'] = {
		spellID = 212040,
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
	['revive'] = {
		spellID = 50769,
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
	['skullBash'] = {
		spellID = 93985,
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
	['solarBeam'] = {
		spellID = 97547,
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
					EXTRA = true,
				},
			},
		},
	},
	['soothe'] = {
		spellID = 2908,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_DISPEL'] = {
				messages = {"Soothed [TARGET]!",},
				tags = {
					TARGET = true,
					EXTRA = true,
				},
			},
		},
	},
	--TODO: Check IDs.
	['stampedingRoar'] = {
		spellID = 106898,
		additionalSpellIDs = {
			[77761] = true,
			[77764] = true,
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
				dest = {'player'},
				messages = {"[LINK] finished!",},
			},
		},
	},
	['survivalInstincts'] = {
		spellID = 61336,
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
	['tranquility'] = {
		spellID = 740,
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
	['ursolsVortex'] = {
		spellID = 102793,
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
}

local wrath = {
	['barkskin'] = {
		spellID = 22812,
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
	['cyclone'] = {
		spellID = 33786,
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
	['demoralizingRoar'] = {
		spellID = 99,
		additionalSpellIDs = {
			[1735] = true, -- Rank 2
			[9490] = true, -- Rank 3
			[9747] = true, -- Rank 4
			[9898] = true, -- Rank 5
			[26998] = true, -- Rank 6
			[48559] = true, -- Rank 7
			[48560] = true, -- Rank 8
		},
		throttle = 2,
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
	['entanglingRoots'] = {
		spellID = 339,
		additionalSpellIDs = {
			[1062] = true, -- Rank 2
			[5195] = true, -- Rank 3
			[5196] = true, -- Rank 4
			[9852] = true, -- Rank 5
			[9853] = true, -- Rank 6
			[26989] = true, -- Rank 7
			[53308] = true, -- Rank 8
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
			--TODO: Test that this event exists for Roots.
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
	['frenziedRegeneration'] = {
		spellID = 22842,
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
	['growl'] = {
		spellID = 6795,
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
	['hibernate'] = {
		spellID = 2637,
		additionalSpellIDs = {
			[18657] = true, -- Rank 2
			[18658] = true, -- Rank 3
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
	['innervate'] = {
		spellID = 29166,
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
	['rebirth'] = {
		spellID = 20484,
		additionalSpellIDs = {
			[20739] = true, -- Rank 2
			[20742] = true, -- Rank 3
			[20747] = true, -- Rank 4
			[20748] = true, -- Rank 5
			[26994] = true, -- Rank 6
			[48477] = true, -- Rank 7
		},
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_CAST_START'] = {
				messages = {"Casting [LINK] on [TARGET]!",},
				tags = {TARGET = true,},
			},
			['SPELL_RESURRECT'] = {
				messages = {"Resurrected [TARGET]!",},
				tags = {TARGET = true,},
			},
		},
	},
	['removeCurse'] = {
		spellID = 2782,
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
	['revive'] = {
		spellID = 50769,
		additionalSpellIDs = {
			[50768] = true, -- Rank 2
			[50767] = true, -- Rank 3
			[50766] = true, -- Rank 4
			[50765] = true, -- Rank 5
			[50764] = true, -- Rank 6
			[50763] = true, -- Rank 7
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
	['sootheAnimal'] = {
		spellID = 2908,
		additionalSpellIDs = {
			[8955] = true, -- Rank 2
			[9901] = true, -- Rank 3
			[26995] = true, -- Rank 4
		},
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_DISPEL'] = {
				messages = {"Soothed [TARGET]!",},
				tags = {
					TARGET = true,
					EXTRA = true,
				},
			},
		},
	},
	['survivalInstincts'] = {
		spellID = 61336,
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
	['tranquility'] = {
		spellID = 740,
		additionalSpellIDs = {
			[8918] = true, -- Rank 2
			[9862] = true, -- Rank 3
			[9863] = true, -- Rank 4
			[26983] = true, -- Rank 5
			[48446] = true, -- Rank 6
			[48447] = true, -- Rank 7
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
}

if RSA.IsRetail() then
	RSA.monitorData.druid, RSA.configData.druid = RSA.PrepareDataTables(defaults)
elseif RSA.IsWrath() then
	RSA.monitorData.druid, RSA.configData.druid = RSA.PrepareDataTables(wrath)
end