local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

local defaults = {
	['aspectOfTheTurtle'] = {
		spellID = 186265,
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
	['bindingShot'] = {
		spellID = 109248,
		throttle = 0.5,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_AURA_APPLIED'] = {
				uniqueSpellID = 117526,
				messages = {"[LINK] activated!",},
			},
			['SPELL_AURA_REMOVED'] = {
				uniqueSpellID = 117526,
				messages = {"[LINK] finished!",},
			},
		},
	},
	['camouflage'] = {
		spellID = 199483,
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
	['concussiveShot'] = {
		spellID = 5116,
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
	['counterShot'] = {
		spellID = 147362,
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
	--TODO: Check IDs
	['freezingTrap'] = {
		spellID = 187650,
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
	--TODO: Check IDs.
	['intimidation'] = {
		spellID = 19577,
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
	--TODO: Support custom code to tally amount of threat transferred.
	['misdirection'] = {
		spellID = 34477,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_AURA_APPLIED'] = {
				tracker = 2,
				messages = {"[LINK] cast on [TARGET]!",},
				tags = {TARGET = true,},
			},
			['SPELL_AURA_REMOVED'] = {
				uniqueSpellID = 197336,
				tracker = 1,
				messages = {"[LINK] on [TARGET] finished and transferred [AMOUNT] threat!",},
				tags = {
					TARGET = true,
					AMOUNT = true,
				},
			},
		},
	},
	['muzzle'] = {
		spellID = 187707,
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
	['primalRage'] = {
		spellID = 264667,
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
	['roarOfSacrifice'] = {
		spellID = 53480,
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
	['spiritMend'] = {
		spellID = 90361,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_HEAL'] = {
				messages = {"[LINK] healed [TARGET] for [AMOUNT]!",},
				tags = {
					TARGET = true,
					AMOUNT = true,
				},
			},
		},
	},
	['tranquilizingShot'] = {
		spellID = 19801,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_DISPEL'] = {
				messages = {"Dispelled [TARGET]'s! [EXTRALINK]",},
				tags = {
					TARGET = true,
					EXTRA = true,
				},
			},
		},
	},
}

local wrath = {
	['concussiveShot'] = {
		spellID = 5116,
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
	['freezingTrap'] = {
		spellID = 1499,
		additionalSpellIDs = {
			[14310] = true, -- Rank 2
			[14311] = true, -- Rank 3
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
	['intimidation'] = {
		spellID = 19577,
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
	['misdirection'] = {
		spellID = 34477,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_AURA_APPLIED'] = {
				tracker = 2,
				messages = {"[LINK] cast on [TARGET]!",},
				tags = {TARGET = true,},
			},
			['SPELL_AURA_REMOVED'] = {
				uniqueSpellID = 197336,
				tracker = 1,
				messages = {"[LINK] on [TARGET] finished and transferred [AMOUNT] threat!",},
				tags = {
					TARGET = true,
					AMOUNT = true,
				},
			},
		},
	},
	['roarOfSacrifice'] = {
		spellID = 53480,
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
	['silencingShot'] = {
		spellID = 34490,
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
	['spiritMend'] = {
		spellID = 42025,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_HEAL'] = {
				messages = {"[LINK] healed [TARGET] for [AMOUNT]!",},
				tags = {
					TARGET = true,
					AMOUNT = true,
				},
			},
		},
	},
	['tranquilizingShot'] = {
		spellID = 19801,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_DISPEL'] = {
				messages = {"Dispelled [TARGET]'s! [EXTRALINK]",},
				tags = {
					TARGET = true,
					EXTRA = true,
				},
			},
		},
	},
}

if RSA.IsRetail() then
	RSA.monitorData.hunter, RSA.configData.hunter = RSA.PrepareDataTables(defaults)
elseif RSA.IsWrath() then
	RSA.monitorData.hunter, RSA.configData.hunter = RSA.PrepareDataTables(wrath)
end