local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 虛無綁縛 (軍需官科拉泰特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426968,
	},
	{
		-- 凶暴閃電 (虛無騎士, 凱力厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 474017,
	},
	{
		-- 龍捲狂風
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 420679,
	},
	{
		-- 閃電洪流 (凱力厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 444250,
	},
	{
		-- 閃電突進 (凱力厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419871,
	},
	{
		-- 接地箭 (凱力厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214318,
	},
	{
		-- 空無激變 (虛無石巨怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423356,
	},
	{
		-- 延滯虛無 (風暴衛兵格倫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 424966,
	},
	{
		-- 黑暗重力 (風暴衛兵格倫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 425052,
	},
	{
		-- 扯裂現實 (風暴衛兵格倫)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426136,
	},
	{
		-- 滲透腐化 (腐化神諭者, 虛無石巨怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 430186,
	},
	{
		-- 滲透腐化 (腐化神諭者, 虛無石巨怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 433067,
	},
	{
		-- 沉重虛無
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 442192,
	},
	{
		-- 不穩定 (受苦的市民)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443847,
	},
	{
		-- 吸引暗影 (凝聚虛無散布者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 452932,
	},
	{
		-- 腐化之水 (虛無石巨怪)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 455220,
	},
	{
		-- 晦影浪潮 (虛無蛻變者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214550,
	},
	{
		-- 黑暗爆發 (吞噬虛無石)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214645,
	},
}

local mapIds = { 2315, 2316, 2317, 2318, 2319, 2320 }

AD:AddData("The Rookery", mistakes, mapIds)
