local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 黏著寄生 (沼地怪幼體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 335882,
	},
	{
		-- 振翅攻擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330404,
	},
	{
		-- 腐臭膽汁 (噴湧軟泥)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319120,
	},
	{
		-- 瘟疫炸彈 (路上炸彈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 328501,
	},
	{
		-- 毒液池 (腐爛的血肉巨人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320072,
	},
	{
		-- 鋸齒脊刺 (荒蕪斷脊者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320519,
	},
	{
		-- 膿瘡噴射 (荒蕪斷脊者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 318949,
	},
	{
		-- 嘔吐瘟疫
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 327233,
	},
	-- [1] 葛洛格羅
	{
		-- 軟泥波
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 324667,
	},
	{
		-- 軟泥波
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326242,
	},
	-- [2] 伊克思博士
	{
		-- 黏液爆發
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 333808,
	},
	{
		-- 軟泥突擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 329217,
	},
	-- [3] 多米娜‧毒刃
	-- [4] 藩侯史特拉達瑪
	{
		-- 瘟疫撞擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 322475,
	},
	{
		-- 瘟疫泉源
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 330135,
	},
}

local mapIds = { 1674, 1697 }

AD:AddData("Plaguefall", mistakes, mapIds)
