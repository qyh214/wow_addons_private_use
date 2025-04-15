local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 融化蠟液
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 421067,
	},
	{
		-- 黑焰刃鎬 (蠟燭大王)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 421282,
	},
	{
		-- 持燈者彈幕 (熾空)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 421638,
	},
	{
		-- 無畏衝鋒 (老蠟鬚)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 422125,
	},
	{
		-- 坍塌的落石 (老蠟鬚)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 422274,
	},
	{
		-- 窒息黑暗 (奔爬黑暗蛛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 422393,
	},
	{
		-- 滅焰狂風 (熾空)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 422700,
	},
	{
		-- 狂野痛擊 (高階監督者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423501,
	},
	{
		-- 激發烈焰 (熾空)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424223,
	},
	{
		-- 高速碰撞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424821,
	},
	{
		-- 敲昏！ (狗頭人差事工)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426883,
	},
	{
		-- 升騰幽影 (無邊黑暗)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426943,
	},
	{
		-- 陰晦爪擊 (無邊黑暗)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427100,
	},
	{
		-- 燃燒反噬
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428650,
	},
	{
		-- 奔騰烈焰 (徘徊之燭)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440652,
	},
	{
		-- 奔騰烈焰 (徘徊之燭)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440653,
	},
	{
		-- 點燃地獄火 (熾空)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443969,
	},
	{
		-- 燃燒的蠟燭 (灰鼻子)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1218133,
	},
}

local mapIds = { 2303 }

AD:AddData("Darkflame Cleft", mistakes, mapIds)
