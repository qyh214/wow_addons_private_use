local T, C, L, G = unpack(JST)

G.MobData[503] = {

	["216293"] = { -- 颤声侍从
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
				434786, -- 蛛网箭
				--434793, -- 共振弹幕
			},
		},
	},
	
	["223253"] = { -- 沾血的网法师
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
				434786, -- 蛛网箭
				--448248, -- 恶臭齐射
			},
		},
	},
	
	["216340"] = { -- 哨兵鹿壳虫
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
				432967, -- 预警尖鸣
			},
		},
	},
	
	["216365"] = { -- 飞翼运输者
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
				433821, -- 冲刺打击
			},
		},
	},
}

