local appName, app = ...
---@class AbilityTimeline
local private = app

private.dispellTypeList = {
	{ -- Enrage
		mask = 2,
		color = { r = 0.5137254901960784, b = 0.00392156862745098, g = 0.00392156862745098, a = 1 }
	},
	{ -- Bleed
		mask = 4,
		color = { r = 1, g = 0, b = 0, a = 1 },
	},
	{ -- Magic
		mask = 8,
		color = { r = 0, g = 0.5019607843137255, b = 1, a = 1 },
	},
	{ -- Disease
		mask = 16,
		color = { r = 1, g = 0.5019607843137255, b = 0, a = 1 },
	},
	{ -- Curse
		mask = 32,
		color = { r = 0.5019607843137255, g = 0, b = 1, a = 1 },
	},
	{ -- Poison
		mask = 64,
		color = { r = 0, g = 1, b = 0, a = 1 },
	},
}

private.IconBorderSettings = {
    dispell = "dispell",
    bossmods = "bossmods",
	none = "none",
}
