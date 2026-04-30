---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local inspector = addon.Core.Inspector

addon.Modules.Cooldowns = addon.Modules.Cooldowns or {}

---@class CooldownTalents
local M = {}
addon.Modules.Cooldowns.Talents = M

-- All talent data is keyed by the realm-stripped short name (e.g. "Bob" not "Bob-Realm").
-- UnitNameUnmodified returns the full name for cross-realm players, so strip the realm here
-- before any table lookup to ensure cross-realm players' data is found correctly.
local function ShortName(name)
	return name:match("^([^%-]+)") or name
end

-- playerName -> talentRanks (spellId -> rank purchased)
local unitTalentRanks = {}
-- playerName -> specId (captured when talent string was decoded)
local unitTalentSpecId = {}
-- playerName -> set of active PvP talent IDs ({ [talentId] = true })
local unitPvPTalentIds = {}
-- (classToken .. "_" .. specId) -> merged default talent ranks table
-- The defaults are static constants so this never needs invalidation.
local defaultTalentRanksCache = {}

local db

-- Cooldown/duration-affecting talent modifiers.
-- Structure: [talentSpellId] = { {rank1_mods}, {rank2_mods}, ... }
-- Each mod:  { SpellId = affectedSpellId, Amount = number [, Mult = true] }
-- Additive:  value = value + Amount
-- Mult:      value = value + (baseValue * Amount / 100)   (Amount is typically negative %)

local ClassCooldownModifiers = {
	DEATHKNIGHT = {
		[205727] = { { { SpellId = 48707, Amount = -20 } } },
		[457574] = { { { SpellId = 48707, Amount = 20 } } },
	},
	DEMONHUNTER = {},
	HUNTER = {
		[1258485] = { { { SpellId = 186265, Amount = -30 } } },
		[266921] = {
			{ { SpellId = 186265, Amount = -15 } },
			{ { SpellId = 186265, Amount = -30 } },
		},
	},
	MAGE = {
		[382424] = {
			{ { SpellId = 45438, Amount = -30 }, { SpellId = 414659, Amount = -30 } },
			{ { SpellId = 45438, Amount = -60 }, { SpellId = 414659, Amount = -60 } },
		},
		[1265517] = { { { SpellId = 45438, Amount = -30 }, { SpellId = 414659, Amount = -30 } } },
		[1255166] = { { { SpellId = 342246, Amount = -10 } } }, -- Alter Time CDR: -10s
	},
	PALADIN = {
		-- Blessed Protector: BoP -60s, Spellwarding -60s
		[384909] = { { { SpellId = 1022, Amount = -60 }, { SpellId = 204018, Amount = -60 } } },
		-- Unbreakable Spirit: Bubble / DP (Holy) / Ardent Defender / DP (Prot) each -30% (mult)
		[114154] = {
			{
				{ SpellId = 642, Amount = -30, Mult = true },
				{ SpellId = 498, Amount = -30, Mult = true },
				{ SpellId = 31850, Amount = -30, Mult = true },
				{ SpellId = 403876, Amount = -30, Mult = true },
			},
		},
	},
	MONK = {},
	SHAMAN = {
		[381647] = { { { SpellId = 108271, Amount = -30 } } }, -- Planes Traveler: Astral Shift -30s
		[381867] = { { { SpellId = 204336, Amount = -5 } } },  -- Totemic Surge: Grounding Totem -5s
	},
	WARLOCK = { [386659] = { { { SpellId = 104773, Amount = -45 } } } },
	WARRIOR = {
		-- Honed Reflexes: Die by the Sword -10% (mult)
		[391271] = {
			{
				{ SpellId = 118038, Amount = -10, Mult = true },
			},
		},
	},
}

