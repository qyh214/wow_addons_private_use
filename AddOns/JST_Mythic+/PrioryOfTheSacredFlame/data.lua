local T, C, L, G = unpack(JST)

G.MobData[499] = {

	["206705"] = { -- 阿拉希步兵
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
			["SPELL_CAST_SUCCESS"] = {
				427342, -- 防御
			},
		},
	},	
	
	["206694"] = { -- 热诚的神射手
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
				462859, -- 随意射击
			},
		},
	},
	
	["206698"] = { -- 狂热的咒术师
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
				427469, -- 火球术
			},
		},
	},
	
	["206697"] = { -- 虔诚的牧师
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
				427357, -- 神圣惩击
				--427356, -- 强效治疗术
			},
		},
	},
	
	["221760"] = { -- 亡灵法师
		cc = {
			["CC_Grip"] = true,
			["CC_Stun"] = true,
			["CC_Silence"] = true,
			["CC_Disorient"] = true,
			--["CC_Fear"] = true,
			["CC_KnockOff"] = true,
			["CC_KnockBack"] = true,
		},
		spell = {
			["SPELL_CAST_START"] = {
				--427469, -- 火球术
				--444743, -- 连珠火球
			},
		},
	},
	
}