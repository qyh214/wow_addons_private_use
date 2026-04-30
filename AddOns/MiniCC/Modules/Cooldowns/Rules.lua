--@type string, Addon
local _, addon = ...

addon.Modules.Cooldowns = addon.Modules.Cooldowns or {}

-- Rules keyed first by spec ID (more precise), then by class token (fallback).
-- Each rule carries flags for which aura type(s) it can match:
--   BigDefensive = true      matches BIG_DEFENSIVE auras from GetDefensiveState()
--   ExternalDefensive = true matches EXTERNAL_DEFENSIVE auras from GetDefensiveState()
--   Important = true         matches IMPORTANT auras from GetImportantState()
-- A rule may carry multiple flags when a spell is tagged as both (e.g. Paladin Divine Protection).
--
-- Paladin:     Holy=65,    Prot=66,      Ret=70
-- Warrior:     Arms=71,    Fury=72,      Prot=73
-- Mage:        Arcane=62,  Fire=63,      Frost=64
-- Hunter:      BM=253,     MM=254,       Survival=255
-- Priest:      Disc=256,   Holy=257,     Shadow=258
-- Rogue:       Assassination=259, Outlaw=260, Subtlety=261
-- Death Knight: Blood=250, Frost=251,    Unholy=252
-- Shaman:      Elem=262,   Enh=263,      Resto=264
-- Warlock:     Affliction=265, Demonology=266, Destruction=267
-- Monk:        Brew=268,   WW=269,       MW=270
-- Demon Hunter: Havoc=577, Vengeance=581, Devourer=1480
-- Druid:       Balance=102,Feral=103,    Guardian=104, Resto=105
-- Evoker:      Devas=1467, Preserv=1468, Aug=1473

-- SpellId maps a rule to the canonical spell ID used for talent CDR lookups.