local SpecCooldownModifiers = {
	-- Vengeance Demon Hunter: Fiery Brand -12s
	[581] = { [389732] = { { { SpellId = 204021, Amount = -12 } } } },

	-- Balance Druid: Whirling Stars -60s / Orbital Strike -60s (mutually exclusive; both reduce Incarnation: Chosen of Elune)
	[102] = {
		[468743] = { { { SpellId = 102560, Amount = -60 } } }, -- Whirling Stars
		[390378] = { { { SpellId = 102560, Amount = -60 } } }, -- Orbital Strike
	},

	-- Feral Druid: Heart of the Lion -60s (Berserk + Incarnation); Ashamane's Guidance -30s (Berserk + Incarnation)
	[103] = {
		[391174] = { { { SpellId = 102543, Amount = -60 }, { SpellId = 106951, Amount = -60 } } }, -- Heart of the Lion -60s
		[391548] = { { { SpellId = 102543, Amount = -30 }, { SpellId = 106951, Amount = -30 } } }, -- Ashamane's Guidance -30s
	},

	-- Restoration Druid: Ironbark -20s
	[105] = { [382552] = { { { SpellId = 102342, Amount = -20 } } } },

	-- Preservation Evoker: Time Dilation -10s
	[1468] = { [376204] = { { { SpellId = 357170, Amount = -10 } } } },

	-- Augmentation Evoker: Obsidian Scales -10% (mult)
	[1473] = { [412713] = { { { SpellId = 363916, Amount = -10, Mult = true } } } },

	-- Marksmanship Hunter: Calling the Shots -30s
	[254] = { [260404] = { { { SpellId = 288613, Amount = -30 } } } },

	-- Survival Hunter: -15s / -30s
	[255] = { [1251790] = {
		{ { SpellId = 1250646, Amount = -15 } },
		{ { SpellId = 1250646, Amount = -30 } },
	} },

	-- Fire Mage: Combustion -60s
	[63] = { [1254194] = { { { SpellId = 190319, Amount = -60 } } } },

	-- Brewmaster Monk
	[268] = {
		[450989] = { { { SpellId = 132578, Amount = -25 } } }, -- Efficient Reduction: Invoke Niuzao -25s
		[388813] = { { { SpellId = 115203, Amount = -120 } } }, -- Expeditious Fortification: Fortifying Brew -120s
	},

	-- Windwalker Monk
	[269] = {
		[388813] = { { { SpellId = 115203, Amount = -30 } } }, -- Expeditious Fortification: Fortifying Brew -30s
		[280197] = { { { SpellId = 1249625, Amount = -20 } } }, -- Spiritual Focus: Zenith -20s
		[450989] = { { { SpellId = 1249625, Amount = -10 } } }, -- Efficient Training: Zenith -10s
	},

	-- Mistweaver Monk: Life Cocoon (Chrysalis); Expeditious Fortification -30s
	[270] = {
		[202424] = { { { SpellId = 116849, Amount = -30 } } }, -- Life Cocoon (Chrysalis)
		[388813] = { { { SpellId = 115203, Amount = -30 } } }, -- Expeditious Fortification -30s
	},

	-- Holy Priest: Seraphic Crescendo -60s
	[257] = {
		[419110] = { { { SpellId = 64843, Amount = -60 } } }, -- Holy Priest: Divine Hymn -60s
		[200209] = { { { SpellId = 47788, Amount = 60, PostBuff = true } } }, -- Guardian Angel: sets post-buff CD to 60s
	},

	-- Protection Paladin
	[66] = {
		-- Blessing of Sacrifice -60s
		[384820] = { { { SpellId = 6940, Amount = -60 } } },
		-- Aegis of Light -15% mult on Bubble/BoP
		[378425] = {
			{
				{ SpellId = 642, Amount = -15, Mult = true },
				{ SpellId = 1022, Amount = -15, Mult = true },
				{ SpellId = 204018, Amount = -15, Mult = true },
			},
		},
		-- Righteous Protector: Avenging Wrath/Sentinel -50% cooldown
		[204074] = {
			{ { SpellId = 31884, Amount = -50, Mult = true }, { SpellId = 389539, Amount = -50, Mult = true } },
		},
	},

	-- Holy Paladin
	[65] = {
		-- Blessing of Sacrifice -15s
		[384820] = { { { SpellId = 6940, Amount = -15 } } },
		-- Call of the Righteous: AW -15s/-30s, AC -7.5s/-15s
		[1241511] = {
			{ { SpellId = 31884, Amount = -15 }, { SpellId = 216331, Amount = -7.5 } },
			{ { SpellId = 31884, Amount = -30 }, { SpellId = 216331, Amount = -15 } },
		},
	},

	-- Retribution Paladin: Blessing of Sacrifice -60s
	[70] = { [384820] = { { { SpellId = 6940, Amount = -60 } } } },

	-- Shadow Priest: Dispersion -30s
	[258] = { [288733] = { { { SpellId = 47585, Amount = -30 } } } },

	-- Protection Warrior: Shield Wall -60s
	[73] = { [397103] = { { { SpellId = 871, Amount = -60 } } } },

	-- Enhancement Shaman: Thorim's Invocation: Ascendance -60s
	[263] = { [384444] = { { { SpellId = 114051, Amount = -60 } } } },

	-- Elemental Shaman: First Ascendant: Ascendance -60s
	[262] = { [462440] = { { { SpellId = 114050, Amount = -60 } } } },

	-- Restoration Shaman: First Ascendant: Ascendance -60s
	[264] = { [462440] = { { { SpellId = 114052, Amount = -60 } } } },
}

-- Charge-affecting talent modifiers.
-- Structure: [talentSpellId] = { {rank1_mods}, {rank2_mods}, ... }
-- Each mod:  { SpellId = affectedSpellId, Amount = number }
local ClassChargeModifiers = {
	EVOKER = {
		[375406] = { { { SpellId = 363916, Amount = 1 } } }, -- Obsidian Scales +1 charge
	},
	HUNTER = {
		[459450] = { { { SpellId = 264735, Amount = 1 } } }, -- Survival of the Fittest +1 charge
	},
	DEMONHUNTER = {
		[1266307] = { { { SpellId = 198589, Amount = 1 } } }, -- Demonic Resilience: Blur +1 charge
	},
}

