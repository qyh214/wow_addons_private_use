local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 嚴寒尖刺
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 324391,
	},
	{
		-- 臟腑削切 (胖子)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333477,
	},
	-- [1] 荒骨
	-- [2] 『收割者』亞瑪斯
	{
		-- 死靈吐息
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333489,
	},
	{
		-- 死靈膿液
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333492,
	},
	{
		-- Final Harvest
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321258
	},
	-- [3] 縫補師縫肉
	{
		-- 肉鉤
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 327952,
	},
	{
		-- 防腐黏液 (腳下污水)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320365,
	},
	{
		-- 防腐黏液 (腳下污水)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320366,
	},
	{
		-- 劇毒迷霧
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 327100,
	},
	{
		-- 病態凝視 (追人)
		type = AD.MISTAKE.MELEE,
		npc = 162689,
		playerDebuff = 343556,
		playerIsNotTank = true,
	},
	-- [4] 『霜縛者』納爾索
	{
		-- 彗星風暴 (楼上的)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320784,
	},
	{
		-- 彗星風暴 (楼下的)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321956,
	},
	{
		-- 鋒利碎冰 (大冰圈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 328212,
	},
	{
		-- Gruesome Cleave
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 328423,
		playerIsNotTank = true
	}
}

local mapIds = { 1666, 1667, 1668 }

AD:AddData("The Necrotic Wake", mistakes, mapIds)
