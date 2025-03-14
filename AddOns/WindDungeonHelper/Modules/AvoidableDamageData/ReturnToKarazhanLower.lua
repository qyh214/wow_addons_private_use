local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 哥布林龍槍 (魅影賓客)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 21910,
	},
	{
		-- 琅琅詩詞 (鬼魅候補演員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227917,
	},
	{
		-- 勁爆終曲 (鬼魅候補演員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227925,
	},
	{
		-- 閃光 (骷髏接待員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227966,
	},
	{
		-- 閃光 (骷髏接待員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227977,
	},
	{
		-- 乾坤一擲 (鬼魅慈善家)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 228001,
	},
	{
		-- 衝鋒 (鬼靈戰騎)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 228603,
	},
	{
		-- 秘法爆發 (秘法看守者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 238606,
	},
	{
		-- 盾牌潰擊 (魅影守衛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 241774,
	},
	-- 歌劇大廳: 西荒故事
	{
		-- 烈焰掃腿
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227568,
	},
	{
		-- 洗淨一切
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227799,
	},
	-- 歌劇大廳: 美女與野獸
	{
		-- 殘羹
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 228019,
	},
	{
		-- 兇猛除塵
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 228215,
	},
	-- 獵人阿圖曼
	{
		-- 苦難共享
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 228852,
	},
	{
		-- 舉踏
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227339,
	},
	{
		-- 鬼騎衝鋒
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227645,
	},
	-- 摩洛斯
	{
		-- 喪志打擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 227672,
	},
}

local mapIds = { 809, 810, 811, 812, 813, 814 }

AD:AddData("Return to Karazhan: Lower", mistakes, mapIds)