local SpecChargeModifiers = {
	[102] = { [468743]  = { { { SpellId = 102560, Amount = 1 } } } }, -- Balance Druid: Whirling Stars: Incarnation +1 charge
	[256] = { [373035]  = { { { SpellId = 33206,  Amount = 1 } } } }, -- Disc Priest: Pain Suppression +1 charge
	[66]  = { [1246481] = { { { SpellId = 86659,  Amount = 1 } } } }, -- Prot Paladin: Guardian of Ancient Kings +1 charge
	[73]  = { [397103]  = { { { SpellId = 871,    Amount = 1 } } } }, -- Prot Warrior: Shield Wall +1 charge
	[1468]= { [376204]  = { { { SpellId = 357170, Amount = 1 } } } }, -- Preservation Evoker: Time Dilation +1 charge
	[64]  = { [1244110] = { { { SpellId = 45438,  Amount = 1 }, { SpellId = 414659, Amount = 1 } } } }, -- Frost Mage: Ice Block/Ice Cold +1 charge
}

-- PvP talent cooldown modifiers. No ranks - talent is either active or not.
-- Structure: [pvpTalentId] = { { SpellId = x, Amount = y [, Mult = true] } }
local ClassPvPCooldownModifiers = {}

-- Structure: [specId] = { [pvpTalentId] = { { SpellId = x, Amount = y [, Mult = true] } } }
local SpecPvPCooldownModifiers = {
	-- Brewmaster Monk: Microbrew (Fortifying Brew -50%)
	[268] = { [666] = { { SpellId = 115203, Amount = -50, Mult = true } } },
	-- Blood Death Knight: Spellwarden (Anti-Magic Shell -10s)
	[250] = { [5592] = { { SpellId = 48707, Amount = -10 } } },
	-- Frost Death Knight: Spellwarden (Anti-Magic Shell -10s)
	[251] = { [5591] = { { SpellId = 48707, Amount = -10 } } },
	-- Unholy Death Knight: Spellwarden (Anti-Magic Shell -10s)
	[252] = { [5590] = { { SpellId = 48707, Amount = -10 } } },
	-- Subtlety Rogue: Thief's Bargain (Shadow Blades -20%)
	[261] = { [354825] = { { SpellId = 121471, Amount = -20, Mult = true } } },
	-- Protection Paladin: Sacred Duty (Blessing of Protection & Blessing of Sacrifice -33%)
	[66] = { [92] = { { SpellId = 1022, Amount = -33, Mult = true }, { SpellId = 6940, Amount = -33, Mult = true } } },
}

-- Duration-affecting talent modifiers. Supports additive (seconds) and Mult (% of base).
local ClassDurationModifiers = {
	DEATHKNIGHT = {
		[205727] = { { { SpellId = 48707, Amount = 40, Mult = true } } }, -- Anti-Magic Barrier: AMS +40%
	},
	DRUID = {
		[327993] = { { { SpellId = 22812, Amount = 4 } } }, -- Improved Barkskin: +4s
	},
	HUNTER = {
		[388039] = { { { SpellId = 264735, Amount = 2 } } }, -- Survival of the Fittest: +2s
	},
	PRIEST = {
		[458718] = { { { SpellId = 19236, Amount = 10 } } }, -- Desperate Measures: Desperate Prayer +10s
	},
}

-- Spec-specific duration-affecting talent modifiers. Supports additive (seconds) and Mult (% of base).
-- Structure: [specId] = { [talentSpellId] = { {rank1_mods}, {rank2_mods}, ... } }
local SpecDurationModifiers = {
	-- Protection Paladin: Righteous Protector: Avenging Wrath/Sentinel -40% duration
	[66] = {
		[204074] = {
			{ { SpellId = 31884, Amount = -40, Mult = true }, { SpellId = 389539, Amount = -40, Mult = true } },
		},
	},
	-- Blood Death Knight: Vampiric Blood +2s / +4s
	[250] = {
		[317133] = {
			{ { SpellId = 55233, Amount = 2 } }, -- rank 1
			{ { SpellId = 55233, Amount = 4 } }, -- rank 2
		},
	},
	-- Survival Hunter: Takedown +2s
	[255] = { [1253830] = { { { SpellId = 1250646, Amount = 2 } } } },
	-- Fury Warrior: Invigorating Fury: Enraged Regeneration +3s
	[72] = { [383468] = { { { SpellId = 184364, Amount = 3 } } } },
	-- Vengeance Demon Hunter: Vengeful Beast: Metamorphosis +5s
	[581] = { [1265818] = { { { SpellId = 187827, Amount = 5 } } } },
	-- Enhancement Shaman: Thorim's Invocation: Doomwinds +2s
	[263] = { [384444] = { { { SpellId = 384352, Amount = 2 } } } },
	-- Elemental Shaman: Preeminence: Ascendance +3s
	[262] = { [462443] = { { { SpellId = 114050, Amount = 3 } } } },
	-- Holy Priest: Foreseen Circumstances: Guardian Spirit +2s
	[257] = { [440738] = { { { SpellId = 47788, Amount = 2 } } } },
	-- Shadow Priest: Heightened Alteration is handled by the dedicated 8s variant rule in
	-- Rules.lua BySpec[258] (BuffDuration=8, RequiresTalent=453729).  Adding +2s here on top
	-- of that rule would double-count the bonus and raise expectedDuration to 10s, causing
	-- Desperate Prayer (9.9s) to be incorrectly committed as Dispersion.
	-- Windwalker Monk: Drinking Horn Cover: Zenith +5s
	[269] = { [391370] = { { { SpellId = 1249625, Amount = 5 } } } },
	-- Preservation Evoker: Timeless Magic: Time Dilation +15% / +30%
	[1468] = {
		[376240] = {
			{ { SpellId = 357170, Amount = 15, Mult = true } }, -- rank 1
			{ { SpellId = 357170, Amount = 30, Mult = true } }, -- rank 2
		},
	},
	-- Restoration Druid: Regenerative Heartwood: Ironbark +4s
	[105] = { [392116] = { { { SpellId = 102342, Amount = 4 } } } },
}

