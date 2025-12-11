local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 近戰 (海盜蠻兵)
		type = AD.MISTAKE.MELEE,
		npc = 177500,
	},
	{
		-- 致命汪洋
		type = AD.MISTAKE.AURA,
		aura = 347422,
	},
	{
		-- 淨化力場 (海布藍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346828,
	},
	{
		-- 淨滅火焰 (巨大防禦砲塔, 海布藍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346960,
	},
	{
		-- 淨滅力場 (海布藍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346961,
	},
	{
		-- 泰坦撞擊 (海布藍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347094,
	},
	{
		-- 無限吐息 (時光船長鉤尾)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347149,
	},
	{
		-- 火砲彈幕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347370,
	},
	{
		-- 致命汪洋
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347423,
	},
	{
		-- 能量分離 (索利亞, 創先者文物)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 351101,
	},
	{
		-- 極光新星 (索利亞, 創先者文物)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 351646,
	},
	{
		-- 易爆河豚 (暗洋魚法師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355234,
	},
	{
		-- 爆炸河豚 (暗洋魚法師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355423,
	},
	{
		-- 巨石投擲 (岸行者巨人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355465,
	},
	{
		-- 轟雷 (風鑄守護者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355581,
	},
	{
		-- 充電脈衝 (風鑄守護者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355584,
	},
	{
		-- 潮汐爆發 (沙漏號浪潮賢者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356260,
	},
	{
		-- 符文回應 (海布藍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356796,
	},
	{
		-- 漂流之星 (絢麗觀星者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357228,
	},
	{
		-- 燃燒焦油
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 358947,
	},
}

local mapIds = { 1989, 1990, 1991, 1992, 1995, 1997, 1996, 1993 }

AD:AddData("Tazavesh: So'leah's Gambit", mistakes, mapIds)
