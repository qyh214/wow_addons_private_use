------------------------------------------------
---- Raeli's Spell Announcer Utility Spells ----
------------------------------------------------
local RSA = LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local RSA_Racials = RSA:NewModule("Racials")

local MonitorConfig_Racials

function RSA_Racials:OnInitialize()
	RSA_Racials.CombatLogMonitor = CreateFrame("Frame", "RSA_Racials:CLM")
	RSA_Racials.CombatLogMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function RSA_Racials:OnEnable()
	RSA.db.profile.Modules.Racials = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	--[[
	-- Template
	local Config_RepairBots = { -- Repair Bots
		profile = 'Jeeves',
		comm = true, -- If we only want one person in the group to announce this.
		sourceIsMe = true, -- For personal utility spells like Rocket Boots, Trinkets etc.
		replacements = { SOURCE = 1 }
	}
	]]--
	local Config_ArcaneTorrent = { -- Blood Elf Arcane Torrent
		profile = 'ArcaneTorrent',
		section = "Cast",
	}
	local Config_GOTN = { -- Draenei Gift of the Naaru
		profile = 'GOTN',
		section = "Cast",
		replacements = { TARGET = 1 },
	}
	local Config_BloodFury = { -- Orc Blood Fury Start
		profile = 'BloodFury',
	}
	local Config_BloodFury_End = { -- Orc Blood Fury End
		profile = 'BloodFury',
		section = "End",
	}
	local Config_AncestralCall = { -- Mag'har Orc Ancestral Call Start
		profile = 'AncestralCall',
		linkID = 274738,
	}
	local Config_AncestralCall_End = { -- Mag'har Orc Ancestral Call End
		profile = 'AncestralCall',
		linkID = 274738,
		section = "End",
	}
	MonitorConfig_Racials = {
		player_profile = RSA.db.profile.Racials,
		SPELL_AURA_APPLIED = {
			[20572] = Config_BloodFury, -- Attack Power
			[33697] = Config_BloodFury, -- Intellect
			[33702] = Config_BloodFury, -- Both
			[274741] = Config_AncestralCall, -- Mastery
			[274742] = Config_AncestralCall, -- Versatility
			[274740] = Config_AncestralCall, -- Haste
			[274739] = Config_AncestralCall, -- Crit
			[20594] = { -- Dwarf
				profile = 'Stoneform',
			},
			[58984] = { -- Night Elf
				profile = 'Shadowmeld',
			},
			[68992] = { -- Worgen
				profile = 'Darkflight',
			},
			[26297] = { -- Troll
				profile = 'Berserking',
			},
			[265221] = { -- Dark Iron Dwarf
				profile = 'Fireblood',
			},
			[260364] = { -- Nightborne
				profile = 'ArcanePulse',
				tracker = 2,
			},
		},
		SPELL_AURA_REMOVED = {
			[20572] = Config_BloodFury_End, -- Attack Power
			[33697] = Config_BloodFury_End, -- Intellect
			[33702] = Config_BloodFury_End, -- Both
			[274741] = Config_AncestralCall_End, -- Mastery
			[274742] = Config_AncestralCall_End, -- Versatility
			[274740] = Config_AncestralCall_End, -- Haste
			[274739] = Config_AncestralCall_End, -- Crit
			[20594] = { -- Dwarf
				profile = 'Stoneform',
				section = "End",
			},
			[58984] = { -- Night Elf
				profile = 'Shadowmeld',
				section = "End",
			},
			[68992] = { -- Worgen
				profile = 'Darkflight',
				section = "End",
			},
			[26297] = { -- Troll
				profile = 'Berserking',
				section = "End",
			},
			[265221] = { -- Dark Iron Dwarf
				profile = 'Fireblood',
				section = "End",
			},
			[260364] = { -- Nightborne
				profile = 'ArcanePulse',
				section = "End",
				tracker = 1,
			},
			[274738] = { -- Mag'har Orc
				profile = 'AncestralCall',
				section = "End",
			},
		},
		SPELL_CAST_SUCCESS = {
			[28880] = Config_GOTN, -- Warrior
			[59542] = Config_GOTN, -- Paladin
			[59543] = Config_GOTN, -- Hunter
			[59544] = Config_GOTN, -- Priest
			[59545] = Config_GOTN, -- Death Knight
			[59547] = Config_GOTN, -- Shaman
			[59548] = Config_GOTN, -- Mage
			[121093] = Config_GOTN, -- Monk
			[25046] = Config_ArcaneTorrent, -- Rogue
			[28730] = Config_ArcaneTorrent, -- Warlock, Mage
			[50613] = Config_ArcaneTorrent, -- Death Knight
			[69179] = Config_ArcaneTorrent, -- Warrior
			[80483] = Config_ArcaneTorrent, -- Hunter
			[129597] = Config_ArcaneTorrent, -- Monk
			[155145] = Config_ArcaneTorrent, -- Paladin
			[202719] = Config_ArcaneTorrent, -- Demon Hunter
			[232633] = Config_ArcaneTorrent, -- Priest
			[59752] = { -- Human Every Man for Himself
				profile = 'EMFH',
				section = "Cast",
			},
			[20589] = { -- Gnome
				profile = 'EscapeArtist',
				section = "Cast",
			},
			[7744] = { -- Undead Will of the Forsaken
				profile = 'WOTF',
				section = "Cast",
			},
			[20549] = { -- Tauren
				profile = 'WarStomp',
				section = "Cast",
			},
			[69070] = { -- Goblin
				profile = 'RocketJump',
				section = "Cast",
			},
			[256948] = { -- Void Elf Spawning the rift
				profile = 'SpatialRift',
				section = "Placed",
			},
			[257040] = { -- Void Elf Teleporting to the rift
				profile = 'SpatialRift',
				section = "Cast",
			},
			[255654] = { -- Highmountain Tauren
				profile = 'BullRush',
				section = "Cast",
			},
		},
	}

	RSA.RacialMonitorConfig(MonitorConfig_Racials, UnitGUID("player"))

	local function Spells()
		if RSA.db.profile.Modules.Racials == false then return end
		local timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
		if RSA.AffiliationMine(sourceFlags) then
			RSA.MonitorAndAnnounce(self, "racials", timestamp, event, hideCaster, sourceGUID, source, sourceFlags, sourceRaidFlag, destGUID, dest, destFlags, destRaidFlags, spellID, spellName, spellSchool, missType, overheal, ex3, ex4, ex5, ex6, ex7, ex8)
		end
	end
	RSA_Racials.CombatLogMonitor:SetScript("OnEvent", Spells)
end

function RSA_Racials:OnDisable()
	RSA.db.profile.Modules.Racials = false
	RSA_Racials.CombatLogMonitor:SetScript("OnEvent", nil)
end