-- Assumed talent ranks used when no real talent data is available for a unit.
-- Applied as a fallback so near-universal talents still affect cooldown calculations.
-- Format matches unitTalentRanks: { [spellId] = rank }
local ClassDefaultTalentRanks = {
	DEATHKNIGHT = {
		[205727] = 1, -- Anti-Magic Barrier: AMS -20s cd, +40% duration (nearly universal)
	},
	HUNTER = {
		[1258485] = 1, -- Improved Aspect of the Turtle: Turtle -30s (nearly universal)
		[459450] = 1,  -- Survival of the Fittest: +1 charge (nearly universal)
		[53480] = 1,   -- Roar of Sacrifice (universal)
	},
	MAGE = {
		[382424] = 2, -- Winter's Protection: Ice Block/Ice Cold -60s at rank 2 (nearly universal)
		[1265517] = 1, -- Permafrost Bauble: Ice Block/Ice Cold -30s (nearly universal)
	},
	MONK = {
		[388813] = 1, -- Expeditious Fortification: Fortifying Brew CDR (nearly universal)
	},
	PALADIN = {
		[114154] = 1, -- Unbreakable Spirit: Bubble/DP/Ardent Defender -30% (nearly universal)
		[384909] = 1, -- Blessed Protector: BoP/Spellwarding -60s (nearly universal)
	},
	SHAMAN = {
		[381647] = 1, -- Planes Traveler: Astral Shift -30s (nearly universal)
		[381867] = 1, -- Totemic Surge: Grounding Totem -5s (nearly universal)
	},
	WARRIOR = {
		[107574] = 1, -- Avatar: nearly universal across all specs
		[184364] = 1, -- Enraged Regeneration: nearly universal for Fury
	},
}

-- Spec-specific assumed talent ranks (specId-keyed), merged on top of class defaults.
local SpecDefaultTalentRanks = {
	[102] = {
		[468743] = 1, -- Whirling Stars (Balance Druid): Incarnation -60s, nearly universal
	},
	[254] = {
		[260404] = 1, -- Calling the Shots (Marksmanship Hunter): Trueshot -30s, nearly universal
	},
	[103] = {
		[102543] = 1, -- Incarnation: Avatar of Ashamane (Feral Druid): nearly universal
		[391174] = 1, -- Berserk: Heart of the Lion (Feral Druid): nearly universal
		[391548] = 1, -- Ashamane's Guidance (Feral Druid): nearly universal
	},
	[63] = {
		[1254194] = 1, -- Kindling (Fire Mage): Combustion -60s, nearly universal
	},
	[64] = {
		[1244110] = 1, -- Glacial Bulwark (Frost Mage): Ice Block/Ice Cold +1 charge, nearly universal
	},
	[256] = {
		[373035] = 1, -- Twins of the Sun Priestess (Disc Priest): Pain Suppression +1 charge, nearly universal
	},
	[257] = {
		[419110] = 1, -- Seraphic Crescendo (Holy Priest): nearly universal
		[440738] = 1, -- Foreseen Circumstances (Holy Priest): Guardian Spirit +2s, nearly universal
	},
	[105] = {
		[382552] = 1, -- Improved Ironbark (Restoration Druid): Ironbark -20s (nearly universal)
	},
	[258] = {
		[288733] = 1, -- Intangibility (Shadow Priest): Dispersion -30s (nearly universal)
	},
	[73] = {
		[397103] = 1, -- Defender's Aegis (Protection Warrior): Shield Wall +1 charge (nearly universal)
	},
	[269] = {
		[280197] = 1, -- Spiritual Focus (Windwalker): Zenith -20s (universal)
	},
	[270] = {
		[202424] = 1, -- Chrysalis (Mistweaver): Life Cocoon -30s/45s (nearly universal)
	},
	[1468] = {
		[376204] = 1, -- Just in Time (Preservation Evoker): Time Dilation -10s (nearly universal)
		[376240] = 2, -- Timeless Magic (Preservation Evoker): Time Dilation +30% duration (nearly universal)
	},
	[65] = {
		[384820] = 1, -- Sacrifice of the Just (Holy Paladin): BoSac -15s, nearly universal
		[216331] = 1, -- Avenging Crusader (Holy Paladin): replaces Avenging Wrath, nearly universal
	},
	[66] = {
		[384820] = 1, -- Sacrifice of the Just (Protection Paladin): BoSac -60s, nearly universal
	},
	[70] = {
		[458359] = 1, -- Radiant Glory (Retribution Paladin): nearly universal
		[384820] = 1, -- Sacrifice of the Just (Retribution Paladin): BoSac -60s, nearly universal
	},
	[72] = {
		[383468] = 1, -- Invigorating Fury (Fury Warrior): Enraged Regeneration +3s, nearly universal
	},
	[262] = {
		[114050] = 1, -- Ascendance (Elemental Shaman): nearly universal
		[462440] = 1, -- First Ascendant (Elemental Shaman): Ascendance -60s, nearly universal
		[462443] = 1, -- Preeminence (Elemental Shaman): Ascendance +3s, nearly universal
	},
	[264] = {
		[114052] = 1, -- Ascendance (Restoration Shaman): nearly universal
		[462440] = 1, -- First Ascendant (Restoration Shaman): Ascendance -60s, nearly universal
	},
	[263] = {
		[384352] = 1, -- Doomwinds (Enhancement Shaman): nearly universal
		[384444] = 1, -- Thorim's Invocation (Enhancement Shaman): nearly universal
	},
	[577] = {
		[1266307] = 1, -- Demonic Resilience (Havoc Demon Hunter): Blur +1 charge, nearly universal
	},
	[1480] = {
		[1266307] = 1, -- Demonic Resilience (Devourer Demon Hunter): Blur +1 charge, nearly universal
	},
}

