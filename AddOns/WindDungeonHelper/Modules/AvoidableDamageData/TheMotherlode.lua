local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 計時引爆
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 256137,
	},
	{
		-- 震擊猛爪 (投幣式群眾鎮壓機器人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257337,
	},
	{
		-- 催淚毒氣 (機械保安官)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257371,
	},
	{
		-- 共鳴地震 (艾澤洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 258628,
	},
	{
		-- 艾澤萊晶岩觸媒 (芮克莎‧熔焰)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 259533,
	},
	{
		-- 噴射衝擊 (芮克莎‧熔焰)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 260103,
	},
	{
		-- 格林機槍 (瑞茲當克老大)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 260279,
	},
	{
		-- 震盪衝擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 262287,
	},
	{
		-- 地雷爆炸 (爬行者地雷)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 262348,
	},
	{
		-- 採礦用定時炸彈 (到處亂炸的工兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 268365,
	},
	{
		-- 威力鑽刺
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 268417,
	},
	{
		-- 狂震 (石怒)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 268704,
	},
	{
		-- 火砲彈幕 (爆裂物專家)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 269092,
	},
	{
		-- 終極爆轟 (到處亂炸的工兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 269313,
	},
	{
		-- 劇毒淤泥
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 269831,
	},
	{
		-- 大型紅色火箭
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 270277,
	},
	{
		-- 鑽頭碎擊 (瑞茲當克老大)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 270926,
	},
	{
		-- 測試用飛彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 271432,
	},
	{
		-- 特製黑火藥
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 271583,
	},
	{
		-- 地殼碎擊 (艾澤洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 275907,
	},
	{
		-- 微型飛彈 (轟轟)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 276234,
	},
	{
		-- 艾澤萊晶岩爆發 (艾澤萊晶岩採礦機)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473198,
	},
	{
		-- 腦力激盪 (風險投資公司高階主管)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214748,
	},
	{
		-- 巨力猛擊 (監工阿斯卡利)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214754,
	},
	{
		-- 腦力激盪 (風險投資公司高階主管)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1215424,
	},
	{
		-- 催淚毒氣 (機械保安官)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217283,
	},
	{
		-- 投擲錢幣 (足球炸彈流氓)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217286,
	},
	{
		-- 震擊猛爪 (投幣式群眾鎮壓機器人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217296,
	},
}

local mapIds = { 1010 }

AD:AddData("The MOTHERLODE!!", mistakes, mapIds)
