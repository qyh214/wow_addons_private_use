local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 高殺傷性松鼠
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 293861,
	},
	{
		-- 音波脈衝 (砲轟機器人X-80型, 蜘蛛坦克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 293986,
	},
	{
		-- 發射高爆火箭
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
		-- 熔爐火焰
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 301299,
	},
	{
		-- 處理廢料
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294291,
	},
	{
		-- 強力鑽刺 (廢棄物處理器)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294324,
	},
	{
		-- 電鋸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 282945,
	},
	{
		-- 極限衝刺 (地精鏟肉機)
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
	{
		-- 空投 (K.U.-J.0.機械犬)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291930,
	},
	{
		-- 噴射烈焰 (K.U.-J.0.機械犬)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291946,
	},
	{
		-- 垃圾炸彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291953,
	},
	{
		-- 混-亂-榴彈 (首席機械師火熔)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285454,
	},
	{
		-- 自我修剪樹籬 (首席機械師火熔)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294954,
	},
	{
		-- 校準 (空中單位R-21/X型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291856,
	},
	{
		-- 電漿球 (空中單位R-21/X型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291915,
	},
	{
		-- B.4.T.T.L.3.地雷 (地精鏟肉機)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285377,
	},
	{
		-- 「隱藏式」烈焰火砲 (首席機械師火熔)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285443,
	},
	{
		-- 混-亂-榴彈 (首席機械師火熔)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 285460,
	},
	{
		-- 起飛！ (空中單位R-21/X型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291613,
	},
	{
		-- 切割光束 (空中單位R-21/X型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291914,
	},
	{
		-- 噴射烈焰 (K.U.-J.0.機械犬)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 291949,
	},
	{
		-- 熔爐火焰
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294549,
	},
	{
		-- 咆哮之焰 (不起眼的植物)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 294869,
	},
	{
		-- 蓄電領域
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1213154,
	},
	{
		-- B.4.T.T.L.3.地雷 (地精鏟肉機)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1215039,
	},
}

local mapIds = { 1490, 1491, 1493, 1494, 1497 }

AD:AddData("Operation: Mechagon - Workshop", mistakes, mapIds)