---@class CooldownRules
local rules = {
	BySpec = {
		[65] = { -- Holy Paladin
			{
				BuffDuration = 12,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 31884,
				MinDuration = true,
				ExcludeIfTalent = 216331,
			}, -- Avenging Wrath (hidden if Avenging Crusader talented)
			{
				BuffDuration = 10,
				Cooldown = 60,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 216331,
				MinDuration = true,
				RequiresTalent = 216331,
			}, -- Avenging Crusader
			{
				BuffDuration = 8,
				Cooldown = 300,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				RequiresEvidence = "UnitFlags",
				CanCancelEarly = true,
				SpellId = 642,
			}, -- Divine Shield
			{
				BuffDuration = 8,
				Cooldown = 60,
				BigDefensive = true,
				Important = true,
				ExternalDefensive = false,
				SpellId = 498,
			}, -- Divine Protection
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 1022,
				ExcludeIfTalent = 5692,
			}, -- Blessing of Protection (excluded when Spellwarding talented; both share the same 300s CD)
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 204018,
				CastSpellId = 1022,
				RequiresTalent = 5692,
			}, -- Blessing of Spellwarding (matches both BoS and BoP casts when talented; CastSpellId=1022 so local player casting BoP is still attributed to BoS)
			{
				BuffDuration = 12,
				Cooldown = 120,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				RequiresEvidence = "Shield",
				SelfCastable = false,
				SpellId = 6940,
			}, -- Blessing of Sacrifice
		},
		[66] = { -- Protection Paladin
			{
				BuffDuration = 25,
				Cooldown = 120,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				MinDuration = true,
				SpellId = 31884,
				ExcludeIfTalent = 389539,
			}, -- Avenging Wrath (hidden if Sentinel talented)
			{
				BuffDuration = 20,
				Cooldown = 120,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				MinDuration = true,
				SpellId = 389539,
				RequiresTalent = 389539,
				ExcludeIfTalent = 31884,
			}, -- Sentinel (hidden if Avenging Wrath talented)
			{
				BuffDuration = 8,
				Cooldown = 300,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				RequiresEvidence = "UnitFlags",
				CanCancelEarly = true,
				SpellId = 642,
			}, -- Divine Shield
			{
				BuffDuration = 8,
				Cooldown = 90,
				BigDefensive = true,
				Important = true,
				ExternalDefensive = false,
				SpellId = 31850,
			}, -- Ardent Defender
			{
				BuffDuration = 8,
				Cooldown = 180,
				BigDefensive = true,
				Important = false,
				ExternalDefensive = false,
				SpellId = 86659,
				MaxCharges = 2,
			}, -- Guardian of Ancient Kings
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 1022,
				ExcludeIfTalent = 5692,
			}, -- Blessing of Protection (excluded when Spellwarding talented; both share the same 300s CD)
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 204018,
				CastSpellId = 1022,
				RequiresTalent = 5692,
			}, -- Blessing of Spellwarding (matches both BoS and BoP casts when talented; CastSpellId=1022 so local player casting BoP is still attributed to BoS)
			{
				BuffDuration = 12,
				Cooldown = 120,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				RequiresEvidence = "Shield",
				SelfCastable = false,
				SpellId = 6940,
			}, -- Blessing of Sacrifice
		},
		[70] = { -- Retribution Paladin
			{
				BuffDuration = 24,
				Cooldown = 60,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 31884,
				ExcludeIfTalent = 458359,
			}, -- Avenging Wrath (hidden if Radiant Glory talented)
			{
				BuffDuration = 8,
				Cooldown = 300,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				RequiresEvidence = "UnitFlags",
				CanCancelEarly = true,
				SpellId = 642,
			}, -- Divine Shield
			{
				BuffDuration = 8,
				Cooldown = 90,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				RequiresEvidence = "Shield",
				SpellId = 403876,
			}, -- Divine Protection (90s base for Ret)
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 1022,
				ExcludeIfTalent = 5573,
			}, -- Blessing of Protection (excluded when Spellwarding talented; both share the same 300s CD)
			{
				BuffDuration = 10,
				Cooldown = 300,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				SpellId = 204018,
				CastSpellId = 1022,
				RequiresTalent = 5573,
			}, -- Blessing of Spellwarding (matches both BoS and BoP casts when talented; CastSpellId=1022 so local player casting BoP is still attributed to BoS)
			{
				BuffDuration = 12,
				Cooldown = 120,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				RequiresEvidence = "Shield",
				SelfCastable = false,
				SpellId = 6940,
			}, -- Blessing of Sacrifice
		},
		[62] = { -- Arcane Mage
			{
				BuffDuration = 15,
				Cooldown = 90,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				MinDuration = true,
				SpellId = 365350,
			}, -- Arcane Surge
			{
				BuffDuration = 10,
				Cooldown = 240,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CanCancelEarly = true,
				SpellId = 45438,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				ExcludeIfTalent = 414659,
			}, -- Ice Block
		},
		[63] = { -- Fire Mage
			{
				BuffDuration = 10,
				Cooldown = 120,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 190319,
				MinDuration = true,
			}, -- Combustion
			{
				BuffDuration = 10,
				Cooldown = 240,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CanCancelEarly = true,
				SpellId = 45438,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				ExcludeIfTalent = 414659,
			}, -- Ice Block
		},
		[64] = { -- Frost Mage
			{
				BuffDuration = 10,
				Cooldown = 240,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CanCancelEarly = true,
				SpellId = 45438,
				RequiresEvidence = { "Debuff", "UnitFlags" },
				ExcludeIfTalent = 414659,
				MaxCharges = 2,
			}, -- Ice Block
			{
				BuffDuration = 6,
				Cooldown = 240,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 414659,
				CastSpellId = 414658,
				RequiresEvidence = "Debuff",
				RequiresTalent = 414659,
				MaxCharges = 2,
			}, -- Ice Cold (replaces Ice Block)
		},
		[71] = { -- Arms Warrior
			{
				BuffDuration = 8,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 118038,
			}, -- Die by the Sword
			{
				BuffDuration = 20,
				Cooldown = 90,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 107574,
				MinDuration = true,
				RequiresTalent = 107574,
			}, -- Avatar
		},
		[72] = { -- Fury Warrior
			{
				BuffDuration = 8,
				Cooldown = 108,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 184364,
				RequiresTalent = 184364,
			}, -- Enraged Regeneration
			{
				BuffDuration = 11,
				Cooldown = 108,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 184364,
				RequiresTalent = 184364,
			}, -- Enraged Regeneration + duration talent
			{
				BuffDuration = 20,
				Cooldown = 90,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 107574,
				MinDuration = true,
				RequiresTalent = 107574,
			}, -- Avatar
		},
		[73] = { -- Protection Warrior
			{
				BuffDuration = 8,
				Cooldown = 180,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 871,
				MaxCharges = 2,
			}, -- Shield Wall
			{
				BuffDuration = 20,
				Cooldown = 90,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 107574,
				MinDuration = true,
				RequiresTalent = 107574,
			}, -- Avatar
		},
		[251] = {
			{
				BuffDuration = 12,
				Cooldown = 45,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				MinDuration = true,
				SpellId = 51271,
			},
		}, -- Frost Death Knight: Pillar of Frost
		[250] = { -- Blood Death Knight
			{
				BuffDuration = 10,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 55233,
			}, -- Vampiric Blood
			{
				BuffDuration = 12,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 55233,
			}, -- Vampiric Blood + Goreringers Anguish rank 1 (+2s)
			{
				BuffDuration = 14,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 55233,
			}, -- Vampiric Blood + Goreringers Anguish rank 2 (+4s)
		},
		[256] = {
			{
				BuffDuration = 8,
				Cooldown = 180,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				SpellId = 33206,
				MaxCharges = 2,
			},
		}, -- Discipline Priest: Pain Suppression
		[257] = { -- Holy Priest
			{
				BuffDuration = 10,
				Cooldown = 180,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				SpellId = 47788,
				ExcludeIfTalent = 440738,
			}, -- Guardian Spirit
			{
				BuffDuration = 12,
				Cooldown = 180,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				SpellId = 47788,
				RequiresTalent = 440738,
			}, -- Guardian Spirit (Foreseen Circumstances)
			{
				BuffDuration = 5,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				CanCancelEarly = true,
				MinCancelDuration = 1.5, -- Phase Shift (PvP talent) applies a 1s IMPORTANT buff on Fade; exclude it
				SpellId = 64843,
			}, -- Divine Hymn
		},
		[258] = { -- Shadow Priest
			{
				BuffDuration = 6,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CrowdControl = true,
				CanCancelEarly = true,
				SpellId = 47585,
			}, -- Dispersion
			{
				BuffDuration = 8,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CrowdControl = true,
				CanCancelEarly = true,
				SpellId = 47585,
				RequiresTalent = 453729,
			}, -- Dispersion + Heightened Alteration (+2s)
			{
				BuffDuration = 20,
				Cooldown = 120,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				-- Archon Sustainted Potency can increase the duration
				MinDuration = true,
				SpellId = 228260,
			}, -- Voidform
		},
		[102] = {
			{
				BuffDuration = 20,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				MinDuration = true,
				SpellId = 102560,
				MaxCharges = 2,
			},
		}, -- Balance Druid: Incarnation: Chosen of Elune
		[103] = {
			{
				BuffDuration = 15,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				MinDuration = true,
				SpellId = 106951,
				RequiresTalent = 106951,
				ExcludeIfTalent = 102543,
			}, -- Feral Druid: Berserk (hidden if Incarnation talented)
			{
				BuffDuration = 20,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 102543,
				RequiresTalent = 102543,
			}, -- Feral Druid: Incarnation: Avatar of Ashamane (shown when 102543 talented; Berserk self-excludes via ExcludeIfTalent=102543)
		},
		[104] = {
			{
				BuffDuration = 30,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 102558,
			},
		}, -- Guardian Druid: Incarnation: Guardian of Ursoc
		[105] = {
			{
				BuffDuration = 12,
				Cooldown = 90,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				SpellId = 102342,
			},
		}, -- Restoration Druid: Ironbark
		[268] = { -- Brewmaster Monk
			{
				BuffDuration = 25,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 132578,
			}, -- Invoke Niuzao, the Black Ox
			{
				BuffDuration = 15,
				Cooldown = 360,
				BigDefensive = true,
				Important = false,
				ExternalDefensive = false,
				SpellId = 115203,
			}, -- Fortifying Brew
		},
		[270] = {
			{
				BuffDuration = 12,
				Cooldown = 120,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = "Shield",
				SpellId = 116849,
			},
		}, -- Mistweaver Monk: Life Cocoon
		[269] = { -- Windwalker Monk
			{
				BuffDuration = 15,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				BaseCharges = 2,
				SpellId = 1249625,
			}, -- Zenith
			{
				BuffDuration = 10,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = false,
				CanCancelEarly = true,
				RequiresEvidence = "Shield",
				SpellId = 125174,
			}, -- Touch of Karma
		},
		[577] = { -- Havoc Demon Hunter
			{
				BuffDuration = 10,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 198589,
				MaxCharges = 2,
			}, -- Blur
		},
		[1480] = { -- Devourer Demon Hunter
			{
				BuffDuration = 10,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = false,
				SpellId = 198589,
				MaxCharges = 2,
			}, -- Blur
		},
		[581] = { -- Vengeance Demon Hunter
			{
				BuffDuration = 12,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = false,
				MinDuration = true,
				SpellId = 204021,
			}, -- Fiery Brand
			{
				BuffDuration = 15,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 187827,
			}, -- Metamorphosis
			{
				BuffDuration = 20,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 187827,
			}, -- Metamorphosis +5s (Vengeful Beast)
		},
		[254] = {
			{
				BuffDuration = 15,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 288613,
			}, -- Marksmanship Hunter: Trueshot
			{
				BuffDuration = 17,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 288613,
			}, -- Marksmanship Hunter: Trueshot +2s
		},
		[255] = { -- Survival Hunter
			{
				BuffDuration = 8,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 1250646,
			}, -- Takedown
			{
				BuffDuration = 10,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 1250646,
			}, -- Takedown +2s
		},
		[261] = {
			{
				BuffDuration = 16,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 121471,
				ExcludeFromPrediction = true, -- Shadow Dance (also IMPORTANT) cannot be distinguished without duration
				CanCancelEarly = true,
				MinCancelDuration = 11,
			}, -- Subtlety Rogue: Shadow Blades
			{
				BuffDuration = 18,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 121471,
				ExcludeFromPrediction = true, -- Shadow Dance (also IMPORTANT) cannot be distinguished without duration
				CanCancelEarly = true,
				MinCancelDuration = 11,
			}, -- Shadow Blades +2s (set bonus)
			{
				BuffDuration = 20,
				Cooldown = 90,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 121471,
				ExcludeFromPrediction = true, -- Shadow Dance (also IMPORTANT) cannot be distinguished without duration
				CanCancelEarly = true,
				MinCancelDuration = 11,
			}, -- Shadow Blades +4s (set bonus)
		},
		[1467] = {
			{
				BuffDuration = 18,
				Cooldown = 120,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				MinDuration = true,
				SpellId = 375087,
			},
		}, -- Devastation Evoker: Dragonrage
		[1468] = {
			{
				BuffDuration = 8,
				Cooldown = 60,
				ExternalDefensive = true,
				BigDefensive = false,
				Important = false,
				SpellId = 357170,
				MaxCharges = 2,
			},
		}, -- Preservation Evoker: Time Dilation
		[1473] = {
			{
				BuffDuration = 13.4,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				MinDuration = true,
				SpellId = 363916,
				MaxCharges = 2,
			},
			{
				BuffDuration = 5,
				Cooldown = 41,
				BigDefensive = false,
				Important = true,
				ExternalDefensive = false,
				CrowdControl = true,
				CanCancelEarly = true,
				CastableOnOthers = true,
				RequiresEvidence = "UnitFlags",
				SpellId = 378441,
				RequiresTalent = { 5463, 5464, 5619 },
				PvPOnly = true,
			}, -- Time Stop (PvP talent)
		}, -- Augmentation Evoker: Obsidian Scales
		[264] = { -- Restoration Shaman
			{
				BuffDuration = 15,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 114052,
				RequiresTalent = 114052,
			}, -- Ascendance
		},
		[262] = { -- Elemental Shaman
			{
				BuffDuration = 15,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 114050,
				RequiresTalent = 114050,
			}, -- Ascendance
			{
				BuffDuration = 18,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 114050,
				RequiresTalent = 114050,
			}, -- Ascendance +3s (Preeminence)
		},
		[263] = { -- Enhancement Shaman
			{
				BuffDuration = 8,
				Cooldown = 60,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 384352,
				RequiresTalent = 384352,
				ExcludeIfTalent = { 114051, 378270 },
			}, -- Doomwinds (hidden if Ascendance or Deeply Rooted Elements talented)
			{
				BuffDuration = 10,
				Cooldown = 60,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 384352,
				RequiresTalent = 384352,
				ExcludeIfTalent = { 114051, 378270 },
			}, -- Doomwinds +2s (Thorim's Invocation)
			{
				BuffDuration = 15,
				Cooldown = 180,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				SpellId = 114051,
				RequiresTalent = 114051,
			}, -- Ascendance
		},
	},
	ByClass = {
		PALADIN = {
			{
				BuffDuration = 8,
				Cooldown = 300,
				BigDefensive = true,
				Important = true,
				ExternalDefensive = false,
				RequiresEvidence = "UnitFlags",
				CanCancelEarly = true,
				SpellId = 642,
			}, -- Divine Shield
			{
				BuffDuration = 8,
				Cooldown = 25,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				CrowdControl = false, -- BoF is not a CC; rejects Time Stop (CrowdControl=true) false matches
				CanCancelEarly = true,
				MinCancelDuration = 1.5, -- Phase Shift (PvP talent) applies a 1s IMPORTANT buff on Fade; exclude it
				CastableOnOthers = true,
				SpellId = 1044,
			}, -- Blessing of Freedom
		},
		WARRIOR = {},
		MAGE = {
			{
				BuffDuration = 10,
				Cooldown = 50,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CanCancelEarly = true,
				SpellId = 342246,
				CastSpellId = { 342245, 342247 },
			}, -- Alter Time
		},
		HUNTER = {
			{
				BuffDuration = 8,
				Cooldown = 180,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				CanCancelEarly = true,
				SpellId = 186265,
				RequiresEvidence = "UnitFlags",
				ExcludeFromPrediction = true,
			}, -- Aspect of the Turtle
			{
				BuffDuration = 6,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				MinDuration = true,
				SpellId = 264735,
				MaxCharges = 2,
				RequiresEvidence = false,
			}, -- Survival of the Fittest
			{
				BuffDuration = 8,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				MinDuration = true,
				SpellId = 264735,
				MaxCharges = 2,
				RequiresEvidence = false,
			}, -- Survival of the Fittest + Survival of the Fittest talent (+2s)
			{
				BuffDuration = 3,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 109304,
				RequiresTalent = 430709,
				ExcludeFromPrediction = true,
			}, -- Exhilaration (Dark Ranger: applies 3s SotF)
			{
				BuffDuration = 10,
				Cooldown = 120,
				BigDefensive = false,
				ExternalDefensive = true,
				Important = false,
				CastableOnOthers = true,
				SpellId = 53480,
				RequiresTalent = 53480,
			}, -- Roar of Sacrifice
		},
		DRUID = {
			{
				BuffDuration = 8,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 22812,
			}, -- Barkskin
			{
				BuffDuration = 12,
				Cooldown = 60,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 22812,
			}, -- Barkskin + Improved Barkskin (+4s)
		},
		ROGUE = {
			{
				BuffDuration = 10,
				Cooldown = 120,
				Important = true,
				ExternalDefensive = false,
				BigDefensive = false,
				SpellId = 5277,
				ExcludeFromPrediction = true, -- Shadow Dance (also IMPORTANT) cannot be distinguished without duration
			}, -- Evasion
			{
				BuffDuration = 5,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = false,
				SpellId = 31224,
			}, -- Cloak of Shadows
		},
		DEATHKNIGHT = {
			{
				BuffDuration = 5,
				Cooldown = 60,
				BigDefensive = true,
				Important = true,
				ExternalDefensive = false,
				CanCancelEarly = true,
				SpellId = 48707,
				RequiresEvidence = "Shield",
			}, -- Anti-Magic Shell (BigDefensive, without Spellwarding)
			{
				BuffDuration = 7,
				Cooldown = 60,
				BigDefensive = true,
				Important = true,
				ExternalDefensive = false,
				CanCancelEarly = true,
				SpellId = 48707,
				RequiresEvidence = "Shield",
			}, -- Anti-Magic Shell + Anti-Magic Barrier (+40%) (BigDefensive, without Spellwarding)
			{
				BuffDuration = 8,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 48792,
			}, -- Icebound Fortitude
			{
				BuffDuration = 5,
				Cooldown = 60,
				BigDefensive = false,
				Important = true,
				ExternalDefensive = false,
				CanCancelEarly = true,
				SpellId = 48707,
				CastSpellId = 410358,
				CastableOnOthers = true,
				RequiresEvidence = "Shield",
			}, -- Anti-Magic Shell (Spellwarding self-cast, or cast on ally)
			{
				BuffDuration = 7,
				Cooldown = 60,
				BigDefensive = false,
				Important = true,
				ExternalDefensive = false,
				CanCancelEarly = true,
				CastableOnOthers = true,
				SpellId = 48707,
				CastSpellId = 410358,
				RequiresEvidence = "Shield",
			}, -- Anti-Magic Shell + AMB +40% (Spellwarding self-cast, or cast on ally)
		},
		DEMONHUNTER = {},
		MONK = {
			{
				BuffDuration = 15,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = false,
				SpellId = 115203,
			},
		}, -- Fortifying Brew
		SHAMAN = {
			{
				BuffDuration = 12,
				Cooldown = 120,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 108271,
			}, -- Astral Shift
			{
				BuffDuration = 3.5,
				Cooldown = 30,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				CanCancelEarly = true,
				MinCancelDuration = 0.5,
				SpellId = 204336,
				RequiresTalent = { 3620, 3622, 715 },
				PvPOnly = true,
			}, -- Grounding Totem (PvP talent, consumed in 0.5-3s)
		},
		WARLOCK = {
			{
				BuffDuration = 8,
				Cooldown = 180,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 104773,
			}, -- Unending Resolve
			{
				BuffDuration = 3,
				Cooldown = 45,
				Important = true,
				BigDefensive = false,
				ExternalDefensive = false,
				CanCancelEarly = true,
				SpellId = 212295,
				RequiresTalent = { 18, 3508, 3624 },
				PvPOnly = true,
			}, -- Nether Ward (PvP talent)
		},
		PRIEST = {
			{
				BuffDuration = 10,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				SpellId = 19236,
			}, -- Desperate Prayer
		},
		EVOKER = {
			{
				BuffDuration = 12,
				Cooldown = 90,
				BigDefensive = true,
				ExternalDefensive = false,
				Important = true,
				MinDuration = true,
				SpellId = 363916,
				MaxCharges = 2,
			}, -- Obsidian Scales
			{
				BuffDuration = 5,
				Cooldown = 45,
				BigDefensive = false,
				Important = true,
				ExternalDefensive = false,
				CrowdControl = true,
				CanCancelEarly = true,
				CastableOnOthers = true,
				RequiresEvidence = "UnitFlags",
				SpellId = 378441,
				RequiresTalent = { 5463, 5464, 5619 },
				PvPOnly = true,
			}, -- Time Stop (PvP talent)
		},
	},
}

