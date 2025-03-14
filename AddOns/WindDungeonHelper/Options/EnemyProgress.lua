local W, F, L, _, O = unpack(select(2, ...))
local EP = W:GetModule("EnemyProgress")

O.enemyProgress = {
	order = 4,
	name = L["Enemy Progress"],
	type = "group",
	get = function(info)
		return W.db[info[#info - 1]][info[#info]]
	end,
	set = function(info, value)
		W.db[info[#info - 1]][info[#info]] = value
	end,
	args = {
		enable = {
			order = 1,
			name = L["Enable"],
			desc = L["Enables / disables the module"],
			type = "toggle",
			set = function(info, value)
				W.db[info[#info - 1]][info[#info]] = value
				EP:ProfileUpdate()
			end,
			width = "full",
		},
		accuracy = {
			order = 2,
			name = L["Accuracy"],
			type = "range",
			disabled = function(info)
				return not W.db.enable
			end,
			min = 0,
			max = 5,
			step = 1,
		},
	},
}
