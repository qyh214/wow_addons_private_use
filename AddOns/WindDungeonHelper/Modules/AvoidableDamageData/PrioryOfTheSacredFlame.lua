local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 懲戒者的引爆 (布朗派克男爵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423019,
	},
	{
		-- 純淨之錘 (布朗派克男爵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423076,
	},
	{
		-- 純淨之錘 (布朗派克男爵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423121,
	},
	{
		-- 奉獻 (忠誠聖騎士)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424430,
	},
	{
		-- 餘燼風暴 (特納‧迪爾摩)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424460,
	},
	{
		-- 野蠻潰擊 (士官謝娜梅爾)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424621,
	},
	{
		-- 淨化術 (女院長莫普芮)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 425554,
	},
	{
		-- 沐聖之地 (女院長莫普芮)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 425556,
	},
	{
		-- 烈焰風暴 (狂熱咒術師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427472,
	},
	{
		-- 烈焰風暴 (狂熱咒術師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427473,
	},
	{
		-- 烈光爆發 (聖光之子)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427601,
	},
	{
		-- 熔岩池 (鍛造大師達米安)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427900,
	},
	{
		-- 盲目之光 (女院長莫普芮)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428170,
	},
	{
		-- 神聖火焰 (女院長莫普芮)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451606,
	},
	{
		-- 釘爪刺 (熱情狙擊手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 453461,
	},
	{
		-- 碎地長矛 (德爾凱隊長)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1238782,
	},
}

local mapIds = { 2308, 2309 }

AD:AddData("Priory of the Sacred Flame", mistakes, mapIds)
