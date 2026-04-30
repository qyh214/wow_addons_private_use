---@diagnostic disable: unused-function
---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
---@class Db
---@field SpecCache table<string, {SpecId: number?, LastSeen: number?, LastAttempt: number?}>
---@field TalentCache table<string, {SpecId: number, TalentString: string, Time: number}>
---@field PvPTalentCache table<string, {Ids: number[], Time: number}>
local dbDefaults = {
	Version = 44,
	Profiles = {},
	ActiveProfile = "Default",
	AutoSwitch = {},
	WhatsNew = {},
	NotifiedChanges = true,
	GlowType = "Proc Glow",
	FontScale = 1.0,
	IconSpacing = 2,
	ConfigureBlizzardNameplates = true,
	CCNativeOrder = false,
	DisableSwipe = false,
	MillisecondsThreshold = 5,
	LocaleOverride = false,
	Modules = {
		---@class CrowdControlModuleOptions
		CCModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = false,
				Dungeons = true,
				Raid = false,
			},

			---@class CrowdControlInstanceOptions
			Default = {
				ExcludePlayer = false,
				Offset = {
					X = 2,
					Y = 0,
				},
				Grow = "RIGHT",

				Icons = {
					Size = 32,
					Glow = true,
					ReverseCooldown = true,
					ColorByDispelType = true,
					Count = 3,
					ShowMilliseconds = false,
				},

				ShowTooltips = false,
			},

			---@type CrowdControlInstanceOptions
			Raid = {
				ExcludePlayer = false,
				Offset = {
					X = 2,
					Y = 0,
				},
				Grow = "CENTER",

				Icons = {
					Size = 20,
					Glow = true,
					ReverseCooldown = true,
					ColorByDispelType = true,
					Count = 3,
					ShowMilliseconds = false,
				},

				ShowTooltips = false,
			},
		},

		---@class PetCrowdControlModuleOptions
		PetCCModule = {
			Enabled = {
				World = false,
				Arena = false,
				BattleGrounds = false,
				Dungeons = false,
				Raid = false,
			},

			Grow = "CENTER",
			Offset = {
				X = 0,
				Y = 0,
			},

			Icons = {
				Size = 20,
				Count = 3,
				Glow = true,
				ReverseCooldown = true,
				ColorByDispelType = true,
			},

			ShowTooltips = false,
		},

		---@class HealerCrowdControlModuleOptions
		HealerCCModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = false,
				Dungeons = true,
				Raid = false,
			},

			Sound = {
				Enabled = true,
				Channel = "Master",
				File = "Sonar.ogg",
			},

			Point = "CENTER",
			RelativePoint = "TOP",
			RelativeTo = "UIParent",
			Offset = {
				X = 0,
				Y = -200,
			},

			Icons = {
				Enabled = true,
				Size = 50,
				Glow = true,
				ReverseCooldown = true,
				ColorByDispelType = true,
			},

			Font = {
				File = "Fonts\\FRIZQT__.TTF",
				Size = 32,
				Flags = "OUTLINE",
			},

			ShowWarningText = true,
			ShowTooltips = false,
		},
		---@class PortraitModuleOptions
		PortraitModule = {
			Enabled = {
				Always = true,
			},

			ReverseCooldown = true,
		},
		---@class AlertsModuleOptions
		AlertsModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = false,
				Dungeons = false,
				Raid = false,
			},

			IncludeDefensives = true,
			TargetFocusOnly = false,
			Point = "CENTER",
			RelativePoint = "TOP",
			RelativeTo = "UIParent",

			Offset = {
				X = 0,
				Y = -100,
			},

			Sound = {
				Important = {
					Enabled = false,
					Channel = "Master",
					File = "AirHorn.ogg",
				},
				Defensive = {
					Enabled = false,
					Channel = "Master",
					File = "AlertToastWarm.ogg",
				},
			},

			TTS = {
				Volume = 100,
				VoiceID = 0,
				SpeechRate = 0,
				Important = {
					Enabled = false,
				},
				Defensive = {
					Enabled = false,
				},
			},

			Icons = {
				Enabled = true,
				Size = 50,
				Glow = true,
				ReverseCooldown = true,
				ColorByClass = true,
				MaxIcons = 8,
			},

			ShowTooltips = false,
		},
		---@class NameplateModuleOptions
		NameplatesModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = true,
				Dungeons = true,
				Raid = true,
			},
			ScaleWithNameplate = true,

			---@class NameplateFactionOptions
			Friendly = {
				IgnorePets = true,
				---@class NameplateSpellTypeOptions
				CC = {
					Enabled = false,
					Grow = "RIGHT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
						ShowMilliseconds = false,
					},

					ShowTooltips = false,
				},
				Important = {
					Enabled = false,
					Grow = "LEFT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
					},

					ShowTooltips = false,
				},
				Combined = {
					Enabled = false,
					Grow = "RIGHT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
					},

					ShowTooltips = false,
				},
			},
			Enemy = {
				IgnorePets = true,
				CC = {
					Enabled = true,
					Grow = "RIGHT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
						ShowMilliseconds = false,
					},

					ShowTooltips = false,
				},
				Important = {
					Enabled = true,
					Grow = "LEFT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
					},

					ShowTooltips = false,
				},
				Combined = {
					Enabled = false,
					Grow = "RIGHT",
					Offset = {
						X = 0,
						Y = 0,
					},

					Icons = {
						Size = 35,
						Glow = true,
						ReverseCooldown = true,
						ColorByCategory = true,
						MaxIcons = 5,
					},

					ShowTooltips = false,
				},
			},
		},
		---@class KickTimerModuleOptions
		KickTimerModule = {
			Enabled = {
				Always = false,
				Caster = true,
				Healer = true,
			},

			Point = "CENTER",
			RelativeTo = "UIParent",
			RelativePoint = "CENTER",
			Offset = {
				X = 0,
				Y = -200,
			},

			Icons = {
				Size = 50,
				Glow = false,
				ReverseCooldown = true,
			},
		},
		-- keeping this just in case we need to revert back for some reason
		-- might remove it in a future release
		---@class TrinketsModuleOptions
		TrinketsModule = {
			Enabled = {
				Always = true,
			},

			ExcludePlayer = false,

			Point = "RIGHT",
			RelativePoint = "LEFT",
			Offset = {
				X = -2,
				Y = 0,
			},

			Icons = {
				Size = 40,
				Glow = false,
				ReverseCooldown = false,
				ShowText = true,
			},

			Font = {
				File = "GameFontHighlightSmall",
			},
		},
		---@class FriendlyIndicatorModuleOptions
		FriendlyIndicatorModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = true,
				Dungeons = true,
				Raid = false,
			},

			---@class FriendlyIndicatorInstanceOptions
			Default = {
				ExcludePlayer = false,
				ShowDefensives = true,
				ShowImportant = true,
				ShowCC = false,
				Offset = { X = 0, Y = 0 },
				Grow = "CENTER",
				Icons = {
					Size = 30,
					Glow = true,
					ReverseCooldown = true,
					MaxIcons = 1,
					ColorByDispelType = true,
				},
				ShowTooltips = false,
			},

			---@type FriendlyIndicatorInstanceOptions
			Raid = {
				ExcludePlayer = false,
				ShowDefensives = true,
				ShowImportant = true,
				ShowCC = true,
				Offset = { X = 0, Y = 0 },
				Grow = "CENTER",
				Icons = {
					Size = 25,
					Glow = true,
					ReverseCooldown = true,
					MaxIcons = 1,
					ColorByDispelType = true,
				},
				ShowTooltips = false,
			},
		},
		---@class FriendlyCooldownTrackerModuleOptions
		---@field DisabledSpells table<number, boolean> SpellIds excluded from the static-ability display; keyed by SpellId, value true. Treated as an opaque user hash - CleanTable must not recurse into it.
		FriendlyCooldownTrackerModule = {
			Enabled = {
				World = true,
				Arena = true,
				BattleGrounds = false,
				Dungeons = true,
				Raid = false,
			},
			DisabledSpells = {},

			---@class FriendlyCooldownTrackerAnchorOptions
			---@field IconSpacing number
			---@field Predictive boolean When true, icons glow and show a countdown while a buff is active before the cooldown timer is committed.
			Default = {
				Grow = "LEFT",
				Offset = { X = -2, Y = 0 },
				ExcludeSelf = false,
				ShowTooltips = true,
				ShowTrinket = true,
				Predictive = true,
				IconSpacing = 2,
				Icons = {
					Size = 40,
					ReverseCooldown = true,
					DesaturateOnCooldown = false,
					MaxIcons = 10,
					Rows = 1,
					Columns = 1,
				},
			},

			---@type FriendlyCooldownTrackerAnchorOptions
			Raid = {
				Grow = "CENTER",
				Offset = { X = -2, Y = 0 },
				ExcludeSelf = false,
				ShowTooltips = true,
				ShowTrinket = true,
				Predictive = true,
				IconSpacing = 2,
				Icons = {
					Size = 20,
					ReverseCooldown = true,
					DesaturateOnCooldown = false,
					MaxIcons = 5,
					Rows = 1,
					Columns = 1,
				},
			},
		},

		---@class EnemyCooldownTrackerModuleOptions
		---@field DisabledSpells table<number, boolean> SpellIds excluded from the display; keyed by SpellId, value true. Treated as an opaque user hash - CleanTable must not recurse into it.
		EnemyCooldownTrackerModule = {
			Enabled = {
				World = false,
				Arena = true,
				BattleGrounds = false,
				Dungeons = false,
				Raid = false,
			},

			DisabledSpells = {},

			DisplayMode  = "Linear",
			ShowTooltips = false,
			IconSpacing  = 2,
			EntrySpacing = 4,

			Icons = {
				Size            = 40,
				ReverseCooldown = true,
			},

			---@class EcdArenaFramesOptions
			ArenaFrames = {
				Grow   = "RIGHT",
				Offset = { X = 58, Y = 0 },
			},

			---@class EcdLinearOptions
			Linear = {
				Point         = "CENTER",
				RelativeTo    = "UIParent",
				RelativePoint = "CENTER",
				X             = 0,
				Y             = -100,
			},
		},

		---@class PrecogGuesserModuleOptions
		PrecogGuesserModule = {
			Enabled = {
				Always = true,
			},

			Point = "CENTER",
			RelativeTo = "UIParent",
			RelativePoint = "CENTER",
			Offset = {
				X = 0,
				Y = 70,
			},

			Icons = {
				Size = 70,
				Glow = true,
				ReverseCooldown = true,
			},
		},
	},
}

