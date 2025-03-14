local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- 小怪
	{
		-- 黑石炸彈 (恐軌投彈手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 164188,
	},
	{
		-- 破片射擊 (格羅姆卡槍手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 156303,
	},
	{
		-- 黑石迫擊炮 (格羅姆卡砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 160963,
	},
	{
		-- 黑石手榴彈 (格羅姆卡擲彈手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 161153,
	},
	{
		-- 風暴之盾 (格羅姆卡先知)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 166336,
	},
	{
		-- 雷獄 (格羅姆卡先知)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 166340,
	},
	{
		-- 火舌 (格羅姆卡識燼者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 176033,
	},
	{
		-- 火舌 (格羅姆卡識燼者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 176039,
	},
	{
		-- 火砲彈幕 (格羅姆卡砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 176131,
	},
	-- [1] 火箭光和波爾卡
	{
		-- 瘋狂衝刺
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 161089,
	},
	{
		-- VX18-B目標殲滅者
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 162513,
	},
	-- [2] 奈楚格‧雷塔
	{
		-- 壓制射擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 161220,
	},
	{
		-- 黑石迫擊炮
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 163741,
	},
	-- [3] 傲天者托芙菈
	{
		-- 散射能量
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 161588,
	},
	{
		-- 冰凍陷阱
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 162065,
	},
	{
		-- 旋轉長矛
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 162057,
	},
}

local mapIds = { 606, 607, 608, 609 }

AD:AddData("Grimrail Depot", mistakes, mapIds)
