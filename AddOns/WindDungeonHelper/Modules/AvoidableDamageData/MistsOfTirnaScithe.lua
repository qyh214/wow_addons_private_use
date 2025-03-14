local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 困惑花粉 (面前衝擊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321968,
	},
	{
		-- 刺藤爆發(佐司特斷枝者 緩速黑水)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 325027,
	},
	{
		-- 後背踢 (霧紗守護者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 331748,
	},
	{
		-- 長舌鞭笞 (青蛙怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 340300,
	},
	{
		-- 毒性分泌物 (青蛙怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 340304,
	},
	{
		-- 長矛亂舞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 331721,
		playerIsNotTank = true,
	},
	{
		-- 璀璨之息
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 340160,
	},
	-- [1] 英拉馬洛克
	{
		-- 靈魄之潭 (藍色污水)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323250,
	},
	{
		-- 困惑花粉 (面前衝擊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323137,
	},
	-- [2] 喚霧者
	{
		-- 拍蛋糕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321828,
	},
	{
		-- 躲避球
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 336759,
	},
	{
		-- 冰凍衝擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 321893,
	},
	-- [3] 崔朵瓦
	{
		-- 酸液滴
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326021,
	},
	{
		-- 消化酸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326309,
	},
	{
		-- 酸液噴吐
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 322655,
	},
}

local mapIds = { 1669 }

AD:AddData("Mists of Tirna Scithe", mistakes, mapIds)
