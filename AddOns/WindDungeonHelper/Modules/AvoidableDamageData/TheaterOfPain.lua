local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 死靈箭雨 (癲狂縛魂者, [4] 庫薩洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 317367,
	},
	{
		-- 噁心爆發 (染疫嘔泥者死亡綠圈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321041,
	},
	{
		-- 骸骨風暴 (魂鑄削骨者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 331224,
	},
	{
		-- 地面潰擊 (『毀壞者』黑文)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 332708,
	},
	{
		-- 蠻橫跳躍 (『殘暴者』多奇格)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 342126,
	},
	{
		-- 迴旋刀刃 (『割碎者』奈克薩拉)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 337037,
	},
	{
		-- 死亡之風 (會被吹下平台)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333297,
	},
	{
		-- 邪惡爆發 (腐臭肉囊 後噴)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330592,
	},
	{
		-- 邪惡爆發 (腐臭肉囊 前噴)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330608,
	},
	{
		-- 骸骨尖刺 (魂鑄削骨者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 331243,
	},
	-- [1] 蔑視挑戰者
	{
		-- 灼熱死亡 (腳下圈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333292,
		noPlayerDebuff = 333231,
	},
	-- [2] 肉排
	{
		-- 搗肉猛擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 318406,
	},
	{
		-- 鋸齒劈砍 (被勾上)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323406,
	},
	-- [3] 『未逝者』薩夫
	{
		-- 震耳衝擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 339415,
	},
	{
		-- 巨力猛劈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320729,
	},
	{
		-- 粉碎猛擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 317231,
	},
	-- [4] 庫薩洛克
	{
		-- 幻魄寄生 (腳下圈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319765,
		noPlayerDebuff = 319626,
	},
	{
		-- 抓握之手
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319639,
	},
	-- [5] 『不朽女皇』莫瑞莎
	{
		-- 黑暗破滅
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323681,
	},
	{
		-- 鬼魅衝鋒
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 339751,
	},
	{
		-- 戰鬥殘影
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 339550,
	},
}

local mapIds = { 1683, 1684, 1685, 1686, 1687 }

AD:AddData("Theater of Pain", mistakes, mapIds)