local talentCallbacks = {}

local function BuildTalentToSpellMap(specId)

	if not (C_ClassTalents and C_Traits and Constants and Constants.TraitConsts) then
		return nil
	end

	local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
	C_ClassTalents.InitializeViewLoadout(specId, 100)
	C_ClassTalents.ViewLoadout({})
	local configInfo = C_Traits.GetConfigInfo(configId)
	if not configInfo then
		return nil
	end

	local talentmap = {}
	for _, treeId in ipairs(configInfo.treeIDs) do
		for _, nodeId in ipairs(C_Traits.GetTreeNodes(treeId)) do
			local node = C_Traits.GetNodeInfo(configId, nodeId)
			if node and node.ID ~= 0 then
				for choiceIndex, talentId in ipairs(node.entryIDs) do
					local entryInfo = C_Traits.GetEntryInfo(configId, talentId)
					if node.type == Enum.TraitNodeType.SubTreeSelection then
						talentmap[node.ID .. "_" .. choiceIndex] = {
							spellId = -1,
							maxRank = -1,
							type = node.type,
							subTreeID = entryInfo.subTreeID,
						}
					end
					if entryInfo and entryInfo.definitionID then
						local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
						if definitionInfo.spellID then
							talentmap[node.ID .. "_" .. choiceIndex] = {
								spellId = definitionInfo.spellID,
								maxRank = node.maxRanks,
								type = node.type,
								subTreeID = node.subTreeID,
							}
						end
					end
				end
			end
		end
	end

	return talentmap
end

local function DecodeTalent(stream)
	local function readbool(s)
		return s:ExtractValue(1) == 1
	end
	local selected = readbool(stream)
	local purchased = nil
	local rank = nil
	local choiceIndex = 1
	local notMaxRank = true
	if selected then
		purchased = readbool(stream)
		if purchased then
			notMaxRank = readbool(stream)
			if notMaxRank then
				rank = stream:ExtractValue(6)
			end
			local choiceNode = readbool(stream)
			if choiceNode then
				choiceIndex = stream:ExtractValue(2) + 1
			end
		end
	end
	return selected, purchased, notMaxRank, rank, choiceIndex
end

