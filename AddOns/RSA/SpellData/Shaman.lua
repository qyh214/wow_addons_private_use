local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

local defaults = {
	['ancestralGuidance'] = {
		spellID = 108281,
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
	['ancestralProtectionTotem'] = {
		spellID = 207399,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] placed!",},
			},
			-- TODO save GUID of SPELL_SUMMON, and match this to that.
			--['SPELL_CAST_SUCCESS'] = {
			--	messages = {"[LINK] resurrected [TARGET]!",},
			--},
			['UNIT_DIED'] = {
				messages = {"[LINK] finished!",},
			},
		},
	},
	['ancestralSpirit'] = {
		spellID = 2008,
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
	['ancestralVision'] = {
		spellID = 212048,
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
	['ascendence'] = {
		spellID = 114050, -- Elemental
		additionalSpellIDs = {
			[114051] = true, -- Enhancement
			[114052] = true, -- Restoration
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
	['astralShift'] = {
		spellID = 108271,
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
	['bloodlust'] = {
		spellID = 2825, -- Bloodlust
		additionalSpellIDs = {
			[32182] = true, -- Heroism
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
	['capacitorTotem'] = {
		spellID = 192058,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] placed!",},
			},
			-- TODO save GUID of SPELL_SUMMON, and match this to that.
			--['SPELL_CAST_SUCCESS'] = {
			--	uniqueSpellID = 118905,
			--	messages = {"[LINK] activated!",},
			--},
			['SPELL_AURA_REMOVED'] = {
			--	uniqueSpellID = 118905,
				messages = {"[LINK] finished!",},
			},
		},
	},
	['cleanseSpirit'] = {
		spellID = 51886,
		throttle = 0.25,
		additionalSpellIDs = {
			[77130] = true, -- Purify Spirit
		},
		configDisplay = {
			isDefault = true,
			defaultName = RSA.GetSpellInfo(51886) .. ' | ' .. RSA.GetSpellInfo(77130),
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
	['cloudburstTotem'] = {
		spellID = 157153,
		throttle = 0.25,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] placed!",},
			},
			-- TODO save GUID of SPELL_SUMMON, and match this to that.
			--['SPELL_CAST_SUCCESS'] = {
			--	uniqueSpellID = 201764,
			--	messages = {"[LINK] activated!",},
			--},
			['SPELL_HEAL'] = {
				uniqueSpellID = 157503,
				messages = {"[LINK] healed for [AMOUNT]!",},
				tags = {AMOUNT = true,},
			},
		},
	},
	['earthElemental'] = {
		spellID = 198103,
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
	['earthenWallTotem'] = {
		spellID = 198838,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] placed!",},
			},
			-- TODO save GUID of SPELL_SUMMON, and match this to that.
			['UNIT_DIED'] = {
				messages = {"[LINK] finished!",},
			},
		},
	},
	['feralSpirit'] = {
		spellID = 51533,
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
	['fireElemental'] = {
		spellID = 198067,
		additionalSpellIDs = {
			[118291] = true,
			[188592] = true,
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
--[[
Earthgrab Totem
-----------------------Feral Spirit
-----------------------Fire Elemental
Grounding Totem
Healing Tide Totem
-----------------------Reincarnation
Spirit Link Totem
-----------------------Thunderstorm
Tremor Totem
Wind Rush Totem
]]--

	['hex'] = {
		spellID = 51514, -- Frog (Default)
		additionalSpellIDs = {
			[211004] = true, -- Spider
			[210873] = true, -- Compy
			[211010] = true, -- Snake
			[211015] = true, -- Cockroach
			[277784] = true, -- Wicker Mongrel
			[309328] = true, -- Living Honey
			[277778] = true, -- Zandalari Tendonripper
			[269352] = true, -- Skeletal Hatchling
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
	['purge'] = {
		spellID = 370,
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
	['reincarnation'] = {
		spellID = 21169,
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"Resurrected myself with [LINK]!",},
			},
		},
	},
	['thunderstorm'] = {
		spellID = 51490,
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
	['windShear'] = {
		spellID = 57994,
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
}

local wrath = {
	['ancestralSpirit'] = {
		spellID = 2008,
		additionalSpellIDs = {
			[20609] = true, -- Rank 2
			[20610] = true, -- Rank 3
			[20776] = true, -- Rank 4
			[20777] = true, -- Rank 5
			[25590] = true, -- Rank 6
			[49277] = true, -- Rank 7
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
	['astralShift'] = {
		spellID = 51474,
		additionalSpellIDs = {
			[51478] = true, -- Rank 2
			[51479] = true, -- Rank 3
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
	['bloodlust'] = {
		spellID = 2825, -- Bloodlust
		additionalSpellIDs = {
			[32182] = true, -- Heroism
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
	['cleanseSpirit'] = {
		spellID = 51886,
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
	['cureToxins'] = {
		spellID = 526,
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
	['earthElemental'] = {
		spellID = 2062,
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
	['stoneSkinTotem'] = {
		spellID = 8071,
		additionalSpellIDs = {
			[8154] = true, -- Rank 2
			[8155] = true, -- Rank 3
			[10406] = true, -- Rank 4
			[10407] = true, -- Rank 5
			[10408] = true, -- Rank 6
			[25508] = true, -- Rank 7
			[25509] = true, -- Rank 8
			[58751] = true, -- Rank 9
			[58753] = true, -- Rank 10
		},
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"[LINK] placed!",},
			},
			-- TODO save GUID of SPELL_SUMMON, and match this to that.
			['UNIT_DIED'] = {
				messages = {"[LINK] finished!",},
			},
		},
	},
	['feralSpirit'] = {
		spellID = 51533,
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
	['fireElemental'] = {
		spellID = 2894,
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
	['hex'] = {
		spellID = 51514, -- Frog (Default)
		additionalSpellIDs = {
			[211004] = true, -- Spider
			[210873] = true, -- Compy
			[211010] = true, -- Snake
			[211015] = true, -- Cockroach
			[277784] = true, -- Wicker Mongrel
			[309328] = true, -- Living Honey
			[277778] = true, -- Zandalari Tendonripper
			[269352] = true, -- Skeletal Hatchling
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
	['purge'] = {
		spellID = 370,
		additionalSpellIDs = {
			[8012] = true, -- Rank 2
		},
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
	['reincarnation'] = {
		spellID = 20608,
		additionalSpellIDs = {
			[21169] = true, -- Spell that actually activates
		},
		configDisplay = {
			isDefault = true,
			disabledChannels = {whisper = true},
		},
		events = {
			['SPELL_CAST_SUCCESS'] = {
				messages = {"Resurrected myself with [LINK]!",},
			},
		},
	},
	['thunderstorm'] = {
		spellID = 51490,
		additionalSpellIDs = {
			[59156] = true, -- Rank 2
			[59158] = true, -- Rank 3
			[59159] = true, -- Rank 4
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
	['windShear'] = {
		spellID = 57994,
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
}

if RSA.IsRetail() then
	RSA.monitorData.shaman, RSA.configData.shaman = RSA.PrepareDataTables(defaults)
elseif RSA.IsWrath() then
	RSA.monitorData.shaman, RSA.configData.shaman = RSA.PrepareDataTables(wrath)
end