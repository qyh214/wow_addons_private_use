local W, F, L, _, O = unpack(select(2, ...))
local C = W.Utilities.Color

O.keystoneTooltip = {
	order = 7,
	type = "group",
	name = L["Keystone"],
	get = function(info)
		return W.db[info[#info - 1]][info[#info]]
	end,
	set = function(info, value)
		W.db[info[#info - 1]][info[#info]] = value
	end,
	args = {
		description = {
			order = 1,
			type = "description",
			width = "full",
			name = C.StringByTemplate(
				format(L["The keystone information only available for players who installed Details! or %s."], L["Wind Dungeon Helper"]),
				"warning"
			),
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L["Show the keystone information in the tooltip."],
		},
		useAbbreviation = {
			order = 3,
			type = "toggle",
			name = L["Use Abbreviation"],
			desc = L["Use abbreviation for the keystone name."],
		},
		icon = {
			order = 4,
			type = "toggle",
			name = L["Add Icon"],
			desc = L["Show an icon for the keystone."],
			disabled = function()
				return not W.db.keystoneTooltip.enable
			end,
		},
		iconWidth = {
			order = 5,
			type = "range",
			name = L["Icon Width"],
			min = 1,
			max = 50,
			step = 1,
			hidden = function()
				return not W.db.keystoneTooltip.icon
			end,
		},
		iconHeight = {
			order = 6,
			type = "range",
			name = L["Icon Height"],
			min = 1,
			max = 50,
			step = 1,
			hidden = function()
				return not W.db.keystoneTooltip.icon
			end,
		},
	},
}
