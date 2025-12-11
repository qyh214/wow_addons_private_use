local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 審問 (佐菲克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346028,
	},
	{
		-- 灑出的液體 (郵務主管)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346329,
	},
	{
		-- 殊離之環 (索阿茲米)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347481,
	},
	{
		-- 武裝保全 (佐菲克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 348366,
	},
	{
		-- 飢餓之握 (阿克魯斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349663,
	},
	{
		-- 宏偉吞噬 (阿克魯斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349801,
	},
	{
		-- 靈魄引爆 (亞奇力特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349999,
	},
	{
		-- 腐蝕靈魄 (亞奇力特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 350045,
	},
	{
		-- 旋風之滅 (溫札‧金熔)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 350090,
	},
	{
		-- 控場 (佐戈隆)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 350921,
	},
	{
		-- 散熱震盪 (亞奇力特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 351070,
	},
	{
		-- 靜電錘擊 (市集打手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 351961,
		playerIsNotTank = true,
	},
	{
		-- 裂隙衝擊 (傳送門法師佐洪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355306,
	},
	{
		-- 壓制火光 (佐戈隆)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355439,
	},
	{
		-- 震擊地雷 (指揮官佐發)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355476,
	},
	{
		-- 致命武力 (指揮官佐發)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355487,
	},
	{
		-- 震光屏障
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355502,
	},
	{
		-- 鎮壓猛襲 (市場保安官)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355638,
	},
	{
		-- 迅捷之刃 (集團潛藏者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355832,
		playerIsNotTank = true,
	},
	{
		-- 干擾手榴彈 (海關警衛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355903,
	},
	{
		-- 光束接合者 (武裝監督者, 『追蹤者』佐寇司)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356011,
	},
	{
		-- 熔岩之息 (上古熔核犬)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356404,
	},
	{
		-- 腐爛的食物 (脫序的顧客)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356482,
	},
	{
		-- 聖光裂片撤退 (集團幫派)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357019,
	},
	{
		-- 狂野痛擊 (暴怒的恐角龍)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357509,
	},
	{
		-- 不許進入！
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357799,
	},
	{
		-- 充能斬擊 (佐菲克斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1236348,
	},
}

local mapIds = { 1989, 1990, 1991, 1992, 1995, 1997, 1996, 1993 }

AD:AddData("Tazavesh: Streets of Wonder", mistakes, mapIds)
