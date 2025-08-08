local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 纏繞之網
		type = AD.MISTAKE.AURA,
		aura = 436614,
	},
	{
		-- 寰宇奇異點 (『收割者』祈卡托)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432117,
	},
	{
		-- 噴發蜘蛛網 (血紅監督者, 『收割者』祈卡托)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 432132,
	},
	{
		-- 刺穿 (阿努扎克特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 433443,
	},
	{
		-- 鑽地衝鋒 (阿努扎克特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 433731,
	},
	{
		-- 無間蟲群 (阿努扎克特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 433781,
	},
	{
		-- 噴發蜘蛛網 (血紅監督者, 『收割者』祈卡托)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 433843,
	},
	{
		-- 鑽地衝鋒 (阿努扎克特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434284,
	},
	{
		-- 撒網 (阿提克, 納克特, 伊克辛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434824,
	},
	{
		-- 邪惡蛛網 (阿瓦諾克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434830,
	},
	{
		-- 毒性之雲 (阿提克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438825,
	},
	{
		-- 毒性之雲 (阿提克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438832,
	},
	{
		-- 遊絲猛襲 (阿瓦諾克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438966,
	},
	{
		-- 撒網 (阿提克, 納克特, 伊克辛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439469,
	},
	{
		-- 穿刺 (笨重血紅衛兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 453160,
	},
	{
		-- 培育毒藥 (『收割者』祈卡托)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 461507,
	},
}

local mapIds = { 2357, 2358 }

AD:AddData("Ara-Kara, City of Echoes", mistakes, mapIds)
