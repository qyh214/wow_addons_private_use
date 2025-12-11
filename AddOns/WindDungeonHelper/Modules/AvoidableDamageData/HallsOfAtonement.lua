local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 罪光幻象
		type = AD.MISTAKE.AURA,
		aura = 339237,
	},
	{
		-- 血腥洪流 (艾可隆)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319702,
	},
	{
		-- 血腥洪流 (艾可隆)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 319703,
	},
	{
		-- 玻璃裂片 (哈奇厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323001,
		playerIsNotTank = true,
	},
	{
		-- 念力碰撞
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323126,
	},
	{
		-- 釋放磨難 (宮務大臣)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 323236,
	},
	{
		-- 折射罪光 (哈奇厄斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 324044,
	},
	{
		-- 致命推進
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 325523,
	},
	{
		-- 急速射擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 325799,
	},
	{
		-- 罪孽震盪 (哈奇厄斯裂片)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326440,
	},
	{
		-- 苦痛 (嫉妒化身)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326891,
	},
	{
		-- 強力揮擊 (石源魔斬擊者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 326997,
		playerIsNotTank = true,
	},
	{
		-- 爆發折磨 (宮務大臣)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1236964,
	},
	{
		-- 念力猛襲 (宮務大臣)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 329113,
	},
	{
		-- 靈魄泉 (靈魄泉, 至高判決者阿利茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 329340,
	},
	{
		-- 靈魄泉 (靈魄泉, 至高判決者阿利茲)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 338013,
	},
	{
		-- 岩石之息
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346866,
		playerIsNotTank = true,
	},
}

local mapIds = { 1663, 1664, 1665 }

AD:AddData("Halls of Atonement", mistakes, mapIds)