-- Returns { [spellId] = rank } or nil on failure.
local function GetTalentRanks(specId, talentExportString)
	if not (C_Traits and C_Traits.GetLoadoutSerializationVersion and ImportDataStreamMixin and C_ClassTalents) then
		return nil
	end

	local talentIdToSpellMap = BuildTalentToSpellMap(specId)
	if not talentIdToSpellMap then
		return nil
	end

	local stream = CreateAndInitFromMixin(ImportDataStreamMixin, talentExportString)

	-- Header: 8 bits version, 16 bits specId, 128 bits treeHash
	local version = stream:ExtractValue(8)
	local encodedSpec = stream:ExtractValue(16)
	stream:ExtractValue(128) -- discard treeHash

	if C_Traits.GetLoadoutSerializationVersion() ~= 2 or version ~= 2 then
		return nil
	end
	if encodedSpec ~= specId then
		return nil
	end

	local traitTree = C_ClassTalents.GetTraitTreeForSpec(specId)
	if not traitTree then
		return nil
	end

	local fullRecords = {}
	local heroChoice
	for _, talentId in ipairs(C_Traits.GetTreeNodes(traitTree)) do
		local selected, purchased, _, rank, choiceIndex = DecodeTalent(stream)
		local spell = talentIdToSpellMap[talentId .. "_" .. choiceIndex]
		local record = {
			spellId = spell and spell.spellId or -1,
			selected = selected,
			purchased = purchased,
			rank = rank,
			maxRank = spell and spell.maxRank or nil,
			subTreeId = spell and spell.subTreeID or nil,
			type = spell and spell.type or nil,
		}
		fullRecords[#fullRecords + 1] = record
		if record.type == Enum.TraitNodeType.SubTreeSelection then
			heroChoice = spell.subTreeID
		end
	end

	local talentRanks = {}
	for _, record in ipairs(fullRecords) do
		if record.subTreeId == nil or record.subTreeId == heroChoice then
			talentRanks[record.spellId] = not record.selected and 0 or record.rank or record.maxRank
		end
	end
	return talentRanks
end

local function GetEffectiveTalentRanks(playerName, classToken, specId)
	local ranks = unitTalentRanks[playerName]
	if ranks then
		return ranks
	end
	local classDef = ClassDefaultTalentRanks[classToken]
	local specDef = specId and SpecDefaultTalentRanks[specId]
	if not classDef and not specDef then
		return nil
	end
	local cacheKey = (classToken or "") .. "_" .. (specId or "")
	local cached = defaultTalentRanksCache[cacheKey]
	if cached then
		return cached
	end
	local merged = {}
	if classDef then
		for k, v in pairs(classDef) do
			merged[k] = v
		end
	end
	if specDef then
		for k, v in pairs(specDef) do
			merged[k] = v
		end
	end
	defaultTalentRanksCache[cacheKey] = merged
	return merged
end

local function FireTalentCallbacks(playerName)
	for _, fn in ipairs(talentCallbacks) do
		fn(playerName)
	end
end

---Called by LibSpecialization when a group member's spec/talents are known.
---@param specId number
---@param playerName string
---@param talentString string?
local function OnLibSpecUpdate(specId, playerName, talentString)
	if not talentString then
		return
	end
	local ranks = GetTalentRanks(specId, talentString)
	if ranks then
		local name = ShortName(playerName)
		unitTalentRanks[name] = ranks
		unitTalentSpecId[name] = specId
		if db then
			db.TalentCache[name] = { SpecId = specId, TalentString = talentString, Time = time() }
		end
		FireTalentCallbacks(name)
	end
end

local function UpdateLocalPlayer()
	if not (GetSpecialization and GetSpecializationInfo) then
		return
	end
	local specIdx = GetSpecialization()
	if not specIdx then
		return
	end
	local specId = GetSpecializationInfo(specIdx)
	if not specId then
		return
	end
	local configId = C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
	if not configId then
		return
	end
	local talentString = C_Traits and C_Traits.GenerateImportString and C_Traits.GenerateImportString(configId)
	if not talentString then
		return
	end
	local playerName = UnitNameUnmodified("player")
	local ranks = GetTalentRanks(specId, talentString)
	if ranks then
		unitTalentRanks[playerName] = ranks
		unitTalentSpecId[playerName] = specId
		if db then
			db.TalentCache[playerName] = { SpecId = specId, TalentString = talentString, Time = time() }
		end
		FireTalentCallbacks(playerName)
	end
end

---Returns the effective cooldown for abilityId after applying known talent modifiers.
---Falls back to assumed default talents when no real talent data is available for the unit.
---If no talent data or defaults exist for the unit's class/spec, returns baseCooldown unchanged.
---measuredDuration is required for PostBuff modifiers (cooldown set after buff expires).
---@param unit string
---@param specId number|nil
---@param classToken string
---@param abilityId number
---@param baseCooldown number
---@param measuredDuration number?
---@return number
function M:GetUnitCooldown(unit, specId, classToken, abilityId, baseCooldown, measuredDuration)
	local rawName = UnitNameUnmodified(unit)
	-- Arena enemy names are secret values; resolve to nil so GetEffectiveTalentRanks
	-- falls back to class/spec defaults rather than returning baseCooldown unchanged.
	local playerName = (rawName and not issecretvalue(rawName)) and ShortName(rawName) or nil
	local talentRanks = GetEffectiveTalentRanks(playerName, classToken, specId)
	if not talentRanks then
		return baseCooldown
	end

	local addAmount = 0
	local multAmount = 0
	local postBuffRemaining = nil
	local classMods = ClassCooldownModifiers[classToken]
	local resolvedSpec = (playerName and unitTalentSpecId[playerName]) or specId
	local specMods = resolvedSpec and SpecCooldownModifiers[resolvedSpec]

	local function applyModTable(modTable)
		if not modTable then
			return
		end
		for talentSpellId, rankList in pairs(modTable) do
			local rank = talentRanks[talentSpellId]
			if rank and rank > 0 then
				local mods = rankList[rank]
				if mods then
					for _, mod in ipairs(mods) do
						if mod.SpellId == abilityId then
							if mod.PostBuff then
								postBuffRemaining = mod.Amount
							elseif mod.Mult then
								multAmount = multAmount + mod.Amount
							else
								addAmount = addAmount + mod.Amount
							end
						end
					end
				end
			end
		end
	end
	applyModTable(classMods)
	applyModTable(specMods)

	local pvpIds = playerName and unitPvPTalentIds[playerName]

	-- PostBuff: talent sets remaining cooldown after the buff expires.
	-- Return measuredDuration + postBuffRemaining so that remaining = cooldown - measuredDuration = postBuffRemaining.
	if postBuffRemaining then
		return math.max((measuredDuration or 0) + postBuffRemaining, 0)
	end

	-- Apply regular mods first, then PvP mods on top of that result.
	local cd = baseCooldown + addAmount + (baseCooldown * multAmount / 100)

	local pvpAddAmount = 0
	local pvpMultAmount = 0
	local function applyPvPModTable(modTable)
		if not modTable or not pvpIds or not UnitIsPVP(unit) then
			return
		end
		for pvpTalentId, mods in pairs(modTable) do
			if pvpIds[pvpTalentId] then
				for _, mod in ipairs(mods) do
					if mod.SpellId == abilityId then
						if mod.Mult then
							pvpMultAmount = pvpMultAmount + mod.Amount
						else
							pvpAddAmount = pvpAddAmount + mod.Amount
						end
					end
				end
			end
		end
	end
	applyPvPModTable(ClassPvPCooldownModifiers[classToken])
	applyPvPModTable(resolvedSpec and SpecPvPCooldownModifiers[resolvedSpec])

	cd = cd + pvpAddAmount + (cd * pvpMultAmount / 100)
	return math.max(cd, 0)
end

---Returns the effective buff duration for abilityId after applying known talent modifiers.
---Falls back to assumed default talents when no real talent data is available for the unit.
---If no talent data or defaults exist for the unit's class/spec, returns baseDuration unchanged.
---@param unit string
---@param specId number|nil
---@param classToken string
---@param abilityId number
---@param baseDuration number
---@return number
function M:GetUnitBuffDuration(unit, specId, classToken, abilityId, baseDuration)
	local rawName = UnitNameUnmodified(unit)
	-- Arena enemy names are secret values; resolve to nil so GetEffectiveTalentRanks
	-- falls back to class/spec defaults rather than returning baseDuration unchanged.
	local playerName = (rawName and not issecretvalue(rawName)) and ShortName(rawName) or nil
	local talentRanks = GetEffectiveTalentRanks(playerName, classToken, specId)
	if not talentRanks then
		return baseDuration
	end

	local addAmount = 0
	local multAmount = 0
	local resolvedSpec = (playerName and unitTalentSpecId[playerName]) or specId

	local function applyDurationModTable(modTable)
		if not modTable then
			return
		end
		for talentSpellId, rankList in pairs(modTable) do
			local rank = talentRanks[talentSpellId]
			if rank and rank > 0 then
				local mods = rankList[rank]
				if mods then
					for _, mod in ipairs(mods) do
						if mod.SpellId == abilityId then
							if mod.Mult then
								multAmount = multAmount + mod.Amount
							else
								addAmount = addAmount + mod.Amount
							end
						end
					end
				end
			end
		end
	end
	applyDurationModTable(ClassDurationModifiers[classToken])
	applyDurationModTable(resolvedSpec and SpecDurationModifiers[resolvedSpec])

	return math.max(baseDuration + addAmount + (baseDuration * multAmount / 100), 0)
end

---Returns the effective maximum charge count for abilityId after applying known talent modifiers.
---Falls back to assumed default talents when no real talent data is available for the unit.
---If no talent data or defaults exist for the unit's class/spec, returns 1.
---@param unit string
---@param specId number|nil
---@param classToken string
---@param abilityId number
---@return number
function M:GetUnitMaxCharges(unit, specId, classToken, abilityId)
	local rawName = UnitNameUnmodified(unit)
	local playerName = (rawName and not issecretvalue(rawName)) and ShortName(rawName) or nil
	local talentRanks = GetEffectiveTalentRanks(playerName, classToken, specId)
	if not talentRanks then
		return 1
	end

	local addAmount = 0
	local classMods = ClassChargeModifiers[classToken]
	local resolvedSpec = (playerName and unitTalentSpecId[playerName]) or specId
	local specMods = resolvedSpec and SpecChargeModifiers[resolvedSpec]

	local function applyModTable(modTable)
		if not modTable then
			return
		end
		for talentSpellId, rankList in pairs(modTable) do
			local rank = talentRanks[talentSpellId]
			if rank and rank > 0 then
				local mods = rankList[rank]
				if mods then
					for _, mod in ipairs(mods) do
						if mod.SpellId == abilityId then
							addAmount = addAmount + mod.Amount
						end
					end
				end
			end
		end
	end
	applyModTable(classMods)
	applyModTable(specMods)

	return 1 + addAmount
end

---Returns true if the unit has the given talent spell ID ranked (rank > 0), or has it as an active PvP talent.
---Falls back to ClassDefaultTalentRanks/SpecDefaultTalentRanks when no real talent data is available.
---@param unit string
---@param talentSpellId number
---@param callerSpecId number? Caller-resolved spec ID (e.g. from Inspector); used when unitTalentSpecId has no entry
---@return boolean
function M:UnitHasTalent(unit, talentSpellId, callerSpecId)
	local playerName = UnitNameUnmodified(unit)
	if playerName and not issecretvalue(playerName) then
		playerName = ShortName(playerName)
		local talentRanks = unitTalentRanks[playerName]
		if talentRanks ~= nil and (talentRanks[talentSpellId] or 0) > 0 then
			return true
		end
		local pvpIds = unitPvPTalentIds[playerName]
		if pvpIds ~= nil and pvpIds[talentSpellId] == true then
			return true
		end
		-- No real talent data - check class/spec defaults.
		-- Prefer the caller-supplied spec ID (from Inspector) over our stored one,
		-- since non-MiniCC players won't have an entry in unitTalentSpecId.
		if talentRanks == nil then
			local _, classToken = UnitClass(unit)
			local specId = unitTalentSpecId[playerName] or callerSpecId
			local effectiveRanks = GetEffectiveTalentRanks(playerName, classToken, specId)
			if effectiveRanks and (effectiveRanks[talentSpellId] or 0) > 0 then
				return true
			end
		end
		return false
	end
	-- playerName is nil or a secret value - can't look up stored data.
	-- Fall back to class/spec defaults using callerSpecId so spec-specific icons
	-- (e.g. AC vs AW for Holy Paladin) still render correctly.
	local _, classToken = UnitClass(unit)
	local effectiveRanks = GetEffectiveTalentRanks(nil, classToken, callerSpecId)
	return effectiveRanks ~= nil and (effectiveRanks[talentSpellId] or 0) > 0
end

---Returns the spec ID stored for a unit from talent decode (LibSpec or local player).
---@param unit string
---@return number|nil
function M:GetUnitSpecId(unit)
	-- FrameSort is most authoritative (real-time); inspector is the fallback real-time source;
	-- unitTalentSpecId covers cross-realm players and situations where the above return nil.
	local fs = FrameSortApi and FrameSortApi.v3
	if fs and fs.Inspector then
		local id = fs.Inspector:GetUnitSpecId(unit)
		if id then
			return id
		end
		-- FrameSort returned nil; fall through to tooltip check and talent cache.
	end
	local specId = inspector:GetUnitSpecId(unit)
	if specId then
		return specId
	end
	-- For enemy arena units use GetArenaOpponentSpec, which is authoritative and available
	-- as soon as ARENA_PREP_OPPONENT_SPECIALIZATIONS fires.
	local arenaIndex = unit:match("^arena(%d)$")
	if arenaIndex then
		local id = GetArenaOpponentSpec and GetArenaOpponentSpec(tonumber(arenaIndex))
		if id and id > 0 then
			return id
		end
	end
	local playerName = UnitNameUnmodified(unit)
	if not playerName or issecretvalue(playerName) then
		return nil
	end
	return unitTalentSpecId[ShortName(playerName)]
end

---Registers a callback to be fired when any unit's talent data is updated.
---The callback receives the player name (without realm) as its argument.
---@param fn fun(playerName: string)
function M:RegisterTalentCallback(fn)
	talentCallbacks[#talentCallbacks + 1] = fn
end

function M:Refresh() end

function M:Init()
	db = mini:GetSavedVars()
	db.TalentCache = db.TalentCache or {}
	db.PvPTalentCache = db.PvPTalentCache or {}

	local now = time()
	local maxAge = 86400 -- 1 day in seconds

	-- Restore talent data from saved vars so CDR calculations work immediately after a reload.
	for name, entry in pairs(db.TalentCache) do
		if not entry.Time or (now - entry.Time) > maxAge then
			db.TalentCache[name] = nil
		else
			local ranks = GetTalentRanks(entry.SpecId, entry.TalentString)
			if ranks then
				unitTalentRanks[name] = ranks
				unitTalentSpecId[name] = entry.SpecId
			else
				db.TalentCache[name] = nil
			end
		end
	end

	-- Restore PvP talent data from saved vars.
	for name, entry in pairs(db.PvPTalentCache) do
		if not entry.Time or (now - entry.Time) > maxAge then
			db.PvPTalentCache[name] = nil
		else
			local set = {}
			for _, id in ipairs(entry.Ids) do
				set[id] = true
			end
			unitPvPTalentIds[name] = set
		end
	end

	-- Register with LibSpecialization for group member talent strings.
	local libSpec = LibStub and LibStub("LibSpecialization", true)
	if libSpec then
		libSpec.RegisterGroup(addon, function(specId, _, _, playerName, talentString)
			OnLibSpecUpdate(specId, playerName, talentString)
		end)
	end

	-- Track local player talent changes.
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", UpdateLocalPlayer)
	frame:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
	frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
	frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	frame:RegisterEvent("PLAYER_LOGIN")

	-- Receive PvP talent data from group members via PvPTalentSync.
	addon.Modules.Cooldowns.PvPTalentSync:RegisterCallback(function(playerName, pvpTalentIds)
		local name = playerName:match("^([^%-]+)") or playerName
		if pvpTalentIds then
			local ids = {}
			for _, id in ipairs(pvpTalentIds) do
				ids[#ids + 1] = id
			end
			db.PvPTalentCache[name] = { Ids = ids, Time = time() }
			local set = {}
			for _, id in ipairs(ids) do
				set[id] = true
			end
			unitPvPTalentIds[name] = set
		else
			db.PvPTalentCache[name] = nil
			unitPvPTalentIds[name] = nil
		end
		FireTalentCallbacks(name)
	end)
end

---@class CooldownTalents
---@field Init fun(self: CooldownTalents)
---@field Refresh fun(self: CooldownTalents)
---@field GetUnitCooldown fun(self: CooldownTalents, unit: string, specId: number|nil, classToken: string, abilityId: number, baseCooldown: number, measuredDuration: number?): number
---@field GetUnitBuffDuration fun(self: CooldownTalents, unit: string, specId: number|nil, classToken: string, abilityId: number, baseDuration: number): number
---@field GetUnitMaxCharges fun(self: CooldownTalents, unit: string, specId: number|nil, classToken: string, abilityId: number): number
---@field GetUnitSpecId fun(self: CooldownTalents, unit: string): number|nil
---@field UnitHasTalent fun(self: CooldownTalents, unit: string, talentSpellId: number): boolean
---@field RegisterTalentCallback fun(self: CooldownTalents, fn: fun(playerName: string))
