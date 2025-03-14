local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 暗焰新星 (被喚來的暗焰靈魂)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 75238,
	},
	{
		-- 熾炎斬 (鍛造大師瑟隆葛斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 447395,
	},
	{
		-- 暗焰召喚 (德拉卡‧燃影者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448028,
	},
	{
		-- 吞噬烈焰 (瓦莉歐娜)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448105,
	},
	{
		-- 暗影焰息
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448566,
	},
	{
		-- 震動的大地 (昂布里斯將軍)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448953,
	},
	{
		-- 熔岩池 (鍛造大師瑟隆葛斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449536,
	},
	{
		-- 暗影強風 (伊魯達克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449985,
	},
	{
		-- 深淵之握
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 450087,
	},
	{
		-- 晉升 (暮光操熔者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451389,
	},
	{
		-- 心靈穿刺者 (無面墮落者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451394,
	},
	{
		-- 暮光餘燼 (暮光毀滅者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451614,
	},
	{
		-- 滾燙熔岩
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 454216,
	},
	{
		-- 黑曜踐踏 (暮光蠻卒)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 456701,
	},
	{
		-- 暗影熔岩衝擊 (暮光操熔者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 456711,
	},
	{
		-- 暮光之風 (瓦莉歐娜)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 456773,
	},
	{
		-- 暗影強風 (伊魯達克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 461513,
	},
	{
		-- 燃燒的暗焰 (暮光烈焰撕裂者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 462219,
	},
	{
		-- 燃燒的暗焰 (暮光烈焰撕裂者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 462220,
	},
}

local mapIds = { 293 }

AD:AddData("Grim Batol", mistakes, mapIds)
