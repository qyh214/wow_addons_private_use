local T, C, L, G = unpack(JST)

G.MobData[542] = {

	["242209"] = { -- 吃撑的幼虫
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
				1229474, -- 啃噬
			},
		},
	},
	
	["234957"] = { -- 废土遗民祭师
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
				1222815, -- 奥术箭
			},
		},
	},

}