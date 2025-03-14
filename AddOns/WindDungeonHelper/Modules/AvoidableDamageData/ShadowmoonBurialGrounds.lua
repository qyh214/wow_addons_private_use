local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 猛撞 (食腐骨蟲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153686,
	},
	{
		-- 地底爆發 (虛無生靈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 365201,
	},
	{
		-- 暗影符文 (地板)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 152696,
	},
	-- [1] 莎妲娜‧血怒
	{
		-- 黑暗之蝕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 164686,
		noPlayerDebuff = 162652,
	},
	{
		-- 暗影燃烧
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153224,
	},
	{
		-- 暗影符文
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 152688,
	},
	-- [2] 納里旭
	{
		-- 虛無漩渦
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 152800,
	},
	{
		-- 虛無破壞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153072,
	},
	{
		-- 虛無衝擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153501,
		playerIsNotTank = true,
	},
	-- [3] 骨喉
	{
		-- 猛撞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153395,
	},
	{
		-- 吸入
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 153908,
	},
	-- [4] 耐祖奧
	{
		-- 惡意
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 154442,
	},
	{
		-- 祭儀骸骨
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 154469,
	},
}

local mapIds = { 574, 575, 576 }

AD:AddData("Shadowmoon Burial Grounds", mistakes, mapIds)
