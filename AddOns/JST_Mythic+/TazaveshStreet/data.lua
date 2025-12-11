local T, C, L, G = unpack(JST)

G.MobData[391] = {

	["177817"] = { -- 支援警官
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
				354297, -- 凌光箭
				--355934, -- 强光屏障
			},
		},
	},	
	
	["180336"] = { -- 财团智囊
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
				357196, -- 凌光箭
			},
		},
	},
	
	["176395"] = { -- 过载的邮件元素
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
				347903, -- 垃圾邮件
				--347775, -- 垃圾信息过滤
			},
		},
	},
}