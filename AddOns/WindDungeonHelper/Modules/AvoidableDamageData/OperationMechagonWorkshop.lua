local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 高殺傷性松鼠 (高殺傷性松鼠)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 293861,
	},
	{
		-- 音波脈衝 (砲轟機器人X-80型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 293986,
	},
	{
		-- 發射高爆性火箭 (砲轟機器人X-80型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294015,
	},
	{
		-- 電容器釋電 (砲轟機器人X-80型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 295168,
	},
	{
		-- 火箭彈幕 (火箭機兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294128,
	},
	{
		-- 熔爐火焰 (傳送帶)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 301299,
	},
	{
		-- 處理廢料 (廢棄物處理器)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294291,
	},
	{
		-- 強力鑽刺 (廢棄物處理器)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294324,
	},
	-- 暴力機兵
	{
		-- 電鋸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 282945,
	},
	{
		-- 極限衝刺
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 283422,
	},
	{
		-- 迴旋刀刃
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285020,
	},
	{
		-- 設置詭雷
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285344,
	},
	-- K.U.-J.0.機械犬
	{
		-- 空投
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291930,
	},
	{
		-- 噴射烈焰
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291946,
	},
	{
		-- 垃圾炸彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291953,
	},
	-- 機械工花園
	{
		-- 混-亂-榴彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285454,
	},
	{
		-- 自我修剪樹籬
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294954,
	},
	-- 機械岡國王
	{
		-- 校準
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291856,
	},
	{
		-- 電漿球
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291915,
	},
}

local mapIds = { 1491, 1493, 1494, 1497 }

AD:AddData("Operation: Mechagon - Workshop", mistakes, mapIds)
