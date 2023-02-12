local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

local defaults = {
	['cauterizingFlame'] = {
		spellID = 374251,
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
	['dreamFlight'] = {
		spellID = 359816,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] activated!",},
			},
		},
	},
	['dreamBreath'] = {
		spellID = 355936,
		throttle = 0.5,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_HEAL'] = {
				messages = {"[LINK] activated!",},
			},
		},
	},
	['expunge'] = {
		spellID = 365585,
		additionalSpellIDs = {
			[360823] = true, -- Naturalize
		},
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
	['furyOfTheAspects'] = { -- (Bloodlust)
		spellID = 390386,
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
	['landslide'] = {
		spellID = 358385,
		throttle = 0.5,
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
	['massReturn'] = {
		spellID = 361178,
		configDisplay = {
			isDefault = true,
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
	['obsidianScales'] = {
		spellID = 363916,
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
	['oppressingRoar'] = {
		spellID = 372048,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] activated!",},
			},
			['SPELL_DISPEL'] = {
				messages = {"Removed [TARGET]'s Enrage!",},
				tags = {
					TARGET = true,
					EXTRA = true,
				},
			},
		},
	},
	['quell'] = {
		spellID = 351338,
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
	['renewingBlaze'] = {
		spellID = 374348,
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
	['rescue'] = {
		spellID = 370665,
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
	['return'] = {
		spellID = 361227,
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
	['rewind'] = {
		spellID = 363534,
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
	['sourceOfMagic'] = {
		spellID = 369459,
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
	['timeDilation'] = {
		spellID = 357170,
		configDisplay = {
			isDefault = true,
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] cast on [TARGET]!",},
				tags = {TARGET = true,},
			},
			--[[['SPELL_AURA_REMOVED'] = {
				messages = {"[LINK] on [TARGET] finished!",},
				tags = {TARGET = true,},
			},]]--
		},
	},

}

if RSA.IsRetail() then
	RSA.monitorData.evoker, RSA.configData.evoker = RSA.PrepareDataTables(defaults)
end