local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

if RSA.IsRetail() then
	local defaults = {
		['ancestralCall'] = {
			spellID = 274738, -- Base
			additionalSpellIDs = {
				[274741] = true, -- Mastery
				[274742] = true, -- Versatility
				[274740] = true, -- Haste
				[274739] = true, -- Crit
			},
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
		['arcanePulse'] = {
			spellID = 260364,
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
		['arcaneTorrent'] = {
			spellID = 28730, -- Warlock, Mage
			throttle = 0.25,
			additionalSpellIDs = {
				[25046] = true, -- Rogue
				[50613] = true, -- Death Knight
				[69179] = true, -- Warrior
				[80483] = true, -- Hunter
				[129597] = true, -- Monk
				[155145] = true, -- Paladin
				[202719] = true, -- Demon Hunter
				[232633] = true, -- Priest
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_DISPEL'] = {
					messages = {"Purged [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['bagOfTricks'] = {
			spellID = 312411,
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
		['berserking'] = {
			spellID = 26297,
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
		['bloodFury'] = {
			spellID = 33702,
			additionalSpellIDs = {
				[20572] = true, -- Attack Power
				[33697] = true, -- Intellect
				[33702] = true, -- Both
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
		['bullRush'] = {
			spellID = 255654,
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
		['darkFlight'] = {
			spellID = 68992,
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
		['escapeArtist'] = {
			spellID = 20589,
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
		['fireblood'] = {
			spellID = 265221,
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
		['giftOfTheNaaru'] = {
			spellID = 28880, -- Warrior
			additionalSpellIDs = {
				[59542] = true, -- Paladin
				[59543] = true, -- Hunter
				[59544] = true, -- Priest
				[59545] = true, -- Death Knight
				[59547] = true, -- Shaman
				[59548] = true, -- Mage
				[121093] = true, -- Monk
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
		['haymaker'] = {
			spellID = 287712,
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
		['hyperOrganicLightOriginator'] = {
			spellID = 312924,
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
		['regeneratin'] = {
			spellID = 291944,
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
		['rocketJump'] = {
			spellID = 69070,
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
		['shadowmeld'] = {
			spellID = 58984,
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
		['warStomp'] = {
			spellID = 20549,
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['willOfTheForsaken'] = {
			spellID = 7744,
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
		['willToSurvive'] = {
			spellID = 59752,
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
	}

	RSA.monitorData.racials, RSA.configData.racials = RSA.PrepareDataTables(defaults)
end

if RSA.IsWrath() then
	local wrath = {
		['arcaneTorrent'] = {
			spellID = 25046, -- Energy
			throttle = 0.25,
			additionalSpellIDs = {
				[25046] = true, -- Rogue
				[28730] = true, -- Mana
				[50613] = true, -- Runic Power
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_DISPEL'] = {
					messages = {"Purged [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['berserking'] = {
			spellID = 26297,
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
		['bloodFury'] = {
			spellID = 33702,
			additionalSpellIDs = {
				[20572] = true, -- Attack Power
				[33697] = true, -- Intellect
				[33702] = true, -- Both
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
		['escapeArtist'] = {
			spellID = 20589,
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
		['giftOfTheNaaru'] = {
			spellID = 28880, -- Warrior
			additionalSpellIDs = {
				[59542] = true, -- Paladin
				[59543] = true, -- Hunter
				[59544] = true, -- Priest
				[59545] = true, -- Death Knight
				[59547] = true, -- Shaman
				[59548] = true, -- Mage
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
		['shadowmeld'] = {
			spellID = 58984,
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
		['warStomp'] = {
			spellID = 20549,
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['willOfTheForsaken'] = {
			spellID = 7744,
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
		['willToSurvive'] = {
			spellID = 59752,
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
	}

	RSA.monitorData.racials, RSA.configData.racials = RSA.PrepareDataTables(wrath)
end

if RSA.IsCata() then
	local cata = {
		['arcaneTorrent'] = {
			spellID = 25046, -- Energy
			throttle = 0.25,
			additionalSpellIDs = {
				[28730] = true, -- Mana
				[50613] = true, -- Runic Power
				[69179] = true, -- Rage
				[80483] = true, -- Focus
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_SUCCESS'] = {
					messages = {"[LINK] activated!",},
				},
				['SPELL_DISPEL'] = {
					messages = {"Purged [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['berserking'] = {
			spellID = 26297,
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
		['bloodFury'] = {
			spellID = 33702,
			additionalSpellIDs = {
				[20572] = true, -- Attack Power
				[33697] = true, -- Intellect
				[33702] = true, -- Both
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
		['darkFlight'] = {
			spellID = 68992,
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
		['escapeArtist'] = {
			spellID = 20589,
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
		['giftOfTheNaaru'] = {
			spellID = 28880, -- Warrior
			additionalSpellIDs = {
				[59542] = true, -- Paladin
				[59543] = true, -- Hunter
				[59544] = true, -- Priest
				[59545] = true, -- Death Knight
				[59547] = true, -- Shaman
				[59548] = true, -- Mage
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
		['rocketJump'] = {
			spellID = 69070,
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
		['shadowmeld'] = {
			spellID = 58984,
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
		['warStomp'] = {
			spellID = 20549,
			throttle = 0.5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_AURA_APPLIED'] = {
					messages = {"[LINK] activated!",},
				},
			},
		},
		['willOfTheForsaken'] = {
			spellID = 7744,
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
		['willToSurvive'] = {
			spellID = 59752,
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
	}

	RSA.monitorData.racials, RSA.configData.racials = RSA.PrepareDataTables(cata)
end