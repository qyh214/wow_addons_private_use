local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 死靈箭雨 (庫薩洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 317367,
	},
	{
		-- 噁心爆發 (噁心廢棄物, 染疫嘔泥者)
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
		-- 蠻橫跳躍
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 342126,
	},
	{
		-- 迴旋刀刃 (『割碎者』奈克薩拉, 『嗜血者』哈魯吉亞)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 337037,
	},
	{
		-- 死亡之風 (惡毒暗語者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333297,
	},
	{
		-- 邪惡爆發 (腐臭肉囊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330592,
	},
	{
		-- 邪惡爆發 (腐臭肉囊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330608,
	},
	{
		-- 骸骨尖刺 (魂鑄削骨者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 331243,
	},
	{
		-- 灼熱死亡 (『詛咒者』薩賽爾)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333292,
		noPlayerDebuff = 333231,
	},
	{
		-- 搗肉猛擊 (肉排)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 318406,
	},
	{
		-- 鋸齒劈砍
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323406,
	},
	{
		-- 震耳衝擊 (『未逝者』薩夫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 339415,
	},
	{
		-- 巨力猛劈 (『未逝者』薩夫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320729,
	},
	{
		-- 粉碎猛擊 (『未逝者』薩夫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 317231,
	},
	{
		-- 幻魄寄生
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319765,
		noPlayerDebuff = 319626,
	},
	{
		-- 抓握之手
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319639,
	},
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
		-- 戰鬥殘影 (『不朽女皇』莫瑞莎)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 339550,
	},
	{
		-- 死亡螺旋 (庫薩洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473519,
	},
	{
		-- 碎地者 (『殘暴者』多奇格)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1213695,
	},
	{
		-- 毒孢子 (『劇毒者』帕瑟朗)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1215636,
	},
	{
		-- 凋零吐息 (『劇毒者』帕瑟朗)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1215738,
	},
	{
		-- 死亡螺旋 (庫薩洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1223240,
	},
}

local mapIds = { 1683, 1684, 1685, 1686, 1687 }

AD:AddData("Theater of Pain", mistakes, mapIds)