-- Spell IDs treated as offensive cooldowns for the ShowOffensiveCooldowns option.
local offensiveSpellIds = {
	[375087] = true, -- Dragonrage
	[107574] = true, -- Avatar
	[121471] = true, -- Shadow Blades
	[31884] = true, -- Avenging Wrath
	[216331] = true, -- Avenging Crusader
	[190319] = true, -- Combustion
	[288613] = true, -- Trueshot
	[228260] = true, -- Voidform
	[102560] = true, -- Incarnation: Chosen of Elune (Balance)
	[102543] = true, -- Incarnation: Avatar of Ashamane (Feral)
	[106951] = true, -- Berserk (Feral, same choice node as Incarnation)
	[102558] = true, -- Incarnation: Guardian of Ursoc (Guardian)
	[1250646] = true, -- Takedown
	[384352] = true, -- Doomwinds
	[114051] = true, -- Ascendance (Enhancement)
	[114050] = true, -- Ascendance (Elemental)
}

rules.OffensiveSpellIds = offensiveSpellIds

-- Lazily built spellId -> rule lookup for GetSpellType.
local spellTypeCache = nil

local function BuildSpellTypeCache()
	spellTypeCache = {}
	for _, ruleList in pairs(rules.BySpec) do
		for _, rule in ipairs(ruleList) do
			if rule.SpellId then
				spellTypeCache[rule.SpellId] = rule
			end
		end
	end
	for _, ruleList in pairs(rules.ByClass) do
		for _, rule in ipairs(ruleList) do
			if rule.SpellId and not spellTypeCache[rule.SpellId] then
				spellTypeCache[rule.SpellId] = rule
			end
		end
	end
end

---Returns the type of a spell: "Offensive", "Defensive", or "Important".
---"Defensive" means the rule has BigDefensive or ExternalDefensive set.
---"Offensive" means the spell is in the offensive set.
---"Important" is the fallback for spells that are neither.
---@param spellId number
---@return "Offensive"|"Defensive"|"Important"
function rules.GetSpellType(spellId)
	if offensiveSpellIds[spellId] then
		return "Offensive"
	end
	if not spellTypeCache then
		BuildSpellTypeCache()
	end
	local rule = spellTypeCache[spellId]
	if rule and (rule.BigDefensive or rule.ExternalDefensive) then
		return "Defensive"
	end
	return "Important"
end

addon.Modules.Cooldowns.Rules = rules
