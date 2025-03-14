local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 騎士出動 (騎士)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229298,
	},
	{
		-- 騎士出動 (騎士)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229563,
	},
	{
		-- 皇后出動 (皇后)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229384,
	},
	{
		-- 皇家斬擊 (國王)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229427,
	},
	{
		-- 主教出動 (主教)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229559,
	},
	{
		-- 城堡出動 (城堡)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229568,
	},
	{
		-- 燒灼方格 (憤怒守衛烈焰使者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229988,
	},
	{
		-- 不穩定的能量 (受損的魔像)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 242894,
	},
	{
		-- 奔竄 (老鼠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229696,
	},
	{
		-- 魔化炸彈 (溢能火占師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229678,
	},
	{
		-- 魔化迫擊砲 (魔化蝙蝠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229597,
	},
	{
		-- 順劈斬 (憤怒守衛烈焰使者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 230044,
		playerIsNotTank = true,
	},
	-- [1] 館長
	{
		-- 能量釋放
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227285,
	},
	{
		-- 能量釋放
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227465,
	},
	-- [2] 麥迪文之影
	{
		-- 不絕寒冬
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227806,
	},
	-- [3] 法力吞噬者
	{
		-- 秘法炸彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227620,
	},
	-- [4] 『監視者』維茲亞頓
	{
		-- 崩解
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229151,
	},
	{
		-- 爆裂黑影
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229161,
	},
	{
		-- 魔化能量光束
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229248,
	},
	{
		-- 轟炸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 229285,
	},
}

local mapIds = { 815, 816, 817, 818, 819, 820, 821, 822 }

AD:AddData("Return to Karazhan: Upper", mistakes, mapIds)
