local T, C, L, G = unpack(JST)

G.MobData[378] = {

	["164562"] = { -- 堕落的驯犬者
		cc = {
			["CC_Grip"] = true,
			["CC_Stun"] = true,
			["CC_Silence"] = true,
			["CC_Disorient"] = true,
			["CC_Fear"] = true,
			["CC_KnockOff"] = true,
			["CC_KnockBack"] = true,
		},
		spell = {
			["SPELL_CAST_START"] = {
				325535, -- 射击
				--326450, -- 忠心的野兽
			},
		},
	},	
	
	["165414"] = { -- 堕落的歼灭者
		cc = {
			["CC_Grip"] = true,
			["CC_Stun"] = true,
			["CC_Silence"] = true,
			["CC_Disorient"] = true,
			["CC_Fear"] = true,
			["CC_KnockOff"] = true,
			["CC_KnockBack"] = true,
		},
		spell = {
			["SPELL_CAST_START"] = {
				338003, -- 邪恶箭矢
			},
		},
	},

}