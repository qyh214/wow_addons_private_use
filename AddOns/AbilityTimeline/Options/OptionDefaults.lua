local appName, app = ...
---@class AbilityTimeline
local private = app

private.OptionDefaults = {
	profile = {
		debugMode = false,
		useAudioCountdowns = true,
		enableKeyRerollTimer = true,
		icon_settings = {
			size = 50,
			iconMargin = 5,
		},
		reminders = {},
		editor = {
			defaultEncounterDuration = 300,
		},
		disableAllOnEncounterEnd = true,
		enableDNDMessage = true,
		disableLoginMessage = false,
		disableReadyCheck = false,
	}
}
