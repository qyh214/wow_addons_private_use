local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 戰爭踐踏 (諾庫德長矛砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384336,
	},
	{
		-- 順劈打擊 (諾庫德長矛砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384512,
		playerIsNotTank = true,
	},
	{
		-- 多重射擊 (諾庫德長矛砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384868,
	},
	{
		-- 弓箭狂雨 (諾庫德長弓手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384479,
	},
	{
		-- 弧形打擊 (洪荒使者秘法劍客)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 387135,
		playerIsNotTank = true,
	},
	{
		-- 雷霆一擊 (洪荒使者雷獸)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386028,
	},
	{
		-- 風暴怒濤 (風湧圖騰)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386694,
	},
	{
		-- 風湧雷雲 (風湧圖騰)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386912,
	},
	{
		-- 風湧閃電
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384882,
	},
	{
		-- 褻瀆儀式 TODO: 來源不能確認
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 388104,
	},
	{
		-- 腐爛之風 (受辱的歐胡納鷹)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 387629,
	},
	{
		-- 死靈爆發 (烏克赫腐化者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 387611,
	},
	{
		-- 亡者聖歌 (烏克赫亡頌者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 396376,
	},
	{
		-- 廣域踐踏 (巴塔克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 382233,
	},
	{
		-- 猛烈衝鋒 (巴菈菈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 382274,
	},
	{
		-- 蹂躪之矛 (巴菈菈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 374711,
	},
	-- [1] 葛蘭尼斯
	{
		-- 地動踐踏
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 385916,
	},
	-- [2] 狂怒風暴
	{
		-- 狂怒風暴
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386916,
	},
	{
		-- 狂怒閃電
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386920,
	},
	{
		-- 電荷超載
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 391967,
	},
	-- [3] 蹄拉和莫魯克
	{
		-- 強風箭矢 (蹄拉)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386037,
	},
	{
		-- 裂地者 (莫魯克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 384960,
	},
	{
		-- 裂地者 (莫魯克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 385193,
	},
	{
		-- 裂地者 (莫魯克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 385339,
	},
	{
		-- 震盪餘波 (莫魯克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 395669,
	},
	{
		-- 恐怖咆哮 (莫魯克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 386063,
	},
	-- [4] 巴拉卡可汗
	{
		-- 剛毅狂奔
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 376685,
	},
	{
		-- 地裂崩引
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 375943,
	},
	{
		-- 轟響雷雲
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 376899,
	},
	{
		-- 轟雷動盪
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 376892,
	},
	{
		-- 閃電
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 376737,
	},
}
local mapIds = { 2093 }

AD:AddData("The Nokhud Offensive", mistakes, mapIds)
