local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 爆裂絲繭
		type = AD.MISTAKE.AURA,
		aura = 451104,
	},
	{
		-- 黑暗傷痕 (阿努比卡杰, 『死亡尖嘯者』伊坎特克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427378,
	},
	{
		-- 阿拉希飛船火砲
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 430655,
	},
	{
		-- 折磨爆發 (夜暮黑暗建造者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 431352,
	},
	{
		-- 黯黑邊緣 (夜暮謀士)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 431494,
	},
	{
		-- 冥魄之種 (夜暮祭儀師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432454,
	},
	{
		-- 黑雹 (現形暗影)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432606,
	},
	{
		-- 黏網 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434096,
	},
	{
		-- 腐蝕 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434579,
	},
	{
		-- 阿拉希炸彈 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434655,
	},
	{
		-- 酸液之池 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438956,
	},
	{
		-- 酸液之池 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438957,
	},
	{
		-- 驅逐蛛網 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448215,
	},
	{
		-- 遁入暗影
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449335,
	},
	{
		-- 黑暗降臨 (代言者影冠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451032,
	},
	{
		-- 阿拉希炸彈 (菈夏南)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451093,
	},
	{
		-- 黏性新星 (蘇芮基戰士)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451098,
	},
	{
		-- 崩解之夜 (代言者影冠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 453173,
	},
	{
		-- 黑曜光束 (代言者影冠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 453214,
	},
	{
		-- 黑暗傷痕 (阿努比卡杰, 『死亡尖嘯者』伊坎特克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 460135,
	},
}

local mapIds = { 2359 }

AD:AddData("The Dawnbreaker", mistakes, mapIds)
