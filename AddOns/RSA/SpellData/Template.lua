-- Example
local fullTemplate = {
	['profileName'] = {
		spellID = 31850,
		throttle = 2.25, -- Prevent any subsequent announcements from this profile for this amount of time after it has already caused an announcement. A spell can belong to multiple profiles, this just limits announcemenets tied to this profile.
		additionalSpellIDs = {[1044] = true,}, -- key, value list of any alternate variants of this spell, like if you want to use one announcement for all mage portal spells.
		comm = false, -- Only required if you want to use the Addon Comms to determine if you are allowed to announce this spell.
		configDisplay = {
			isDefault = true, -- Only for defaultly included spells so that the config GUI can know whether to allow removal or not.
			messageAreas = {},
			disabledChannels = {whisper = true},
			customDesc = 'My custom description',
			customName = 'My custom spell name',
		},
		environments = { -- Entire environment table supplied with following values if not manually entered.
			useGlobal = true, -- This spell will use the global envrionment settings to determine where it can announce, this overrides the other values in this section.
			alwaysWhisper = false, -- Allows whispers to always be sent.
			enableIn = {
				arenas = false,
				bgs = false,
				warModeWorld = false, -- Enable in War Mode world zones.
				nonWarWorld = false, -- Enable in world zones without war mode enabled.
				dungeons = false,
				raids = false,
				lfg = false,
				lfr = false,
				scenarios = false,
			},
			groupToggles = { -- When true, only announce to these channels if you are in a group
				emote = true,
				say = true,
				yell = true,
				whisper = true,
			},
			combatState = {
				inCombat = true, -- Allow announcements while in Combat
				noCombat = false, -- Allow announcements while not in Combat
			},
		},
		events = {
			SPELL_HEAL = { -- Combat log event. RSA also has various "fake" events to help with certain spells where a real event doesn't easily get the job done.
				uniqueSpellID = 66235, -- Ardent Defender uses a different spell ID when the heal effect triggers.
				tracker = 1, -- Tells the monitor to not announce any further messages for this spell, so that we don't also announce the finishing message.
				tags = { -- The types of tags this particular event can replace. Each is implied false if not supplied.
					TARGET = true,
					AMOUNT = true,
				},
				messages = {
					"[LINK] saved my life and healed me for [AMOUNT] hp!",
				},
				channels = {
					say = true,
					yell = true,
					emote = true,
					personal = true, -- Whatever LibSink is set to.
					whisper = true,
					party = true,
					raid = true,
					instance = true,
					smartGroup = true, -- Smart Group only announces to one of the group channels. If you want to announce in both Party & Raid, or only one of those two, use party or raid instead.
					-- These are all toggleable in config GUI, setting true only means that they are turned on by default. If none listed means this event doesn't announce by default.
				},
			},
			SPELL_CAST_SUCCESS = {
				tracker = 2, -- Tells the monitor to start tracking this spell so that we can prevent both the Heal and Finish message from playing if the heal triggers.
				tags = {
					-- No additional tags needed for this event.
				},
				messages = {
					"[LINK] Activated!",
					"AD STARTED",
				},
				channels = {
					emote = true,
				},
			},
			SPELL_AURA_REMOVED = {
				tracker = 1,
				tags = {},
				messages = {"[LINK] faded!",},
				channels = {emote = true,},
			},
		},
	},
}

-- Minimum data for a valid spell profile.
local minimalTemplate = {
	['profileName'] = {
		spellID = 31850,
		events = {
			SPELL_CAST_SUCCESS = {},
			SPELL_AURA_REMOVED = {},
		},
	},
}
