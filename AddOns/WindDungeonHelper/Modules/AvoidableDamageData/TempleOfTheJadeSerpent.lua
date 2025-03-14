local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 洶湧洪水 (腐化的活水元素)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 397881,
	},
	{
		-- 痛苦之淚 (愛哭猴)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 396010,
	},
	{
		-- 疑惑烈焰 (蹣跚的感染者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 398301,
	},
	{
		-- 掃葉腿 (煞化守護者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 397899,
	},
	{
		-- 玷污迷霧 (腐敗的織霧者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 397914,
	},
	{
		-- 粉碎決心 (疑惑之煞的爪牙)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 110125,
	},
	{
		-- 領地顯示 (鳴禽之后)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 396003,
	},
	-- [1] 智者瑪利
	{
		-- 沖走
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 397785,
	},
	{
		-- 腐化噴泉
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 397793,
	},
	-- [2] 博學行者石步
	-- [3] 劉‧焰心
	{
		-- 玉蛟踢
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 106864,
	},
	{
		-- 蛟龍踢
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 106856,
	},
	{
		-- 玉蛟波
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 107053,
	},
	{
		-- 玉蛟波
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 118540,
	},
	{
		-- 蛟龍波
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 106938,
	},
	{
		-- 翠玉火焰吐息
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 396907,
	},
	{
		-- 翠玉火焰召喚
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 107103,
	},
	{
		-- 翠玉火焰
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 107110,
	},

	-- [4] 疑惑之煞
}

local mapIds = { 429, 430 }

AD:AddData("Temple of the Jade Serpent", mistakes, mapIds)