---@class DbMigrator
local M = {}
addon.Config.Migrator = M

function M:UpgradeToVersion1(vars)
	if vars.Version then
		return false
	end

	local v1Defaults = {
		Version = 1,

		SimpleMode = {
			Enabled = true,
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		AdvancedMode = {
			Enabled = false,
			Point = "TOPLEFT",
			RelativePoint = "TOPRIGHT",
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		---@class IconOptions
		Icons = {
			Size = 72,
			Padding = {
				X = 2,
				Y = 0,
			},
		},

		Container = {
			Point = "TOPLEFT",
			RelativePoint = "TOPRIGHT",
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		Anchor1 = "CompactPartyFrameMember1",
		Anchor2 = "CompactPartyFrameMember2",
		Anchor3 = "CompactPartyFrameMember3",
	}

	mini:CopyTable(v1Defaults, vars)
	vars.Version = 1

	return true
end

function M:UpgradeToVersion2(vars)
	-- allow nil vars.Version as the 1st version didn't have one
	if vars.Version ~= 1 then
		return false
	end

	vars.SimpleMode = vars.SimpleMode or {}
	vars.SimpleMode.Enabled = true
	vars.Version = 2

	return true
end

function M:UpgradeToVersion3(vars)
	if vars.Version ~= 2 then
		return false
	end

	-- made some strucure changes
	local v3Defaults = {
		Version = 3,

		SimpleMode = {
			Enabled = true,
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		AdvancedMode = {
			Point = "TOPLEFT",
			RelativePoint = "TOPRIGHT",
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		Icons = {
			Size = 72,
		},

		Container = {
			Point = "TOPLEFT",
			RelativePoint = "TOPRIGHT",
			Offset = {
				X = 2,
				Y = 0,
			},
		},

		Anchor1 = "CompactPartyFrameMember1",
		Anchor2 = "CompactPartyFrameMember2",
		Anchor3 = "CompactPartyFrameMember3",
	}

	mini:CleanTable(vars, v3Defaults, true, true)
	vars.Version = 3

	return true
end

function M:UpgradeToVersion4(vars)
	if vars.Version ~= 3 then
		return false
	end

	vars.Arena = {
		SimpleMode = mini:CopyTable(vars.SimpleMode),
		AdvancedMode = mini:CopyTable(vars.AdvancedMode),
		Icons = mini:CopyTable(vars.Icons),
		Enabled = true,
		ExcludePlayer = vars.ExcludePlayer,
	}

	vars.BattleGrounds = {
		SimpleMode = mini:CopyTable(vars.SimpleMode),
		AdvancedMode = mini:CopyTable(vars.AdvancedMode),
		Icons = mini:CopyTable(vars.Icons),
		Enabled = not vars.ArenaOnly,
		ExcludePlayer = vars.ExcludePlayer,
	}

	vars.Default = {
		SimpleMode = mini:CopyTable(vars.SimpleMode),
		AdvancedMode = mini:CopyTable(vars.AdvancedMode),
		Icons = mini:CopyTable(vars.Icons),
		Enabled = not vars.ArenaOnly,
		ExcludePlayer = vars.ExcludePlayer,
	}

	local v4Defaults = {
		Version = 4,

		ArenaOnly = false,
		ExcludePlayer = false,

		Arena = {
			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			---@class IconOptions
			Icons = {
				Size = 72,
				Glow = true,
			},
		},

		BattleGrounds = {
			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			Icons = {
				Size = 72,
				Glow = true,
			},
		},

		Anchor1 = "CompactPartyFrameMember1",
		Anchor2 = "CompactPartyFrameMember2",
		Anchor3 = "CompactPartyFrameMember3",
	}

	mini:CleanTable(vars, v4Defaults, true, true)
	vars.Version = 4

	return true
end

function M:UpgradeToVersion5(vars)
	if vars.Version ~= 4 then
		return false
	end

	vars.Raid = vars.BattleGrounds
	vars.BattleGrounds = nil

	vars.Default = vars.Arena
	vars.Arena = nil

	local v5Defaults = {
		Version = 5,

		---@class InstanceOptions
		Default = {
			Enabled = true,
			ExcludePlayer = false,

			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			---@class IconOptions
			Icons = {
				Size = 72,
				Glow = true,
			},
		},

		Raid = {
			Enabled = true,
			ExcludePlayer = false,

			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			Icons = {
				Size = 72,
				Glow = true,
			},
		},

		Anchor1 = "CompactPartyFrameMember1",
		Anchor2 = "CompactPartyFrameMember2",
		Anchor3 = "CompactPartyFrameMember3",
	}
	mini:CleanTable(vars, v5Defaults, true, true)
	vars.Version = 5

	return true
end

function M:UpgradeToVersion6(vars)
	if vars.Version ~= 5 then
		return false
	end

	if vars.Anchor1 == "CompactPartyFrameMember1" then
		vars.Anchor1 = ""
	end
	if vars.Anchor2 == "CompactPartyFrameMember2" then
		vars.Anchor2 = ""
	end
	if vars.Anchor3 == "CompactPartyFrameMember3" then
		vars.Anchor3 = ""
	end

	vars.NotifiedChanges = false
	vars.Version = 6

	return true
end

function M:UpgradeToVersion7(vars)
	if vars.Version ~= 6 then
		return false
	end

	vars.NotifiedChanges = false
	vars.Version = 7

	return true
end

function M:UpgradeToVersion8(vars)
	if vars.Version ~= 7 then
		return false
	end

	vars.NotifiedChanges = false
	vars.Version = 8

	return true
end

function M:UpgradeToVersion9(vars)
	if vars.Version ~= 8 then
		return false
	end

	vars.NotifiedChanges = false
	vars.WhatsNew = vars.WhatsNew or {}
	table.insert(vars.WhatsNew, " - New spell alerts bar that shows enemy cooldowns.")
	vars.Version = 9

	return true
end

function M:UpgradeToVersion10(vars)
	if vars.Version ~= 9 then
		return false
	end

	vars.WhatsNew = vars.WhatsNew or {}
	table.insert(vars.WhatsNew, " - New feature to show enemy cooldowns on nameplates.")
	vars.NotifiedChanges = false
	vars.Version = 10

	return true
end

function M:UpgradeToVersion11(vars)
	if vars.Version ~= 10 then
		return false
	end

	-- they may not have the nameplates table yet if upgrading from say v8
	if vars.Nameplates then
		vars.Nameplates.FriendlyEnabled = vars.Nameplates.Enabled
		vars.Nameplates.EnemyEnabled = vars.Nameplates.Enabled
	end
	vars.Version = 11

	return true
end

function M:UpgradeToVersion12(vars)
	if vars.Version ~= 11 then
		return false
	end

	local v12Defaults = {
		Version = 12,
		WhatsNew = {},

		NotifiedChanges = true,

		Default = {
			Enabled = true,
			ExcludePlayer = false,

			-- TODO: after a few patches once people have moved over, remove simple/advanced mode into just one single mode
			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
				Grow = "RIGHT",
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			Icons = {
				Size = 50,
				Glow = true,
				ReverseCooldown = true,
				ColorByDispelType = true,
			},
		},

		Raid = {
			Enabled = true,
			ExcludePlayer = false,

			SimpleMode = {
				Enabled = true,
				Offset = {
					X = 2,
					Y = 0,
				},
				Grow = "CENTER",
			},

			AdvancedMode = {
				Point = "TOPLEFT",
				RelativePoint = "TOPRIGHT",
				Offset = {
					X = 2,
					Y = 0,
				},
			},

			Icons = {
				Size = 50,
				Glow = true,
				ReverseCooldown = true,
				ColorByDispelType = true,
			},
		},

		Healer = {
			Enabled = false,
			Sound = {
				Enabled = true,
				Channel = "Master",
			},

			Point = "CENTER",
			RelativePoint = "TOP",
			RelativeTo = "UIParent",
			Offset = {
				X = 0,
				Y = -200,
			},

			Icons = {
				Size = 72,
				Glow = true,
				ReverseCooldown = true,
				ColorByDispelType = true,
			},

			Filters = {
				Arena = true,
				BattleGrounds = false,
				World = true,
			},

			Font = {
				File = "Fonts\\FRIZQT__.TTF",
				Size = 32,
				Flags = "OUTLINE",
			},
		},

		Alerts = {
			Enabled = true,
			Point = "CENTER",
			RelativePoint = "TOP",
			RelativeTo = "UIParent",

			Offset = {
				X = 0,
				Y = -100,
			},

			Icons = {
				Size = 72,
				Glow = true,
				ReverseCooldown = true,
			},
		},

		Nameplates = {
			Friendly = {
				CC = {
					Enabled = true,
					Grow = "RIGHT",
					Offset = {
						X = 2,
						Y = 0,
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
						MaxIcons = 5,
					},
				},
				Important = {
					Enabled = true,
					Grow = "LEFT",
					Offset = {
						X = 2,
						Y = 0,
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
						MaxIcons = 5,
					},
				},
			},
			Enemy = {
				CC = {
					Enabled = true,
					Grow = "RIGHT",
					Offset = {
						X = 2,
						Y = 0,
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
						MaxIcons = 5,
					},
				},
				Important = {
					Enabled = true,
					Grow = "LEFT",
					Offset = {
						X = 2,
						Y = 0,
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
						MaxIcons = 5,
					},
				},
			},
		},

		Portrait = {
			Enabled = true,
			ReverseCooldown = true,
		},

		Anchor1 = "",
		Anchor2 = "",
		Anchor3 = "",
	}

	-- get the new nameplate config
	vars = mini:GetSavedVars(v12Defaults)

	-- db defaults may have changed since then
	if vars.Nameplates and vars.Nameplates.Friendly and vars.Nameplates.Enemy then
		vars.Nameplates.Friendly.CC.Enabled = vars.Nameplates.FriendlyEnabled
		vars.Nameplates.Friendly.Important.Enabled = vars.Nameplates.FriendlyEnabled

		vars.Nameplates.Enemy.CC.Enabled = vars.Nameplates.EnemyEnabled
		vars.Nameplates.Enemy.Important.Enabled = vars.Nameplates.EnemyEnabled
	end

	table.insert(vars.WhatsNew, " - Separated CC and important spell positions on nameplates.")
	vars.NotifiedChanges = false

	-- clean up old values
	mini:CleanTable(vars, v12Defaults, true, true)
	vars.Version = 12

	return true
end

function M:UpgradeToVersion13(vars)
	if vars.Version ~= 12 then
		return false
	end

	table.insert(vars.WhatsNew, " - New poor man's kick timer (don't get too excited, it's really basic).")
	table.insert(vars.WhatsNew, " - Various bug fixes and performance improvements.")
	vars.NotifiedChanges = false
	vars.Version = 13

	return true
end

function M:UpgradeToVersion14(vars)
	if vars.Version ~= 13 then
		return false
	end

	table.insert(vars.WhatsNew, " - Added pet portrait CC icon.")
	vars.NotifiedChanges = false
	vars.Version = 14

	return true
end

function M:UpgradeToVersion15(vars)
	if vars.Version ~= 14 then
		return false
	end

	table.insert(vars.WhatsNew, " - Improved kick detection logic (can now detect who kicked you).")
	table.insert(vars.WhatsNew, " - Added party trinkets tracker.")
	table.insert(vars.WhatsNew, " - Added Shadowed Unit Frames and Plexus frames support.")
	table.insert(vars.WhatsNew, " - Improved addon performance.")
	vars.NotifiedChanges = false
	vars.Version = 15

	return true
end

function M:UpgradeToVersion16(vars)
	if vars.Version ~= 15 then
		return false
	end

	table.insert(vars.WhatsNew, " - New ally CDs frame that shows active defensives and offensive cooldowns.")
	vars.NotifiedChanges = false
	vars.Version = 16

	return true
end

function M:UpgradeToVersion17(vars)
	if vars.Version ~= 16 then
		return false
	end

	table.insert(vars.WhatsNew, " - Added option to color alert glows by enemy class color (enabled by default).")
	vars.NotifiedChanges = false
	vars.Version = 17

	return true
end

function M:UpgradeToVersion18(vars)
	if vars.Version ~= 17 then
		return false
	end

	-- commence massive refactor
	-- Move Default and Raid configs into Modules.CCModule
	if vars.Default then
		vars.Modules = vars.Modules or {}
		vars.Modules.CCModule = vars.Modules.CCModule or {}
		vars.Modules.CCModule.Default = mini:CopyTable(vars.Default)
		vars.Modules.CCModule.Enabled = {
			Always = vars.Default.Enabled,
			Arena = vars.Default.Enabled,
			Raids = vars.Raid and vars.Raid.Enabled,
			Dungeons = vars.Raid and vars.Raid.Enabled,
		}
		vars.Modules.CCModule.Default.Grow = vars.Default.SimpleMode.Grow
		vars.Modules.CCModule.Default.Offset = mini:CopyTable(vars.Default.SimpleMode.Offset)
		vars.Default = nil
	end

	if vars.Raid then
		vars.Modules = vars.Modules or {}
		vars.Modules.CCModule = vars.Modules.CCModule or {}
		vars.Modules.CCModule.Raid = mini:CopyTable(vars.Raid)
		vars.Modules.CCModule.Raid.Grow = vars.Raid.SimpleMode.Grow
		vars.Modules.CCModule.Raid.Offset = mini:CopyTable(vars.Raid.SimpleMode.Offset)
		vars.Raid = nil
	end

	-- Move AllyIndicator config into Modules.AllyIndicatorModule
	if vars.AllyIndicator then
		vars.Modules = vars.Modules or {}
		vars.Modules.FriendlyIndicatorModule = vars.Modules.FriendlyIndicatorModule or {}

		-- Merge AllyIndicator properties directly into AllyIndicatorModule
		for key, value in pairs(vars.AllyIndicator) do
			vars.Modules.FriendlyIndicatorModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.FriendlyIndicatorModule.Enabled = {
			Always = vars.AllyIndicator.Enabled,
			Arena = false,
			Raids = false,
			Dungeons = false,
		}
		vars.AllyIndicator = nil
	end

	-- Move Healer config into Modules.HealerCCModule
	if vars.Healer then
		vars.Modules = vars.Modules or {}
		vars.Modules.HealerCCModule = vars.Modules.HealerCCModule or {}

		-- Merge Healer properties directly into HealerCCModule
		for key, value in pairs(vars.Healer) do
			vars.Modules.HealerCCModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.HealerCCModule.Enabled = {
			Always = vars.Healer.Enabled,
			Arena = vars.Healer.Filters.Arena,
			Raids = vars.Healer.BattleGrounds,
			Dungeons = vars.Healer.Enabled,
		}

		vars.Healer = nil
	end

	-- Move Alerts config into Modules.AlertsModule
	if vars.Alerts then
		vars.Modules = vars.Modules or {}
		vars.Modules.AlertsModule = vars.Modules.AlertsModule or {}

		-- Merge Alerts properties directly into AlertsModule
		for key, value in pairs(vars.Alerts) do
			vars.Modules.AlertsModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.AlertsModule.Enabled = {
			Always = vars.Alerts.Enabled,
		}
		vars.Alerts = nil
	end

	-- Move Portrait config into Modules.PortraitModule
	if vars.Portrait then
		vars.Modules = vars.Modules or {}
		vars.Modules.PortraitModule = vars.Modules.PortraitModule or {}

		-- Merge Portrait properties directly into PortraitModule
		for key, value in pairs(vars.Portrait) do
			vars.Modules.PortraitModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.PortraitModule.Enabled = {
			Always = vars.Portrait.Enabled,
		}
		vars.Portrait = nil
	end

	-- Move Nameplates config into Modules.NameplatesModule
	if vars.Nameplates then
		vars.Modules = vars.Modules or {}
		vars.Modules.NameplatesModule = vars.Modules.NameplatesModule or {}

		-- Merge Nameplates properties directly into NameplatesModule
		for key, value in pairs(vars.Nameplates) do
			vars.Modules.NameplatesModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.NameplatesModule.Enabled = {
			Always = true,
		}
		vars.Nameplates = nil
	end

	-- Move KickTimer config into Modules.KickTimerModule
	if vars.KickTimer then
		vars.Modules = vars.Modules or {}
		vars.Modules.KickTimerModule = vars.Modules.KickTimerModule or {}

		-- Merge KickTimer properties directly into KickTimerModule
		for key, value in pairs(vars.KickTimer) do
			vars.Modules.KickTimerModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.KickTimerModule.Enabled = {
			Always = vars.KickTimer.AllEnabled,
			Caster = vars.KickTimer.CasterEnabled,
			Healer = vars.KickTimer.HealerEnabled,
		}
		vars.KickTimer = nil
	end

	-- Move Trinkets config into Modules.TrinketsModule
	if vars.Trinkets then
		vars.Modules = vars.Modules or {}
		vars.Modules.TrinketsModule = vars.Modules.TrinketsModule or {}

		-- Merge Trinkets properties directly into TrinketsModule
		for key, value in pairs(vars.Trinkets) do
			vars.Modules.TrinketsModule[key] = mini:CopyValueOrTable(value)
		end

		vars.Modules.TrinketsModule.Enabled = { Always = vars.Trinkets.Enabled }
		vars.Trinkets = nil
	end

	local v18Defaults = {
		Version = 25,
		WhatsNew = {},
		NotifiedChanges = true,
		Modules = {
			CcModule = {
				Enabled = {
					Always = true,
					Arena = false,
					Raids = false,
					Dungeons = false,
				},
				Default = {
					ExcludePlayer = false,

					-- TODO: after a few patches once people have moved over, remove simple/advanced mode into just one single mode
					SimpleMode = {
						Enabled = true,
						Offset = {
							X = 2,
							Y = 0,
						},
						Grow = "RIGHT",
					},

					AdvancedMode = {
						Point = "TOPLEFT",
						RelativePoint = "TOPRIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
					},
				},
				Raid = {
					ExcludePlayer = false,

					SimpleMode = {
						Enabled = true,
						Offset = {
							X = 2,
							Y = 0,
						},
						Grow = "CENTER",
					},

					AdvancedMode = {
						Point = "TOPLEFT",
						RelativePoint = "TOPRIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},
					},

					Icons = {
						Size = 50,
						Glow = true,
						ReverseCooldown = true,
						ColorByDispelType = true,
					},
				},
			},
			HealerCcModule = {
				Enabled = {
					Always = true,
					Arena = false,
					Raids = false,
					Dungeons = false,
				},

				Sound = {
					Enabled = true,
					Channel = "Master",
				},

				Point = "CENTER",
				RelativePoint = "TOP",
				RelativeTo = "UIParent",
				Offset = {
					X = 0,
					Y = -200,
				},

				Icons = {
					Size = 72,
					Glow = true,
					ReverseCooldown = true,
					ColorByDispelType = true,
				},

				Font = {
					File = "Fonts\\FRIZQT__.TTF",
					Size = 32,
					Flags = "OUTLINE",
				},
			},
			PortraitModule = {
				Enabled = {
					Always = true,
				},

				ReverseCooldown = true,
			},
			AlertsModule = {
				Enabled = {
					Always = true,
				},

				IncludeDefensives = true,
				Point = "CENTER",
				RelativePoint = "TOP",
				RelativeTo = "UIParent",

				Offset = {
					X = 0,
					Y = -100,
				},

				Icons = {
					Size = 72,
					Glow = true,
					ReverseCooldown = true,
					ColorByClass = true,
				},
			},
			NameplatesModule = {
				Enabled = {
					Always = true,
					Arena = false,
					Raids = false,
					Dungeons = false,
				},

				Friendly = {
					IgnorePets = true,
					CC = {
						Enabled = false,
						Grow = "RIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ReverseCooldown = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
					Important = {
						Enabled = false,
						Grow = "LEFT",
						Offset = {
							X = -2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ReverseCooldown = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
					Combined = {
						Enabled = false,
						Grow = "RIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ReverseCooldown = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
				},
				Enemy = {
					IgnorePets = true,
					CC = {
						Enabled = true,
						Grow = "RIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ReverseCooldown = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
					Important = {
						Enabled = true,
						Grow = "LEFT",
						Offset = {
							X = -2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
					Combined = {
						Enabled = false,
						Grow = "RIGHT",
						Offset = {
							X = 2,
							Y = 0,
						},

						Icons = {
							Size = 50,
							Glow = true,
							ReverseCooldown = true,
							ColorByDispelType = true,
							MaxIcons = 5,
						},
					},
				},
			},
			KickTimerModule = {
				Enabled = {
					Always = false,
					Caster = true,
					Healer = true,
				},

				Point = "CENTER",
				RelativeTo = "UIParent",
				RelativePoint = "CENTER",
				Offset = {
					X = 0,
					Y = -200,
				},

				Icons = {
					Size = 50,
					Glow = false,
					ReverseCooldown = true,
				},
			},
			TrinketsModule = {
				Enabled = {
					Always = true,
				},

				Point = "RIGHT",
				RelativePoint = "LEFT",
				Offset = {
					X = -2,
					Y = 0,
				},

				Icons = {
					Size = 50,
					Glow = false,
					ReverseCooldown = false,
					ShowText = true,
				},

				Font = {
					File = "GameFontHighlightSmall",
				},
			},
			FriendlyIndicatorModule = {
				Enabled = {
					Always = true,
					Arena = false,
					Raids = false,
					Dungeons = false,
				},

				ExcludePlayer = false,

				Offset = {
					X = 0,
					Y = 0,
				},
				Grow = "CENTER",

				Icons = {
					Size = 40,
					Glow = true,
					ReverseCooldown = true,
				},
			},
		},
	}

	mini:CleanTable(vars, v18Defaults, true, true)
	vars.Version = 18

	return true
end

function M:UpgradeToVersion19(vars)
	if vars.Version ~= 18 then
		return false
	end

	-- Rename CcModule to CCModule
	if vars.Modules and vars.Modules.CcModule then
		vars.Modules.CCModule = vars.Modules.CcModule
		vars.Modules.CcModule = nil
	end

	-- Rename HealerCcModule to HealerCCModule
	if vars.Modules and vars.Modules.HealerCcModule then
		vars.Modules.HealerCCModule = vars.Modules.HealerCcModule
		vars.Modules.HealerCcModule = nil
	end

	vars.Version = 19
	return true
end

function M:UpgradeToVersion20(vars)
	if vars.Version ~= 19 then
		return false
	end

	-- accident, update db migration to the same value as db defaults
	vars.Version = 20
	return true
end

function M:UpgradeToVersion21(vars)
	if vars.Version ~= 20 then
		return false
	end

	-- removed this glow type as it doesn't support secrets
	if vars.GlowType == "Action Button Glow" then
		vars.GlowType = "Proc Glow"
	end

	vars.Version = 21
	return true
end

function M:UpgradeToVersion22(vars)
	if vars.Version ~= 21 then
		return false
	end

	-- Add ShowWarningText option to HealerCCModule (default on)
	if vars.Modules and vars.Modules.HealerCCModule then
		vars.Modules.HealerCCModule.ShowWarningText = true
	end

	vars.Version = 22
	return true
end

function M:UpgradeToVersion23(vars)
	if vars.Version ~= 22 then
		return false
	end

	vars.Modules.AlertsModule.Sound = {
		Important = {
			Enabled = false,
			Channel = "Master",
			File = "AirHorn.ogg",
		},
		Defensive = {
			Enabled = false,
			Channel = "Master",
			File = "AlertToastWarm.ogg",
		},
	}

	vars.Modules.AlertsModule.TTS = {
		Volume = 100,
		Important = {
			Enabled = false,
		},
		Defensive = {
			Enabled = false,
		},
	}

	-- might as well clean up any garbage while we're here
	-- do this before we add stuff to what's new otherwise it'll get cleared
	mini:CleanTable(vars, dbDefaults, true, true)

	table.insert(vars.WhatsNew, " - Added important and defensive alert sound effects.")
	table.insert(vars.WhatsNew, " - Added text to speech functionality in the alerts module (i.e. GladiatorlosSA).")

	vars.NotifiedChanges = false
	vars.Version = 23
	return true
end

function M:UpgradeToVersion24(vars)
	if vars.Version ~= 23 then
		return false
	end

	vars.Modules.PrecogGuesserModule = {
		Enabled = {
			Always = true,
		},

		Point = "CENTER",
		RelativeTo = "UIParent",
		RelativePoint = "CENTER",
		Offset = {
			X = 0,
			Y = 70,
		},

		Icons = {
			Size = 70,
			Glow = true,
			ReverseCooldown = true,
		},
	}

	vars.Modules.PetCCModule = {
		Enabled = {
			Always = false,
			Arena = false,
			Raids = false,
			Dungeons = false,
		},

		Grow = "CENTER",
		Offset = {
			X = 0,
			Y = 0,
		},

		Icons = {
			Size = 30,
			Count = 3,
			Glow = true,
			ReverseCooldown = true,
			ColorByDispelType = true,
		},
	}

	table.insert(vars.WhatsNew, L[" - Added CC icons on pet party/raid frames (disabled by default)."])
	table.insert(vars.WhatsNew, L[" - Added precognition guesser module that shows when you get precog."])
	table.insert(vars.WhatsNew, L[" - Added profile import/export feature."])

	vars.NotifiedChanges = false
	vars.Version = 24
	return true
end

function M:UpgradeToVersion25(vars)
	if vars.Version ~= 24 then
		return false
	end

	-- Rename Raids->BattleGrounds and Dungeons->PvE in all module Enabled tables
	if vars.Modules then
		local modules = {
			"CCModule",
			"PetCCModule",
			"HealerCCModule",
			"AlertsModule",
			"NameplatesModule",
			"FriendlyIndicatorModule",
		}
		for _, moduleName in ipairs(modules) do
			local m = vars.Modules[moduleName]
			if m and m.Enabled then
				if m.Enabled.Raids ~= nil then
					m.Enabled.BattleGrounds = m.Enabled.Raids
					m.Enabled.Raids = nil
				end
				if m.Enabled.Dungeons ~= nil then
					m.Enabled.PvE = m.Enabled.Dungeons
					m.Enabled.Dungeons = nil
				end
			end
		end
	end

	vars.Version = 25
	return true
end

function M:UpgradeToVersion26(vars)
	if vars.Version ~= 25 then
		return false
	end

	-- CC module now uses SetIgnoreParentScale(true), so saved icon sizes need to be
	-- scaled up by UIParent:GetScale(). That value isn't reliable at load time (returns 1),
	-- so set a flag and apply it later via RunDeferredMigrations on PLAYER_LOGIN.
	vars.PendingScaleMigration26 = true

	vars.Version = 26
	return true
end

function M:UpgradeToVersion27(vars)
	if vars.Version ~= 26 then
		return false
	end

	-- Rename Always->World in location-based modules.
	-- If Always was true, it acted as an override for all contexts, so enable all of them.
	if vars.Modules then
		local modules = {
			"CCModule",
			"PetCCModule",
			"HealerCCModule",
			"AlertsModule",
			"NameplatesModule",
			"FriendlyIndicatorModule",
		}
		for _, moduleName in ipairs(modules) do
			local m = vars.Modules[moduleName]
			if m and m.Enabled and m.Enabled.Always ~= nil then
				if m.Enabled.Always == true then
					m.Enabled.World = true
					m.Enabled.Arena = true
					m.Enabled.BattleGrounds = true
					m.Enabled.PvE = true
				else
					m.Enabled.World = false
				end
				m.Enabled.Always = nil
			end
		end
	end

	vars.Version = 27
	return true
end

function M:UpgradeToVersion28(vars)
	if vars.Version ~= 27 then
		return false
	end

	-- Add MaxIcons to AlertsModule.Icons
	if vars.Modules and vars.Modules.AlertsModule and vars.Modules.AlertsModule.Icons then
		vars.Modules.AlertsModule.Icons.MaxIcons = 8
	end

	vars.Version = 28
	return true
end

function M:UpgradeToVersion29(vars)
	if vars.Version ~= 28 then
		return false
	end

	-- Add ShowCC and ColorByDispelType to FriendlyIndicatorModule
	if vars.Modules and vars.Modules.FriendlyIndicatorModule then
		local fi = vars.Modules.FriendlyIndicatorModule
		fi.ShowCC = false
		if fi.Icons then
			fi.Icons.ColorByDispelType = true
		end
	end

	vars.Version = 29
	return true
end

function M:UpgradeToVersion30(vars)
	if vars.Version ~= 29 then
		return false
	end

	if vars.Modules and vars.Modules.FriendlyIndicatorModule then
		local fi = vars.Modules.FriendlyIndicatorModule

		local instanceSettings = {
			ExcludePlayer = fi.ExcludePlayer,
			ShowDefensives = fi.ShowDefensives,
			ShowImportant = fi.ShowImportant,
			ShowCC = fi.ShowCC,
			Offset = fi.Offset and mini:CopyTable(fi.Offset) or { X = 0, Y = 0 },
			Grow = fi.Grow,
			Icons = fi.Icons and mini:CopyTable(fi.Icons) or nil,
		}

		-- Write into the existing table shells so upvalue references captured by
		-- Config UI closures during Build() remain valid after a profile import.
		local function MergeInPlace(target, src)
			for key, value in pairs(src) do
				if type(value) == "table" then
					target[key] = target[key] or {}
					for subKey, subValue in pairs(value) do
						target[key][subKey] = subValue
					end
				else
					target[key] = value
				end
			end
		end

		fi.Default = fi.Default or {}
		MergeInPlace(fi.Default, instanceSettings)

		fi.Raid = fi.Raid or {}
		MergeInPlace(fi.Raid, instanceSettings)
		fi.Raid.ShowCC = true

		-- nil old flat values that are no longer used
		fi.ExcludePlayer = nil
		fi.ShowDefensives = nil
		fi.ShowImportant = nil
		fi.ShowCC = nil
		fi.Offset = nil
		fi.Grow = nil
		fi.Icons = nil
	end

	vars.Version = 30
	return true
end

function M:UpgradeToVersion31(vars)
	if vars.Version ~= 30 then
		return false
	end

	-- Add ScaleWithNameplate to NameplatesModule. Existing installs default to false
	-- to preserve their current behaviour (icons were previously not scaling with the nameplate).
	if vars.Modules and vars.Modules.NameplatesModule then
		vars.Modules.NameplatesModule.ScaleWithNameplate = false
	end

	vars.Version = 31
	return true
end

function M:UpgradeToVersion32(vars)
	if vars.Version ~= 31 then
		return false
	end

	-- Rename IncludeBigDefensives to IncludeDefensives in AlertsModule
	if vars.Modules and vars.Modules.AlertsModule then
		local am = vars.Modules.AlertsModule
		if am.IncludeBigDefensives ~= nil then
			am.IncludeDefensives = am.IncludeBigDefensives
			am.IncludeBigDefensives = nil
		end
	end

	vars.Version = 32
	return true
end

function M:UpgradeToVersion33(vars)
	if vars.Version ~= 32 then
		return false
	end

	-- If the CC module is enabled in battlegrounds AND the friendly indicator is also
	-- showing CC icons for groups greater than 5 members, disable the latter to avoid
	-- both modules displaying CC icons simultaneously in battlegrounds.
	-- this is to fix a migration where the CC module used to be enabled "always"
	-- and Show CC is defaulted to true for the indicator module in bgs, which would result in both modules showing CC icons in bgs after the migration
	local mods = vars.Modules
	if mods and mods.CCModule and mods.FriendlyIndicatorModule then
		local ccEnabledBGs = mods.CCModule.Enabled and mods.CCModule.Enabled.BattleGrounds
		local fiRaidShowCC = mods.FriendlyIndicatorModule.Raid and mods.FriendlyIndicatorModule.Raid.ShowCC
		if ccEnabledBGs and fiRaidShowCC then
			mods.FriendlyIndicatorModule.Raid.ShowCC = false
		end
	end

	vars.Version = 33
	return true
end

function M:UpgradeToVersion34(vars)
	if vars.Version ~= 33 then
		return false
	end

	table.insert(vars.WhatsNew, L[" - Added friendly cooldown guessing module. You can now somewhat track your team mates cooldowns!"])

	vars.NotifiedChanges = false
	vars.Version = 34
	return true
end

function M:UpgradeToVersion35(vars)
	if vars.Version ~= 34 then
		return false
	end

	-- Split PvE into Dungeons + Raid for all modules
	local moduleNames = {
		"CCModule", "PetCCModule", "HealerCCModule",
		"AlertsModule", "NameplatesModule", "FriendlyIndicatorModule",
		"FriendlyCooldownTrackerModule",
	}
	if vars.Modules then
		for _, moduleName in ipairs(moduleNames) do
			local m = vars.Modules[moduleName]
			if m and m.Enabled and m.Enabled.PvE ~= nil then
				m.Enabled.Dungeons = m.Enabled.PvE
				m.Enabled.Raid = m.Enabled.PvE
				m.Enabled.PvE = nil
			end
		end
	end

	vars.Version = 35
	return true
end

function M:UpgradeToVersion36(vars)
	if vars.Version ~= 35 then
		return false
	end

	local fcdModule = vars.Modules and vars.Modules.FriendlyCooldownTrackerModule
	if fcdModule then
		local spacing = vars.IconSpacing or 2
		if fcdModule.Default then
			fcdModule.Default.IconSpacing = spacing
		end
		if fcdModule.Raid then
			fcdModule.Raid.IconSpacing = spacing
		end
	end

	vars.Version = 36
	return true
end

function M:UpgradeToVersion37(vars)
	if vars.Version ~= 36 then return false end

	vars.Profiles = vars.Profiles or {}
	vars.ActiveProfile = vars.ActiveProfile or "Default"
	vars.AutoSwitch = vars.AutoSwitch or {}

	-- Snapshot the current settings into the "Default" profile slot so existing
	-- users don't lose their configuration after upgrading.
	if not vars.Profiles["Default"] then
		local payloadKeys = addon.Core.ProfileManager.PayloadKeys
		local snapshot = {}
		for _, k in ipairs(payloadKeys) do
			if vars[k] ~= nil then
				snapshot[k] = mini:CopyValueOrTable(vars[k])
			end
		end
		vars.Profiles["Default"] = snapshot
	end

	vars.Version = 37
	return true
end

function M:UpgradeToVersion38(vars)
	if vars.Version ~= 37 then return false end

	-- Add ShowTooltips to each NameplateSpellTypeOptions section. Existing installs default to true.
	if vars.Modules and vars.Modules.NameplatesModule then
		local nm = vars.Modules.NameplatesModule
		for _, faction in ipairs({ nm.Friendly, nm.Enemy }) do
			if faction then
				for _, section in ipairs({ faction.CC, faction.Important, faction.Combined }) do
					if section and section.ShowTooltips == nil then
						section.ShowTooltips = false
					end
				end
			end
		end
	end

	vars.Version = 38
	return true
end

function M:UpgradeToVersion39(vars)
	if vars.Version ~= 38 then return false end

	table.insert(vars.WhatsNew, L["HEADS UP: Blizzard is making changes in patch 12.0.5 (April 21st) that will severely reduce the accuracy of friendly CD tracking, kill cooldown glow on press, and completely remove PvP enemy kick tracking. So please be aware that tracking will lose accuracy soon."])

	vars.NotifiedChanges = false
	vars.Version = 39
	return true
end

function M:UpgradeToVersion40(vars)
	if vars.Version ~= 39 then return false end

	-- Rename "夏一可.ogg" -> "XiaYike.ogg" in the three known Sound.File locations.
	local function RenameSound(modules)
		if not modules then return end

		local healer = modules.HealerCCModule
		if healer and healer.Sound and healer.Sound.File == "夏一可.ogg" then
			healer.Sound.File = "XiaYike.ogg"
		end

		local alerts = modules.AlertsModule
		if alerts and alerts.Sound then
			if alerts.Sound.Important and alerts.Sound.Important.File == "夏一可.ogg" then
				alerts.Sound.Important.File = "XiaYike.ogg"
			end
			if alerts.Sound.Defensive and alerts.Sound.Defensive.File == "夏一可.ogg" then
				alerts.Sound.Defensive.File = "XiaYike.ogg"
			end
		end
	end

	RenameSound(vars.Modules)

	if vars.Profiles then
		for _, profile in pairs(vars.Profiles) do
			RenameSound(profile.Modules)
		end
	end

	vars.Version = 40
	return true
end

function M:UpgradeToVersion41(vars)
	if vars.Version ~= 40 then return false end

	-- Add DisabledSpells to EnemyCooldownTrackerModule (new spell-filter feature).
	-- DisabledSpells is an opaque user hash; initialise to empty for existing installs.
	local ecd = vars.Modules and vars.Modules.EnemyCooldownTrackerModule
	if ecd and ecd.DisabledSpells == nil then
		ecd.DisabledSpells = {}
	end

	vars.Version = 41
	return true
end

function M:UpgradeToVersion42(vars)
	if vars.Version ~= 41 then return false end

	vars.Version = 42
	return true
end

function M:UpgradeToVersion43(vars)
	if vars.Version ~= 42 then return false end

	vars.WhatsNew = vars.WhatsNew or {}
	table.insert(vars.WhatsNew, L[" - Added enemy cooldown tracking module."])
	vars.NotifiedChanges = false

	vars.Version = 43
	return true
end

function M:UpgradeToVersion44(vars)
	if vars.Version ~= 43 then return false end

	vars.WhatsNew = vars.WhatsNew or {}
	table.insert(vars.WhatsNew, L["With the new Blizzard restrictions in 12.0.5, this is what has changed in MiniCC.\n\nThe good news:\n* Cooldown tracking still works mostly fine in arena and dungeons.\n* Added support for multiple spell charges (e.g. 2x Pain Suppression, 2x Blur) for both friendly and enemy CDs.\n\nThe bad news:\n* Friendly externals no longer track in Raids and Battlegrounds.\n* Predictive glows are less reliable.\n* PvP kick tracking can no longer identify the kicker. Now just displays a generic icon using the shortest known enemy kick cooldown.\n\nWe've put a lot of work into this update, but there may still be issues. \nPlease report any bugs you find in our Discord so we can address them."])
	vars.NotifiedChanges = false

	vars.Version = 44
	return true
end

---@return boolean true if any deferred migrations were applied
function M:RunDeferredMigrations(vars)
	local applied = false

	if vars.PendingScaleMigration26 then
		local scale = UIParent:GetScale()
		if vars.Modules then
			local ccModule = vars.Modules.CCModule
			if ccModule then
				if ccModule.Default and ccModule.Default.Icons and ccModule.Default.Icons.Size then
					ccModule.Default.Icons.Size = math.floor(ccModule.Default.Icons.Size * scale + 0.5)
				end
				if ccModule.Raid and ccModule.Raid.Icons and ccModule.Raid.Icons.Size then
					ccModule.Raid.Icons.Size = math.floor(ccModule.Raid.Icons.Size * scale + 0.5)
				end
			end
			local petCCModule = vars.Modules.PetCCModule
			if petCCModule and petCCModule.Icons and petCCModule.Icons.Size then
				petCCModule.Icons.Size = math.floor(petCCModule.Icons.Size * scale + 0.5)
			end
		end
		vars.PendingScaleMigration26 = nil
		applied = true
	end

	return applied
end

-- Opaque per-player caches that CleanTable must not recurse into.
-- "Profiles", "ActiveProfile", and "AutoSwitch" are included here because CleanTable
-- would otherwise wipe all stored profile snapshots (profile names are unknown keys
-- relative to the dbDefaults.Profiles = {} template).
local opaqueCacheKeys = { "SpecCache", "TalentCache", "PvPTalentCache", "WhatsNew", "NotifiedChanges", "Profiles", "ActiveProfile", "AutoSwitch" }

local function SaveOpaqueCaches(vars)
	local saved = {}
	for _, key in ipairs(opaqueCacheKeys) do
		saved[key] = mini:CopyValueOrTable(vars[key])
	end
	-- DisabledSpells is a user-edited hash (spellId -> true) nested inside the module options.
	-- CleanTable would strip all SpellId keys because none are in the empty-table schema, so
	-- we save and restore each module's DisabledSpells the same way as top-level opaque caches.
	local fcdModule = vars.Modules and vars.Modules.FriendlyCooldownTrackerModule
	saved._FcdDisabledSpells = fcdModule and mini:CopyValueOrTable(fcdModule.DisabledSpells) or {}
	local ecdModule = vars.Modules and vars.Modules.EnemyCooldownTrackerModule
	saved._EcdDisabledSpells = ecdModule and mini:CopyValueOrTable(ecdModule.DisabledSpells) or {}
	return saved
end

local function RestoreOpaqueCaches(vars, saved)
	for _, key in ipairs(opaqueCacheKeys) do
		vars[key] = saved[key]
	end
	local fcdModule = vars.Modules and vars.Modules.FriendlyCooldownTrackerModule
	if fcdModule then
		fcdModule.DisabledSpells = saved._FcdDisabledSpells or {}
	end
	local ecdModule = vars.Modules and vars.Modules.EnemyCooldownTrackerModule
	if ecdModule then
		ecdModule.DisabledSpells = saved._EcdDisabledSpells or {}
	end
end

---@return Db
function M:GetAndUpgradeDb()
	local isFirstTimeSetup = MiniCCDB == nil

	if isFirstTimeSetup then
		return mini:GetSavedVars(dbDefaults)
	end

	local vars = mini:GetSavedVars()

	if vars.Version and vars.Version > dbDefaults.Version then
		-- they are running some version ahead of us, let's reset to factory
		return M:SoftReset()
	end

	local isCorrupt = false

	while (vars.Version or 0) < dbDefaults.Version do
		local currentVersion = vars.Version or 0
		local nextVersion = currentVersion + 1
		local upgradeFn = M["UpgradeToVersion" .. nextVersion]

		isCorrupt = upgradeFn == nil

		if isCorrupt then
			break
		end

		local ok, result = pcall(upgradeFn, self, vars)

		if not ok or not result then
			isCorrupt = true
			break
		end
	end

	if isCorrupt then
		return M:SoftReset()
	end

	-- grab any new keys
	vars = mini:GetSavedVars(dbDefaults)

	if vars.Version == dbDefaults.Version then
		-- if we are running the latest version, clean up any garbage that may have been left over from old versions
		local caches = SaveOpaqueCaches(vars)
		mini:CleanTable(vars, dbDefaults, true, true)
		RestoreOpaqueCaches(vars, caches)
	end

	return vars
end

---Fills any missing keys in the live db from dbDefaults without overwriting existing values.
---Call this after a profile switch to ensure all settings have a value.
function M:FillDefaults()
	mini:GetSavedVars(dbDefaults)
end

---Returns a deep copy of the Modules portion of dbDefaults.
---Used by ProfileManager to reset a profile while preserving live table identities.
function M:GetModuleDefaults()
	return mini:CopyTable(dbDefaults.Modules, {})
end

---@return Db
function M:ResetToFactory()
	return mini:ResetSavedVars(dbDefaults)
end

function M:SoftReset()
	-- grab any new keys
	local vars = mini:GetSavedVars(dbDefaults)

	-- clean up any garbage
	local caches = SaveOpaqueCaches(vars)
	mini:CleanTable(vars, dbDefaults, true, true)
	RestoreOpaqueCaches(vars, caches)

	return vars
end
