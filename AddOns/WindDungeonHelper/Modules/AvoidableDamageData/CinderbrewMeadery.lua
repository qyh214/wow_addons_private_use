local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 灼熱蜜酒 (釀酒大師阿迪爾)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432196,
	},
	{
		-- 熾炎之息 (釀酒大師阿迪爾)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432198,
	},
	{
		-- 燼釀蜜酒投擲 (品酒室侍從)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434707,
	},
	{
		-- 高級肉排 (嚼嚼大廚)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 435000,
	},
	{
		-- 燼火爆炸！ (戈蒂‧貝倫巴特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 435788,
	},
	{
		-- 跳動烈焰
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 437965,
	},
	{
		-- 點心時間 (班克‧鳴蜂)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438651,
	},
	{
		-- 棘手狀況
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438931,
	},
	{
		-- 棘手狀況
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438933,
	},
	{
		-- 沉降趨勢 (應聲蟲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439468,
	},
	{
		-- 噴湧啤酒 (伊帕)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439991,
	},
	{
		-- 滲液蜂蜜 (酒水滴)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440087,
	},
	{
		-- 蜂蜜醃漬 (班克‧鳴蜂)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440141,
	},
	{
		-- 蜂蜜雨 (絕佳的蜂王乳供應商)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440887,
	},
	{
		-- 滲液蜂蜜 (酒水滴)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 441179,
	},
	{
		-- 蜜蠟 (風險投資公司蜂蜜收割者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 442589,
	},
	{
		-- 移行鬥毆
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 445180,
	},
	{
		-- 天降快遞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448855,
	},
	{
		-- 魯莽遞送 (粗心的蹦跳哥布林)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448920,
	},
}

local mapIds = { 2335 }

AD:AddData("Cinderbrew Meadery", mistakes, mapIds)
