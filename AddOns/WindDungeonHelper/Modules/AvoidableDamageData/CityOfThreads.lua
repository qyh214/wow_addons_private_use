local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 猛毒噴霧 (皇家毒殼)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434133,
	},
	{
		-- 壓迫之鏈 (演說家克里維茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434710,
	},
	{
		-- 驚恐 (演說家克里維茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434779,
	},
	{
		-- 滯留影響 (演說家克里維茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 434926,
	},
	{
		-- 黑血 (凝結聚合體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 438601,
	},
	{
		-- 幻化異象 (『無上接合者』埃佐)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439481,
	},
	{
		-- 暗影斬擊 (倪克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439686,
	},
	{
		-- 暗影斬擊 (倪克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439687,
	},
	{
		-- 暮色使者 (倪克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 439696,
	},
	{
		-- 協調步法 (倪克斯, 薇克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 440049,
	},
	{
		-- 黑血 (凝結聚合體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443311,
	},
	{
		-- 扭曲思想 (安蘇芮克的使者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443435,
	},
	{
		-- 疑惑 (安蘇芮克的使者, 演說家克里維茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443438,
	},
	{
		-- 地裂擊 (皇家蟲群衛士, 皇家毒殼, 退休的弗爾札克領主)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443500,
	},
	{
		-- 黑暗彈幕 (Unstable Test Subject)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 445838,
	},
	{
		-- 有毒氣體
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 446084,
	},
	{
		-- 纏繞之網
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448047,
	},
	{
		-- 疑惑 (安蘇芮克的使者, 演說家克里維茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448562,
	},
	{
		-- 香水投擲 (謝非提克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 450783,
	},
	{
		-- 輕絲彈幕 (謝非提克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451426,
	},
	{
		-- 空無猛擊 (女王之眼)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 451543,
	},
	{
		-- 牢牢凍住
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 458741,
	},
	{
		-- 黑血 (凝結聚合體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 461825,
	},
	{
		-- 鮮血澎湃 (凝結聚合體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 461880,
	},
	{
		-- 黑血 (凝結聚合體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 462439,
	},
}

local mapIds = { 2343, 2344 }

AD:AddData("City of Threads", mistakes, mapIds)
