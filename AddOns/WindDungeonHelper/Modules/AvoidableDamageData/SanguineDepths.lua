local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 回音戳刺 (本體)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320999,
	},
	{
		-- 回音戳刺 (鏡像)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 320991,
	},
	{
		-- 易爆陷阱 (恐怖神獵手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 334563,
	},
	{
		-- 橫掃揮擊 (監護長賈夫臨 面前放風)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 334615,
	},
	{
		-- 斷魂削砍 (大石像鬼正面順劈)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 322429,
		playerIsNotTank = true,
	},
	{
		-- 爆裂皮紙 (研究紀錄者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 334378,
	},
	{
		-- 峭岩裂石
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 322418,
	},
	-- [1] 貪婪的奎西斯
	-- [2] 處決者塔沃德
	{
		-- 罪觸靈魄
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 328494,
	},
	{
		-- 殘渣
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323573,
	},
	-- [3] 總監督者貝莉亞
	{
		-- 苦痛狂嚎
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 325885,
	},
	{
		-- 滋長的猜忌
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 322212,
	},
	-- [4] 凱厄將軍
	{
		-- 穿透殘影
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323810,
	},
	{
		-- 沉鬱疾風
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323810,
		noPlayerBuff = 324092,
	},
}

local mapIds = { 1675, 1676 }

AD:AddData("Sanguine Depths", mistakes, mapIds)
