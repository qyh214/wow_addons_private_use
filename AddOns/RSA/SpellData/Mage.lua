local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

if RSA.IsRetail() then
	local defaults = {
		['cauterize'] = {
			spellID = 87023,
			throttle = 5,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_HEAL'] = {
					messages = {"[LINK] saved my life, please heal me!",},
				},
				['SPELL_AURA_REMOVED'] = {
					tracker = 1,
					messages = {"[LINK] finished!",},
				},
			},
		},
		['conjureRefreshment'] = {
			spellID = 190336,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['counterspell'] = {
			spellID = 2139,
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
		['iceBlock'] = {
			spellID = 45438,
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
		['polymorph'] = {
			spellID = 118,
			additionalSpellIDs = {
				[161372] = true, --Peacock
				[28272] = true, -- Pig
				[61780] = true, -- Turkey
				[161355] = true, -- Penguin
				[61305] = true, -- Black Cat
				[28271] = true, -- Turtle
				[161353] = true, -- Polar Bear Cub
				[277792] = true, -- Bumblebee
				[61721] = true, -- Rabbit
				[161354] = true, -- Monkey
				[126819] = true, -- Porcupine
				[277787] = true, -- Direhorn
				[321395] = true, -- Mawrat
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
		['portal'] = {
			spellID = 343140, -- Generic Portal spell.
			additionalSpellIDs = {
				[10059] = true, -- Stormwind
				[11416] = true, -- Ironforge
				[11417] = true, -- Orgrimmar
				[11418] = true, -- Undercity
				[11419] = true, -- Darnassus
				[11420] = true, -- Thunder Bluff
				[32266] = true, -- Exodar
				[32267] = true, -- Silvermoon
				[33691] = true, -- Shattrath
				[35717] = true, -- Shattrath
				[49360] = true, -- Theramore
				[49361] = true, -- Stonard
				[53142] = true, -- Dalaran: Northrend
				[88345] = true, -- Tol Barad (Alliance)
				[88346] = true, -- Tol Barad (Horde)
				[120146] = true, -- Ancient Portal: Dalaran
				[132620] = true, -- Vale of Eternal Blossoms (Alliance)
				[132626] = true, -- Vale of Eternal Blossoms (Horde)
				[176244] = true, -- Warspear
				[176246] = true, -- Stormshield
				[224871] = true, -- Dalaran - Broken Isles
				[281400] = true, -- Boralus
				[281402] = true, -- Dazar'alor
				[344597] = true, -- Oribos
				[395289] = true, -- Valdrakken
				[446534] = true, -- Dornogal
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['removeCurse'] = {
			spellID = 475,
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
		['ringOfFrost'] = {
			spellID = 113724,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
				['SPELL_SUMMON'] = {
					messages = {'Conjured a [LINK]!',},
				},
			},
		},
		['slowFall'] = {
			spellID = 130,
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
		['spellsteal'] = {
			spellID = 30449,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_STOLEN'] = {
					messages = {"Stole [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['teleport'] = {
			spellID = 343127, -- Generic Teleport spell.
			additionalSpellIDs = {
				[3561] = true, -- Stormwind
				[3562] = true, -- Ironforge
				[3563] = true, -- Undercity
				[3565] = true, -- Darnassus
				[3566] = true, -- Thunder Bluff
				[3567] = true, -- Orgrimmar
				[32271] = true, -- Exodar
				[32272] = true, -- Silvermoon
				[33690] = true, -- Shattrath (Alliance)
				[35715] = true, -- Shattrath (Horde)
				[49358] = true, -- Stonard
				[49359] = true, -- Theramore
				[53140] = true, -- Dalaran: Northrend
				[88342] = true, -- Tol Barad (Alliance)
				[88344] = true, -- Tol Barad (Horde)
				[120145] = true, -- Ancient Teleport: Dalaran
				[132621] = true, -- Vale of Eternal Blossoms (Alliance)
				[132627] = true, -- Vale of Eternal Blossoms (Horde)
				[176242] = true, -- Warspear
				[176248] = true, -- Stormshield
				[193759] = false, -- Hall of the Guardian
				[224869] = true, -- Dalaran - Broken Isles
				[281403] = true, -- Boralus
				[281404] = true, -- Dazar'alor
				[344587] = true, -- Oribos
				[395277] = true, -- Valdrakken
				[446540] = true, -- Dornogal
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['timeWarp'] = {
			spellID = 80353,
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
	}

	RSA.monitorData.mage, RSA.configData.mage = RSA.PrepareDataTables(defaults)
end

if RSA.IsWrath() then
	local wrath = {
		['conjureRefreshment'] = {
			spellID = 42955,
			additionalSpellIDs = {
				[42956] = true, -- Rank 2
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['counterspell'] = {
			spellID = 2139,
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
		['iceBlock'] = {
			spellID = 45438,
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
		['polymorph'] = {
			spellID = 118,
			additionalSpellIDs = {
				[161372] = true, --Peacock
				[28272] = true, -- Pig
				[61780] = true, -- Turkey
				[161355] = true, -- Penguin
				[61305] = true, -- Black Cat
				[28271] = true, -- Turtle
				[161353] = true, -- Polar Bear Cub
				[277792] = true, -- Bumblebee
				[61721] = true, -- Rabbit
				[161354] = true, -- Monkey
				[126819] = true, -- Porcupine
				[277787] = true, -- Direhorn
				[321395] = true, -- Mawrat
				[12824] = true, -- Rank 2
				[12825] = true, -- Rank 3
				[12826] = true, -- Rank 4
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
		['portal'] = {
			spellID = 10059, -- Portal: Stormwind (Generic Portal spell doesn't exist in classic)
			additionalSpellIDs = {
				[10059] = true, -- Stormwind
				[11416] = true, -- Ironforge
				[11417] = true, -- Orgrimmar
				[11418] = true, -- Undercity
				[11419] = true, -- Darnassus
				[11420] = true, -- Thunder Bluff
				[32266] = true, -- Exodar
				[32267] = true, -- Silvermoon
				[33691] = true, -- Shattrath
				[35717] = true, -- Shattrath
				[49360] = true, -- Theramore
				[49361] = true, -- Stonard
				[53142] = true, -- Dalaran: Northrend
				[88345] = true, -- Tol Barad (Alliance)
				[88346] = true, -- Tol Barad (Horde)
				[120146] = true, -- Ancient Portal: Dalaran
				[132620] = true, -- Vale of Eternal Blossoms (Alliance)
				[132626] = true, -- Vale of Eternal Blossoms (Horde)
				[176244] = true, -- Warspear
				[176246] = true, -- Stormshield
				[224871] = true, -- Dalaran - Broken Isles
				[281400] = true, -- Boralus
				[281402] = true, -- Dazar'alor
				[344597] = true, -- Oribos
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['removeCurse'] = {
			spellID = 475,
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
		['ritualOfRefreshment'] = {
			spellID = 43987,
			additionalSpellIDs = {
				[58659] = true, -- Rank 2
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['slowFall'] = {
			spellID = 130,
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
		['spellsteal'] = {
			spellID = 30449,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_STOLEN'] = {
					messages = {"Stole [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['teleport'] = {
			spellID = 3561, -- Teleport: Stormwind (Generic Teleport spell doesn't exist in classic).
			additionalSpellIDs = {
				[3561] = true, -- Stormwind
				[3562] = true, -- Ironforge
				[3563] = true, -- Undercity
				[3565] = true, -- Darnassus
				[3566] = true, -- Thunder Bluff
				[3567] = true, -- Orgrimmar
				[32271] = true, -- Exodar
				[32272] = true, -- Silvermoon
				[33690] = true, -- Shattrath (Alliance)
				[35715] = true, -- Shattrath (Horde)
				[49358] = true, -- Stonard
				[49359] = true, -- Theramore
				[53140] = true, -- Dalaran: Northrend
				[88342] = true, -- Tol Barad (Alliance)
				[88344] = true, -- Tol Barad (Horde)
				[120145] = true, -- Ancient Teleport: Dalaran
				[132621] = true, -- Vale of Eternal Blossoms (Alliance)
				[132627] = true, -- Vale of Eternal Blossoms (Horde)
				[176242] = true, -- Warspear
				[176248] = true, -- Stormshield
				[193759] = false, -- Hall of the Guardian
				[224869] = true, -- Dalaran - Broken Isles
				[281403] = true, -- Boralus
				[281404] = true, -- Dazar'alor
				[344587] = true, -- Oribos
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
	}

	RSA.monitorData.mage, RSA.configData.mage = RSA.PrepareDataTables(wrath)
end

if RSA.IsCata() then
	local cata = {
		['conjureRefreshment'] = {
			spellID = 42955,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['counterspell'] = {
			spellID = 2139,
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
		['iceBlock'] = {
			spellID = 45438,
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
		['polymorph'] = {
			spellID = 118,
			additionalSpellIDs = {
				[161372] = true, --Peacock
				[28272] = true, -- Pig
				[61780] = true, -- Turkey
				[161355] = true, -- Penguin
				[61305] = true, -- Black Cat
				[28271] = true, -- Turtle
				[161353] = true, -- Polar Bear Cub
				[277792] = true, -- Bumblebee
				[61721] = true, -- Rabbit
				[161354] = true, -- Monkey
				[126819] = true, -- Porcupine
				[277787] = true, -- Direhorn
				[321395] = true, -- Mawrat
				[12824] = true, -- Rank 2
				[12825] = true, -- Rank 3
				[12826] = true, -- Rank 4
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
		['portal'] = {
			spellID = 10059, -- Portal: Stormwind (Generic Portal spell doesn't exist in classic)
			additionalSpellIDs = {
				[10059] = true, -- Stormwind
				[11416] = true, -- Ironforge
				[11417] = true, -- Orgrimmar
				[11418] = true, -- Undercity
				[11419] = true, -- Darnassus
				[11420] = true, -- Thunder Bluff
				[32266] = true, -- Exodar
				[32267] = true, -- Silvermoon
				[33691] = true, -- Shattrath
				[35717] = true, -- Shattrath
				[49360] = true, -- Theramore
				[49361] = true, -- Stonard
				[53142] = true, -- Dalaran: Northrend
				[88345] = true, -- Tol Barad (Alliance)
				[88346] = true, -- Tol Barad (Horde)
				[120146] = true, -- Ancient Portal: Dalaran
				[132620] = true, -- Vale of Eternal Blossoms (Alliance)
				[132626] = true, -- Vale of Eternal Blossoms (Horde)
				[176244] = true, -- Warspear
				[176246] = true, -- Stormshield
				[224871] = true, -- Dalaran - Broken Isles
				[281400] = true, -- Boralus
				[281402] = true, -- Dazar'alor
				[344597] = true, -- Oribos
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['removeCurse'] = {
			spellID = 475,
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
		['ritualOfRefreshment'] = {
			spellID = 43987,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
		['slowFall'] = {
			spellID = 130,
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
		['spellsteal'] = {
			spellID = 30449,
			throttle = 0.25,
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_STOLEN'] = {
					messages = {"Stole [TARGET]'s [EXTRALINK]!",},
					tags = {
						TARGET = true,
						EXTRA = true,
					},
				},
			},
		},
		['teleport'] = {
			spellID = 3561, -- Teleport: Stormwind (Generic Teleport spell doesn't exist in classic).
			additionalSpellIDs = {
				[3561] = true, -- Stormwind
				[3562] = true, -- Ironforge
				[3563] = true, -- Undercity
				[3565] = true, -- Darnassus
				[3566] = true, -- Thunder Bluff
				[3567] = true, -- Orgrimmar
				[32271] = true, -- Exodar
				[32272] = true, -- Silvermoon
				[33690] = true, -- Shattrath (Alliance)
				[35715] = true, -- Shattrath (Horde)
				[49358] = true, -- Stonard
				[49359] = true, -- Theramore
				[53140] = true, -- Dalaran: Northrend
				[88342] = true, -- Tol Barad (Alliance)
				[88344] = true, -- Tol Barad (Horde)
				[120145] = true, -- Ancient Teleport: Dalaran
				[132621] = true, -- Vale of Eternal Blossoms (Alliance)
				[132627] = true, -- Vale of Eternal Blossoms (Horde)
				[176242] = true, -- Warspear
				[176248] = true, -- Stormshield
				[193759] = false, -- Hall of the Guardian
				[224869] = true, -- Dalaran - Broken Isles
				[281403] = true, -- Boralus
				[281404] = true, -- Dazar'alor
				[344587] = true, -- Oribos
			},
			configDisplay = {
				isDefault = true,
				disabledChannels = {whisper = true},
			},
			events = {
				['SPELL_CAST_START'] = {
					messages = {'Casting [LINK]!',},
				},
			},
		},
	}

	RSA.monitorData.mage, RSA.configData.mage = RSA.PrepareDataTables(cata)
end